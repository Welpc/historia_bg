-- 🌮 Evento de Tacos (solo visual, cliente) 🌮
-- Coloca este LocalScript en StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TacoEventVisual"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Banner superior
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 80)
banner.Position = UDim2.new(0, 0, -0.2, 0)
banner.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
banner.BackgroundTransparency = 0.1
banner.BorderSizePixel = 0
banner.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.TextStrokeTransparency = 0.5
title.Text = "🌮 ¡EVENTO DE TACOS ACTIVADO! 🌮"
title.Parent = banner

-- Sonido de fiesta (ID de sonido de ejemplo)
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9120564323" -- Puedes cambiar este ID
sound.Volume = 0.7
sound.Parent = gui

-- Partículas de tacos cayendo
local function spawnTaco()
	local taco = Instance.new("ImageLabel")
	taco.Size = UDim2.new(0, 80, 0, 80)
	taco.Position = UDim2.new(math.random(), 0, -0.1, 0)
	taco.BackgroundTransparency = 1
	taco.Image = "rbxassetid://13092811742" -- Imagen de un taco
	taco.Rotation = math.random(-30, 30)
	taco.Parent = gui
	
	local tween = TweenService:Create(
		taco,
		TweenInfo.new(3, Enum.EasingStyle.Linear),
		{Position = UDim2.new(taco.Position.X.Scale, 0, 1.2, 0), Rotation = taco.Rotation + 180}
	)
	tween:Play()
	tween.Completed:Connect(function()
		taco:Destroy()
	end)
end

-- Función principal que activa el evento
local function playTacoEvent()
	-- Mostrar banner con animación
	local slideIn = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Position = UDim2.new(0, 0, 0, 0)})
	slideIn:Play()
	
	-- Reproducir sonido
	pcall(function() sound:Play() end)
	
	-- Generar tacos
	for i = 1, 25 do
		spawnTaco()
		wait(0.2)
	end
	
	-- Ocultar banner después de 6 segundos
	wait(6)
	local slideOut = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, -0.2, 0)})
	slideOut:Play()
end

-- Activación con tecla T
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		playTacoEvent()
	end
end)

-- Botón opcional en pantalla
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 160, 0, 40)
btn.Position = UDim2.new(1, -180, 1, -60)
btn.Text = "🌮 Activar Evento"
btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
btn.TextColor3 = Color3.fromRGB(0, 0, 0)
btn.Font = Enum.Font.GothamBold
btn.Parent = gui
btn.MouseButton1Click:Connect(playTacoEvent)
