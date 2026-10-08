-- Panel de exploración y modificación para Adopt Me (Delta Executor - Celular)
-- Permite seleccionar objetos, ver nombres, rutas, coordenadas y modificar Parts

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 1. VARIABLES GLOBALES
-- ============================================================
local selectedObject = nil
local highlight = nil
local isPanelOpen = true
local isSelecting = false
local dragPart = nil
local dragStart = nil

-- ============================================================
-- 2. INTERFAZ PRINCIPAL (PANEL)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdoptMeExplorer"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón flotante para abrir/cerrar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.Text = "🔍"
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 25)
toggleCorner.Parent = toggleBtn

-- Panel principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 280, 0, 400)
panel.Position = UDim2.new(0, 70, 0.5, -200)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Explorador Adopt Me"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = panel

-- ============================================================
-- 3. BOTONES DE ACCIÓN
-- ============================================================
local function createButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = panel
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local selectBtn = createButton("SELECCIONAR OBJETO", 40, Color3.fromRGB(0, 150, 100))
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0.9, 0, 0, 120)
infoFrame.Position = UDim2.new(0.05, 0, 0, 78)
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

local moveBtn = createButton("MOVER PART (arrastrar)", 205, Color3.fromRGB(180, 120, 0))
local deleteBtn = createButton("ELIMINAR OBJETO", 242, Color3.fromRGB(180, 0, 0))
local copyBtn = createButton("COPIAR RUTA", 279, Color3.fromRGB(100, 60, 180))

-- ============================================================
-- 4. SELECCIÓN POR TOQUE/CLIC EN PANTALLA
-- ============================================================
local function getObjectAtPosition(x, y)
    local ray = Ray.new(
        workspace.CurrentCamera:ScreenPointToRay(x, y).Origin,
        workspace.CurrentCamera:ScreenPointToRay(x, y).Direction * 500
    )
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then
        return hit
    end
    return nil
end

local function getFullPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game." .. path
end

local function selectObject(obj)
    if not obj then return end
    
    -- Eliminar highlight anterior
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
    
    selectedObject = obj
    
    -- Crear highlight visual
    highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = obj
    
    -- Actualizar información
    local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart.Position) or Vector3.new(0,0,0)
    local size = obj:IsA("BasePart") and obj.Size or Vector3.new(0,0,0)
    
    infoText.Text = string.format(
        "Nombre: %s\nClase: %s\nRuta: %s\nPosición: (%.1f, %.1f, %.1f)\nTamaño: (%.1f, %.1f, %.1f)\nPadre: %s",
        obj.Name,
        obj.ClassName,
        getFullPath(obj),
        pos.X, pos.Y, pos.Z,
        size.X, size.Y, size.Z,
        obj.Parent and obj.Parent.Name or "nil"
    )
end

-- Detectar toque en pantalla para seleccionar
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isSelecting then return end
    
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local obj = getObjectAtPosition(pos.X, pos.Y)
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
-- 5. MOVER PART ARRASTRANDO
-- ============================================================
local function startDrag()
    if not selectedObject or not selectedObject:IsA("BasePart") then
        infoText.Text = "Selecciona un BasePart para mover"
        return
    end
    dragPart = selectedObject
    infoText.Text = "Arrastra el objeto con el dedo/mouse"
end

local function updateDrag(input)
    if not dragPart then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    
    local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local targetPos = ray.Origin + ray.Direction * 50
    dragPart.CFrame = CFrame.new(targetPos)
end

local function stopDrag()
    dragPart = nil
end

moveBtn.MouseButton1Click:Connect(startDrag)
UserInputService.InputChanged:Connect(updateDrag)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        stopDrag()
    end
end)

-- ============================================================
-- 6. ELIMINAR OBJETO
-- ============================================================
deleteBtn.MouseButton1Click:Connect(function()
    if selectedObject then
        local name = selectedObject.Name
        selectedObject:Destroy()
        if highlight then highlight:Destroy() highlight = nil end
        selectedObject = nil
        infoText.Text = "Objeto eliminado: " .. name
    else
        infoText.Text = "Ningún objeto seleccionado"
    end
end)

-- ============================================================
-- 7. COPIAR RUTA AL PORTAPAPELES
-- ============================================================
copyBtn.MouseButton1Click:Connect(function()
    if selectedObject then
        local path = getFullPath(selectedObject)
        if setclipboard then
            setclipboard(path)
            infoText.Text = "Ruta copiada:\n" .. path
        else
            infoText.Text = "setclipboard no disponible"
        end
    end
end)

-- ============================================================
-- 8. CONTROL DE APERTURA DEL PANEL
-- ============================================================
toggleBtn.MouseButton1Click:Connect(function()
    isPanelOpen = not isPanelOpen
    panel.Visible = isPanelOpen
end)

-- ============================================================
-- 9. HACER EL PANEL ARRASTRABLE
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

print("[AdoptMeExplorer] Panel cargado. Usa el botón 🔍 para abrir/cerrar.")
print("[AdoptMeExplorer] Toca 'SELECCIONAR OBJETO' y luego toca cualquier parte del juego.")
