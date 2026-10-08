-- Mod Menu con pestañas + clonar + selección múltiple para Adopt Me (Delta Executor - Celular)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. VARIABLES
-- ============================================================
local selectedObjects = {}   -- lista de objetos seleccionados
local highlights = {}        -- highlights asociados
local isSelecting = false
local isMultiSelect = false
local moveStep = 1
local currentTab = "Seleccion"

-- ============================================================
-- 2. INTERFAZ PRINCIPAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenuTabsPlus"
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
panel.Size = UDim2.new(0, 220, 0, 270)
panel.Position = UDim2.new(0, 62, 0.5, -135)
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
title.Text = "Mod Menu Plus"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = panel

-- ============================================================
-- 3. BARRA DE PESTAÑAS
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

local tabNames = {"Seleccion", "Mover", "Rotar", "Escalar", "Clonar"}
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.2, -2, 1, 0)
    tab.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(180, 200, 220)
    tab.Font = Enum.Font.SourceSansBold
    tab.TextSize = 8
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
-- 4. INFO DE SELECCIÓN
-- ============================================================
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0, 34)
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
-- 5. CONTENEDOR DE CONTENIDO
-- ============================================================
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.95, 0, 0, 150)
contentFrame.Position = UDim2.new(0.025, 0, 0, 96)
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

local function clearSelection()
    for _, h in ipairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    highlights = {}
    selectedObjects = {}
    infoLabel.Text = "Sin selección"
end

local function addHighlight(obj)
    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(0, 255, 100)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.Parent = obj
    table.insert(highlights, h)
end

local function updateInfo()
    if #selectedObjects == 0 then
        infoLabel.Text = "Sin selección"
        return
    end
    local txt = "Sel: " .. #selectedObjects .. " obj\n"
    for i, obj in ipairs(selectedObjects) do
        if i > 3 then txt = txt .. "... +" .. (#selectedObjects - 3) .. " más"; break end
        txt = txt .. i .. ". " .. obj.Name .. " (" .. obj.ClassName .. ")\n"
    end
    infoLabel.Text = txt
end

-- ============================================================
-- 7. SELECCIÓN (SIMPLE Y MÚLTIPLE)
-- ============================================================
local function selectObject(obj)
    if not obj then return end
    if not isMultiSelect then
        clearSelection()
    end
    -- Evitar duplicados
    for _, o in ipairs(selectedObjects) do
        if o == obj then return end
    end
    table.insert(selectedObjects, obj)
    addHighlight(obj)
    updateInfo()
end

-- ============================================================
-- 8. ACCIONES
-- ============================================================
local function moveAll(direction)
    for _, obj in ipairs(selectedObjects) do
        if obj:IsA("BasePart") then
            local p = obj.Position
            if direction == "up" then p = p + Vector3.new(0, moveStep, 0)
            elseif direction == "down" then p = p - Vector3.new(0, moveStep, 0)
            elseif direction == "left" then p = p - Vector3.new(moveStep, 0, 0)
            elseif direction == "right" then p = p + Vector3.new(moveStep, 0, 0)
            elseif direction == "forward" then p = p + Vector3.new(0, 0, -moveStep)
            elseif direction == "back" then p = p + Vector3.new(0, 0, moveStep)
            end
            obj.Position = p
        end
    end
    updateInfo()
end

local function rotateAll(axis)
    for _, obj in ipairs(selectedObjects) do
        if obj:IsA("BasePart") then
            local r = obj.Orientation
            if axis == "x" then r = r + Vector3.new(15,0,0)
            elseif axis == "y" then r = r + Vector3.new(0,15,0)
            elseif axis == "z" then r = r + Vector3.new(0,0,15)
            end
            obj.Orientation = r
        end
    end
    updateInfo()
end

local function scaleAll(up)
    for _, obj in ipairs(selectedObjects) do
        if obj:IsA("BasePart") then
            local s = obj.Size
            local d = up and 0.5 or -0.5
            obj.Size = Vector3.new(math.max(0.1, s.X+d), math.max(0.1, s.Y+d), math.max(0.1, s.Z+d))
        end
    end
    updateInfo()
end

local function cloneAll()
    if #selectedObjects == 0 then return end
    local clones = {}
    for _, obj in ipairs(selectedObjects) do
        local clone = obj:Clone()
        clone.Parent = obj.Parent
        -- Desplazar ligeramente para no superponer
        if clone:IsA("BasePart") then
            clone.Position = clone.Position + Vector3.new(2, 0, 0)
        end
        table.insert(clones, clone)
    end
    -- Seleccionar los clones
    clearSelection()
    for _, c in ipairs(clones) do
        selectObject(c)
    end
    updateInfo()
end

-- ============================================================
-- 9. ACTUALIZAR CONTENIDO SEGÚN TAB
-- ============================================================
function updateContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local function addBtn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 27)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 9
        btn.Parent = contentFrame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
        btn.MouseButton1Click:Connect(callback)
    end

    if currentTab == "Seleccion" then
        addBtn("🔍 SELECCIONAR UNO", Color3.fromRGB(0, 150, 100), function()
            isSelecting = true
            isMultiSelect = false
            infoLabel.Text = "Toca un objeto..."
        end)
        addBtn("🔍 SELECCIONAR VARIOS", Color3.fromRGB(0, 120, 200), function()
            isSelecting = true
            isMultiSelect = true
            infoLabel.Text = "Toca varios objetos..."
        end)
        addBtn("🗑 LIMPIAR SELECCIÓN", Color3.fromRGB(100, 60, 180), function()
            clearSelection()
        end)
        addBtn("❌ ELIMINAR SELECCIONADOS", Color3.fromRGB(180, 0, 0), function()
            for _, obj in ipairs(selectedObjects) do
                if obj and obj.Parent then obj:Destroy() end
            end
            clearSelection()
        end)
        addBtn("📋 COPIAR RUTA(S)", Color3.fromRGB(100, 60, 180), function()
            if #selectedObjects > 0 and setclipboard then
                local txt = ""
                for _, obj in ipairs(selectedObjects) do
                    txt = txt .. getFullPath(obj) .. "\n"
                end
                setclipboard(txt)
                infoLabel.Text = "Ruta(s) copiada(s)"
            end
        end)
    elseif currentTab == "Mover" then
        addBtn("↑ SUBIR", Color3.fromRGB(0, 100, 200), function() moveAll("up") end)
        addBtn("↓ BAJAR", Color3.fromRGB(0, 100, 200), function() moveAll("down") end)
        addBtn("← IZQUIERDA", Color3.fromRGB(0, 100, 200), function() moveAll("left") end)
        addBtn("→ DERECHA", Color3.fromRGB(0, 100, 200), function() moveAll("right") end)
        addBtn("↗ ADELANTE", Color3.fromRGB(0, 150, 100), function() moveAll("forward") end)
        addBtn("↙ ATRÁS", Color3.fromRGB(0, 150, 100), function() moveAll("back") end)
    elseif currentTab == "Rotar" then
        addBtn("🔄 ROTAR X (+15°)", Color3.fromRGB(180, 120, 0), function() rotateAll("x") end)
        addBtn("🔄 ROTAR Y (+15°)", Color3.fromRGB(180, 120, 0), function() rotateAll("y") end)
        addBtn("🔄 ROTAR Z (+15°)", Color3.fromRGB(180, 120, 0), function() rotateAll("z") end)
        addBtn("🔃 RESET ROTACIÓN", Color3.fromRGB(100, 60, 180), function()
            for _, obj in ipairs(selectedObjects) do
                if obj:IsA("BasePart") then obj.Orientation = Vector3.new(0,0,0) end
            end
            updateInfo()
        end)
    elseif currentTab == "Escalar" then
        addBtn("➕ AGRANDAR (+0.5)", Color3.fromRGB(0, 150, 100), function() scaleAll(true) end)
        addBtn("➖ REDUCIR (-0.5)", Color3.fromRGB(0, 150, 100), function() scaleAll(false) end)
        addBtn("🔃 RESET TAMAÑO", Color3.fromRGB(100, 60, 180), function()
            for _, obj in ipairs(selectedObjects) do
                if obj:IsA("BasePart") then obj.Size = Vector3.new(1,1,1) end
            end
            updateInfo()
        end)
    elseif currentTab == "Clonar" then
        addBtn("📄 CLONAR SELECCIONADOS", Color3.fromRGB(0, 120, 200), function()
            cloneAll()
        end)
        addBtn("📄 CLONAR Y SEPARAR (+5)", Color3.fromRGB(0, 150, 100), function()
            if #selectedObjects == 0 then return end
            local clones = {}
            for _, obj in ipairs(selectedObjects) do
                local clone = obj:Clone()
                clone.Parent = obj.Parent
                if clone:IsA("BasePart") then
                    clone.Position = clone.Position + Vector3.new(5, 0, 0)
                end
                table.insert(clones, clone)
            end
            clearSelection()
            for _, c in ipairs(clones) do selectObject(c) end
            updateInfo()
        end)
        addBtn("🗑 ELIMINAR CLONES", Color3.fromRGB(180, 0, 0), function()
            -- Elimina los objetos seleccionados que sean clones (heurística: nombre con "Clone" o recién creados)
            for _, obj in ipairs(selectedObjects) do
                if obj and obj.Parent and obj.Name:find("Clone") then
                    obj:Destroy()
                end
            end
            clearSelection()
        end)
    end
end

updateContent()

-- ============================================================
-- 10. SELECCIÓN POR TOQUE
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not isSelecting then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local obj = getObjectAtPosition(input.Position.X, input.Position.Y)
        if obj then
            selectObject(obj)
            if not isMultiSelect then
                isSelecting = false
            end
        end
    end
end)

-- ============================================================
-- 11. ARRASTRAR PANEL
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
-- 12. TOGGLE
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("[ModMenuPlus] Cargado. Usa ☰ para abrir/cerrar.")
print("[ModMenuPlus] Selección múltiple activada en pestaña Selección.")
print("[ModMenuPlus] Pestaña Clonar añadida.")
