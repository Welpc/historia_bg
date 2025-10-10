local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")
local TweenService = game:GetService("TweenService")
local BillsStore = DataStoreService:GetDataStore("PlayerBilletes")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local JobId = game.JobId

-- ============================================
-- VARIABLES GLOBALES
-- ============================================
local MultiServerEvents = {
	ActiveEvents = {}
}

local MeteorShowerModule
local hasMeteorModule = pcall(function()
	MeteorShowerModule = require(script.Parent:WaitForChild("MeteorShowerModule"))
end)

-- Variables para controlar el sistema de humo
local humoActivo = false
local tiempoHumo = 300
local humoTween

-- Variables para controlar el modo cámara
local primeraPersonaActivada = false

-- Variables para controlar la música
local mainMusic = Workspace:FindFirstChild("MainMusic")
local customMusicPlaying = false

-- Configuración del sistema de humo
local fuegoID = 8651011854
local cantidadFuego = 1000

-- Variables de lluvia
local lluviaActiva = false
local lluviaGrandeId = 5338590536
local lluviaChicaId = 4451256888
local lluviaObjeto = nil
local lluviaParticulas = {}

-- ============================================
-- CREAR REMOTEEVENTS
-- ============================================
local MeteorEvent = Instance.new("RemoteEvent")
MeteorEvent.Name = "MeteorEvent"
MeteorEvent.Parent = ReplicatedStorage

local AudioEvent = Instance.new("RemoteEvent")
AudioEvent.Name = "AudioEvent"
AudioEvent.Parent = ReplicatedStorage

local SpeedEvent = Instance.new("RemoteEvent")
SpeedEvent.Name = "SpeedEvent"
SpeedEvent.Parent = ReplicatedStorage

local FlyEvent = Instance.new("RemoteEvent")
FlyEvent.Name = "FlyEvent"
FlyEvent.Parent = ReplicatedStorage

local MoneyEvent = Instance.new("RemoteEvent")
MoneyEvent.Name = "MoneyEvent"
MoneyEvent.Parent = ReplicatedStorage

local TroncosEvent = Instance.new("RemoteEvent")
TroncosEvent.Name = "TroncosEvent"
TroncosEvent.Parent = ReplicatedStorage

local HumoEvent = Instance.new("RemoteEvent")
HumoEvent.Name = "HumoEvent"
HumoEvent.Parent = ReplicatedStorage

local LluviaEvent = Instance.new("RemoteEvent")
LluviaEvent.Name = "LluviaEvent"
LluviaEvent.Parent = ReplicatedStorage

local MultiServerEvent = Instance.new("RemoteEvent")
MultiServerEvent.Name = "MultiServerEvent"
MultiServerEvent.Parent = ReplicatedStorage

local MessageEvent = Instance.new("RemoteEvent")
MessageEvent.Name = "MessageEvent"
MessageEvent.Parent = ReplicatedStorage

-- ============================================
-- FUNCIONES AUXILIARES
-- ============================================
local function sendMessageToPlayer(player, text, color)
	if player and player.Character and player.Character:FindFirstChild("Head") then
		local chatService = game:GetService("Chat")
		chatService:Chat(player.Character.Head, text, color or Enum.ChatColor.White)
	end
end

local function broadcastMessage(text, color)
	for _, player in ipairs(Players:GetPlayers()) do
		sendMessageToPlayer(player, text, color)
	end
end

local function publishToAllServers(eventName, data)
	if eventName == "MultiServerMessage" then
		local success, errorMessage = pcall(function()
			MessagingService:PublishAsync("MultiServerMessage", {
				Sender = JobId,
				Data = data,
				Timestamp = os.time()
			})
		end)

		if not success then
			warn("Error al publicar mensaje multi-servidor: " .. tostring(errorMessage))
		end
	else
		local success, errorMessage = pcall(function()
			MessagingService:PublishAsync(eventName, {
				Sender = JobId,
				Data = data,
				Timestamp = os.time()
			})
		end)

		if not success then
			warn("Error al publicar evento " .. eventName .. ": " .. tostring(errorMessage))
		end
	end
end

-- ============================================
-- SISTEMA DE CÁMARA EN PRIMERA PERSONA
-- ============================================
local function forzarPrimeraPersona(player)
	player.CameraMode = Enum.CameraMode.LockFirstPerson

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end

	print("📷 Cámara en primera persona forzada para: " .. player.Name)
end

local function restaurarCamaraNormal(player)
	player.CameraMode = Enum.CameraMode.Classic

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end

	print("📷 Cámara restaurada para: " .. player.Name)
end

local function togglePrimeraPersona(activar)
	primeraPersonaActivada = activar

	if activar then
		print("🔒 Activando primera persona para todos los jugadores...")
		for _, player in ipairs(Players:GetPlayers()) do
			forzarPrimeraPersona(player)
		end
	else
		print("🔓 Desactivando primera persona...")
		for _, player in ipairs(Players:GetPlayers()) do
			restaurarCamaraNormal(player)
		end
	end
end

-- ============================================
-- SISTEMA DE HUMO
-- ============================================
local function limpiarHumo()
	local humosEliminados = 0

	local pasto1 = Workspace:FindFirstChild("pasto1")
	if pasto1 then
		for _, obj in ipairs(pasto1:GetChildren()) do
			if obj.Name == "FuegoClon" then
				obj:Destroy()
				humosEliminados = humosEliminados + 1
			end
		end
	end

	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name == "FuegoClon" then
			obj:Destroy()
			humosEliminados = humosEliminados + 1
		end
	end

	if humoTween then
		humoTween:Cancel()
		humoTween = nil
	end

	return humosEliminados
end

local function crearSistemaHumo()
	local pasto1 = Workspace:FindFirstChild("pasto1")
	if not pasto1 then
		warn("❌ No se encontró 'pasto1' en el Workspace")
		return false
	end

	print("✅ Encontrado pasto1 existente, dispersando modelos en él...")

	local humosEliminados = limpiarHumo()
	print("🗑️ Humos eliminados: " .. humosEliminados)

	local ok, fuegoModelo = pcall(function()
		return InsertService:LoadAsset(fuegoID)
	end)

	if not ok or not fuegoModelo then 
		warn("❌ Error al cargar el modelo de humo")
		return false
	end

	local fuegoOriginal
	for _, child in ipairs(fuegoModelo:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			fuegoOriginal = child
			break
		end
	end

	if not fuegoOriginal then
		warn("❌ No se encontró el modelo de humo")
		return false
	end

	local pastoSize = pasto1.Size
	local pastoPosition = pasto1.Position

	local minX = pastoPosition.X - (pastoSize.X / 2)
	local minZ = pastoPosition.Z - (pastoSize.Z / 2)
	local baseY = pastoPosition.Y + (pastoSize.Y / 2) + 0.3

	local humosCreados = 0
	for i = 1, cantidadFuego do
		local fuego = fuegoOriginal:Clone()
		fuego.Name = "FuegoClon"

		local randomX = minX + math.random() * pastoSize.X
		local randomZ = minZ + math.random() * pastoSize.Z
		local randomY = baseY + math.random() * 0.7

		if fuego:IsA("Model") then
			local primaryPart = fuego.PrimaryPart or fuego:FindFirstChildWhichIsA("BasePart")
			if primaryPart then
				fuego:PivotTo(CFrame.new(randomX, randomY, randomZ))
			else
				for _, part in ipairs(fuego:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Position = Vector3.new(randomX, randomY, randomZ)
						break
					end
				end
			end
		else
			fuego.Position = Vector3.new(randomX, randomY, randomZ)
		end

		fuego.Parent = pasto1
		humosCreados = humosCreados + 1

		if i % 25 == 0 then
			task.wait(0.02)
		end
	end

	togglePrimeraPersona(true)

	print("✅ Sistema de humo creado con " .. humosCreados .. " modelos dispersados en pasto1")
	print("📷 Primera persona activada para todos")
	return true
end

local function activarSistemaHumo(duracionMinutos)
	if humoActivo then
		broadcastMessage("Evento de humo ya está activo!", Enum.ChatColor.Yellow)
		return
	end

	tiempoHumo = duracionMinutos * 60

	local exito = crearSistemaHumo()
	if not exito then
		broadcastMessage("❌ Error al crear el sistema de humo", Enum.ChatColor.Red)
		return
	end

	humoActivo = true
	broadcastMessage("💨 HUMO ACTIVADO por " .. duracionMinutos .. " minutos", Enum.ChatColor.Green)
	broadcastMessage("📷 Cámara en primera persona activada", Enum.ChatColor.Green)

	spawn(function()
		local tiempoRestante = tiempoHumo
		while tiempoRestante > 0 and humoActivo do
			if tiempoRestante % 60 == 0 or tiempoRestante <= 10 then
				local minutos = math.floor(tiempoRestante / 60)
				local segundos = tiempoRestante % 60
				broadcastMessage("💨 Humo activo: " .. minutos .. "m " .. segundos .. "s restantes", Enum.ChatColor.Yellow)
			end
			wait(1)
			tiempoRestante = tiempoRestante - 1
		end

		if humoActivo then
			desactivarSistemaHumo()
			broadcastMessage("💨 EVENTO DE HUMO TERMINADO", Enum.ChatColor.Blue)
		end
	end)
end

local function desactivarSistemaHumo()
	if not humoActivo then
		broadcastMessage("No hay evento de humo activo", Enum.ChatColor.Yellow)
		return
	end

	local humosEliminados = limpiarHumo()
	humoActivo = false

	togglePrimeraPersona(false)

	broadcastMessage("💨 Evento de humo desactivado", Enum.ChatColor.Blue)
	broadcastMessage("📷 Cámara restaurada a normal", Enum.ChatColor.Blue)
	print("Evento de humo desactivado. Humos eliminados: " .. humosEliminados)
end

-- ============================================
-- SISTEMA DE LLUVIA
-- ============================================
local function configurarModelo(modelo)
	for _, obj in ipairs(modelo:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = false
			obj.CanTouch = false
			obj.Anchored = true
			obj.Transparency = 1
		end
	end
end

local function activarLluvia()
	if lluviaActiva then
		return
	end

	local pasto1 = Workspace:FindFirstChild("pasto1")
	if not pasto1 then
		warn("❌ No se encontró 'pasto1' en el Workspace")
		return
	end

	print("✅ Activando lluvia en pasto1...")

	local ok, asset = pcall(function()
		return InsertService:LoadAsset(lluviaGrandeId)
	end)

	if ok and asset then
		local modelo = asset:GetChildren()[1]
		if modelo then
			modelo.Parent = Workspace
			modelo.Name = "LluviaActiva"
			local offsetY = 40
			modelo:PivotTo(pasto1.CFrame * CFrame.new(0, offsetY, 0))

			configurarModelo(modelo)

			lluviaObjeto = modelo
		end
	end

	local lluviasCreadas = 0
	for i = 1, 100 do
		local ok2, asset2 = pcall(function()
			return InsertService:LoadAsset(lluviaChicaId)
		end)

		if ok2 and asset2 then
			local modeloChico = asset2:GetChildren()[1]
			if modeloChico then
				modeloChico.Parent = pasto1
				modeloChico.Name = "LluviaChica_" .. i

				local size = pasto1.Size
				local randomX = math.random(-size.X/2, size.X/2)
				local randomZ = math.random(-size.Z/2, size.Z/2)
				local pos = pasto1.Position + Vector3.new(randomX, 3, randomZ)
				modeloChico:PivotTo(CFrame.new(pos))

				configurarModelo(modeloChico)

				table.insert(lluviaParticulas, modeloChico)
				lluviasCreadas = lluviasCreadas + 1
			end
		end

		if i % 25 == 0 then
			task.wait(0.02)
		end
	end

	lluviaActiva = true
	print("✅ Lluvia activada con " .. lluviasCreadas .. " partículas en pasto1")
	broadcastMessage("🌧️ LLUVIA ACTIVADA", Enum.ChatColor.Blue)
end

local function desactivarLluvia()
	if not lluviaActiva then
		return
	end

	if lluviaObjeto and lluviaObjeto.Parent then
		lluviaObjeto:Destroy()
	end
	lluviaObjeto = nil

	local lluviasEliminadas = 0
	for _, obj in ipairs(lluviaParticulas) do
		if obj and obj.Parent then
			obj:Destroy()
			lluviasEliminadas = lluviasEliminadas + 1
		end
	end
	lluviaParticulas = {}

	lluviaActiva = false
	print("✅ Lluvia desactivada. Partículas eliminadas: " .. lluviasEliminadas)
	broadcastMessage("🌧️ LLUVIA DESACTIVADA", Enum.ChatColor.Blue)
end

-- ============================================
-- SISTEMA DE METEORITOS
-- ============================================
local function activateMeteorEvent(duration)
	if not hasMeteorModule then
		broadcastMessage("El módulo de meteoritos no está disponible", Enum.ChatColor.Red)
		return
	end

	if MeteorShowerModule.Active then
		broadcastMessage("Ya hay un evento de meteoritos activo", Enum.ChatColor.Yellow)
		return
	end

	print("Activando evento continuo de meteoritos por " .. duration .. " segundos")
	MeteorShowerModule:StartContinuousEvent(duration)
	broadcastMessage("☄️ ¡LLUVIA DE METEORITOS! ¡Cuidado!", Enum.ChatColor.Red)

	spawn(function()
		for i = duration, 1, -10 do
			if not MeteorShowerModule.Active then break end
			if i % 30 == 0 or i <= 10 then
				broadcastMessage("☄️ Meteoritos por " .. i .. " segundos más...", Enum.ChatColor.Yellow)
			end
			wait(10)
		end
	end)

	spawn(function()
		wait(duration)
		if not MeteorShowerModule.Active then return end
		broadcastMessage("☄️ Evento de meteoritos terminado", Enum.ChatColor.Blue)
	end)
end

local function stopMeteorEvent()
	if not hasMeteorModule then
		broadcastMessage("El módulo de meteoritos no está disponible", Enum.ChatColor.Red)
		return
	end

	if not MeteorShowerModule.Active then
		broadcastMessage("No hay evento activo para detener", Enum.ChatColor.Yellow)
		return
	end

	MeteorShowerModule:StopEvent()
	broadcastMessage("☄️ Evento de meteoritos detenido", Enum.ChatColor.Blue)
end

-- ============================================
-- SISTEMA DE AUDIO
-- ============================================
local function playAudio(audioId)
	if not mainMusic then
		mainMusic = Workspace:FindFirstChild("MainMusic")
	end

	if mainMusic and mainMusic:IsA("Sound") then
		mainMusic:Stop()
		mainMusic.Volume = 0
	end

	local currentCustomMusic = Workspace:FindFirstChild("BackgroundMusic")
	if currentCustomMusic and currentCustomMusic:IsA("Sound") then
		currentCustomMusic:Stop()
		currentCustomMusic:Destroy()
	end

	local newSound = Instance.new("Sound")
	newSound.SoundId = "rbxassetid://" .. audioId
	newSound.Looped = false
	newSound.Volume = 1
	newSound.Name = "BackgroundMusic"
	newSound.Parent = Workspace

	newSound.Ended:Connect(function()
		customMusicPlaying = false
		if mainMusic and mainMusic:IsA("Sound") then
			mainMusic.Volume = 1
			mainMusic:Play()
			print("Música principal restaurada")
		end

		newSound:Destroy()
	end)

	newSound:Play()
	customMusicPlaying = true
	print("¡Reproduciendo audio personalizado! ID: " .. audioId)
	broadcastMessage("🎵 Reproduciendo audio personalizado", Enum.ChatColor.Green)
end

local function stopAudio()
	local currentCustomMusic = Workspace:FindFirstChild("BackgroundMusic")
	if currentCustomMusic and currentCustomMusic:IsA("Sound") then
		currentCustomMusic:Stop()
		currentCustomMusic:Destroy()
		customMusicPlaying = false
	end

	if mainMusic and mainMusic:IsA("Sound") then
		mainMusic.Volume = 1
		mainMusic:Play()
		print("Música principal restaurada")
	end
	
	broadcastMessage("🎵 Audio detenido", Enum.ChatColor.Blue)
end

-- ============================================
-- SISTEMA DE MENSAJES GLOBALES
-- ============================================
local function handleGlobalMessage(player, message, allServers)
	if allServers then
		publishToAllServers("MultiServerMessage", {
			Message = message,
			Timestamp = os.time()
		})
	end

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local targetGui = targetPlayer:FindFirstChild("PlayerGui")
		if targetGui then
			local messageGui = targetGui:FindFirstChild("GlobalMessageGui")
			if messageGui then
				messageGui:Destroy()
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "GlobalMessageGui"
			screenGui.Parent = targetGui
			screenGui.ResetOnSpawn = false
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

			local messageFrame = Instance.new("Frame")
			messageFrame.Size = UDim2.new(1, 0, 0, 60)
			messageFrame.Position = UDim2.new(0, 0, 0.1, 0)
			messageFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			messageFrame.BackgroundTransparency = 0.3
			messageFrame.BorderSizePixel = 0
			messageFrame.Parent = screenGui

			local messageLabel = Instance.new("TextLabel")
			messageLabel.Size = UDim2.new(1, -20, 1, -10)
			messageLabel.Position = UDim2.new(0, 10, 0, 5)
			messageLabel.BackgroundTransparency = 1
			messageLabel.Text = message
			messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			messageLabel.TextScaled = true
			messageLabel.Font = Enum.Font.GothamBold
			messageLabel.TextWrapped = true
			messageLabel.Parent = messageFrame

			messageFrame.Position = UDim2.new(0, 0, -0.1, 0)
			local tween = TweenService:Create(
				messageFrame,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(0, 0, 0.1, 0)}
			)
			tween:Play()

			delay(10, function()
				if messageFrame and messageFrame.Parent then
					local exitTween = TweenService:Create(
						messageFrame,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Position = UDim2.new(0, 0, -0.1, 0)}
					)
					exitTween:Play()
					exitTween.Completed:Connect(function()
						screenGui:Destroy()
					end)
				end
			end)
		end
	end

	print("Mensaje global enviado por " .. player.Name .. ": " .. message)
end

-- ============================================
-- SUSCRIPCIÓN A EVENTOS MULTI-SERVIDOR
-- ============================================
local function subscribeToEvents()
	pcall(function()
		MessagingService:SubscribeAsync("MultiServerHumo", function(message)
			if message.Data.Sender == JobId then return end
			
			if message.Data.Data.Action == "start" then
				activarSistemaHumo(message.Data.Data.Duration)
			elseif message.Data.Data.Action == "stop" then
				desactivarSistemaHumo()
			end
		end)

		MessagingService:SubscribeAsync("MultiServerLluvia", function(message)
			if message.Data.Sender == JobId then return end
			
			if message.Data.Data.Action == "start" then
				activarLluvia()
			elseif message.Data.Data.Action == "stop" then
				desactivarLluvia()
			end
		end)

		MessagingService:SubscribeAsync("MultiServerMeteoros", function(message)
			if message.Data.Sender == JobId then return end
			
			if message.Data.Data.Action == "start" then
				activateMeteorEvent(message.Data.Data.Duration)
			elseif message.Data.Data.Action == "stop" then
				stopMeteorEvent()
			end
		end)

		MessagingService:SubscribeAsync("MultiServerMusica", function(message)
			if message.Data.Sender == JobId then return end
			
			if message.Data.Data.Action == "play" then
				playAudio(message.Data.Data.AudioId)
			elseif message.Data.Data.Action == "stop" then
				stopAudio()
			end
		end)

		MessagingService:SubscribeAsync("MultiServerMessage", function(message)
			if message.Data
						.Sender == JobId then return end
			
			for _, targetPlayer in ipairs(Players:GetPlayers()) do
				local targetGui = targetPlayer:FindFirstChild("PlayerGui")
				if targetGui then
					local messageGui = targetGui:FindFirstChild("GlobalMessageGui")
					if messageGui then
						messageGui:Destroy()
					end

					local screenGui = Instance.new("ScreenGui")
					screenGui.Name = "GlobalMessageGui"
					screenGui.Parent = targetGui
					screenGui.ResetOnSpawn = false
					screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

					local messageFrame = Instance.new("Frame")
					messageFrame.Size = UDim2.new(1, 0, 0, 60)
					messageFrame.Position = UDim2.new(0, 0, 0.1, 0)
					messageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					messageFrame.BackgroundTransparency = 0.3
					messageFrame.BorderSizePixel = 0
					messageFrame.Parent = screenGui

					local messageLabel = Instance.new("TextLabel")
					messageLabel.Size = UDim2.new(1, -20, 1, -10)
					messageLabel.Position = UDim2.new(0, 10, 0, 5)
					messageLabel.BackgroundTransparency = 1
					messageLabel.Text = message.Data.Data.Message
					messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					messageLabel.TextScaled = true
					messageLabel.Font = Enum.Font.GothamBold
					messageLabel.TextWrapped = true
					messageLabel.Parent = messageFrame

					messageFrame.Position = UDim2.new(0, 0, -0.1, 0)
					local tween = TweenService:Create(
						messageFrame,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Position = UDim2.new(0, 0, 0.1, 0)}
					)
					tween:Play()

					delay(10, function()
						if messageFrame and messageFrame.Parent then
							local exitTween = TweenService:Create(
								messageFrame,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{Position = UDim2.new(0, 0, -0.1, 0)}
							)
							exitTween:Play()
							exitTween.Completed:Connect(function()
								screenGui:Destroy()
							end)
						end
					end)
				end
			end
		end)
	end)
end

subscribeToEvents()

-- ============================================
-- DATASTORE MULTI-SERVIDOR
-- ============================================
local MultiServerStore = DataStoreService:GetDataStore("MultiServerEvents")

local function publishToAllServersDataStore(eventType, action, data)
	local eventData = {
		Action = action,
		Data = data,
		Timestamp = os.time(),
		Sender = JobId
	}

	local success, errorMessage = pcall(function()
		MultiServerStore:SetAsync(eventType, eventData)
	end)

	if not success then
		warn("Error al publicar evento " .. eventType .. ": " .. tostring(errorMessage))
	end
end

local function checkMultiServerEvents()
	while true do
		local eventsToCheck = {"Humo", "Lluvia", "Meteoros", "Musica"}

		for _, eventType in ipairs(eventsToCheck) do
			local success, eventData = pcall(function()
				return MultiServerStore:GetAsync(eventType)
			end)

			if success and eventData then
				if eventData.Sender ~= JobId and os.time() - eventData.Timestamp < 5 then
					print("Evento multi-servidor recibido: " .. eventType .. " - " .. eventData.Action)

					if eventType == "Humo" then
						if eventData.Action == "start" then
							activarSistemaHumo(eventData.Data.Duration)
							MultiServerEvents.ActiveEvents["Humo"] = {
								StartTime = os.time(),
								Duration = eventData.Data.Duration
							}
						elseif eventData.Action == "stop" then
							desactivarSistemaHumo()
							MultiServerEvents.ActiveEvents["Humo"] = nil
						end
					elseif eventType == "Lluvia" then
						if eventData.Action == "start" then
							activarLluvia()
							MultiServerEvents.ActiveEvents["Lluvia"] = { StartTime = os.time() }
						elseif eventData.Action == "stop" then
							desactivarLluvia()
							MultiServerEvents.ActiveEvents["Lluvia"] = nil
						end
					elseif eventType == "Meteoros" then
						if eventData.Action == "start" then
							activateMeteorEvent(eventData.Data.Duration)
							MultiServerEvents.ActiveEvents["Meteoros"] = {
								StartTime = os.time(),
								Duration = eventData.Data.Duration
							}
						elseif eventData.Action == "stop" then
							stopMeteorEvent()
							MultiServerEvents.ActiveEvents["Meteoros"] = nil
						end
					elseif eventType == "Musica" then
						if eventData.Action == "play" then
							playAudio(eventData.Data.AudioId)
							MultiServerEvents.ActiveEvents["Musica"] = {
								StartTime = os.time(),
								AudioId = eventData.Data.AudioId
							}
						elseif eventData.Action == "stop" then
							stopAudio()
							MultiServerEvents.ActiveEvents["Musica"] = nil
						end
					end

					pcall(function()
						MultiServerStore:RemoveAsync(eventType)
					end)
				end
			end
		end

		wait(2)
	end
end

spawn(checkMultiServerEvents)

-- ============================================
-- MANEJADORES DE EVENTOS (SIN RESTRICCIONES)
-- ============================================

-- METEORITOS
MeteorEvent.OnServerEvent:Connect(function(player, action, duration)
	print("🎮 " .. player.Name .. " ejecutó comando de meteoritos: " .. action)
	
	if action == "start" then
		activateMeteorEvent(duration or 240)
	elseif action == "stop" then
		stopMeteorEvent()
	end
end)

-- HUMO
HumoEvent.OnServerEvent:Connect(function(player, action, duracionMinutos)
	print("🎮 " .. player.Name .. " ejecutó comando de humo: " .. action)
	
	if action == "start" then
		activarSistemaHumo(duracionMinutos or 5)
	elseif action == "stop" then
		desactivarSistemaHumo()
	end
end)

-- LLUVIA
LluviaEvent.OnServerEvent:Connect(function(player, action)
	print("🎮 " .. player.Name .. " ejecutó comando de lluvia: " .. action)
	
	if action == "start" then
		activarLluvia()
	elseif action == "stop" then
		desactivarLluvia()
	end
end)

-- AUDIO
AudioEvent.OnServerEvent:Connect(function(player, action, audioId)
	print("🎮 " .. player.Name .. " ejecutó comando de audio: " .. action)
	
	if action == "play" then
		playAudio(audioId)
		sendMessageToPlayer(player, "🎵 Reproduciendo audio ID: " .. audioId, Enum.ChatColor.Green)
	elseif action == "stop" then
		stopAudio()
		sendMessageToPlayer(player, "🎵 Audio detenido", Enum.ChatColor.Green)
	end
end)

-- VELOCIDAD
SpeedEvent.OnServerEvent:Connect(function(player, speed)
	print("🎮 " .. player.Name .. " cambió velocidad a: " .. speed)
	
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
			sendMessageToPlayer(player, "⚡ Velocidad establecida a " .. speed, Enum.ChatColor.Green)
		end
	end
end)

-- VUELO
FlyEvent.OnServerEvent:Connect(function(player, action)
	print("🎮 " .. player.Name .. " ejecutó comando de vuelo: " .. action)
	
	if action == "enable" then
		sendMessageToPlayer(player, "✈️ Vuelo activado", Enum.ChatColor.Green)
	elseif action == "disable" then
		sendMessageToPlayer(player, "✈️ Vuelo desactivado", Enum.ChatColor.Green)
	end
end)

-- BILLETES (DINERO)
MoneyEvent.OnServerEvent:Connect(function(player, action, amount)
	print("🎮 " .. player.Name .. " ejecutó comando de billetes: " .. action .. " - " .. amount)
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local billetes = leaderstats:FindFirstChild("Billetes")
		if billetes then
			if action == "add" then
				billetes.Value = billetes.Value + amount
				sendMessageToPlayer(player, "💰 Se agregaron $" .. amount .. " billetes", Enum.ChatColor.Green)
			elseif action == "set" then
				billetes.Value = amount
				sendMessageToPlayer(player, "💰 Billetes establecidos a $" .. amount, Enum.ChatColor.Green)
			elseif action == "remove" then
				billetes.Value = math.max(0, billetes.Value - amount)
				sendMessageToPlayer(player, "💰 Se quitaron $" .. amount .. " billetes", Enum.ChatColor.Green)
			end
		else
			warn("⚠️ No se encontró 'Billetes' en leaderstats para " .. player.Name)
		end
	else
		warn("⚠️ No se encontró 'leaderstats' para " .. player.Name)
	end
end)

-- TRONCOS
TroncosEvent.OnServerEvent:Connect(function(player, action, amount)
	print("🎮 " .. player.Name .. " ejecutó comando de troncos: " .. action .. " - " .. amount)
	
	local leaderstats1 = player:FindFirstChild("leaderstats1")
	if leaderstats1 then
		local troncos = leaderstats1:FindFirstChild("Troncos")
		if troncos then
			if action == "add" then
				troncos.Value = troncos.Value + amount
				sendMessageToPlayer(player, "🪵 Se agregaron " .. amount .. " troncos", Enum.ChatColor.Green)
			elseif action == "set" then
				troncos.Value = amount
				sendMessageToPlayer(player, "🪵 Troncos establecidos a " .. amount, Enum.ChatColor.Green)
			elseif action == "remove" then
				troncos.Value = math.max(0, troncos.Value - amount)
				sendMessageToPlayer(player, "🪵 Se quitaron " .. amount .. " troncos", Enum.ChatColor.Green)
			end
		else
			warn("⚠️ No se encontró 'Troncos' en leaderstats1 para " .. player.Name)
		end
	else
		warn("⚠️ No se encontró 'leaderstats1' para " .. player.Name)
	end
end)

-- MENSAJES GLOBALES
MessageEvent.OnServerEvent:Connect(function(player, message, allServers)
	print("🎮 " .. player.Name .. " envió mensaje global: " .. message)
	handleGlobalMessage(player, message, allServers)
end)

-- MULTI-SERVIDOR
MultiServerEvent.OnServerEvent:Connect(function(player, eventType, action, data)
	print("🎮 " .. player.Name .. " ejecutó evento multi-servidor: " .. eventType .. " - " .. action)
	
	publishToAllServersDataStore(eventType, action, data)

	if eventType == "Humo" then
		if action == "start" then
			activarSistemaHumo(data.Duration)
			MultiServerEvents.ActiveEvents["Humo"] = {
				StartTime = os.time(),
				Duration = data.Duration
			}
		else
			desactivarSistemaHumo()
			MultiServerEvents.ActiveEvents["Humo"] = nil
		end
	elseif eventType == "Lluvia" then
		if action == "start" then
			activarLluvia()
			MultiServerEvents.ActiveEvents["Lluvia"] = { StartTime = os.time() }
		else
			desactivarLluvia()
			MultiServerEvents.ActiveEvents["Lluvia"] = nil
		end
	elseif eventType == "Meteoros" then
		if action == "start" then
			activateMeteorEvent(data.Duration)
			MultiServerEvents.ActiveEvents["Meteoros"] = {
				StartTime = os.time(),
				Duration = data.Duration
			}
		else
			stopMeteorEvent()
			MultiServerEvents.ActiveEvents["Meteoros"] = nil
		end
	elseif eventType == "Musica" then
		if action == "play" then
			playAudio(data.AudioId)
			MultiServerEvents.ActiveEvents["Musica"] = {
				StartTime = os.time(),
				AudioId = data.AudioId
			}
		else
			stopAudio()
			MultiServerEvents.ActiveEvents["Musica"] = nil
		end
	end

	broadcastMessage("🌐 Evento " .. eventType .. " " .. action .. " en TODOS los servidores", Enum.ChatColor.Green)
end)

-- ============================================
-- VERIFICAR PASTO1 AL INICIAR
-- ============================================
local function verificarPasto1()
	local pasto1 = Workspace:FindFirstChild("pasto1")
	if pasto1 then
		print("✅ pasto1 encontrado en el Workspace")
	else
		warn("⚠️ pasto1 no encontrado en el Workspace - los eventos de humo y lluvia no funcionarán correctamente")
	end
end

verificarPasto1()

-- ============================================
-- MANEJAR NUEVOS JUGADORES
-- ============================================
Players.PlayerAdded:Connect(function(player)
	print("👤 Jugador conectado: " .. player.Name)
	
	-- Si la primera persona está activada, aplicarla al nuevo jugador
	if primeraPersonaActivada then
		player.CharacterAdded:Connect(function()
			wait(1)
			forzarPrimeraPersona(player)
		end)
	end
end)

-- ============================================
-- MENSAJES DE CONFIRMACIÓN
-- ============================================
print("✅ ========================================")
print("✅ SISTEMA DE ADMINISTRACIÓN CARGADO")
print("✅ ========================================")
print("🔥 Sistema de humo: Modelos en pasto1")
print("🌧️ Sistema de lluvia: Partículas en pasto1")
print("📷 Sistema de cámara en primera persona")
print("🎵 Sistema de música mejorado")
print("🌐 Sistema de eventos multi-servidor activado")
print("💬 Sistema de mensajes globales activado")
print("⚠️ MODO SIN RESTRICCIONES: Todos pueden usar el panel")
print("✅ ========================================")
