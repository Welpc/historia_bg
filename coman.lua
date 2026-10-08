-- Script para Delta Executor - Adopt Me
-- Detecta la necesidad de la mascota y hace CLIC directamente en ella
-- No camina, solo simula clics en la interfaz de necesidades

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. INTERFAZ DE USUARIO
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdoptMeClickNeeds"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
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
title.Text = "Auto Click Pet Needs"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
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
infoLabel.Size = UDim2.new(1, 0, 0, 30)
infoLabel.Position = UDim2.new(0, 0, 0, 95)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Hace clic en las necesidades\nde la mascota automáticamente"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

-- ============================================================
-- 2. FUNCIONES DE DETECCIÓN Y CLIC
-- ============================================================
local isRunning = false

-- Obtener la mascota equipada
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

-- Detectar necesidades en la GUI de la mascota
local function getNeedButtons(pet)
    local buttons = {}
    if not pet then return buttons end

    -- Buscar en toda la jerarquía de la mascota
    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                -- Botones que contienen texto de necesidades
                local text = child.Text or ""
                local name = child.Name or ""
                local combined = (text .. " " .. name):lower()

                local needsList = {
                    "potty", "hungry", "thirsty", "sleepy", "dirty",
                    "play", "school", "salon", "sick", "beach",
                    "camping", "pizza", "walk", "ride", "bored",
                    "catch", "choose", "rain", "leaf", "snow"
                }

                for _, need in ipairs(needsList) do
                    if combined:find(need) then
                        table.insert(buttons, {button = child, need = need})
                        break
                    end
                end
            end
            -- Escanear recursivamente
            if #child:GetChildren() > 0 then
                scan(child)
            end
        end
    end

    scan(pet)
    return buttons
end

-- Simular clic en un botón (funciona con cualquier ejecutor)
local function clickButton(button)
    local success = pcall(function()
        -- Método 1: usar la función interna de Roblox
        if button.Activated then
            button:Activated()
        end

        -- Método 2: simular clic con VirtualInputManager (coordenadas del botón)
        local virtualInputManager = game:GetService("VirtualInputManager")
        local absPos = button.AbsolutePosition
        local absSize = button.AbsoluteSize
        local centerX = absPos.X + (absSize.X / 2)
        local centerY = absPos.Y + (absSize.Y / 2)

        virtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.05)
        virtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
    end)
    return success
end

-- ============================================================
-- 3. BUCLE PRINCIPAL
-- ============================================================
local function autoClickLoop()
    while isRunning do
        local success, err = pcall(function()
            local pet = getEquippedPet()

            if pet then
                local buttons = getNeedButtons(pet)

                if #buttons > 0 then
                    for _, data in ipairs(buttons) do
                        if not isRunning then break end
                        statusLabel.Text = "Clic en: " .. data.need
                        clickButton(data.button)
                        task.wait(0.5)
                    end
                else
                    statusLabel.Text = "Sin necesidades visibles"
                end
            else
                statusLabel.Text = "Sin mascota equipada"
            end

            -- Anti-AFK
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end)

        if not success then
            warn("[ClickNeeds] Error: " .. tostring(err))
        end

        task.wait(0.8)
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
        statusLabel.Text = "Buscando necesidades..."
        task.spawn(autoClickLoop)
    else
        toggleButton.Text = "INICIAR AUTO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Inactivo"
    end
end)

print("[ClickNeeds] Script cargado. Hace clic en necesidades de mascota.")
print("[ClickNeeds] Presiona INICIAR AUTO para comenzar.")
