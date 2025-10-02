-- 🌮 Evento de Tacos (solo visual, cliente) 🌮
-- Coloca este LocalScript en StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TacoEventVisual"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Banner superior
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1,0,0,80)
banner.Position = UDim2.new(0,0,-0.2,0)
banner.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
banner.BackgroundTransparency = 0.1
banner.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(255,255,0)
title.TextStrokeTransparency = 0.5
title.Text = "🌮 ¡EVENTO DE TACOS ACTIVADO! 🌮"
title.Parent = banner

-- Sonido (puedes cambiar el ID por música mexicana o fiesta)
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9120564323" -- cámbialo si quieres
sound.Volume = 1
sound.Parent = gui

-- Partículas de tacos cayendo (usamos ImageLabels)
local function spawnTaco()
	local taco = Instance.new("ImageLabel")
	taco.Size = UDim2.new(0,80,0,80)
	taco.Position = UDim2.new(math.random(),0,-0.1,0)
	taco.BackgroundTransparency = 1
	taco.Image = "rbxassetid://13092811742" -- imagen de taco, cámbialo si quieres
	taco.Parent = gui
	
	-- Tween hacia abajo
	local tween = TweenService:Create(
		taco,
		TweenInfo.new(3, Enum.EasingStyle.Linear),
		{Position = UDim2.new(taco.Position.X.Scale,0,1.2,0)}
	)
	tween:Play()
	tween.Completed:Connect(function()
		taco:Destroy()
	end)
end

-- Función principal
local function playTacoEvent()
	-- Muestra banner
	TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Position = UDim2.new(0,0,0,0)}):Play()
	
	-- Sonido
	pcall(function() sound:Play() end)
	
	-- Spawnear tacos durante unos segundos
	for i=1,25 do
		spawnTaco()
		wait(0.2)
	end
	
	-- Ocultar banner después de 6s
	wait(6)
	TweenService:Create(banner, TweenInfo.new(0.5), {Position = UDim2.new(0,0,-0.2,0)}):Play()
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
btn.Size = UDim2.new(0,160,0,40)
btn.Position = UDim2.new(1,-180,1,-60)
btn.Text = "🌮 Activar Evento"
btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
btn.Parent = gui
btn.MouseButton1Click:Connect(playTacoEvent)
