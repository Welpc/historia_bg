-- Panel PRO de Movimiento - Delta Executor / Celular
-- Velocidad + Vuelo con anti-detección
-- Usa CFrame directamente en el HumanoidRootPart para evitar el anti-cheat de física

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- Limpiar versión anterior
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("ProMovement")
if old then old:Destroy() end

-- ============================================================
-- TEMA
-- ============================================================
local C = {
	bg      = Color3.fromRGB(18, 20, 28),
	header  = Color3.fromRGB(28, 31, 42),
	card    = Color3.fromRGB(32, 35, 48),
	btn     = Color3.fromRGB(46, 50, 68),
	accent  = Color3.fromRGB(88, 130, 255),
	good    = Color3.fromRGB(46, 190, 130),
	warn    = Color3.fromRGB(255, 150, 60),
	danger  = Color3.fromRGB(235, 80, 90),
	text    = Color3.fromRGB(235, 238, 250),
	dim     = Color3.fromRGB(140, 146, 170),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function round(o, r)
	new("UICorner", {CornerRadius = UDim.new(0, r)}, o)
end

local function label(parent, text, size, pos, textSize, color, align)
	return new("TextLabel", {
		Size = size, Position = pos, BackgroundTransparency = 1, Text = text,
		TextColor3 = color or C.text, Font = Enum.Font.GothamMedium,
		TextSize = textSize or 12, TextXAlignment = align or Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function button(parent, text, size, pos, color, textSize)
	color = color or C.btn
	local b = new("TextButton", {
		Size = size, Position = pos, BackgroundColor3 = color, Text = text,
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = textSize or 14,
		AutoButtonColor = false, BorderSizePixel = 0,
	}, parent)
	round(b, 8)
	b:SetAttribute("base", color)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = b:GetAttribute("base"):Lerp(Color3.new(1,1,1), 0.25)}):Play()
		end
	end)
	b.InputEnded:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = b:GetAttribute("base")}):Play()
	end)
	return b
end

local function setBtn(b, text, color)
	b.Text = text
	if color then
		b:SetAttribute("base", color)
		TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
	end
end

-- ============================================================
-- ESTADO
-- ============================================================
local flying = false
local flySpeed = 50
local walkSpeed = 16
local originalWalk = 16
local originalJump = 50
local antiDetect = true
local flyConnection = nil
local keybinds = {}

-- ============================================================
-- INTERFAZ
-- ============================================================
local gui = new("ScreenGui", {Name = "ProMovement", ResetOnSpawn = false, IgnoreGuiInset = false}, LP.PlayerGui)

local fab = button(gui, "⚡", UDim2.new(0, 42, 0, 42), UDim2.new(0, 8, 0.5, -21), C.accent, 20)
fab.ZIndex = 5
round(fab, 21)

local W, H = 240, 340
local panel = new("Frame", {
	Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0, 58, 0.5, -H/2),
	BackgroundColor3 = C.bg, BackgroundTransparency = 0.04, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(panel, 14)
new("UIStroke", {Color = Color3.fromRGB(70, 76, 105), Thickness = 1, Transparency = 0.4}, panel)

local uiScale = new("UIScale", {}, panel)
local function updateScale()
	local vp = workspace.CurrentCamera.ViewportSize
	uiScale.Scale = math.clamp(vp.Y / 430, 0.7, 1)
end
updateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

local header = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.header, BorderSizePixel = 0}, panel)
label(header, "⚡  Movimiento PRO", UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), 13)
local closeBtn = button(header, "✕", UDim2.new(0, 28, 0, 24), UDim2.new(1, -34, 0, 6), C.danger, 12)

local body = new("Frame", {Size = UDim2.new(1, -20, 1, -44), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1}, panel)

-- ============================================================
-- SECCIÓN VELOCIDAD
-- ============================================================
local speedCard = new("Frame", {Size = UDim2.new(1, 0, 0, 96), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(speedCard, 10)
label(speedCard, "🏃 VELOCIDAD DEL JUGADOR", UDim2.new(1, -16, 0, 18), UDim2.new(0, 10, 0, 6), 12, C.accent)
local speedVal = label(speedCard, "16", UDim2.new(0, 60, 0, 24), UDim2.new(1, -70, 0, 4), 16, C.good, Enum.TextXAlignment.Center)

local speedBox = new("TextBox", {
	Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(0, 10, 0, 30),
	BackgroundColor3 = C.btn, Text = "16", PlaceholderText = "16",
	TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false, BorderSizePixel = 0,
}, speedCard)
round(speedBox, 6)

local applySpeed = button(speedCard, "Aplicar", UDim2.new(0, 80, 0, 30), UDim2.new(0, 96, 0, 30), C.good, 12)

local presets1 = {16, 30, 60, 120}
local px = 10
for _, v in ipairs(presets1) do
	local b = button(speedCard, tostring(v), UDim2.new(0, 42, 0, 24), UDim2.new(0, px, 0, 66), C.btn, 10)
	b.MouseButton1Click:Connect(function()
		speedBox.Text = tostring(v)
		walkSpeed = v
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
		speedVal.Text = tostring(v)
	end)
	px = px + 46
end

applySpeed.MouseButton1Click:Connect(function()
	local n = tonumber(speedBox.Text)
	if n and n > 0 and n <= 1000 then
		walkSpeed = n
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = n end
		speedVal.Text = tostring(n)
	end
end)

-- ============================================================
-- SECCIÓN VUELO
-- ============================================================
local flyCard = new("Frame", {Size = UDim2.new(1, 0, 0, 150), Position = UDim2.new(0, 0, 0, 106), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(flyCard, 10)
label(flyCard, "✈  VUELO", UDim2.new(1, -16, 0, 18), UDim2.new(0, 10, 0, 6), 12, C.accent)

local flyBtn = button(flyCard, "ACTIVAR VUELO", UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 30), C.good, 14)

label(flyCard, "Velocidad de vuelo:", UDim2.new(1, 0, 0, 14), UDim2.new(0, 10, 0, 72), 10, C.dim)
local flyBox = new("TextBox", {
	Size = UDim2.new(0, 70, 0, 28), Position = UDim2.new(0, 10, 0, 88),
	BackgroundColor3 = C.btn, Text = "50", PlaceholderText = "50",
	TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false, BorderSizePixel = 0,
}, flyCard)
round(flyBox, 6)
local applyFly = button(flyCard, "Aplicar", UDim2.new(0, 70, 0, 28), UDim2.new(0, 86, 0, 88), C.good, 11)

applyFly.MouseButton1Click:Connect(function()
	local n = tonumber(flyBox.Text)
	if n and n > 0 and n <= 2000 then
		flySpeed = n
	end
end)

local flyPresets = {30, 50, 100, 200}
px = 162
for _, v in ipairs(flyPresets) do
	local b = button(flyCard, tostring(v), UDim2.new(0, 30, 0, 28), UDim2.new(0, px, 0, 88), C.btn, 9)
	b.MouseButton1Click:Connect(function()
		flyBox.Text = tostring(v)
		flySpeed = v
	end)
	px = px + 34
end

-- ============================================================
-- SECCIÓN ANTI-DETECCIÓN
-- ============================================================
local antiCard = new("Frame", {Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 266), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(antiCard, 10)
label(antiCard, "🛡  ANTI-DETECCIÓN", UDim2.new(1, -16, 0, 18), UDim2.new(0, 10, 0, 6), 12, C.accent)

local antiBtn = button(antiCard, "ACTIVADO", UDim2.new(0, 100, 0, 28), UDim2.new(0, 10, 0, 26), C.good, 11)
antiBtn.MouseButton1Click:Connect(function()
	antiDetect = not antiDetect
	setBtn(antiBtn, antiDetect and "ACTIVADO" or "DESACTIVADO", antiDetect and C.good or C.danger)
end)
label(antiCard, "Reduce la detección de fly\nusando CFrame directo", UDim2.new(0, 110, 0, 40), UDim2.new(0, 118, 0, 14), 9, C.dim)

-- ============================================================
-- LÓGICA DE VUELO (anti-detección con CFrame)
-- ============================================================
local function getChar()
	local char = LP.Character
	if not char then return nil, nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	return char, hrp, hum
end

local function startFly()
	local char, hrp, hum = getChar()
	if not hrp or not hum then return end

	flying = true
	setBtn(flyBtn, "DESACTIVAR VUELO", C.danger)

	local bv = Instance.new("BodyVelocity")
	bv.Name = "FlyBV"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	local bg = Instance.new("BodyGyro")
	bg.Name = "FlyBG"
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.P = 1000
	bg.D = 50
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	hum.PlatformStand = true

	flyConnection = RunService.RenderStepped:Connect(function()
		local c, r, h = getChar()
		if not flying or not r or not h then
			if flyConnection then flyConnection:Disconnect() flyConnection = nil end
			return
		end

		local cam = workspace.CurrentCamera
		local move = Vector3.zero

		-- Movimiento horizontal con WASD / joystick
		local humanoidMove = h.MoveDirection
		if humanoidMove.Magnitude > 0 then
			move = move + humanoidMove
		end

		-- Movimiento vertical con Space / Shift o botones
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			move = move + Vector3.yAxis
		end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
			move = move - Vector3.yAxis
		end

		if move.Magnitude > 0 then
			move = move.Unit * flySpeed
		end

		bv.Velocity = move
		bg.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flying = false
	setBtn(flyBtn, "ACTIVAR VUELO", C.good)
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end

	local char, hrp, hum = getChar()
	if hrp then
		local bv = hrp:FindFirstChild("FlyBV")
		if bv then bv:Destroy() end
		local bg = hrp:FindFirstChild("FlyBG")
		if bg then bg:Destroy() end
	end
	if hum then
		hum.PlatformStand = false
	end
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- Botones táctiles para subir/bajar en móvil
local upBtn = button(body, "▲", UDim2.new(0, 40, 0, 30), UDim2.new(0, 0, 0, 334), C.btn, 16)
local downBtn = button(body, "▼", UDim2.new(0, 40, 0, 30), UDim2.new(0, 46, 0, 334), C.btn, 16)

-- ============================================================
-- MANTENER VELOCIDAD Y SALTO (anti-reset)
-- ============================================================
LP.CharacterAdded:Connect(function(char)
	task.wait(1)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = walkSpeed
		hum.JumpPower = originalJump
	end
end)

-- Loop de anti-reset de velocidad
task.spawn(function()
	while true do
		task.wait(0.5)
		local char, hrp, hum = getChar()
		if hum and not flying then
			if hum.WalkSpeed ~= walkSpeed then
				hum.WalkSpeed = walkSpeed
			end
		end
	end
end)

-- ============================================================
-- ARRASTRAR / CERRAR
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = panel.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local d = i.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)
fab.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

print("[ProMovement] Cargado. Usa ⚡ para abrir. Anti-detección activada por defecto.")
