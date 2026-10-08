-- Panel de edición tipo Studio para Adopt Me (Delta Executor - Celular)
-- Mueve Parts con botones de flechas (arriba, abajo, izquierda, derecha, adelante, atrás)
-- Incluye rotación y escalado

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. VARIABLES GLOBALES
-- ============================================================
local selectedObject = nil
local highlight = nil
local isSelecting = false
local moveStep = 1 -- Studs por clic (se puede cambiar)

-- ============================================================
-- 2. INTERFAZ PRINCIPAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StudioEditor"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón flotante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.Text = "🛠"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 25)
toggleCorner.Parent = toggleBtn

-- Panel principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 520)
panel.Position = UDim2.new(0, 70, 0.5, -260)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Título (arrastrable)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Editor de Objetos - Adopt Me"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = panel

-- ============================================================
-- 3. INFORMACIÓN DEL OBJETO SELECCIONADO
-- ============================================================
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0.95, 0, 0, 100)
infoFrame.Position = UDim2.new(0.025, 0, 0, 40)
infoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
infoFrame.BorderSizePixel = 0
infoFrame.Parent = panel

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, -10)
infoText.Position = UDim2.new(0, 5, 0, 5)
infoText.BackgroundTransparency = 1
infoText.Text = "Ningún objeto seleccionado"
infoText.TextColor3 = Color3.fromRGB(180, 200, 220)
infoText.Font = Enum.Font.Code
infoText.TextSize = 10
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoFrame

-- ============================================================
-- 4. FUNCIONES AUXILIARES
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
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    if result then return result.Instance end
    return nil
end

local function updateInfo()
    if not selectedObject then
        infoText.Text = "Ningún objeto seleccionado"
        return
    end
    local obj = selectedObject
    local pos = obj:IsA("BasePart") and obj.Position or Vector3.new(0,0,0)
    local rot = obj:IsA("BasePart") and obj.Orientation or Vector3.new(0,0,0)
    local size = obj:IsA("BasePart") and obj.Size or Vector3.new(0,0,0)
    
    infoText.Text = string.format(
        "Nombre: %s\nClase: %s\nRuta: %s\nPos: (%.1f, %.1f, %.1f)\nRot: (%.1f, %.1f, %.1f)\nSize: (%.1f, %.1f, %.1f)\nPadre: %s",
        obj.Name, obj.ClassName, getFullPath(obj),
        pos.X, pos.Y, pos.Z,
        rot.X, rot.Y, rot.Z,
        size.X, size.Y, size.Z,
        obj.Parent and obj.Parent.Name or "nil"
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
-- 5. BOTONES DE ACCIÓN
-- ============================================================
local function createButton(text, x, y, w, h, color, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, h)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = parent or panel
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    return btn
end

-- Botón seleccionar
local selectBtn = createButton("SELECCIONAR OBJETO", 15, 148, 290, 30, Color3.fromRGB(0, 150, 100))

-- ============================================================
-- 6. CONTROLES DE MOVIMIENTO (FLECHAS)
-- ============================================================
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0.95, 0, 0, 130)
moveFrame.Position = UDim2.new(0.025, 0, 0, 185)
moveFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
moveFrame.BorderSizePixel = 0
moveFrame.Parent = panel

local moveCorner = Instance.new("UICorner")
moveCorner.CornerRadius = UDim.new(0, 8)
moveCorner.Parent = moveFrame

local moveLabel = Instance.new("TextLabel")
moveLabel.Size = UDim2.new(1, 0, 0, 20)
moveLabel.Position = UDim2.new(0, 0, 0, 2)
moveLabel.BackgroundTransparency = 1
moveLabel.Text = "MOVER (Studs: " .. moveStep .. ")"
moveLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
moveLabel.Font = Enum.Font.SourceSansBold
moveLabel.TextSize = 12
moveLabel.Parent = moveFrame

-- Flechas de movimiento
local btnUp = createButton("↑ Arriba", 10, 25, 90, 30, Color3.fromRGB(0, 100, 200), moveFrame)
local btnDown = createButton("↓ Abajo", 110, 25, 90, 30, Color3.fromRGB(0, 100, 200), moveFrame)
local btnLeft = createButton("← Izquierda", 10, 60, 90, 30, Color3.fromRGB(0, 100, 200), moveFrame)
local btnRight = createButton("→ Derecha", 110, 60, 90, 30, Color3.fromRGB(0, 100, 200), moveFrame)
local btnForward = createButton("↗ Adelante", 10, 95, 90, 30, Color3.fromRGB(0, 150, 100), moveFrame)
local btnBack = createButton("↙ Atrás", 110, 95, 90, 30, Color3.fromRGB(0, 150, 100), moveFrame)

-- ============================================================
-- 7. CONTROLES DE ROTACIÓN
-- ============================================================
local rotFrame = Instance.new("Frame")
rotFrame.Size = UDim2.new(0.95, 0, 0, 100)
rotFrame.Position = UDim2.new(0.025, 0, 0, 320)
rotFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
rotFrame.BorderSizePixel = 0
rotFrame.Parent = panel

local rotCorner = Instance.new("UICorner")
rotCorner.CornerRadius = UDim.new(0, 8)
rotCorner.Parent = rotFrame

local rotLabel = Instance.new("TextLabel")
rotLabel.Size = UDim2.new(1, 0, 0, 20)
rotLabel.Position = UDim2.new(0, 0, 0, 2)
rotLabel.BackgroundTransparency = 1
rotLabel.Text = "ROTAR (15 grados por clic)"
rotLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
rotLabel.Font = Enum.Font.SourceSansBold
rotLabel.TextSize = 12
rotLabel.Parent = rotFrame

local btnRotX = createButton("Rotar X", 10, 25, 90, 30, Color3.fromRGB(180, 120, 0), rotFrame)
local btnRotY = createButton("Rotar Y", 110, 25, 90, 30, Color3.fromRGB(180, 120, 0), rotFrame)
local btnRotZ = createButton("Rotar Z", 10, 60, 90, 30, Color3.fromRGB(180, 120, 0), rotFrame)
local btnResetRot = createButton("Reset Rot", 110, 60, 90, 30, Color3.fromRGB(100, 60, 180), rotFrame)

-- ============================================================
-- 8. CONTROLES DE ESCALA
-- ============================================================
local sizeFrame = Instance.new("Frame")
sizeFrame.Size = UDim2.new(0.95, 0, 0, 100)
sizeFrame.Position = UDim2.new(0.025, 0, 0, 425)
sizeFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
sizeFrame.BorderSizePixel = 0
sizeFrame.Parent = panel

local sizeCorner = Instance.new("UICorner")
sizeCorner.CornerRadius = UDim.new(0, 8)
sizeCorner.Parent = sizeFrame

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, 0, 0, 20)
sizeLabel.Position = UDim2.new(0, 0, 0, 2)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "ESCALAR (0.5 studs por clic)"
sizeLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
sizeLabel.Font = Enum.Font.SourceSansBold
sizeLabel.TextSize = 12
sizeLabel.Parent = sizeFrame

local btnSizeUp = createButton("+ Grande", 10, 25, 90, 30, Color3.fromRGB(0, 150, 100), sizeFrame)
local btnSizeDown = createButton("- Pequeño", 110, 25, 90, 30, Color3.fromRGB(0, 150, 100), sizeFrame)
local btnResetSize = createButton("Reset Size", 10, 60, 90, 30, Color3.fromRGB(100, 60, 180), sizeFrame)
local btnResetAll = createButton("Reset Todo", 110, 60, 90, 30, Color3.fromRGB(180, 0, 0), sizeFrame)

-- ============================================================
-- 9. FUNCIONES DE MOVIMIENTO
-- ============================================================
local function moveSelected(direction)
    if not selectedObject or not selectedObject:IsA("BasePart") then
        infoText.Text = "Selecciona un BasePart para mover"
        return
    end
    local pos = selectedObject.Position
    if direction == "up" then pos = pos + Vector3.new(0, moveStep, 0)
    elseif direction == "down" then pos = pos - Vector3.new(0, moveStep, 0)
    elseif direction == "left" then pos = pos - Vector3.new(moveStep, 0, 0)
    elseif direction == "right" then pos = pos + Vector3.new(moveStep, 0, 0)
    elseif direction == "forward" then pos = pos + Vector3.new(0, 0, -moveStep)
    elseif direction == "back" then pos = pos + Vector3.new(0, 0, moveStep)
    end
    selectedObject.Position = pos
    updateInfo()
end

local function rotateSelected(axis)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local rot = selectedObject.Orientation
    if axis == "x" then rot = rot + Vector3.new(15, 0, 0)
    elseif axis == "y" then rot = rot + Vector3.new(0, 15, 0)
    elseif axis == "z" then rot = rot + Vector3.new(0, 0, 15)
    end
    selectedObject.Orientation = rot
    updateInfo()
end

local function scaleSelected(up)
    if not selectedObject or not selectedObject:IsA("BasePart") then return end
    local size = selectedObject.Size
    local delta = up and 0.5 or -0.5
    local newSize = Vector3.new(
        math.max(0.1, size.X + delta),
        math.max(0.1, size.Y + delta),
        math.max(0.1, size.Z + delta)
    )
    selectedObject.Size = newSize
    updateInfo()
end

-- ============================================================
-- 10. CONEXIONES DE BOTONES
-- ============================================================
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
        selectedObject.Orientation = Vector3.new(0,0,0)
        updateInfo()
    end
end)

btnSizeUp.MouseButton1Click:Connect(function() scaleSelected(true) end)
btnSizeDown.MouseButton1Click:Connect(function() scaleSelected(false) end)
btnResetSize.MouseButton1Click:Connect(function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Size = Vector3.new(1,1,1)
        updateInfo()
    end
end)
btnResetAll.MouseButton1Click:Connect(function()
    if selectedObject and selectedObject:IsA("BasePart") then
        selectedObject.Size = Vector3.new(1,1,1)
        selectedObject.Orientation = Vector3.new(0,0,0)
        selectedObject.Position = Vector3.new(0, 5, 0)
        updateInfo()
    end
end)

-- ============================================================
-- 11. SELECCIÓN POR TOQUE
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isSelecting then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local obj = getObjectAtPosition(input.Position.X, input.Position.Y)
        if obj then
            selectObject(obj)
            isSelecting = false
            selectBtn.Text = "SELECCIONAR OBJETO"
            selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end
end)

selectBtn.MouseButton1Click:Connect(function()
    isSelecting = not isSelecting
    if isSelecting then
        selectBtn.Text = "TOCA UN OBJETO..."
        selectBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    else
        selectBtn.Text = "SELECCIONAR OBJETO"
        selectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    end
end)

-- ============================================================
-- 12. PANEL ARRASTRABLE
-- ============================================================
local dragging = false
local dragStartPos = nil
local startPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        startPos = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartPos
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================================
-- 13. TOGGLE DEL PANEL
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("[StudioEditor] Panel cargado. Usa 🛠 para abrir/cerrar.")
print("[StudioEditor] Selecciona un objeto y usa las flechas para moverlo.")
print("[StudioEditor] Los cambios son solo locales en tu cliente.")
