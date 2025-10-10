local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

-- Crear ScreenGui principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal con diseño responsive
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.3, 0, 0.55, 0)  -- Aumentado ligeramente para más contenido
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -30, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "PANEL DE ADMINISTRACIÓN"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

-- Botón de cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.ZIndex = 2
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Botón toggle (siempre visible cuando el panel está cerrado)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "📋\nPanel"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Visible = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- ScrollingFrame para el contenido
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Name = "UIListLayout"
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = scrollFrame

-- Función para crear secciones
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
	sectionTitle.Size = UDim2.new(1, 0, 0, 25)
	sectionTitle.Position = UDim2.new(0, 0, 0, 0)
	sectionTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sectionTitle.BorderSizePixel = 0
	sectionTitle.Text = "  " .. title
	sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextSize = 13
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = section

	local titleCorner2 = Instance.new("UICorner")
	titleCorner2.CornerRadius = UDim.new(0, 8)
	titleCorner2.Parent = sectionTitle

	return section
end

-- Función para crear botones
local function createButton(parent, name, text, color, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size or UDim2.new(0.48, 0, 0, 25)
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11
	button.AutoButtonColor = true
	button.Parent = parent

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 5)
	buttonCorner.Parent = button

	return button
end

-- Función para crear TextBox
local function createTextBox(parent, name, placeholder, position, size)
	local textBox = Instance.new("TextBox")
	textBox.Name = name
	textBox.Size = size or UDim2.new(0.48, 0, 0, 25)
	textBox.Position = position
	textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textBox.BorderSizePixel = 0
	textBox.PlaceholderText = placeholder
	textBox.Text = ""
	textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 11
	textBox.ClearTextOnFocus = false
	textBox.Parent = parent

	local textCorner = Instance.new("UICorner")
	textCorner.CornerRadius = UDim.new(0, 5)
	textCorner.Parent = textBox

	return textBox
end

-- ============================================
-- SECCIÓN 1: BILLETES
-- ============================================
local moneySection = createSection("💰 Billetes", 90, 1)
local moneyInput = createTextBox(moneySection, "MoneyInput", "Cantidad de billetes", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
local moneyAddButton = createButton(moneySection, "MoneyAddButton", "+ Agregar", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 60))
local moneySetButton = createButton(moneySection, "MoneySetButton", "Establecer", Color3.fromRGB(60, 120, 180), UDim2.new(0.51, 0, 0, 60))

-- ============================================
-- SECCIÓN 2: TRONCOS
-- ============================================
local troncosSection = createSection("🪵 Troncos", 90, 2)
local troncosInput = createTextBox(troncosSection, "TroncosInput", "Cantidad de troncos", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
local troncosAddButton = createButton(troncosSection, "TroncosAddButton", "+ Agregar", Color3.fromRGB(200, 140, 60), UDim2.new(0.02, 0, 0, 60), UDim2.new(0.31, 0, 0, 25))
local troncosSetButton = createButton(troncosSection, "TroncosSetButton", "Establecer", Color3.fromRGB(60, 120, 180), UDim2.new(0.345, 0, 0, 60), UDim2.new(0.31, 0, 0, 25))
local troncosRemoveButton = createButton(troncosSection, "TroncosRemoveButton", "- Quitar", Color3.fromRGB(180, 60, 60), UDim2.new(0.67, 0, 0, 60), UDim2.new(0.31, 0, 0, 25))

-- ============================================
-- SECCIÓN 3: VELOCIDAD
-- ============================================
local speedSection = createSection("⚡ Velocidad del Jugador", 65, 3)
local speedInput = createTextBox(speedSection, "SpeedInput", "Velocidad (16 = normal)", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
local speedSetButton = createButton(speedSection, "SpeedSetButton", "Aplicar Velocidad", Color3.fromRGB(60, 120, 180), UDim2.new(0.02, 0, 0, 60), UDim2.new(0.96, 0, 0, 25))

-- ============================================
-- SECCIÓN 4: VUELO
-- ============================================
local flySection = createSection("🚀 Modo Vuelo", 60, 4)
local flyEnableButton = createButton(flySection, "FlyEnableButton", "✓ Activar Vuelo", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 30))
local flyDisableButton = createButton(flySection, "FlyDisableButton", "✗ Desactivar Vuelo", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 30))

-- ============================================
-- SECCIÓN 5: METEORITOS
-- ============================================
local meteorSection = createSection("☄️ Lluvia de Meteoritos", 120, 5)
local meteorTimeInput = createTextBox(meteorSection, "MeteorTimeInput", "Duración (segundos)", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
meteorTimeInput.Text = "240"
local meteorStartButton = createButton(meteorSection, "MeteorStartButton", "▶ Iniciar", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 60))
local meteorStopButton = createButton(meteorSection, "MeteorStopButton", "■ Detener", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 60))
local meteorMultiButton = createButton(meteorSection, "MeteorMultiButton", "🌐 Iniciar en Todos", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 90))
local meteorMultiStopButton = createButton(meteorSection, "MeteorMultiStopButton", "🌐 Detener Todos", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 90))

-- ============================================
-- SECCIÓN 6: AUDIO/MÚSICA
-- ============================================
local audioSection = createSection("🎵 Sistema de Audio", 120, 6)
local audioInput = createTextBox(audioSection, "AudioInput", "ID del Audio", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
audioInput.Text = "74456998941899"
local audioPlayButton = createButton(audioSection, "AudioPlayButton", "▶ Reproducir", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 60))
local audioStopButton = createButton(audioSection, "AudioStopButton", "■ Detener", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 60))
local audioMultiButton = createButton(audioSection, "AudioMultiButton", "🌐 Todos los Servidores", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 90))
local audioMultiStopButton = createButton(audioSection, "AudioMultiStopButton", "🌐 Detener Todos", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 90))

-- ============================================
-- SECCIÓN 7: SISTEMA DE HUMO
-- ============================================
local humoSection = createSection("💨 Sistema de Humo", 120, 7)
local humoTimeInput = createTextBox(humoSection, "HumoTimeInput", "Duración (minutos)", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
humoTimeInput.Text = "5"
local humoStartButton = createButton(humoSection, "HumoStartButton", "▶ Activar Humo", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 60))
local humoStopButton = createButton(humoSection, "HumoStopButton", "■ Desactivar", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 60))
local humoMultiButton = createButton(humoSection, "HumoMultiButton", "🌐 Activar en Todos", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 90))
local humoMultiStopButton = createButton(humoSection, "HumoMultiStopButton", "🌐 Desactivar Todos", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 90))

-- ============================================
-- SECCIÓN 8: LLUVIA
-- ============================================
local lluviaSection = createSection("🌧️ Sistema de Lluvia", 90, 8)
local lluviaStartButton = createButton(lluviaSection, "LluviaStartButton", "▶ Activar Lluvia", Color3.fromRGB(60, 180, 60), UDim2.new(0.02, 0, 0, 30))
local lluviaStopButton = createButton(lluviaSection, "LluviaStopButton", "■ Desactivar", Color3.fromRGB(180, 60, 60), UDim2.new(0.51, 0, 0, 30))
local lluviaMultiButton = createButton(lluviaSection, "LluviaMultiButton", "🌐 Activar en Todos", Color3.fromRGB(120, 80, 200), UDim2.new(0.02, 0, 0, 60))
local lluviaMultiStopButton = createButton(lluviaSection, "LluviaMultiStopButton", "🌐 Desactivar Todos", Color3.fromRGB(150, 50, 150), UDim2.new(0.51, 0, 0, 60))

-- ============================================
-- SECCIÓN 9: MENSAJES GLOBALES
-- ============================================
local messageSection = createSection("💬 Mensajes Globales", 90, 9)
local messageInput = createTextBox(messageSection, "MessageInput", "Escribe tu mensaje aquí...", UDim2.new(0.02, 0, 0, 30), UDim2.new(0.96, 0, 0, 25))
local messageSendButton = createButton(messageSection, "MessageSendButton", "📤 Enviar (Este Servidor)", Color3.fromRGB(60, 120, 180), UDim2.new(0.02, 0, 0, 60))
local messageSendAllButton = createButton(messageSection, "MessageSendAllButton", "🌐 Enviar (Todos)", Color3.fromRGB(120, 80, 200), UDim2.new(0.51, 0, 0, 60))

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
-- BOTONES DE CONTROL DEL PANEL
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
	end
end)

moneySetButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyInput.Text)
	if amount then
		MoneyEvent:FireServer("set", amount)
		moneyInput.Text = ""
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

-- ============================================
-- FUNCIONALIDAD: VELOCIDAD
-- ============================================
speedSetButton.MouseButton1Click:Connect(function()
	local speed = tonumber(speedInput.Text)
	if speed then
		SpeedEvent:FireServer(speed)
		speedInput.Text = ""
	end
end)

-- ============================================
-- FUNCIONALIDAD: VUELO
-- ============================================
flyEnableButton.MouseButton1Click:Connect(function()
	FlyEvent:FireServer("enable")
end)

flyDisableButton.MouseButton1Click:Connect(function()
	FlyEvent:FireServer("disable")
end)

-- ============================================
-- FUNCIONALIDAD: METEORITOS
-- ============================================
meteorStartButton.MouseButton1Click:Connect(function()
	local duration = tonumber(meteorTimeInput.Text) or 240
	MeteorEvent:FireServer("start", duration)
end)

meteorStopButton.MouseButton1Click:Connect(function()
	MeteorEvent:FireServer("stop")
end)

meteorMultiButton.MouseButton1Click:Connect(function()
	local duration = tonumber(meteorTimeInput.Text) or 240
	MultiServerEvent:FireServer("Meteoros", "start", {Duration = duration})
end)

meteorMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Meteoros", "stop", {})
end)

-- ============================================
-- FUNCIONALIDAD: AUDIO
-- ============================================
audioPlayButton.MouseButton1Click:Connect(function()
	local audioId = audioInput.Text
	if audioId and audioId ~= "" then
		AudioEvent:FireServer("play", audioId)
	end
end)

audioStopButton.MouseButton1Click:Connect(function()
	AudioEvent:FireServer("stop")
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

-- ============================================
-- FUNCIONALIDAD: HUMO
-- ============================================
humoStartButton.MouseButton1Click:Connect(function()
	local minutos = tonumber(humoTimeInput.Text)
	if minutos and minutos > 0 then
		HumoEvent:FireServer("start", minutos)
	end
end)

humoStopButton.MouseButton1Click:Connect(function()
	HumoEvent:FireServer("stop")
end)

humoMultiButton.MouseButton1Click:Connect(function()
	local minutos = tonumber(humoTimeInput.Text) or 5
	MultiServerEvent:FireServer("Humo", "start", {Duration = minutos})
end)

humoMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Humo", "stop", {})
end)

-- ============================================
-- FUNCIONALIDAD: LLUVIA
-- ============================================
lluviaStartButton.MouseButton1Click:Connect(function()
	LluviaEvent:FireServer("start")
end)

lluviaStopButton.MouseButton1Click:Connect(function()
	LluviaEvent:FireServer("stop")
end)

lluviaMultiButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Lluvia", "start", {})
end)

lluviaMultiStopButton.MouseButton1Click:Connect(function()
	MultiServerEvent:FireServer("Lluvia", "stop", {})
end)

-- ============================================
-- FUNCIONALIDAD: MENSAJES GLOBALES
-- ============================================
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

-- ============================================
-- ATAJO DE TECLADO (F3)
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.F3 then
		mainFrame.Visible = not mainFrame.Visible
		toggleButton.Visible = not mainFrame.Visible
	end
end)

-- Estado inicial
mainFrame.Visible = false
toggleButton.Visible = true

print("✅ Panel de Administración cargado completamente")
print("📋 Todas las funcionalidades disponibles:")
print("   • Billetes (agregar/establecer)")
print("   • Troncos (agregar/quitar/establecer)")
print("   • Velocidad del jugador")
print("   • Modo vuelo")
print("   • Lluvia de meteoritos (local y multi-servidor)")
print("   • Sistema de audio (local y multi-servidor)")
print("   • Sistema de humo (local y multi-servidor)")
print("   • Sistema de lluvia (local y multi-servidor)")
print("   • Mensajes globales (servidor actual y todos los servidores)")
print("🎮 Presiona F3 para abrir/cerrar el panel")
