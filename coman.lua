--=============================================================
--  FLY + SPEED SIN MORIR v3  —  MOVIL / DELTA EXECUTOR
--  Hecho por Venice
---------------------------------------------------------------
--  Estrategia anti-muerte:
--    1. SUAVIZADO  -> la velocidad sube progresivamente
--    2. ANTI-MUERTE-> si el juego te mata, revives al instante
--    3. AUTO-AJUSTE-> si te matan 3 veces, baja un poco y guarda
--
--  PANEL (arrastra desde la barra de arriba)
--    VUELO | SPEED | MODO | AUTO-AJUSTE | ANTI-DETECT
--    ANTI-RETRO | ANTI-MUERTE | SUAVE
--    [-] [+] velocidad vuelo / correr (manten pulsado)
--
--  MOVIL: joystick para moverte, ▲ / ▼ para la altura
--=============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer

-- ================== CONFIGURACION ==================
local CONFIG = {
	-- "BodyVelocity" = ESTABLE | "Velocity" = PURO (0 objetos) | "CFrame"
	MetodoVuelo       = "BodyVelocity",

	VelocidadVuelo    = 120,   -- sube todo lo que quieras
	VelocidadCaminar  = 60,
	PasoVelocidad     = 5,

	Suave             = true,  -- rampa progresiva (CLAVE para no morir)
	TiempoRampa       = 0.7,   -- segundos en llegar a la velocidad final

	AntiMuerte        = "VELOCIDAD", -- "OFF" | "VELOCIDAD" | "SIEMPRE"
	AutoAjuste        = true,  -- baja sola si te matan repetido
	AntiDeteccion     = true,
	AntiRetroceso     = true,

	UsarPlatformStand = false,
	UsarGyro          = true,
}

local MODOS   = { "BodyVelocity", "Velocity", "CFrame" }
local NOMBRES = {
	BodyVelocity = "MODO: ESTABLE",
	Velocity     = "MODO: PURO",
	CFrame       = "MODO: CFrame",
}
local MODOS_MUERTE = { "OFF", "VELOCIDAD", "SIEMPRE" }

local volando, speedOn   = false, false
local velVuelo           = CONFIG.VelocidadVuelo
local velCaminar         = CONFIG.VelocidadCaminar
local velOriginal        = 16
local bv, bg
local upHeld, downHeld   = false, false
local touchUp, touchDown
local aplicando          = false
local direccionActual    = Vector3.new(0, 0, 0)
local rampa              = 1
local protegerHasta      = 0
local muertesRecientes   = {}
local totalMuertes       = 0

local function getChar()
	local char = LocalPlayer.Character
	if not char then return nil, nil end
	return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function getHum() local h = getChar() return h end
local function getHRP() local _, r = getChar() return r end

local function vertical()
	if upHeld and not downHeld then return 1 end
	if downHeld and not upHeld then return -1 end
	return 0
end

local Controls
pcall(function()
	local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
	Controls = PlayerModule:GetControls()
end)

local function vectorMovimiento()
	if Controls then
		local ok, mv = pcall(function() return Controls:GetMoveVector() end)
		if ok and mv and mv.Magnitude > 0.05 then
			local cam = workspace.CurrentCamera
			if cam then
				local d = cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z))
				return Vector3.new(d.X, 0, d.Z)
			end
		end
	end
	local hum = getHum()
	if hum then
		local md = hum.MoveDirection
		return Vector3.new(md.X, 0, md.Z)
	end
	return Vector3.new(0, 0, 0)
end

-- ======================= GUI =======================
local gui = Instance.new("ScreenGui")
gui.Name           = "FlyStealthV3"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 200, 0, 306)
panel.Position         = UDim2.new(0, 10, 0, 70)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
panel.BorderSizePixel  = 0
panel.Active           = true
panel.Draggable        = true
panel.Parent           = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local brd = Instance.new("UIStroke", panel)
brd.Color = Color3.fromRGB(62, 62, 80)

local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
header.BorderSizePixel  = 0
header.Active           = false
header.Parent           = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local titulo = Instance.new("TextLabel")
titulo.Size                   = UDim2.new(1, -46, 1, 0)
titulo.Position               = UDim2.new(0, 12, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text                   = "VENICE  •  FLY v3"
titulo.TextColor3             = Color3.fromRGB(235, 235, 245)
titulo.Font                   = Enum.Font.GothamBold
titulo.TextSize               = 12
titulo.TextXAlignment         = Enum.TextXAlignment.Left
titulo.Parent                 = header

local btnMin = Instance.new("TextButton")
btnMin.Size             = UDim2.new(0, 26, 0, 22)
btnMin.Position         = UDim2.new(1, -32, 0, 3)
btnMin.BackgroundColor3 = Color3.fromRGB(52, 52, 66)
btnMin.TextColor3       = Color3.fromRGB(255, 255, 255)
btnMin.Font             = Enum.Font.GothamBold
btnMin.TextSize         = 14
btnMin.Text             = "—"
btnMin.BorderSizePixel  = 0
btnMin.Parent           = header
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

local ANCHO_MITAD = 87

local function crearBoton(texto, y, izquierda)
	local b = Instance.new("TextButton")
	if izquierda == nil then
		b.Size     = UDim2.new(1, -20, 0, 28)
		b.Position = UDim2.new(0, 10, 0, y)
	else
		b.Size     = UDim2.new(0, ANCHO_MITAD, 0, 28)
		b.Position = UDim2.new(0, izquierda and 10 or 103, 0, y)
	end
	b.BackgroundColor3 = Color3.fromRGB(52, 52, 66)
	b.TextColor3       = Color3.fromRGB(255, 255, 255)
	b.Font             = Enum.Font.GothamBold
	b.TextSize         = 11
	b.Text             = texto
	b.BorderSizePixel  = 0
	b.Parent           = panel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local VERDE = Color3.fromRGB(38, 140, 80)
local GRIS  = Color3.fromRGB(52, 52, 66)
local ROJO  = Color3.fromRGB(150, 55, 55)

local lblVueloVal, lblCorrerVal

local function actualizarInfo()
	if lblVueloVal then  lblVueloVal.Text  = tostring(math.floor(velVuelo)) end
	if lblCorrerVal then lblCorrerVal.Text = tostring(math.floor(velCaminar)) end
end

local function filaVelocidad(y, etiqueta, esVuelo)
	local lbl = Instance.new("TextLabel")
	lbl.Size                   = UDim2.new(1, -20, 0, 11)
	lbl.Position               = UDim2.new(0, 12, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3             = Color3.fromRGB(165, 165, 185)
	lbl.Font                   = Enum.Font.GothamBold
	lbl.TextSize               = 10
	lbl.TextXAlignment         = Enum.TextXAlignment.Left
	lbl.Text                   = etiqueta
	lbl.Parent                 = panel

	local minus = Instance.new("TextButton")
	minus.Size             = UDim2.new(0, 44, 0, 28)
	minus.Position         = UDim2.new(0, 10, 0, y + 12)
	minus.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
	minus.TextColor3       = Color3.fromRGB(255, 255, 255)
	minus.Font             = Enum.Font.GothamBold
	minus.TextSize         = 18
	minus.Text             = "−"
	minus.BorderSizePixel  = 0
	minus.Parent           = panel
	Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 7)

	local valor = Instance.new("TextLabel")
	valor.Size             = UDim2.new(1, -120, 0, 28)
	valor.Position         = UDim2.new(0, 60, 0, y + 12)
	valor.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	valor.TextColor3       = Color3.fromRGB(225, 225, 240)
	valor.Font             = Enum.Font.GothamBold
	valor.TextSize         = 14
	valor.Text             = "0"
	valor.BorderSizePixel  = 0
	valor.Parent           = panel
	Instance.new("UICorner", valor).CornerRadius = UDim.new(0, 7)

	local plus = Instance.new("TextButton")
	plus.Size             = UDim2.new(0, 44, 0, 28)
	plus.Position         = UDim2.new(1, -54, 0, y + 12)
	plus.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
	plus.TextColor3       = Color3.fromRGB(255, 255, 255)
	plus.Font             = Enum.Font.GothamBold
	plus.TextSize         = 18
	plus.Text             = "+"
	plus.BorderSizePixel  = 0
	plus.Parent           = panel
	Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 7)

	local function cambiar(signo)
		if esVuelo then
			velVuelo = math.clamp(velVuelo + signo * CONFIG.PasoVelocidad, 5, 2000)
		else
			velCaminar = math.clamp(velCaminar + signo * CONFIG.PasoVelocidad, 5, 2000)
		end
		actualizarInfo()
	end

	local function enganchar(btn, signo)
		local activo, id = false, 0
		btn.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.Touch
				and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			activo = true
			id = id + 1
			local mio = id
			cambiar(signo)
			task.spawn(function()
				task.wait(0.35)
				while activo and id == mio do
					cambiar(signo)
					task.wait(0.06)
				end
			end)
		end)
		btn.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch
				or i.UserInputType == Enum.UserInputType.MouseButton1 then
				activo = false
			end
		end)
	end
	enganchar(minus, -1)
	enganchar(plus, 1)

	return valor
end

local btnVuelo  = crearBoton("VUELO: OFF", 32)
local btnSpeed  = crearBoton("SPEED: OFF", 62)

local btnModo   = crearBoton(NOMBRES[CONFIG.MetodoVuelo], 92, true)
local btnAuto   = crearBoton("AUTO-AJUSTE: ON", 92, false)
local btnAnti   = crearBoton("ANTI-DETECT: ON", 122, true)
local btnRetro  = crearBoton("ANTI-RETRO: ON", 122, false)
local btnMuerte = crearBoton("ANTI-MUERTE: VELOCIDAD", 152, true)
local btnSuave  = crearBoton("SUAVE: ON", 152, false)

lblVueloVal  = filaVelocidad(184, "VELOCIDAD DE VUELO", true)
lblCorrerVal = filaVelocidad(228, "VELOCIDAD AL CORRER", false)

local pista = Instance.new("TextLabel")
pista.Size                   = UDim2.new(1, -20, 0, 28)
pista.Position               = UDim2.new(0, 10, 0, 274)
pista.BackgroundTransparency = 1
pista.TextColor3             = Color3.fromRGB(130, 130, 150)
pista.Font                   = Enum.Font.Gotham
pista.TextSize               = 10
pista.TextWrapped            = true
pista.Text                   = "Joystick + ▲ / ▼. Si te matan, baja velocidad o pon ANTI-MUERTE: SIEMPRE."
pista.Parent                 = panel

actualizarInfo()

local btnOcultar = Instance.new("TextButton")
btnOcultar.Size             = UDim2.new(0, 42, 0, 42)
btnOcultar.Position         = UDim2.new(0, 10, 0, 22)
btnOcultar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
btnOcultar.TextColor3       = Color3.fromRGB(240, 240, 250)
btnOcultar.Font             = Enum.Font.GothamBold
btnOcultar.TextSize         = 15
btnOcultar.Text             = "V"
btnOcultar.BorderSizePixel  = 0
btnOcultar.Parent           = gui
Instance.new("UICorner", btnOcultar).CornerRadius = UDim.new(1, 0)
local brd2 = Instance.new("UIStroke", btnOcultar)
brd2.Color = Color3.fromRGB(62, 62, 80)

local function crearFlecha(texto, posY)
	local b = Instance.new("TextButton")
	b.AnchorPoint            = Vector2.new(1, 0.5)
	b.Size                   = UDim2.new(0, 62, 0, 62)
	b.Position               = UDim2.new(1, -14, 0.5, posY)
	b.BackgroundColor3       = Color3.fromRGB(28, 28, 38)
	b.BackgroundTransparency = 0.2
	b.TextColor3             = Color3.fromRGB(240, 240, 250)
	b.Font                   = Enum.Font.GothamBold
	b.TextSize               = 22
	b.Text                   = texto
	b.BorderSizePixel        = 0
	b.AutoButtonColor        = false
	b.Parent                 = gui
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke", b)
	st.Color = Color3.fromRGB(80, 80, 100)
	st.Transparency = 0.4
	return b
end

local btnArriba = crearFlecha("▲", -46)
local btnAbajo  = crearFlecha("▼", 46)

-- ============ VELOCIDAD CON SUAVIZADO ============
local function aplicarVelocidad()
	if aplicando then return end
	local hum = getHum()
	if not hum then return end

	local objetivo
	if volando and CONFIG.MetodoVuelo == "BodyVelocity" then
		objetivo = 0
	elseif speedOn then
		objetivo = velOriginal + (velCaminar - velOriginal) * rampa
	else
		objetivo = velOriginal
	end

	if math.abs(hum.WalkSpeed - objetivo) > 0.05 then
		aplicando = true
		hum.WalkSpeed = objetivo
		aplicando = false
	end
end

local function conectarHumanoide(hum)
	hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if aplicando then return end
		if not speedOn and not volando then return end
		if CONFIG.AntiDeteccion then task.defer(aplicarVelocidad) end
	end)

	-- ================= ANTI-MUERTE =================
	hum.Died:Connect(function()
		if CONFIG.AntiMuerte == "OFF" then return end
		if CONFIG.AntiMuerte == "VELOCIDAD" and not (volando or speedOn) then return end

		local ahora = tick()
		local recientes = 0
		for _, t in ipairs(muertesRecientes) do
			if ahora - t < 8 then recientes = recientes + 1 end
		end
		table.insert(muertesRecientes, ahora)
		totalMuertes = totalMuertes + 1

		-- si el juego te mata en bucle, baja un poco para que pare
		if CONFIG.AutoAjuste and recientes >= 2 then
			velVuelo   = math.max(40, math.floor(velVuelo * 0.85))
			velCaminar = math.max(20, math.floor(velCaminar * 0.85))
			actualizarInfo()
			muertesRecientes = {}
			pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "Auto-ajuste",
					Text = "Bajado a " .. velVuelo .. " vuelo / " .. velCaminar .. " correr",
					Duration = 3,
				})
			end)
		end

		-- revive al instante
		protegerHasta = tick() + 0.9
		task.defer(function()
			if hum and hum.Parent and hum.Health <= 0 then
				hum.Health = hum.MaxHealth
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
				pcall(function() hum:
