-- Panel compacto con menú desplegable para Adopt Me (Delta Executor - Celular)
-- Tamaño reducido, opciones en acordeón

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

-- ============================================================
-- 2. INTERFAZ COMPACTA
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompactEditor"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón flotante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.Text = "🛠"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 22)
toggleCorner.Parent = toggleBtn

-- Panel principal (compacto)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 200, 0, 320)
panel.Position = UDim2.new(0, 62, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Visible = false

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

-- Título (arrastrable)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Editor Adopt Me"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = panel

-- Info del objeto (compacta)
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.95, 0, 0, 55)
infoText.Position = UDim2.new(0.025, 0, 0, 32)
infoText.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
infoText.Text = "Sin selección"
infoText.TextColor3 = Color3.fromRGB(180, 200, 220)
infoText.Font = Enum.Font.Code
infoText.TextSize = 8
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = panel

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoText

-- ============================================================
-- 3. FUNCIONES AUXILIARES
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
        infoText.Text = "Sin selección"
        return
    end
    local obj = selectedObject
    local pos = obj:IsA("BasePart") and obj.Position or Vector3.new(0,0,0)
    local size = obj:IsA("BasePart") and obj.Size or Vector3.new(0,0,0)
    infoText.Text = string.format(
        "Nombre: %s\nClase: %s\nPos: %.1f, %.1f, %.1f\nSize: %.1f, %.1f, %.1f\nRuta: %s",
        obj.Name, obj.ClassName,
        pos.X, pos.Y, pos.Z,
        size.X, size.Y, size.Z,
        getFullPath(obj)
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
-- 4. SISTEMA DE MENÚ DESPLEGABLE
-- ============================================================
local sections = {}
local currentY = 92
local sectionHeight = 28

local function createSection(name)
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(0.95, 0, 0, sectionHeight)
    header.Position = UDim2.new(0.025, 0, 0, currentY)
    header.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    header.Text = "▶ " .. name
    header.TextColor3 = Color3.fromRGB(200, 220, 255)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = panel

    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 5)
    hc.Parent = header

    local content = Instance.new("Frame")
    content.Size = UDim2.new(0.95, 0, 0, 0)
    content.Position = UDim2.new(0.025, 0, 0, currentY + sectionHeight)
    content.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = panel

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 5)
    cc.Parent = content

    local isOpen = false
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            header.Text = "▼ " .. name
            content.Size = UDim2.new(0.95, 0, 0, content:GetAttribute("FullHeight") or 80)
        else
            header.Text = "▶ " .. name
            content.Size = UDim2.new(0.95, 0, 0, 0)
        end
    end)

    currentY = currentY + sectionHeight
    table.insert(sections, {header = header, content = content, y = currentY})
    return content
end

local function finalizeSections()
    -- Reajustar posiciones si es necesario
    for _, sec in ipairs(sections) do
        sec.header.Position = UDim2.new(0.025, 0, 0, sec.y)
    end
end

local function addButton(parent, text, x, y, w, h, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, h)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    return btn
end

-- ============================================================
-- 5. SECCIÓN: SELECCIÓN
-- ============================================================
local selContent = createSection("SELECCIÓN")
local selectBtn = addButton(selContent, "Seleccionar objeto", 5, 5, 175, 25, Color3.fromRGB(0, 150, 100))
selContent:SetAttribute("FullHeight", 35)

selectBtn.MouseButton1Click:Connect(function()
    isSelecting = not isSelecting
    selectBtn.Text = isSelecting and "Toca un objeto..." or "Seleccionar objeto"
    selectBtn.BackgroundColor3 = isSelecting and Color3.fromRGB(255,100,0) or Color3.fromRGB(0,150,100)
end)

-- ============================================================
-- 6. SECCIÓN: MOVER
-- ============================================================
local moveContent = createSection("MOVER (1 stud)")
moveContent:SetAttribute("FullHeight", 100)

local btnUp = addButton(moveContent, "↑", 5, 5, 55, 25, Color3.fromRGB(0,100,200))
local btnDown = addButton(moveContent, "↓", 65, 5, 55, 25, Color3.fromRGB(0,100,200))
local btnLeft = addButton(moveContent, "←", 5, 35, 55, 25, Color3.fromRGB(0,100,200))
local btnRight = addButton(moveContent, "→", 65, 35, 55, 25, Color3.fromRGB(0,100,200))
local btnForward = addButton(moveContent, "↗", 5, 65, 55, 25, Color3.fromRGB(0,150,100))
local btnBack = addButton(moveContent, "↙", 65, 65, 55, 25, Color3.fromRGB(0,150,100))

-- ============================================================
-- 7. SECCIÓN: ROTAR
-- ============================================================
local rotContent = createSection("ROTAR (15°)")
rotContent:SetAttribute("FullHeight", 70)

local btnRotX = addButton(rotContent, "X", 5, 5, 55, 25, Color3.fromRGB(180,120,0))
local btnRotY = addButton(rotContent, "Y", 65, 5, 55, 25, Color3.fromRGB(180,120,0))
local btnRotZ = addButton(rotContent, "Z", 5, 35, 55, 25, Color3.fromRGB(180,120,0))
local btnResetRot = addButton(rotContent, "Reset", 65, 35, 55, 25, Color3.fromRGB(100,60,180))

-- ============================================================
-- 8. SECCIÓN: ESCALAR
-- ============================================================
local sizeContent = createSection("ESCALAR (0.5)")
sizeContent:SetAttribute("FullHeight", 70)

local btnSizeUp = addButton(sizeContent, "+", 5, 5, 55, 25, Color3.fromRGB(0,150,100))
local btnSizeDown = addButton(sizeContent, "-", 65, 5, 55, 25, Color3.fromRGB(0,150,100))
local btnResetSize = addButton(sizeContent, "Reset", 5, 35, 55, 25, Color3.fromRGB(100,60,180))
local btnResetAll = addButton(sizeContent, "Todo", 65, 35, 55, 25, Color3.fromRGB(180,0,0))

-- ============================================================
-- 9. LÓGICA DE MOVIMIENTO
-- ============================================================
local function moveSelected(dir)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local p = selectedObject.Position
    if dir == "up" then p = p + Vector3.new(0, moveStep, 0)
    elseif dir == "down" then p = p - Vector3.new(0, moveStep, 0)
    elseif dir == "left" then p = p - Vector3.new(moveStep, 0, 0)
    elseif dir == "right" then p = p + Vector3.new(moveStep, 0, 0)
    elseif dir == "forward" then p = p + Vector3.new(0, 0, -moveStep)
    elseif dir == "back" then p = p + Vector3.new(0, 0, moveStep)
    end
    selectedObject.Position = p
    updateInfo()
end

local function rotateSelected(axis)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local r = selectedObject.Orientation
    if axis == "x" then r = r + Vector3.new(15,0,0)
    elseif axis == "y" then r = r + Vector3.new(0,15,0)
    elseif axis == "z" then r = r + Vector3.new(0,0,15)
    end
    selectedObject.Orientation = r
    updateInfo()
end

local function scaleSelected(up)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local s = selectedObject.Size
    local d = up and 0.5 or -0.5
    selectedObject.Size = Vector3.new(math.max(0.1, s.X+d), math.max(0.1, s.Y+d), math.max(0.1, s.Z+d))
    updateInfo()
end

btnUp.MouseButton1Click:Connect(function() moveSelected("up") end)
btnDown.MouseButton1Click:Connect(function() moveSelected("down") end)
btnLeft.MouseButton1Click:Connect(function() moveSelected("left") end)
btnRight.MouseButton1Click:Connect(function() moveSelected("right") end)
btnForward.MouseButton1Click:Connect(function() moveSelected("forward") end)
btnBack.MouseButton1Click:Connect(function() moveSelected("back") end)

btnRotX.MouseButton1Click:Connect(function() rotateSelected("x") end)
btnRotY.MouseButton1Click:Connect(function() rotateSelected("y") end)
btnRotZ.MouseButton1Click:Connect(function() rotateSelected("z") end)
btnResetRot.MouseButton1Click:Connect(function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Orientation = Vector3.new(0,0,0) updateInfo()
    end
end)

btnSizeUp.MouseButton1Click:Connect(function() scaleSelected(true) end)
btnSizeDown.MouseButton1Click:Connect(function() scaleSelected(false) end)
btnResetSize.MouseButton1Click:Connect(function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Size = Vector3.new(1,1,1) updateInfo()
    end
end)
btnResetAll.MouseButton1Click:Connect(function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Size = Vector3.new(1,1,1)
        selectedObject.Orientation = Vector3.new(0,0,0)
        selectedObject.Position = Vector3.new(0,5,0)
        updateInfo()
    end
end)

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
            isSelecting = false
            selectBtn.Text = "Seleccionar objeto"
            selectBtn.BackgroundColor3 = Color3.fromRGB(0,150,100)
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

print("[CompactEditor] Panel cargado. Usa 🛠 para abrir.")
print("[CompactEditor] Secciones desplegables: Selección, Mover, Rotar, Escalar.")
