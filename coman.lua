-- Script combinado para el Panel de Administración Universal
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")

-- Servicios para eventos multi-servidor
local MessagingService = game:GetService("MessagingService")
local JobId = game.JobId

-- Variables del sistema
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- DataStores
local BillsStore = DataStoreService:GetDataStore("PlayerBilletes")
local MultiServerStore = DataStoreService:GetDataStore("MultiServerEvents")

-- Módulo de meteoritos
local MeteorShowerModule
local hasMeteorModule = pcall(function()
	MeteorShowerModule = require(script.Parent:WaitForChild("MeteorShowerModule"))
end)

-- Variables de control
local humoActivo = false
local tiempoHumo = 300
local humoTween
local primeraPersonaActivada = false
local mainMusic = Workspace:FindFirstChild("MainMusic")
local customMusicPlaying = false
local lluviaActiva = false
local lluviaGrandeId = 5338590536
local lluviaChicaId = 4451256888
local lluviaObjeto = nil
local lluviaParticulas = {}

-- Tabla para controlar eventos entre servidores
local MultiServerEvents = {
	ActiveEvents = {}
}

-- Configuración del sistema de humo
local fuegoID = 8651011854
local cantidadFuego = 1000

-- RemoteEvents
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

-- FUNCIONES DEL SERVIDOR
-- Función para enviar mensaje a un jugador
local function sendMessageToPlayer(player, text, color)
	if player and player.Character and player.Character:FindFirstChild("Head") then
		local chatService = game:GetService("Chat")
		chatService:Chat(player.Character.Head, text, color)
	end
end

-- Función para enviar mensaje a todos los jugadores
local function broadcastMessage(text, color)
	for _, player in ipairs(Players:GetPlayers()) do
		sendMessageToPlayer(player, text, color)
	end
end

-- Función para publicar eventos en todos los servidores
local function publishToAllServers(eventName, data)
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

-- Función para manejar eventos entrantes de otros servidores
local function handleIncomingEvent(eventName, data)
	if data.Sender == JobId then
		return
	end

	print("Evento recibido de otro servidor: " .. eventName)

	if eventName == "MultiServerHumo" then
		if data.Data.Action == "start" then
			activarSistemaHumo(data.Data.Duration)
			MultiServerEvents.ActiveEvents["Humo"] = {
				StartTime = os.time(),
				Duration = data.Data.Duration
			}
		elseif data.Data.Action == "stop" then
			desactivarSistemaHumo()
			MultiServerEvents.ActiveEvents["Humo"] = nil
		end
	elseif eventName == "MultiServerLluvia" then
		if data.Data.Action == "start" then
			activarLluvia()
			MultiServerEvents.ActiveEvents["Lluvia"] = { StartTime = os.time() }
		elseif data.Data.Action == "stop" then
			desactivarLluvia()
			MultiServerEvents.ActiveEvents["Lluvia"] = nil
		end
	elseif eventName == "MultiServerMeteoros" then
		if data.Data.Action == "start" then
			activateMeteorEvent(data.Data.Duration)
			MultiServerEvents.ActiveEvents["Meteoros"] = {
				StartTime = os.time(),
				Duration = data.Data.Duration
			}
		elseif data.Data.Action == "stop" then
			stopMeteorEvent()
			MultiServerEvents.ActiveEvents["Meteoros"] = nil
		end
	elseif eventName == "MultiServerMusica" then
		if data.Data.Action == "play" then
			playAudio(data.Data.AudioId)
			MultiServerEvents.ActiveEvents["Musica"] = {
				StartTime = os.time(),
				AudioId = data.Data.AudioId
			}
		elseif data.Data.Action == "stop" then
			stopAudio()
			MultiServerEvents.ActiveEvents["Musica"] = nil
		end
	elseif eventName == "MultiServerMessage" then
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
				messageFrame.BackgroundTransparency = 1
				messageFrame.BorderSizePixel = 0
				messageFrame.Parent = screenGui

				local messageLabel = Instance.new("TextLabel")
				messageLabel.Size = UDim2.new(1, -20, 1, -10)
				messageLabel.Position = UDim2.new(0, 10, 0, 5)
				messageLabel.BackgroundTransparency = 1
				messageLabel.Text = data.Data.Message
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
	end
end

-- Función para manejar mensajes globales
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
			messageFrame.BackgroundTransparency = 1
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

-- Suscribirse a los eventos multi-servidor
local function subscribeToEvents()
	pcall(function()
		MessagingService:SubscribeAsync("MultiServerHumo", function(message)
			handleIncomingEvent("MultiServerHumo", message.Data)
		end)

		MessagingService:SubscribeAsync("MultiServerLluvia", function(message)
			handleIncomingEvent("MultiServerLluvia", message.Data)
		end)

		MessagingService:SubscribeAsync("MultiServerMeteoros", function(message)
			handleIncomingEvent("MultiServerMeteoros", message.Data)
		end)

		MessagingService:SubscribeAsync("MultiServerMusica", function(message)
			handleIncomingEvent("MultiServerMusica", message.Data)
		end)

		MessagingService:SubscribeAsync("MultiServerMessage", function(message)
			handleIncomingEvent("MultiServerMessage", message.Data)
		end)
	end)
end

-- Iniciar suscripciones
subscribeToEvents()

-- Función para forzar primera persona
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

-- Función para restaurar cámara normal
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

-- Función para activar/desactivar primera persona para todos
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

-- Función para limpiar humo existente
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

-- Función para crear el sistema de humo
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

-- Función para activar el sistema de humo
local function activarSistemaHumo(duracionMinutos)
	if humoActivo then
		broadcastMessage("evento2 ya está activo!", "Yellow")
		return
	end

	tiempoHumo = duracionMinutos * 60

	local exito = crearSistemaHumo()
	if not exito then
		broadcastMessage("❌ Error al crear el sistema de humo", "Red")
		return
	end

	humoActivo = true
	broadcastMessage("ACTIVO " .. duracionMinutos .. " minutos", "Green")
	broadcastMessage("Cámara en primera persona", "Green")

	spawn(function()
		local tiempoRestante = tiempoHumo
		while tiempoRestante > 0 and humoActivo do
			if tiempoRestante % 60 == 0 or tiempoRestante <= 10 then
				local minutos = math.floor(tiempoRestante / 60)
				local segundos = tiempoRestante % 60
				broadcastMessage("Humo activo: " .. minutos .. "m " .. segundos .. "s restantes", "Yellow")
			end
			wait(1)
			tiempoRestante = tiempoRestante - 1
		end

		if humoActivo then
			desactivarSistemaHumo()
			broadcastMessage("TERMINADO", "Blue")
		end
	end)
end

-- Función para desactivar el sistema de humo
local function desactivarSistemaHumo()
	if not humoActivo then
		broadcastMessage("evento2 no activo", "Yellow")
		return
	end

	local humosEliminados = limpiarHumo()
	humoActivo = false

	togglePrimeraPersona(false)

	broadcastMessage("Evento2 desactivado. ", "Blue")
	broadcastMessage("Camara primera", "Blue")
	print("evento2 desactivado. Humos eliminados: " .. humosEliminados)
end

-- Función para hacer invisibles y sin colisión los parts de un modelo
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

-- Función para activar lluvia
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
end

-- Función para desactivar lluvia
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
end

-- Función para activar el evento de meteoritos
local function activateMeteorEvent(duration)
	if not hasMeteorModule then
		broadcastMessage("El módulo de meteoritos no está disponible", "Red")
		return
	end

	if MeteorShowerModule.Active then
		broadcastMessage("evento de meteoritos existente", "Yellow")
		return
	end

	print("Activando evento continuo de meteoritos por " .. duration .. " segundos")
	MeteorShowerModule:StartContinuousEvent(duration)
	broadcastMessage("¡LLUVIA DE METEORITOS! ¡Cuidado!", "Green")

	spawn(function()
		for i = duration, 1, -10 do
			if not MeteorShowerModule.Active then break end
			if i % 30 == 0 or i <= 10 then
				broadcastMessage("Meteoritos por " .. i .. " segundos más...", "Yellow")
			end
			wait(10)
		end
	end)

	spawn(function()
		wait(duration)
		if not MeteorShowerModule.Active then return end
		broadcastMessage("evento terminado", "Blue")
	end)
end

-- Función para detener meteoritos
local function stopMeteorEvent()
	if not hasMeteorModule then
		broadcastMessage("El módulo de meteoritos no está disponible", "Red")
		return
	end

	if not MeteorShowerModule.Active then
		broadcastMessage("No hay evento activo para detener", "Yellow")
		return
	end

	MeteorShowerModule:StopEvent()
	broadcastMessage("Evento apagado", "Blue")
end

-- Función para reproducir audio
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
end

-- Función para detener audio
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
end

-- Función para publicar eventos multi-servidor usando DataStore
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

-- Función para verificar y ejecutar eventos multi-servidor
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

-- Iniciar la verificación de eventos multi-servidor
spawn(checkMultiServerEvents)

-- Manejadores de eventos del servidor
MeteorEvent.OnServerEvent:Connect(function(player, action, duration)
	if action == "start" then
		activateMeteorEvent(duration or 240)
	elseif action == "stop" then
		stopMeteorEvent()
	end
end)

HumoEvent.OnServerEvent:Connect(function(player, action, duracionMinutos)
	if action == "start" then
		activarSistemaHumo(duracionMinutos or 5)
	elseif action == "stop" then
		desactivarSistemaHumo()
	end
end)

LluviaEvent.OnServerEvent:Connect(function(player, action)
	if action == "start" then
		activarLluvia()
	elseif action == "stop" then
		desactivarLluvia()
	end
end)

AudioEvent.OnServerEvent:Connect(function(player, action, audioId)
	if action == "play" then
		playAudio(audioId)
		sendMessageToPlayer(player, "Reproduciendo audio ID: " .. audioId, "Green")
	elseif action == "stop" then
		stopAudio()
		sendMessageToPlayer(player, "Audio detenido", "Green")
	end
end)

SpeedEvent.OnServerEvent:Connect(function(player, speed)
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
			sendMessageToPlayer(player, "Velocidad establecida a " .. speed, "Green")
		end
	end
end)

FlyEvent.OnServerEvent:Connect(function(player, action)
	if action == "enable" then
		sendMessageToPlayer(player, "Vuelo activado", "Green")
	elseif action == "disable" then
		sendMessageToPlayer(player, "Vuelo desactivado", "Green")
	end
end)

MoneyEvent.OnServerEvent:Connect(function(player, action, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local billetes = leaderstats:FindFirstChild("Billetes")
		if billetes then
			if action == "add" then
				billetes.Value = billetes.Value + amount
				sendMessageToPlayer(player, "Se agregaron $" .. amount .. " billetes", "Green")
			elseif action == "set" then
				billetes.Value = amount
				sendMessageToPlayer(player, "Billetes establecidos a $" .. amount, "Green")
			elseif action == "remove" then
				billetes.Value = math.max(0, billetes.Value - amount)
				sendMessageToPlayer(player, "Se quitaron $" .. amount .. " billetes", "Green")
			end
		end
	end
end)

TroncosEvent.OnServerEvent:Connect(function(player, action, amount)
	local leaderstats1 = player:FindFirstChild("leaderstats1")
	if leaderstats1 then
		local troncos = leaderstats1:FindFirstChild("Troncos")
		if troncos then
			if action == "add" then
				troncos.Value = troncos.Value + amount
			elseif action == "set" then
				troncos.Value = amount
			elseif action == "remove" then
				troncos.Value = math.max(0, troncos.Value - amount)
			end
		end
	end
end)

MessageEvent.OnServerEvent:Connect(handleGlobalMessage)

MultiServerEvent.OnServerEvent:Connect(function(player, eventType, action, data)
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

	broadcastMessage("Evento " .. eventType .. " " .. action .. " en TODOS los servidores", "Green")
end)

-- Verificar que pasto1 existe
local function verificarPasto1()
	local pasto1 = Workspace:FindFirstChild("pasto1")
	if pasto1 then
		print("✅ pasto1 encontrado en el Workspace")
	else
		warn("⚠️  pasto1 no encontrado en el Workspace - los eventos de humo y lluvia no funcionarán correctamente")
	end
end

verificarPasto1()

-- INTERFAZ DE USUARIO (CLIENTE)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.25, 0, 0.45, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -25, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "PANEL UNIVERSAL - TODOS PUEDEN USAR"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.ZIndex = 2
closeButton.Parent = titleBar

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Panel"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Visible = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -25)
scrollFrame.Position = UDim2.new(0, 0, 0, 25)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Name = "UIListLayout"
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollFrame

-- Función para crear secciones
local function createSection(title, height, layoutOrder)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Size = UDim2.new(0.96, 0, 0, height)
	section.Position = UDim2.new(0.02, 0, 0, 0)
	section.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	section.BorderSizePixel = 0
	section.LayoutOrder = layoutOrder
	section.Parent = scrollFrame

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 6)
	sectionCorner.Parent = section

	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Name = "Title"
	sectionTitle.Size = UDim2.new(1, 0, 0, 20)
	sectionTitle.Position = UDim2.new(0, 0, 0, 0)
	sectionTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sectionTitle.BorderSizePixel = 0
	sectionTitle.Text = "  " .. title
	sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextSize = 12
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = section

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 6)
	titleCorner.Parent = sectionTitle

	return section
end

-- Función para crear botones
local function createButton(parent, name, text, color, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size or UDim2.new(0.45, -4, 0, 22)
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11
	button.Parent = parent

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = button

	return button
end

-- Función para crear campos de texto
local function createTextBox(parent, name, placeholder, position, size)
	local textBox = Instance.new("TextBox")
	textBox.Name = name
	textBox.Size = size or UDim2.new(0.55, -4, 0, 22)
	textBox.Position = position
	textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textBox.BorderSizePixel = 0
	textBox.PlaceholderText = placeholder
	textBox.Text = ""
	textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 11
	textBox.Parent = parent

	local textCorner = Instance.new("UICorner")
	textCorner.CornerRadius = UDim.new(0, 4)
	textCorner.Parent = textBox

	return textBox
end

-- Crear todas las secciones del panel
local moneySection = createSection("Billetes", 65, 1)
local moneyInput = createTextBox(moneySection, "MoneyInput", "Cantidad", UDim2.new(0, 4, 0, 22))
local moneyAddButton = createButton(moneySection, "MoneyAddButton", "+", Color3.fromRGB(60, 180, 60), UDim2.new(0.55, 2, 0, 22))
local moneySetButton = createButton(moneySection, "MoneySetButton", "Set", Color3.fromRGB(60, 120, 180), UDim2.new(0.55, 2, 0, 44))

local troncosSection = createSection("Troncos", 65, 2)
local troncosInput = createTextBox(troncosSection, "TroncosInput", "Cantidad", UDim2.new(0, 4, 0, 22))
local troncosAddButton = createButton(troncosSection, "TroncosAddButton", "+", Color3.fromRGB(200, 140, 60), UDim2.new(0.55, 2, 0, 22))
local troncosRemoveButton = createButton(troncosSection, "TroncosRemoveButton", "-", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 44))
local troncosSetButton = createButton(troncosSection, "TroncosSetButton", "Set", Color3.fromRGB(60, 120, 180), UDim2.new(0, 4, 0, 44))

local speedSection = createSection("Velocidad", 45, 3)
local speedInput = createTextBox(speedSection, "SpeedInput", "Velocidad", UDim2.new(0, 4, 0, 22))
local speedSetButton = createButton(speedSection, "SpeedSetButton", "Aplicar", Color3.fromRGB(60, 120, 180), UDim2.new(0.55, 2, 0, 22))

local flySection = createSection("Vuelo", 45, 4)
local flyEnableButton = createButton(flySection, "FlyEnableButton", "Activar", Color3.fromRGB(60, 180, 60), UDim2.new(0, 4, 0, 22))
local flyDisableButton = createButton(flySection, "FlyDisableButton", "Desactivar", Color3.fromRGB(180, 60, 60), UDim2.new(0.5, 2, 0, 22))

local meteorSection = createSection("Meteoritos", 85, 5)
local meteorTimeInput = createTextBox(meteorSection, "MeteorTimeInput", "Segundos", UDim2.new(0, 4, 0, 22))
meteorTimeInput.Text = "240"
local meteorStartButton = createButton(meteorSection, "MeteorStartButton", "Iniciar", Color3.fromRGB(60, 180, 60), UDim2.new(0.55, 2, 0, 22))
local meteorStopButton = createButton(meteorSection, "MeteorStopButton", "Detener", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 44))
local meteorMultiButton = createButton(meteorSection, "MeteorMultiButton", "Todos Serv", Color3.fromRGB(120, 80, 200), UDim2.new(0, 4, 0, 44))
local meteorMultiStopButton = createButton(meteorSection, "MeteorMultiStopButton", "Parar Todos", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 66))

local audioSection = createSection("Audio", 85, 6)
local audioInput = createTextBox(audioSection, "AudioInput", "ID Audio", UDim2.new(0, 4, 0, 22))
audioInput.Text = "74456998941899"
local audioPlayButton = createButton(audioSection, "AudioPlayButton", "Play", Color3.fromRGB(60, 180, 60), UDim2.new(0.55, 2, 0, 22))
local audioStopButton = createButton(audioSection, "AudioStopButton", "Stop", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 44))
local audioMultiButton = createButton(audioSection, "AudioMultiButton", "Todos Serv", Color3.fromRGB(120, 80, 200), UDim2.new(0, 4, 0, 44))
local audioMultiStopButton = createButton(audioSection, "AudioMultiStopButton", "Parar Todos", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 66))

local humoSection = createSection("Sistema de Humo", 85, 7)
local humoTimeInput = createTextBox(humoSection, "HumoTimeInput", "Minutos", UDim2.new(0, 4, 0, 22))
humoTimeInput.Text = "5"
local humoStartButton = createButton(humoSection, "HumoStartButton", "Activar", Color3.fromRGB(60, 180, 60), UDim2.new(0.55, 2, 0, 22))
local humoStopButton = createButton(humoSection, "HumoStopButton", "Desactivar", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 44))
local humoMultiButton = createButton(humoSection, "HumoMultiButton", "Todos Serv", Color3.fromRGB(120, 80, 200), UDim2.new(0, 4, 0, 44))
local humoMultiStopButton = createButton(humoSection, "HumoMultiStopButton", "Parar Todos", Color3.fromRGB(180, 60, 60), UDim2.new(0.55, 2, 0, 66))

local lluviaSection = createSection("Lluvia", 65, 8)
local lluviaStartButton = createButton(lluviaSection, "LluviaStartButton", "Activar", Color3.fromRGB(60, 180, 60), UDim2.new(0, 4, 0, 22))
local lluviaStopButton = createButton(lluviaSection, "LluviaStopButton", "Desactivar", Color3.fromRGB(180, 60, 60), UDim2.new(0.5, 2, 0, 22))
local lluviaMultiButton = createButton(lluviaSection, "LluviaMultiButton", "Todos Serv", Color3.fromRGB(120, 80, 200), UDim2.new(0, 4, 0, 44))
local lluviaMultiStopButton = createButton(lluviaSection, "LluviaMultiStopButton", "Parar Todos", Color3.fromRGB(180, 60, 60), UDim2.new(0.5, 2, 0, 44))

local messageSection = createSection("Mensajes Globales", 85, 9)
local messageInput = createTextBox(messageSection, "MessageInput", "Escribe tu mensaje aquí", UDim2.new(0, 4, 0, 22))
messageInput.Size = UDim2.new(0.96, -8, 0, 22)

local messageSendButton = createButton(messageSection, "MessageSendButton", "Enviar a este Servidor", Color3.fromRGB(60, 120, 180), UDim2.new(0, 4, 0, 44))
messageSendButton.Size = UDim2.new(0.48, -4, 0, 22)

local messageSendAllButton = createButton(messageSection, "MessageSendAllButton", "Enviar a Todos los Servidores", Color3.fromRGB(120, 80, 200), UDim2.new(0.5, 2, 0, 44))
messageSendAllButton.Size = UDim2.new(0.48, -4, 0, 22)

-- Ajustar tamaño del canvas
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

-- Funcionalidad de arrastre
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Funcionalidad de los botones
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	toggleButton.Visible = true
end)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	toggleButton.Visible = false
end)

-- Conexiones de los botones con los eventos
moneyAddButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyInput.Text)
	if amount then
		MoneyEvent:FireServer("add", amount)
		moneyInput.Text = ""
	end
end)

moneySetButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyInput.Text)
	if amount then
		MoneyEvent:FireServer("set", amount)
		moneyInput.Text = ""
	end
end)

troncosAddButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("add", amount)
		troncosInput.Text = ""
	end
end)

troncosRemoveButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("remove", amount)
		troncosInput.Text = ""
	end
end)

troncosSetButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("set", amount)
		troncosInput.Text = ""
	end
end)

speedSetButton.MouseButton1Click:Connect(function()
	local speed = tonumber(speedInput.Text)
	if speed then
		SpeedEvent:FireServer(speed)
		speedInput.Text = ""
	end
end)

flyEnableButton.MouseButton1Click:Connect(function()
	FlyEvent:FireServer("enable")
end)

flyDisableButton.MouseButton1Click:Connect(function()
	FlyEvent:FireServer("disable")
end)

meteorStartButton.MouseButton1Click:Connect(function()
	local duration = tonumber(meteorTimeInput.Text) or 240
	MeteorEvent:FireServer("start", duration)
end)

meteorStopButton.MouseButton1Click:Connect(function()
	MeteorEvent:FireServer("stop")
end)

audioPlayButton.MouseButton1Click:Connect(function()
	local audioId = audioInput.Text
	if audioId and audioId ~= "" then
		AudioEvent:FireServer("play", audioId)
	end
end)

audioStopButton.MouseButton1Click:Connect(function()
	AudioEvent:FireServer("stop")
end)

humoStartButton.MouseButton1Click:Connect(function()
	local minutos = tonumber(humoTimeInput.Text)
	if minutos and minutos > 0 then
		HumoEvent:FireServer("start", minutos)
		humoTimeInput.Text = ""
	end
end)

humoStopButton.MouseButton1Click:Connect(function()
	HumoEvent:FireServer("stop")
end)

lluviaStartButton.MouseButton1Click:Connect(function()
	LluviaEvent:FireServer("start")
end)

lluviaStopButton.MouseButton1Click:Connect(function()
	LluviaEvent:FireServer("stop")
end)

-- Eventos multi-servidor
meteorMultiButton.MouseButton1Click:Connect(function()
	local duration = tonumber(meteorTimeInput.Text) or 240
	MultiServerEvent:FireServer("Meteoros", "start", {Duration = duration})
end)

meteorMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Meteoros", "stop", {})
end)

audioMultiButton.MouseButton1Click:Connect(function()
	local audioId = audioInput.Text
	if audioId and audioId ~= "" then
		MultiServerEvent:FireServer("Musica", "play", {AudioId = audioId})
	end
end)

audioMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Musica", "stop", {})
end)

humoMultiButton.MouseButton1Click:Connect(function()
	local minutos = tonumber(humoTimeInput.Text) or 5
	MultiServerEvent:FireServer("Humo", "start", {Duration = minutos})
end)

humoMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Humo", "stop", {})
end)

lluviaMultiButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Lluvia", "start", {})
end)

lluviaMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Lluvia", "stop", {})
end)

messageSendButton.MouseButton1Click:Connect(function()
	local message = messageInput.Text
	if message and message ~= "" then
		MessageEvent:FireServer(message, false)
		messageInput.Text = ""
	end
end)

messageSendAllButton.MouseButton1Click:Connect(function()
	local message = messageInput.Text
	if message and message ~= "" then
		MessageEvent:FireServer(message, true)
		messageInput.Text = ""
	end
end)

-- Inicialmente ocultar el panel principal
mainFrame.Visible = false
toggleButton.Visible = true

-- Atajo de teclado para abrir/cerrar el panel (F3)
local inputConnection
inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.F3 then
		mainFrame.Visible = not mainFrame.Visible
		toggleButton.Visible = not mainFrame.Visible
	end
end)

print("✅ SISTEMA DE PANEL UNIVERSAL CARGADO - TODOS LOS JUGADORES PUEDEN USARLO")
print("🔥 Sistema de humo activado")
print("🌧️ Sistema de lluvia activado")
print("☄️ Sistema de meteoritos activado")
print("🎵 Sistema de audio activado")
print("🌐 Sistema multi-servidor activado")
print("💬 Sistema de mensajes globales activado")
print("📱 Panel accesible para todos los jugadores")
print("🎮 Presiona F3 para abrir/cerrar el panel")
