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
frame.Position = UDim2.new(0.5, -110, 0.85, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
-- Bordes redondeados al frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame
-- Stroke decorativo
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
-- TEXTO DE ESTADO (aparece encima del botón)
-- ============================================
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 220, 0, 40)
statusLabel.Position = UDim2.new(0.5, -110, 0.85, -90) -- Encima del botón
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextStrokeTransparency = 0.4 -- Sombra al texto para que se vea bien
statusLabel.Parent = screenGui

-- ============================================
-- ANIMACIÓN DEL BOTÓN
-- ============================================
local TweenService = game:GetService("TweenService")

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
-- FUNCIÓN: mostrar texto de estado y ocultarlo
-- ============================================
local function mostrarEstado(texto, color)
	statusLabel.Text = texto
	statusLabel.TextColor3 = color
	statusLabel.TextTransparency = 0

	-- Desvanecer después de 2.5 segundos
	task.delay(2, function()
		TweenService:Create(statusLabel, TweenInfo.new(0.5), {
			TextTransparency = 1,
		}):Play()
		task.wait(0.5)
		statusLabel.Text = ""
	end)
end

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
			-- Feedback botón
			button.Text = "✅  ¡+30 Wins!"
			button.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
			-- Texto de estado encima
			mostrarEstado("✅ ¡Funcionó! Se añadieron 30 Wins", Color3.fromRGB(80, 220, 100))
			task.wait(1.5)
			button.Text = "🏆  +30 Wins"
			button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		else
			button.Text = "❌  Error"
			button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			mostrarEstado("❌ No se encontró el stat 'Wins'", Color3.fromRGB(220, 60, 60))
			task.wait(2)
			button.Text = "🏆  +30 Wins"
			button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		end
	else
		button.Text = "❌  Error"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		mostrarEstado("❌ No existe leaderstats", Color3.fromRGB(220, 60, 60))
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	end
end)
