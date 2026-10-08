-- Editor de Objetos (compacto y moderno) - Delta Executor / Celular
-- Pestañas: Mover | Rotar | Escalar. Panel arrastrable y minimizable.
-- Los cambios son solo locales en tu cliente.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local old = LP:WaitForChild("PlayerGui"):FindFirstChild("StudioEditor")
if old then old:Destroy() end

-- ============================================================
-- TEMA
-- ============================================================
local C = {
	bg      = Color3.fromRGB(22, 24, 33),
	header  = Color3.fromRGB(30, 33, 45),
	card    = Color3.fromRGB(34, 37, 50),
	btn     = Color3.fromRGB(48, 52, 70),
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
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = textSize or 15,
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

-- Mantener presionado = repetir
local function bindHold(b, fn)
	local token = 0
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			token += 1
			local my = token
			fn()
			task.delay(0.35, function()
				while token == my do
					fn()
					task.wait(0.07)
				end
			end)
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			token += 1
		end
	end)
end

-- ============================================================
-- ESTADO
-- ============================================================
local sel, hl = nil, nil
local selecting = false
local moveStep, rotStep, scaleStep = 1, 15, 0.10
local camMode = true
local originals = {}

local function valid()
	return sel ~= nil and sel.Parent ~= nil
end

-- ============================================================
-- INTERFAZ
-- ============================================================
local gui = new("ScreenGui", {Name = "StudioEditor", ResetOnSpawn = false, IgnoreGuiInset = false}, LP.PlayerGui)

-- Botón flotante pequeño
local fab = button(gui, "🛠", UDim2.new(0, 38, 0, 38), UDim2.new(0, 8, 0.5, -19), C.accent, 18)
fab.ZIndex = 5
round(fab, 19)

-- Panel
local W, H_FULL, H_MIN = 250, 312, 36
local panel = new("Frame", {
	Size = UDim2.new(0, W, 0, H_FULL), Position = UDim2.new(0, 56, 0.5, -H_FULL/2),
	BackgroundColor3 = C.bg, BackgroundTransparency = 0.04, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(panel, 14)
new("UIStroke", {Color = Color3.fromRGB(70, 76, 105), Thickness = 1, Transparency = 0.4}, panel)

-- Escala automática según la pantalla
local uiScale = new("UIScale", {}, panel)
local function updateScale()
	local vp = workspace.CurrentCamera.ViewportSize
	uiScale.Scale = math.clamp(vp.Y / 430, 0.7, 1)
end
updateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

-- Header (arrastrable)
local header = new("Frame", {Size = UDim2.new(1, 0, 0, H_MIN), BackgroundColor3 = C.header, BorderSizePixel = 0}, panel)
label(header, "🛠  Editor de Objetos", UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), 13)
local minBtn = button(header, "–", UDim2.new(0, 28, 0, 24), UDim2.new(1, -66, 0, 6), C.btn, 16)
local closeBtn = button(header, "✕", UDim2.new(0, 28, 0, 24), UDim2.new(1, -34, 0, 6), C.danger, 12)

-- Cuerpo
local body = new("Frame", {Size = UDim2.new(1, -20, 1, -H_MIN - 8), Position = UDim2.new(0, 10, 0, H_MIN + 6), BackgroundTransparency = 1}, panel)

-- Info
local info = new("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(info, 8)
local infoName = label(info, "Ningún objeto seleccionado", UDim2.new(1, -16, 0, 16), UDim2.new(0, 8, 0, 3), 12)
local infoPos = label(info, "Pulsa Seleccionar y toca un objeto", UDim2.new(1, -16, 0, 14), UDim2.new(0, 8, 0, 18), 10, C.dim)

-- Pestañas
local tabNames = {"Mover", "Rotar", "Escalar"}
local tabBtns, tabFrames = {}, {}
for i, name in ipairs(tabNames) do
	tabBtns[name] = button(body, name, UDim2.new(0, 74, 0, 28), UDim2.new(0, (i-1)*78, 0, 40), C.btn, 12)
	tabFrames[name] = new("Frame", {Size = UDim2.new(1, 0, 0, 150), Position = UDim2.new(0, 0, 0, 74), BackgroundTransparency = 1, Visible = false}, body)
end
local function showTab(name)
	for n, f in pairs(tabFrames) do
		f.Visible = (n == name)
		local col = (n == name) and C.accent or C.btn
		tabBtns[n]:SetAttribute("base", col)
		TweenService:Create(tabBtns[n], TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
	end
end
for n, b in pairs(tabBtns) do b.MouseButton1Click:Connect(function() showTab(n) end) end

-- ============================================================
-- INFO / ACCIONES
-- ============================================================
local scaleInfo -- se define en la pestaña Escalar

local function refresh()
	if not valid() then
		infoName.Text = "Ningún objeto seleccionado"
		infoPos.Text = "Pulsa Seleccionar y toca un objeto"
		if scaleInfo then scaleInfo.Text = "" end
		return
	end
	local p = sel:GetPivot().Position
	infoName.Text = sel.Name .. "  ·  " .. sel.ClassName
	infoPos.Text = string.format("X %.1f   Y %.1f   Z %.1f", p.X, p.Y, p.Z)
	if scaleInfo then
		if sel:IsA("Model") then
			scaleInfo.Text = string.format("Escala actual: %.2fx", sel:GetScale())
		elseif sel:IsA("BasePart") then
			scaleInfo.Text = string.format("Tamaño: %.1f, %.1f, %.1f", sel.Size.X, sel.Size.Y, sel.Size.Z)
		end
	end
end

local function select_(obj)
	if hl then hl:Destroy() hl = nil end
	sel = obj
	if not obj then refresh() return end
	hl = new("Highlight", {
		FillColor = C.good, OutlineColor = Color3.new(1,1,1), FillTransparency = 0.55,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
	}, obj)
	if not originals[obj] then
		originals[obj] = {
			pivot = obj:GetPivot(),
			size = obj:IsA("BasePart") and obj.Size or nil,
			scale = obj:IsA("Model") and obj:GetScale() or nil,
		}
	end
	refresh()
end

local function dir(name)
	local f, r
	if camMode then
		local look = workspace.CurrentCamera.CFrame.LookVector
		f = Vector3.new(look.X, 0, look.Z)
		f = (f.Magnitude < 0.01) and Vector3.new(0, 0, -1) or f.Unit
	else
		f = Vector3.new(0, 0, -1)
	end
	r = f:Cross(Vector3.yAxis)
	if name == "fwd" then return f
	elseif name == "back" then return -f
	elseif name == "right" then return r
	elseif name == "left" then return -r
	elseif name == "up" then return Vector3.yAxis
	elseif name == "down" then return -Vector3.yAxis end
	return Vector3.zero
end

local function move(name)
	if not valid() then return end
	sel:PivotTo(sel:GetPivot() + dir(name) * moveStep)
	refresh()
end

local function rotate(axis, sign)
	if not valid() then return end
	local a = math.rad(rotStep * sign)
	local rot = (axis == "x" and CFrame.Angles(a, 0, 0)) or (axis == "y" and CFrame.Angles(0, a, 0)) or CFrame.Angles(0, 0, a)
	sel:PivotTo(sel:GetPivot() * rot)
	refresh()
end

local function scale(sign)
	if not valid() then return end
	local f = 1 + scaleStep * sign
	if sel:IsA("Model") then
		sel:ScaleTo(math.clamp(sel:GetScale() * f, 0.05, 200))
	elseif sel:IsA("BasePart") then
		local s = sel.Size * f
		sel.Size = Vector3.new(math.max(0.05, s.X), math.max(0.05, s.Y), math.max(0.05, s.Z))
	end
	refresh()
end

local function resetAll()
	if not valid() then return end
	local o = originals[sel]
	if not o then return end
	if o.size then sel.Size = o.size end
	if o.scale then sel:ScaleTo(o.scale) end
	sel:PivotTo(o.pivot)
	refresh()
end

-- Selector de valores (chips)
local function chips(parent, y, options, fmt, default, onPick)
	local n = #options
	local gap = 6
	local w = (230 - gap * (n - 1)) / n
	local list = {}
	local function paint(active)
		for _, c in ipairs(list) do
			local col = (c.value == active) and C.accent or C.btn
			c.btn:SetAttribute("base", col)
			TweenService:Create(c.btn, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
		end
	end
	for i, v in ipairs(options) do
		local b = button(parent, fmt(v), UDim2.new(0, w, 0, 24), UDim2.new(0, (i-1)*(w+gap), 0, y), C.btn, 11)
		table.insert(list, {btn = b, value = v})
		b.MouseButton1Click:Connect(function() onPick(v) paint(v) end)
	end
	paint(default)
end

-- ============================================================
-- PESTAÑA MOVER
-- ============================================================
do
	local f = tabFrames["Mover"]
	local S = UDim2.new(0, 44, 0, 44)
	local bUp   = button(f, "↑", S, UDim2.new(0, 50, 0, 0), C.accent, 20)
	local bLeft = button(f, "←", S, UDim2.new(0, 0, 0, 48), C.accent, 20)
	local bDown = button(f, "↓", S, UDim2.new(0, 50, 0, 48), C.accent, 20)
	local bRight= button(f, "→", S, UDim2.new(0, 100, 0, 48), C.accent, 20)
	bindHold(bUp, function() move("fwd") end)
	bindHold(bDown, function() move("back") end)
	bindHold(bLeft, function() move("left") end)
	bindHold(bRight, function() move("right") end)

	label(f, "Altura", UDim2.new(0, 70, 0, 12), UDim2.new(0, 160, 0, -2), 10, C.dim, Enum.TextXAlignment.Center)
	local bHi = button(f, "▲ Subir", UDim2.new(0, 70, 0, 38), UDim2.new(0, 160, 0, 12), C.good, 12)
	local bLo = button(f, "▼ Bajar", UDim2.new(0, 70, 0, 38), UDim2.new(0, 160, 0, 54), C.good, 12)
	bindHold(bHi, function() move("up") end)
	bindHold(bLo, function() move("down") end)

	chips(f, 100, {0.5, 1, 5, 10}, function(v) return v .. " st" end, moveStep, function(v) moveStep = v end)

	local camBtn = button(f, "Dirección: según cámara", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 128), C.btn, 11)
	camBtn.MouseButton1Click:Connect(function()
		camMode = not camMode
		camBtn.Text = camMode and "Dirección: según cámara" or "Dirección: ejes del mundo"
	end)
end

-- ============================================================
-- PESTAÑA ROTAR
-- ============================================================
do
	local f = tabFrames["Rotar"]
	for i, ax in ipairs({"x", "y", "z"}) do
		local y = (i-1) * 36
		label(f, ax:upper(), UDim2.new(0, 40, 0, 32), UDim2.new(0, 0, 0, y), 14, C.warn, Enum.TextXAlignment.Center)
		local m = button(f, "−", UDim2.new(0, 86, 0, 32), UDim2.new(0, 46, 0, y), C.btn, 18)
		local p = button(f, "+", UDim2.new(0, 94, 0, 32), UDim2.new(0, 136, 0, y), C.warn, 18)
		bindHold(m, function() rotate(ax, -1) end)
		bindHold(p, function() rotate(ax, 1) end)
	end
	chips(f, 114, {5, 15, 45, 90}, function(v) return v .. "°" end, rotStep, function(v) rotStep = v end)
end

-- ============================================================
-- PESTAÑA ESCALAR
-- ============================================================
do
	local f = tabFrames["Escalar"]
	local m = button(f, "−  Reducir", UDim2.new(0, 112, 0, 52), UDim2.new(0, 0, 0, 0), C.btn, 14)
	local p = button(f, "+  Agrandar", UDim2.new(0, 112, 0, 52), UDim2.new(0, 118, 0, 0), C.good, 14)
	bindHold(m, function() scale(-1) end)
	bindHold(p, function() scale(1) end)
	chips(f, 62, {0.05, 0.10, 0.25, 0.50}, function(v) return math.floor(v * 100) .. "%" end, scaleStep, function(v) scaleStep = v end)
	scaleInfo = label(f, "", UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 96), 11, C.dim, Enum.TextXAlignment.Center)
end

-- ============================================================
-- BARRA INFERIOR
-- ============================================================
local selBtn = button(body, "Seleccionar", UDim2.new(0, 130, 0, 34), UDim2.new(0, 0, 0, 232), C.good, 13)
local parBtn = button(body, "Padre", UDim2.new(0, 44, 0, 34), UDim2.new(0, 136, 0, 232), C.btn, 10)
local rstBtn = button(body, "Reset", UDim2.new(0, 44, 0, 34), UDim2.new(0, 186, 0, 232), C.danger, 10)
-- (130 + 6 + 44 + 6 + 44 = 230)

local function setSelecting(v)
	selecting = v
	selBtn.Text = v and "Toca un objeto…" or "Seleccionar"
	local col = v and C.warn or C.good
	selBtn:SetAttribute("base", col)
	TweenService:Create(selBtn, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
end

selBtn.MouseButton1Click:Connect(function() setSelecting(not selecting) end)

parBtn.MouseButton1Click:Connect(function()
	if valid() and sel.Parent and sel.Parent ~= workspace and sel.Parent:IsA("Model") then
		select_(sel.Parent)
	end
end)

rstBtn.MouseButton1Click:Connect(resetAll)

-- ============================================================
-- SELECCIÓN POR TOQUE
-- ============================================================
UIS.InputBegan:Connect(function(input, processed)
	if processed or not selecting then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local cam = workspace.CurrentCamera
		local ray = cam:ScreenPointToRay(input.Position.X, input.Position.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LP.Character}
		local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
		if res and res.Instance then
			select_(res.Instance)
			setSelecting(false)
		end
	end
end)

-- ============================================================
-- ARRASTRAR / MINIMIZAR / CERRAR
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

local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	minBtn.Text = minimized and "+" or "–"
	TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, W, 0, minimized and H_MIN or H_FULL)
	}):Play()
end)

closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)
fab.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

showTab("Mover")
refresh()
print("[StudioEditor] Listo. Usa 🛠 para abrir/cerrar. Cambios solo locales.")
