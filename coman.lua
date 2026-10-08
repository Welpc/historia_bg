-- Mod Menu con diseño de pestañas (Tabs) para Adopt Me (Delta Executor - Celular)
-- Mismas funciones que el anterior pero organizado por categorías

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. VARIABLES
-- ============================================================
local selectedObject = nil
local highlight = nil
local isSelecting = false
local moveStep = 1
local currentTab = "Seleccion"

-- ============================================================
-- 2. INTERFAZ PRINCIPAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenuTabs"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón flotante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.Text = "☰"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 22)
toggleCorner.Parent = toggleBtn

-- Panel principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 210, 0, 260)
panel.Position = UDim2.new(0, 62, 0.5, -130)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Visible = false

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

-- Título (arrastrable)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Mod Menu - Tabs"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = panel

-- ============================================================
-- 3. BARRA DE PESTAÑAS (TABS)
-- ============================================================
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0.95, 0, 0, 26)
tabBar.Position = UDim2.new(0.025, 0, 0, 28)
tabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
tabBar.BorderSizePixel = 0
tabBar.Parent = panel

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 6)
tabCorner.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local tabNames = {"Seleccion", "Mover", "Rotar", "Escalar"}
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.25, -2, 1, 0)
    tab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(180, 200, 220)
    tab.Font = Enum.Font.SourceSansBold
    tab.TextSize = 9
    tab.Parent = tabBar
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = tab
    
    tab.MouseButton1Click:Connect(function()
        currentTab = name
        for _, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            btn.TextColor3 = Color3.fromRGB(180, 200, 220)
        end
        tab.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateContent()
    end)
    
    table.insert(tabButtons, tab)
end

-- ============================================================
-- 4. INFO DEL OBJETO
-- ============================================================
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0, 32)
infoLabel.Position = UDim2.new(0.025, 0, 0, 58)
infoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
infoLabel.Text = "Sin selección"
infoLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 8
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = panel

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoLabel

-- ============================================================
-- 5. CONTENEDOR DE CONTENIDO (CAMBIA SEGÚN TAB)
-- ============================================================
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.95, 0, 0, 145)
contentFrame.Position = UDim2.new(0.025, 0, 0, 94)
contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = panel

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 3)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

-- ============================================================
-- 6. FUNCIONES AUXILIARES
-- ============================================================
local function getFullPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game." .. path
end

local function getObjectAtPosition(x, y)
    local ray = workspace.CurrentCamera:ScreenPointToRay(x, y)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, rp)
    return result and result.Instance or nil
end

local function updateInfo()
    if not selectedObject then
        infoLabel.Text = "Sin selección"
        return
    end
    local obj = selectedObject
    local pos = obj:IsA("BasePart") and obj.Position or Vector3.new(0,0,0)
    local size = obj:IsA("BasePart") and obj.Size or Vector3.new(0,0,0)
    infoLabel.Text = string.format(
        "%s | %s | Pos: %.0f,%.0f,%.0f | Size: %.0f,%.0f,%.0f",
        obj.Name, obj.ClassName,
        pos.X, pos.Y, pos.Z,
        size.X, size.Y, size.Z
    )
end

local function selectObject(obj)
    if not obj then return end
    if highlight then highlight:Destroy() highlight = nil end
    selectedObject = obj
    highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = obj
    updateInfo()
end

-- ============================================================
-- 7. FUNCIONES DE ACCIÓN
-- ============================================================
local function move(direction)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local p = selectedObject.Position
    if direction == "up" then p = p + Vector3.new(0, moveStep, 0)
    elseif direction == "down" then p = p - Vector3.new(0, moveStep, 0)
    elseif direction == "left" then p = p - Vector3.new(moveStep, 0, 0)
    elseif direction == "right" then p = p + Vector3.new(moveStep, 0, 0)
    elseif direction == "forward" then p = p + Vector3.new(0, 0, -moveStep)
    elseif direction == "back" then p = p + Vector3.new(0, 0, moveStep)
    end
    selectedObject.Position = p
    updateInfo()
end

local function rotate(axis)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local r = selectedObject.Orientation
    if axis == "x" then r = r + Vector3.new(15, 0, 0)
    elseif axis == "y" then r = r + Vector3.new(0, 15, 0)
    elseif axis == "z" then r = r + Vector3.new(0, 0, 15)
    end
    selectedObject.Orientation = r
    updateInfo()
end

local function scale(up)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local s = selectedObject.Size
    local d = up and 0.5 or -0.5
    selectedObject.Size = Vector3.new(math.max(0.1, s.X+d), math.max(0.1, s.Y+d), math.max(0.1, s.Z+d))
    updateInfo()
end

-- ============================================================
-- 8. ACTUALIZAR CONTENIDO SEGÚN TAB
-- ============================================================
function updateContent()
    -- Limpiar contenido
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local function addBtn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 28)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 10
        btn.Parent = contentFrame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        btn.MouseButton1Click:Connect(callback)
    end
    
    if currentTab == "Seleccion" then
        addBtn("🔍 SELECCIONAR OBJETO", Color3.fromRGB(0, 150, 100), function()
            isSelecting = true
            infoLabel.Text = "Toca un objeto..."
        end)
        addBtn("❌ ELIMINAR OBJETO", Color3.fromRGB(180, 0, 0), function()
            if selectedObject then
                selectedObject:Destroy()
                if highlight then highlight:Destroy() highlight = nil end
                selectedObject = nil
                updateInfo()
            end
        end)
        addBtn("📋 COPIAR RUTA", Color3.fromRGB(100, 60, 180), function()
            if selectedObject and setclipboard then
                setclipboard(getFullPath(selectedObject))
                infoLabel.Text = "Ruta copiada"
            end
        end)
    elseif currentTab == "Mover" then
        addBtn("↑ SUBIR", Color3.fromRGB(0, 100, 200), function() move("up") end)
        addBtn("↓ BAJAR", Color3.fromRGB(0, 100, 200), function() move("down") end)
        addBtn("← IZQUIERDA", Color3.fromRGB(0, 100, 200), function() move("left") end)
        addBtn("→ DERECHA", Color3.fromRGB(0, 100, 200), function() move("right") end)
        addBtn("↗ ADELANTE", Color3.fromRGB(0, 150, 100), function() move("forward") end)
        addBtn("↙ ATRÁS", Color3.fromRGB(0, 150, 100), function() move("back") end)
    elseif currentTab == "Rotar" then
        addBtn("🔄 ROTAR X (+15°)", Color3.fromRGB(180, 120, 0), function() rotate("x") end)
        addBtn("🔄 ROTAR Y (+15°)", Color3.fromRGB(180, 120, 0), function() rotate("y") end)
        addBtn("🔄 ROTAR Z (+15°)", Color3.fromRGB(180, 120, 0), function() rotate("z") end)
        addBtn("🔃 RESET ROTACIÓN", Color3.fromRGB(100, 60, 180), function()
            if selectedObject and selectedObject:IsA("BasePart") then
                selectedObject.Orientation = Vector3.new(0,0,0)
                updateInfo()
            end
        end)
    elseif currentTab == "Escalar" then
        addBtn("➕ AGRANDAR (+0.5)", Color3.fromRGB(0, 150, 100), function() scale(true) end)
        addBtn("➖ REDUCIR (-0.5)", Color3.fromRGB(0, 150, 100), function() scale(false) end)
        addBtn("🔃 RESET TAMAÑO", Color3.fromRGB(100, 60, 180), function()
            if selectedObject and selectedObject:IsA("BasePart") then
                selectedObject.Size = Vector3.new(1,1,1)
                updateInfo()
            end
        end)
    end
end

-- Inicializar contenido
updateContent()

-- ============================================================
-- 9. SELECCIÓN POR TOQUE
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not isSelecting then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local obj = getObjectAtPosition(input.Position.X, input.Position.Y)
        if obj then
            selectObject(obj)
            isSelecting = false
        end
    end
end)

-- ============================================================
-- 10. ARRASTRAR PANEL
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
-- 11. TOGGLE
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("[ModMenuTabs] Cargado. Usa ☰ para abrir/cerrar.")
print("[ModMenuTabs] Cambia entre pestañas: Selección, Mover, Rotar, Escalar.")
