-- Mod Menu compacto y funcional para Adopt Me (Delta Executor - Celular)
-- Con scroll para ver todas las opciones sin ocupar toda la pantalla
-- Selección de objetos por toque + funciones de edición

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================================
-- 1. VARIABLES
-- ============================================================
local selectedObject = nil
local highlight = nil
local isSelecting = false
local moveStep = 1

-- ============================================================
-- 2. INTERFAZ PRINCIPAL (COMPACTA CON SCROLL)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenuCompact"
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
panel.Size = UDim2.new(0, 190, 0, 280)
panel.Position = UDim2.new(0, 62, 0.5, -140)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Visible = false

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

-- Título (arrastrable)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.Position = UDim2.new(0, 0, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Mod Menu"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = panel

-- Info del objeto seleccionado
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0, 38)
infoLabel.Position = UDim2.new(0.025, 0, 0, 30)
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

-- ScrollFrame para las opciones
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.95, 0, 0, 185)
scroll.Position = UDim2.new(0.025, 0, 0, 72)
scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 215)
scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
scroll.Parent = panel

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scroll

-- Layout para organizar botones
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

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
        infoLabel.Text = "Sin selección"
        return
    end
    local obj = selectedObject
    local pos = obj:IsA("BasePart") and obj.Position or Vector3.new(0,0,0)
    local size = obj:IsA("BasePart") and obj.Size or Vector3.new(0,0,0)
    infoLabel.Text = string.format(
        "%s | %s\nPos: %.0f, %.0f, %.0f | Size: %.0f, %.0f, %.0f\nRuta: %s",
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

local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = scroll
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================
-- 4. BOTONES DEL MENÚ
-- ============================================================

-- Seleccionar objeto
createButton("🔍 SELECCIONAR OBJETO", Color3.fromRGB(0, 150, 100), function()
    isSelecting = true
    infoLabel.Text = "Toca un objeto en pantalla..."
end)

-- Mover
createButton("↑ SUBIR", Color3.fromRGB(0, 100, 200), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position + Vector3.new(0, moveStep, 0)
        updateInfo()
    end
end)

createButton("↓ BAJAR", Color3.fromRGB(0, 100, 200), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position - Vector3.new(0, moveStep, 0)
        updateInfo()
    end
end)

createButton("← IZQUIERDA", Color3.fromRGB(0, 100, 200), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position - Vector3.new(moveStep, 0, 0)
        updateInfo()
    end
end)

createButton("→ DERECHA", Color3.fromRGB(0, 100, 200), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position + Vector3.new(moveStep, 0, 0)
        updateInfo()
    end
end)

createButton("↗ ADELANTE", Color3.fromRGB(0, 150, 100), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position + Vector3.new(0, 0, -moveStep)
        updateInfo()
    end
end)

createButton("↙ ATRÁS", Color3.fromRGB(0, 150, 100), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Position = selectedObject.Position + Vector3.new(0, 0, moveStep)
        updateInfo()
    end
end)

-- Rotar
createButton("🔄 ROTAR X", Color3.fromRGB(180, 120, 0), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Orientation = selectedObject.Orientation + Vector3.new(15, 0, 0)
        updateInfo()
    end
end)

createButton("🔄 ROTAR Y", Color3.fromRGB(180, 120, 0), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Orientation = selectedObject.Orientation + Vector3.new(0, 15, 0)
        updateInfo()
    end
end)

createButton("🔄 ROTAR Z", Color3.fromRGB(180, 120, 0), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Orientation = selectedObject.Orientation + Vector3.new(0, 0, 15)
        updateInfo()
    end
end)

-- Escalar
createButton("➕ AGRANDAR", Color3.fromRGB(0, 150, 100), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        local s = selectedObject.Size
        selectedObject.Size = Vector3.new(s.X+0.5, s.Y+0.5, s.Z+0.5)
        updateInfo()
    end
end)

createButton("➖ REDUCIR", Color3.fromRGB(0, 150, 100), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        local s = selectedObject.Size
        selectedObject.Size = Vector3.new(math.max(0.1, s.X-0.5), math.max(0.1, s.Y-0.5), math.max(0.1, s.Z-0.5))
        updateInfo()
    end
end)

-- Resets
createButton("🔃 RESET ROTACIÓN", Color3.fromRGB(100, 60, 180), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Orientation = Vector3.new(0,0,0)
        updateInfo()
    end
end)

createButton("🔃 RESET TAMAÑO", Color3.fromRGB(100, 60, 180), function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Size = Vector3.new(1,1,1)
        updateInfo()
    end
end)

createButton("❌ ELIMINAR", Color3.fromRGB(180, 0, 0), function()
    if selectedObject then
        selectedObject:Destroy()
        if highlight then highlight:Destroy() highlight = nil end
        selectedObject = nil
        updateInfo()
    end
end)

-- Ajustar CanvasSize dinámicamente
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- 5. SELECCIÓN POR TOQUE
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

print("[ModMenuCompact] Cargado. Usa ☰ para abrir/cerrar.")
print("[ModMenuCompact] Toca SELECCIONAR y luego toca un objeto en pantalla.")
