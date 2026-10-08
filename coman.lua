-- Script para Delta Executor - Adopt Me
-- Auto-camina y completa necesidades de mascotas automáticamente
-- Usa PathfindingService para navegar sin teletransportes bruscos

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. CONFIGURACIÓN DE NECESIDADES Y UBICACIONES
-- ============================================================
-- NOTA: Estas coordenadas son de ejemplo. Debes actualizarlas con las reales.
-- Puedes obtenerlas caminando en el juego y leyendo tu posición en un script de coordenadas.
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

local PetNeeds = {
    ["Potty"] = "Fire Hydrant",
    ["Hungry"] = "Pizza Shop",
    ["Thirsty"] = "Water Fountain",
    ["Sleepy"] = "Campsite",
    ["Dirty"] = "Bathroom",
    ["Play"] = "Playground",
    ["School"] = "School",
    ["Salon"] = "Salon",
    ["Sick"] = "Hospital",
    ["Beach Party"] = "Beach",
}

-- ============================================================
-- 2. INTERFAZ DE USUARIO
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdoptMeAutoWalker"
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
title.Text = "Auto Walker - Pet Needs"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Inactivo"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 11
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
infoLabel.Text = "Camina automáticamente y completa\nnecesidades de la mascota"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

-- ============================================================
-- 3. FUNCIONES DE MOVIMIENTO Y DETECCIÓN
-- ============================================================
local isRunning = false
local currentPath = nil

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

local function getCurrentNeed(pet)
    if not pet then return nil end
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
end

-- Caminar usando PathfindingService (evita obstáculos)
local function walkTo(targetPosition)
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 7,
        AgentMaxSlope = 45,
    })

    local success, err = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        statusLabel.Text = "No se pudo trazar ruta"
        return false
    end

    local waypoints = path:GetWaypoints()

    for _, waypoint in ipairs(waypoints) do
        if not isRunning then return false end
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(waypoint.Position)
        local reached = humanoid.MoveToFinished:Wait(2)
        if not reached then
            statusLabel.Text = "Movimiento interrumpido"
            return false
        end
    end

    return true
end

-- Interactuar con la necesidad (presionar E)
local function interact()
    local virtualInputManager = game:GetService("VirtualInputManager")
    virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Bucle principal
local function autoLoop()
    while isRunning do
        local success, err = pcall(function()
            local pet = getEquippedPet()
            if pet then
                local need = getCurrentNeed(pet)
                if need then
                    local locationName = PetNeeds[need]
                    local destination = Locations[locationName]

                    if destination then
                        statusLabel.Text = "Necesidad: " .. need
                        statusLabel.Text = "Caminando a: " .. locationName

                        local reached = walkTo(destination)

                        if reached and isRunning then
                            statusLabel.Text = "Completando: " .. need
                            interact()
                            task.wait(2)
                        end
                    else
                        statusLabel.Text = "Ubicación no definida: " .. tostring(locationName)
                    end
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
            warn("[AutoWalker] Error: " .. tostring(err))
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
        task.spawn(autoLoop)
    else
        toggleButton.Text = "INICIAR AUTO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Inactivo"
        -- Detener movimiento
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid:MoveTo(character.HumanoidRootPart.Position) end
        end
    end
end)

print("[AutoWalker] Script cargado. Caminará y completará necesidades.")
print("[AutoWalker] IMPORTANTE: Actualiza las coordenadas en la tabla Locations.")
print("[AutoWalker] Las coordenadas actuales son de ejemplo y no funcionarán.")
