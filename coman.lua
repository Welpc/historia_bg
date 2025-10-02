-- 🌮 RECREACIÓN DEL EVENTO TACO TUESDAY (Steal a Brainrot) 🌮
-- LocalScript para StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear la GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "TacoTuesdayRecreation"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- MÚSICA: Se intenta cargar "It's Raining Tacos", con una de respaldo por si falla.
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9120564323" -- ID de "It's Raining Tacos" (puede necesitar cambio)
sound.Volume = 1
sound.Looped = true
sound.Parent = gui

-- Crear un cañón de tacos visual
local tacoCannon = Instance.new("ImageLabel")
tacoCannon.Name = "TacoCannon"
tacoCannon.Size = UDim2.new(0, 200, 0, 150)
tacoCannon.Position = UDim2.new(0.5, -100, 0.05, 0) -- Centrado en la parte superior
tacoCannon.AnchorPoint = Vector2.new(0.5, 0)
tacoCannon.BackgroundTransparency = 1
tacoCannon.Image = "rbxassetid://13123456789" -- Reemplaza con el ID de una imagen de un cañón
tacoCannon.Visible = false
tacoCannon.Parent = gui

-- Banner de estilo festivo
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 100)
banner.Position = UDim2.new(0, 0, -0.25, 0)
banner.BackgroundColor3 = Color3.fromRGB(200, 16, 46) -- Rojo
banner.BorderSizePixel = 0
banner.Parent = gui

local bannerGradient = Instance.new("UIGradient")
bannerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 16, 46)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 102, 71)) -- Verde
})
bannerGradient.Rotation = 90
bannerGradient.Parent = banner

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.FredokaOne
title.TextSize = 42
title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Dorado
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.Text = "🌮 !TACO TUESDAY! 🌮"
title.Parent = banner

-- Función para crear y disparar un taco desde el cañón
local function shootTaco()
    local taco = Instance.new("ImageLabel")
    taco.Size = UDim2.new(0, 60, 0, 60)
    taco.AnchorPoint = Vector2.new(0.5, 0.5)
    taco.Position = UDim2.new(0.5, 0, 0.05, 75) -- Sale del cañón
    taco.BackgroundTransparency = 1
    taco.Image = "rbxassetid://13092811742" -- Imagen de un taco
    taco.Parent = gui

    -- Animación de disparo con parábola
    local targetX = (math.random() - 0.5) * 1.6 -- Blanco aleatorio en X (-0.8 a 0.8)
    local targetY = math.random() * 0.6 + 0.3   -- Blanco aleatorio en Y (0.3 a 0.9)

    local tween = TweenService:Create(
        taco,
        TweenInfo.new(1, Enum.EasingStyle.Quad),
        {
            Position = UDim2.new(targetX, 0, targetY, 0),
            Rotation = 360,
            Size = UDim2.new(0, 45, 0, 45) -- El taco se reduce un poco al "volar"
        }
    )
    tween:Play()

    tween.Completed:Connect(function()
        taco:Destroy()
    end)
end

-- Función para crear partículas de tacos cayendo (lluvia de fondo)
local function spawnTacoParticle()
    local taco = Instance.new("ImageLabel")
    taco.Size = UDim2.new(0, 50, 0, 50)
    taco.Position = UDim2.new(math.random(), 0, -0.1, math.random(-50, 50))
    taco.BackgroundTransparency = 1
    taco.Image = "rbxassetid://13092811742" -- Imagen de un taco
    taco.Rotation = math.random(-15, 15)
    taco.Parent = gui

    local tweenInfo = TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(
        taco,
        tweenInfo,
        {
            Position = UDim2.new(taco.Position.X.Scale, 0, 1.2, 0),
            Rotation = taco.Rotation + math.random(-180, 180)
        }
    )
    tween:Play()
    tween.Completed:Connect(function()
        taco:Destroy()
    end)
end

-- Función principal que activa todo el evento
local function playTacoTuesdayEvent()
    -- Mostrar banner y cañón
    local slideIn = TweenService:Create(banner, TweenInfo.new(0.7, Enum.EasingStyle.Bounce), {Position = UDim2.new(0, 0, 0, 0)})
    slideIn:Play()

    tacoCannon.Visible = true
    tacoCannon.Rotation = -10
    local cannonSway = TweenService:Create(
        tacoCannon,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1),
        {Rotation = 10}
    )
    cannonSway:Play()

    -- Reproducir música
    pcall(function()
        sound:Stop()
        sound:Play()
    end)

    -- Disparar tacos del cañón (más intensos)
    for i = 1, 20 do
        shootTaco()
        wait(0.2)
    end

    -- Lluvia de tacos de fondo continua
    for i = 1, 50 do
        spawnTacoParticle()
        wait(0.1)
    end

    -- Finalizar evento después de 10 segundos
    wait(10)
    local slideOut = TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, -0.25, 0)})
    slideOut:Play()
    cannonSway:Cancel()
    tacoCannon.Visible = false
    sound:Stop()
end

-- Activación con tecla T
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T then
        playTacoTuesdayEvent()
    end
end)

-- Botón en pantalla
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(1, -220, 1, -70)
btn.Text = "🌮 !Taco Tuesday!"
btn.BackgroundColor3 = Color3.fromRGB(200, 16, 46)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.FredokaOne
btn.TextSize = 20
btn.Parent = gui

btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 102, 71)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 16, 46)}):Play()
end)
btn.MouseButton1Click:Connect(playTacoTuesdayEvent)
