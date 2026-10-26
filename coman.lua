--=============================================================
--  FLY + SPEED SIN MORIR v5  —  MOVIL / DELTA EXECUTOR
--  Hecho por Venice
---------------------------------------------------------------
--  v5: botones arreglados (sin Draggable, con Activated)
--      + reporte global de errores en pantalla
--=============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")

print("[VeniceFly] v5 iniciando...")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	repeat task.wait() until Players.LocalPlayer
	LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
	warn("[VeniceFly] PlayerGui no encontrado")
	return
end

local function diferir(f)
	if task and task.defer then task.defer(f) else delay(0, f) end
end

-- ================= REPORTERO DE ERRORES =================
local lblError
local function reportar(msg)
	if not lblError then
		local g = Instance.new("ScreenGui")
		g.Name         = "VeniceFlyError"
		g.ResetOnSpawn = false
		g.DisplayOrder = 2000000
		g.IgnoreGuiInset = true
		g.Parent       = PlayerGui
		lblError = Instance.new("TextLabel")
		lblError.Size = UDim2.new(0, 360, 0, 120)
		lblError.Position = UDim2.new(0, 10, 0, 400)
		lblError.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
		lblError.TextColor3 = Color3.fromRGB(255, 255, 255)
		lblError.Font = Enum.Font.Code
		lblError.TextSize = 11
		lblError.TextWrapped = true
		lblError.TextXAlignment = Enum.TextXAlignment.Left
		lblError.TextYAlignment = Enum.TextYAlignment.Top
		lblError.Parent = g
		Instance.new("UICorner", lblError).CornerRadius = UDim.new(0, 8)
	end
	lblError.Text = "VeniceFly v5 ERROR:\n" .. tostring(msg)
	warn("[VeniceFly] " .. tostring(msg))
end

-- =========================================================
--                     CUERPO PRINCIPAL
-- =========================================================
local pistaRef

local function principal()

	local CONFIG = {
		MetodoVuelo       = "BodyVelocity",
		VelocidadVuelo    = 120,
		VelocidadCaminar  = 60,
		PasoVelocidad     = 5,
		Suave             = true,
		TiempoRampa       = 0.7,
		AntiMuerte        = "VELOCIDAD",
		AutoAjuste        = true,
		AntiDeteccion     = true,
		AntiRetroceso     = true,
		UsarPlatformStand = false,
		UsarGyro          = true,
	}

	local MODOS        = { "BodyVelocity", "Velocity", "CFrame" }
	local NOMBRES      = {
		BodyVelocity = "MODO: ESTABLE",
		Velocity     = "MODO: PURO",
		CFrame       = "MODO: CFrame",
	}
	local MODOS_MUERTE = { "OFF", "VELOCIDAD", "SIEMPRE" }

	local VERDE = Color3.fromRGB(38, 140, 80)
	local GRIS  = Color3.fromRGB(52, 52, 66)
	local AMBAR = Color3.fromRGB(120, 95, 45)
	local FONDO = Color3.fromRGB(18, 18, 24)

	local vieja = PlayerGui:FindFirstChild("VeniceFlyPanel")
	if vieja then vieja:Destroy() end

	-- ================= GUI =================
	local gui = Instance.new("ScreenGui")
	gui.Name           = "VeniceFlyPanel"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder   = 1000000
	gui.Enabled        = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent         = PlayerGui

	local panel = Instance.new("Frame")
	panel.Name             = "Panel"
	panel.Size             = UDim2.new(0, 200, 0, 306)
	panel.Position         = UDim2.new(0, 10, 0, 70)
	panel.BackgroundColor3 = FONDO
	panel.BorderSizePixel  = 0
	panel.Active           = false     -- CLAVE: que no se coma los toques
	panel.Draggable        = false     -- arrastre manual
	panel.Parent           = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
	local brd = Instance.new("UIStroke", panel)
	brd.Color = Color3.fromRGB(62, 62, 80)

	local header = Instance.new("Frame")
	header.Size             = UDim2.new(1, 0, 0, 28)
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	header.BorderSizePixel  = 0
	header.Active           = true      -- zona de arrastre
	header.Parent           = panel
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

	local titulo = Instance.new("TextLabel")
	titulo.Size                   = UDim2.new(1, -46, 1, 0)
	titulo.Position               = UDim2.new(0, 12, 0, 0)
	titulo.BackgroundTransparency = 1
	titulo.Text                   = "VENICE  •  FLY v5"
	titulo.TextColor3             = Color3.fromRGB(235, 235, 245)
	titulo.Font                   = Enum.Font.GothamBold
	titulo.TextSize               = 12
	titulo.TextXAlignment         = Enum.TextXAlignment.Left
	titulo.Parent                 = header

	local btnMin = Instance.new("TextButton")
	btnMin.Size             = UDim2.new(0, 26, 0, 22)
	btnMin.Position         = UDim2.new(1, -32, 0, 3)
	btnMin.BackgroundColor3 = GRIS
	btnMin.TextColor3       = Color3.fromRGB(255, 255, 255)
	btnMin.Font             = Enum.Font.GothamBold
	btnMin.TextSize         = 14
	btnMin.Text             = "—"
	btnMin.BorderSizePixel  = 0
	btnMin.Parent           = header
	Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

	-- ---------- helper de pulsacion a prueba de fallos ----------
	local function pulsar(btn, fn)
		local ultimo = 0
		local function disparar()
			local ahora = tick()
			if ahora - ultimo < 0.15 then return end
			ultimo = ahora
			local ok, err = pcall(fn)
			if not ok then reportar(err) end
		end
		btn.Activated:Connect(disparar)
		btn.MouseButton1Click:Connect(disparar)
	end

	-- ---------- helper mantener (para flechas y + / -) ----------
	local function mantener(btn, alBajar, alSubir)
		local activo = false
		local function esRaton(i)
			return i.UserInputType == Enum.UserInputType.Touch
				or i.UserInputType == Enum.UserInputType.MouseButton1
		end
		local function bajar(i)
			if not esRaton(i) or activo then return end
			activo = true
			local ok, err = pcall(alBajar)
			if not ok then reportar(err) end
		end
		local function subir(i)
			if not esRaton(i) or not activo then return end
			activo = false
			local ok, err = pcall(alSubir)
			if not ok then reportar(err) end
		end
		btn.InputBegan:Connect(bajar)
		btn.MouseButton1Down:Connect(bajar)
		btn.InputEnded:Connect(subir)
		btn.MouseButton1Up:Connect(subir)
	end

	local function crearBoton(texto, y, izquierda)
		local b = Instance.new("TextButton")
		if izquierda == nil then
			b.Size     = UDim2.new(1, -20, 0, 28)
			b.Position = UDim2.new(0, 10, 0, y)
		else
			b.Size     = UDim2.new(0, 87, 0, 28)
			b.Position = UDim2.new(0, izquierda and 10 or 103, 0, y)
		end
		b.BackgroundColor3 = GRIS
		b.TextColor3       = Color3.fromRGB(255, 255, 255)
		b.Font             = Enum.Font.GothamBold
		b.TextSize         = 11
		b.Text             = texto
		b.BorderSizePixel  = 0
		b.Parent           = panel
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
		return b
	end

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

		local repitiendo = {}
		local function engancharRepeticion(btn, signo)
			local activo = false
			local id = 0
			mantener(btn,
				function()
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
				end,
				function() activo = false end
			)
		end
		engancharRepeticion(minus, -1)
		engancharRepeticion(plus, 1)

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
	pista.Text                   = "v5 OK  •  Joystick + ▲ / ▼"
	pista.Parent                 = panel
	pistaRef = pista

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

	print("[VeniceFly] GUI creada")

	-- ================= ARRASTRE MANUAL =================
	do
		local arrastrando = false
		local offsetIni   = Vector2.new(0, 0)
		local posIni      = UDim2.new(0, 0, 0, 0)

		header.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.Touch
				and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			arrastrando = true
			offsetIni = i.Position
			posIni = panel.Position
		end)

		UserInputService.InputChanged:Connect(function(i)
			if not arrastrando then return end
			if i.UserInputType ~= Enum.UserInputType.Touch
				and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local d = i.Position - offsetIni
			panel.Position = UDim2.new(
				posIni.X.Scale, posIni.X.Offset + d.X,
				posIni.Y.Scale, posIni.Y.Offset + d.Y
			)
		end)

		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch
				or i.UserInputType == Enum.UserInputType.MouseButton1 then
				arrastrando = false
			end
		end)
	end

	-- ================= ESTADO =================
	local volando, speedOn = false, false
	local velVuelo         = CONFIG.VelocidadVuelo
	local velCaminar       = CONFIG.VelocidadCaminar
	local velOriginal      = 16
	local bv, bg
	local upHeld, downHeld = false, false
	local touchUp, touchDown
	local aplicando        = false
	local direccionActual  = Vector3.new(0, 0, 0)
	local rampa            = 1
	local protegerHasta    = 0
	local muertesRecientes = {}
	local Controls

	actualizarInfo()

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
			local ps = LocalPlayer:FindFirstChild("PlayerScripts")
			if not ps then ps = LocalPlayer:WaitForChild("PlayerScripts", 6) end
			if not ps then return nil end
			local pm = ps:FindFirstChild("PlayerModule")
			if not pm then pm = ps:WaitForChild("PlayerModule", 6) end
			if not pm then return nil end
			return require(pm)
		end)
		if ok and res then
			local ok2, c = pcall(function() return res:GetControls() end)
			if ok2 and c then
				Controls = c
				print("[VeniceFly] ControlModule enlazado")
			end
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

	-- ============ VELOCIDAD ============
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

	-- ============ ANTI-MUERTE ============
	local function conectarHumanoide(hum)
		hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if aplicando then return end
			if not speedOn and not volando then return end
			if CONFIG.AntiDeteccion then diferir(aplicarVelocidad) end
		end)

		hum.Died:Connect(function()
			if CONFIG.AntiMuerte == "OFF" then return end
			if CONFIG.AntiMuerte == "VELOCIDAD" and not (volando or speedOn) then return end

			local ahora = tick()
			local recientes = 0
			for _, t in ipairs(muertesRecientes) do
				if ahora - t < 8 then recientes = recientes + 1 end
			end
			table.insert(muertesRecientes, ahora)

			if CONFIG.AutoAjuste and recientes >= 2 then
				velVuelo   = math.max(40, math.floor(velVuelo * 0.85))
				velCaminar = math.max(20, math.floor(velCaminar * 0.85))
				actualizarInfo()
				muertesRecientes = {}
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

	-- ============ VUELO ============
	local function limpiarVuelo()
		if bv then bv:Destroy() bv = nil end
		if bg then bg:Destroy() bg = nil end
	end

	local function detenerVuelo()
		volando = false
		limpiarVuelo()
		btnVuelo.Text             = "VUELO: OFF"
		btnVuelo.BackgroundColor3 = GRIS
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
		btnVuelo.Text             = "VUELO: ON"
		btnVuelo.BackgroundColor3 = VERDE

		if CONFIG.AntiDeteccion then
			pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
		end

		if CONFIG.MetodoVuelo == "BodyVelocity" then
			velOriginal = hum.WalkSpeed > 0 and hum.WalkSpeed or velOriginal
			hum.WalkSpeed = 0
			bv = Instance.new("BodyVelocity")
			bv.Name     = "FlyBV"
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent   = hrp
			if CONFIG.UsarGyro then
				bg = Instance.new("BodyGyro")
				bg.Name      = "FlyBG"
				bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
				bg.P          = 3000
				bg.D          = 500
				bg.CFrame     = hrp.CFrame
				bg.Parent     = hrp
			end
		elseif CONFIG.MetodoVuelo == "Velocity" then
			pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, false) end)
			velOriginal = hum.WalkSpeed > 0 and hum.WalkSpeed or velOriginal
			hum.WalkSpeed = 0
		end

		if CONFIG.UsarPlatformStand then hum.PlatformStand = true end
	end

	local function toggleVuelo()
		if volando then detenerVuelo() else iniciarVuelo() end
	end

	local function toggleSpeed()
		speedOn = not speedOn
		rampa = CONFIG.Suave and 0 or 1
		btnSpeed.Text             = speedOn and "SPEED: ON" or "SPEED: OFF"
		btnSpeed.BackgroundColor3 = speedOn and VERDE or GRIS
		aplicarVelocidad()
	end

	local function calcularDireccion()
		local d = vectorMovimiento()
		local dir = Vector3.new(d.X, vertical(), d.Z)
		if dir.Magnitude > 1 then dir = dir.Unit end
		return dir
	end

	-- ============ BUCLE ============
	RunService.Heartbeat:Connect(function(dt)
		if rampa < 1 then
			rampa = math.min(1, rampa + dt / math.max(0.05, CONFIG.TiempoRampa))
		end

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

		local dir = calcularDireccion()
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

	-- ============ ANTI-RETROCESO ============
	local ultimaPos, ultimaVel
	RunService.Heartbeat:Connect(function(dt)
		local hum, hrp = getChar()
		if not hum or not hrp then
			ultimaPos, ultimaVel = nil, nil
			return
		end
		if not CONFIG.AntiRetroceso or not ultimaPos then
			ultimaPos = hrp.Position
			ultimaVel = hrp.AssemblyLinearVelocity
			return
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
			ultimaPos = hrp.Position
			ultimaVel = hrp.AssemblyLinearVelocity
			return
		end

		ultimaPos = pos
		ultimaVel = hrp.AssemblyLinearVelocity
	end)

	task.spawn(function()
		while task.wait(2) do
			if CONFIG.AntiDeteccion and volando then
				local hrp = getHRP()
				if hrp then
					local ok, dueno = pcall(function() return hrp:GetNetworkOwner() end)
					if ok and dueno ~= LocalPlayer then
						pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
					end
				end
			end
		end
	end)

	-- ============ BOTONES ============
	pulsar(btnVuelo, toggleVuelo)
	pulsar(btnSpeed, toggleSpeed)

	pulsar(btnModo, function()
		local i = 1
		for n, m in ipairs(MODOS) do if m == CONFIG.MetodoVuelo then i = n end end
		i = (i % #MODOS) + 1
		CONFIG.MetodoVuelo = MODOS[i]
		btnModo.Text = NOMBRES[CONFIG.MetodoVuelo]
		if volando then
			detenerVuelo()
			task.wait(0.15)
			iniciarVuelo()
		end
	end)

	local function pintarAuto()
		btnAuto.Text = "AUTO-AJUSTE: " .. (CONFIG.AutoAjuste and "ON" or "OFF")
		btnAuto.BackgroundColor3 = CONFIG.AutoAjuste and VERDE or GRIS
	end
	pulsar(btnAuto, function()
		CONFIG.AutoAjuste = not CONFIG.AutoAjuste
		pintarAuto()
	end)
	pintarAuto()

	local function pintarAnti()
		btnAnti.Text = "ANTI-DETECT: " .. (CONFIG.AntiDeteccion and "ON" or "OFF")
		btnAnti.BackgroundColor3 = CONFIG.AntiDeteccion and VERDE or GRIS
	end
	pulsar(btnAnti, function()
		CONFIG.AntiDeteccion = not CONFIG.AntiDeteccion
		pintarAnti()
		aplicarVelocidad()
	end)
	pintarAnti()

	local function pintarRetro()
		btnRetro.Text = "ANTI-RETRO: " .. (CONFIG.AntiRetroceso and "ON" or "OFF")
		btnRetro.BackgroundColor3 = CONFIG.AntiRetroceso and VERDE or GRIS
	end
	pulsar(btnRetro, function()
		CONFIG.AntiRetroceso = not CONFIG.AntiRetroceso
		pintarRetro()
	end)
	pintarRetro()

	local function pintarMuerte()
		btnMuerte.Text = "ANTI-MUERTE: " .. CONFIG.AntiMuerte
		if CONFIG.AntiMuerte == "OFF" then
			btnMuerte.BackgroundColor3 = GRIS
		elseif CONFIG.AntiMuerte == "SIEMPRE" then
			btnMuerte.BackgroundColor3 = VERDE
		else
			btnMuerte.BackgroundColor3 = AMBAR
		end
	end
	pulsar(btnMuerte, function()
		local i = 1
		for n, m in ipairs(MODOS_MUERTE) do if m == CONFIG.AntiMuerte then i = n end end
		CONFIG.AntiMuerte = MODOS_MUERTE[(i % #MODOS_MUERTE) + 1]
		pintarMuerte()
	end)
	pintarMuerte()

	local function pintarSuave()
		btnSuave.Text = "SUAVE: " .. (CONFIG.Suave and "ON" or "OFF")
		btnSuave.BackgroundColor3 = CONFIG.Suave and VERDE or GRIS
	end
	pulsar(btnSuave, function()
		CONFIG.Suave = not CONFIG.Suave
		rampa = 1
		pintarSuave()
	end)
	pintarSuave()

	local minimizado = false
	pulsar(btnMin, function()
		minimizado = not minimizado
		for _, o in ipairs(panel:GetChildren()) do
			if o ~= header and o:IsA("GuiObject") then
				o.Visible = not minimizado
			end
		end
		panel.Size  = minimizado and UDim2.new(0, 200, 0, 28) or UDim2.new(0, 200, 0, 306)
		btnMin.Text = minimizado and "+" or "—"
	end)

	pulsar(btnOcultar, function()
		local mostrar = not panel.Visible
		panel.Visible     = mostrar
		btnArriba.Visible = mostrar
		btnAbajo.Visible  = mostrar
		btnOcultar.Text   = mostrar and "V" or "▲"
	end)

	mantener(btnArriba,
		function() upHeld = true  btnArriba.BackgroundColor3 = VERDE end,
		function() upHeld = false btnArriba.BackgroundColor3 = Color3.fromRGB(28, 28, 38) end
	)
	mantener(btnAbajo,
		function() downHeld = true  btnAbajo.BackgroundColor3 = VERDE end,
		function() downHeld = false btnAbajo.BackgroundColor3 = Color3.fromRGB(28, 28, 38) end
	)

	UserInputService.InputEnded:Connect(function(input)
		if input == touchUp then
			upHeld = false touchUp = nil
			btnArriba.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
		end
		if input == touchDown then
			downHeld = false touchDown = nil
			btnAbajo.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
		end
	end)

	-- ============ TECLADO ============
	UserInputService.InputBegan:Connect(function(input, procesado)
		if procesado then return end
		local k = input.KeyCode
		if k == Enum.KeyCode.F then toggleVuelo()
		elseif k == Enum.KeyCode.G then toggleSpeed()
		elseif k == Enum.KeyCode.Space then upHeld = true
		elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then downHeld = true
		elseif k == Enum.KeyCode.Equals or k == Enum.KeyCode.KeypadPlus then
			velVuelo = math.clamp(velVuelo + CONFIG.PasoVelocidad, 5, 2000) actualizarInfo()
		elseif k == Enum.KeyCode.Minus or k == Enum.KeyCode.KeypadMinus then
			velVuelo = math.clamp(velVuelo - CONFIG.PasoVelocidad, 5, 2000) actualizarInfo()
		elseif k == Enum.KeyCode.LeftBracket then
			velCaminar = math.clamp(velCaminar - CONFIG.PasoVelocidad, 5, 2000) actualizarInfo()
		elseif k == Enum.KeyCode.RightBracket then
			velCaminar = math.clamp(velCaminar + CONFIG.PasoVelocidad, 5, 2000) actualizarInfo()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space then upHeld = false end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then downHeld = false end
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
			volando = false
			limpiarVuelo()
			task.wait(0.4)
			iniciarVuelo()
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

	print("[VeniceFly] v5 cargado completamente")
end

-- =========================================================
local ok, err = xpcall(principal, function(e)
	return tostring(e) .. "\n" .. debug.traceback("", 2)
end)

if not ok then
	reportar(err)
end

task.spawn(function()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Venice Fly v5",
			Text = "Panel interactivo. Toca VUELO para empezar.",
			Duration = 4,
		})
	end)
end)
