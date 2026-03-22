-- ══════════════════════════════════════════════════════════════
--  LeaderstatsEditor — StarterPlayerScripts (LocalScript)
--  Verifica si el stat REALMENTE cambió tras disparar el remote
-- ══════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- ══════════════════════════════════════════
--  SCANNER
-- ══════════════════════════════════════════
local function getAllRemotes(parent, list, depth)
	depth = depth or 0
	if depth > 8 then return list end
	list = list or {}
	for _, obj in ipairs(parent:GetChildren()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			table.insert(list, obj)
		end
		getAllRemotes(obj, list, depth + 1)
	end
	return list
end

local function scanAllRemotes()
	local list = {}
	getAllRemotes(ReplicatedStorage, list)
	getAllRemotes(game:GetService("Workspace"), list)
	return list
end

-- Cache del remote+formato que SÍ cambió el valor
local cachedRemote = nil
local cachedFmt    = nil

local FORMATS = {
	function(p,s,v,r) return {p.Name, s, v} end,
	function(p,s,v,r) return {p,      s, v} end,
	function(p,s,v,r) return {s,         v} end,
	function(p,s,v,r) return {p.UserId,s, v} end,
	function(p,s,v,r) return {p.Name, s, r} end,
	function(p,s,v,r) return {p,      s, r} end,
	function(p,s,v,r) return {s,         r} end,
	function(p,s,v,r) return {p.Name,    v} end,
	function(p,s,v,r) return {p,         v} end,
	function(p,s,v,r) return {p.Name, v, s} end,
	function(p,s,v,r) return {p.UserId,  v} end,
}

local function fireRemote(remote, args)
	if remote:IsA("RemoteEvent") then
		pcall(function() remote:FireServer(table.unpack(args)) end)
	else
		pcall(function() remote:InvokeServer(table.unpack(args)) end)
	end
end

-- Espera hasta WAIT_TIME segundos a que stat.Value == targetVal
local WAIT_TIME = 1.2

local function waitForChange(stat, targetVal)
	local changed = false
	local conn
	conn = stat.Changed:Connect(function(v)
		if tonumber(v) == tonumber(targetVal) then
			changed = true
		end
	end)
	local t = 0
	while not changed and t < WAIT_TIME do
		task.wait(0.05)
		t = t + 0.05
		-- también chequea directo por si el evento ya disparó
		if tonumber(stat.Value) == tonumber(targetVal) then
			changed = true
		end
	end
	conn:Disconnect()
	return changed
end

-- Busca el remote que SÍ hace cambiar el stat
-- onProgress(tried, total, remoteName, fmtIndex)
local function autoFire(player, stat, targetVal, onProgress)
	local rawVal = tostring(targetVal)

	-- Intenta cache primero
	if cachedRemote and cachedRemote.Parent and cachedFmt then
		fireRemote(cachedRemote, cachedFmt(player, stat.Name, targetVal, rawVal))
		if waitForChange(stat, targetVal) then
			return true, cachedRemote:GetFullName()
		end
		-- cache ya no sirve
		cachedRemote = nil; cachedFmt = nil
	end

	local remotes = scanAllRemotes()
	local total   = #remotes * #FORMATS
	local tried   = 0

	for _, remote in ipairs(remotes) do
		for fi, fmt in ipairs(FORMATS) do
			tried = tried + 1
			if onProgress then onProgress(tried, total, remote.Name, fi) end

			fireRemote(remote, fmt(player, stat.Name, targetVal, rawVal))

			if waitForChange(stat, targetVal) then
				cachedRemote = remote
				cachedFmt    = fmt
				return true, remote:GetFullName()
			end
		end
	end

	return false, "ningún remote cambió el valor (" .. #remotes .. " probados)"
end

-- ══════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaderstatsEditorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,42,0,42)
ToggleBtn.Position = UDim2.new(0,12,0.5,-21)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,215,96)
ToggleBtn.Text = "💰"
ToggleBtn.TextSize = 20; ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0; ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,300,0,445)
Frame.Position = UDim2.new(0,62,0.5,-222)
Frame.BackgroundColor3 = Color3.fromRGB(12,12,18)
Frame.BorderSizePixel = 0; Frame.Visible = false; Frame.Active = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)
local FStroke = Instance.new("UIStroke", Frame)
FStroke.Color = Color3.fromRGB(30,215,96); FStroke.Thickness = 1.2

local GlowBar = Instance.new("Frame", Frame)
GlowBar.Size = UDim2.new(1,0,0,2)
GlowBar.BackgroundColor3 = Color3.fromRGB(30,215,96)
GlowBar.BorderSizePixel = 0
Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(0,12)

local Header = Instance.new("TextButton")
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundTransparency = 1; Header.Text = ""; Header.AutoButtonColor = false
Header.Parent = Frame

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-40,1,0); Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1; Title.Text = "⚡ Leaderstats Editor"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 13; Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,24,0,24); CloseBtn.Position = UDim2.new(1,-30,0.5,-12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(160,160,160)
CloseBtn.TextSize = 11; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

local function makeLabel(text, y)
	local l = Instance.new("TextLabel", Frame)
	l.Size = UDim2.new(1,-24,0,13); l.Position = UDim2.new(0,12,0,y)
	l.BackgroundTransparency = 1; l.Text = text
	l.TextColor3 = Color3.fromRGB(30,215,96)
	l.TextSize = 9; l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

-- Jugadores
makeLabel("JUGADOR", 46)
local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1,-24,0,66); PlayerScroll.Position = UDim2.new(0,12,0,62)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(18,18,28); PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3; PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(30,215,96)
PlayerScroll.CanvasSize = UDim2.new(0,0,0,0); PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0,8)
local PSL = Instance.new("UIListLayout", PlayerScroll)
PSL.SortOrder = Enum.SortOrder.Name; PSL.Padding = UDim.new(0,3)
local PSP = Instance.new("UIPadding", PlayerScroll)
PSP.PaddingTop = UDim.new(0,4); PSP.PaddingLeft = UDim.new(0,4); PSP.PaddingRight = UDim.new(0,4)

-- Stats
makeLabel("LEADERSTATS  —  edita el número y presiona ✔", 136)
local StatsScroll = Instance.new("ScrollingFrame", Frame)
StatsScroll.Size = UDim2.new(1,-24,0,236); StatsScroll.Position = UDim2.new(0,12,0,152)
StatsScroll.BackgroundColor3 = Color3.fromRGB(18,18,28); StatsScroll.BorderSizePixel = 0
StatsScroll.ScrollBarThickness = 3; StatsScroll.ScrollBarImageColor3 = Color3.fromRGB(30,215,96)
StatsScroll.CanvasSize = UDim2.new(0,0,0,0); StatsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", StatsScroll).CornerRadius = UDim.new(0,8)
local SSL = Instance.new("UIListLayout", StatsScroll)
SSL.SortOrder = Enum.SortOrder.LayoutOrder; SSL.Padding = UDim.new(0,5)
local SSP = Instance.new("UIPadding", StatsScroll)
SSP.PaddingTop = UDim.new(0,6); SSP.PaddingLeft = UDim.new(0,6); SSP.PaddingRight = UDim.new(0,6)

local NoStatsLabel = Instance.new("TextLabel", StatsScroll)
NoStatsLabel.Size = UDim2.new(1,0,0,30); NoStatsLabel.BackgroundTransparency = 1
NoStatsLabel.Text = "Selecciona un jugador..."
NoStatsLabel.TextColor3 = Color3.fromRGB(70,70,90)
NoStatsLabel.TextSize = 11; NoStatsLabel.Font = Enum.Font.Gotham

-- Barra progreso
local ProgBg = Instance.new("Frame", Frame)
ProgBg.Size = UDim2.new(1,-24,0,5); ProgBg.Position = UDim2.new(0,12,0,396)
ProgBg.BackgroundColor3 = Color3.fromRGB(22,22,32); ProgBg.BorderSizePixel = 0
Instance.new("UICorner", ProgBg).CornerRadius = UDim.new(1,0)

local ProgFill = Instance.new("Frame", ProgBg)
ProgFill.Size = UDim2.new(0,0,1,0)
ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96); ProgFill.BorderSizePixel = 0
Instance.new("UICorner", ProgFill).CornerRadius = UDim.new(1,0)

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1,-24,0,14); StatusLabel.Position = UDim2.new(0,12,0,404)
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "Selecciona un jugador"
StatusLabel.TextColor3 = Color3.fromRGB(70,70,90)
StatusLabel.TextSize = 9; StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd

local RemoteLabel = Instance.new("TextLabel", Frame)
RemoteLabel.Size = UDim2.new(1,-24,0,13); RemoteLabel.Position = UDim2.new(0,12,0,420)
RemoteLabel.BackgroundTransparency = 1; RemoteLabel.Text = ""
RemoteLabel.TextColor3 = Color3.fromRGB(80,180,255)
RemoteLabel.TextSize = 8; RemoteLabel.Font = Enum.Font.Gotham
RemoteLabel.TextXAlignment = Enum.TextXAlignment.Left; RemoteLabel.TextTruncate = Enum.TextTruncate.AtEnd

local function setStatus(msg, col)
	StatusLabel.Text = msg
	StatusLabel.TextColor3 = col or Color3.fromRGB(70,70,90)
end

-- ── DRAG ─────────────────────────────────
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
--  FILAS DE STATS
-- ══════════════════════════════════════════
local selectedPlayer = nil
local playerButtons  = {}
local statRows       = {}
local busyStats      = {}

local function clearStats()
	for _, r in ipairs(statRows) do if r and r.Parent then r:Destroy() end end
	statRows = {}
	NoStatsLabel.Parent = StatsScroll
	RemoteLabel.Text = ""
	setStatus("Selecciona un jugador")
end

local function makeStatRow(plr, stat, index)
	NoStatsLabel.Parent = nil
	local isNum = stat:IsA("IntValue") or stat:IsA("NumberValue")

	local row = Instance.new("Frame", StatsScroll)
	row.Size = UDim2.new(1,0,0,50)
	row.BackgroundColor3 = Color3.fromRGB(20,20,32)
	row.BorderSizePixel = 0; row.LayoutOrder = index
	Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
	local RS = Instance.new("UIStroke", row)
	RS.Color = Color3.fromRGB(35,35,55); RS.Thickness = 1
	table.insert(statRows, row)

	-- Nombre
	local nameL = Instance.new("TextLabel", row)
	nameL.Size = UDim2.new(0.52,0,0,20); nameL.Position = UDim2.new(0,10,0,6)
	nameL.BackgroundTransparency = 1; nameL.Text = stat.Name
	nameL.TextColor3 = Color3.fromRGB(30,215,96)
	nameL.TextSize = 13; nameL.Font = Enum.Font.GothamBold
	nameL.TextXAlignment = Enum.TextXAlignment.Left

	-- Tipo
	local typeL = Instance.new("TextLabel", row)
	typeL.Size = UDim2.new(0.52,0,0,13); typeL.Position = UDim2.new(0,10,0,28)
	typeL.BackgroundTransparency = 1; typeL.Text = stat.ClassName
	typeL.TextColor3 = Color3.fromRGB(50,50,72)
	typeL.TextSize = 9; typeL.Font = Enum.Font.Gotham
	typeL.TextXAlignment = Enum.TextXAlignment.Left

	-- Caja de valor
	local valBox = Instance.new(isNum and "TextBox" or "TextLabel", row)
	valBox.Size = UDim2.new(0,82,0,32); valBox.Position = UDim2.new(1,-120,0.5,-16)
	valBox.BackgroundColor3 = Color3.fromRGB(14,14,22)
	valBox.BackgroundTransparency = isNum and 0 or 1
	valBox.Text = tostring(stat.Value)
	valBox.TextColor3 = Color3.fromRGB(255,255,255)
	valBox.TextSize = 13; valBox.Font = Enum.Font.GothamBold
	valBox.BorderSizePixel = 0; valBox.ClearTextOnFocus = false
	Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,6)
	local VS = Instance.new("UIStroke", valBox)
	VS.Color = Color3.fromRGB(40,40,60); VS.Thickness = 1
	local VP = Instance.new("UIPadding", valBox); VP.PaddingLeft = UDim.new(0,6)

	if isNum then
		valBox.Focused:Connect(function() VS.Color = Color3.fromRGB(30,215,96) end)
		valBox.FocusLost:Connect(function() VS.Color = Color3.fromRGB(40,40,60) end)
	end

	-- Mantiene visible el valor real del servidor
	stat.Changed:Connect(function(v)
		if valBox and valBox.Parent then
			local focused = isNum and valBox:IsFocused() or false
			if not focused then valBox.Text = tostring(v) end
		end
	end)

	-- Botón ✔
	local confirmBtn = Instance.new("TextButton", row)
	confirmBtn.Size = UDim2.new(0,32,0,32); confirmBtn.Position = UDim2.new(1,-36,0.5,-16)
	confirmBtn.BackgroundColor3 = isNum and Color3.fromRGB(20,80,35) or Color3.fromRGB(25,25,35)
	confirmBtn.Text = isNum and "✔" or "—"
	confirmBtn.TextColor3 = isNum and Color3.fromRGB(30,215,96) or Color3.fromRGB(50,50,70)
	confirmBtn.TextSize = 15; confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.BorderSizePixel = 0
	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0,6)

	if not isNum then return row end

	confirmBtn.MouseButton1Click:Connect(function()
		if busyStats[stat.Name] then return end

		local num = tonumber(valBox.Text)
		if not num then
			valBox.Text = tostring(stat.Value)
			setStatus("⚠️ Valor inválido en " .. stat.Name, Color3.fromRGB(255,200,50))
			return
		end

		-- Si el valor ya es ese, no hace nada
		if tonumber(stat.Value) == num then
			setStatus("ℹ️ " .. stat.Name .. " ya vale " .. tostring(num), Color3.fromRGB(100,150,255))
			return
		end

		busyStats[stat.Name] = true
		confirmBtn.Text = "⏳"; confirmBtn.BackgroundColor3 = Color3.fromRGB(60,60,15)
		RS.Color = Color3.fromRGB(180,180,40)
		ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
		ProgFill.Size = UDim2.new(0,0,1,0)
		RemoteLabel.Text = ""
		setStatus("🔎 Buscando remote para " .. stat.Name .. "...", Color3.fromRGB(200,200,50))

		task.spawn(function()
			local ok, result = autoFire(
				plr, stat, num,
				function(tried, total, remoteName)
					ProgFill.Size = UDim2.new(tried/total, 0, 1, 0)
					setStatus("🔎 Probando " .. remoteName .. "...", Color3.fromRGB(160,160,50))
				end
			)

			ProgFill.Size = UDim2.new(1,0,1,0)

			if ok then
				-- Doble confirmación: leer el valor real
				task.wait(0.1)
				local realVal = stat.Value
				if tonumber(realVal) == num then
					confirmBtn.Text = "✅"; confirmBtn.BackgroundColor3 = Color3.fromRGB(10,110,35)
					RS.Color = Color3.fromRGB(30,215,96); VS.Color = Color3.fromRGB(30,215,96)
					setStatus("✅ " .. stat.Name .. " = " .. tostring(num), Color3.fromRGB(30,215,96))
					RemoteLabel.Text = "🌐 " .. result
					ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
				else
					-- Disparó ok pero el valor no cambió (servidor lo rechazó)
					confirmBtn.Text = "⚠️"; confirmBtn.BackgroundColor3 = Color3.fromRGB(100,70,10)
					RS.Color = Color3.fromRGB(200,150,30)
					valBox.Text = tostring(realVal)
					setStatus("⚠️ Remote disparó pero el servidor no aplicó el cambio", Color3.fromRGB(255,180,50))
					RemoteLabel.Text = "Remote: " .. result .. " (no aplicó)"
					ProgFill.BackgroundColor3 = Color3.fromRGB(200,150,30)
				end
			else
				confirmBtn.Text = "❌"; confirmBtn.BackgroundColor3 = Color3.fromRGB(110,18,18)
				RS.Color = Color3.fromRGB(200,40,40)
				valBox.Text = tostring(stat.Value)
				setStatus("❌ " .. result, Color3.fromRGB(255,70,70))
				ProgFill.BackgroundColor3 = Color3.fromRGB(180,40,40)
			end

			task.wait(2)
			confirmBtn.Text = "✔"; confirmBtn.BackgroundColor3 = Color3.fromRGB(20,80,35)
			confirmBtn.TextColor3 = Color3.fromRGB(30,215,96)
			RS.Color = Color3.fromRGB(35,35,55); VS.Color = Color3.fromRGB(40,40,60)
			ProgFill.Size = UDim2.new(0,0,1,0)
			ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
			busyStats[stat.Name] = nil
		end)
	end)

	return row
end

local function loadStats(plr)
	clearStats()
	if not plr then return end
	local ls = plr:FindFirstChild("leaderstats")
	if not ls then
		NoStatsLabel.Text = plr.Name .. " no tiene leaderstats"; return
	end
	local children = ls:GetChildren()
	if #children == 0 then NoStatsLabel.Text = "Sin stats"; return end
	for i, stat in ipairs(children) do
		if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
			makeStatRow(plr, stat, i)
		end
	end
end

-- ── Jugadores ────────────────────────────
local function refreshPlayers()
	for _, b in pairs(playerButtons) do b:Destroy() end
	playerButtons = {}; selectedPlayer = nil
	clearStats()

	for _, plr in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,26)
		btn.BackgroundColor3 = Color3.fromRGB(28,28,40)
		btn.Text = "👤  " .. plr.Name
		btn.TextColor3 = Color3.fromRGB(210,210,210)
		btn.TextSize = 11; btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0; btn.Parent = PlayerScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		local p = Instance.new("UIPadding", btn); p.PaddingLeft = UDim.new(0,8)
		playerButtons[plr.Name] = btn

		btn.MouseButton1Click:Connect(function()
			for _, b in pairs(playerButtons) do
				b.BackgroundColor3 = Color3.fromRGB(28,28,40)
				b.TextColor3 = Color3.fromRGB(210,210,210)
			end
			btn.BackgroundColor3 = Color3.fromRGB(18,50,26)
			btn.TextColor3 = Color3.fromRGB(30,215,96)
			selectedPlayer = plr
			loadStats(plr)
			setStatus("Jugador: " .. plr.Name, Color3.fromRGB(30,215,96))
		end)
	end
end

-- ── Toggle / Close ───────────────────────
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
	if open then refreshPlayers() end
end)
CloseBtn.MouseButton1Click:Connect(function()
	open = false; Frame.Visible = false
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,215,96)
end)
ToggleBtn.MouseEnter:Connect(function() ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,230,110) end)
ToggleBtn.MouseLeave:Connect(function()
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
end)

Players.PlayerAdded:Connect(function() if open then refreshPlayers() end end)
Players.PlayerRemoving:Connect(function(plr)
	if open then
		if selectedPlayer == plr then clearStats() end
		refreshPlayers()
	end
end)

print("[LeaderstatsEditor] Listo ✓")
