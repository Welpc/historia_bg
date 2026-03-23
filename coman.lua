-- ============================================================
--  StarterPlayerScripts_Executor_Scanner_UI_v5.lua
--  Compatible con: Roblox Studio, Delta, KRNL, Synapse, Fluxus
-- ============================================================

local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ScannerUI") then
	playerGui.ScannerUI:Destroy()
end

-- ----------------------------------------------------------------
-- Colores
-- ----------------------------------------------------------------
local C = {
	bg        = Color3.fromRGB(15, 15, 20),
	panel     = Color3.fromRGB(22, 22, 32),
	card      = Color3.fromRGB(30, 30, 44),
	header    = Color3.fromRGB(18, 18, 28),
	border    = Color3.fromRGB(55, 55, 80),
	text      = Color3.fromRGB(225, 225, 240),
	textMuted = Color3.fromRGB(140, 140, 170),
	textDim   = Color3.fromRGB(90, 90, 120),
	alta      = Color3.fromRGB(220, 65, 65),
	media     = Color3.fromRGB(210, 150, 30),
	baja      = Color3.fromRGB(55, 130, 210),
	green     = Color3.fromRGB(65, 185, 110),
	btnScan   = Color3.fromRGB(75, 105, 210),
	btnCopy   = Color3.fromRGB(50, 140, 100),
	btnClose  = Color3.fromRGB(180, 50, 50),
	white     = Color3.fromRGB(255, 255, 255),
}

local NIVEL_COLOR = { ALTA = C.alta, MEDIA = C.media, BAJA = C.baja }

-- ----------------------------------------------------------------
-- Sistema de copia universal (sin emojis para máxima compatibilidad)
-- ----------------------------------------------------------------
local function copiarTexto(texto)
	-- Limpiar emojis y caracteres especiales que rompen algunos executors
	local limpio = texto:gsub("[^\32-\126\n]", "")

	-- Método 1: setclipboard (Delta, KRNL, Synapse, Fluxus)
	if setclipboard then
		local ok, err = pcall(setclipboard, limpio)
		if ok then return true, "clipboard" end
	end

	-- Método 2: Clipboard vía TextBox oculto (Roblox Studio)
	-- Crea un TextBox invisible, mete el texto y simula Ctrl+A + Copy
	local ok2 = pcall(function()
		local tbGui = Instance.new("ScreenGui")
		tbGui.Name = "_CopyHelper"
		tbGui.ResetOnSpawn = false
		tbGui.Parent = playerGui

		local tb = Instance.new("TextBox", tbGui)
		tb.Size = UDim2.new(0, 1, 0, 1)
		tb.Position = UDim2.new(2, 0, 2, 0) -- fuera de pantalla
		tb.Text = limpio
		tb.Visible = true
		tb:CaptureFocus()

		-- Seleccionar todo el texto del TextBox
		tb.SelectionStart = 1
		tb.CursorPosition = #limpio + 1

		task.wait(0.05)
		tbGui:Destroy()
	end)
	if ok2 then return true, "textbox" end

	-- Método 3: toclipboard (Arceus X)
	if toclipboard then
		local ok3 = pcall(toclipboard, limpio)
		if ok3 then return true, "toclipboard" end
	end

	-- Método 4: writefile — guarda el reporte como .txt
	if writefile then
		local ok4 = pcall(writefile, "ScannerReporte.txt", limpio)
		if ok4 then return true, "writefile" end
	end

	-- Último recurso: imprimir en Output
	print(limpio)
	return false, "output"
end

-- ----------------------------------------------------------------
-- Helpers UI
-- ----------------------------------------------------------------
local function corner(p, r)
	local c = Instance.new("UICorner", p)
	c.CornerRadius = UDim.new(0, r or 8)
end

local function stroke(p, col, t)
	local s = Instance.new("UIStroke", p)
	s.Color = col or C.border
	s.Thickness = t or 1
end

local function label(parent, props)
	local l = Instance.new("TextLabel", parent)
	l.BackgroundTransparency = 1
	l.Font = props.font or Enum.Font.Gotham
	l.TextSize = props.size or 12
	l.TextColor3 = props.color or C.text
	l.Text = props.text or ""
	l.TextXAlignment = props.xa or Enum.TextXAlignment.Left
	l.TextYAlignment = props.ya or Enum.TextYAlignment.Center
	l.TextWrapped = props.wrap or false
	l.TextTruncate = props.trunc or Enum.TextTruncate.None
	l.Size = props.sz or UDim2.new(1, 0, 0, 20)
	l.Position = props.pos or UDim2.new(0, 0, 0, 0)
	l.ZIndex = props.z or 2
	return l
end

-- ----------------------------------------------------------------
-- ScreenGui
-- ----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScannerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ----------------------------------------------------------------
-- Botón flotante
-- ----------------------------------------------------------------
local launchBtn = Instance.new("TextButton", screenGui)
launchBtn.Size = UDim2.new(0, 136, 0, 34)
launchBtn.Position = UDim2.new(0, 14, 0.5, -17)
launchBtn.BackgroundColor3 = C.btnScan
launchBtn.Text = "  Scan Scripts"
launchBtn.TextColor3 = C.white
launchBtn.TextSize = 12
launchBtn.Font = Enum.Font.GothamBold
launchBtn.BorderSizePixel = 0
launchBtn.ZIndex = 10
corner(launchBtn, 10)
stroke(launchBtn, Color3.fromRGB(100, 130, 255), 1)

-- ----------------------------------------------------------------
-- Panel principal
-- ----------------------------------------------------------------
local main = Instance.new("Frame", screenGui)
main.Name = "Main"
main.Size = UDim2.new(0, 420, 0, 460)
main.Position = UDim2.new(0.5, -210, 0.5, -230)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.ZIndex = 5
corner(main, 12)
stroke(main, C.border, 1.5)

-- Header
local hdr = Instance.new("Frame", main)
hdr.Size = UDim2.new(1, 0, 0, 40)
hdr.BackgroundColor3 = C.header
hdr.BorderSizePixel = 0
hdr.ZIndex = 6
corner(hdr, 12)

local hdrPatch = Instance.new("Frame", hdr)
hdrPatch.Size = UDim2.new(1, 0, 0.5, 0)
hdrPatch.Position = UDim2.new(0, 0, 0.5, 0)
hdrPatch.BackgroundColor3 = C.header
hdrPatch.BorderSizePixel = 0
hdrPatch.ZIndex = 6

label(hdr, {
	text  = "PlayerScripts Scanner",
	font  = Enum.Font.GothamBold,
	size  = 13,
	color = C.text,
	sz    = UDim2.new(1, -46, 1, 0),
	pos   = UDim2.new(0, 12, 0, 0),
	z     = 7,
})

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.btnClose
closeBtn.Text = "X"
closeBtn.TextColor3 = C.white
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 8
corner(closeBtn, 6)

-- Toolbar
local toolbar = Instance.new("Frame", main)
toolbar.Size = UDim2.new(1, -16, 0, 32)
toolbar.Position = UDim2.new(0, 8, 0, 48)
toolbar.BackgroundColor3 = C.panel
toolbar.BorderSizePixel = 0
toolbar.ZIndex = 6
corner(toolbar, 7)
stroke(toolbar, C.border, 1)

local summaryLabel = label(toolbar, {
	text  = "Presiona Escanear para iniciar...",
	size  = 11,
	color = C.textMuted,
	sz    = UDim2.new(1, -190, 1, 0),
	pos   = UDim2.new(0, 10, 0, 0),
	xa    = Enum.TextXAlignment.Left,
	z     = 7,
})

local scanBtn = Instance.new("TextButton", toolbar)
scanBtn.Size = UDim2.new(0, 88, 0, 22)
scanBtn.Position = UDim2.new(1, -182, 0.5, -11)
scanBtn.BackgroundColor3 = C.btnScan
scanBtn.Text = "Escanear"
scanBtn.TextColor3 = C.white
scanBtn.TextSize = 11
scanBtn.Font = Enum.Font.GothamBold
scanBtn.BorderSizePixel = 0
scanBtn.ZIndex = 8
corner(scanBtn, 6)

local copyBtn = Instance.new("TextButton", toolbar)
copyBtn.Size = UDim2.new(0, 82, 0, 22)
copyBtn.Position = UDim2.new(1, -90, 0.5, -11)
copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
copyBtn.Text = "Copiar"
copyBtn.TextColor3 = Color3.fromRGB(100, 100, 130)
copyBtn.TextSize = 11
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.ZIndex = 8
corner(copyBtn, 6)
stroke(copyBtn, C.border, 1)

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -92)
scroll.Position = UDim2.new(0, 8, 0, 88)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 6
corner(scroll, 8)
stroke(scroll, C.border, 1)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local listPad = Instance.new("UIPadding", scroll)
listPad.PaddingTop    = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 6)
listPad.PaddingLeft   = UDim.new(0, 6)
listPad.PaddingRight  = UDim.new(0, 6)

-- Toast
local toast = Instance.new("Frame", screenGui)
toast.Size = UDim2.new(0, 280, 0, 34)
toast.Position = UDim2.new(0.5, -140, 1, -56)
toast.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
toast.BorderSizePixel = 0
toast.ZIndex = 20
toast.Visible = false
corner(toast, 8)
stroke(toast, C.border, 1)

local toastLabel = label(toast, {
	text = "",
	size = 11,
	font = Enum.Font.GothamBold,
	color = C.white,
	sz = UDim2.new(1, -10, 1, 0),
	pos = UDim2.new(0, 10, 0, 0),
	xa = Enum.TextXAlignment.Left,
	z = 21,
})

local function mostrarToast(texto, color)
	toastLabel.Text = texto
	toast.BackgroundColor3 = color or Color3.fromRGB(30, 30, 44)
	toast.Visible = true
	task.delay(2.5, function() toast.Visible = false end)
end

-- ----------------------------------------------------------------
-- Módulos de escaneo
-- ----------------------------------------------------------------
local function escanear()
	local hallazgos = {}

	local function reg(nivel, nombre, detalle, obj)
		local ruta = "N/A"
		if obj then
			local ok, r = pcall(function() return obj:GetFullName() end)
			if ok then ruta = r end
		end
		table.insert(hallazgos, { nivel=nivel, nombre=nombre, detalle=detalle, ruta=ruta })
	end

	local palabrasRem = {
		"give","admin","kick","ban","money","cash","coins","damage",
		"kill","speed","fly","tp","teleport","god","item","tool",
		"weapon","power","level","exp","reward","buy","sell","skip",
	}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			local n = v.Name:lower()
			for _, p in ipairs(palabrasRem) do
				if n:find(p) then
					reg("ALTA","Remote sospechoso: "..v.Name,"Sin validacion en servidor.",v)
					break
				end
			end
			if v:IsA("RemoteFunction") then
				reg("MEDIA","RemoteFunction: "..v.Name,"Verifica que siempre devuelva valor.",v)
			end
		end
	end

	local sps = localPlayer:FindFirstChild("PlayerScripts")
	if not sps then
		reg("MEDIA","PlayerScripts no encontrado","No hallado en LocalPlayer.",nil)
	else
		for _, d in ipairs(sps:GetDescendants()) do
			if d:IsA("LocalScript") and d.Disabled then
				reg("BAJA","LocalScript deshabilitado: "..d.Name,"Puede tener conexiones activas.",d)
			end
			if d:IsA("ModuleScript") then
				local n = d.Name:lower()
				if n:find("key") or n:find("token") or n:find("secret")
				or n:find("password") or n:find("auth") then
					reg("ALTA","ModuleScript sensible: "..d.Name,"Datos sensibles expuestos al cliente.",d)
				end
			end
			if d:IsA("BindableEvent") or d:IsA("BindableFunction") then
				reg("BAJA","Bindable expuesto: "..d.Name,"Puede invocarse externamente.",d)
			end
		end
	end

	local palabrasVal = {"key","token","secret","password","auth","admin","rank","permission","role"}
	for _, d in ipairs(game:GetDescendants()) do
		if d:IsA("StringValue") or d:IsA("IntValue") or d:IsA("NumberValue") then
			local n = d.Name:lower()
			for _, p in ipairs(palabrasVal) do
				if n:find(p) then
					reg("ALTA","Valor sensible: "..d.Name,"Accesible desde el cliente.",d)
					break
				end
			end
		end
	end

	local char = localPlayer.Character
	if not char then
		reg("ALTA","Character es nil","Scripts sin nil-check fallaran.",localPlayer)
	else
		if not char:FindFirstChildOfClass("Humanoid") then
			reg("MEDIA","Humanoid no encontrado","Scripts que dependan de el pueden fallar.",char)
		end
		if not char:FindFirstChild("HumanoidRootPart") then
			reg("MEDIA","HumanoidRootPart no encontrado","Scripts sin nil-check fallaran.",char)
		end
	end

	return hallazgos
end

-- ----------------------------------------------------------------
-- Generar texto limpio (sin emojis) para el portapapeles
-- ----------------------------------------------------------------
local function generarTexto(hallazgos)
	local lineas = {}
	table.insert(lineas, "====================================")
	table.insert(lineas, "  REPORTE - PlayerScripts Scanner")
	table.insert(lineas, "====================================")

	local cA, cM, cB = 0, 0, 0
	for _, h in ipairs(hallazgos) do
		if h.nivel=="ALTA"  then cA=cA+1 end
		if h.nivel=="MEDIA" then cM=cM+1 end
		if h.nivel=="BAJA"  then cB=cB+1 end
	end

	table.insert(lineas, string.format(
		"Total: %d  |  Alta: %d  |  Media: %d  |  Baja: %d",
		#hallazgos, cA, cM, cB))
	table.insert(lineas, "")

	for _, h in ipairs(hallazgos) do
		table.insert(lineas, string.format("[%s] %s", h.nivel, h.nombre))
		table.insert(lineas, "  Ruta   : " .. h.ruta)
		table.insert(lineas, "  Consejo: " .. h.detalle)
		table.insert(lineas, "")
	end

	table.insert(lineas, "====================================")
	return table.concat(lineas, "\n")
end

-- ----------------------------------------------------------------
-- Renderizar tarjetas
-- ----------------------------------------------------------------
local ultimosHallazgos = {}

local function renderizarHallazgos(hallazgos)
	ultimosHallazgos = hallazgos

	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end

	local orden = { ALTA=1, MEDIA=2, BAJA=3 }
	table.sort(hallazgos, function(a,b)
		return (orden[a.nivel] or 9) < (orden[b.nivel] or 9)
	end)

	local cA, cM, cB = 0, 0, 0
	for _, h in ipairs(hallazgos) do
		if h.nivel=="ALTA"  then cA=cA+1 end
		if h.nivel=="MEDIA" then cM=cM+1 end
		if h.nivel=="BAJA"  then cB=cB+1 end
	end

	if #hallazgos == 0 then
		summaryLabel.Text = "Sin vulnerabilidades detectadas."
		summaryLabel.TextColor3 = C.green
		copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		copyBtn.TextColor3 = Color3.fromRGB(100, 100, 130)
		local emptyCard = Instance.new("Frame", scroll)
		emptyCard.Size = UDim2.new(1, 0, 0, 50)
		emptyCard.BackgroundColor3 = C.card
		emptyCard.BorderSizePixel = 0
		emptyCard.LayoutOrder = 1
		emptyCard.ZIndex = 7
		corner(emptyCard, 7)
		label(emptyCard, {
			text  = "Sin vulnerabilidades encontradas",
			font  = Enum.Font.GothamBold,
			size  = 12,
			color = C.green,
			sz    = UDim2.new(1, 0, 1, 0),
			xa    = Enum.TextXAlignment.Center,
			z     = 8,
		})
		return
	end

	summaryLabel.Text = string.format(
		"Total: %d  Alta: %d  Media: %d  Baja: %d",
		#hallazgos, cA, cM, cB)
	summaryLabel.TextColor3 = C.textMuted
	copyBtn.BackgroundColor3 = C.btnCopy
	copyBtn.TextColor3 = C.white

	for i, h in ipairs(hallazgos) do
		local col = NIVEL_COLOR[h.nivel] or C.baja

		local card = Instance.new("Frame", scroll)
		card.Size = UDim2.new(1, 0, 0, 76)
		card.BackgroundColor3 = C.card
		card.BorderSizePixel = 0
		card.LayoutOrder = i
		card.ZIndex = 7
		corner(card, 7)
		stroke(card, C.border, 1)

		local barra = Instance.new("Frame", card)
		barra.Size = UDim2.new(0, 3, 1, -10)
		barra.Position = UDim2.new(0, 0, 0, 5)
		barra.BackgroundColor3 = col
		barra.BorderSizePixel = 0
		barra.ZIndex = 8
		corner(barra, 3)

		local badge = Instance.new("Frame", card)
		badge.Size = UDim2.new(0, 56, 0, 17)
		badge.Position = UDim2.new(0, 10, 0, 8)
		badge.BackgroundColor3 = col
		badge.BorderSizePixel = 0
		badge.ZIndex = 8
		corner(badge, 4)
		label(badge, {
			text  = h.nivel,
			font  = Enum.Font.GothamBold,
			size  = 9,
			color = C.white,
			sz    = UDim2.new(1, 0, 1, 0),
			xa    = Enum.TextXAlignment.Center,
			z     = 9,
		})

		label(card, {
			text  = h.nombre,
			font  = Enum.Font.GothamBold,
			size  = 11,
			color = C.text,
			sz    = UDim2.new(1, -80, 0, 17),
			pos   = UDim2.new(0, 74, 0, 7),
			trunc = Enum.TextTruncate.AtEnd,
			z     = 8,
		})

		label(card, {
			text  = "Ruta: "..h.ruta,
			size  = 9,
			color = C.textDim,
			sz    = UDim2.new(1, -16, 0, 14),
			pos   = UDim2.new(0, 10, 0, 30),
			trunc = Enum.TextTruncate.AtEnd,
			z     = 8,
		})

		label(card, {
			text  = "Consejo: "..h.detalle,
			size  = 9,
			color = C.textMuted,
			sz    = UDim2.new(1, -16, 0, 24),
			pos   = UDim2.new(0, 10, 0, 46),
			wrap  = true,
			ya    = Enum.TextYAlignment.Top,
			z     = 8,
		})
	end
end

-- ----------------------------------------------------------------
-- Eventos
-- ----------------------------------------------------------------
scanBtn.MouseButton1Click:Connect(function()
	scanBtn.Text = "Escaneando..."
	scanBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	task.wait(0.1)
	local resultados = escanear()
	renderizarHallazgos(resultados)
	scanBtn.Text = "Re-escanear"
	scanBtn.BackgroundColor3 = C.btnScan
end)

copyBtn.MouseButton1Click:Connect(function()
	if #ultimosHallazgos == 0 then return end

	local texto = generarTexto(ultimosHallazgos)
	local ok, metodo = copiarTexto(texto)

	if ok then
		if metodo == "writefile" then
			mostrarToast("Guardado en ScannerReporte.txt", Color3.fromRGB(60, 100, 160))
		elseif metodo == "textbox" then
			mostrarToast("Texto seleccionado - presiona Ctrl+C", Color3.fromRGB(80, 100, 180))
		else
			mostrarToast("Copiado al portapapeles!", Color3.fromRGB(40, 130, 70))
		end
		copyBtn.Text = "Copiado!"
		copyBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
		task.wait(1.5)
		copyBtn.Text = "Copiar"
		copyBtn.BackgroundColor3 = C.btnCopy
	else
		mostrarToast("Ver Output (F9 o Ctrl+F9)", Color3.fromRGB(160, 100, 30))
		copyBtn.Text = "Ver Output"
		task.wait(2)
		copyBtn.Text = "Copiar"
	end
end)

launchBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	launchBtn.Text = main.Visible and "X  Cerrar" or "Scan Scripts"
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	launchBtn.Text = "Scan Scripts"
end)

print("Scanner UI v5 listo.")
