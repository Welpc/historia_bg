-- ============================================================
--  BuyCandyEvent_Checker_v2.lua
--  Ejecuta el remote y muestra en pantalla qué pasó exactamente
-- ============================================================

local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("CheckerUI") then
	playerGui.CheckerUI:Destroy()
end

local C = {
	bg     = Color3.fromRGB(12, 12, 18),
	panel  = Color3.fromRGB(20, 20, 30),
	card   = Color3.fromRGB(28, 28, 40),
	header = Color3.fromRGB(16, 16, 26),
	border = Color3.fromRGB(50, 50, 75),
	text   = Color3.fromRGB(225, 225, 240),
	muted  = Color3.fromRGB(140, 140, 170),
	dim    = Color3.fromRGB(80, 80, 110),
	green  = Color3.fromRGB(60, 200, 110),
	red    = Color3.fromRGB(220, 60, 60),
	yellow = Color3.fromRGB(210, 170, 30),
	blue   = Color3.fromRGB(60, 130, 220),
	white  = Color3.fromRGB(255, 255, 255),
}

local function corner(p, r)
	Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 8)
end
local function stroke(p, col, t)
	local s = Instance.new("UIStroke", p)
	s.Color = col or C.border s.Thickness = t or 1
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

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "CheckerUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

-- Panel principal
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 400, 0, 540)
main.Position = UDim2.new(0.5, -200, 0.5, -270)
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
hdrPatch.BorderSizePixel = 0 hdrPatch.ZIndex = 6

mkLabel(hdr, {
	text = "BuyCandyEvent — Checker",
	font = Enum.Font.GothamBold, size = 13, color = C.text,
	sz = UDim2.new(1, -46, 1, 0), pos = UDim2.new(0, 12, 0, 0), z = 7,
})

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.red
closeBtn.Text = "X" closeBtn.TextColor3 = C.white
closeBtn.TextSize = 11 closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0 closeBtn.ZIndex = 8
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Stats en tiempo real (arriba)
local statsFrame = Instance.new("Frame", main)
statsFrame.Size = UDim2.new(1, -16, 0, 50)
statsFrame.Position = UDim2.new(0, 8, 0, 48)
statsFrame.BackgroundColor3 = C.panel
statsFrame.BorderSizePixel = 0
statsFrame.ZIndex = 6
corner(statsFrame, 8)
stroke(statsFrame, C.border, 1)

mkLabel(statsFrame, {
	text = "TUS STATS EN TIEMPO REAL",
	font = Enum.Font.GothamBold, size = 9, color = C.dim,
	sz = UDim2.new(1, -10, 0, 16), pos = UDim2.new(0, 10, 0, 4), z = 7,
})

local statsValLabel = mkLabel(statsFrame, {
	text = "Cargando...",
	font = Enum.Font.GothamBold, size = 12, color = C.yellow,
	sz = UDim2.new(1, -10, 0, 22), pos = UDim2.new(0, 10, 0, 22), z = 7,
	trunc = Enum.TextTruncate.AtEnd,
})

-- Log de eventos (scroll)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -172)
scroll.Position = UDim2.new(0, 8, 0, 106)
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
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local lpad = Instance.new("UIPadding", scroll)
lpad.PaddingTop = UDim.new(0,6) lpad.PaddingBottom = UDim.new(0,6)
lpad.PaddingLeft = UDim.new(0,6) lpad.PaddingRight = UDim.new(0,6)

-- Botones abajo
local btnFrame = Instance.new("Frame", main)
btnFrame.Size = UDim2.new(1, -16, 0, 56)
btnFrame.Position = UDim2.new(0, 8, 1, -62)
btnFrame.BackgroundTransparency = 1
btnFrame.ZIndex = 6

local ejecutarBtn = Instance.new("TextButton", btnFrame)
ejecutarBtn.Size = UDim2.new(0.48, 0, 0, 26)
ejecutarBtn.Position = UDim2.new(0, 0, 0, 0)
ejecutarBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 210)
ejecutarBtn.Text = "Ejecutar 1 vez"
ejecutarBtn.TextColor3 = C.white
ejecutarBtn.TextSize = 11
ejecutarBtn.Font = Enum.Font.GothamBold
ejecutarBtn.BorderSizePixel = 0
ejecutarBtn.ZIndex = 7
corner(ejecutarBtn, 6)

local loopBtn = Instance.new("TextButton", btnFrame)
loopBtn.Size = UDim2.new(0.48, 0, 0, 26)
loopBtn.Position = UDim2.new(0.52, 0, 0, 0)
loopBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
loopBtn.Text = "Loop x10"
loopBtn.TextColor3 = C.white
loopBtn.TextSize = 11
loopBtn.Font = Enum.Font.GothamBold
loopBtn.BorderSizePixel = 0
loopBtn.ZIndex = 7
corner(loopBtn, 6)

local limpiarBtn = Instance.new("TextButton", btnFrame)
limpiarBtn.Size = UDim2.new(1, 0, 0, 24)
limpiarBtn.Position = UDim2.new(0, 0, 0, 30)
limpiarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
limpiarBtn.Text = "Limpiar log"
limpiarBtn.TextColor3 = C.dim
limpiarBtn.TextSize = 10
limpiarBtn.Font = Enum.Font.Gotham
limpiarBtn.BorderSizePixel = 0
limpiarBtn.ZIndex = 7
corner(limpiarBtn, 6)
stroke(limpiarBtn, C.border, 1)

-- ----------------------------------------------------------------
-- Funciones de log
-- ----------------------------------------------------------------
local logOrden = 0

local function addLog(texto, color, bg)
	logOrden = logOrden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundColor3 = bg or C.card
	row.BorderSizePixel = 0
	row.LayoutOrder = logOrden
	row.ZIndex = 7
	corner(row, 5)

	mkLabel(row, {
		text = texto,
		font = Enum.Font.GothamBold, size = 10,
		color = color or C.text,
		sz = UDim2.new(1, -16, 1, 0),
		pos = UDim2.new(0, 10, 0, 0),
		wrap = false, trunc = Enum.TextTruncate.AtEnd,
		z = 8,
	})

	-- Auto scroll al fondo
	task.wait()
	scroll.CanvasPosition = Vector2.new(0, math.huge)
end

local function addLogSep(texto)
	logOrden = logOrden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 18)
	row.BackgroundTransparency = 1
	row.LayoutOrder = logOrden
	row.ZIndex = 7
	mkLabel(row, {
		text = "— " .. texto .. " —",
		font = Enum.Font.GothamBold, size = 9, color = C.dim,
		sz = UDim2.new(1, 0, 1, 0),
		xa = Enum.TextXAlignment.Center, z = 8,
	})
end

-- ----------------------------------------------------------------
-- Actualizar stats en tiempo real
-- ----------------------------------------------------------------
local function getStatsTexto()
	local leaderstats = localPlayer:FindFirstChild("leaderstats")
	if not leaderstats then return "Sin leaderstats" end
	local partes = {}
	for _, stat in ipairs(leaderstats:GetChildren()) do
		table.insert(partes, stat.Name .. ": " .. tostring(stat.Value))
	end
	return table.concat(partes, "   |   ")
end

local function getStatsTabla()
	local t = {}
	local leaderstats = localPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		for _, stat in ipairs(leaderstats:GetChildren()) do
			t[stat.Name] = stat.Value
		end
	end
	return t
end

-- Loop de actualización de stats
task.spawn(function()
	while sg.Parent do
		statsValLabel.Text = getStatsTexto()
		task.wait(0.5)
	end
end)

-- ----------------------------------------------------------------
-- Info inicial
-- ----------------------------------------------------------------
local remote = game.ReplicatedStorage:FindFirstChild("BuyCandyEvent")

addLogSep("INICIO")
if remote then
	addLog("Remote encontrado: " .. remote.ClassName, C.green)
	addLog("Ruta: " .. remote:GetFullName(), C.muted)
else
	addLog("BuyCandyEvent NO existe en ReplicatedStorage", C.red)
end
addLog("Stats iniciales: " .. getStatsTexto(), C.yellow)

-- ----------------------------------------------------------------
-- Ejecutar 1 vez
-- ----------------------------------------------------------------
ejecutarBtn.MouseButton1Click:Connect(function()
	if not remote then
		addLog("ERROR: Remote no encontrado", C.red)
		return
	end

	local antes = getStatsTabla()
	addLogSep("DISPARO UNICO")
	addLog("Disparando BuyCandyEvent...", C.muted)

	local ok, err = pcall(function()
		remote:FireServer()
	end)

	if not ok then
		addLog("ERROR al disparar: " .. tostring(err), C.red)
		return
	end

	addLog("Remote disparado OK", C.blue)
	addLog("Esperando respuesta del servidor...", C.muted)
	task.wait(1.5)

	-- Comparar
	local despues = getStatsTabla()
	local huboCambio = false

	for nombre, valAntes in pairs(antes) do
		local valDespues = despues[nombre] or valAntes
		local diff = valDespues - valAntes
		if diff > 0 then
			huboCambio = true
			addLog(nombre .. ": " .. valAntes .. " → " .. valDespues .. " (+" .. diff .. ")", C.red)
		elseif diff < 0 then
			huboCambio = true
			addLog(nombre .. ": " .. valAntes .. " → " .. valDespues .. " (" .. diff .. ")", C.yellow)
		else
			addLog(nombre .. ": " .. valAntes .. " → sin cambio", C.green)
		end
	end

	addLogSep("VEREDICTO")
	if huboCambio then
		addLog("VULNERABLE — El remote cambio stats!", C.red, Color3.fromRGB(40, 15, 15))
	else
		addLog("SEGURO — No hubo cambios", C.green, Color3.fromRGB(15, 35, 20))
	end
end)

-- ----------------------------------------------------------------
-- Loop x10
-- ----------------------------------------------------------------
local loopActivo = false

loopBtn.MouseButton1Click:Connect(function()
	if not remote then
		addLog("ERROR: Remote no encontrado", C.red)
		return
	end

	if loopActivo then
		loopActivo = false
		loopBtn.Text = "Loop x10"
		loopBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
		addLog("Loop detenido", C.yellow)
		return
	end

	loopActivo = true
	loopBtn.Text = "DETENER"
	loopBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 30)

	local antes = getStatsTabla()
	addLogSep("LOOP x10")
	addLog("Iniciando loop de 10 disparos...", C.muted)

	task.spawn(function()
		for i = 1, 10 do
			if not loopActivo then break end
			local ok = pcall(function() remote:FireServer() end)
			addLog("Disparo " .. i .. "/10 — " .. (ok and "OK" or "ERROR"), ok and C.blue or C.red)
			task.wait(0.3)
		end

		task.wait(1.5)
		addLogSep("RESULTADO LOOP")

		local despues = getStatsTabla()
		local huboCambio = false

		for nombre, valAntes in pairs(antes) do
			local valDespues = despues[nombre] or valAntes
			local diff = valDespues - valAntes
			if diff ~= 0 then
				huboCambio = true
				addLog(nombre .. ": " .. valAntes .. " → " .. valDespues ..
					(diff > 0 and " (+" or " (") .. diff .. ")",
					diff > 0 and C.red or C.yellow)
			else
				addLog(nombre .. ": sin cambio", C.green)
			end
		end

		addLogSep("VEREDICTO LOOP")
		if huboCambio then
			addLog("VULNERABLE — Stats cambiaron con el loop!", C.red, Color3.fromRGB(40,15,15))
		else
			addLog("SEGURO — Ningun cambio detectado", C.green, Color3.fromRGB(15,35,20))
		end

		loopActivo = false
		loopBtn.Text = "Loop x10"
		loopBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
	end)
end)

-- Limpiar log
limpiarBtn.MouseButton1Click:Connect(function()
	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	logOrden = 0
	addLog("Log limpiado", C.dim)
end)

print("BuyCandyEvent Checker v2 listo.")
