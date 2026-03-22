-- ============================================
-- Script para Ejecutador: Dar 30 Wins
-- Pega y ejecuta directo en el ejecutador
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Eliminar GUI anterior si ya existe
local existente = player.PlayerGui:FindFirstChild("WinsGui")
if existente then existente:Destroy() end

-- ============================================
-- CREAR LA GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinsGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- TEXTO DE ESTADO (encima del botón)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 260, 0, 44)
statusLabel.Position = UDim2.new(0.5, -130, 0.85, -100)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusLabel.BackgroundTransparency = 0
statusLabel.BorderSizePixel = 0
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 15
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Visible = false
statusLabel.ZIndex = 20
statusLabel.Parent = screenGui

Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 10)

local statusStroke = Instance.new("UIStroke")
statusStroke.Thickness = 1.5
statusStroke.Parent = statusLabel

-- Marco del botón
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 80)
frame.Position = UDim2.new(0.5, -110, 0.85, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 215, 0)
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Botón principal
local button = Instance.new("TextButton")
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

Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

-- ============================================
-- ANIMACIONES
-- ============================================
button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 230, 80), TextSize = 19}):Play()
end)
button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0), TextSize = 18}):Play()
end)
button.MouseButton1Down:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.08), {Size = UDim2.new(0.95, -20, 0.9, -20)}):Play()
end)
button.MouseButton1Up:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 1, -20)}):Play()
end)

-- ============================================
-- FUNCIÓN: mostrar texto de estado
-- ============================================
local statusThread = nil
local function mostrarEstado(texto, color)
	if statusThread then task.cancel(statusThread) end
	statusStroke.Color = color
	statusLabel.TextColor3 = color
	statusLabel.Text = texto
	statusLabel.TextTransparency = 0
	statusLabel.Visible = true
	statusThread = task.delay(3, function()
		TweenService:Create(statusLabel, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
		task.wait(0.6)
		statusLabel.Visible = false
		statusLabel.TextTransparency = 0
	end)
end

-- ============================================
-- LÓGICA AL HACER CLIC
-- ============================================
local debounce = false

button.MouseButton1Click:Connect(function()
	if debounce then return end
	debounce = true

	-- 1) Verificar que el RemoteEvent existe
	local UpdateSpeed = ReplicatedStorage:FindFirstChild("UpdateSpeed")
	if not UpdateSpeed then
		mostrarEstado("❌ 'UpdateSpeed' no existe en ReplicatedStorage", Color3.fromRGB(220, 80, 80))
		button.Text = "❌  Sin Remote"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		debounce = false
		return
	end

	-- 2) Verificar leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		mostrarEstado("❌ No existe leaderstats en el jugador", Color3.fromRGB(220, 80, 80))
		button.Text = "❌  Sin leaderstats"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		debounce = false
		return
	end

	-- 3) Verificar stat Wins
	local wins = leaderstats:FindFirstChild("Wins")
	if not wins then
		mostrarEstado("❌ No se encontró el stat 'Wins'", Color3.fromRGB(220, 80, 80))
		button.Text = "❌  Sin stat"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		debounce = false
		return
	end

	-- 4) Todo OK: guardar valor actual y disparar remote
	local valorAntes = wins.Value
	mostrarEstado("⏳ Enviando al servidor...", Color3.fromRGB(255, 200, 0))
	UpdateSpeed:FireServer("Wins", 30)

	-- 5) Esperar hasta 5 segundos a que el valor cambie
	local limite = tick() + 5
	local funciono = false

	repeat
		task.wait(0.1)
		if wins.Value ~= valorAntes then
			funciono = true
			break
		end
	until tick() > limite

	-- 6) Mostrar resultado
	if funciono then
		button.Text = "✅  ¡+30 Wins!"
		button.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
		mostrarEstado("✅ ¡Funcionó! Wins: " .. valorAntes .. " → " .. wins.Value, Color3.fromRGB(80, 220, 100))
	else
		button.Text = "⚠️  Sin respuesta"
		button.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
		mostrarEstado("⚠️ El servidor no respondió (timeout 5s)", Color3.fromRGB(255, 160, 0))
	end

	task.wait(2)
	button.Text = "🏆  +30 Wins"
	button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	debounce = false
end)
