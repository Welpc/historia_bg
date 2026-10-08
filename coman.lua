-- Spawn visual de mascotas en Adopt Me (Delta Executor - Celular)
-- Solo modelo visual, no es mascota real. No se guarda, no se tradea, no se monta.
-- Usa IDs de modelos de Roblox. Algunos pueden no cargar si están protegidos.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local InsertService = game:GetService("InsertService")
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. LISTA DE MASCOTAS CON IDs DE MODELOS (los más populares)
-- ============================================================
-- NOTA: Estos IDs son de modelos públicos de Roblox. Algunos pueden no funcionar.
-- Si un ID no carga, el script lo dirá. Puedes reemplazarlos por IDs actualizados.
local PETS = {
    -- S+ TIER
    {name = "Bat Dragon", id = 0}, -- reemplazar con ID real
    {name = "Shadow Dragon", id = 0},
    {name = "Giraffe", id = 0},
    {name = "Frost Dragon", id = 0},
    {name = "Owl", id = 0},
    {name = "Parrot", id = 0},
    {name = "Crow", id = 0},
    {name = "Evil Unicorn", id = 0},
    {name = "Arctic Reindeer", id = 0},
    {name = "Queen Bee", id = 0},
    -- A TIER
    {name = "Albino Monkey", id = 0},
    {name = "African Wild Dog", id = 0},
    {name = "Balloon Unicorn", id = 0},
    {name = "Blazing Lion", id = 0},
    {name = "Haetae", id = 0},
    {name = "Giant Panda", id = 0},
    {name = "Cryptid", id = 0},
    {name = "Hedgehog", id = 0},
    {name = "Dalmatian", id = 0},
    {name = "King Monkey", id = 0},
    -- B TIER
    {name = "Turtle", id = 0},
    {name = "Kangaroo", id = 0},
    {name = "Cow", id = 0},
    {name = "Mini Pig", id = 0},
    {name = "Goose", id = 0},
    {name = "Flamingo", id = 0},
    {name = "Elephant", id = 0},
    {name = "Crocodile", id = 0},
    {name = "Dragon", id = 0},
    {name = "Unicorn", id = 0},
    -- C TIER
    {name = "Cerberus", id = 0},
    {name = "Guardian Lion", id = 0},
    {name = "Skele-Rex", id = 0},
    {name = "Dodo", id = 0},
    {name = "T-Rex", id = 0},
    {name = "Shark", id = 0},
    {name = "Diamond Ladybug", id = 0},
    {name = "Golden Penguin", id = 0},
    {name = "Golden Unicorn", id = 0},
    {name = "Metal Ox", id = 0},
}

-- ============================================================
-- 2. FUNCIÓN DE SPAWN VISUAL
-- ============================================================
local function spawnVisualPet(petName, petId)
    local character = LocalPlayer.Character
    if not character then
        return false, "Sin personaje"
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false, "Sin RootPart"
    end

    -- Si no hay ID, intentar buscar el modelo en ReplicatedStorage
    if petId == 0 or not petId then
        local rs = game:GetService("ReplicatedStorage")
        local found = rs:FindFirstChild(petName, true)
        if found then
            local clone = found:Clone()
            if clone:IsA("Model") then
                clone:PivotTo(root.CFrame * CFrame.new(0, 0, -5))
            elseif clone:IsA("BasePart") then
                clone.Position = root.Position + Vector3.new(0, 0, -5)
            end
            clone.Parent = workspace
            return true, "Modelo local: " .. petName
        end
        return false, "ID no configurado y modelo no encontrado"
    end

    -- Cargar desde InsertService con el ID
    local success, model = pcall(function()
        return InsertService:LoadAsset(petId)
    end)

    if success and model then
        local pet = model:GetChildren()[1]
        if pet then
            if pet:IsA("Model") then
                pet:PivotTo(root.CFrame * CFrame.new(0, 0, -5))
            elseif pet:IsA("BasePart") then
                pet.Position = root.Position + Vector3.new(0, 0, -5)
            end
            pet.Parent = workspace
            return true, "Spawneado: " .. petName
        end
    end
    return false, "No se pudo cargar: " .. petName
end

-- ============================================================
-- 3. INTERFAZ
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualPetSpawner"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.Text = "🐾"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 25)
toggleCorner.Parent = toggleBtn

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 230, 0, 340)
panel.Position = UDim2.new(0, 70, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Visible = false

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Spawn Visual de Mascotas"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = panel

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0, 26)
infoLabel.Position = UDim2.new(0.025, 0, 0, 30)
infoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
infoLabel.Text = "Selecciona una mascota"
infoLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 9
infoLabel.TextWrapped = true
infoLabel.Parent = panel

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoLabel

-- Contenedor con scroll manual
local scrollFrame = Instance.new("Frame")
scrollFrame.Size = UDim2.new(0.95, 0, 0, 245)
scrollFrame.Position = UDim2.new(0.025, 0, 0, 60)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scrollFrame.BorderSizePixel = 0
scrollFrame.ClipsDescendants = true
scrollFrame.Parent = panel

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local innerFrame = Instance.new("Frame")
innerFrame.Size = UDim2.new(1, 0, 0, 0)
innerFrame.Position = UDim2.new(0, 0, 0, 0)
innerFrame.BackgroundTransparency = 1
innerFrame.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = innerFrame

-- ============================================================
-- 4. CREAR BOTONES DE MASCOTAS
-- ============================================================
for _, pet in ipairs(PETS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.Text = pet.name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.Parent = innerFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local ok, msg = spawnVisualPet(pet.name, pet.id)
        infoLabel.Text = msg
    end)
end

innerFrame.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

-- ============================================================
-- 5. SCROLL MANUAL
-- ============================================================
local scrollDragging = false
local scrollStartY = 0
local scrollStartPos = 0

scrollFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        scrollDragging = true
        scrollStartY = input.Position.Y
        scrollStartPos = innerFrame.Position.Y.Offset
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if scrollDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position.Y - scrollStartY
        local newY = scrollStartPos + delta
        local minY = math.min(0, scrollFrame.AbsoluteSize.Y - innerFrame.AbsoluteSize.Y)
        if newY > 0 then newY = 0 end
        if newY < minY then newY = minY end
        innerFrame.Position = UDim2.new(0, 0, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        scrollDragging = false
    end
end)

-- ============================================================
-- 6. ARRASTRAR PANEL
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================================
-- 7. TOGGLE
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("[VisualPetSpawner] Cargado. Usa 🐾 para abrir.")
print("[VisualPetSpawner] Los modelos son visuales. No son mascotas reales.")
print("[VisualPetSpawner] Si un ID no funciona, edita la tabla PETS con IDs actualizados.")
