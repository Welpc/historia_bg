-- ══════════════════════════════════════════════════════════════
--  LeaderstatsEditor — StarterPlayerScripts (LocalScript)
--  Pones el stat + valor → busca solo el remote que responde
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

-- Guarda el remote + formato que funcionó para no volver a buscar
local cachedRemote = nil
local cachedFmt    = nil

local function tryFire(remote, args)
	if remote:IsA("RemoteEvent") then
		return pcall(function() remote:FireServer(table.unpack(args)) end)
	else
		return pcall(function() remote:InvokeServer(table.unpack(args)) end)
	end
end

-- Busca y dispara: devuelve (true, remoteName) o (false, "motivo")
local function autoFire(player, statName, finalVal, rawVal, onProgress)
	-- Si ya tenemos cache, úsalo primero
	if cachedRemote and cachedRemote.Parent and cachedFmt then
		local ok = tryFire(cachedRemote, cachedFmt(player, statName, finalVal, rawVal))
		if ok then return true, cachedRemote:GetFullName() end
		cachedRemote = nil; cachedFmt = nil  -- cache inválido, re-busca
	end

	local formats = {
		function(p, s, v, r) return {p.Name, s, v} end,
		function(p, s, v, r) return {p,      s, v} end,
		function(p, s, v, r) return {s,         v} end,
		function(p, s, v, r) return {p.UserId, s, v} end,
		function(p, s, v, r) return {p.Name, s, r} end,
		function(p, s, v, r) return {p,      s, r} end,
		function(p, s, v, r) return {s,         r} end,
		function(p, s, v, r) return {p.Name,    v} end,
		function(p, s, v, r) return {p,         v} end,
		function(p, s, v, r) return {p.Name, v, s} end,
		function(p, s, v, r) return {p.UserId,  v} end,
	}

	local remotes = scanAllRemotes()
	local total   = #remotes * #formats
	local tried   = 0

	for _, remote in ipairs(remotes) do
		for _, fmt in ipairs(formats) do
			tried = tried + 1
			if onProgress then onProgress(tried, total, remote.Name) end

			local ok = tryFire(remote, fmt(player, statName, finalVal, rawVal))
			if ok then
				cachedRemote = remote
				cachedFmt    = fmt
				return true, remote:GetFullName()
			end
		end
	end

	return false, "ningún remote respondió (" .. #remotes .. " probados)"
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
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,290,0,360)
Frame.Position = UDim2.new(0,62,0.5,-180)
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

local Header = Instance.new("TextButton")
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundTransparency = 1
Header.Text = ""; Header.AutoButtonColor = false
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
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(160,160,160)
CloseBtn.TextSize = 11; CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

local function makeLabel(text, y)
	local l = Instance.new("TextLabel", Frame)
	l.Size = UDim2.new(1,-24,0,13)
	l.Position = UDim2.new(0,12,0,y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(30,215,96)
	l.TextSize = 9; l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

local function makeBox(y, placeholder)
	local box = Instance.new("TextBox", Frame)
	box.Size = UDim2.new(1,-24,0,32)
	box.Position = UDim2.new(0,12,0,y)
	box.BackgroundColor3 = Color3.fromRGB(18,18,28)
	box.Text = ""
	box.PlaceholderText = placeholder
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.PlaceholderColor3 = Color3.fromRGB(60,60,80)
	box.TextSize = 12; box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0; box.ClearTextOnFocus = false
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
	local s = Instance.new("UIStroke", box)
	s.Color = Color3.fromRGB(45,45,65); s.Thickness = 1
	box.Focused:Connect(function() s.Color = Color3.fromRGB(30,215,96) end)
	box.FocusLost:Connect(function() s.Color = Color3.fromRGB(45,45,65) end)
	local p = Instance.new("UIPadding", box); p.PaddingLeft = UDim.new(0,10)
	return box
end

-- ── Jugadores ────────────────────────────
makeLabel("JUGADOR", 46)

local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1,-24,0,66)
PlayerScroll.Position = UDim2.new(0,12,0,62)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(18,18,28)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(30,215,96)
PlayerScroll.CanvasSize = UDim2.new(0,0,0,0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0,8)
local PSL = Instance.new("UIListLayout", PlayerScroll)
PSL.SortOrder = Enum.SortOrder.Name; PSL.Padding = UDim.new(0,3)
local PSP = Instance.new("UIPadding", PlayerScroll)
PSP.PaddingTop = UDim.new(0,4); PSP.PaddingLeft = UDim.new(0,4); PSP.PaddingRight = UDim.new(0,4)

local RefreshBtn = Instance.new("TextButton", Frame)
RefreshBtn.Size = UDim2.new(1,-24,0,22)
RefreshBtn.Position = UDim2.new(0,12,0,133)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(18,40,25)
RefreshBtn.Text = "🔄 Actualizar jugadores"
RefreshBtn.TextColor3 = Color3.fromRGB(30,215,96)
RefreshBtn.TextSize = 10; RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.BorderSizePixel = 0
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,6)

-- ── Stat + Valor ─────────────────────────
makeLabel("NOMBRE DEL STAT", 164)
local StatBox = makeBox(180, "ej: Cash, Coins, Level...")

makeLabel("VALOR NUEVO", 220)
local ValBox = makeBox(236, "ej: 9999")

-- ── Botón enviar ─────────────────────────
local SendBtn = Instance.new("TextButton", Frame)
SendBtn.Size = UDim2.new(1,-24,0,36)
SendBtn.Position = UDim2.new(0,12,0,278)
SendBtn.BackgroundColor3 = Color3.fromRGB(20,150,60)
SendBtn.Text = "🚀  ENVIAR  (auto-busca el remote)"
SendBtn.TextColor3 = Color3.fromRGB(255,255,255)
SendBtn.TextSize = 12; SendBtn.Font = Enum.Font.GothamBold
SendBtn.BorderSizePixel = 0
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0,10)

-- ── Barra de progreso ────────────────────
local ProgBg = Instance.new("Frame", Frame)
ProgBg.Size = UDim2.new(1,-24,0,6)
ProgBg.Position = UDim2.new(0,12,0,320)
ProgBg.BackgroundColor3 = Color3.fromRGB(25,25,35)
ProgBg.BorderSizePixel = 0
Instance.new("UICorner", ProgBg).CornerRadius = UDim.new(1,0)

local ProgFill = Instance.new("Frame", ProgBg)
ProgFill.Size = UDim2.new(0,0,1,0)
ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
ProgFill.BorderSizePixel = 0
Instance.new("UICorner", ProgFill).CornerRadius = UDim.new(1,0)

-- ── Status ───────────────────────────────
local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1,-24,0,16)
StatusLabel.Position = UDim2.new(0,12,0,330)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Listo"
StatusLabel.TextColor3 = Color3.fromRGB(80,80,100)
StatusLabel.TextSize = 9; StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- Remote encontrado
local RemoteFoundLabel = Instance.new("TextLabel", Frame)
RemoteFoundLabel.Size = UDim2.new(1,-24,0,14)
RemoteFoundLabel.Position = UDim2.new(0,12,0,348)
RemoteFoundLabel.BackgroundTransparency = 1
RemoteFoundLabel.Text = ""
RemoteFoundLabel.TextColor3 = Color3.fromRGB(80,180,255)
RemoteFoundLabel.TextSize = 8; RemoteFoundLabel.Font = Enum.Font.Gotham
RemoteFoundLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteFoundLabel.TextTruncate = Enum.TextTruncate.AtEnd

local function setStatus(msg, color)
	StatusLabel.Text = msg
	StatusLabel.TextColor3 = color or Color3.fromRGB(80,80,100)
end

-- ══════════════════════════════════════════
--  ESTADO + DRAG
-- ══════════════════════════════════════════
local selectedPlayer = nil
local playerButtons  = {}
local isSending      = false

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

-- ── Jugadores ────────────────────────────
local function refreshPlayers()
	for _, b in pairs(playerButtons) do b:Destroy() end
	playerButtons = {}; selectedPlayer = nil

	for _, plr in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,24)
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
			setStatus("Jugador: " .. plr.Name, Color3.fromRGB(30,215,96))
			-- Auto-llena stat si está vacío
			local ls = plr:FindFirstChild("leaderstats")
			if ls then
				local first = ls:GetChildren()[1]
				if first and StatBox.Text == "" then StatBox.Text = first.Name end
			end
		end)
	end
end

RefreshBtn.MouseButton1Click:Connect(refreshPlayers)

-- ── ENVIAR ───────────────────────────────
SendBtn.MouseButton1Click:Connect(function()
	if isSending then return end

	if not selectedPlayer then
		setStatus("⚠️ Selecciona un jugador", Color3.fromRGB(255,200,50)); return
	end
	if StatBox.Text == "" then
		setStatus("⚠️ Escribe el nombre del stat", Color3.fromRGB(255,200,50)); return
	end
	if ValBox.Text == "" then
		setStatus("⚠️ Escribe el valor", Color3.fromRGB(255,200,50)); return
	end

	isSending = true
	SendBtn.Text = "⏳  Buscando remote..."
	SendBtn.BackgroundColor3 = Color3.fromRGB(60,60,20)
	ProgFill.Size = UDim2.new(0,0,1,0)
	RemoteFoundLabel.Text = ""

	local statName = StatBox.Text
	local rawVal   = ValBox.Text
	local numVal   = tonumber(rawVal)
	local finalVal = numVal or rawVal

	task.spawn(function()
		local ok, result = autoFire(
			selectedPlayer, statName, finalVal, rawVal,
			function(tried, total, remoteName)
				-- actualiza progreso en cada intento
				local pct = tried / total
				ProgFill.Size = UDim2.new(pct, 0, 1, 0)
				setStatus("🔎 Probando: " .. remoteName, Color3.fromRGB(150,150,80))
			end
		)

		ProgFill.Size = UDim2.new(1,0,1,0)

		if ok then
			SendBtn.Text = "✅  ENVIADO"
			SendBtn.BackgroundColor3 = Color3.fromRGB(10,130,45)
			setStatus("✅ " .. statName .. " = " .. tostring(finalVal), Color3.fromRGB(30,215,96))
			RemoteFoundLabel.Text = "🌐 " .. result
			ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
		else
			SendBtn.Text = "❌  Sin remote válido"
			SendBtn.BackgroundColor3 = Color3.fromRGB(130,20,20)
			setStatus("❌ " .. result, Color3.fromRGB(255,80,80))
			ProgFill.BackgroundColor3 = Color3.fromRGB(200,50,50)
		end

		task.wait(2)
		SendBtn.Text = "🚀  ENVIAR  (auto-busca el remote)"
		SendBtn.BackgroundColor3 = Color3.fromRGB(20,150,60)
		ProgFill.BackgroundColor3 = Color3.fromRGB(30,215,96)
		ProgFill.Size = UDim2.new(0,0,1,0)
		isSending = false
	end)
end)

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

print("[LeaderstatsEditor] Listo ✓ — Auto-remote activo")
