-- ══════════════════════════════════════════════════════════════
--  LeaderstatsEditor — StarterPlayerScripts (LocalScript)
--  Tú eliges el remote, pones el valor y lo dispara
-- ══════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- ══════════════════════════════════════════
--  SCANNER DE REMOTES
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

-- ══════════════════════════════════════════
--  GUI BASE
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaderstatsEditorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle btn
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
Frame.Size = UDim2.new(0,310,0,480)
Frame.Position = UDim2.new(0,62,0.5,-240)
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

-- Header drag
local Header = Instance.new("TextButton")
Header.Size = UDim2.new(1,0,0,40)
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

-- ── Sección 1: Jugadores ──────────────────
local function makeLabel(parent, text, y)
	local l = Instance.new("TextLabel", parent)
	l.Size = UDim2.new(1,-24,0,13)
	l.Position = UDim2.new(0,12,0,y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(30,215,96)
	l.TextSize = 9
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

makeLabel(Frame, "JUGADOR", 46)

local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1,-24,0,60)
PlayerScroll.Position = UDim2.new(0,12,0,62)
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
PSPad.PaddingTop = UDim.new(0,4); PSPad.PaddingLeft = UDim.new(0,4); PSPad.PaddingRight = UDim.new(0,4)

-- ── Sección 2: Remotes ───────────────────
makeLabel(Frame, "REMOTE A USAR", 130)

local RemoteScroll = Instance.new("ScrollingFrame", Frame)
RemoteScroll.Size = UDim2.new(1,-24,0,80)
RemoteScroll.Position = UDim2.new(0,12,0,146)
RemoteScroll.BackgroundColor3 = Color3.fromRGB(18,18,28)
RemoteScroll.BorderSizePixel = 0
RemoteScroll.ScrollBarThickness = 3
RemoteScroll.ScrollBarImageColor3 = Color3.fromRGB(80,180,255)
RemoteScroll.CanvasSize = UDim2.new(0,0,0,0)
RemoteScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", RemoteScroll).CornerRadius = UDim.new(0,8)
local RSLayout = Instance.new("UIListLayout", RemoteScroll)
RSLayout.SortOrder = Enum.SortOrder.LayoutOrder
RSLayout.Padding = UDim.new(0,3)
local RSPad = Instance.new("UIPadding", RemoteScroll)
RSPad.PaddingTop = UDim.new(0,4); RSPad.PaddingLeft = UDim.new(0,4); RSPad.PaddingRight = UDim.new(0,4)

local ScanBtn = Instance.new("TextButton", Frame)
ScanBtn.Size = UDim2.new(1,-24,0,24)
ScanBtn.Position = UDim2.new(0,12,0,232)
ScanBtn.BackgroundColor3 = Color3.fromRGB(20,50,80)
ScanBtn.Text = "🔎  Escanear remotes del juego"
ScanBtn.TextColor3 = Color3.fromRGB(80,180,255)
ScanBtn.TextSize = 10
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.BorderSizePixel = 0
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0,8)

local SelectedRemoteLabel = Instance.new("TextLabel", Frame)
SelectedRemoteLabel.Size = UDim2.new(1,-24,0,18)
SelectedRemoteLabel.Position = UDim2.new(0,12,0,262)
SelectedRemoteLabel.BackgroundTransparency = 1
SelectedRemoteLabel.Text = "Ningún remote seleccionado"
SelectedRemoteLabel.TextColor3 = Color3.fromRGB(100,100,120)
SelectedRemoteLabel.TextSize = 9
SelectedRemoteLabel.Font = Enum.Font.Gotham
SelectedRemoteLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedRemoteLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- ── Sección 3: Stat + Valor + Enviar ─────
makeLabel(Frame, "NOMBRE DEL STAT", 286)

local StatNameBox = Instance.new("TextBox", Frame)
StatNameBox.Size = UDim2.new(1,-24,0,30)
StatNameBox.Position = UDim2.new(0,12,0,302)
StatNameBox.BackgroundColor3 = Color3.fromRGB(18,18,28)
StatNameBox.Text = ""
StatNameBox.PlaceholderText = "ej: Cash, Coins, Level..."
StatNameBox.TextColor3 = Color3.fromRGB(255,255,255)
StatNameBox.PlaceholderColor3 = Color3.fromRGB(70,70,90)
StatNameBox.TextSize = 11
StatNameBox.Font = Enum.Font.Gotham
StatNameBox.BorderSizePixel = 0
StatNameBox.ClearTextOnFocus = false
Instance.new("UICorner", StatNameBox).CornerRadius = UDim.new(0,8)
local SNStroke = Instance.new("UIStroke", StatNameBox)
SNStroke.Color = Color3.fromRGB(50,50,70); SNStroke.Thickness = 1
StatNameBox.Focused:Connect(function() SNStroke.Color = Color3.fromRGB(30,215,96) end)
StatNameBox.FocusLost:Connect(function() SNStroke.Color = Color3.fromRGB(50,50,70) end)
local SNPad = Instance.new("UIPadding", StatNameBox); SNPad.PaddingLeft = UDim.new(0,8)

makeLabel(Frame, "VALOR NUEVO", 340)

local ValueBox = Instance.new("TextBox", Frame)
ValueBox.Size = UDim2.new(1,-24,0,30)
ValueBox.Position = UDim2.new(0,12,0,356)
ValueBox.BackgroundColor3 = Color3.fromRGB(18,18,28)
ValueBox.Text = ""
ValueBox.PlaceholderText = "ej: 9999"
ValueBox.TextColor3 = Color3.fromRGB(255,255,255)
ValueBox.PlaceholderColor3 = Color3.fromRGB(70,70,90)
ValueBox.TextSize = 13
ValueBox.Font = Enum.Font.GothamBold
ValueBox.BorderSizePixel = 0
ValueBox.ClearTextOnFocus = false
Instance.new("UICorner", ValueBox).CornerRadius = UDim.new(0,8)
local VStroke = Instance.new("UIStroke", ValueBox)
VStroke.Color = Color3.fromRGB(50,50,70); VStroke.Thickness = 1
ValueBox.Focused:Connect(function() VStroke.Color = Color3.fromRGB(30,215,96) end)
ValueBox.FocusLost:Connect(function() VStroke.Color = Color3.fromRGB(50,50,70) end)
local VPad = Instance.new("UIPadding", ValueBox); VPad.PaddingLeft = UDim.new(0,8)

-- Botón ENVIAR
local SendBtn = Instance.new("TextButton", Frame)
SendBtn.Size = UDim2.new(1,-24,0,34)
SendBtn.Position = UDim2.new(0,12,0,394)
SendBtn.BackgroundColor3 = Color3.fromRGB(20,150,60)
SendBtn.Text = "🚀  ENVIAR AL REMOTE"
SendBtn.TextColor3 = Color3.fromRGB(255,255,255)
SendBtn.TextSize = 13
SendBtn.Font = Enum.Font.GothamBold
SendBtn.BorderSizePixel = 0
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0,10)

-- Status
local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1,-24,0,16)
StatusLabel.Position = UDim2.new(0,12,0,434)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(30,215,96)
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd

local function setStatus(msg, color)
	StatusLabel.Text = msg
	StatusLabel.TextColor3 = color or Color3.fromRGB(30,215,96)
end

-- ══════════════════════════════════════════
--  ESTADO
-- ══════════════════════════════════════════
local selectedPlayer = nil
local selectedRemote = nil
local playerButtons  = {}
local remoteButtons  = {}

-- ── Drag ─────────────────────────────────
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

-- ── Poblar jugadores ─────────────────────
local function refreshPlayers()
	for _, b in pairs(playerButtons) do b:Destroy() end
	playerButtons = {}
	selectedPlayer = nil

	for _, plr in ipairs(Players:GetPlayers()) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,24)
		btn.BackgroundColor3 = Color3.fromRGB(28,28,40)
		btn.Text = "👤  " .. plr.Name
		btn.TextColor3 = Color3.fromRGB(210,210,210)
		btn.TextSize = 11
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0
		btn.Parent = PlayerScroll
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
			setStatus("Jugador: " .. plr.Name)
			-- Auto-llena el nombre del stat con el primero que encuentre
			local ls = plr:FindFirstChild("leaderstats")
			if ls then
				local first = ls:GetChildren()[1]
				if first and StatNameBox.Text == "" then
					StatNameBox.Text = first.Name
				end
			end
		end)
	end
end

-- ── Poblar remotes ───────────────────────
local function refreshRemotes()
	for _, b in ipairs(remoteButtons) do
		if b and b.Parent then b:Destroy() end
	end
	remoteButtons  = {}
	selectedRemote = nil
	SelectedRemoteLabel.Text = "Ningún remote seleccionado"
	SelectedRemoteLabel.TextColor3 = Color3.fromRGB(100,100,120)

	local remotes = scanAllRemotes()
	if #remotes == 0 then
		local lbl = Instance.new("TextLabel", RemoteScroll)
		lbl.Size = UDim2.new(1,0,0,24)
		lbl.BackgroundTransparency = 1
		lbl.Text = "  No se encontraron remotes"
		lbl.TextColor3 = Color3.fromRGB(100,100,120)
		lbl.TextSize = 10
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(remoteButtons, lbl)
		setStatus("Sin remotes encontrados", Color3.fromRGB(255,100,100))
		return
	end

	setStatus("🔎 " .. #remotes .. " remote(s) encontrado(s)")

	for i, remote in ipairs(remotes) do
		local isEvent = remote:IsA("RemoteEvent")
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,24)
		btn.BackgroundColor3 = Color3.fromRGB(22,28,40)
		btn.Text = (isEvent and "📡 " or "⚙️ ") .. remote:GetFullName()
		btn.TextColor3 = Color3.fromRGB(160,200,255)
		btn.TextSize = 9
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BorderSizePixel = 0
		btn.LayoutOrder = i
		btn.Parent = RemoteScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		local p = Instance.new("UIPadding", btn); p.PaddingLeft = UDim.new(0,8)
		table.insert(remoteButtons, btn)

		btn.MouseButton1Click:Connect(function()
			for _, b in ipairs(remoteButtons) do
				if b:IsA("TextButton") then
					b.BackgroundColor3 = Color3.fromRGB(22,28,40)
					b.TextColor3 = Color3.fromRGB(160,200,255)
				end
			end
			btn.BackgroundColor3 = Color3.fromRGB(18,40,70)
			btn.TextColor3 = Color3.fromRGB(80,180,255)
			selectedRemote = remote
			SelectedRemoteLabel.Text = "✅ " .. remote:GetFullName()
			SelectedRemoteLabel.TextColor3 = Color3.fromRGB(80,180,255)
			setStatus("Remote: " .. remote.Name)
		end)
	end
end

-- ── ENVIAR ───────────────────────────────
SendBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		setStatus("⚠️ Selecciona un jugador primero", Color3.fromRGB(255,200,50)); return
	end
	if not selectedRemote or not selectedRemote.Parent then
		setStatus("⚠️ Selecciona un remote primero", Color3.fromRGB(255,200,50)); return
	end
	if StatNameBox.Text == "" then
		setStatus("⚠️ Escribe el nombre del stat", Color3.fromRGB(255,200,50)); return
	end
	if ValueBox.Text == "" then
		setStatus("⚠️ Escribe el valor", Color3.fromRGB(255,200,50)); return
	end

	local statName = StatNameBox.Text
	local rawVal   = ValueBox.Text
	local numVal   = tonumber(rawVal)
	local finalVal = numVal or rawVal

	local isEvent = selectedRemote:IsA("RemoteEvent")

	-- Todos los formatos posibles que usan los juegos
	local formats = {
		{selectedPlayer.Name, statName, finalVal},
		{selectedPlayer,      statName, finalVal},
		{statName,            finalVal},
		{selectedPlayer.UserId, statName, finalVal},
		{selectedPlayer.Name, statName, rawVal},
		{selectedPlayer,      statName, rawVal},
		{statName,            rawVal},
		{selectedPlayer.Name, finalVal},
		{selectedPlayer,      finalVal},
	}

	local success = false
	local usedFmt = 0

	for i, args in ipairs(formats) do
		local ok = pcall(function()
			if isEvent then
				selectedRemote:FireServer(table.unpack(args))
			else
				selectedRemote:InvokeServer(table.unpack(args))
			end
		end)
		if ok then
			success = true
			usedFmt = i
			break
		end
	end

	if success then
		SendBtn.BackgroundColor3 = Color3.fromRGB(10,120,40)
		setStatus("✅ Enviado → " .. statName .. " = " .. tostring(finalVal), Color3.fromRGB(30,215,96))
		task.delay(1.2, function() SendBtn.BackgroundColor3 = Color3.fromRGB(20,150,60) end)
	else
		SendBtn.BackgroundColor3 = Color3.fromRGB(120,20,20)
		setStatus("❌ Este remote no aceptó ningún formato", Color3.fromRGB(255,80,80))
		task.delay(1.2, function() SendBtn.BackgroundColor3 = Color3.fromRGB(20,150,60) end)
	end
end)

-- ── Toggle / Close ───────────────────────
ScanBtn.MouseButton1Click:Connect(refreshRemotes)

local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
	if open then
		refreshPlayers()
		refreshRemotes()
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

print("[LeaderstatsEditor] Listo ✓")
