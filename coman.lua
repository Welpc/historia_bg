-- ══════════════════════════════════════════════════════════════
--  LeaderstatsEditor — StarterPlayerScripts (LocalScript)
--  Auto-detecta RemoteEvents/Functions para modificar stats
-- ══════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- ══════════════════════════════════════════
--  BUSCADOR DE REMOTES
-- ══════════════════════════════════════════
local foundRemotes = {}      -- { name, instance, type }
local testedRemote = nil     -- el remote que funcionó
local remoteLog    = {}      -- log de intentos

local function getAllRemotes(parent, list, depth)
	depth = depth or 0
	if depth > 6 then return end
	list = list or {}
	for _, obj in ipairs(parent:GetChildren()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			table.insert(list, { name = obj.Name, instance = obj, type = obj.ClassName, path = obj:GetFullName() })
		end
		getAllRemotes(obj, list, depth + 1)
	end
	return list
end

local function scanRemotes()
	foundRemotes = {}
	-- Busca en ReplicatedStorage y sus hijos
	local rs = getAllRemotes(ReplicatedStorage) or {}
	for _, r in ipairs(rs) do
		table.insert(foundRemotes, r)
	end
	-- Busca también en Workspace por si acaso
	local ws = getAllRemotes(game:GetService("Workspace")) or {}
	for _, r in ipairs(ws) do
		table.insert(foundRemotes, r)
	end
	return foundRemotes
end

-- Intenta disparar un remote con parámetros típicos de "set stat"
-- Prueba varios formatos comunes que usan los juegos
local function tryRemote(remote, targetName, statName, newValue)
	local ok, err = false, nil
	local plr = Players:FindFirstChild(targetName)

	-- Formatos comunes a intentar
	local payloads = {
		-- formato (playerName, statName, value)
		function() return remote.instance:FireServer(targetName, statName, newValue) end,
		-- formato (player, statName, value)
		function() return remote.instance:FireServer(plr, statName, newValue) end,
		-- formato (statName, value)
		function() return remote.instance:FireServer(statName, newValue) end,
		-- formato (playerName, { stat = value })
		function() return remote.instance:FireServer(targetName, { [statName] = newValue }) end,
		-- formato ({ player=, stat=, value= })
		function() return remote.instance:FireServer({ player = targetName, stat = statName, value = newValue }) end,
	}

	if remote.type == "RemoteFunction" then
		payloads = {
			function() return remote.instance:InvokeServer(targetName, statName, newValue) end,
			function() return remote.instance:InvokeServer(plr, statName, newValue) end,
			function() return remote.instance:InvokeServer(statName, newValue) end,
		}
	end

	for i, fn in ipairs(payloads) do
		local s, e = pcall(fn)
		if s then
			table.insert(remoteLog, "✅ " .. remote.path .. " [formato " .. i .. "] funcionó")
			return true
		else
			table.insert(remoteLog, "❌ " .. remote.path .. " [formato " .. i .. "]: " .. tostring(e))
		end
	end
	return false
end

-- Modifica directo en cliente (fallback si no hay remote)
local function setStatDirect(targetName, statName, newValue, statRef)
	if statRef and statRef.Parent then
		local s, e = pcall(function()
			if statRef:IsA("IntValue") then
				statRef.Value = math.floor(tonumber(newValue) or statRef.Value)
			elseif statRef:IsA("NumberValue") then
				statRef.Value = tonumber(newValue) or statRef.Value
			elseif statRef:IsA("StringValue") then
				statRef.Value = tostring(newValue)
			end
		end)
		if s then
			table.insert(remoteLog, "⚠️ Sin remote — editado solo en cliente")
			return true
		end
	end
	return false
end

-- Función principal: intenta todos los remotes, si ninguno → directo
local function setStat(targetName, statName, newValue, statRef)
	-- 1. Si ya encontramos uno que funcionó antes, úsalo primero
	if testedRemote then
		local ok = tryRemote(testedRemote, targetName, statName, newValue)
		if ok then return "remote", testedRemote.path end
	end

	-- 2. Busca remotes frescos y pruébalos todos
	local remotes = scanRemotes()
	for _, remote in ipairs(remotes) do
		-- filtra por nombres que suenen a "set/give/update/add stat/cash/coins/points"
		local nameLower = remote.name:lower()
		local relevant = nameLower:find("set") or nameLower:find("give") or
			nameLower:find("update") or nameLower:find("add") or
			nameLower:find("stat") or nameLower:find("cash") or
			nameLower:find("coin") or nameLower:find("point") or
			nameLower:find("money") or nameLower:find("gold") or
			nameLower:find("gem") or nameLower:find("level") or
			nameLower:find("xp") or nameLower:find("exp") or
			nameLower:find(statName:lower())

		if relevant then
			local ok = tryRemote(remote, targetName, statName, newValue)
			if ok then
				testedRemote = remote
				return "remote", remote.path
			end
		end
	end

	-- 3. Prueba TODOS los remotes sin filtro
	for _, remote in ipairs(remotes) do
		local ok = tryRemote(remote, targetName, statName, newValue)
		if ok then
			testedRemote = remote
			return "remote", remote.path
		end
	end

	-- 4. Fallback: edita directo en cliente
	local ok = setStatDirect(targetName, statName, newValue, statRef)
	if ok then return "direct", "cliente" end

	return "fail", "ninguno funcionó"
end

-- ══════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaderstatsEditorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón toggle
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,42,0,42)
ToggleBtn.Position = UDim2.new(0,12,0.5,-21)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,215,96)
ToggleBtn.Text = "💰"
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- Frame principal
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0,290,0,420)
Frame.Position = UDim2.new(0,62,0.5,-210)
Frame.BackgroundColor3 = Color3.fromRGB(12,12,18)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
local FStroke = Instance.new("UIStroke", Frame)
FStroke.Color = Color3.fromRGB(30,215,96)
FStroke.Thickness = 1.2

local GlowBar = Instance.new("Frame", Frame)
GlowBar.Size = UDim2.new(1,0,0,2)
GlowBar.BackgroundColor3 = Color3.fromRGB(30,215,96)
GlowBar.BorderSizePixel = 0
Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(0,12)

-- Header / drag
local Header = Instance.new("TextButton")
Header.Size = UDim2.new(1,0,0,42)
Header.BackgroundTransparency = 1
Header.Text = ""
Header.AutoButtonColor = false
Header.Parent = Frame

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-40,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Leaderstats Editor"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,24,0,24)
CloseBtn.Position = UDim2.new(1,-30,0.5,-12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(160,160,160)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

-- Status bar (muestra qué remote está usando)
local StatusBar = Instance.new("TextLabel", Frame)
StatusBar.Size = UDim2.new(1,-24,0,18)
StatusBar.Position = UDim2.new(0,12,0,44)
StatusBar.BackgroundTransparency = 1
StatusBar.Text = "🔍 Buscando remotes..."
StatusBar.TextColor3 = Color3.fromRGB(120,120,140)
StatusBar.TextSize = 9
StatusBar.Font = Enum.Font.Gotham
StatusBar.TextXAlignment = Enum.TextXAlignment.Left
StatusBar.TextTruncate = Enum.TextTruncate.AtEnd

-- Botón scan remotes
local ScanBtn = Instance.new("TextButton", Frame)
ScanBtn.Size = UDim2.new(0.48,0,0,26)
ScanBtn.Position = UDim2.new(0,12,0,66)
ScanBtn.BackgroundColor3 = Color3.fromRGB(25,60,90)
ScanBtn.Text = "🔎 Escanear remotes"
ScanBtn.TextColor3 = Color3.fromRGB(80,180,255)
ScanBtn.TextSize = 9
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.BorderSizePixel = 0
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0,8)

-- Botón ver log
local LogBtn = Instance.new("TextButton", Frame)
LogBtn.Size = UDim2.new(0.48,0,0,26)
LogBtn.Position = UDim2.new(0.52,-12,0,66)
LogBtn.BackgroundColor3 = Color3.fromRGB(40,30,60)
LogBtn.Text = "📋 Ver log"
LogBtn.TextColor3 = Color3.fromRGB(180,120,255)
LogBtn.TextSize = 9
LogBtn.Font = Enum.Font.GothamBold
LogBtn.BorderSizePixel = 0
Instance.new("UICorner", LogBtn).CornerRadius = UDim.new(0,8)

-- Log panel (oculto por default)
local LogPanel = Instance.new("ScrollingFrame", Frame)
LogPanel.Size = UDim2.new(1,-24,0,80)
LogPanel.Position = UDim2.new(0,12,0,96)
LogPanel.BackgroundColor3 = Color3.fromRGB(8,8,14)
LogPanel.BorderSizePixel = 0
LogPanel.ScrollBarThickness = 2
LogPanel.ScrollBarImageColor3 = Color3.fromRGB(180,120,255)
LogPanel.CanvasSize = UDim2.new(0,0,0,0)
LogPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogPanel.Visible = false
Instance.new("UICorner", LogPanel).CornerRadius = UDim.new(0,6)
local LogLayout = Instance.new("UIListLayout", LogPanel)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0,2)
local LogPad = Instance.new("UIPadding", LogPanel)
LogPad.PaddingTop = UDim.new(0,4)
LogPad.PaddingLeft = UDim.new(0,4)
LogPad.PaddingRight = UDim.new(0,4)

local function addLog(text)
	table.insert(remoteLog, text)
	local lbl = Instance.new("TextLabel", LogPanel)
	lbl.Size = UDim2.new(1,0,0,14)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = text:sub(1,1) == "✅" and Color3.fromRGB(30,215,96)
		or text:sub(1,1) == "❌" and Color3.fromRGB(255,80,80)
		or Color3.fromRGB(180,180,180)
	lbl.TextSize = 9
	lbl.Font = Enum.Font.Gotham
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.LayoutOrder = #remoteLog
	-- autoscroll
	task.defer(function()
		LogPanel.CanvasPosition = Vector2.new(0, LogPanel.AbsoluteCanvasSize.Y)
	end)
end

-- Refresh btn
local RefreshBtn = Instance.new("TextButton", Frame)
RefreshBtn.Size = UDim2.new(1,-24,0,26)
RefreshBtn.Position = UDim2.new(0,12,0,100)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(20,80,35)
RefreshBtn.Text = "🔄  Actualizar jugadores"
RefreshBtn.TextColor3 = Color3.fromRGB(30,215,96)
RefreshBtn.TextSize = 11
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.BorderSizePixel = 0
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,8)

-- Label jugador
local PlayerLabel = Instance.new("TextLabel", Frame)
PlayerLabel.Size = UDim2.new(1,-24,0,14)
PlayerLabel.Position = UDim2.new(0,12,0,132)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "JUGADOR"
PlayerLabel.TextColor3 = Color3.fromRGB(30,215,96)
PlayerLabel.TextSize = 9
PlayerLabel.Font = Enum.Font.GothamBold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1,-24,0,70)
PlayerScroll.Position = UDim2.new(0,12,0,148)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(18,18,28)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(30,215,96)
PlayerScroll.CanvasSize = UDim2.new(0,0,0,0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0,8)
local PSLayout = Instance.new("UIListLayout", PlayerScroll)
PSLayout.SortOrder = Enum.SortOrder.Name
PSLayout.Padding = UDim.new(0,3)
local PSPad = Instance.new("UIPadding", PlayerScroll)
PSPad.PaddingTop = UDim.new(0,4)
PSPad.PaddingLeft = UDim.new(0,4)
PSPad.PaddingRight = UDim.new(0,4)

-- Label stats
local StatsLabel = Instance.new("TextLabel", Frame)
StatsLabel.Size = UDim2.new(1,-24,0,14)
StatsLabel.Position = UDim2.new(0,12,0,226)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "LEADERSTATS"
StatsLabel.TextColor3 = Color3.fromRGB(30,215,96)
StatsLabel.TextSize = 9
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsScroll = Instance.new("ScrollingFrame", Frame)
StatsScroll.Size = UDim2.new(1,-24,0,168)
StatsScroll.Position = UDim2.new(0,12,0,242)
StatsScroll.BackgroundColor3 = Color3.fromRGB(18,18,28)
StatsScroll.BorderSizePixel = 0
StatsScroll.ScrollBarThickness = 3
StatsScroll.ScrollBarImageColor3 = Color3.fromRGB(30,215,96)
StatsScroll.CanvasSize = UDim2.new(0,0,0,0)
StatsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", StatsScroll).CornerRadius = UDim.new(0,8)
local SSLayout = Instance.new("UIListLayout", StatsScroll)
SSLayout.SortOrder = Enum.SortOrder.LayoutOrder
SSLayout.Padding = UDim.new(0,4)
local SSPad = Instance.new("UIPadding", StatsScroll)
SSPad.PaddingTop = UDim.new(0,6)
SSPad.PaddingLeft = UDim.new(0,6)
SSPad.PaddingRight = UDim.new(0,6)

local NoStats = Instance.new("TextLabel", StatsScroll)
NoStats.Size = UDim2.new(1,0,0,30)
NoStats.BackgroundTransparency = 1
NoStats.Text = "Selecciona un jugador..."
NoStats.TextColor3 = Color3.fromRGB(80,80,100)
NoStats.TextSize = 11
NoStats.Font = Enum.Font.Gotham

-- ── Drag ──────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = i.Position; startPos = Frame.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
	or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
			startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ══════════════════════════════════════════
--  LÓGICA PRINCIPAL
-- ══════════════════════════════════════════
local selectedPlayerName = nil
local playerButtons = {}

local function getStatsOf(plr)
	local result = {}
	local ls = plr:FindFirstChild("leaderstats")
	if not ls then return result end
	for _, stat in ipairs(ls:GetChildren()) do
		if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
			table.insert(result, {
				name = stat.Name,
				value = stat.Value,
				className = stat.ClassName,
				ref = stat
			})
		end
	end
	return result
end

local function clearStats()
	for _, c in ipairs(StatsScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	NoStats.Parent = StatsScroll
end

local function makeStatRow(sd, index)
	local row = Instance.new("Frame", StatsScroll)
	row.Size = UDim2.new(1,0,0,44)
	row.BackgroundColor3 = Color3.fromRGB(24,24,36)
	row.BorderSizePixel = 0
	row.LayoutOrder = index
	Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

	local nameL = Instance.new("TextLabel", row)
	nameL.Size = UDim2.new(0.55,0,0,18)
	nameL.Position = UDim2.new(0,8,0,4)
	nameL.BackgroundTransparency = 1
	nameL.Text = sd.name
	nameL.TextColor3 = Color3.fromRGB(30,215,96)
	nameL.TextSize = 11
	nameL.Font = Enum.Font.GothamBold
	nameL.TextXAlignment = Enum.TextXAlignment.Left

	local typeL = Instance.new("TextLabel", row)
	typeL.Size = UDim2.new(0.55,0,0,14)
	typeL.Position = UDim2.new(0,8,0,26)
	typeL.BackgroundTransparency = 1
	typeL.Text = sd.className
	typeL.TextColor3 = Color3.fromRGB(70,70,90)
	typeL.TextSize = 9
	typeL.Font = Enum.Font.Gotham
	typeL.TextXAlignment = Enum.TextXAlignment.Left

	local isNum = (sd.className == "IntValue" or sd.className == "NumberValue")
	local valBox = Instance.new(isNum and "TextBox" or "TextLabel", row)
	valBox.Size = UDim2.new(0,78,0,28)
	valBox.Position = UDim2.new(1,-84,0.5,-14)
	valBox.BackgroundColor3 = Color3.fromRGB(14,14,22)
	valBox.BackgroundTransparency = isNum and 0 or 1
	valBox.Text = tostring(sd.value)
	valBox.TextColor3 = Color3.fromRGB(255,255,255)
	valBox.TextSize = 13
	valBox.Font = Enum.Font.GothamBold
	valBox.BorderSizePixel = 0
	if isNum then valBox.PlaceholderText = "0" end
	valBox.ClearTextOnFocus = false

	-- Indicador de método usado
	local methodBadge = Instance.new("TextLabel", row)
	methodBadge.Size = UDim2.new(0,14,0,14)
	methodBadge.Position = UDim2.new(0,0,0,0)
	methodBadge.BackgroundTransparency = 1
	methodBadge.Text = ""
	methodBadge.TextSize = 8
	methodBadge.Font = Enum.Font.Gotham

	if isNum then
		Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,6)
		local vs = Instance.new("UIStroke", valBox)
		vs.Color = Color3.fromRGB(30,215,96)
		vs.Thickness = 1
		vs.Transparency = 0.5

		valBox.FocusLost:Connect(function(enter)
			if not enter or not selectedPlayerName then return end
			local num = tonumber(valBox.Text)
			if not num then valBox.Text = tostring(sd.ref and sd.ref.Value or sd.value); return end

			local method, info = setStat(selectedPlayerName, sd.name, num, sd.ref)

			if method == "remote" then
				vs.Color = Color3.fromRGB(80,180,255)
				methodBadge.Text = "🌐"
				StatusBar.Text = "🌐 Remote: " .. info
				addLog("✅ Editado via remote: " .. info)
			elseif method == "direct" then
				vs.Color = Color3.fromRGB(30,215,96)
				methodBadge.Text = "💻"
				StatusBar.Text = "💻 Edición local (solo cliente)"
				addLog("⚠️ Editado localmente (sin remote)")
			else
				vs.Color = Color3.fromRGB(255,80,80)
				methodBadge.Text = "✖"
				StatusBar.Text = "❌ No se pudo editar — " .. info
				addLog("❌ Falló todo: " .. info)
				valBox.Text = tostring(sd.ref and sd.ref.Value or sd.value)
			end

			vs.Transparency = 0
			task.delay(0.8, function() vs.Transparency = 0.5; vs.Color = Color3.fromRGB(30,215,96) end)
		end)
	end
end

local function loadStats(name)
	clearStats()
	if not name then return end
	local plr = Players:FindFirstChild(name)
	if not plr then NoStats.Text = name .. ": no encontrado"; return end
	local list = getStatsOf(plr)
	if #list == 0 then NoStats.Text = name .. ": sin leaderstats"; return end
	NoStats.Parent = nil
	for i, sd in ipairs(list) do makeStatRow(sd, i) end
end

local function refreshPlayers()
	for _, b in pairs(playerButtons) do b:Destroy() end
	playerButtons = {}
	selectedPlayerName = nil
	clearStats()
	NoStats.Text = "Selecciona un jugador..."
	for _, plr in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,26)
		btn.BackgroundColor3 = Color3.fromRGB(28,28,40)
		btn.Text = "👤  " .. plr.Name
		btn.TextColor3 = Color3.fromRGB(210,210,210)
		btn.TextSize = 11
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0
		btn.Parent = PlayerScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		local pad = Instance.new("UIPadding", btn)
		pad.PaddingLeft = UDim.new(0,8)
		playerButtons[plr.Name] = btn
		btn.MouseButton1Click:Connect(function()
			for _, b in pairs(playerButtons) do
				b.BackgroundColor3 = Color3.fromRGB(28,28,40)
				b.TextColor3 = Color3.fromRGB(210,210,210)
			end
			btn.BackgroundColor3 = Color3.fromRGB(18,50,26)
			btn.TextColor3 = Color3.fromRGB(30,215,96)
			selectedPlayerName = plr.Name
			loadStats(plr.Name)
		end)
	end
end

-- ── Botones ───────────────────────────────
ScanBtn.MouseButton1Click:Connect(function()
	testedRemote = nil
	local found = scanRemotes()
	local count = #found
	StatusBar.Text = "🔎 " .. count .. " remote(s) encontrado(s)"
	addLog("── Scan: " .. count .. " remotes ──")
	for _, r in ipairs(found) do
		addLog("  📡 [" .. r.type .. "] " .. r.path)
	end
end)

local logOpen = false
LogBtn.MouseButton1Click:Connect(function()
	logOpen = not logOpen
	LogPanel.Visible = logOpen
	-- desplaza los demás elementos
	local offset = logOpen and 84 or 0
	RefreshBtn.Position = UDim2.new(0,12,0,100 + offset)
	PlayerLabel.Position = UDim2.new(0,12,0,132 + offset)
	PlayerScroll.Position = UDim2.new(0,12,0,148 + offset)
	StatsLabel.Position = UDim2.new(0,12,0,226 + offset)
	StatsScroll.Position = UDim2.new(0,12,0,242 + offset)
	Frame.Size = UDim2.new(0,290,0, logOpen and 504 or 420)
end)

RefreshBtn.MouseButton1Click:Connect(refreshPlayers)

local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
	if open then
		refreshPlayers()
		-- escanea remotes al abrir
		task.spawn(function()
			local found = scanRemotes()
			StatusBar.Text = "🔎 " .. #found .. " remote(s) encontrado(s)"
			addLog("── Auto-scan al abrir: " .. #found .. " remotes ──")
			for _, r in ipairs(found) do
				addLog("  📡 [" .. r.type .. "] " .. r.path)
			end
		end)
	end
end)
CloseBtn.MouseButton1Click:Connect(function()
	open = false; Frame.Visible = false
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,215,96)
end)
ToggleBtn.MouseEnter:Connect(function() ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,230,110) end)
ToggleBtn.MouseLeave:Connect(function()
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
end)

print("[LeaderstatsEditor] Listo ✓ — Auto-buscador de remotes activo")
