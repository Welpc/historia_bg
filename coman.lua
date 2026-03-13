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

local modoActual = "remotes"

-- ═══════════════════════════════
-- BOTONES SUPERIORES
-- ═══════════════════════════════

local function crearBoton(texto, posX, ancho, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, ancho, 0, 34)
    btn.Position = UDim2.new(0.5, posX, 0, 14)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = texto
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 10
    btn.Parent = screenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    return btn
end

local btnRemotes  = crearBoton("📡 Remotes",  -215, 120, Color3.fromRGB(30, 100, 220))
local btnScripts  = crearBoton("📜 Scripts",  -85,  120, Color3.fromRGB(40, 40, 60))
local btnBytecode = crearBoton("🔬 Bytecode",  45,  120, Color3.fromRGB(40, 40, 60))
local btnCopiar   = crearBoton("📋 Copiar",   175,  100, Color3.fromRGB(20, 100, 80))

-- ═══════════════════════════════
-- PANEL PRINCIPAL
-- ═══════════════════════════════

local panel = Instance.new("ScrollingFrame")
panel.Size = UDim2.new(0, 440, 0, 420)
panel.Position = UDim2.new(0.5, -220, 0, 58)
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

-- Toast notificación
local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0, 280, 0, 36)
toast.Position = UDim2.new(0.5, -140, 1, -60)
toast.BackgroundColor3 = Color3.fromRGB(20, 120, 80)
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Text = ""
toast.Font = Enum.Font.GothamBold
toast.TextSize = 13
toast.BorderSizePixel = 0
toast.ZIndex = 20
toast.Visible = false
toast.Parent = screenGui
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 8)
toastCorner.Parent = toast

local function mostrarToast(texto, color)
    toast.Text = texto
    toast.BackgroundColor3 = color or Color3.fromRGB(20, 120, 80)
    toast.Visible = true
    task.delay(2.5, function()
        toast.Visible = false
    end)
end

-- ═══════════════════════════════
-- UI HELPERS
-- ═══════════════════════════════

local function limpiarPanel()
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
end

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

local function addScriptRow(index, nombre, tipo, ruta, enabled, scriptRef)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = Color3.fromRGB(20, 18, 40)
    frame.BorderSizePixel = 0
    frame.ZIndex = 11
    frame.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame

    local colorTipo = Color3.fromRGB(180, 120, 255)
    if tipo == "LocalScript" then colorTipo = Color3.fromRGB(90, 200, 255)
    elseif tipo == "ModuleScript" then colorTipo = Color3.fromRGB(255, 210, 80) end

    local lblNombre = Instance.new("TextLabel")
    lblNombre.Size = UDim2.new(1, -10, 0, 20)
    lblNombre.Position = UDim2.new(0, 8, 0, 3)
    lblNombre.BackgroundTransparency = 1
    lblNombre.TextColor3 = colorTipo
    lblNombre.Text = string.format("[%d] %s  (%s) %s", index, nombre, tipo, enabled and "🟢" or "🔴")
    lblNombre.Font = Enum.Font.GothamBold
    lblNombre.TextSize = 12
    lblNombre.TextXAlignment = Enum.TextXAlignment.Left
    lblNombre.TextTruncate = Enum.TextTruncate.AtEnd
    lblNombre.ZIndex = 12
    lblNombre.Parent = frame

    local lblRuta = Instance.new("TextLabel")
    lblRuta.Size = UDim2.new(1, -100, 0, 16)
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

    local btnByte = Instance.new("TextButton")
    btnByte.Size = UDim2.new(0, 88, 0, 18)
    btnByte.Position = UDim2.new(1, -96, 0, 24)
    btnByte.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    btnByte.TextColor3 = Color3.fromRGB(200, 160, 255)
    btnByte.Text = "🔬 bytecode"
    btnByte.Font = Enum.Font.Gotham
    btnByte.TextSize = 10
    btnByte.BorderSizePixel = 0
    btnByte.ZIndex = 13
    btnByte.Parent = frame
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = btnByte

    btnByte.MouseButton1Click:Connect(function()
        limpiarPanel()
        addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(80, 40, 150))
        addLine("🔬 BYTECODE: " .. nombre, Color3.fromRGB(200, 160, 255))
        addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(80, 40, 150))

        local rawContent = ""

        local okDecompile, src = pcall(function()
            return decompile(scriptRef)
        end)

        if okDecompile and src and #src > 0 then
            addLine("✅ Decompilado correctamente:", Color3.fromRGB(100, 255, 160))
            rawContent = src
            for line in src:gmatch("[^\n]+") do
                addLine(line, Color3.fromRGB(220, 220, 220))
            end
        else
            local okByte, bytecode = pcall(function()
                return getscriptbytecode(scriptRef)
            end)
            if okByte and bytecode and #bytecode > 0 then
                addLine("⚠️ Solo bytecode disponible:", Color3.fromRGB(255, 200, 60))
                addLine("Tamaño: " .. #bytecode .. " bytes", Color3.fromRGB(160, 160, 200))
                rawContent = bytecode
                local preview = ""
                for i = 1, math.min(200, #bytecode) do
                    preview = preview .. string.format("%02X ", bytecode:byte(i))
                    if i % 16 == 0 then
                        addLine(preview, Color3.fromRGB(160, 200, 160))
                        preview = ""
                    end
                end
                if #preview > 0 then addLine(preview, Color3.fromRGB(160, 200, 160)) end
                addLine("... (truncado a 200 bytes)", Color3.fromRGB(120, 120, 160))
            else
                addLine("❌ No disponible en este executor", Color3.fromRGB(255, 100, 100))
                rawContent = ""
            end
        end

        -- Botón copiar bytecode individual
        if #rawContent > 0 then
            local btnCopyByte = Instance.new("TextButton")
            btnCopyByte.Size = UDim2.new(1, 0, 0, 30)
            btnCopyByte.BackgroundColor3 = Color3.fromRGB(20, 100, 80)
            btnCopyByte.TextColor3 = Color3.new(1, 1, 1)
            btnCopyByte.Text = "📋 Copiar contenido al portapapeles"
            btnCopyByte.Font = Enum.Font.GothamBold
            btnCopyByte.TextSize = 12
            btnCopyByte.BorderSizePixel = 0
            btnCopyByte.ZIndex = 12
            btnCopyByte.Parent = panel
            local cc = Instance.new("UICorner")
            cc.CornerRadius = UDim.new(0, 6)
            cc.Parent = btnCopyByte

            btnCopyByte.MouseButton1Click:Connect(function()
                local ok = pcall(function()
                    setclipboard(rawContent)
                end)
                if ok then
                    mostrarToast("✅ Copiado al portapapeles!", Color3.fromRGB(20, 120, 80))
                else
                    mostrarToast("❌ Delta no soporta setclipboard", Color3.fromRGB(150, 30, 30))
                end
            end)
        end

        -- Botón volver
        local btnVolver = Instance.new("TextButton")
        btnVolver.Size = UDim2.new(1, 0, 0, 30)
        btnVolver.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        btnVolver.TextColor3 = Color3.new(1, 1, 1)
        btnVolver.Text = "⬅️ Volver a Scripts"
        btnVolver.Font = Enum.Font.GothamBold
        btnVolver.TextSize = 12
        btnVolver.BorderSizePixel = 0
        btnVolver.ZIndex = 12
        btnVolver.Parent = panel
        local bvc = Instance.new("UICorner")
        bvc.CornerRadius = UDim.new(0, 6)
        bvc.Parent = btnVolver

        btnVolver.MouseButton1Click:Connect(function()
            modoActual = "scripts"
            renderScripts()
        end)

        panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
end

-- ═══════════════════════════════
-- BÚSQUEDAS
-- ═══════════════════════════════

local function buscarRemotes(parent, ruta, lista)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(lista, { nombre = obj.Name, tipo = obj.ClassName, ruta = ruta .. "." .. obj.Name })
        end
        pcall(buscarRemotes, obj, ruta .. "." .. obj.Name, lista)
    end
end

local function buscarScripts(parent, ruta, lista)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local ok, enabled = pcall(function() return obj.Enabled end)
            table.insert(lista, {
                nombre  = obj.Name,
                tipo    = obj.ClassName,
                ruta    = ruta .. "." .. obj.Name,
                enabled = ok and enabled or false,
                ref     = obj
            })
        end
        pcall(buscarScripts, obj, ruta .. "." .. obj.Name, lista)
    end
end

-- ═══════════════════════════════
-- RENDERS
-- ═══════════════════════════════

-- Cache para copiar todo
local cacheRemotes = {}
local cacheScripts = {}

function renderRemotes()
    limpiarPanel()
    cacheRemotes = {}
    local totalGlobal = 0
    for _, cat in ipairs(categorias) do
        if cat.ref then
            local lista = {}
            buscarRemotes(cat.ref, cat.nombre, lista)
            totalGlobal += #lista
            for _, r in ipairs(lista) do table.insert(cacheRemotes, r) end
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

function renderScripts()
    limpiarPanel()
    cacheScripts = {}
    local totalGlobal = 0
    for _, cat in ipairs(categorias) do
        if cat.ref then
            local lista = {}
            buscarScripts(cat.ref, cat.nombre, lista)
            totalGlobal += #lista
            for _, s in ipairs(lista) do table.insert(cacheScripts, s) end
            addHeader(cat.nombre, #lista, Color3.fromRGB(45, 20, 80))
            if #lista == 0 then
                addLine("   ⚠️ Sin scripts", Color3.fromRGB(160, 160, 100))
            else
                for i, s in ipairs(lista) do
                    addScriptRow(i, s.nombre, s.tipo, s.ruta, s.enabled, s.ref)
                end
            end
        end
    end
    addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(120, 50, 200))
    addLine("  📜 TOTAL GLOBAL: " .. totalGlobal .. " scripts", Color3.fromRGB(200, 150, 255))
    panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- ═══════════════════════════════
-- BOTÓN COPIAR TODO
-- ═══════════════════════════════

btnCopiar.MouseButton1Click:Connect(function()
    local lines = {}

    if modoActual == "remotes" then
        table.insert(lines, "=== REMOTES DEL JUEGO ===")
        table.insert(lines, "Juego: " .. game.Name)
        table.insert(lines, "PlaceId: " .. game.PlaceId)
        table.insert(lines, "Total: " .. #cacheRemotes)
        table.insert(lines, "")
        local catActual = ""
        for _, r in ipairs(cacheRemotes) do
            local cat = r.ruta:match("^([^%.]+)")
            if cat ~= catActual then
                catActual = cat
                table.insert(lines, "--- " .. cat .. " ---")
            end
            table.insert(lines, string.format("[%s] %s", r.tipo, r.ruta))
        end

    elseif modoActual == "scripts" then
        table.insert(lines, "=== SCRIPTS DEL JUEGO ===")
        table.insert(lines, "Juego: " .. game.Name)
        table.insert(lines, "PlaceId: " .. game.PlaceId)
        table.insert(lines, "Total: " .. #cacheScripts)
        table.insert(lines, "")
        local catActual = ""
        for _, s in ipairs(cacheScripts) do
            local cat = s.ruta:match("^([^%.]+)")
            if cat ~= catActual then
                catActual = cat
                table.insert(lines, "--- " .. cat .. " ---")
            end
            table.insert(lines, string.format("[%s] %s %s", s.tipo, s.ruta, s.enabled and "(ON)" or "(OFF)"))
        end
    else
        mostrarToast("⚠️ Abre Remotes o Scripts primero", Color3.fromRGB(140, 100, 20))
        return
    end

    local texto = table.concat(lines, "\n")

    if #texto == 0 then
        mostrarToast("⚠️ Nada que copiar, abre una pestaña primero", Color3.fromRGB(140, 100, 20))
        return
    end

    local ok = pcall(function()
        setclipboard(texto)
    end)

    if ok then
        mostrarToast("✅ Copiado! Pégalo en Notas o WhatsApp", Color3.fromRGB(20, 120, 80))
    else
        mostrarToast("❌ Delta no soporta portapapeles", Color3.fromRGB(150, 30, 30))
    end
end)

-- ═══════════════════════════════
-- EVENTOS BOTONES
-- ═══════════════════════════════

local function actualizarBotones()
    btnRemotes.BackgroundColor3  = modoActual == "remotes"  and Color3.fromRGB(30, 100, 220) or Color3.fromRGB(40, 40, 60)
    btnScripts.BackgroundColor3  = modoActual == "scripts"  and Color3.fromRGB(100, 40, 180) or Color3.fromRGB(40, 40, 60)
    btnBytecode.BackgroundColor3 = modoActual == "bytecode" and Color3.fromRGB(60, 20, 120)  or Color3.fromRGB(40, 40, 60)
    btnCopiar.BackgroundColor3   = Color3.fromRGB(20, 100, 80)
end

btnRemotes.MouseButton1Click:Connect(function()
    if modoActual == "remotes" and panel.Visible then panel.Visible = false return end
    modoActual = "remotes"
    actualizarBotones()
    renderRemotes()
    panel.Visible = true
end)

btnScripts.MouseButton1Click:Connect(function()
    if modoActual == "scripts" and panel.Visible then panel.Visible = false return end
    modoActual = "scripts"
    actualizarBotones()
    renderScripts()
    panel.Visible = true
end)

btnBytecode.MouseButton1Click:Connect(function()
    if modoActual == "bytecode" and panel.Visible then panel.Visible = false return end
    modoActual = "bytecode"
    actualizarBotones()
    limpiarPanel()
    addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(80, 40, 150))
    addLine("🔬 Ve a 📜 Scripts y pulsa 🔬 en", Color3.fromRGB(200, 160, 255))
    addLine("   el script que quieras inspeccionar", Color3.fromRGB(160, 140, 200))
    addLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(80, 40, 150))
    panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    panel.Visible = true
end)

print("✅ RemotesGui v4 cargado")
