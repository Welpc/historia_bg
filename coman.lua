local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("RemovesGui") then
    CoreGui:FindFirstChild("RemovesGui"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemovesGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local categorias = {
    { nombre = "ReplicatedStorage",    ref = game:GetService("ReplicatedStorage") },
    { nombre = "Workspace",            ref = game:GetService("Workspace") },
    { nombre = "StarterGui",           ref = game:GetService("StarterGui") },
    { nombre = "StarterPack",          ref = game:GetService("StarterPack") },
    { nombre = "StarterPlayerScripts", ref = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") },
    { nombre = "Lighting",             ref = game:GetService("Lighting") },
    { nombre = "Players",              ref = game:GetService("Players") },
}

-- Botones de modo
local modoActual = "remotes" -- "remotes" o "scripts"

local btnRemotes = Instance.new("TextButton")
btnRemotes.Size = UDim2.new(0, 190, 0, 38)
btnRemotes.Position = UDim2.new(0.5, -200, 0, 14)
btnRemotes.BackgroundColor3 = Color3.fromRGB(30, 100, 220)
btnRemotes.TextColor3 = Color3.new(1, 1, 1)
btnRemotes.Text = "📡 Remotes"
btnRemotes.Font = Enum.Font.GothamBold
btnRemotes.TextSize = 14
btnRemotes.BorderSizePixel = 0
btnRemotes.ZIndex = 10
btnRemotes.Parent = screenGui

local uiC1 = Instance.new("UICorner")
uiC1.CornerRadius = UDim.new(0, 9)
uiC1.Parent = btnRemotes

local btnScripts = Instance.new("TextButton")
btnScripts.Size = UDim2.new(0, 190, 0, 38)
btnScripts.Position = UDim2.new(0.5, 10, 0, 14)
btnScripts.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
btnScripts.TextColor3 = Color3.fromRGB(180, 180, 200)
btnScripts.Text = "📜 Scripts"
btnScripts.Font = Enum.Font.GothamBold
btnScripts.TextSize = 14
btnScripts.BorderSizePixel = 0
btnScripts.ZIndex = 10
btnScripts.Parent = screenGui

local uiC2 = Instance.new("UICorner")
uiC2.CornerRadius = UDim.new(0, 9)
uiC2.Parent = btnScripts

-- Panel principal
local panel = Instance.new("ScrollingFrame")
panel.Size = UDim2.new(0, 420, 0, 440)
panel.Position = UDim2.new(0.5, -210, 0, 62)
panel.BackgroundColor3 = Color3.fromRGB(10, 14, 30)
panel.BorderSizePixel = 0
panel.ScrollBarThickness = 5
panel.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
panel.Visible = false
panel.ZIndex = 10
panel.Parent = screenGui

local uiCornerPanel = Instance.new("UICorner")
uiCornerPanel.CornerRadius = UDim.new(0, 12)
uiCornerPanel.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.Parent = panel

local paddingPanel = Instance.new("UIPadding")
paddingPanel.PaddingTop = UDim.new(0, 10)
paddingPanel.PaddingLeft = UDim.new(0, 10)
paddingPanel.PaddingRight = UDim.new(0, 14)
paddingPanel.PaddingBottom = UDim.new(0, 10)
paddingPanel.Parent = panel

-- UI helpers
local function addHeader(texto, total, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = color or Color3.fromRGB(25, 50, 120)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(210, 225, 255)
    label.Text = "📁 " .. texto .. "   ✅ Total: " .. total
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 12
    label.Parent = frame
end

local function addRemoteRow(index, nombre, tipo, ruta)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Color3.fromRGB(18, 24, 48)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame

    local lblNombre = Instance.new("TextLabel")
    lblNombre.Size = UDim2.new(1, -10, 0, 20)
    lblNombre.Position = UDim2.new(0, 8, 0, 3)
    lblNombre.BackgroundTransparency = 1
    lblNombre.TextColor3 = tipo == "RemoteEvent"
        and Color3.fromRGB(100, 255, 160)
        or Color3.fromRGB(255, 185, 70)
    lblNombre.Text = string.format("[%d] %s  (%s)", index, nombre, tipo)
    lblNombre.Font = Enum.Font.GothamBold
    lblNombre.TextSize = 12
    lblNombre.TextXAlignment = Enum.TextXAlignment.Left
    lblNombre.TextTruncate = Enum.TextTruncate.AtEnd
    lblNombre.ZIndex = 12
    lblNombre.Parent = frame

    local lblRuta = Instance.new("TextLabel")
    lblRuta.Size = UDim2.new(1, -10, 0, 16)
    lblRuta.Position = UDim2.new(0, 8, 0, 24)
    lblRuta.BackgroundTransparency = 1
    lblRuta.TextColor3 = Color3.fromRGB(140, 150, 200)
    lblRuta.Text = "📁 " .. ruta
    lblRuta.Font = Enum.Font.Gotham
    lblRuta.TextSize = 11
    lblRuta.TextXAlignment = Enum.TextXAlignment.Left
    lblRuta.TextTruncate = Enum.TextTruncate.AtEnd
    lblRuta.ZIndex = 12
    lblRuta.Parent = frame
end

local function addScriptRow(index, nombre, tipo, ruta, enabled)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Color3.fromRGB(20, 18, 40)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame

    -- Color por tipo de script
    local colorTipo = Color3.fromRGB(180, 120, 255) -- Script
    if tipo == "LocalScript" then
        colorTipo = Color3.fromRGB(90, 200, 255)
    elseif tipo == "ModuleScript" then
        colorTipo = Color3.fromRGB(255, 210, 80)
    end

    local estadoIcon = enabled and "🟢" or "🔴"

    local lblNombre = Instance.new("TextLabel")
    lblNombre.Size = UDim2.new(1, -10, 0, 20)
    lblNombre.Position = UDim2.new(0, 8, 0, 3)
    lblNombre.BackgroundTransparency = 1
    lblNombre.TextColor3 = colorTipo
    lblNombre.Text = string.format("[%d] %s  (%s) %s", index, nombre, tipo, estadoIcon)
    lblNombre.Font = Enum.Font.GothamBold
    lblNombre.TextSize = 12
    lblNombre.TextXAlignment = Enum.TextXAlignment.Left
    lblNombre.TextTruncate = Enum.TextTruncate.AtEnd
    lblNombre.ZIndex = 12
    lblNombre.Parent = frame

    local lblRuta = Instance.new("TextLabel")
    lblRuta.Size = UDim2.new(1, -10, 0, 16)
    lblRuta.Position = UDim2.new(0, 8, 0, 24)
    lblRuta.BackgroundTransparency = 1
    lblRuta.TextColor3 = Color3.fromRGB(140, 150, 200)
    lblRuta.Text = "📁 " .. ruta
    lblRuta.Font = Enum.Font.Gotham
    lblRuta.TextSize = 11
    lblRuta.TextXAlignment = Enum.TextXAlignment.Left
    lblRuta.TextTruncate = Enum.TextTruncate.AtEnd
    lblRuta.ZIndex = 12
    lblRuta.Parent = frame
end

local function addLine(texto, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.Text = texto
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 11
    label.Parent = panel
end

local function limpiarPanel()
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- Búsqueda recursiva remotes
local function buscarRemotes(parent, ruta, lista)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(lista, { nombre = obj.Name, tipo = obj.ClassName, ruta = ruta .. "." .. obj.Name })
        end
        pcall(buscarRemotes, obj, ruta .. "." .. obj.Name, lista)
    end
end

-- Búsqueda recursiva scripts
local function buscarScripts(parent, ruta, lista)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local ok, enabled = pcall(function() return obj.Enabled end)
            table.insert(lista, {
                nombre  = obj.Name,
                tipo    = obj.ClassName,
                ruta    = ruta .. "." .. obj.Name,
                enabled = ok and enabled or false
            })
        end
        pcall(buscarScripts, obj, ruta .. "." .. obj.Name, lista)
    end
end

-- Render remotes
local function renderRemotes()
    limpiarPanel()
    local totalGlobal = 0
    for _, cat in ipairs(categorias) do
        if cat.ref then
            local lista = {}
            buscarRemotes(cat.ref, cat.nombre, lista)
            totalGlobal += #lista
            addHeader(cat.nombre, #lista, Color3.fromRGB(25, 50, 120))
            if #lista == 0 then
                addLine("   ⚠️ Sin remotes", Color3.fromRGB(160, 160, 100))
            else
                for i, r in ipairs(lista) do
                    addRemoteRow(i, r.nombre, r.tipo, r.ruta)
                end
            end
        end
    end
    addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(30, 100, 220))
    addLine("  📡 TOTAL GLOBAL: " .. totalGlobal .. " remotes", Color3.fromRGB(100, 200, 255))
    panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- Render scripts
local function renderScripts()
    limpiarPanel()
    local totalGlobal = 0
    for _, cat in ipairs(categorias) do
        if cat.ref then
            local lista = {}
            buscarScripts(cat.ref, cat.nombre, lista)
            totalGlobal += #lista
            addHeader(cat.nombre, #lista, Color3.fromRGB(45, 20, 80))
            if #lista == 0 then
                addLine("   ⚠️ Sin scripts", Color3.fromRGB(160, 160, 100))
            else
                for i, s in ipairs(lista) do
                    addScriptRow(i, s.nombre, s.tipo, s.ruta, s.enabled)
                end
            end
        end
    end
    addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(120, 50, 200))
    addLine("  📜 TOTAL GLOBAL: " .. totalGlobal .. " scripts", Color3.fromRGB(200, 150, 255))
    panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- Highlight botón activo
local function actualizarBotones()
    if modoActual == "remotes" then
        btnRemotes.BackgroundColor3 = Color3.fromRGB(30, 100, 220)
        btnRemotes.TextColor3 = Color3.new(1, 1, 1)
        btnScripts.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btnScripts.TextColor3 = Color3.fromRGB(180, 180, 200)
    else
        btnScripts.BackgroundColor3 = Color3.fromRGB(100, 40, 180)
        btnScripts.TextColor3 = Color3.new(1, 1, 1)
        btnRemotes.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btnRemotes.TextColor3 = Color3.fromRGB(180, 180, 200)
    end
end

btnRemotes.MouseButton1Click:Connect(function()
    if modoActual == "remotes" and panel.Visible then
        panel.Visible = false
        return
    end
    modoActual = "remotes"
    actualizarBotones()
    renderRemotes()
    panel.Visible = true
end)

btnScripts.MouseButton1Click:Connect(function()
    if modoActual == "scripts" and panel.Visible then
        panel.Visible = false
        return
    end
    modoActual = "scripts"
    actualizarBotones()
    renderScripts()
    panel.Visible = true
end)

print("✅ RemotesGui v2 cargado")
