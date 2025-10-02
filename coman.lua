-- 🌮 EVENTO DE TACOS VISUAL (Steal a Brainrot Style) 🌮
-- LocalScript para StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear la GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "TacoEventGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- SONIDO: It's Raining Tacos :cite[2]
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9120564323" -- Reemplaza con el ID de "It's Raining Tacos" si es necesario
sound.Volume = 1
sound.Looped = true
sound.Parent = gui

-- Banner superior de estilo mexicano
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 100)
banner.Position = UDim2.new(0, 0, -0.25, 0)
banner.BackgroundColor3 = Color3.fromRGB(200, 16, 46) -- Rojo mexicano
banner.BorderSizePixel = 0
banner.Parent = gui

local bannerGradient = Instance.new("UIGradient")
bannerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 16, 46)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 102, 71)) -- Verde mexicano
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
title.Text = "🌮 ¡IT'S RAINING TACOS! 🌮"
title.Parent = banner

-- Efecto de partículas de tacos cayendo
local tacoImages = {
    "rbxassetid://13092811742", -- Imagen de taco estándar
    "rbxassetid://13245678901", -- Imagen de taco corrupto (si la encuentras)
}

local function spawnTacoParticle()
    local taco = Instance.new("ImageLabel")
    taco.Size = UDim2.new(0, 60, 0, 60)
    taco.Position = UDim2.new(math.random(), 0, -0.1, math.random(-50, 50))
    taco.BackgroundTransparency = 1
    taco.Image = tacoImages[math.random(1, #tacoImages)]
    taco.Rotation = math.random(-15, 15)
    taco.Parent = gui

    -- Animación de caída con balanceo
    local tweenInfo = TweenInfo.new(
        math.random(3, 5), 
        Enum.EasingStyle.Linear
    )
    
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

-- Crear un cañón de tacos visual :cite[2]
local function createTacoCannon()
    local cannon = Instance.new("ImageLabel")
    cannon.Size = UDim2.new(0, 150, 0, 150)
    cannon.Position = UDim2.new(0.5, -75, 0.1, 0)
    cannon.BackgroundTransparency = 1
    cannon.Image = "rbxassetid://13123456789" -- Imagen de un cañón, si tienes una
    cannon.Parent = gui
    cannon.Visible = false
    return cannon
end

local tacoCannon = createTacoCannon()

-- Función para disparar un taco desde el cañón
local function shootTacoFromCannon()
    if not tacoCannon.Visible then return end
    
    local taco = Instance.new("ImageLabel")
    taco.Size = UDim2.new(0, 50, 0, 50)
    taco.AnchorPoint = Vector2.new(0.5, 0.5)
    taco.Position = UDim2.new(0.5, 0, 0.1, 75)
    taco.BackgroundTransparency = 1
    taco.Image = tacoImages[1]
    taco.Parent = gui

    local targetX = math.random(0.1, 0.9)
    local targetY = math.random(0.3, 0.9)
    
    local tween = TweenService:Create(
        taco,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad),
        {
            Position = UDim2.new(targetX, 0, targetY, 0),
            Rotation = 360
        }
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        spawnTacoParticle() -- Cuando el taco impacta, genera partículas
        taco:Destroy()
    end)
end

-- Función principal del evento
local function playTacoEvent()
    -- Mostrar banner con animación mejorada
    local slideIn = TweenService:Create(
        banner, 
        TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    )
    slideIn:Play()
    
    -- Reproducir música de fondo :cite[2]
    pcall(function() 
        sound:Stop()
        sound:Play() 
    end)
    
    -- Mostrar y animar el cañón
    tacoCannon.Visible = true
    tacoCannon.Rotation = -10
    local cannonSway = TweenService:Create(
        tacoCannon,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1),
        {Rotation = 10}
    )
    cannonSway:Play()
    
    -- Disparar tacos desde el cañón
    for i = 1, 15 do
        shootTacoFromCannon()
        wait(0.3)
    end
    
    -- Generar partículas de tacos adicionales
    for i = 1, 40 do
        spawnTacoParticle()
        wait(0.15)
    end
    
    -- Finalizar evento después de 8 segundos
    wait(8)
    
    -- Ocultar banner
    local slideOut = TweenService:Create(
        banner, 
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {Position = UDim2.new(0, 0, -0.25, 0)}
    )
    slideOut:Play()
    
    -- Detener efectos
    cannonSway:Cancel()
    tacoCannon.Visible = false
    sound:Stop()
end

-- Activación con tecla T
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T then
        playTacoEvent()
    end
end)

-- Botón en pantalla con estilo mexicano
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(1, -220, 1, -70)
btn.Text = "🌮 ¡Taco Event!"
btn.BackgroundColor3 = Color3.fromRGB(200, 16, 46)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.FredokaOne
btn.TextSize = 20
btn.Parent = gui

-- Efecto hover para el botón
btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 102, 71)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 16, 46)}):Play()
end)

btn.MouseButton1Click:Connect(playTacoEvent)
