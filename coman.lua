-- ============================================================
--  BuyCandyEvent_Checker.lua
--  Muestra un frame con toda la info del remote y leaderstats
-- ============================================================

local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("CheckerUI") then
	playerGui.CheckerUI:Destroy()
end

-- ----------------------------------------------------------------
-- Colores
-- ----------------------------------------------------------------
local C = {
	bg      = Color3.fromRGB(12, 12, 18),
	panel   = Color3.fromRGB(20, 20, 30),
	card    = Color3.fromRGB(28, 28, 40),
	header  = Color3.fromRGB(16, 16, 26),
	border  = Color3.fromRGB(50, 50, 75),
	text    = Color3.fromRGB(225, 225, 240),
	muted   = Color3.fromRGB(140, 140, 170),
	dim     = Color3.fromRGB(80, 80, 110),
	green   = Color3.fromRGB(60, 200, 110),
	red     = Color3.fromRGB(220, 60, 60),
	yellow  = Color3.fromRGB(210, 170, 30),
	blue    = Color3.fromRGB(60, 130, 220),
	white   = Color3.fromRGB(255, 255, 255),
}

-- ----------------------------------------------------------------
-- Helpers
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
local function mkLabel(parent, props)
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
local sg = Instance.new("ScreenGui")
sg.Name = "CheckerUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

-- Panel
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 380, 0, 500)
main.Position = UDim2.new(0.5, -190, 0.5, -250)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
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

mkLabel(hdr, {
	text = "BuyCandyEvent Checker",
	font = Enum.Font.GothamBold, size = 13, color = C.text,
	sz = UDim2.new(1, -46, 1, 0), pos = UDim2.new(0, 12, 0, 0), z = 7,
})

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.red
closeBtn.Text = "X"
closeBtn.TextColor3 = C.white
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 8
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Scroll para los resultados
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -100)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 110)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 6
corner(scroll, 8)
stroke(scroll, C.border, 1)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", scroll)
pad.PaddingTop = UDim.new(0, 6) pad.PaddingBottom = UDim.new(0, 6)
pad.PaddingLeft = UDim.new(0, 6) pad.PaddingRight = UDim.new(0, 6)

-- Botón de testear
local testBtn = Instance.new("TextButton", main)
testBtn.Size = UDim2.new(1, -16, 0, 36)
testBtn.Position = UDim2.new(0, 8, 1, -44)
testBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 210)
testBtn.Text = "Disparar BuyCandyEvent y comparar"
testBtn.TextColor3 = C.white
testBtn.TextSize = 12
testBtn.Font = Enum.Font.GothamBold
testBtn.BorderSizePixel = 0
testBtn.ZIndex = 7
corner(testBtn, 8)

-- ----------------------------------------------------------------
-- Función para agregar una fila al scroll
-- ----------------------------------------------------------------
local orden = 0
local function addFila(icono, titulo, valor, colorVal)
	orden = orden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = C.card
	row.BorderSizePixel = 0
	row.LayoutOrder = orden
	row.ZIndex = 7
	corner(row, 6)

	mkLabel(row, {
		text = icono .. " " .. titulo,
		font = Enum.Font.Gotham, size = 10, color = C.muted,
		sz = UDim2.new(0.5, -10, 1, 0),
		pos = UDim2.new(0, 10, 0, 0), z = 8,
	})
	mkLabel(row, {
		text = tostring(valor),
		font = Enum.Font.GothamBold, size = 11,
		color = colorVal or C.text,
		sz = UDim2.new(0.5, -10, 1, 0),
		pos = UDim2.new(0.5, 0, 0, 0),
		xa = Enum.TextXAlignment.Right,
		trunc = Enum.TextTruncate.AtEnd,
		z = 8,
	})
end

local function addSeparador(texto)
	orden = orden + 1
	local sep = Instance.new("Frame", scroll)
	sep.Size = UDim2.new(1, 0, 0, 20)
	sep.BackgroundTransparency = 1
	sep.LayoutOrder = orden
	sep.ZIndex = 7
	mkLabel(sep, {
		text = texto:upper(),
		font = Enum.Font.GothamBold, size = 9, color = C.dim,
		sz = UDim2.new(1, -10, 1, 0),
		pos = UDim2.new(0, 8, 0, 0), z = 8,
	})
end

local function addResultado(texto, color)
	orden = orden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = C.card
	row.BorderSizePixel = 0
	row.LayoutOrder = orden
	row.ZIndex = 7
	corner(row, 6)
	stroke(row, color or C.border, 1.5)
	mkLabel(row, {
		text = texto,
		font = Enum.Font.GothamBold, size = 12,
		color = color or C.text,
		sz = UDim2.new(1, -16, 1, 0),
		pos = UDim2.new(0, 12, 0, 0),
		wrap = true, z = 8,
	})
end

-- ----------------------------------------------------------------
-- PASO 1: Info inicial al cargar
-- ----------------------------------------------------------------
local remote = game.ReplicatedStorage:FindFirstChild("BuyCandyEvent")

addSeparador("Estado del Remote")
if remote then
	addFila("✔", "Remote encontrado", remote.Name, C.green)
	addFila("•", "Tipo", remote.ClassName, C.blue)
	addFila("•", "Ruta", remote:GetFullName(), C.muted)
else
	addFila("✘", "BuyCandyEvent", "NO EXISTE", C.red)
end

-- Leaderstats actuales
local leaderstats = localPlayer:FindFirstChild("leaderstats")
addSeparador("Tus Stats Actuales")

local statsAntes = {}
if leaderstats then
	for _, stat in ipairs(leaderstats:GetChildren()) do
		addFila("•", stat.Name, stat.Value, C.yellow)
		statsAntes[stat.Name] = stat.Value
	end
else
	addFila("✘", "leaderstats", "No encontrado", C.red)
end

-- ----------------------------------------------------------------
-- PASO 2: Al presionar el botón, disparar y comparar
-- ----------------------------------------------------------------
testBtn.MouseButton1Click:Connect(function()
	if not remote then
		addSeparador("Error")
		addResultado("No se puede disparar: remote no existe", C.red)
		return
	end

	testBtn.Text = "Disparando..."
	testBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)

	-- Guardar valores antes
	local antes = {}
	if leaderstats then
		for _, stat in ipairs(leaderstats:GetChildren()) do
			antes[stat.Name] = stat.Value
		end
	end

	-- Disparar el remote
	local ok, err = pcall(function()
		remote:FireServer()
	end)

	if not ok then
		addSeparador("Resultado del Disparo")
		addResultado("ERROR al disparar: " .. tostring(err), C.red)
		testBtn.Text = "Reintentar"
		testBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 210)
		return
	end

	addSeparador("Resultado del Disparo")
	addFila("✔", "Remote disparado", "OK", C.green)

	-- Esperar respuesta del servidor
	task.wait(1.5)

	-- Comparar valores después
	addSeparador("Comparacion Antes vs Despues")

	local huboCambio = false

	if leaderstats then
		for _, stat in ipairs(leaderstats:GetChildren()) do
			local despues = stat.Value
			local antesVal = antes[stat.Name] or 0
			local cambio = despues - antesVal

			if cambio > 0 then
				huboCambio = true
				addFila("▲ " .. stat.Name, tostring(antesVal) .. " → " .. tostring(despues),
					"+" .. tostring(cambio), C.red)
			elseif cambio < 0 then
				huboCambio = true
				addFila("▼ " .. stat.Name, tostring(antesVal) .. " → " .. tostring(despues),
					tostring(cambio), C.yellow)
			else
				addFila("= " .. stat.Name, tostring(antesVal) .. " → " .. tostring(despues),
					"sin cambio", C.green)
			end
		end
	end

	-- Veredicto final
	addSeparador("Veredicto")
	if huboCambio then
		addResultado("VULNERABLE: El remote cambio stats sin validacion!", C.red)
	else
		addResultado("SEGURO: No se detectaron cambios. El servidor valida correctamente.", C.green)
	end

	testBtn.Text = "Volver a testear"
	testBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 210)
end)

print("BuyCandyEvent Checker listo.")
