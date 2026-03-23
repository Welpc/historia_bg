-- ══════════════════════════════════════════════════════════════
--  LeaderstatsEditor — UN SOLO LocalScript
--  Ponlo en: StarterPlayerScripts (como LocalScript)
-- ══════════════════════════════════════════════════════════════

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ── GUI ───────────────────────────────────
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
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0,270,0,370)
Frame.Position = UDim2.new(0,62,0.5,-185)
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

local RefreshBtn = Instance.new("TextButton", Frame)
RefreshBtn.Size = UDim2.new(1,-24,0,28)
RefreshBtn.Position = UDim2.new(0,12,0,48)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(20,80,35)
RefreshBtn.Text = "🔄  Actualizar jugadores"
RefreshBtn.TextColor3 = Color3.fromRGB(30,215,96)
RefreshBtn.TextSize = 11
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.BorderSizePixel = 0
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,8)

local PlayerLabel = Instance.new("TextLabel", Frame)
PlayerLabel.Size = UDim2.new(1,-24,0,14)
PlayerLabel.Position = UDim2.new(0,12,0,82)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "JUGADOR"
PlayerLabel.TextColor3 = Color3.fromRGB(30,215,96)
PlayerLabel.TextSize = 9
PlayerLabel.Font = Enum.Font.GothamBold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1,-24,0,76)
PlayerScroll.Position = UDim2.new(0,12,0,98)
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

local StatsLabel = Instance.new("TextLabel", Frame)
StatsLabel.Size = UDim2.new(1,-24,0,14)
StatsLabel.Position = UDim2.new(0,12,0,182)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "LEADERSTATS"
StatsLabel.TextColor3 = Color3.fromRGB(30,215,96)
StatsLabel.TextSize = 9
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsScroll = Instance.new("ScrollingFrame", Frame)
StatsScroll.Size = UDim2.new(1,-24,0,168)
StatsScroll.Position = UDim2.new(0,12,0,198)
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
		dragging = true
		dragStart = i.Position
		startPos = Frame.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
	or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ── Lógica (todo cliente, sin RemoteEvents) ──
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
				ref = stat  -- referencia directa al objeto
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

	if isNum then
		Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,6)
		local vs = Instance.new("UIStroke", valBox)
		vs.Color = Color3.fromRGB(30,215,96)
		vs.Thickness = 1
		vs.Transparency = 0.5

		valBox.FocusLost:Connect(function(enter)
			if enter and sd.ref and sd.ref.Parent then
				local num = tonumber(valBox.Text)
				if num then
					-- Escribe directo en el stat (funciona en Studio y juegos sin FE estricto)
					if sd.className == "IntValue" then
						sd.ref.Value = math.floor(num)
					elseif sd.className == "NumberValue" then
						sd.ref.Value = num
					end
					vs.Transparency = 0
					task.delay(0.5, function() vs.Transparency = 0.5 end)
				else
					valBox.Text = tostring(sd.ref.Value)
				end
			end
		end)
	end
end

local function loadStats(name)
	clearStats()
	if not name then return end
	local plr = Players:FindFirstChild(name)
	if not plr then NoStats.Text = name .. ": no encontrado"; return end
	local list = getStatsOf(plr)
	if #list == 0 then
		NoStats.Text = name .. ": sin leaderstats"; return
	end
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
RefreshBtn.MouseButton1Click:Connect(refreshPlayers)

local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
	if open then refreshPlayers() end
end)
CloseBtn.MouseButton1Click:Connect(function()
	open = false
	Frame.Visible = false
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,215,96)
end)
ToggleBtn.MouseEnter:Connect(function()
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,230,110)
end)
ToggleBtn.MouseLeave:Connect(function()
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18,160,65) or Color3.fromRGB(30,215,96)
end)

print("[LeaderstatsEditor] LocalScript listo ✓")
