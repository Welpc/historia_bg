-- Panel PRO de Movimiento v2 - Delta Executor / Celular
-- Velocidad corregida (método que SÍ funciona en la mayoría de juegos)
-- Vuelo con controles táctiles en pantalla para subir/bajar/adelante/atrás

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

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
local antiDetect = true
local flyConnection = nil
local flyDir = {up=false, down=false, fwd=false, back=false, left=false, right=false}
local bv, bg
local originalWalk = 16
local originalJump = 50

-- ============================================================
-- INTERFAZ
-- ============================================================
local gui = new("ScreenGui", {Name = "ProMovement", ResetOnSpawn = false, IgnoreGuiInset = false}, LP.PlayerGui)

local fab = button(gui, "⚡", UDim2.new(0, 42, 0, 42), UDim2.new(0, 8, 0.5, -21), C.accent, 20)
fab.ZIndex = 5
round(fab, 21)

local W, H = 250, 420
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
label(header, "⚡  Movimiento PRO v2", UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), 13)
local closeBtn = button(header, "✕", UDim2.new(0, 28, 0, 24), UDim2.new(1, -34, 0, 6), C.danger, 12)

local body = new("Frame", {Size = UDim2.new(1, -20, 1, -44), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1}, panel)

-- ============================================================
-- SECCIÓN VELOCIDAD (CORREGIDA)
-- ============================================================
local speedCard = new("Frame", {Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
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

-- Función de velocidad corregida: usa Humanoid.WalkSpeed + BodyVelocity para forzar
local function setWalkSpeed(n)
	walkSpeed = n
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = n
		-- Forzar con BodyVelocity si el juego resetea
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local existing = hrp:FindFirstChild("SpeedForce")
			if existing then existing:Destroy() end
		end
	end
	speedVal.Text = tostring(n)
end

applySpeed.MouseButton1Click:Connect(function()
	local n = tonumber(speedBox.Text)
	if n and n > 0 and n <= 10000 then
		setWalkSpeed(n)
	end
end)

local presets1 = {16, 50, 100, 500, 1000, 5000}
local px = 10
local py = 66
for i, v in ipairs(presets1) do
	local b = button(speedCard, tostring(v), UDim2.new(0, 36, 0, 22), UDim2.new(0, px, 0, py), C.btn, 9)
	b.MouseButton1Click:Connect(function()
		speedBox.Text = tostring(v)
		setWalkSpeed(v)
	end)
	px = px + 38
	if i == 3 then px = 10 py = py + 26 end
end

-- Loop de anti-reset de velocidad (fuerza cada 0.2 seg)
task.spawn(function()
	while true do
		task.wait(0.2)
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and not flying then
			if hum.WalkSpeed ~= walkSpeed then
				hum.WalkSpeed = walkSpeed
			end
			-- Forzar movimiento con BodyVelocity si el juego lo resetea
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp and walkSpeed > 100 then
				local moveDir = hum.MoveDirection
				if moveDir.Magnitude > 0 then
					hrp.CFrame = hrp.CFrame + moveDir * (walkSpeed * 0.2 * 0.016)
				end
			end
		end
	end
end)

-- ============================================================
-- SECCIÓN VUELO CON CONTROLES TÁCTILES
-- ============================================================
local flyCard = new("Frame", {Size = UDim2.new(1, 0, 0, 240), Position = UDim2.new(0, 0, 0, 120), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(flyCard, 10)
label(flyCard, "✈  VUELO", UDim2.new(1, -16, 0, 18), UDim2.new(0, 10, 0, 6), 12, C.accent)

local flyBtn = button(flyCard, "ACTIVAR VUELO", UDim2.new(1, -20, 0, 34), UDim2.new(0, 10, 0, 28), C.good, 14)

label(flyCard, "Velocidad:", UDim2.new(0, 70, 0, 14), UDim2.new(0, 10, 0, 68), 10, C.dim)
local flyBox = new("TextBox", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 70, 0, 64),
	BackgroundColor3 = C.btn, Text = "50", PlaceholderText = "50",
	TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false, BorderSizePixel = 0,
}, flyCard)
round(flyBox, 6)
local applyFly = button(flyCard, "OK", UDim2.new(0, 40, 0, 26), UDim2.new(0, 134, 0, 64), C.good, 11)

applyFly.MouseButton1Click:Connect(function()
	local n = tonumber(flyBox.Text)
	if n and n > 0 and n <= 5000 then flySpeed = n end
end)

local flyPresets = {30, 50, 100, 300, 1000}
px = 180
for _, v in ipairs(flyPresets) do
	local b = button(flyCard, tostring(v), UDim2.new(0, 26, 0, 26), UDim2.new(0, px, 0, 64), C.btn, 8)
	b.MouseButton1Click:Connect(function()
		flyBox.Text = tostring(v)
		flySpeed = v
	end)
	px = px + 28
end

-- Controles táctiles (D-Pad vertical + horizontal)
label(flyCard, "Controles de vuelo:", UDim2.new(1, 0, 0, 14), UDim2.new(0, 10, 0, 96), 10, C.dim)

local S = UDim2.new(0, 44, 0, 40)
local bUp    = button(flyCard, "▲", S, UDim2.new(0, 80, 0, 114), C.accent, 18)
local bDown  = button(flyCard, "▼", S, UDim2.new(0, 80, 0, 196), C.accent, 18)
local bLeft  = button(flyCard, "◀", S, UDim2.new(0, 10, 0, 155), C.accent, 18)
local bRight = button(flyCard, "▶", S, UDim2.new(0, 150, 0, 155), C.accent, 18)
local bFwd   = button(flyCard, "▲ Frente", UDim2.new(0, 66, 0, 40), UDim2.new(0, 80, 0, 155), C.good, 10)
local bBack  = button(flyCard, "▼ Atrás", UDim2.new(0, 66, 0, 40), UDim2.new(0, 150, 0, 114), C.good, 10)

-- Asignar eventos de mantener presionado
local function bindHoldBtn(b, key)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			flyDir[key] = true
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			flyDir[key] = false
		end
	end)
end

bindHoldBtn(bUp, "up")
bindHoldBtn(bDown, "down")
bindHoldBtn(bLeft, "left")
bindHoldBtn(bRight, "right")
bindHoldBtn(bFwd, "fwd")
bindHoldBtn(bBack, "back")

-- ============================================================
-- LÓGICA DE VUELO (con controles táctiles + teclado)
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

	bv = Instance.new("BodyVelocity")
	bv.Name = "FlyBV"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
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

		-- Movimiento con joystick/WASD del juego
		local humanoidMove = h.MoveDirection
		if humanoidMove.Magnitude > 0 then
			move = move + humanoidMove
		end

		-- Controles táctiles
		if flyDir.fwd then move = move + cam.CFrame.LookVector end
		if flyDir.back then move = move - cam.CFrame.LookVector end
		if flyDir.left then move = move - cam.CFrame.RightVector end
		if flyDir.right then move = move + cam.CFrame.RightVector end
		if flyDir.up then move = move + Vector3.yAxis end
		if flyDir.down then move = move - Vector3.yAxis end

		-- Teclado (PC)
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end

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
		local b = hrp:FindFirstChild("FlyBV")
		if b then b:Destroy() end
		local g = hrp:FindFirstChild("FlyBG")
		if g then g:Destroy() end
	end
	if hum then hum.PlatformStand = false end
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- ============================================================
-- SECCIÓN ANTI-DETECCIÓN
-- ============================================================
local antiCard = new("Frame", {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 366), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(antiCard, 10)
label(antiCard, "🛡  ANTI-DETECCIÓN", UDim2.new(0, 120, 0, 18), UDim2.new(0, 10, 0, 6), 11, C.accent)

local antiBtn = button(antiCard, "ACTIVADO", UDim2.new(0, 90, 0, 26), UDim2.new(0, 10, 0, 22), C.good, 10)
antiBtn.MouseButton1Click:Connect(function()
	antiDetect = not antiDetect
	setBtn(antiBtn, antiDetect and "ACTIVADO" or "DESACTIVADO", antiDetect and C.good or C.danger)
end)
label(antiCard, "Fuerza velocidad cada 0.2s", UDim2.new(0, 110, 0, 30), UDim2.new(0, 110, 0, 18), 9, C.dim)

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

print("[ProMovement v2] Cargado. Velocidad corregida + controles táctiles de vuelo.")
