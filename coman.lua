-- Script para Delta Executor - Adopt Me
-- Auto-completa necesidades de mascotas automáticamente
-- Funciona con las nuevas necesidades del juego (Potty, Sleep, Hungry, Thirsty, etc.)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. CONFIGURACIÓN DE NECESIDADES Y UBICACIONES
-- ============================================================
local PetNeeds = {
    -- Necesidades básicas (aparecen siempre)
    ["Potty"] = {Location = "Fire Hydrant", Type = "Proximity"},
    ["Hungry"] = {Location = "Pizza Shop", Type = "Proximity"},
    ["Thirsty"] = {Location = "Water Fountain", Type = "Proximity"},
    ["Sleepy"] = {Location = "Campsite", Type = "Proximity"},
    ["Dirty"] = {Location = "Bathroom", Type = "Proximity"},
    ["Play"] = {Location = "Playground", Type = "Proximity"},
    ["Walk"] = {Location = "Adoption Island", Type = "Proximity"},
    ["Ride"] = {Location = "Vehicle", Type = "Proximity"},
    
    -- Necesidades de ubicación
    ["School"] = {Location = "School", Type = "Proximity"},
    ["Salon"] = {Location = "Salon", Type = "Proximity"},
    ["Camping"] = {Location = "Campsite", Type = "Proximity"},
    ["Pizza Party"] = {Location = "Pizza Shop", Type = "Proximity"},
    ["Beach Party"] = {Location = "Beach", Type = "Proximity"},
    ["Sick"] = {Location = "Hospital", Type = "Proximity"},
    ["Bored"] = {Location = "Playground", Type = "Proximity"},
    
    -- Necesidades avanzadas
    ["Catch"] = {Location = "Playground", Type = "Proximity"},
    ["Choose"] = {Location = "Auto", Type = "Dynamic"},
    
    -- Necesidades de clima
    ["Rain Puddle"] = {Location = "Adoption Island", Type = "Weather"},
    ["Leaf Pile"] = {Location = "Adoption Island", Type = "Weather"},
    ["Diving Board"] = {Location = "Beach", Type = "Weather"},
    ["Snowman"] = {Location = "Adoption Island", Type = "Weather"},
}

-- Coordenadas aproximadas de ubicaciones clave
local Locations = {
    ["Fire Hydrant"] = Vector3.new(0, 5, 0),
    ["Pizza Shop"] = Vector3.new(0, 5, 0),
    ["Water Fountain"] = Vector3.new(0, 5, 0),
    ["Campsite"] = Vector3.new(0, 5, 0),
    ["Bathroom"] = Vector3.new(0, 5, 0),
    ["Playground"] = Vector3.new(0, 5, 0),
    ["School"] = Vector3.new(0, 5, 0),
    ["Salon"] = Vector3.new(0, 5, 0),
    ["Beach"] = Vector3.new(0, 5, 0),
    ["Hospital"] = Vector3.new(0, 5, 0),
    ["Adoption Island"] = Vector3.new(0, 5, 0),
}

-- ============================================================
-- 2. INTERFAZ DE USUARIO
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdoptMeAutoPet"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
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
title.Text = "Auto Pet Needs"
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
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 100)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Detecta y completa necesidades\nautomáticamente"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

-- ============================================================
-- 3. FUNCIONES PRINCIPALES DE AUTOMATIZACIÓN
-- ============================================================
local isRunning = false
local currentTask = nil

-- Función para obtener la mascota equipada actual
local function getEquippedPet()
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return nil end
        
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Model") and (child.Name:lower():find("pet") or child:FindFirstChild("Humanoid")) then
                return child
            end
        end
        return nil
    end)
    return success and result or nil
end

-- Función para obtener la necesidad actual de la mascota
local function getCurrentNeed(pet)
    if not pet then return nil end
    
    local success, need = pcall(function()
        local needGui = pet:FindFirstChild("NeedGui") or pet:FindFirstChild("Needs")
        if needGui then
            for _, child in ipairs(needGui:GetChildren()) do
                if child:IsA("TextLabel") and child.Text ~= "" then
                    for needName, _ in pairs(PetNeeds) do
                        if child.Text:lower():find(needName:lower()) then
                            return needName
                        end
                    end
                end
            end
        end
        return nil
    end)
    
    return success and need or nil
end

-- Función para teletransportar al jugador a una ubicación
local function teleportTo(locationName)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local destination = Locations[locationName]
    if not destination then
        statusLabel.Text = "Ubicación no encontrada: " .. locationName
        return false
    end
    
    -- Teletransporte suave
    humanoidRootPart.CFrame = CFrame.new(destination)
    statusLabel.Text = "Moviendo a: " .. locationName
    return true
end

-- Función para simular interacción con la necesidad
local function completeNeed(needName)
    local needInfo = PetNeeds[needName]
    if not needInfo then return false end
    
    statusLabel.Text = "Completando: " .. needName
    
    -- Intentar teletransportarse a la ubicación
    if needInfo.Location and Locations[needInfo.Location] then
        teleportTo(needInfo.Location)
    end
    
    -- Esperar un momento para que la necesidad se complete
    task.wait(2)
    
    -- Simular interacción (presionar E o hacer clic)
    local success = pcall(function()
        local virtualInputManager = game:GetService("VirtualInputManager")
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    
    return success
end

-- Bucle principal de automatización
local function autoPetLoop()
    while isRunning do
        local success, err = pcall(function()
            local pet = getEquippedPet()
            
            if pet then
                local need = getCurrentNeed(pet)
                
                if need then
                    currentTask = need
                    statusLabel.Text = "Necesidad: " .. need
                    
                    -- Completar la necesidad
                    completeNeed(need)
                    
                    -- Esperar antes de buscar la siguiente
                    task.wait(1)
                else
                    statusLabel.Text = "Esperando necesidad..."
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
            warn("[AutoPet] Error: " .. tostring(err))
        end
        
        task.wait(0.5)
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
        statusLabel.Text = "Iniciando..."
        task.spawn(autoPetLoop)
    else
        toggleButton.Text = "INICIAR AUTO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Inactivo"
        currentTask = nil
    end
end)

print("[AutoPet] Script cargado correctamente")
print("[AutoPet] Presiona INICIAR AUTO para comenzar")
print("[AutoPet] NOTA: Este script es una plantilla. Las ubicaciones deben ajustarse")
print("[AutoPet] a las coordenadas reales del mapa actual de Adopt Me.")
