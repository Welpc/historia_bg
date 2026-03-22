-- ============================================
-- LocalScript: Dar 30 Wins
-- Ubicación: StarterPlayerScripts
-- ============================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- ============================================
-- CREAR LA GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinsGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui
-- Marco del botón
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 220, 0, 80)
frame.Position = UDim2.new(0.5, -110, 0.85, -40) -- Centro inferior de la pantalla
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
-- Bordes redondeados al frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame
-- Sombra/stroke decorativo
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 215, 0)
frameStroke.Thickness = 2
frameStroke.Parent = frame
-- Botón principal
local button = Instance.new("TextButton")
button.Name = "DarWinsBtn"
button.Size = UDim2.new(1, -20, 1, -20)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
button.TextColor3 = Color3.fromRGB(20, 20, 30)
button.Text = "🏆  +30 Wins"
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = frame
-- Bordes redondeados al botón
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = button
-- ============================================
-- ANIMACIÓN DEL BOTÓN
-- ============================================
local TweenService = game:GetService("TweenService")
-- Efecto hover: botón se ilumina al pasar el mouse
button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(255, 230, 80),
		TextSize = 19,
	}):Play()
end)
button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(255, 200, 0),
		TextSize = 18,
	}):Play()
end)
-- Efecto clic: botón se encoge brevemente
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
-- LÓGICA: DAR 30 WINS AL HACER CLIC via UpdateSpeed
-- ============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateSpeed = ReplicatedStorage:WaitForChild("UpdateSpeed")

button.MouseButton1Click:Connect(function()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local wins = leaderstats:FindFirstChild("Wins")
		if wins then
			UpdateSpeed:FireServer("Wins", 30)
			-- Feedback visual: cambiar texto temporalmente
			button.Text = "✅  ¡+30 Wins!"
			button.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
			task.wait(1.5)
			button.Text = "🏆  +30 Wins"
			button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		else
			-- Si no encuentra el stat "Wins"
			button.Text = "❌  Stat no encontrado"
			button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			task.wait(2)
			button.Text = "🏆  +30 Wins"
			button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		end
	else
		-- Si no existe leaderstats
		button.Text = "❌  Sin leaderstats"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	end
end)
