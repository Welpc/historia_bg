-- ============================================================
--  AllRemotes_Checker_v4.lua
--  Prueba TODOS los remotes del juego
--  Detecta cambios en: leaderstats, Backpack y Character
--  Las tools recibidas NO se pueden usar ni quitar
-- ============================================================

local Players          = game:GetService("Players")
local localPlayer      = Players.LocalPlayer
local playerGui        = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("AllRemotesUI") then
	playerGui.AllRemotesUI:Destroy()
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

-- ================================================================
-- SISTEMA DE PROTECCION DE TOOLS
-- - Bloquea Activated (click) para que no se consuma
-- - Restaura la tool si alguien intenta quitarla
-- ================================================================
local toolsProtegidas    = {}
local conexionesProteccion = {}
local proteccionActiva   = false

local function protegerTool(tool)
	if not tool:IsA("Tool") then return end
	if toolsProtegidas[tool.Name] then return end -- ya protegida

	-- Guardar clon
	local clon = tool:Clone()
	toolsProtegidas[tool.Name] = clon

	-- Bloquear Activated (click) — no hace nada al clickear
	local connActivated = tool.Activated:Connect(function() end)
	table.insert(conexionesProteccion, connActivated)

	-- Bloquear Unequipped para que no desaparezca al desequipar
	local connUnequip = tool.Unequipped:Connect(function()
		task.wait(0.05)
		local bp = localPlayer:FindFirstChild("Backpack")
		if bp and not bp:FindFirstChild(tool.Name) then
			local restaurada = toolsProtegidas[tool.Name]
			if restaurada then
				local nueva = restaurada:Clone()
				-- Proteger la nueva también
				local connAct2 = nueva.Activated:Connect(function() end)
				table.insert(conexionesProteccion, connAct2)
				nueva.Parent = bp
			end
		end
	end)
	table.insert(conexionesProteccion, connUnequip)
end

local function activarProteccion()
	if proteccionActiva then return end
	proteccionActiva = true

	local backpack = localPlayer:WaitForChild("Backpack")

	-- Proteger tools que ya existen
	for _, tool in ipairs(backpack:GetChildren()) do
		protegerTool(tool)
	end

	-- Proteger tools nuevas que lleguen
	local connAdd = backpack.ChildAdded:Connect(function(hijo)
		task.wait(0.05)
		protegerTool(hijo)
	end)
	table.insert(conexionesProteccion, connAdd)

	-- Si una tool desaparece del Backpack, restaurarla
	local connRemove = backpack.ChildRemoved:Connect(function(quitado)
		if not quitado:IsA("Tool") then return end
		task.wait(0.15)
		local bp = localPlayer:FindFirstChild("Backpack")
		local char = localPlayer.Character
		local enBp   = bp   and bp:FindFirstChild(quitado.Name)
		local enChar = char and char:FindFirstChild(quitado.Name)
		if not enBp and not enChar then
			local restaurada = toolsProtegidas[quitado.Name]
			if restaurada then
				local nueva = restaurada:Clone()
				local connAct = nueva.Activated:Connect(function() end)
				table.insert(conexionesProteccion, connAct)
				nueva.Parent = bp
			end
		end
	end)
	table.insert(conexionesProteccion, connRemove)
end

local function desactivarProteccion()
	proteccionActiva = false
	for _, conn in ipairs(conexionesProteccion) do
		pcall(function() conn:Disconnect() end)
	end
	conexionesProteccion = {}
	toolsProtegidas = {}
end

-- ================================================================
-- ScreenGui
-- ================================================================
local sg = Instance.new("ScreenGui")
sg.Name = "AllRemotesUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

-- Panel
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 440, 0, 580)
main.Position = UDim2.new(0.5, -220, 0.5, -290)
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
	text = "All Remotes Checker v4",
	font = Enum.Font.GothamBold, size = 13, color = C.text,
	sz = UDim2.new(1,-46,1,0), pos = UDim2.new(0,12,0,0), z = 7,
})

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.Position = UDim2.new(1,-34,0.5,-13)
closeBtn.BackgroundColor3 = C.red
closeBtn.Text = "X" closeBtn.TextColor3 = C.white
closeBtn.TextSize = 11 closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0 closeBtn.ZIndex = 8
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function()
	desactivarProteccion()
	sg:Destroy()
end)

-- Stats en tiempo real
local statsFrame = Instance.new("Frame", main)
statsFrame.Size = UDim2.new(1,-16,0,52)
statsFrame.Position = UDim2.new(0,8,0,48)
statsFrame.BackgroundColor3 = C.panel
statsFrame.BorderSizePixel = 0 statsFrame.ZIndex = 6
corner(statsFrame, 8)
stroke(statsFrame, C.border, 1)

mkLabel(statsFrame, {
	text = "LEADERSTATS",
	font = Enum.Font.GothamBold, size = 9, color = C.dim,
	sz = UDim2.new(1,-10,0,14), pos = UDim2.new(0,10,0,2), z = 7,
})
local statsValLabel = mkLabel(statsFrame, {
	text = "Cargando...",
	font = Enum.Font.GothamBold, size = 11, color = C.yellow,
	sz = UDim2.new(1,-10,0,16), pos = UDim2.new(0,10,0,16),
	trunc = Enum.TextTruncate.AtEnd, z = 7,
})
mkLabel(statsFrame, {
	text = "BACKPACK",
	font = Enum.Font.GothamBold, size = 9, color = C.dim,
	sz = UDim2.new(0.35,-10,0,14), pos = UDim2.new(0,10,0,34), z = 7,
})
local backpackLabel = mkLabel(statsFrame, {
	text = "...",
	font = Enum.Font.GothamBold, size = 10, color = C.blue,
	sz = UDim2.new(0.55,0,0,14), pos = UDim2.new(0.33,0,0,34),
	trunc = Enum.TextTruncate.AtEnd, z = 7,
})

-- Indicador protección
local proteccionBadge = Instance.new("Frame", statsFrame)
proteccionBadge.Size = UDim2.new(0,110,0,14)
proteccionBadge.Position = UDim2.new(1,-118,0,35)
proteccionBadge.BackgroundColor3 = Color3.fromRGB(35,35,52)
proteccionBadge.BorderSizePixel = 0 proteccionBadge.ZIndex = 8
corner(proteccionBadge, 4)
local proteccionLabel = mkLabel(proteccionBadge, {
	text = "Proteccion: OFF",
	font = Enum.Font.GothamBold, size = 8, color = C.dim,
	sz = UDim2.new(1,0,1,0),
	xa = Enum.TextXAlignment.Center, z = 9,
})

-- Barra de progreso
local progressBar = Instance.new("Frame", main)
progressBar.Size = UDim2.new(1,-16,0,26)
progressBar.Position = UDim2.new(0,8,0,108)
progressBar.BackgroundColor3 = C.panel
progressBar.BorderSizePixel = 0 progressBar.ZIndex = 6
corner(progressBar, 7)
stroke(progressBar, C.border, 1)

local progressFill = Instance.new("Frame", progressBar)
progressFill.Size = UDim2.new(0,0,1,0)
progressFill.BackgroundColor3 = C.blue
progressFill.BorderSizePixel = 0 progressFill.ZIndex = 7
corner(progressFill, 7)

local progressLabel = mkLabel(progressBar, {
	text = "Listo para escanear",
	font = Enum.Font.GothamBold, size = 10, color = C.white,
	sz = UDim2.new(1,0,1,0),
	xa = Enum.TextXAlignment.Center, z = 8,
})

-- Contadores
local resumeFrame = Instance.new("Frame", main)
resumeFrame.Size = UDim2.new(1,-16,0,36)
resumeFrame.Position = UDim2.new(0,8,0,142)
resumeFrame.BackgroundColor3 = C.panel
resumeFrame.BorderSizePixel = 0 resumeFrame.ZIndex = 6
corner(resumeFrame, 7)
stroke(resumeFrame, C.border, 1)

local statsLayout = Instance.new("UIListLayout", resumeFrame)
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local counters = {}
local counterDefs = {
	{key="total",  label="TOTAL",      color=C.muted},
	{key="vuln",   label="VULNERABLE", color=C.red},
	{key="seguro", label="SEGURO",     color=C.green},
	{key="tools",  label="DIO TOOLS",  color=C.yellow},
}
for i, def in ipairs(counterDefs) do
	local cell = Instance.new("Frame", resumeFrame)
	cell.Size = UDim2.new(0.25,0,1,0)
	cell.BackgroundTransparency = 1
	cell.ZIndex = 7 cell.LayoutOrder = i
	local num = mkLabel(cell, {
		text = "0", font = Enum.Font.GothamBold,
		size = 14, color = def.color,
		sz = UDim2.new(1,0,0,20), pos = UDim2.new(0,0,0,2),
		xa = Enum.TextXAlignment.Center, z = 8,
	})
	mkLabel(cell, {
		text = def.label, font = Enum.Font.Gotham,
		size = 8, color = C.dim,
		sz = UDim2.new(1,0,0,12), pos = UDim2.new(0,0,0,20),
		xa = Enum.TextXAlignment.Center, z = 8,
	})
	counters[def.key] = num
end

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-16,1,-240)
scroll.Position = UDim2.new(0,8,0,186)
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
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local lpad = Instance.new("UIPadding", scroll)
lpad.PaddingTop = UDim.new(0,6) lpad.PaddingBottom = UDim.new(0,6)
lpad.PaddingLeft = UDim.new(0,6) lpad.PaddingRight = UDim.new(0,6)

-- Botones
local btnFrame = Instance.new("Frame", main)
btnFrame.Size = UDim2.new(1,-16,0,28)
btnFrame.Position = UDim2.new(0,8,1,-34)
btnFrame.BackgroundTransparency = 1 btnFrame.ZIndex = 6

local scanAllBtn = Instance.new("TextButton", btnFrame)
scanAllBtn.Size = UDim2.new(0.65,0,1,0)
scanAllBtn.Position = UDim2.new(0,0,0,0)
scanAllBtn.BackgroundColor3 = Color3.fromRGB(70,100,210)
scanAllBtn.Text = "Escanear todos los remotes"
scanAllBtn.TextColor3 = C.white scanAllBtn.TextSize = 11
scanAllBtn.Font = Enum.Font.GothamBold
scanAllBtn.BorderSizePixel = 0 scanAllBtn.ZIndex = 7
corner(scanAllBtn, 6)

local limpiarBtn = Instance.new("TextButton", btnFrame)
limpiarBtn.Size = UDim2.new(0.32,0,1,0)
limpiarBtn.Position = UDim2.new(0.68,0,0,0)
limpiarBtn.BackgroundColor3 = Color3.fromRGB(30,30,45)
limpiarBtn.Text = "Limpiar"
limpiarBtn.TextColor3 = C.dim limpiarBtn.TextSize = 11
limpiarBtn.Font = Enum.Font.Gotham
limpiarBtn.BorderSizePixel = 0 limpiarBtn.ZIndex = 7
corner(limpiarBtn, 6)
stroke(limpiarBtn, C.border, 1)

-- ================================================================
-- Snapshot
-- ================================================================
local function getSnapshot()
	local snap = { stats = {}, backpack = {}, character = {} }
	local ls = localPlayer:FindFirstChild("leaderstats")
	if ls then
		for _, s in ipairs(ls:GetChildren()) do
			snap.stats[s.Name] = s.Value
		end
	end
	local bp = localPlayer:FindFirstChild("Backpack")
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then
				snap.backpack[t.Name] = (snap.backpack[t.Name] or 0) + 1
			end
		end
	end
	local char = localPlayer.Character
	if char then
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") then
				snap.character[t.Name] = (snap.character[t.Name] or 0) + 1
			end
		end
	end
	return snap
end

local function diffSnapshot(antes, despues)
	local cambios = {}
	local toolsRecibidas = {}

	for nombre, valAntes in pairs(antes.stats) do
		local valDespues = despues.stats[nombre] or valAntes
		local diff = valDespues - valAntes
		if diff ~= 0 then
			local signo = diff > 0 and "+" or ""
			table.insert(cambios, nombre..": "..signo..diff)
		end
	end
	for nombre, val in pairs(despues.stats) do
		if not antes.stats[nombre] then
			table.insert(cambios, nombre.." (nuevo): "..tostring(val))
		end
	end
	for nombre, cant in pairs(despues.backpack) do
		local antesVal = antes.backpack[nombre] or 0
		if cant > antesVal then
			local diff = cant - antesVal
			table.insert(toolsRecibidas, nombre.." x"..diff)
			table.insert(cambios, "Tool en Backpack: "..nombre.." x"..diff)
		end
	end
	for nombre, cant in pairs(despues.character) do
		local antesVal = antes.character[nombre] or 0
		if cant > antesVal then
			local diff = cant - antesVal
			local entry = nombre.." x"..diff
			if not table.find(toolsRecibidas, entry) then
				table.insert(toolsRecibidas, entry)
				table.insert(cambios, "Tool equipada: "..nombre.." x"..diff)
			end
		end
	end
	return cambios, toolsRecibidas
end

-- ================================================================
-- Tarjeta de resultado
-- ================================================================
local cardOrden = 0

local function addCard(remote, estado, cambios, tools)
	cardOrden = cardOrden + 1
	local col = estado == "VULNERABLE" and C.red or C.green
	local alturaExtra = #tools > 0 and 16 or 0

	local card = Instance.new("Frame", scroll)
	card.Size = UDim2.new(1,0,0,58 + alturaExtra)
	card.BackgroundColor3 = C.card
	card.BorderSizePixel = 0
	card.LayoutOrder = cardOrden
	card.ZIndex = 7
	corner(card, 7)
	stroke(card, estado == "VULNERABLE" and C.red or C.border, 1)

	local barra = Instance.new("Frame", card)
	barra.Size = UDim2.new(0,3,1,-10)
	barra.Position = UDim2.new(0,0,0,5)
	barra.BackgroundColor3 = col
	barra.BorderSizePixel = 0 barra.ZIndex = 8
	corner(barra, 3)

	local badge = Instance.new("Frame", card)
	badge.Size = UDim2.new(0,80,0,16)
	badge.Position = UDim2.new(0,10,0,6)
	badge.BackgroundColor3 = col
	badge.BorderSizePixel = 0 badge.ZIndex = 8
	corner(badge, 4)
	mkLabel(badge, {
		text = estado, font = Enum.Font.GothamBold,
		size = 9, color = C.white,
		sz = UDim2.new(1,0,1,0),
		xa = Enum.TextXAlignment.Center, z = 9,
	})

	local tipoBadge = Instance.new("Frame", card)
	tipoBadge.Size = UDim2.new(0,60,0,16)
	tipoBadge.Position = UDim2.new(0,96,0,6)
	tipoBadge.BackgroundColor3 = Color3.fromRGB(40,40,60)
	tipoBadge.BorderSizePixel = 0 tipoBadge.ZIndex = 8
	corner(tipoBadge, 4)
	mkLabel(tipoBadge, {
		text = remote.ClassName == "RemoteFunction" and "Function" or "Event",
		font = Enum.Font.Gotham, size = 9, color = C.muted,
		sz = UDim2.new(1,0,1,0),
		xa = Enum.TextXAlignment.Center, z = 9,
	})

	mkLabel(card, {
		text = remote.Name,
		font = Enum.Font.GothamBold, size = 11, color = C.text,
		sz = UDim2.new(1,-170,0,16),
		pos = UDim2.new(0,162,0,5),
		trunc = Enum.TextTruncate.AtEnd, z = 8,
	})
	mkLabel(card, {
		text = "Ruta: "..remote:GetFullName(),
		size = 9, color = C.dim,
		sz = UDim2.new(1,-16,0,14),
		pos = UDim2.new(0,10,0,26),
		trunc = Enum.TextTruncate.AtEnd, z = 8,
	})

	local cambioTexto = #cambios > 0
		and table.concat(cambios, "  |  ")
		or "Sin cambios detectados"
	mkLabel(card, {
		text = cambioTexto,
		font = Enum.Font.GothamBold, size = 9,
		color = #cambios > 0 and C.red or C.green,
		sz = UDim2.new(1,-16,0,14),
		pos = UDim2.new(0,10,0,40),
		trunc = Enum.TextTruncate.AtEnd, z = 8,
	})

	if #tools > 0 then
		mkLabel(card, {
			text = "Tools guardadas: "..table.concat(tools, ", "),
			font = Enum.Font.GothamBold, size = 9,
			color = C.yellow,
			sz = UDim2.new(1,-16,0,14),
			pos = UDim2.new(0,10,0,55),
			trunc = Enum.TextTruncate.AtEnd, z = 8,
		})
	end

	task.wait()
	scroll.CanvasPosition = Vector2.new(0, math.huge)
end

-- ================================================================
-- Display helpers
-- ================================================================
local function getStatsTexto()
	local ls = localPlayer:FindFirstChild("leaderstats")
	if not ls then return "Sin leaderstats" end
	local p = {}
	for _, s in ipairs(ls:GetChildren()) do
		table.insert(p, s.Name..": "..tostring(s.Value))
	end
	return table.concat(p, "  |  ")
end

local function getBackpackTexto()
	local bp = localPlayer:FindFirstChild("Backpack")
	if not bp then return "No encontrado" end
	local tools = {}
	for _, t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") then table.insert(tools, t.Name) end
	end
	return #tools > 0 and table.concat(tools, ", ") or "Vacio"
end

task.spawn(function()
	while sg.Parent do
		statsValLabel.Text = getStatsTexto()
		backpackLabel.Text = getBackpackTexto()
		task.wait(0.5)
	end
end)

-- ================================================================
-- ESCANEO PRINCIPAL
-- ================================================================
local escaneando = false

scanAllBtn.MouseButton1Click:Connect(function()
	if escaneando then return end
	escaneando = true

	-- Activar protección
	activarProteccion()
	proteccionBadge.BackgroundColor3 = Color3.fromRGB(20,50,30)
	proteccionLabel.Text = "Proteccion: ON"
	proteccionLabel.TextColor3 = C.green

	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	cardOrden = 0

	local remotes = {}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			table.insert(remotes, v)
		end
	end

	local cTotal, cVuln, cSeguro, cTools = 0, 0, 0, 0
	counters.total.Text  = tostring(#remotes)
	counters.vuln.Text   = "0"
	counters.seguro.Text = "0"
	counters.tools.Text  = "0"

	scanAllBtn.Text = "Escaneando..."
	scanAllBtn.BackgroundColor3 = Color3.fromRGB(45,45,70)

	for i, remote in ipairs(remotes) do
		local pct = i / #remotes
		progressFill.Size = UDim2.new(pct, 0, 1, 0)
		progressLabel.Text = string.format(
			"Probando %d/%d — %s", i, #remotes, remote.Name)

		local antes = getSnapshot()

		pcall(function()
			if remote:IsA("RemoteFunction") then
				local hilo = task.spawn(function()
					pcall(function() remote:InvokeServer() end)
				end)
				task.wait(1)
				task.cancel(hilo)
			else
				remote:FireServer()
			end
		end)

		task.wait(1)

		local despues = getSnapshot()
		local cambios, tools = diffSnapshot(antes, despues)
		local estado = #cambios > 0 and "VULNERABLE" or "SEGURO"

		if estado == "VULNERABLE" then cVuln = cVuln + 1
		else cSeguro = cSeguro + 1 end
		if #tools > 0 then cTools = cTools + 1 end

		cTotal = cTotal + 1
		counters.total.Text  = tostring(cTotal)
		counters.vuln.Text   = tostring(cVuln)
		counters.seguro.Text = tostring(cSeguro)
		counters.tools.Text  = tostring(cTools)

		addCard(remote, estado, cambios, tools)
	end

	progressFill.Size = UDim2.new(1,0,1,0)
	progressFill.BackgroundColor3 = cVuln > 0 and C.red or C.green
	progressLabel.Text = string.format(
		"Listo — %d vulnerable(s) de %d remotes", cVuln, #remotes)

	scanAllBtn.Text = "Re-escanear"
	scanAllBtn.BackgroundColor3 = Color3.fromRGB(70,100,210)
	escaneando = false
end)

limpiarBtn.MouseButton1Click:Connect(function()
	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	cardOrden = 0
	counters.total.Text  = "0"
	counters.vuln.Text   = "0"
	counters.seguro.Text = "0"
	counters.tools.Text  = "0"
	progressFill.Size = UDim2.new(0,0,1,0)
	progressFill.BackgroundColor3 = C.blue
	progressLabel.Text = "Listo para escanear"
end)

print("All Remotes Checker v4 listo — Tools protegidas contra uso y quitar.")
