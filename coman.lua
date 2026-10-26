--=============================================================
--   VENICE UNIVERSAL v7
--   FLY + SPEED + DINERO UNIVERSAL + EDITOR + VEHICULO
--   Movil / Delta Executor  --  Hecho por Venice
--=============================================================
--  v7 anade 3 pestanas nuevas al panel v6:
--   [$] DINERO   -> escanea monedas (IntValue/NumberValue + tablas getgc)
--   [E] EDITOR   -> seleccionar / mover / rotar / escalar / copiar / duplicar
--   [V] VEHICULO -> acelera lo que estes montado o encima
--=============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local StarterGui        = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Venice] v7 iniciando...")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	repeat task.wait() until Players.LocalPlayer
	LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 20)
if not PlayerGui then warn("[Venice] sin PlayerGui") return end

local function diferir(f)
	if task and task.defer then task.defer(f) else delay(0, f) end
end

-- ============ REPORTERO ============
local lblError
local function reportar(msg)
	if not lblError then
		local g = Instance.new("ScreenGui")
		g.Name = "VeniceError"; g.ResetOnSpawn = false
		g.DisplayOrder = 2000000; g.IgnoreGuiInset = true; g.Parent = PlayerGui
		lblError = Instance.new("TextLabel")
		lblError.AnchorPoint = Vector2.new(0, 1)
		lblError.Size = UDim2.new(0, 380, 0, 130)
		lblError.Position = UDim2.new(0, 10, 1, -10)
		lblError.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
		lblError.TextColor3 = Color3.fromRGB(255, 255, 255)
		lblError.Font = Enum.Font.Code; lblError.TextSize = 11
		lblError.TextWrapped = true
		lblError.TextXAlignment = Enum.TextXAlignment.Left
		lblError.TextYAlignment = Enum.TextYAlignment.Top
		lblError.ZIndex = 50; lblError.Parent = g
		Instance.new("UICorner", lblError).CornerRadius = UDim.new(0, 8)
	end
	lblError.Text = "Venice v7 ERROR:\n" .. tostring(msg)
	warn("[Venice] " .. tostring(msg))
end

-- =========================================================
local function principal()

	local CONFIG = {
		MetodoVuelo = "BodyVelocity",
		VelocidadVuelo = 120, VelocidadCaminar = 60, PasoVelocidad = 5,
		Suave = true, TiempoRampa = 0.7,
		AntiMuerte = "VELOCIDAD", AutoAjuste = true,
		AntiDeteccion = true, AntiRetroceso = true, UsarGyro = true,
		VelocidadVehiculo = 200, PasoEditor = 2,
	}

	local MODOS = { "BodyVelocity", "Velocity", "CFrame" }
	local NOMBRES = {
		BodyVelocity = "MODO: ESTABLE",
		Velocity = "MODO: PURO",
		CFrame = "MODO: CFrame",
	}
	local MODOS_MUERTE = { "OFF", "VELOCIDAD", "SIEMPRE" }

	local VERDE = Color3.fromRGB(38, 140, 80)
	local GRIS  = Color3.fromRGB(52, 52, 66)
	local AMBAR = Color3.fromRGB(120, 95, 45)
	local AZUL  = Color3.fromRGB(45, 90, 140)
	local ROJO  = Color3.fromRGB(150, 55, 55)
	local FONDO = Color3.fromRGB(18, 18, 24)

	-- ============ ESTADO ============
	local volando, speedOn = false, false
	local velVuelo, velCaminar = CONFIG.VelocidadVuelo, CONFIG.VelocidadCaminar
	local velOriginal = 16
	local bv, bg
	local upHeld, downHeld = false, false
	local touchUp, touchDown
	local aplicando = false
	local direccionActual = Vector3.new(0, 0, 0)
	local rampa = 1
	local protegerHasta = 0
	local muertesRecientes = {}
	local Controls
	local minimizado = false
	local pestañaActiva = "FLY"

	local editorOn = false
	local seleccionado, highlight
	local portapapeles
	local pasoEditor = CONFIG.PasoEditor

	local vehiculoOn = false
	local velVehiculo = CONFIG.VelocidadVehiculo

	local entradas = {}
	local entradaSel
	local valorPuesto = 999999
	local autoDinero = false

	-- ============ SISTEMA DE TOQUE ============
	local registros = {}

	local function visibleReal(o)
		local x = o
		while x and x ~= gui do
			if x:IsA("GuiObject") and not x.Visible then return false end
			x = x.Parent
		end
		return true
	end

	local function dentro(btn, p)
		if not btn or not btn.Parent or not visibleReal(btn) then return false end
		local tl, sz = btn.AbsolutePosition, btn.AbsoluteSize
		return p.X >= tl.X and p.X <= tl.X + sz.X
			and p.Y >= tl.Y and p.Y <= tl.Y + sz.Y
	end

	local function registrarPulsacion(btn, fn)
		local reg = { btn = btn, fn = fn, tipo = "click", presionado = nil, ultimo = 0 }
		table.insert(registros, reg)
		local function disparar()
			local ahora = tick()
			if ahora - reg.ultimo < 0.2 then return end
			reg.ultimo = ahora
			local ok, err = pcall(fn)
			if not ok then reportar(err) end
		end
		btn.Activated:Connect(disparar)
		btn.MouseButton1Click:Connect(disparar)
	end

	local function registrarMantener(btn, bajar, soltar)
		table.insert(registros, { btn = btn, tipo = "hold", bajar = bajar, soltar = soltar, presionado = nil })
	end

	-- ============ DECLARACIONES ADELANTADAS ============
	local panel, header, btnMin, btnOcultar, btnArriba, btnAbajo
	local lblVueloVal, lblCorrerVal, pista
	local btnVuelo, btnSpeed, btnModo, btnAuto, btnAnti, btnRetro, btnMuerte, btnSuave
	local minusV, plusV, minusC, plusC
	local contenidos, botonesPestana = {}, {}
	local listaMonedas, lblSelDinero, cajaDinero, lblCuenta
	local lblSelEditor
	local lblEstadoVeh

	local toggleVuelo, toggleSpeed, ciclarModo, toggleAuto, toggleAnti, toggleRetro, ciclarMuerte, toggleSuave
	local cambiarV, cambiarC, actualizarInfo, cambiarPestana
	local pintarAuto, pintarAnti, pintarRetro, pintarMuerte, pintarSuave
	local escanearDinero, refrescarLista, ponerValor, multiplicarValor, quickValor
	local toggleEditor, seleccionar, seleccionarEn, moverSel, rotarSel, escalarSel
	local duplicarSel, copiarSel, pegarSel, borrarSel, anclarSel, colisionSel, transSel
	local irAlObjeto, traerObjeto
	local toggleVehiculo

	-- ============ GUI ============
	local vieja = PlayerGui:FindFirstChild("VenicePanel")
	if vieja then vieja:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "VenicePanel"; gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true; gui.DisplayOrder = 1000000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui

	panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 250, 0, 420)
	panel.Position = UDim2.new(0, 10, 0, 60)
	panel.BackgroundColor3 = FONDO
	panel.BorderSizePixel = 0; panel.Active = false
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
	local brd = Instance.new("UIStroke", panel)
	brd.Color = Color3.fromRGB(62, 62, 80)

	header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	header.BorderSizePixel = 0; header.Active = false; header.Parent = panel
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

	local titulo = Instance.new("TextLabel")
	titulo.Size = UDim2.new(1, -46, 1, 0)
	titulo.Position = UDim2.new(0, 12, 0, 0)
	titulo.BackgroundTransparency = 1
	titulo.Text = "VENICE  •  UNIVERSAL v7"
	titulo.TextColor3 = Color3.fromRGB(235, 235, 245)
	titulo.Font = Enum.Font.GothamBold; titulo.TextSize = 12
	titulo.TextXAlignment = Enum.TextXAlignment.Left
	titulo.Parent = header

	btnMin = Instance.new("TextButton")
	btnMin.Size = UDim2.new(0, 26, 0, 22)
	btnMin.Position = UDim2.new(1, -32, 0, 3)
	btnMin.BackgroundColor3 = GRIS
	btnMin.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnMin.Font = Enum.Font.GothamBold; btnMin.TextSize = 14
	btnMin.Text = "—"; btnMin.BorderSizePixel = 0; btnMin.Parent = header
	Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

	-- helper de botones
	local function B(padre, texto, x, y, w, h, fn)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, w, 0, h)
		b.Position = UDim2.new(0, x, 0, y)
		b.BackgroundColor3 = GRIS
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Font = Enum.Font.GothamBold; b.TextSize = 10
		b.Text = texto; b.TextWrapped = true
		b.BorderSizePixel = 0; b.AutoButtonColor = false
		b.Parent = padre
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
		if fn then registrarPulsacion(b, fn) end
		return b
	end

	local function fila2(padre, t1, f1, t2, f2, y)
		return B(padre, t1, 0, y, 112, 26, f1), B(padre, t2, 122, y, 112, 26, f2)
	end

	local function fila3(padre, textos, fns, y)
		local out = {}
		local x = 0
		for i = 1, 3 do
			out[i] = B(padre, textos[i], x, y, 74, 26, fns[i])
			x = x + 79
		end
		return out
	end

	-- ---------- PESTANAS ----------
	local tabsFrame = Instance.new("Frame")
	tabsFrame.Size = UDim2.new(1, -16, 0, 26)
	tabsFrame.Position = UDim2.new(0, 8, 0, 32)
	tabsFrame.BackgroundTransparency = 1
	tabsFrame.Parent = panel

	local nombresTabs = { { "FLY", "FLY" }, { "$", "DINERO" }, { "E", "EDITOR" }, { "V", "VEH" } }
	for i, t in ipairs(nombresTabs) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 54, 0, 26)
		b.Position = UDim2.new(0, (i - 1) * 58, 0, 0)
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
		b.TextColor3 = Color3.fromRGB(150, 150, 170)
		b.Font = Enum.Font.GothamBold; b.TextSize = 11
		b.Text = t[1]; b.BorderSizePixel = 0
		b.Parent = tabsFrame
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
		botonesPestana[t[2]] = b
		registrarPulsacion(b, function() cambiarPestana(t[2]) end)
	end

	local function crearContenido(nombre)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -16, 1, -74)
		f.Position = UDim2.new(0, 8, 0, 66)
		f.BackgroundTransparency = 1
		f.Visible = false
		f.Parent = panel
		contenidos[nombre] = f
		return f
	end

	local cFly    = crearContenido("FLY")
	local cDinero = crearContenido("DINERO")
	local cEditor = crearContenido("EDITOR")
	local cVeh    = crearContenido("VEH")

	-- ==================== PESTANA FLY ====================
	btnVuelo = B(cFly, "VUELO: OFF", 0, 0, 234, 26, function() toggleVuelo() end)
	btnSpeed = B(cFly, "SPEED: OFF", 0, 30, 234, 26, function() toggleSpeed() end)
	btnModo, btnAuto = fila2(cFly, NOMBRES[CONFIG.MetodoVuelo], function() ciclarModo() end, "AUTO-AJUSTE: ON", function() toggleAuto() end, 60)
	btnAnti, btnRetro = fila2(cFly, "ANTI-DETECT: ON", function() toggleAnti() end, "ANTI-RETRO: ON", function() toggleRetro() end, 90)
	btnMuerte, btnSuave = fila2(cFly, "ANTI-MUERTE: VELOCIDAD", function() ciclarMuerte() end, "SUAVE: ON", function() toggleSuave() end, 120)

	local function filaVelocidad(padre, y, etiqueta, esVuelo)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -20, 0, 11)
		lbl.Position = UDim2.new(0, 2, 0, y)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(165, 165, 185)
		lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = etiqueta; lbl.Parent = padre

		local m = B(padre, "−", 0, y + 12, 44, 28)
		local v = Instance.new("TextLabel")
		v.Size = UDim2.new(0, 116, 0, 28); v.Position = UDim2.new(0, 50, 0, y + 12)
		v.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
		v.TextColor3 = Color3.fromRGB(225, 225, 240)
		v.Font = Enum.Font.GothamBold; v.TextSize = 14; v.Text = "0"
		v.BorderSizePixel = 0; v.Parent = padre
		Instance.new("UICorner", v).CornerRadius = UDim.new(0, 7)
		local p = B(padre, "+", 190, y + 12, 44, 28)
		return v, m, p
	end

	lblVueloVal, minusV, plusV = filaVelocidad(cFly, 152, "VELOCIDAD DE VUELO", true)
	lblCorrerVal, minusC, plusC = filaVelocidad(cFly, 190, "VELOCIDAD AL CORRER", false)

	pista = Instance.new("TextLabel")
	pista.Size = UDim2.new(1, 0, 0, 24); pista.Position = UDim2.new(0, 2, 0, 232)
	pista.BackgroundTransparency = 1
	pista.TextColor3 = Color3.fromRGB(130, 130, 150)
	pista.Font = Enum.Font.Gotham; pista.TextSize = 9; pista.TextWrapped = true
	pista.TextXAlignment = Enum.TextXAlignment.Left
	pista.Text = "Teclas: F vuelo · G speed · Espacio subir · Shift bajar"
	pista.Parent = cFly

	-- ==================== PESTANA DINERO ====================
	B(cDinero, "ESCANEAR MONEDAS DEL JUEGO", 0, 0, 234, 26, function() escanearDinero() end)

	cajaDinero = Instance.new("TextBox")
	cajaDinero.Size = UDim2.new(0, 152, 0, 26); cajaDinero.Position = UDim2.new(0, 0, 0, 30)
	cajaDinero.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	cajaDinero.TextColor3 = Color3.fromRGB(225, 225, 240)
	cajaDinero.Font = Enum.Font.GothamBold; cajaDinero.TextSize = 12
	cajaDinero.PlaceholderText = "cantidad"; cajaDinero.Text = "999999"
	cajaDinero.ClearTextOnFocus = false; cajaDinero.BorderSizePixel = 0
	cajaDinero.Parent = cDinero
	Instance.new("UICorner", cajaDinero).CornerRadius = UDim.new(0, 7)

	B(cDinero, "PONER", 160, 30, 74, 26, function()
		local n = tonumber(cajaDinero.Text)
		if n then valorPuesto = n; ponerValor(n) end
	end)
	B(cDinero, "+1000", 0, 60, 74, 26, function() quickValor(1000) end)
	B(cDinero, "x2", 79, 60, 74, 26, function() multiplicarValor(2) end)
	B(cDinero, "1e9", 158, 60, 76, 26, function() quickValor(1000000000) end)
	B(cDinero, "+1M", 0, 90, 74, 26, function() quickValor(1000000) end)
	B(cDinero, "x10", 79, 90, 74, 26, function() multiplicarValor(10) end)
	local btnAutoDinero = B(cDinero, "AUTO: OFF", 158, 90, 76, 26, function()
		autoDinero = not autoDinero
		btnAutoDinero.Text = autoDinero and "AUTO: ON" or "AUTO: OFF"
		btnAutoDinero.BackgroundColor3 = autoDinero and VERDE or GRIS
	end)

	lblSelDinero = Instance.new("TextLabel")
	lblSelDinero.Size = UDim2.new(1, 0, 0, 14); lblSelDinero.Position = UDim2.new(0, 2, 0, 120)
	lblSelDinero.BackgroundTransparency = 1
	lblSelDinero.TextColor3 = Color3.fromRGB(140, 200, 255)
	lblSelDinero.Font = Enum.Font.GothamBold; lblSelDinero.TextSize = 10
	lblSelDinero.TextXAlignment = Enum.TextXAlignment.Left
	lblSelDinero.Text = "SEL: (ninguno)"
	lblSelDinero.Parent = cDinero

	lblCuenta = Instance.new("TextLabel")
	lblCuenta.Size = UDim2.new(1, 0, 0, 12); lblCuenta.Position = UDim2.new(0, 2, 0, 134)
	lblCuenta.BackgroundTransparency = 1
	lblCuenta.TextColor3 = Color3.fromRGB(120, 120, 140)
	lblCuenta.Font = Enum.Font.Gotham; lblCuenta.TextSize = 9
	lblCuenta.TextXAlignment = Enum.TextXAlignment.Left
	lblCuenta.Text = "0 valores encontrados"
	lblCuenta.Parent = cDinero

	listaMonedas = Instance.new("ScrollingFrame")
	listaMonedas.Size = UDim2.new(1, 0, 0, 168); listaMonedas.Position = UDim2.new(0, 0, 0, 150)
	listaMonedas.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	listaMonedas.BorderSizePixel = 0; listaMonedas.ScrollBarThickness = 6
	listaMonedas.CanvasSize = UDim2.new(0, 0, 0, 0)
	listaMonedas.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listaMonedas.Parent = cDinero
	Instance.new("UICorner", listaMonedas).CornerRadius = UDim.new(0, 8)
	local lay = Instance.new("UIListLayout", listaMonedas)
	lay.Padding = UDim.new(0, 4)

	-- ==================== PESTANA EDITOR ====================
	local btnEditor = B(cEditor, "MODO EDITOR: OFF", 0, 0, 234, 26, function() toggleEditor() end)
	lblSelEditor = Instance.new("TextLabel")
	lblSelEditor.Size = UDim2.new(1, 0, 0, 14); lblSelEditor.Position = UDim2.new(0, 2, 0, 30)
	lblSelEditor.BackgroundTransparency = 1
	lblSelEditor.TextColor3 = Color3.fromRGB(140, 200, 255)
	lblSelEditor.Font = Enum.Font.GothamBold; lblSelEditor.TextSize = 10
	lblSelEditor.TextXAlignment = Enum.TextXAlignment.Left
	lblSelEditor.Text = "SEL: (toca un objeto en el mundo)"
	lblSelEditor.Parent = cEditor

	fila3(cEditor, { "X −", "Y −", "Z −" }, {
		function() moverSel(-pasoEditor, 0, 0) end,
		function() moverSel(0, pasoEditor, 0) end,
		function() moverSel(0, 0, -pasoEditor) end,
	}, 48)
	fila3(cEditor, { "X +", "Y +", "Z +" }, {
		function() moverSel(pasoEditor, 0, 0) end,
		function() moverSel(0, -pasoEditor, 0) end,
		function() moverSel(0, 0, pasoEditor) end,
	}, 76)
	fila3(cEditor, { "↺ X", "↺ Y", "↺ Z" }, {
		function() rotarSel("X", 15) end,
		function() rotarSel("Y", 15) end,
		function() rotarSel("Z", 15) end,
	}, 104)
	fila3(cEditor, { "↻ X", "↻ Y", "↻ Z" }, {
		function() rotarSel("X", -15) end,
		function() rotarSel("Y", -15) end,
		function() rotarSel("Z", -15) end,
	}, 132)
	fila3(cEditor, { "Tamaño −", "Tamaño +", "Paso " .. pasoEditor }, {
		function() escalarSel(0.9) end,
		function() escalarSel(1.1) end,
		function()
			pasoEditor = pasoEditor + 1
			if pasoEditor > 20 then pasoEditor = 0.5 end
		end,
	}, 160)
	fila3(cEditor, { "Duplicar", "Copiar", "Pegar" }, {
		function() duplicarSel() end,
		function() copiarSel() end,
		function() pegarSel() end,
	}, 188)
	fila3(cEditor, { "Borrar", "Anclar", "Colisión" }, {
		function() borrarSel() end,
		function() anclarSel() end,
		function() colisionSel() end,
	}, 216)
	fila3(cEditor, { "Transp −", "Transp +", "Ir al obj" }, {
		function() transSel(0.1) end,
		function() transSel(-0.1) end,
		function() irAlObjeto() end,
	}, 244)
	fila3(cEditor, { "Traer", "Deselecc.", "Anclar todo" }, {
		function() traerObjeto() end,
		function() seleccionar(nil) end,
		function() anclarSel(true) end,
	}, 272)

	-- ==================== PESTANA VEHICULO ====================
	local btnVeh = B(cVeh, "VEHICULO: OFF", 0, 0, 234, 28, function() toggleVehiculo() end)

	local lblVelVeh = Instance.new("TextLabel")
	lblVelVeh.Size = UDim2.new(1, 0, 0, 12); lblVelVeh.Position = UDim2.new(0, 2, 0, 36)
	lblVelVeh.BackgroundTransparency = 1
	lblVelVeh.TextColor3 = Color3.fromRGB(165, 165, 185)
	lblVelVeh.Font = Enum.Font.GothamBold; lblVelVeh.TextSize = 10
	lblVelVeh.TextXAlignment = Enum.TextXAlignment.Left
	lblVelVeh.Text = "VELOCIDAD DEL VEHICULO"
	lblVelVeh.Parent = cVeh

	local lblVelVehVal
	do
		local m = B(cVeh, "−", 0, 50, 44, 30)
		lblVelVehVal = Instance.new("TextLabel")
		lblVelVehVal.Size = UDim2.new(0, 116, 0, 30); lblVelVehVal.Position = UDim2.new(0, 50, 0, 50)
		lblVelVehVal.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
		lblVelVehVal.TextColor3 = Color3.fromRGB(225, 225, 240)
		lblVelVehVal.Font = Enum.Font.GothamBold; lblVelVehVal.TextSize = 14
		lblVelVehVal.Text = tostring(velVehiculo); lblVelVehVal.BorderSizePixel = 0
		lblVelVehVal.Parent = cVeh
		Instance.new("UICorner", lblVelVehVal).CornerRadius = UDim.new(0, 7)
		local p = B(cVeh, "+", 190, 50, 44, 30)
		registrarMantener(m, function()
			velVehiculo = math.clamp(velVehiculo - 25, 10, 3000)
			lblVelVehVal.Text = tostring(velVehiculo)
		end, function() end)
		registrarMantener(p, function()
			velVehiculo = math.clamp(velVehiculo + 25, 10, 3000)
			lblVelVehVal.Text = tostring(velVehiculo)
		end, function() end)
	end

	B(cVeh, "PONER ASIENTO AL MAXIMO (MaxSpeed)", 0, 90, 234, 26, function()
		local hum = getHum()
		if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
			pcall(function()
				hum.SeatPart.MaxSpeed = velVehiculo
				hum.SeatPart.Torque = math.huge
			end)
		end
	end)

	lblEstadoVeh = Instance.new("TextLabel")
	lblEstadoVeh.Size = UDim2.new(1, 0, 0, 60); lblEstadoVeh.Position = UDim2.new(0, 2, 0, 124)
	lblEstadoVeh.BackgroundTransparency = 1
	lblEstadoVeh.TextColor3 = Color3.fromRGB(150, 150, 170)
	lblEstadoVeh.Font = Enum.Font.Gotham; lblEstadoVeh.TextSize = 10
	lblEstadoVeh.TextWrapped = true; lblEstadoVeh.TextXAlignment = Enum.TextXAlignment.Left
	lblEstadoVeh.TextYAlignment = Enum.TextYAlignment.Top
	lblEstadoVeh.Text = "Montate en un vehiculo o ponte encima de una plataforma y activa el boost. Se empuja en la direccion del joystick."
	lblEstadoVeh.Parent = cVeh

	-- boton flotante ocultar
	btnOcultar = Instance.new("TextButton")
	btnOcultar.Size = UDim2.new(0, 42, 0, 42)
	btnOcultar.Position = UDim2.new(0, 10, 0, 12)
	btnOcultar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	btnOcultar.TextColor3 = Color3.fromRGB(240, 240, 250)
	btnOcultar.Font = Enum.Font.GothamBold; btnOcultar.TextSize = 15
	btnOcultar.Text = "V"; btnOcultar.BorderSizePixel = 0; btnOcultar.Parent = gui
	Instance.new("UICorner", btnOcultar).CornerRadius = UDim.new(1, 0)
	local brd2 = Instance.new("UIStroke", btnOcultar)
	brd2.Color = Color3.fromRGB(62, 62, 80)

	local function crearFlecha(texto, posY)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Size = UDim2.new(0, 62, 0, 62)
		b.Position = UDim2.new(1, -14, 0.5, posY)
		b.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
		b.BackgroundTransparency = 0.2
		b.TextColor3 = Color3.fromRGB(240, 240, 250)
		b.Font = Enum.Font.GothamBold; b.TextSize = 22
		b.Text = texto; b.BorderSizePixel = 0; b.AutoButtonColor = false
		b.Parent = gui
		Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
		local st = Instance.new("UIStroke", b)
		st.Color = Color3.fromRGB(80, 80, 100); st.Transparency = 0.4
		return b
	end
	btnArriba = crearFlecha("▲", -46)
	btnAbajo  = crearFlecha("▼", 46)

	-- ============ LOGICA BASE ============
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

	task.spawn(function()
		local ok, res = pcall(function()
			local ps = LocalPlayer:FindFirstChild("PlayerScripts") or LocalPlayer:WaitForChild("PlayerScripts", 6)
			if not ps then return nil end
			local pm = ps:FindFirstChild("PlayerModule") or ps:WaitForChild("PlayerModule", 6)
			if not pm then return nil end
			return require(pm)
		end)
		if ok and res then
			local ok2, c = pcall(function() return res:GetControls() end)
			if ok2 and c then Controls = c end
		end
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

	local function aplicarVelocidad()
		if aplicando then return end
		local hum = getHum(); if not hum then return end
		local objetivo
		if volando and CONFIG.MetodoVuelo == "BodyVelocity" then objetivo = 0
		elseif speedOn then objetivo = velOriginal + (velCaminar - velOriginal) * rampa
		else objetivo = velOriginal end
		if math.abs(hum.WalkSpeed - objetivo) > 0.05 then
			aplicando = true; hum.WalkSpeed = objetivo; aplicando = false
		end
	end

	local function conectarHumanoide(hum)
		hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if aplicando then return end
			if not speedOn and not volando then return end
			if CONFIG.AntiDeteccion then diferir(aplicarVelocidad) end
		end)
		hum.Died:Connect(function()
			if CONFIG.AntiMuerte == "OFF" then return end
			if CONFIG.AntiMuerte == "VELOCIDAD" and not (volando or speedOn) then return end
			local ahora = tick(); local recientes = 0
			for _, t in ipairs(muertesRecientes) do
				if ahora - t < 8 then recientes = recientes + 1 end
			end
			table.insert(muertesRecientes, ahora)
			if CONFIG.AutoAjuste and recientes >= 2 then
				velVuelo = math.max(40, math.floor(velVuelo * 0.85))
				velCaminar = math.max(20, math.floor(velCaminar * 0.85))
				actualizarInfo(); muertesRecientes = {}
			end
			protegerHasta = tick() + 0.9
			diferir(function()
				if hum and hum.Parent and hum.Health <= 0 then
					hum.Health = hum.MaxHealth
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
				end
			end)
		end)
	end

	local function limpiarVuelo()
		if bv then bv:Destroy() bv = nil end
		if bg then bg:Destroy() bg = nil end
	end

	local function detenerVuelo()
		volando = false; limpiarVuelo()
		btnVuelo.Text = "VUELO: OFF"; btnVuelo.BackgroundColor3 = GRIS
		local hum = getHum()
		if hum then
			hum.PlatformStand = false
			pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
			aplicarVelocidad()
		end
	end

	local function iniciarVuelo()
		local hum, hrp = getChar()
		if not hum or not hrp then return end
		volando = true
		rampa = CONFIG.Suave and 0 or 1
		btnVuelo.Text = "VUELO: ON"; btnVuelo.BackgroundColor3 = VERDE
		if CONFIG.AntiDeteccion then pcall(function() hrp:SetNetworkOwner(LocalPlayer) end) end
		if CONFIG.MetodoVuelo == "BodyVelocity" then
			velOriginal = hum.WalkSpeed > 0 and hum.WalkSpeed or velOriginal
			hum.WalkSpeed = 0
			bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp
			if CONFIG.UsarGyro then
				bg = Instance.new("BodyGyro")
				bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
				bg.P = 3000; bg.D = 500; bg.CFrame = hrp.CFrame
				bg.Parent = hrp
			end
		elseif CONFIG.MetodoVuelo == "Velocity" then
			pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, false) end)
			velOriginal = hum.WalkSpeed > 0 and hum.WalkSpeed or velOriginal
			hum.WalkSpeed = 0
		end
	end

	function actualizarInfo()
		if lblVueloVal then lblVueloVal.Text = tostring(math.floor(velVuelo)) end
		if lblCorrerVal then lblCorrerVal.Text = tostring(math.floor(velCaminar)) end
	end

	-- ============ PINTADO ============
	function pintarAuto()
		btnAuto.Text = "AUTO-AJUSTE: " .. (CONFIG.AutoAjuste and "ON" or "OFF")
		btnAuto.BackgroundColor3 = CONFIG.AutoAjuste and VERDE or GRIS
	end
	function pintarAnti()
		btnAnti.Text = "ANTI-DETECT: " .. (CONFIG.AntiDeteccion and "ON" or "OFF")
		btnAnti.BackgroundColor3 = CONFIG.AntiDeteccion and VERDE or GRIS
	end
	function pintarRetro()
		btnRetro.Text = "ANTI-RETRO: " .. (CONFIG.AntiRetroceso and "ON" or "OFF")
		btnRetro.BackgroundColor3 = CONFIG.AntiRetroceso and VERDE or GRIS
	end
	function pintarMuerte()
		btnMuerte.Text = "ANTI-MUERTE: " .. CONFIG.AntiMuerte
		if CONFIG.AntiMuerte == "OFF" then btnMuerte.BackgroundColor3 = GRIS
		elseif CONFIG.AntiMuerte == "SIEMPRE" then btnMuerte.BackgroundColor3 = VERDE
		else btnMuerte.BackgroundColor3 = AMBAR end
	end
	function pintarSuave()
		btnSuave.Text = "SUAVE: " .. (CONFIG.Suave and "ON" or "OFF")
		btnSuave.BackgroundColor3 = CONFIG.Suave and VERDE or GRIS
	end

	function cambiarPestana(nombre)
		for n, f in pairs(contenidos) do f.Visible = (n == nombre) end
		for n, b in pairs(botonesPestana) do
			if n == nombre then
				b.BackgroundColor3 = AZUL; b.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				b.BackgroundColor3 = Color3.fromRGB(30, 30, 42); b.TextColor3 = Color3.fromRGB(150, 150, 170)
			end
		end
		pestañaActiva = nombre
	end

	-- ============ CALLBACKS FLY ============
	function toggleVuelo() if volando then detenerVuelo() else iniciarVuelo() end end
	function toggleSpeed()
		speedOn = not speedOn; rampa = CONFIG.Suave and 0 or 1
		btnSpeed.Text = speedOn and "SPEED: ON" or "SPEED: OFF"
		btnSpeed.BackgroundColor3 = speedOn and VERDE or GRIS
		aplicarVelocidad()
	end
	function ciclarModo()
		local i = 1
		for n, m in ipairs(MODOS) do if m == CONFIG.MetodoVuelo then i = n end end
		i = (i % #MODOS) + 1
		CONFIG.MetodoVuelo = MODOS[i]
		btnModo.Text = NOMBRES[CONFIG.MetodoVuelo]
		if volando then detenerVuelo(); task.wait(0.15); iniciarVuelo() end
	end
	function toggleAuto() CONFIG.AutoAjuste = not CONFIG.AutoAjuste; pintarAuto() end
	function toggleAnti() CONFIG.AntiDeteccion = not CONFIG.AntiDeteccion; pintarAnti(); aplicarVelocidad() end
	function toggleRetro() CONFIG.AntiRetroceso = not CONFIG.AntiRetroceso; pintarRetro() end
	function ciclarMuerte()
		local i = 1
		for n, m in ipairs(MODOS_MUERTE) do if m == CONFIG.AntiMuerte then i = n end end
		CONFIG.AntiMuerte = MODOS_MUERTE[(i % #MODOS_MUERTE) + 1]
		pintarMuerte()
	end
	function toggleSuave() CONFIG.Suave = not CONFIG.Suave; rampa = 1; pintarSuave() end
	function cambiarV(s)
		velVuelo = math.clamp(velVuelo + s * CONFIG.PasoVelocidad, 5, 2000); actualizarInfo()
	end
	function cambiarC(s)
		velCaminar = math.clamp(velCaminar + s * CONFIG.PasoVelocidad, 5, 2000); actualizarInfo()
	end

	-- ============ DINERO ============
	local PALABRAS = {
		"coin","moneda","money","dinero","cash","gem","gemas","gold","oro","credit","credito",
		"ticket","token","buck","star","point","punto","shard","crystal","cristal","diamond",
		"diamante","ruby","candy","egg","seed","ore","mineral","key","llave","fragment","core",
		"soul","essence","crown","trophy","scoin","wins","brick","block","carrot","berry","fish","level","xp",
	}

	local function coincide(nombre)
		local ln = string.lower(nombre)
		for _, p in ipairs(PALABRAS) do
			if string.find(ln, p, 1, true) then return true end
		end
		return false
	end

	function refrescarLista()
		for _, c in ipairs(listaMonedas:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		local total = 0
		for _, e in ipairs(entradas) do
			total = total + 1
			local fila = Instance.new("TextButton")
			fila.Size = UDim2.new(1, -10, 0, 26)
			fila.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
			fila.TextColor3 = Color3.fromRGB(220, 220, 235)
			fila.Font = Enum.Font.Code; fila.TextSize = 11
			fila.TextXAlignment = Enum.TextXAlignment.Left
			fila.Text = "  " .. e.nombre .. "  =  " .. tostring(e.leer())
			fila.BorderSizePixel = 0; fila.Parent = listaMonedas
			Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 6)
			registrarPulsacion(fila, function()
				entradaSel = e
				for _, c in ipairs(listaMonedas:GetChildren()) do
					if c:IsA("GuiObject") then c.BackgroundColor3 = Color3.fromRGB(36, 36, 46) end
				end
				fila.BackgroundColor3 = AZUL
				lblSelDinero.Text = "SEL: " .. e.nombre
			end)
		end
		lblCuenta.Text = total .. " valores encontrados"
	end

	function escanearDinero()
		entradas = {}
		local vistos = {}
		local function agregarValue(v)
			if vistos[v] then return end
			vistos[v] = true
			table.insert(entradas, {
				nombre = v.Name .. " [" .. v.ClassName .. "]",
				leer = function() return v.Value end,
				escribir = function(n) pcall(function() v.Value = n end) end,
			})
		end
		local function revisar(raiz, limite)
			if not raiz then return end
			local n = 0
			for _, v in ipairs(raiz:GetDescendants()) do
				n = n + 1
				if limite and n > limite then break end
				if v:IsA("IntValue") or v:IsA("NumberValue") then agregarValue(v) end
			end
		end
		revisar(LocalPlayer)
		revisar(ReplicatedStorage, 4000)
		local okSS = pcall(function() return game:GetService("ServerStorage") end)
		if okSS then revisar(game:GetService("ServerStorage"), 3000) end

		if getgc then
			local okgc, gc = pcall(getgc, true)
			if okgc and gc then
				local cont = 0
				for _, obj in pairs(gc) do
					if type(obj) == "table" and cont < 4000 then
						cont = cont + 1
						for k, val in pairs(obj) do
							if type(k) == "string" and type(val) == "number" and coincide(k) then
								local t, c = obj, k
								local dupe = false
								for _, e in ipairs(entradas) do
									if e.obj == t and e.clave == c then dupe = true break end
								end
								if not dupe then
									table.insert(entradas, {
										nombre = k .. " (tabla)", obj = t, clave = c,
										leer = function() return c and t[c] end,
										escribir = function(n) pcall(function() t[c] = n end) end,
									})
								end
							end
						end
					end
				end
			end
		end

		table.sort(entradas, function(a, b) return a.nombre < b.nombre end)
		refrescarLista()
	end

	function ponerValor(n)
		if not entradaSel then return end
		entradaSel.escribir(n)
		refrescarLista()
	end
	function quickValor(n)
		if not entradaSel then return end
		entradaSel.escribir(n); valorPuesto = n; refrescarLista()
	end
	function multiplicarValor(f)
		if not entradaSel then return end
		local v = tonumber(entradaSel.leer()) or 0
		entradaSel.escribir(v * f); refrescarLista()
	end

	-- ============ EDITOR ============
	function seleccionar(o)
		seleccionado = o
		if highlight then highlight:Destroy(); highlight = nil end
		if o then
			highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(0, 170, 255)
			highlight.FillTransparency = 0.6
			highlight.OutlineColor = Color3.fromRGB(0, 220, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = o
			highlight.Parent = gui
			lblSelEditor.Text = "SEL: " .. o.Name
		else
			lblSelEditor.Text = "SEL: (toca un objeto en el mundo)"
		end
	end

	function seleccionarEn(pos)
		local cam = workspace.CurrentCamera
		if not cam then return end
		local rayo = cam:ScreenPointToRay(pos.X, pos.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local filtro = {}
		if LocalPlayer.Character then table.insert(filtro, LocalPlayer.Character) end
		params.FilterDescendantsInstances = filtro
		local res = workspace:Raycast(rayo.Origin, rayo.Direction * 3000, params)
		if res and res.Instance then seleccionar(res.Instance) end
	end

	local function sel()
		if seleccionado and seleccionado.Parent then return seleccionado end
		return nil
	end

	function moverSel(dx, dy, dz)
		local o = sel(); if not o then return end
		if o:IsA("BasePart") then
			o.CFrame = o.CFrame * CFrame.new(dx, dy, dz)
		elseif o:IsA("Model") then
			o:PivotTo(o:GetPivot() * CFrame.new(dx, dy, dz))
		end
	end

	function rotarSel(eje, grados)
		local o = sel(); if not o then return end
		local r = math.rad(grados)
		local rot
		if eje == "X" then rot = CFrame.Angles(r, 0, 0)
		elseif eje == "Y" then rot = CFrame.Angles(0, r, 0)
		else rot = CFrame.Angles(0, 0, r) end
		if o:IsA("BasePart") then
			o.CFrame = o.CFrame * rot
		elseif o:IsA("Model") then
			o:PivotTo(o:GetPivot() * rot)
		end
	end

	function escalarSel(f)
		local o = sel(); if not o then return end
		if o:IsA("BasePart") then
			o.Size = o.Size * f
		elseif o:IsA("Model") then
			pcall(function() o:ScaleTo(o:GetScale() * f) end)
		end
	end

	function duplicarSel()
		local o = sel(); if not o then return end
		local c = o:Clone()
		c.Parent = o.Parent
		if c:IsA("BasePart") then c.CFrame = c.CFrame * CFrame.new(pasoEditor, pasoEditor, 0)
		elseif c:IsA("Model") then c:PivotTo(c:GetPivot() * CFrame.new(pasoEditor, pasoEditor, 0)) end
		seleccionar(c)
	end

	function copiarSel()
		local o = sel(); if not o then return end
		portapapeles = o:Clone()
		lblSelEditor.Text = "COPIADO: " .. o.Name
	end

	function pegarSel()
		if not portapapeles then return end
		local c = portapapeles:Clone()
		c.Parent = workspace
		local cam = workspace.CurrentCamera
		local pos = cam and (cam.CFrame.Position + cam.CFrame.LookVector * 12) or Vector3.new(0, 10, 0)
		if c:IsA("BasePart") then c.CFrame = CFrame.new(pos)
		elseif c:IsA("Model") then c:PivotTo(CFrame.new(pos)) end
		seleccionar(c)
	end

	function borrarSel()
		local o = sel(); if not o then return end
		o:Destroy(); seleccionar(nil)
	end

	function anclarSel(forzar)
		local o = sel(); if not o then return end
		if o:IsA("BasePart") then
			if forzar == true then o.Anchored = true else o.Anchored = not o.Anchored end
		elseif o:IsA("Model") then
			for _, d in ipairs(o:GetDescendants()) do
				if d:IsA("BasePart") then
					if forzar == true then d.Anchored = true else d.Anchored = not d.Anchored end
				end
			end
		end
	end

	function colisionSel()
		local o = sel(); if not o then return end
		if o:IsA("BasePart") then o.CanCollide = not o.CanCollide end
		if o:IsA("Model") then
			for _, d in ipairs(o:GetDescendants()) do
				if d:IsA("BasePart") then d.CanCollide = not d.CanCollide end
			end
		end
	end

	function transSel(d)
		local o = sel(); if not o then return end
		if o:IsA("BasePart") then
			o.Transparency = math.clamp(o.Transparency + d, 0, 1)
		end
	end

	function irAlObjeto()
		local o = sel(); if not o then return end
		local hrp = getHRP(); if not hrp then return end
		local pos = o:IsA("BasePart") and o.Position or (o:GetPivot().Position)
		hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
	end

	function traerObjeto()
		local o = sel(); if not o then return end
		local hrp = getHRP(); if not hrp then return end
		local destino = hrp.CFrame * CFrame.new(0, 0, -8)
		if o:IsA("BasePart") then o.CFrame = destino
		elseif o:IsA("Model") then o:PivotTo(destino) end
	end

	function toggleEditor()
		editorOn = not editorOn
		btnEditor.Text = "MODO EDITOR: " .. (editorOn and "ON" or "OFF")
		btnEditor.BackgroundColor3 = editorOn and VERDE or GRIS
		if not editorOn then seleccionar(nil) end
	end

	-- ============ VEHICULO ============
	local function obtenerMontura()
		local hum, hrp = getChar()
		if not hum then return nil end
		if hum.SeatPart then return hum.SeatPart end
		if hrp then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { LocalPlayer.Character }
			local res = workspace:Raycast(hrp.Position, Vector3.new(0, -14, 0), params)
			if res then return res.Instance end
		end
		return nil
	end

	local function raizDe(parte)
		if not parte then return nil end
		if parte:IsA("BasePart") then return parte.AssemblyRootPart or parte end
		return parte:FindFirstChildWhichIsA("BasePart")
	end

	function toggleVehiculo()
		vehiculoOn = not vehiculoOn
		btnVeh.Text = "VEHICULO: " .. (vehiculoOn and "ON" or "OFF")
		btnVeh.BackgroundColor3 = vehiculoOn and VERDE or GRIS
	end

	-- ============ INPUT ============
	local arrastrando = false
	local offsetIni = Vector2.new(0, 0)
	local posIni = UDim2.new(0, 0, 0, 0)

	local function puntoEnGui(p)
		local tl, sz = panel.AbsolutePosition, panel.AbsoluteSize
		if panel.Visible and p.X >= tl.X and p.X <= tl.X + sz.X and p.Y >= tl.Y and p.Y <= tl.Y + sz.Y then
			return true
		end
		for _, o in ipairs({ btnOcultar, btnArriba, btnAbajo }) do
			if o.Visible then
				local t, s = o.AbsolutePosition, o.AbsoluteSize
				if p.X >= t.X and p.X <= t.X + s.X and p.Y >= t.Y and p.Y <= t.Y + s.Y then return true end
			end
		end
		return false
	end

	UserInputService.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		local p = input.Position

		if UserInputService:GetFocusedTextBox() then return end

		if panel.Visible and dentro(header, p) then
			arrastrando = true; offsetIni = p; posIni = panel.Position
		end

		if editorOn and not puntoEnGui(p) then
			seleccionarEn(p)
		end

		for _, reg in ipairs(registros) do
			if dentro(reg.btn, p) then
				reg.presionado = input
				reg.btn.BackgroundTransparency = 0.35
				if reg.tipo == "hold" then
					local ok, err = pcall(reg.bajar)
					if not ok then reportar(err) end
				end
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not arrastrando then return end
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseMovement then return end
		local d = input.Position - offsetIni
		panel.Position = UDim2.new(posIni.X.Scale, posIni.X.Offset + d.X, posIni.Y.Scale, posIni.Y.Offset + d.Y)
	end)

	UserInputService.InputEnded:Connect(function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		if t == Enum.UserInputType.Touch then
			if input == touchUp then upHeld = false; touchUp = nil; btnArriba.BackgroundTransparency = 0.2 end
			if input == touchDown then downHeld = false; touchDown = nil; btnAbajo.BackgroundTransparency = 0.2 end
		end
		arrastrando = false
		for _, reg in ipairs(registros) do
			if reg.presionado == input then
				reg.presionado = nil
				reg.btn.BackgroundTransparency = 0
				if reg.tipo == "hold" then
					local ok, err = pcall(reg.soltar)
					if not ok then reportar(err) end
				else
					if dentro(reg.btn, input.Position) then
						local ahora = tick()
						if ahora - reg.ultimo >= 0.2 then
							reg.ultimo = ahora
							local ok, err = pcall(reg.fn)
							if not ok then reportar(err) end
						end
					end
				end
			end
		end
	end)

	-- ============ BOTONES EXTRA ============
	registrarPulsacion(btnMin, function()
		minimizado = not minimizado
		for _, o in ipairs(panel:GetChildren()) do
			if o ~= header and o:IsA("GuiObject") then o.Visible = not minimizado end
		end
		panel.Size = minimizado and UDim2.new(0, 250, 0, 28) or UDim2.new(0, 250, 0, 420)
		btnMin.Text = minimizado and "+" or "—"
		if not minimizado then cambiarPestana(pestañaActiva) end
	end)

	registrarPulsacion(btnOcultar, function()
		local mostrar = not panel.Visible
		panel.Visible = mostrar
		btnArriba.Visible = mostrar
		btnAbajo.Visible = mostrar
		btnOcultar.Text = mostrar and "V" or "▲"
	end)

	do
		local estados = {}
		local function prepararVel(btn, signo, clave)
			estados[clave] = { activo = false, id = 0 }
			registrarMantener(btn, function()
				local e = estados[clave]
				e.activo = true; e.id = e.id + 1
				local mio = e.id
				if clave == "v" then cambiarV(signo) else cambiarC(signo) end
				task.spawn(function()
					task.wait(0.35)
					while e.activo and e.id == mio do
						if clave == "v" then cambiarV(signo) else cambiarC(signo) end
						task.wait(0.06)
					end
				end)
			end, function() estados[clave].activo = false end)
		end
		prepararVel(minusV, -1, "v"); prepararVel(plusV, 1, "v")
		prepararVel(minusC, -1, "c"); prepararVel(plusC, 1, "c")
	end

	registrarMantener(btnArriba,
		function() upHeld = true; touchUp = nil; btnArriba.BackgroundColor3 = VERDE end,
		function() upHeld = false; btnArriba.BackgroundColor3 = Color3.fromRGB(28, 28, 38) end)
	registrarMantener(btnAbajo,
		function() downHeld = true; touchDown = nil; btnAbajo.BackgroundColor3 = VERDE end,
		function() downHeld = false; btnAbajo.BackgroundColor3 = Color3.fromRGB(28, 28, 38) end)

	-- ============ TECLADO ============
	UserInputService.InputBegan:Connect(function(input, procesado)
		if procesado then return end
		if UserInputService:GetFocusedTextBox() then return end
		local k = input.KeyCode
		if k == Enum.KeyCode.F then toggleVuelo()
		elseif k == Enum.KeyCode.G then toggleSpeed()
		elseif k == Enum.KeyCode.Space then upHeld = true
		elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then downHeld = true
		elseif k == Enum.KeyCode.Equals or k == Enum.KeyCode.KeypadPlus then
			velVuelo = math.clamp(velVuelo + CONFIG.PasoVelocidad, 5, 2000); actualizarInfo()
		elseif k == Enum.KeyCode.Minus or k == Enum.KeyCode.KeypadMinus then
			velVuelo = math.clamp(velVuelo - CONFIG.PasoVelocidad, 5, 2000); actualizarInfo()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space then upHeld = false end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then downHeld = false end
	end)

	-- ============ LOOPS ============
	RunService.Heartbeat:Connect(function(dt)
		if rampa < 1 then rampa = math.min(1, rampa + dt / math.max(0.05, CONFIG.TiempoRampa)) end
		if protegerHasta > 0 and tick() < protegerHasta then
			local h = getHum()
			if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
		end
		local hum, hrp = getChar()
		if not volando then
			if CONFIG.AntiDeteccion and speedOn and hum then aplicarVelocidad() end
			return
		end
		if not hum or not hrp then return end
		local d = vectorMovimiento()
		local dir = Vector3.new(d.X, vertical(), d.Z)
		if dir.Magnitude > 1 then dir = dir.Unit end
		direccionActual = dir
		local vel = dir * velVuelo * rampa
		if CONFIG.MetodoVuelo == "Velocity" then
			hrp.AssemblyLinearVelocity = vel
		elseif CONFIG.MetodoVuelo == "BodyVelocity" then
			if bv then bv.Velocity = vel end
			if bg then
				local cam = workspace.CurrentCamera
				local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
				local plano = Vector3.new(look.X, 0, look.Z)
				if plano.Magnitude < 0.01 then plano = Vector3.new(0, 0, -1) end
				bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + plano.Unit)
			end
		else
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.CFrame = hrp.CFrame + vel * dt
		end
	end)

	-- anti-retroceso
	local ultimaPos, ultimaVel
	RunService.Heartbeat:Connect(function(dt)
		local hum, hrp = getChar()
		if not hum or not hrp then ultimaPos, ultimaVel = nil, nil return end
		if not CONFIG.AntiRetroceso or not ultimaPos then
			ultimaPos = hrp.Position; ultimaVel = hrp.AssemblyLinearVelocity; return
		end
		local pos = hrp.Position
		local esperada
		if volando and CONFIG.MetodoVuelo == "CFrame" then
			esperada = ultimaPos + direccionActual * velVuelo * rampa * dt
		else
			esperada = ultimaPos + ultimaVel * dt
		end
		local errH = Vector3.new(pos.X - esperada.X, 0, pos.Z - esperada.Z).Magnitude
		if errH > 18 then
			local destino = Vector3.new(esperada.X, pos.Y, esperada.Z)
			local look = hrp.CFrame.LookVector
			if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
			hrp.CFrame = CFrame.lookAt(destino, destino + look)
			ultimaPos = hrp.Position; ultimaVel = hrp.AssemblyLinearVelocity; return
		end
		ultimaPos = pos; ultimaVel = hrp.AssemblyLinearVelocity
	end)

	-- loop vehiculo
	task.spawn(function()
		while task.wait(0.05) do
			if vehiculoOn then
				local montura = obtenerMontura()
				if montura then
					local raiz = raizDe(montura)
					if raiz then
						pcall(function() raiz:SetNetworkOwner(LocalPlayer) end)
						local hum = getHum()
						if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
							pcall(function()
								hum.SeatPart.MaxSpeed = math.max(hum.SeatPart.MaxSpeed, velVehiculo)
								hum.SeatPart.Torque = math.huge
							end)
						end
						local d = vectorMovimiento()
						if d.Magnitude > 0.05 then
							raiz.AssemblyLinearVelocity =
								Vector3.new(d.X, raiz.AssemblyLinearVelocity.Y, d.Z) * velVehiculo
						end
						lblEstadoVeh.Text = "Montado en: " .. montura:GetFullName()
					end
				else
					lblEstadoVeh.Text = "Sin montura. Sube a un vehiculo o plataforma."
				end
			end
		end
	end)

	-- loop anti-deteccion vuelo
	task.spawn(function()
		while task.wait(2) do
			if CONFIG.AntiDeteccion and volando then
				local hrp = getHRP()
				if hrp then
					local ok, dueno = pcall(function() return hrp:GetNetworkOwner() end)
					if ok and dueno ~= LocalPlayer then pcall(function() hrp:SetNetworkOwner(LocalPlayer) end) end
				end
			end
		end
	end)

	-- loop dinero AUTO
	task.spawn(function()
		while task.wait(0.5) do
			if autoDinero and entradaSel then
				pcall(function() entradaSel.escribir(valorPuesto) end)
			end
		end
	end)

	-- ============ RESPAWN ============
	local function prepararChar(char)
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then return end
		velOriginal = 16
		upHeld, downHeld = false, false
		rampa = 1
		conectarHumanoide(hum)
		if volando then
			volando = false; limpiarVuelo()
			task.wait(0.4); iniciarVuelo()
		end
	end
	if LocalPlayer.Character then
		task.spawn(function()
			local ok, err = pcall(prepararChar, LocalPlayer.Character)
			if not ok then reportar(err) end
		end)
	end
	LocalPlayer.CharacterAdded:Connect(function(c)
		local ok, err = pcall(prepararChar, c)
		if not ok then reportar(err) end
	end)

	-- ============ INIT ============
	actualizarInfo(); pintarAuto(); pintarAnti(); pintarRetro(); pintarMuerte(); pintarSuave()
	cambiarPestana("FLY")
	print("[Venice] v7 cargado completamente")
end

local ok, err = xpcall(principal, function(e)
	return tostring(e) .. "\n" .. debug.traceback("", 2)
end)
if not ok then reportar(err) end

task.spawn(function()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Venice Universal v7",
			Text = "4 pestanas: FLY / $ / EDITOR / VEH",
			Duration = 4,
		})
	end)
end)
