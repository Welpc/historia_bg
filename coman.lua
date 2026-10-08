-- Mod Menu con pestañas + clonar + selección múltiple + deshacer + spawn de mascotas (Delta Executor - Celular)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. VARIABLES
-- ============================================================
local selectedObjects = {}
local highlights = {}
local isSelecting = false
local isMultiSelect = false
local moveStep = 1
local currentTab = "Sel"
local history = {}
local maxHistory = 20

-- ============================================================
-- 2. LISTA DE 40 MASCOTAS MÁS POPULARES Y VALIOSAS
-- ============================================================
local PETS = {
    -- S+ TIER (Las más valiosas)
    "Bat Dragon",
    "Shadow Dragon",
    "Giraffe",
    "Frost Dragon",
    "Owl",
    "Parrot",
    "Crow",
    "Evil Unicorn",
    "Arctic Reindeer",
    "Queen Bee",
    
    -- A TIER
    "Albino Monkey",
    "African Wild Dog",
    "Balloon Unicorn",
    "Blazing Lion",
    "Haetae",
    "Giant Panda",
    "Cryptid",
    "Hedgehog",
    "Dalmatian",
    "King Monkey",
    
    -- B TIER
    "Turtle",
    "Kangaroo",
    "Cow",
    "Mini Pig",
    "Goose",
    "Flamingo",
    "Elephant",
    "Crocodile",
    "Dragon",
    "Unicorn",
    
    -- C TIER / POPULARES
    "Cerberus",
    "Guardian Lion",
    "Skele-Rex",
    "Dodo",
    "T-Rex",
    "Shark",
    "Queen Bee",
    "Diamond Ladybug",
    "Golden Penguin",
    "Golden Unicorn",
}

-- ============================================================
-- 3. INTERFAZ PRINCIPAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenuSpawn"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 240, 0, 320)
panel.Position = UDim2.new(0, 62, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Visible = false

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Mod Menu + Spawn Pets"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = panel

-- ============================================================
-- 4. BARRA DE PESTAÑAS (6 pestañas)
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

local tabNames = {"Sel", "Mover", "Rotar", "Escalar", "Clonar", "Spawn"}
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.16, -2, 1, 0)
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
-- 5. INFO
-- ============================================================
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0, 30)
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
-- 6. CONTENIDO CON SCROLL
-- ============================================================
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(0.95, 0, 0, 190)
contentFrame.Position = UDim2.new(0.025, 0, 0, 92)
contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 215)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = panel

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 3)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

-- ============================================================
-- 7. FUNCIONES AUXILIARES
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
    isSelecting = false
    isMultiSelect = false
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
-- 8. HISTORIAL
-- ============================================================
local function pushHistory(obj)
    local entry = {
        object = obj,
        position = obj:IsA("BasePart") and obj.Position or nil,
        orientation = obj:IsA("BasePart") and obj.Orientation or nil,
        size = obj:IsA("BasePart") and obj.Size or nil,
        parent = obj.Parent,
        name = obj.Name,
        className = obj.ClassName,
    }
    table.insert(history, entry)
    if #history > maxHistory then
        table.remove(history, 1)
    end
end

local function undoLast()
    if #history == 0 then
        infoLabel.Text = "Nada que deshacer"
        return
    end
    local entry = table.remove(history)
    local obj = entry.object
    if obj and obj.Parent then
        if obj:IsA("BasePart") then
            if entry.position then obj.Position = entry.position end
            if entry.orientation then obj.Orientation = entry.orientation end
            if entry.size then obj.Size = entry.size end
        end
        obj.Name = entry.name
        infoLabel.Text = "Deshecho: " .. entry.name
    else
        infoLabel.Text = "Objeto ya no existe"
    end
    updateInfo()
end

-- ============================================================
-- 9. SELECCIÓN
-- ============================================================
local function selectObject(obj)
    if not obj then return end
    if not isMultiSelect then
        clearSelection()
    end
    for _, o in ipairs(selectedObjects) do
        if o == obj then return end
    end
    table.insert(selectedObjects, obj)
    addHighlight(obj)
    updateInfo()
end

-- ============================================================
-- 10. ACCIONES
-- ============================================================
local function moveAll(direction)
    for _, obj in ipairs(selectedObjects) do
        if obj:IsA("BasePart") then
            pushHistory(obj)
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
            pushHistory(obj)
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
            pushHistory(obj)
            local s = obj.Size
            local d = up and 0.5 or -0.5
            obj.Size = Vector3.new(math.max(0.1, s.X+d), math.max(0.1, s.Y+d), math.max(0.1, s.Z+d))
        end
    end
    updateInfo()
end

local function cloneAll(offset)
    if #selectedObjects == 0 then return end
    local clones = {}
    for _, obj in ipairs(selectedObjects) do
        pushHistory(obj)
        local clone = obj:Clone()
        clone.Parent = obj.Parent
        if clone:IsA("BasePart") then
            clone.Position = clone.Position + (offset or Vector3.new(2, 0, 0))
        end
        table.insert(clones, clone)
    end
    clearSelection()
    for _, c in ipairs(clones) do selectObject(c) end
    updateInfo()
end

-- ============================================================
-- 11. SPAWN DE MASCOTAS
-- ============================================================
local function spawnPet(petName)
    local character = LocalPlayer.Character
    if not character then
        infoLabel.Text = "Personaje no disponible"
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        infoLabel.Text = "RootPart no disponible"
        return
    end

    -- Intentar cargar el modelo de la mascota desde el servidor
    -- Buscar en ReplicatedStorage o en el catálogo del juego
    local success, model = pcall(function()
        -- Método 1: Buscar en ReplicatedStorage
        local rs = game:GetService("ReplicatedStorage")
        local found = rs:FindFirstChild(petName, true)
        if found then return found:Clone() end

        -- Método 2: Buscar en ServerStorage (puede no estar accesible)
        local ss = game:GetService("ServerStorage")
        local foundSS = ss:FindFirstChild(petName, true)
        if foundSS then return foundSS:Clone() end

        -- Método 3: Usar InsertService para cargar desde el catálogo (requiere asset ID)
        -- Este método requiere el ID del asset, que no tenemos para cada mascota
        return nil
    end)

    if success and model then
        -- Posicionar la mascota frente al jugador
        if model:IsA("Model") then
            model:PivotTo(root.CFrame * CFrame.new(0, 0, -5))
        elseif model:IsA("BasePart") then
            model.Position = root.Position + Vector3.new(0, 0, -5)
        end
        model.Parent = workspace
        infoLabel.Text = "Spawneado: " .. petName
        selectObject(model)
    else
        infoLabel.Text = "No se encontró: " .. petName
    end
end

-- ============================================================
-- 12. ACTUALIZAR CONTENIDO
-- ============================================================
function updateContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local function addBtn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 26)
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

    if currentTab == "Sel" then
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
        addBtn("⏹ DEJAR DE SELECCIONAR", Color3.fromRGB(80, 80, 80), function()
            isSelecting = false
            isMultiSelect = false
            infoLabel.Text = "Selección detenida"
        end)
        addBtn("↩ DESHACER SELECCIÓN", Color3.fromRGB(100, 60, 180), function()
            clearSelection()
            infoLabel.Text = "Selección deshecha"
        end)
        addBtn("🗑 ELIMINAR SELECCIONADOS", Color3.fromRGB(180, 0, 0), function()
            for _, obj in ipairs(selectedObjects) do
                if obj and obj.Parent then
                    pushHistory(obj)
                    obj:Destroy()
                end
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
                if obj:IsA("BasePart") then pushHistory(obj) obj.Orientation = Vector3.new(0,0,0) end
            end
            updateInfo()
        end)
    elseif currentTab == "Escalar" then
        addBtn("➕ AGRANDAR (+0.5)", Color3.fromRGB(0, 150, 100), function() scaleAll(true) end)
        addBtn("➖ REDUCIR (-0.5)", Color3.fromRGB(0, 150, 100), function() scaleAll(false) end)
        addBtn("🔃 RESET TAMAÑO", Color3.fromRGB(100, 60, 180), function()
            for _, obj in ipairs(selectedObjects) do
                if obj:IsA("BasePart") then pushHistory(obj) obj.Size = Vector3.new(1,1,1) end
            end
            updateInfo()
        end)
    elseif currentTab == "Clonar" then
        addBtn("📄 CLONAR (+2 studs)", Color3.fromRGB(0, 120, 200), function() cloneAll(Vector3.new(2, 0, 0)) end)
        addBtn("📄 CLONAR (+5 studs)", Color3.fromRGB(0, 150, 100), function() cloneAll(Vector3.new(5, 0, 0)) end)
        addBtn("📄 CLONAR ENCIMA", Color3.fromRGB(0, 100, 150), function() cloneAll(Vector3.new(0, 1, 0)) end)
        addBtn("🗑 ELIMINAR CLONES", Color3.fromRGB(180, 0, 0), function()
            for _, obj in ipairs(selectedObjects) do
                if obj and obj.Parent and obj.Name:find("Clone") then
                    pushHistory(obj)
                    obj:Destroy()
                end
            end
            clearSelection()
        end)
    elseif currentTab == "Spawn" then
        for _, pet in ipairs(PETS) do
            addBtn("🐾 " .. pet, Color3.fromRGB(60, 60, 90), function()
                spawnPet(pet)
            end)
        end
    end

    -- Ajustar CanvasSize
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end

updateContent()

-- ============================================================
-- 13. SELECCIÓN POR TOQUE
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
-- 14. BOTÓN GLOBAL DE DESHACER
-- ============================================================
local undoBtn = Instance.new("TextButton")
undoBtn.Size = UDim2.new(0.95, 0, 0, 24)
undoBtn.Position = UDim2.new(0.025, 0, 0, 290)
undoBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
undoBtn.Text = "↩ DESHACER ÚLTIMA ACCIÓN"
undoBtn.TextColor3 = Color3.fromRGB(255,255,255)
undoBtn.Font = Enum.Font.SourceSansBold
undoBtn.TextSize = 9
undoBtn.Parent = panel
local undoCorner = Instance.new("UICorner")
undoCorner.CornerRadius = UDim.new(0, 4)
undoCorner.Parent = undoBtn

undoBtn.MouseButton1Click:Connect(function()
    undoLast()
end)

-- ============================================================
-- 15. ARRASTRAR PANEL
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
-- 16. TOGGLE
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("[ModMenuSpawn] Cargado. Usa ☰ para abrir/cerrar.")
print("[ModMenuSpawn] Pestaña Spawn: 40 mascotas populares y valiosas.")
print("[ModMenuSpawn] NOTA: El spawn de mascotas depende de que los modelos estén en ReplicatedStorage o ServerStorage.")
print("[ModMenuSpawn] Si la mascota no aparece, el modelo no está accesible desde el cliente.")
