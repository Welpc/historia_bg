-- LeaderstatsEditor LocalScript
-- Pon este script en StarterPlayerScripts o dentro de un ScreenGui en StarterGui

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
--  CREAR LA GUI
-- ══════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaderstatsEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ── Botón flotante ────────────────────────
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 12, 0.5, -20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
ToggleBtn.Text = "💰"
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- ── Panel principal (más compacto) ────────
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 260, 0, 340)
Frame.Position = UDim2.new(0, 60, 0.5, -170)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true   -- necesario para que capture input al arrastrar
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
local FStroke = Instance.new("UIStroke", Frame)
FStroke.Color = Color3.fromRGB(30, 215, 96)
FStroke.Thickness = 1.2

-- Barra verde top
local GlowBar = Instance.new("Frame", Frame)
GlowBar.Size = UDim2.new(1, 0, 0, 2)
GlowBar.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
GlowBar.BorderSizePixel = 0
Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(0, 12)

-- ── Header (drag handle) ──────────────────
local Header = Instance.new("TextButton")  -- TextButton para capturar drag
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Text = ""
Header.AutoButtonColor = false
Header.Parent = Frame

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Leaderstats"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Icono de drag hint
local DragHint = Instance.new("TextLabel", Header)
DragHint.Size = UDim2.new(0, 20, 0, 14)
DragHint.Position = UDim2.new(0.5, -10, 0, 4)
DragHint.BackgroundTransparency = 1
DragHint.Text = "⠿"
DragHint.TextColor3 = Color3.fromRGB(60, 60, 80)
DragHint.TextSize = 14
DragHint.Font = Enum.Font.Gotham

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Divider
local Divider = Instance.new("Frame", Frame)
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 40)
Divider.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Divider.BorderSizePixel = 0

-- ── Label Jugador ─────────────────────────
local PlayerLabel = Instance.new("TextLabel", Frame)
PlayerLabel.Size = UDim2.new(1, -24, 0, 16)
PlayerLabel.Position = UDim2.new(0, 12, 0, 48)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "JUGADOR"
PlayerLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
PlayerLabel.TextSize = 9
PlayerLabel.Font = Enum.Font.GothamBold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ── ScrollFrame jugadores ─────────────────
local PlayerScroll = Instance.new("ScrollingFrame", Frame)
PlayerScroll.Size = UDim2.new(1, -24, 0, 72)
PlayerScroll.Position = UDim2.new(0, 12, 0, 66)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 8)
local PSLayout = Instance.new("UIListLayout", PlayerScroll)
PSLayout.SortOrder = Enum.SortOrder.Name
PSLayout.Padding = UDim.new(0, 3)
local PSPad = Instance.new("UIPadding", PlayerScroll)
PSPad.PaddingTop = UDim.new(0, 4)
PSPad.PaddingLeft = UDim.new(0, 4)
PSPad.PaddingRight = UDim.new(0, 4)

-- ── Label Stats ───────────────────────────
local StatsLabel = Instance.new("TextLabel", Frame)
StatsLabel.Size = UDim2.new(1, -24, 0, 16)
StatsLabel.Position = UDim2.new(0, 12, 0, 148)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "LEADERSTATS"
StatsLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
StatsLabel.TextSize = 9
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ── ScrollFrame stats ─────────────────────
local StatsScroll = Instance.new("ScrollingFrame", Frame)
StatsScroll.Size = UDim2.new(1, -24, 0, 160)
StatsScroll.Position = UDim2.new(0, 12, 0, 166)
StatsScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
StatsScroll.BorderSizePixel = 0
StatsScroll.ScrollBarThickness = 3
StatsScroll.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
StatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
StatsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", StatsScroll).CornerRadius = UDim.new(0, 8)
local SSLayout = Instance.new("UIListLayout", StatsScroll)
SSLayout.SortOrder = Enum.SortOrder.LayoutOrder
SSLayout.Padding = UDim.new(0, 4)
local SSPad = Instance.new("UIPadding", StatsScroll)
SSPad.PaddingTop = UDim.new(0, 6)
SSPad.PaddingLeft = UDim.new(0, 6)
SSPad.PaddingRight = UDim.new(0, 6)

local NoStats = Instance.new("TextLabel", StatsScroll)
NoStats.Size = UDim2.new(1, 0, 0, 30)
NoStats.BackgroundTransparency = 1
NoStats.Text = "Selecciona un jugador..."
NoStats.TextColor3 = Color3.fromRGB(80, 80, 100)
NoStats.TextSize = 11
NoStats.Font = Enum.Font.Gotham

-- ══════════════════════════════════════════
--  DRAG (mover la ventana)
-- ══════════════════════════════════════════

local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ══════════════════════════════════════════
--  LÓGICA
-- ══════════════════════════════════════════

local selectedPlayer = nil
local playerButtons = {}

local function makePlayerBtn(plr)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 26)
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
	btn.Text = "👤  " .. plr.Name
	btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	btn.TextSize = 11
	btn.Font = Enum.Font.Gotham
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = PlayerScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local pad = Instance.new("UIPadding", btn)
	pad.PaddingLeft = UDim.new(0, 8)
	return btn
end

local function makeStatRow(statName, statObj, index)
	local row = Instance.new("Frame", StatsScroll)
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
	row.BorderSizePixel = 0
	row.LayoutOrder = index
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local nameL = Instance.new("TextLabel", row)
	nameL.Size = UDim2.new(0.5, 0, 0, 18)
	nameL.Position = UDim2.new(0, 8, 0, 4)
	nameL.BackgroundTransparency = 1
	nameL.Text = statName
	nameL.TextColor3 = Color3.fromRGB(30, 215, 96)
	nameL.TextSize = 11
	nameL.Font = Enum.Font.GothamBold
	nameL.TextXAlignment = Enum.TextXAlignment.Left

	local typeL = Instance.new("TextLabel", row)
	typeL.Size = UDim2.new(0.5, 0, 0, 14)
	typeL.Position = UDim2.new(0, 8, 0, 24)
	typeL.BackgroundTransparency = 1
	typeL.Text = statObj.ClassName
	typeL.TextColor3 = Color3.fromRGB(70, 70, 90)
	typeL.TextSize = 9
	typeL.Font = Enum.Font.Gotham
	typeL.TextXAlignment = Enum.TextXAlignment.Left

	local isNum = statObj:IsA("IntValue") or statObj:IsA("NumberValue")
	local valBox = Instance.new(isNum and "TextBox" or "TextLabel", row)
	valBox.Size = UDim2.new(0, 75, 0, 26)
	valBox.Position = UDim2.new(1, -82, 0.5, -13)
	valBox.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
	valBox.BackgroundTransparency = isNum and 0 or 1
	valBox.Text = tostring(statObj.Value)
	valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	valBox.TextSize = 13
	valBox.Font = Enum.Font.GothamBold
	valBox.BorderSizePixel = 0
	if isNum then valBox.PlaceholderText = "0" end
	valBox.ClearTextOnFocus = false

	if isNum then
		Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 6)
		local vs = Instance.new("UIStroke", valBox)
		vs.Color = Color3.fromRGB(30, 215, 96)
		vs.Thickness = 1
		vs.Transparency = 0.5

		valBox.FocusLost:Connect(function(enter)
			if enter then
				local num = tonumber(valBox.Text)
				if num then
					statObj.Value = num
					vs.Transparency = 0
					task.delay(0.4, function() vs.Transparency = 0.5 end)
				else
					valBox.Text = tostring(statObj.Value)
				end
			end
		end)

		statObj.Changed:Connect(function(val)
			if not valBox:IsFocused() then
				valBox.Text = tostring(val)
			end
		end)
	end
end

local function loadStats(plr)
	for _, c in ipairs(StatsScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	NoStats.Parent = StatsScroll
	if not plr then return end
	local ls = plr:FindFirstChild("leaderstats")
	if not ls or #ls:GetChildren() == 0 then
		NoStats.Text = plr.Name .. (ls and ": sin stats" or ": sin leaderstats")
		return
	end
	NoStats.Parent = nil
	for i, stat in ipairs(ls:GetChildren()) do
		makeStatRow(stat.Name, stat, i)
	end
end

local function selectPlayer(plr, btn)
	selectedPlayer = plr
	for _, b in pairs(playerButtons) do
		b.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		b.TextColor3 = Color3.fromRGB(210, 210, 210)
	end
	btn.BackgroundColor3 = Color3.fromRGB(18, 50, 26)
	btn.TextColor3 = Color3.fromRGB(30, 215, 96)
	loadStats(plr)
end

local function addPlayer(plr)
	local btn = makePlayerBtn(plr)
	playerButtons[plr] = btn
	btn.MouseButton1Click:Connect(function() selectPlayer(plr, btn) end)
end

local function removePlayer(plr)
	if playerButtons[plr] then playerButtons[plr]:Destroy(); playerButtons[plr] = nil end
	if selectedPlayer == plr then
		selectedPlayer = nil
		loadStats(nil)
		NoStats.Text = "Selecciona un jugador..."
		NoStats.Parent = StatsScroll
	end
end

for _, plr in ipairs(Players:GetPlayers()) do addPlayer(plr) end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- ── Toggle ────────────────────────────────
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18, 160, 65) or Color3.fromRGB(30, 215, 96)
end)
CloseBtn.MouseButton1Click:Connect(function()
	open = false; Frame.Visible = false
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
end)
ToggleBtn.MouseEnter:Connect(function() ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 230, 110) end)
ToggleBtn.MouseLeave:Connect(function()
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(18, 160, 65) or Color3.fromRGB(30, 215, 96)
end)
