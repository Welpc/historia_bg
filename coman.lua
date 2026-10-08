-- Script para Delta Executor - Adopt Me
-- Hace clic SOLO en las necesidades reales de la mascota
-- Con velocidad humanizada (pausas aleatorias) para evitar detección

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. INTERFAZ DE USUARIO
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdoptMeHumanClick"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 140)
mainFrame.Position = UDim2.new(0.5, -115, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Auto Pet Needs (Humano)"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Inactivo"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
toggleButton.Position = UDim2.new(0.05, 0, 0, 55)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleButton.Text = "INICIAR AUTO"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 95)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Clic humanizado con pausas\naleatorias entre acciones"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

-- ============================================================
-- 2. CONFIGURACIÓN DE NECESIDADES REALES
-- ============================================================
-- Lista exacta de necesidades que aparecen en la GUI de la mascota
-- Solo estas se clickearán, nada más
local NEEDS = {
    "Potty",
    "Hungry",
    "Thirsty",
    "Sleepy",
    "Dirty",
    "Play",
    "School",
    "Salon",
    "Sick",
    "Bored",
    "Walk",
    "Ride",
    "Camping",
    "Beach",
    "Pizza",
}

-- Tiempo mínimo y máximo entre clics (en segundos)
local MIN_DELAY = 1.5
local MAX_DELAY = 3.5

-- ============================================================
-- 3. FUNCIONES
-- ============================================================
local isRunning = false

-- Obtener mascota equipada
local function getEquippedPet()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Model") and (child.Name:lower():find("pet") or child:FindFirstChild("Humanoid")) then
            return child
        end
    end
    return nil
end

-- Verificar si un texto coincide EXACTAMENTE con una necesidad
local function isNeedText(text)
    if not text or text == "" then return false end
    local lowerText = text:lower()
    for _, need in ipairs(NEEDS) do
        -- Coincidencia exacta o que contenga la palabra completa
        if lowerText == need:lower() or lowerText:find("%f[%a]" .. need:lower() .. "%f[%A]") then
            return true, need
        end
    end
    return false, nil
end

-- Buscar SOLO botones de necesidades en la GUI de la mascota
local function getNeedButtons(pet)
    local found = {}
    if not pet then return found end

    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            -- Solo considerar botones (TextButton o ImageButton)
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                -- Verificar si el nombre o texto coincide con una necesidad
                local nameMatch, nameNeed = isNeedText(child.Name)
                local textMatch, textNeed = isNeedText(child.Text)

                if nameMatch or textMatch then
                    table.insert(found, {
                        button = child,
                        need = nameNeed or textNeed
                    })
                end
            end
            -- Escanear hijos recursivamente
            if #child:GetChildren() > 0 then
                scan(child)
            end
        end
    end

    scan(pet)
    return found
end

-- Simular clic humanizado (con movimiento y pausa)
local function humanClick(button)
    local success = pcall(function()
        local virtualInputManager = game:GetService("VirtualInputManager")
        local absPos = button.AbsolutePosition
        local absSize = button.AbsoluteSize

        -- Coordenadas con pequeña variación aleatoria (simula mano humana)
        local offsetX = math.random(-5, 5)
        local offsetY = math.random(-5, 5)
        local clickX = absPos.X + (absSize.X / 2) + offsetX
        local clickY = absPos.Y + (absSize.Y / 2) + offsetY

        -- Mover el mouse primero (como un humano)
        virtualInputManager:SendMouseMoveEvent(clickX, clickY, game)
        task.wait(math.random(10, 25) / 100) -- pausa de 0.10-0.25 seg

        -- Presionar
        virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
        task.wait(math.random(5, 15) / 100) -- pausa de 0.05-0.15 seg

        -- Soltar
        virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
    end)
    return success
end

-- Bucle principal
local function autoLoop()
    while isRunning do
        local success, err = pcall(function()
            local pet = getEquippedPet()

            if pet then
                local needButtons = getNeedButtons(pet)

                if #needButtons > 0 then
                    -- Solo hacer clic en la PRIMERA necesidad encontrada
                    local target = needButtons[1]
                    statusLabel.Text = "Clic en: " .. target.need

                    humanClick(target.button)

                    -- Esperar un tiempo aleatorio entre 1.5 y 3.5 segundos
                    -- Esto imita el tiempo de reacción humano
                    local delay = MIN_DELAY + math.random() * (MAX_DELAY - MIN_DELAY)
                    task.wait(delay)
                else
                    statusLabel.Text = "Esperando necesidad..."
                    task.wait(1)
                end
            else
                statusLabel.Text = "Sin mascota equipada"
                task.wait(1)
            end

            -- Anti-AFK suave
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end)

        if not success then
            warn("[HumanClick] Error: " .. tostring(err))
        end

        task.wait(0.3)
    end
end

-- ============================================================
-- 4. CONTROL DEL BOTÓN
-- ============================================================
toggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleButton.Text = "DETENER AUTO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        statusLabel.Text = "Iniciando (modo humano)..."
        task.spawn(autoLoop)
    else
        toggleButton.Text = "INICIAR AUTO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Inactivo"
    end
end)

print("[HumanClick] Script cargado. Clic humanizado solo en necesidades reales.")
print("[HumanClick] Delay entre clics: 1.5 - 3.5 segundos (aleatorio)")
