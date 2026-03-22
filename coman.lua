-- ============================================
-- LocalScript: Dar 30 Wins
-- Ubicación: StarterPlayerScripts
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ============================================
-- CREAR LA GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinsGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- TEXTO DE ESTADO (encima del botón, siempre en el ScreenGui)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 260, 0, 44)
statusLabel.Position = UDim2.new(0.5, -130, 0.85, -100) -- justo encima del botón
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusLabel.BackgroundTransparency = 0
statusLabel.BorderSizePixel = 0
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 15
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Visible = false -- oculto al inicio
statusLabel.ZIndex = 20
statusLabel.Parent = screenGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusLabel

local statusStroke = Instance.new("UIStroke")
statusStroke.Thickness = 1.5
statusStroke.Color = Color3.fromRGB(255, 255, 255)
statusStroke.Parent = statusLabel

-- Marco del botón
local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 220, 0, 80)
frame.Position = UDim2.new(0.5, -110, 0.85, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

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

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = button

-- ============================================
-- ANIMACIÓN DEL BOTÓN
-- ============================================
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
-- FUNCIÓN: mostrar texto de estado
-- ============================================
local statusThread = nil

local function mostrarEstado(texto, color, strokeColor)
	-- Cancelar hilo anterior si existe
	if statusThread then
		task.cancel(statusThread)
		statusThread = nil
	end

	statusStroke.Color = strokeColor or color
	statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	statusLabel.TextColor3 = color
	statusLabel.Text = texto
	statusLabel.TextTransparency = 0
	statusLabel.Visible = true

	statusThread = task.delay(2.5, function()
		TweenService:Create(statusLabel, TweenInfo.new(0.6), {
			TextTransparency = 1,
		}):Play()
		task.wait(0.6)
		statusLabel.Visible = false
		statusLabel.TextTransparency = 0
	end)
end

-- ============================================
-- LÓGICA: DAR 30 WINS AL HACER CLIC via UpdateSpeed
-- ============================================
local UpdateSpeed = ReplicatedStorage:WaitForChild("UpdateSpeed", 10)

button.MouseButton1Click:Connect(function()
	-- Verificar que el RemoteEvent existe
	if not UpdateSpeed then
		button.Text = "❌  Error"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		mostrarEstado("❌ RemoteEvent 'UpdateSpeed' no encontrado", Color3.fromRGB(220, 80, 80), Color3.fromRGB(220, 80, 80))
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local wins = leaderstats:FindFirstChild("Wins")
		if wins then
			-- Disparar el remote y esperar respuesta con timeout
			local respondio = false

			-- Escuchar respuesta del servidor (necesita OnClientEvent en el servidor)
			local conn
			conn = UpdateSpeed.OnClientEvent:Connect(function(resultado)
				respondio = true
				conn:Disconnect()
				if resultado == true then
					button.Text = "✅  ¡+30 Wins!"
					button.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
					mostrarEstado("✅ ¡Funcionó! Se añadieron 30 Wins", Color3.fromRGB(80, 220, 100), Color3.fromRGB(60, 180, 80))
				else
					button.Text = "❌  Falló"
					button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
					mostrarEstado("❌ El servidor no pudo añadir los Wins", Color3.fromRGB(220, 80, 80), Color3.fromRGB(220, 80, 80))
				end
				task.wait(1.5)
				button.Text = "🏆  +30 Wins"
				button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
			end)

			UpdateSpeed:FireServer("Wins", 30)
			mostrarEstado("⏳ Enviando al servidor...", Color3.fromRGB(255, 200, 0), Color3.fromRGB(200, 160, 0))

			-- Timeout de 5 segundos: si el servidor no responde
			task.delay(5, function()
				if not respondio then
					conn:Disconnect()
					button.Text = "⚠️  Sin respuesta"
					button.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
					mostrarEstado("⚠️ El RemoteEvent no respondió (timeout)", Color3.fromRGB(255, 160, 0), Color3.fromRGB(200, 120, 0))
					task.wait(2)
					button.Text = "🏆  +30 Wins"
					button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
				end
			end)
		else
			button.Text = "❌  Error"
			button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			mostrarEstado("❌ No se encontró el stat 'Wins'", Color3.fromRGB(220, 80, 80), Color3.fromRGB(220, 80, 80))
			task.wait(2)
			button.Text = "🏆  +30 Wins"
			button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		end
	else
		button.Text = "❌  Error"
		button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		mostrarEstado("❌ No existe leaderstats en el jugador", Color3.fromRGB(220, 80, 80), Color3.fromRGB(220, 80, 80))
		task.wait(2)
		button.Text = "🏆  +30 Wins"
		button.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	end
end)
