-- LeaderstatsEditor LocalScript
-- Pon este script en StarterPlayerScripts o StarterGui > ScreenGui

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
--  CREAR LA GUI
-- ══════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaderstatsEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ── Botón flotante para abrir/cerrar ──────
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 54, 0, 54)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)   -- verde spotify
ToggleBtn.Text = "💰"
ToggleBtn.TextSize = 26
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(1, 0)
TBCorner.Parent = ToggleBtn

local TBShadow = Instance.new("UIStroke")
TBShadow.Color = Color3.fromRGB(0, 180, 60)
TBShadow.Thickness = 2
TBShadow.Parent = ToggleBtn

-- ── Panel principal ───────────────────────
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 340, 0, 480)
Frame.Position = UDim2.new(0, 84, 0.5, -240)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

local FCorner = Instance.new("UICorner")
FCorner.CornerRadius = UDim.new(0, 16)
FCorner.Parent = Frame

local FStroke = Instance.new("UIStroke")
FStroke.Color = Color3.fromRGB(30, 215, 96)
FStroke.Thickness = 1.5
FStroke.Parent = Frame

-- Glow decoration top
local GlowBar = Instance.new("Frame")
GlowBar.Size = UDim2.new(1, 0, 0, 3)
GlowBar.Position = UDim2.new(0, 0, 0, 0)
GlowBar.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
GlowBar.BorderSizePixel = 0
GlowBar.Parent = Frame
local GBCorner = Instance.new("UICorner")
GBCorner.CornerRadius = UDim.new(0, 16)
GBCorner.Parent = GlowBar

-- ── Header ────────────────────────────────
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Leaderstats Editor"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(1, 0)
CBCorner.Parent = CloseBtn

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 56)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Divider.BorderSizePixel = 0
Divider.Parent = Frame

-- ── Selector de Player ────────────────────
local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Size = UDim2.new(1, -32, 0, 20)
PlayerLabel.Position = UDim2.new(0, 16, 0, 68)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "JUGADOR"
PlayerLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
PlayerLabel.TextSize = 10
PlayerLabel.Font = Enum.Font.GothamBold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerLabel.Parent = Frame

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -32, 0, 100)
PlayerScroll.Position = UDim2.new(0, 16, 0, 90)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.Parent = Frame
local PSCorner = Instance.new("UICorner")
PSCorner.CornerRadius = UDim.new(0, 10)
PSCorner.Parent = PlayerScroll
local PSLayout = Instance.new("UIListLayout")
PSLayout.SortOrder = Enum.SortOrder.Name
PSLayout.Padding = UDim.new(0, 4)
PSLayout.Parent = PlayerScroll
local PSPad = Instance.new("UIPadding")
PSPad.PaddingTop = UDim.new(0, 6)
PSPad.PaddingLeft = UDim.new(0, 6)
PSPad.PaddingRight = UDim.new(0, 6)
PSPad.Parent = PlayerScroll

-- ── Sección de Stats ──────────────────────
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -32, 0, 20)
StatsLabel.Position = UDim2.new(0, 16, 0, 202)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "LEADERSTATS"
StatsLabel.TextColor3 = Color3.fromRGB(30, 215, 96)
StatsLabel.TextSize = 10
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = Frame

local StatsScroll = Instance.new("ScrollingFrame")
StatsScroll.Size = UDim2.new(1, -32, 0, 220)
StatsScroll.Position = UDim2.new(0, 16, 0, 224)
StatsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatsScroll.BorderSizePixel = 0
StatsScroll.ScrollBarThickness = 3
StatsScroll.ScrollBarImageColor3 = Color3.fromRGB(30, 215, 96)
StatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
StatsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
StatsScroll.Parent = Frame
local SSCorner = Instance.new("UICorner")
SSCorner.CornerRadius = UDim.new(0, 10)
SSCorner.Parent = StatsScroll
local SSLayout = Instance.new("UIListLayout")
SSLayout.SortOrder = Enum.SortOrder.LayoutOrder
SSLayout.Padding = UDim.new(0, 6)
SSLayout.Parent = StatsScroll
local SSPad = Instance.new("UIPadding")
SSPad.PaddingTop = UDim.new(0, 8)
SSPad.PaddingLeft = UDim.new(0, 8)
SSPad.PaddingRight = UDim.new(0, 8)
SSPad.Parent = StatsScroll

-- Mensaje cuando no hay stats
local NoStats = Instance.new("TextLabel")
NoStats.Size = UDim2.new(1, 0, 0, 40)
NoStats.BackgroundTransparency = 1
NoStats.Text = "Selecciona un jugador..."
NoStats.TextColor3 = Color3.fromRGB(100, 100, 120)
NoStats.TextSize = 13
NoStats.Font = Enum.Font.Gotham
NoStats.Parent = StatsScroll

-- ══════════════════════════════════════════
--  LÓGICA
-- ══════════════════════════════════════════

local selectedPlayer = nil
local playerButtons = {}

-- Helper: crear botón de jugador
local function makePlayerBtn(plr)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	btn.Text = "👤  " .. plr.Name
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = PlayerScroll

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 8)
	bc.Parent = btn

	local bp = Instance.new("UIPadding")
	bp.PaddingLeft = UDim.new(0, 10)
	bp.Parent = btn

	return btn
end

-- Helper: crear fila de stat editable
local function makeStatRow(statName, statObj, index)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 52)
	row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
	row.BorderSizePixel = 0
	row.LayoutOrder = index
	row.Parent = StatsScroll

	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0, 10)
	rc.Parent = row

	-- Nombre del stat
	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(0.45, 0, 0, 20)
	nameL.Position = UDim2.new(0, 10, 0, 6)
	nameL.BackgroundTransparency = 1
	nameL.Text = statName
	nameL.TextColor3 = Color3.fromRGB(30, 215, 96)
	nameL.TextSize = 12
	nameL.Font = Enum.Font.GothamBold
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.Parent = row

	-- Tipo
	local typeL = Instance.new("TextLabel")
	typeL.Size = UDim2.new(0.45, 0, 0, 16)
	typeL.Position = UDim2.new(0, 10, 0, 28)
	typeL.BackgroundTransparency = 1
	typeL.Text = statObj.ClassName
	typeL.TextColor3 = Color3.fromRGB(80, 80, 100)
	typeL.TextSize = 10
	typeL.Font = Enum.Font.Gotham
	typeL.TextXAlignment = Enum.TextXAlignment.Left
	typeL.Parent = row

	-- Campo de valor (solo editable si es número)
	local isNum = statObj:IsA("IntValue") or statObj:IsA("NumberValue")

	local valBox = Instance.new(isNum and "TextBox" or "TextLabel")
	valBox.Size = UDim2.new(0, 90, 0, 30)
	valBox.Position = UDim2.new(1, -100, 0.5, -15)
	valBox.BackgroundColor3 = isNum and Color3.fromRGB(18, 18, 28) or Color3.fromRGB(0,0,0)
	valBox.BackgroundTransparency = isNum and 0 or 1
	valBox.Text = tostring(statObj.Value)
	valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	valBox.TextSize = 14
	valBox.Font = Enum.Font.GothamBold
	valBox.BorderSizePixel = 0
	valBox.PlaceholderText = "valor"
	valBox.ClearTextOnFocus = false
	valBox.Parent = row

	if isNum then
		local vc = Instance.new("UICorner")
		vc.CornerRadius = UDim.new(0, 8)
		vc.Parent = valBox

		local vs = Instance.new("UIStroke")
		vs.Color = Color3.fromRGB(30, 215, 96)
		vs.Thickness = 1
		vs.Transparency = 0.6
		vs.Parent = valBox

		-- Actualizar cuando se escribe y se presiona Enter
		valBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local num = tonumber(valBox.Text)
				if num then
					statObj.Value = num
					-- Feedback visual
					vs.Color = Color3.fromRGB(30, 215, 96)
					vs.Transparency = 0
					task.delay(0.5, function()
						vs.Transparency = 0.6
					end)
				else
					valBox.Text = tostring(statObj.Value)
				end
			end
		end)

		-- Mantener sync si cambia externamente
		statObj.Changed:Connect(function(val)
			if not valBox:IsFocused() then
				valBox.Text = tostring(val)
			end
		end)
	end

	return row
end

-- Cargar stats del jugador seleccionado
local function loadStats(plr)
	-- Limpiar
	for _, c in ipairs(StatsScroll:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextLabel") and c ~= NoStats then
			c:Destroy()
		end
	end
	NoStats.Parent = StatsScroll

	if not plr then return end

	local ls = plr:FindFirstChild("leaderstats")
	if not ls then
		NoStats.Text = plr.Name .. " no tiene leaderstats"
		return
	end

	local children = ls:GetChildren()
	if #children == 0 then
		NoStats.Text = "leaderstats vacío"
		return
	end

	NoStats.Parent = nil

	for i, stat in ipairs(children) do
		makeStatRow(stat.Name, stat, i)
	end
end

-- Resaltar botón seleccionado
local function selectPlayer(plr, btn)
	selectedPlayer = plr
	for _, b in pairs(playerButtons) do
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
		b.TextColor3 = Color3.fromRGB(220, 220, 220)
	end
	btn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
	btn.TextColor3 = Color3.fromRGB(30, 215, 96)
	loadStats(plr)
end

-- Poblar lista de jugadores
local function addPlayer(plr)
	local btn = makePlayerBtn(plr)
	playerButtons[plr] = btn
	btn.MouseButton1Click:Connect(function()
		selectPlayer(plr, btn)
	end)
end

local function removePlayer(plr)
	if playerButtons[plr] then
		playerButtons[plr]:Destroy()
		playerButtons[plr] = nil
	end
	if selectedPlayer == plr then
		selectedPlayer = nil
		loadStats(nil)
		NoStats.Text = "Selecciona un jugador..."
		NoStats.Parent = StatsScroll
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	addPlayer(plr)
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- ── Toggle visibilidad ────────────────────
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
	open = not open
	Frame.Visible = open
	ToggleBtn.BackgroundColor3 = open
		and Color3.fromRGB(20, 160, 70)
		or  Color3.fromRGB(30, 215, 96)
end)

CloseBtn.MouseButton1Click:Connect(function()
	open = false
	Frame.Visible = false
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
end)

-- Hover effects
ToggleBtn.MouseEnter:Connect(function()
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 230, 110)
end)
ToggleBtn.MouseLeave:Connect(function()
	ToggleBtn.BackgroundColor3 = open and Color3.fromRGB(20, 160, 70) or Color3.fromRGB(30, 215, 96)
end)
