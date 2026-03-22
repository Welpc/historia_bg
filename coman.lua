-- ============================================
-- LocalScript: Dar 30 Wins via RemoteEvent
-- Ubicación: StarterPlayerScripts
-- RemoteEvent: UpdateSpeed (en ReplicatedStorage)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Esperar a que el RemoteEvent exista
local UpdateSpeed = ReplicatedStorage:WaitForChild("UpdateSpeed")

-- ============================================
-- CREAR LA GUI
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinsGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Marco contenedor
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 230, 0, 80)
frame.Position = UDim2.new(0.5, -115, 0.85, -40)
frame.BackgroundColor3 = Color3.fromRGB(10, 15, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 180, 255)
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Botón principal
local button = Instance.new("TextButton")
button.Name = "DarWinsBtn"
button.Size = UDim2.new(1, -20, 1, -20)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "🏅  +30 Wins"
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = button

-- ============================================
-- ANIMACIONES
-- ============================================

button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(90, 170, 255),
		TextSize = 19,
	}):Play()
end)

button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(50, 140, 255),
		TextSize = 18,
	}):Play()
end)

button.MouseButton1Down:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.08), {
		Size = UDim2.new(0.95, -20, 0.9, -20),
	}):Play()
end)

button.MouseButton1Up:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = UDim2.new(1, -20, 1, -20),
	}):Play()
end)

-- ============================================
-- LÓGICA: ENVIAR REMOTE EVENT AL HACER CLIC
-- ============================================

local debounce = false -- Evita spam de clics

button.MouseButton1Click:Connect(function()
	if debounce then return end
	debounce = true

	-- Deshabilitar botón mientras procesa
	button.Text = "⏳  Enviando..."
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 120)

	-- Disparar el RemoteEvent hacia el servidor con 30 Wins
	UpdateSpeed:FireServer("Wins", 30)

	-- Feedback visual de éxito
	task.wait(0.5)
	button.Text = "✅  ¡+30 Wins!"
	button.BackgroundColor3 = Color3.fromRGB(60, 210, 110)

	task.wait(1.5)

	-- Restaurar botón
	button.Text = "🏅  +30 Wins"
	button.BackgroundColor3 = Color3.fromRGB(50, 140, 255)

	task.wait(0.5) -- Cooldown extra
	debounce = false
end)
