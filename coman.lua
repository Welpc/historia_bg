-- ============================================================
--  BuySkipLevel_Checker.lua
--  Prueba BuySkipLevel y BuyLevelSkip al mismo tiempo
--  Compara Level y cualquier stat antes y después
-- ============================================================

local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SkipCheckerUI") then
	playerGui.SkipCheckerUI:Destroy()
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
sg.Name = "SkipCheckerUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

-- Panel
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 400, 0, 560)
main.Position = UDim2.new(0.5, -200, 0.5, -280)
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
hdr.BorderSizePixel = 0 hdr.ZIndex = 6
corner(hdr, 12)
local hdrPatch = Instance.new("Frame", hdr)
hdrPatch.Size = UDim2.new(1, 0, 0.5, 0)
hdrPatch.Position = UDim2.new(0, 0, 0.5, 0)
hdrPatch.BackgroundColor3 = C.header
hdrPatch.BorderSizePixel = 0 hdrPatch.ZIndex = 6

mkLabel(hdr, {
	text = "BuySkipLevel / BuyLevelSkip — Checker",
	font = Enum.Font.GothamBold, size = 12, color = C.text,
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

-- Estado de los remotes (dos tarjetas)
local remotesFrame = Instance.new("Frame", main)
remotesFrame.Size = UDim2.new(1, -16, 0, 54)
remotesFrame.Position = UDim2.new(0, 8, 0, 48)
remotesFrame.BackgroundColor3 = C.panel
remotesFrame.BorderSizePixel = 0 remotesFrame.ZIndex = 6
corner(remotesFrame, 8)
stroke(remotesFrame, C.border, 1)

local remoteA = game.ReplicatedStorage:FindFirstChild("BuySkipLevel")
local remoteB = game.ReplicatedStorage:FindFirstChild("BuyLevelSkip")

-- Remote A
local cardA = Instance.new("Frame", remotesFrame)
cardA.Size = UDim2.new(0.5, -6, 1, -8)
cardA.Position = UDim2.new(0, 4, 0, 4)
cardA.BackgroundColor3 = C.card
cardA.BorderSizePixel = 0 cardA.ZIndex = 7
corner(cardA, 6)
mkLabel(cardA, {
	text = "BuySkipLevel",
	font = Enum.Font.GothamBold, size = 10, color = C.muted,
	sz = UDim2.new(1,0,0,18), pos = UDim2.new(0,8,0,4), z = 8,
})
mkLabel(cardA, {
	text = remoteA and "ENCONTRADO" or "NO EXISTE",
	font = Enum.Font.GothamBold, size = 11,
	color = remoteA and C.green or C.red,
	sz = UDim2.new(1,0,0,18), pos = UDim2.new(0,8,0,24), z = 8,
})

-- Remote B
local cardB = Instance.new("Frame", remotesFrame)
cardB.Size = UDim2.new(0.5, -6, 1, -8)
cardB.Position = UDim2.new(0.5, 2, 0, 4)
cardB.BackgroundColor3 = C.card
cardB.BorderSizePixel = 0 cardB.ZIndex = 7
corner(cardB, 6)
mkLabel(cardB, {
	text = "BuyLevelSkip",
	font = Enum.Font.GothamBold, size = 10, color = C.muted,
	sz = UDim2.new(1,0,0,18), pos = UDim2.new(0,8,0,4), z = 8,
})
mkLabel(cardB, {
	text = remoteB and "ENCONTRADO" or "NO EXISTE",
	font = Enum.Font.GothamBold, size = 11,
	color = remoteB and C.green or C.red,
	sz = UDim2.new(1,0,0,18), pos = UDim2.new(0,8,0,24), z = 8,
})

-- Stats en tiempo real
local statsFrame = Instance.new("Frame", main)
statsFrame.Size = UDim2.new(1, -16, 0, 42)
statsFrame.Position = UDim2.new(0, 8, 0, 110)
statsFrame.BackgroundColor3 = C.panel
statsFrame.BorderSizePixel = 0 statsFrame.ZIndex = 6
corner(statsFrame, 8)
stroke(statsFrame, C.border, 1)

mkLabel(statsFrame, {
	text = "STATS EN TIEMPO REAL",
	font = Enum.Font.GothamBold, size = 9, color = C.dim,
	sz = UDim2.new(1,-10,0,14), pos = UDim2.new(0,10,0,3), z = 7,
})
local statsValLabel = mkLabel(statsFrame, {
	text = "Cargando...",
	font = Enum.Font.GothamBold, size = 11, color = C.yellow,
	sz = UDim2.new(1,-10,0,20), pos = UDim2.new(0,10,0,20),
	trunc = Enum.TextTruncate.AtEnd, z = 7,
})

-- ScrollingFrame log
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -226)
scroll.Position = UDim2.new(0, 8, 0, 160)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(70,70,110)
scroll.CanvasSize = UDim2.new(0,0,0,0)
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

-- Botones
local btnFrame = Instance.new("Frame", main)
btnFrame.Size = UDim2.new(1, -16, 0, 58)
btnFrame.Position = UDim2.new(0, 8, 1, -64)
btnFrame.BackgroundTransparency = 1 btnFrame.ZIndex = 6

local btnA = Instance.new("TextButton", btnFrame)
btnA.Size = UDim2.new(0.48, 0, 0, 26)
btnA.Position = UDim2.new(0, 0, 0, 0)
btnA.BackgroundColor3 = Color3.fromRGB(70,100,210)
btnA.Text = "Probar BuySkipLevel"
btnA.TextColor3 = C.white btnA.TextSize = 10
btnA.Font = Enum.Font.GothamBold
btnA.BorderSizePixel = 0 btnA.ZIndex = 7
corner(btnA, 6)

local btnB = Instance.new("TextButton", btnFrame)
btnB.Size = UDim2.new(0.48, 0, 0, 26)
btnB.Position = UDim2.new(0.52, 0, 0, 0)
btnB.BackgroundColor3 = Color3.fromRGB(160,80,30)
btnB.Text = "Probar BuyLevelSkip"
btnB.TextColor3 = C.white btnB.TextSize = 10
btnB.Font = Enum.Font.GothamBold
btnB.BorderSizePixel = 0 btnB.ZIndex = 7
corner(btnB, 6)

local btnAmbos = Instance.new("TextButton", btnFrame)
btnAmbos.Size = UDim2.new(0.48, 0, 0, 26)
btnAmbos.Position = UDim2.new(0, 0, 0, 30)
btnAmbos.BackgroundColor3 = Color3.fromRGB(140,40,40)
btnAmbos.Text = "Probar AMBOS loop x5"
btnAmbos.TextColor3 = C.white btnAmbos.TextSize = 10
btnAmbos.Font = Enum.Font.GothamBold
btnAmbos.BorderSizePixel = 0 btnAmbos.ZIndex = 7
corner(btnAmbos, 6)

local btnLimpiar = Instance.new("TextButton", btnFrame)
btnLimpiar.Size = UDim2.new(0.48, 0, 0, 26)
btnLimpiar.Position = UDim2.new(0.52, 0, 0, 30)
btnLimpiar.BackgroundColor3 = Color3.fromRGB(30,30,45)
btnLimpiar.Text = "Limpiar log"
btnLimpiar.TextColor3 = C.dim btnLimpiar.TextSize = 10
btnLimpiar.Font = Enum.Font.Gotham
btnLimpiar.BorderSizePixel = 0 btnLimpiar.ZIndex = 7
corner(btnLimpiar, 6)
stroke(btnLimpiar, C.border, 1)

-- ----------------------------------------------------------------
-- Log helpers
-- ----------------------------------------------------------------
local logOrden = 0
local function addLog(texto, color, bg)
	logOrden = logOrden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 26)
	row.BackgroundColor3 = bg or C.card
	row.BorderSizePixel = 0
	row.LayoutOrder = logOrden
	row.ZIndex = 7
	corner(row, 5)
	mkLabel(row, {
		text = texto, font = Enum.Font.GothamBold,
		size = 10, color = color or C.text,
		sz = UDim2.new(1,-16,1,0),
		pos = UDim2.new(0,10,0,0),
		trunc = Enum.TextTruncate.AtEnd, z = 8,
	})
	task.wait()
	scroll.CanvasPosition = Vector2.new(0, math.huge)
end

local function addLogSep(texto)
	logOrden = logOrden + 1
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1, 0, 0, 16)
	row.BackgroundTransparency = 1
	row.LayoutOrder = logOrden row.ZIndex = 7
	mkLabel(row, {
		text = "— " .. texto .. " —",
		font = Enum.Font.GothamBold, size = 9, color = C.dim,
		sz = UDim2.new(1,0,1,0),
		xa = Enum.TextXAlignment.Center, z = 8,
	})
end

-- ----------------------------------------------------------------
-- Helpers de stats
-- ----------------------------------------------------------------
local function getStatsTexto()
	local ls = localPlayer:FindFirstChild("leaderstats")
	if not ls then return "Sin leaderstats" end
	local p = {}
	for _, s in ipairs(ls:GetChildren()) do
		table.insert(p, s.Name .. ": " .. tostring(s.Value))
	end
	return table.concat(p, "  |  ")
end

local function getStatsTabla()
	local t = {}
	local ls = localPlayer:FindFirstChild("leaderstats")
	if ls then
		for _, s in ipairs(ls:GetChildren()) do t[s.Name] = s.Value end
	end
	return t
end

local function compararStats(antes, despues)
	local huboCambio = false
	for nombre, valAntes in pairs(antes) do
		local valDespues = despues[nombre] or valAntes
		local diff = valDespues - valAntes
		if diff > 0 then
			huboCambio = true
			addLog(nombre..": "..valAntes.." → "..valDespues.." (+"..diff..")", C.red)
		elseif diff < 0 then
			huboCambio = true
			addLog(nombre..": "..valAntes.." → "..valDespues.." ("..diff..")", C.yellow)
		else
			addLog(nombre..": "..valAntes.." → sin cambio", C.green)
		end
	end
	return huboCambio
end

local function veredicto(huboCambio, nombreRemote)
	addLogSep("VEREDICTO")
	if huboCambio then
		addLog(nombreRemote .. " — VULNERABLE!", C.red, Color3.fromRGB(40,15,15))
	else
		addLog(nombreRemote .. " — SEGURO", C.green, Color3.fromRGB(15,35,20))
	end
end

-- Stats en tiempo real
task.spawn(function()
	while sg.Parent do
		statsValLabel.Text = getStatsTexto()
		task.wait(0.5)
	end
end)

-- ----------------------------------------------------------------
-- Info inicial
-- ----------------------------------------------------------------
addLogSep("INICIO")
addLog("BuySkipLevel: " .. (remoteA and "ENCONTRADO" or "NO EXISTE"),
	remoteA and C.green or C.red)
addLog("BuyLevelSkip: " .. (remoteB and "ENCONTRADO" or "NO EXISTE"),
	remoteB and C.green or C.red)
addLog("Stats: " .. getStatsTexto(), C.yellow)

-- ----------------------------------------------------------------
-- Probar BuySkipLevel
-- ----------------------------------------------------------------
btnA.MouseButton1Click:Connect(function()
	if not remoteA then addLog("BuySkipLevel no existe", C.red) return end
	local antes = getStatsTabla()
	addLogSep("PROBANDO BuySkipLevel")
	local ok, err = pcall(function() remoteA:FireServer() end)
	addLog("Disparo: " .. (ok and "OK" or "ERROR: "..tostring(err)),
		ok and C.blue or C.red)
	addLog("Esperando servidor...", C.muted)
	task.wait(1.5)
	local huboCambio = compararStats(antes, getStatsTabla())
	veredicto(huboCambio, "BuySkipLevel")
end)

-- ----------------------------------------------------------------
-- Probar BuyLevelSkip
-- ----------------------------------------------------------------
btnB.MouseButton1Click:Connect(function()
	if not remoteB then addLog("BuyLevelSkip no existe", C.red) return end
	local antes = getStatsTabla()
	addLogSep("PROBANDO BuyLevelSkip")
	local ok, err = pcall(function() remoteB:FireServer() end)
	addLog("Disparo: " .. (ok and "OK" or "ERROR: "..tostring(err)),
		ok and C.blue or C.red)
	addLog("Esperando servidor...", C.muted)
	task.wait(1.5)
	local huboCambio = compararStats(antes, getStatsTabla())
	veredicto(huboCambio, "BuyLevelSkip")
end)

-- ----------------------------------------------------------------
-- Probar AMBOS en loop x5
-- ----------------------------------------------------------------
btnAmbos.MouseButton1Click:Connect(function()
	local antes = getStatsTabla()
	addLogSep("LOOP x5 AMBOS REMOTES")

	for i = 1, 5 do
		if remoteA then
			local ok = pcall(function() remoteA:FireServer() end)
			addLog("BuySkipLevel disparo "..i.."/5 — "..(ok and "OK" or "ERROR"),
				ok and C.blue or C.red)
		end
		if remoteB then
			local ok = pcall(function() remoteB:FireServer() end)
			addLog("BuyLevelSkip disparo "..i.."/5 — "..(ok and "OK" or "ERROR"),
				ok and C.blue or C.red)
		end
		task.wait(0.3)
	end

	addLog("Esperando servidor...", C.muted)
	task.wait(1.5)

	addLogSep("RESULTADO LOOP")
	local huboCambio = compararStats(antes, getStatsTabla())
	veredicto(huboCambio, "BuySkipLevel + BuyLevelSkip")
end)

-- Limpiar
btnLimpiar.MouseButton1Click:Connect(function()
	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	logOrden = 0
	addLog("Log limpiado", C.dim)
end)

print("BuySkipLevel Checker listo.")
