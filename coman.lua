--=============================================================
--  VUELO + VELOCIDAD SIGILOSOS  —  MOVIL / DELTA EXECUTOR
--  Hecho por Venice
---------------------------------------------------------------
--  PANEL TACTIL (se arrastra desde la barra superior)
--    [VUELO]   -> ON / OFF
--    [SPEED]   -> ON / OFF
--    [-] [+]   -> velocidad de vuelo
--    [-] [+]   -> velocidad al caminar
--    [—]       -> minimizar panel      [V] -> ocultar todo
--
--  CONTROLES MOVIL
--    Joystick del juego -> moverte (adelante/atras/lados)
--    ▲ / ▼              -> subir / bajar
--
--  TECLADO (por si juegas con mando/teclado)
--    F vuelo | G speed | Espacio / Shift subir-bajar
--    + / - velocidad vuelo | [ / ] velocidad correr
--=============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer

-- ================== CONFIGURACION ==================
local CONFIG = {
	-- "BodyVelocity" = estable | "CFrame" = CERO instancias en el personaje
	MetodoVuelo       = "BodyVelocity",

	VelocidadVuelo    = 60,    -- studs/seg al volar
	VelocidadCaminar  = 40,    -- studs/seg al correr (16 = normal)

	PasoVelocidad     = 10,    -- cuanto sube/baja con cada toque de +/-
	UsarPlatformStand = false, -- true = mas suave | false = mas sigiloso
	BloquearVelocidad = false, -- true = re-aplica tu velocidad si el juego la cambia
	UsarGyro          = true,  -- mantiene el personaje recto al volar
	AnularWalkSpeed   = true,  -- evita que el Humanoid pelee contra el vuelo
}

local volando, speedOn     = false, false
local velVuelo             = CONFIG.VelocidadVuelo
local velCaminar           = CONFIG.VelocidadCaminar
local velOriginal          = 16
local bv, bg
local upHeld, downHeld     = false, false
local touchUp, touchDown

local function getChar()
	local char = LocalPlayer.Character
	if not char then return nil, nil end
	return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function vertical()
	if upHeld and not downHeld then return 1 end
	if downHeld and not upHeld then return -1 end
	return 0
end

-- ======================= GUI =======================
local gui = Instance.new("ScreenGui")
gui.Name           = "FlyStealthMobile"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name             = "Panel"
panel.Size             = UDim2.new(0, 218, 0, 262)
panel.Position         = UDim2.new(0, 10, 0, 90)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
panel.BorderSizePixel  = 0
panel.Active           = true
panel.Draggable        = true
panel.Parent           = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local borde = Instance.new("UIStroke", panel)
borde.Color     = Color3.fromRGB(62, 62, 80)
borde.Thickness = 1

-- Barra superior (zona para arrastrar el panel)
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
header.BorderSizePixel  = 0
header.Active           = false
header.Parent           = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local titulo = Instance.new("TextLabel")
titulo.Size                   = UDim2.new(1, -46, 1, 0)
titulo.Position               = UDim2.new(0, 12, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text                   = "VENICE  •  FLY"
titulo.TextColor3             = Color3.fromRGB(235, 235, 245)
titulo.Font                   = Enum.Font.GothamBold
titulo.TextSize               = 13
titulo.TextXAlignment         = Enum.TextXAlignment.Left
titulo.Parent                 = header

local btnMin = Instance.new("TextButton")
btnMin.Size             = UDim2.new(0, 26, 0, 22)
btnMin.Position         = UDim2.new(1, -32, 0, 4)
btnMin.BackgroundColor3 = Color3.fromRGB(52, 52, 66)
btnMin.TextColor3       = Color3.fromRGB(255, 255, 255)
btnMin.Font             = Enum.Font.GothamBold
btnMin.TextSize         = 14
btnMin.Text             = "—"
btnMin.BorderSizePixel  = 0
btnMin.Parent           = header
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

local function crearBoton(texto, y, alto)
	local b = Instance.new("TextButton")
	b.Size             = UDim2.new(1, -20, 0, alto)
	b.Position         = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(52, 52, 66)
	b.TextColor3       = Color3.fromRGB(255, 255, 255)
	b.Font             = Enum.Font.GothamBold
	b.TextSize         = 13
	b.Text             = texto
	b.BorderSizePixel  = 0
	b.Parent           = panel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local btnVuelo = crearBoton("VUELO: OFF", 38, 38)
local btnSpeed = crearBoton("SPEED: OFF", 82, 38)

local function filaVelocidad(y, etiqueta, esVuelo)
	local lbl = Instance.new("TextLabel")
	lbl.Size                   = UDim2.new(1, -20, 0, 14)
	lbl.Position               = UDim2.new(0, 12, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3             = Color3.fromRGB(165, 165, 185)
	lbl.Font                   = Enum.Font.GothamBold
	lbl.TextSize               = 11
	lbl.TextXAlignment         = Enum.TextXAlignment.Left
	lbl.Text                   = etiqueta
	lbl.Parent                 = panel

	local minus = Instance.new("TextButton")
	minus.Size             = UDim2.new(0, 46, 0, 30)
	minus.Position         = UDim2.new(0, 10, 0, y + 16)
	minus.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
	minus.TextColor3       = Color3.fromRGB(255, 255, 255)
	minus.Font             = Enum.Font.GothamBold
	minus.TextSize         = 18
	minus.Text             = "−"
	minus.BorderSizePixel  = 0
	minus.Parent           = panel
	Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 7)

	local valor = Instance.new("TextLabel")
	valor.Size             = UDim2.new(1, -124, 0, 30)
	valor.Position         = UDim2.new(0, 62, 0, y + 16)
	valor.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	valor.TextColor3       = Color3.fromRGB(225, 225, 240)
	valor.Font             = Enum.Font.GothamBold
	valor.TextSize         = 14
	valor.Text             = "0"
	valor.BorderSizePixel  = 0
	valor.Parent           = panel
	Instance.new("UICorner", valor).CornerRadius = UDim.new(0, 7)

	local plus = Instance.new("TextButton")
	plus.Size             = UDim2.new(0, 46, 0, 30)
	plus.Position         = UDim2.new(1, -56, 0, y + 16)
	plus.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
	plus.TextColor3       = Color3.fromRGB(255, 255, 255)
	plus.Font             = Enum.Font.GothamBold
	plus.TextSize         = 18
	plus.Text             = "+"
	plus.BorderSizePixel  = 0
	plus.Parent           = panel
	Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 7)

	minus.MouseButton1Click:Connect(function()
		if esVuelo then
			velVuelo = math.clamp(velVuelo - CONFIG.PasoVelocidad, 5, 500)
		else
			velCaminar = math.clamp(velCaminar - CONFIG.PasoVelocidad, 5, 500)
		end
		actualizarInfo()
	end)

	plus.MouseButton1Click:Connect(function()
		if esVuelo then
			velVuelo = math.clamp(velVuelo + CONFIG.PasoVelocidad, 5, 500)
		else
			velCaminar = math.clamp(velCaminar + CONFIG.PasoVelocidad, 5, 500)
		end
		actualizarInfo()
	end)

	return valor
end

local lblVuelo  = filaVelocidad(126, "VELOCIDAD DE VUELO", true)
local lblCorrer = filaVelocidad(178, "VELOCIDAD AL CORRER", false)

local pista = Instance.new("TextLabel")
pista.Size                   = UDim2.new(1, -20, 0, 26)
pista.Position               = UDim2.new(0, 10, 0, 230)
pista.BackgroundTransparency = 1
pista.TextColor3             = Color3.fromRGB(130, 130, 150)
pista.Font                   = Enum.Font.Gotham
pista.TextSize               = 11
pista.TextWrapped            = true
pista.Text                   = "Muevete con el joystick del juego y usa ▲ / ▼ para la altura"
pista.Parent                 = panel

local function actualizarInfo()
	lblVuelo.Text  = tostring(math.floor(velVuelo))
	lblCorrer.Text = tostring(math.floor(velCaminar))
end
actualizarInfo()

-- Boton de ocultar todo
local btnOcultar = Instance.new("TextButton")
btnOcultar.Size             = UDim2.new(0, 42, 0, 42)
btnOcultar.Position         = UDim2.new(0, 10, 0, 40)
btnOcultar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
btnOcultar.TextColor3       = Color3.fromRGB(240, 240, 250)
btnOcultar.Font             = Enum.Font.GothamBold
btnOcultar.TextSize         = 15
btnOcultar.Text             = "V"
btnOcultar.BorderSizePixel  = 0
btnOcultar.Parent           = gui
Instance.new("UICorner", btnOcultar).CornerRadius = UDim.new(1, 0)
local borde2 = Instance.new("UIStroke", btnOcultar)
borde2.Color = Color3.fromRGB(62, 62, 80)

-- Botones de altura
local function crearFlecha(texto, posY)
	local b = Instance.new("TextButton")
	b.AnchorPoint          = Vector2.new(1, 0.5)
	b.Size                 = UDim2.new(0, 64, 0, 64)
	b.Position             = UDim2.new(1, -14, 0.5, posY)
	b.BackgroundColor3     = Color3.fromRGB(28, 28, 38)
	b.BackgroundTransparency = 0.2
	b.TextColor3           = Color3.fromRGB(240, 240, 250)
	b.Font                 = Enum.Font.GothamBold
	b.TextSize             = 22
	b.Text                 = texto
	b.BorderSizePixel      = 0
	b.AutoButtonColor      = false
	b.Parent               = gui
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke", b)
	st.Color = Color3.fromRGB(80, 80, 100)
	st.Transparency = 0.4
	return b
end

local btnArriba = crearFlecha("▲", -46)
local btnAbajo  = crearFlecha("▼", 46)

-- ==================== VUELO ====================
local function detenerVuelo()
	volando = false
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end

	btnVuelo.Text             = "VUELO: OFF"
	btnVuelo.BackgroundColor3 = Color3.fromRGB(52, 52, 66)

	local hum = getChar()
	if hum then
		hum.PlatformStand = false
		if CONFIG.AnularWalkSpeed then
			hum.WalkSpeed = speedOn and velCaminar or velOriginal
		end
	end
end

local function iniciarVuelo()
	local hum, hrp = getChar()
	if not hum or not hrp then return end

	volando = true
	btnVuelo.Text             = "VUELO: ON"
	btnVuelo.BackgroundColor3 = Color3.fromRGB(38, 140, 80)

	if CONFIG.AnularWalkSpeed then
		velOriginal = hum.WalkSpeed
		hum.WalkSpeed = 0
	end

	if CONFIG.UsarPlatformStand then
		hum.PlatformStand = true
	end

	if CONFIG.MetodoVuelo == "BodyVelocity" then
		bv = Instance.new("BodyVelocity")
		bv.Name     = "FlyBV"
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent   = hrp

		if CONFIG.UsarGyro then
			bg = Instance.new("BodyGyro")
			bg.Name      = "FlyBG"
			bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
			bg.P         = 3000
			bg.D         = 500
			bg.CFrame    = hrp.CFrame
			bg.Parent    = hrp
		end
	end
end

local function toggleVuelo()
	if volando then detenerVuelo() else iniciarVuelo() end
end

-- ==================== SPEED ====================
local function aplicarSpeed()
	local hum = getChar()
	if not hum then return end
	hum.WalkSpeed = speedOn and velCaminar or velOriginal
end

local function toggleSpeed()
	speedOn = not speedOn
	btnSpeed.Text             = speedOn and "SPEED: ON" or "SPEED: OFF"
	btnSpeed.BackgroundColor3 = speedOn and Color3.fromRGB(38, 140, 80) or Color3.fromRGB(52, 52, 66)
	if not volando then aplicarSpeed() end
end

-- ================= BUCLE PRINCIPAL =================
RunService.RenderStepped:Connect(function(dt)
	if not volando then return end

	local hum, hrp = getChar()
	if not hum or not hrp then return end

	-- Direccion horizontal tomada del joystick del juego (ya viene orientada a la camara)
	local move = hum.MoveDirection
	local dir  = Vector3.new(move.X, 0, move.Z)
	if dir.Magnitude > 1 then dir = dir.Unit end

	dir = dir + Vector3.new(0, vertical(), 0)
	if dir.Magnitude > 1 then dir = dir.Unit end

	local velocidad = dir * velVuelo

	if CONFIG.MetodoVuelo == "BodyVelocity" then
		if bv then bv.Velocity = velocidad end
		if bg then
			local cam  = workspace.CurrentCamera
			local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
			local plano = Vector3.new(look.X, 0, look.Z)
			if plano.Magnitude < 0.01 then plano = Vector3.new(0, 0, -1) end
			bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + plano.Unit)
		end
	else
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.CFrame = hrp.CFrame + velocidad * dt
	end
end)

-- Bloqueo opcional de velocidad (si el juego la reescribe)
task.spawn(function()
	while task.wait(0.4) do
		if CONFIG.BloquearVelocidad and not volando then
			local hum = getChar()
			if hum then
				hum.WalkSpeed = speedOn and velCaminar or velOriginal
			end
		end
	end
end)

-- ==================== EVENTOS UI ====================
btnVuelo.MouseButton1Click:Connect(toggleVuelo)
btnSpeed.MouseButton1Click:Connect(toggleSpeed)

local minimizado = false
btnMin.MouseButton1Click:Connect(function()
	minimizado = not minimizado
	for _, o in ipairs(panel:GetChildren()) do
		if o ~= header and o:IsA("GuiObject") then
			o.Visible = not minimizado
		end
	end
	panel.Size  = minimizado and UDim2.new(0, 218, 0, 30) or UDim2.new(0, 218, 0, 262)
	btnMin.Text = minimizado and "+" or "—"
end)

btnOcultar.MouseButton1Click:Connect(function()
	local mostrar = not panel.Visible
	panel.Visible      = mostrar
	btnArriba.Visible  = mostrar
	btnAbajo.Visible   = mostrar
	btnOcultar.Text    = mostrar and "V" or "▲"
end)

-- Flechas de altura (s
