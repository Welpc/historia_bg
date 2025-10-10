local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Esperar a que todos los eventos estén disponibles
local MeteorEvent = ReplicatedStorage:WaitForChild("MeteorEvent")
local AudioEvent = ReplicatedStorage:WaitForChild("AudioEvent")
local SpeedEvent = ReplicatedStorage:WaitForChild("SpeedEvent")
local FlyEvent = ReplicatedStorage:WaitForChild("FlyEvent")
local MoneyEvent = ReplicatedStorage:WaitForChild("MoneyEvent")
local TroncosEvent = ReplicatedStorage:WaitForChild("TroncosEvent")
local HumoEvent = ReplicatedStorage:WaitForChild("HumoEvent")
local LluviaEvent = ReplicatedStorage:WaitForChild("LluviaEvent")
local MultiServerEvent = ReplicatedStorage:WaitForChild("MultiServerEvent")
local MessageEvent = ReplicatedStorage:WaitForChild("MessageEvent")

-- ============================================
-- VARIABLES GLOBALES DE VUELO
-- ============================================
local flying = false
local flySpeed = 50
local bodyGyro
local bodyVelocity
local flyConnection

-- ============================================
-- SISTEMA DE VUELO COMPLETO
-- ============================================
local function enableFly()
	if flying then return end
	
	character = player.Character
	if not character then return end
	
	humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart then return end
	
	flying = true
	
	-- Crear BodyGyro para controlar la rotación
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.cframe = rootPart.CFrame
	bodyGyro.Parent = rootPart
	
	-- Crear BodyVelocity para controlar el movimiento
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.velocity = Vector3.new(0, 0, 0)
	bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Parent = rootPart
	
	-- Bucle de vuelo
	flyConnection = RunService.Heartbeat:Connect(function()
		if not flying or not character or not character.Parent then
			return
		end
		
		local newRootPart = character:FindFirstChild("HumanoidRootPart")
		if not newRootPart or not bodyGyro or not bodyVelocity then
			return
		end
		
		local camera = workspace.CurrentCamera
		local moveDirection = Vector3.new()
		
		-- Detectar teclas de movimiento
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + (camera.CFrame.LookVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - (camera.CFrame.LookVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - (camera.CFrame.RightVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + (camera.CFrame.RightVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end
		
		-- Aplicar velocidad
		bodyVelocity.velocity = moveDirection * flySpeed
		bodyGyro.cframe = camera.CFrame
	end)
	
	print("✈️ Vuelo activado")
end

local function disableFly()
	if not flying then return end
	
	flying = false
	
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	
	print("✈️ Vuelo desactivado")
end

-- ============================================
-- FUNCIÓN PARA ACTUALIZAR DINERO LOCAL
-- ============================================
local function updateLocalMoney(newValue)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local billetes = leaderstats:FindFirstChild("Billetes")
		if billetes then
			billetes.Value = newValue
		end
	end
end

-- ============================================
-- FUNCIÓN PARA ACTUALIZAR TRONCOS LOCAL
-- ============================================
local function updateLocalTroncos(newValue)
	local leaderstats1 = player:FindFirstChild("leaderstats1")
	if leaderstats1 then
		local troncos = leaderstats1:FindFirstChild("Troncos")
		if troncos then
			troncos.Value = newValue
		end
	end
end

-- ============================================
-- CREAR GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.35, 0, 0.65, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🎮 PANEL DE ADMINISTRACIÓN 🎮"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.Parent = titleBar

-- Botón de cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.ZIndex = 2
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- Botón toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "🎮\nAdmin"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Visible = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 10
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Name = "UIListLayout"
uiListLayout.Padding = UDim.new(0, 12)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = scrollFrame

-- ============================================
-- FUNCIONES HELPER PARA CREAR UI
-- ============================================
local function createSection(title, height, layoutOrder)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Size = UDim2.new(0.98, 0, 0, height)
	section.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	section.BorderSizePixel = 0
	section.LayoutOrder = layoutOrder
	section.Parent = scrollFrame

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 8)
	sectionCorner.Parent = section

	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Name = "Title"
	sectionTitle.Size = UDim2.new(1, 0, 0, 30)
	sectionTitle.Position = UDim2.new(0, 0, 0, 0)
	sectionTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sectionTitle.BorderSizePixel = 0
	sectionTitle.Text = "  " .. title
	sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextSize = 14
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = section

	local titleCorner2 = Instance.new("UICorner")
	titleCorner2.CornerRadius = UDim.new(0, 8)
	titleCorner2.Parent = sectionTitle

	return section
end

local function createButton(parent, name, text, color, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size or UDim2.new(0.48, 0, 0, 30)
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.AutoButtonColor = true
	button.Parent = parent

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	-- Efecto hover
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
			math.min(255, color.R * 255 + 30),
			math.min(255, color.G * 255 + 30),
			math.min(255, color.B * 255 + 30)
		)}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end)

	return button
end

local function createTextBox(parent, name, placeholder, position, size)
	local textBox = Instance.new("TextBox")
	textBox.Name = name
	textBox.Size = size or UDim2.new(0.48, 0, 0, 30)
	textBox.Position = position
	textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textBox.BorderSizePixel = 0
	textBox.PlaceholderText = placeholder
	textBox.Text = ""
	textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 12
	textBox.ClearTextOnFocus = false
	textBox.Parent = parent

	local textCorner = Instance.new("UICorner")
	textCorner.CornerRadius = UDim.new(0, 6)
	textCorner.Parent = textBox

	return textBox
end

-- ============================================
-- SECCIÓN 1: BILLETES (💰)
-- ============================================
local moneySection = createSection("💰 Sistema de Billetes", 110, 1)
local moneyInput = createTextBox(moneySection, "MoneyInput", "Cantidad de billetes...", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
local moneyAddButton = createButton(moneySection, "MoneyAddButton", "➕ Agregar", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 70))
local moneySetButton = createButton(moneySection, "MoneySetButton", "✏️ Establecer", Color3.fromRGB(60, 120, 180), UDim2.new(0.51, 0, 0, 70))

-- ============================================
-- SECCIÓN 2: TRONCOS (🪵)
-- ============================================
local troncosSection = createSection("🪵 Sistema de Troncos", 110, 2)
local troncosInput = createTextBox(troncosSection, "TroncosInput", "Cantidad de troncos...", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
local troncosAddButton = createButton(troncosSection, "TroncosAddButton", "➕ Agregar", Color3.fromRGB(200, 140, 60), UDim2.new(0.02, 0, 0, 70), UDim2.new(0.31, 0, 0, 30))
local troncosSetButton = createButton(troncosSection, "TroncosSetButton", "✏️ Set", Color3.fromRGB(60, 120, 180), UDim2.new(0.345, 0, 0, 70), UDim2.new(0.31, 0, 0, 30))
local troncosRemoveButton = createButton(troncosSection, "TroncosRemoveButton", "➖ Quitar", Color3.fromRGB(180, 60, 60), UDim2.new(0.67, 0, 0, 70), UDim2.new(0.31, 0, 0, 30))

-- ============================================
-- SECCIÓN 3: VELOCIDAD (⚡)
-- ============================================
local speedSection = createSection("⚡ Control de Velocidad", 80, 3)
local speedInput = createTextBox(speedSection, "SpeedInput", "Velocidad (16 = normal)", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
local speedSetButton = createButton(speedSection, "SpeedSetButton", "🚀 Aplicar Velocidad", Color3.fromRGB(60, 120, 180), UDim2.new(0.02, 0, 0, 70), UDim2.new(0.96, 0, 0, 30))

-- ============================================
-- SECCIÓN 4: VUELO (✈️)
-- ============================================
local flySection = createSection("✈️ Modo de Vuelo", 75, 4)
local flyEnableButton = createButton(flySection, "FlyEnableButton", "🚀 Activar Vuelo", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 35))
local flyDisableButton = createButton(flySection, "FlyDisableButton", "🛑 Desactivar Vuelo", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 35))

-- ============================================
-- SECCIÓN 5: METEORITOS (☄️)
-- ============================================
local meteorSection = createSection("☄️ Lluvia de Meteoritos", 140, 5)
local meteorTimeInput = createTextBox(meteorSection, "MeteorTimeInput", "Duración en segundos", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
meteorTimeInput.Text = "240"
local meteorStartButton = createButton(meteorSection, "MeteorStartButton", "▶️ Iniciar Local", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 70))
local meteorStopButton = createButton(meteorSection, "MeteorStopButton", "⏹️ Detener Local", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 70))
local meteorMultiButton = createButton(meteorSection, "MeteorMultiButton", "🌐 Iniciar (Todos)", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 105))
local meteorMultiStopButton = createButton(meteorSection, "MeteorMultiStopButton", "🌐 Detener (Todos)", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 105))

-- ============================================
-- SECCIÓN 6: AUDIO/MÚSICA (🎵)
-- ============================================
local audioSection = createSection("🎵 Sistema de Audio", 140, 6)
local audioInput = createTextBox(audioSection, "AudioInput", "ID del Audio", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
audioInput.Text = "74456998941899"
local audioPlayButton = createButton(audioSection, "AudioPlayButton", "▶️ Reproducir Local", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 70))
local audioStopButton = createButton(audioSection, "AudioStopButton", "⏹️ Detener Local", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 70))
local audioMultiButton = createButton(audioSection, "AudioMultiButton", "🌐 Reproducir (Todos)", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 105))
local audioMultiStopButton = createButton(audioSection, "AudioMultiStopButton", "🌐 Detener (Todos)", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 105))

-- ============================================
-- SECCIÓN 7: SISTEMA DE HUMO (💨)
-- ============================================
local humoSection = createSection("💨 Sistema de Humo", 140, 7)
local humoTimeInput = createTextBox(humoSection, "HumoTimeInput", "Duración en minutos", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
humoTimeInput.Text = "5"
local humoStartButton = createButton(humoSection, "HumoStartButton", "▶️ Activar Local", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 70))
local humoStopButton = createButton(humoSection, "HumoStopButton", "⏹️ Desactivar Local", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 70))
local humoMultiButton = createButton(humoSection, "HumoMultiButton", "🌐 Activar (Todos)", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 105))
local humoMultiStopButton = createButton(humoSection, "HumoMultiStopButton", "🌐 Desactivar (Todos)", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 105))

-- ============================================
-- SECCIÓN 8: LLUVIA (🌧️)
-- ============================================
local lluviaSection = createSection("🌧️ Sistema de Lluvia", 110, 8)
local lluviaStartButton = createButton(lluviaSection, "LluviaStartButton", "▶️ Activar Local", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 35))
local lluviaStopButton = createButton(lluviaSection, "LluviaStopButton", "⏹️ Desactivar Local", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 35))
local lluviaMultiButton = createButton(lluviaSection, "LluviaMultiButton", "🌐 Activar (Todos)", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 70))
local lluviaMultiStopButton = createButton(lluviaSection, "LluviaMultiStopButton", "🌐 Desactivar (Todos)", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 70))

-- ============================================
-- SECCIÓN 9: MENSAJES GLOBALES (💬)
-- ============================================
local messageSection = createSection("💬 Mensajes Globales", 110, 9)
local messageInput = createTextBox(messageSection, "MessageInput", "Escribe tu mensaje aquí...", UDim2.new(0.02, 0, 0, 35), UDim2.new(0.96, 0, 0, 30))
local messageSendButton = createButton(messageSection, "MessageSendButton", "📤 Enviar (Este Servidor)", Color3.fromRGB(60, 120, 180), UDim2.new(0.02, 0, 0, 70))
local messageSendAllButton = createButton(messageSection, "MessageSendAllButton", "🌐 Enviar (Todos los Servidores)", Color3.fromRGB(120, 80, 200), UDim2.new(0.51, 0, 0, 70))

-- ============================================
-- ACTUALIZAR CANVAS SIZE
-- ============================================
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
end)

-- ============================================
-- SISTEMA DE ARRASTRE
-- ============================================
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

-- ============================================
-- CONTROL DEL PANEL
-- ============================================
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	toggleButton.Visible = true
end)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	toggleButton.Visible = false
end)

-- ============================================
-- FUNCIONALIDAD: BILLETES
-- ============================================
moneyAddButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyInput.Text)
	if amount then
		MoneyEvent:FireServer("add", amount)
		moneyInput.Text = ""
		print("💰 Solicitando agregar $" .. amount .. " billetes")
	end
end)

moneySetButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyInput.Text)
	if amount then
		MoneyEvent:FireServer("set", amount)
		moneyInput.Text = ""
		print("💰 Solicitando establecer billetes a $" .. amount)
	end
end)

-- ============================================
-- FUNCIONALIDAD: TRONCOS
-- ============================================
troncosAddButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("add", amount)
		troncosInput.Text = ""
		print("🪵 Solicitando agregar " .. amount .. " troncos")
	end
end)

troncosRemoveButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("remove", amount)
		troncosInput.Text = ""
		print("🪵 Solicitando quitar " .. amount .. " troncos")
	end
end)

troncosSetButton.MouseButton1Click:Connect(function()
	local amount = tonumber(troncosInput.Text)
	if amount then
		TroncosEvent:FireServer("set", amount)
		troncosInput.Text = ""
		print("🪵 Solicitando establecer troncos a " .. amount)
	end
end)

-- ============================================
-- FUNCIONALIDAD: VELOCIDAD
-- ============================================
speedSetButton.MouseButton1Click:Connect(function()
	local speed = tonumber(speedInput.Text)
	if speed then
		SpeedEvent:FireServer(speed)
		
		-- Aplicar localmente también
		character = player.Character
		if character then
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = speed
				print("⚡ Velocidad establecida a " .. speed)
			end
		end
		
		speedInput.Text = ""
	end
end)

-- ============================================
-- FUNCIONALIDAD: VUELO
-- ============================================
flyEnableButton.MouseButton1Click:Connect(function()
	enableFly()
	FlyEvent:FireServer("enable")
end)

flyDisableButton.MouseButton1Click:Connect(function()
	disableFly()
	FlyEvent:FireServer("disable")
end)

-- ============================================
-- FUNCIONALIDAD: METEORITOS
-- ============================================
meteorStartButton.MouseButton1Click:Connect(function()
	local duration = tonumber(meteorTimeInput.Text) or 240
	MeteorEvent:FireServer("start", duration)
	print("☄️ Solicitando iniciar meteoritos por " .. duration .. " segundos")
end)

meteorStopButton.MouseButton1
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
