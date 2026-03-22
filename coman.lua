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
screenGui.IgnoreGuiInset = true -- Evita que la GUI se desplace por la barra de Roblox
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Marco contenedor
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 240, 0, 70)
frame.Position = UDim2.new(0, 20, 0.5, -35) -- Izquierda, centro vertical
frame.BackgroundColor3 = Color3.fromRGB(10, 15, 35)
frame.BorderSizePixel = 0
frame.ZIndex = 10
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 180, 255)
frameStroke.Thickness = 2.5
frameStroke.Parent = frame

-- Botón principal
local button = Instance.new("TextButton")
button.Name = "DarWinsBtn"
button.Size = UDim2.new(1, 0, 1, 0)
button.Position = UDim2.new(0, 0, 0, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 140, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "🏅  +30 Wins"
button.TextSize = 20
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.ZIndex = 11
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 14)
btnCorner.Parent = button

-- ============================================
-- ANIMACIONES
-- ============================================

button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(90, 170, 255),
	}):Play()
end)

button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(50, 140, 255),
	}):Play()
end)

button.MouseButton1Down:Connect(function()
	TweenService:Create(frame, TweenInfo.new(0.08), {
		Size = UDim2.new(0, 225, 0, 65),
	}):Play()
end)

button.MouseButton1Up:Connect(function()
	TweenService:Create(frame, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 240, 0, 70),
	}):Play()
end)

-- ============================================
-- LÓGICA: ENVIAR REMOTE EVENT AL HACER CLIC
-- ============================================

local debounce = false

button.MouseButton1Click:Connect(function()
	if debounce then return end
	debounce = true

	button.Text = "⏳  Enviando..."
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 120)

	UpdateSpeed:FireServer("Wins", 30)

	task.wait(0.5)
	button.Text = "✅  ¡+30 Wins!"
	button.BackgroundColor3 = Color3.fromRGB(60, 210, 110)

	task.wait(1.5)

	button.Text = "🏅  +30 Wins"
	button.BackgroundColor3 = Color3.fromRGB(50, 140, 255)

	task.wait(0.5)
	debounce = false
end)
