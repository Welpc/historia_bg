-- ============================================================
--  GameVulnerabilityScanner.lua  v1.0
--  Escanea TODO el juego en busca de vulnerabilidades
--  Compatible con: Roblox Studio, Delta, KRNL, Synapse, Fluxus
-- ============================================================

local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("GameScannerUI") then
	playerGui.GameScannerUI:Destroy()
end

-- ----------------------------------------------------------------
-- Colores
-- ----------------------------------------------------------------
local C = {
	bg        = Color3.fromRGB(12, 12, 18),
	panel     = Color3.fromRGB(20, 20, 30),
	card      = Color3.fromRGB(28, 28, 40),
	cardAlt   = Color3.fromRGB(24, 24, 36),
	header    = Color3.fromRGB(16, 16, 26),
	border    = Color3.fromRGB(50, 50, 75),
	text      = Color3.fromRGB(225, 225, 240),
	textMuted = Color3.fromRGB(140, 140, 170),
	textDim   = Color3.fromRGB(80, 80, 110),
	alta      = Color3.fromRGB(220, 60, 60),
	media     = Color3.fromRGB(210, 150, 25),
	baja      = Color3.fromRGB(50, 125, 210),
	info      = Color3.fromRGB(80, 160, 220),
	green     = Color3.fromRGB(60, 185, 105),
	btnScan   = Color3.fromRGB(70, 100, 210),
	btnCopy   = Color3.fromRGB(45, 135, 95),
	btnClose  = Color3.fromRGB(175, 45, 45),
	white     = Color3.fromRGB(255, 255, 255),
	black     = Color3.fromRGB(0, 0, 0),
}

local NIVEL_COLOR = { ALTA = C.alta, MEDIA = C.media, BAJA = C.baja, INFO = C.info }

-- ----------------------------------------------------------------
-- Helpers UI
-- ----------------------------------------------------------------
local function corner(p, r)
	local c = Instance.new("UICorner", p)
	c.CornerRadius = UDim.new(0, r or 8)
end
local function stroke(p, col, t)
	local s = Instance.new("UIStroke", p)
	s.Color = col or C.border
	s.Thickness = t or 1
end
local function mkLabel(parent, props)
	local l = Instance.new("TextLabel", parent)
	l.BackgroundTransparency = 1
	l.Font = props.font or Enum.Font.Gotham
	l.TextSize = props.size or 12
	l.TextColor3 = props.color or C.text
	l.Text = props.text or ""
	l.TextXAlignment = props.xa or Enum.TextXAlignment.Left
	l.TextYAlignment = props.ya or Enum.TextYAlignment.Center
	l.TextWrapped = props.wrap or false
	l.TextTruncate = props.trunc or Enum.TextTruncate.None
	l.Size = props.sz or UDim2.new(1, 0, 0, 20)
	l.Position = props.pos or UDim2.new(0, 0, 0, 0)
	l.ZIndex = props.z or 2
	return l
end
local function mkBtn(parent, props)
	local b = Instance.new("TextButton", parent)
	b.Size = props.sz or UDim2.new(0, 80, 0, 26)
	b.Position = props.pos or UDim2.new(0, 0, 0, 0)
	b.BackgroundColor3 = props.bg or C.btnScan
	b.Text = props.text or ""
	b.TextColor3 = props.tc or C.white
	b.TextSize = props.tsize or 11
	b.Font = props.font or Enum.Font.GothamBold
	b.BorderSizePixel = 0
	b.ZIndex = props.z or 5
	corner(b, props.r or 6)
	if props.sc then stroke(b, props.sc, 1) end
	return b
end

-- ================================================================
-- MÓDULOS DE ESCANEO
-- ================================================================

-- Palabras clave para remotes peligrosos
local PALABRAS_REMOTE = {
	"give","admin","kick","ban","money","cash","coins","candy",
	"damage","kill","speed","fly","tp","teleport","god","item",
	"tool","weapon","power","level","exp","reward","buy","sell",
	"skip","rank","promote","demote","ban","unban","health","heal",
	"equip","drop","trade","transfer","chest","loot","spawn","delete",
}

-- Palabras clave para valores sensibles
local PALABRAS_VALOR = {
	"key","token","secret","password","auth","admin","rank",
	"permission","role","config","setting","ban","whitelist",
}

-- Palabras clave para ModuleScripts sensibles
local PALABRAS_MODULE = {
	"key","token","secret","password","auth","config","admin","database","db",
}

-- Servicios a escanear
local SERVICIOS = {
	"Workspace", "ReplicatedStorage", "ReplicatedFirst",
	"StarterGui", "StarterPack", "StarterPlayer",
	"Players", "Lighting", "SoundService",
}

local function getRuta(obj)
	local ok, r = pcall(function() return obj:GetFullName() end)
	return ok and r or "N/A"
end

-- ----------------------------------------------------------------
-- Módulo 1: RemoteEvents y RemoteFunctions
-- ----------------------------------------------------------------
local function escanearRemotes(hallazgos)
	local vistos = {}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			local n = v.Name:lower()
			local ruta = getRuta(v)

			-- Evitar duplicados por ruta
			if not vistos[ruta] then
				vistos[ruta] = true

				-- Nombre sospechoso
				for _, p in ipairs(PALABRAS_REMOTE) do
					if n:find(p) then
						table.insert(hallazgos, {
							categoria = "Remote",
							nivel     = "ALTA",
							nombre    = "Remote sospechoso: " .. v.Name,
							detalle   = "Puede ser llamado por cualquier cliente. Valida en el servidor.",
							ruta      = ruta,
						})
						break
					end
				end

				-- RemoteFunction siempre media
				if v:IsA("RemoteFunction") then
					table.insert(hallazgos, {
						categoria = "Remote",
						nivel     = "MEDIA",
						nombre    = "RemoteFunction expuesta: " .. v.Name,
						detalle   = "Si el servidor no responde, el cliente se congela. Usa pcall al invocar.",
						ruta      = ruta,
					})
				end
			end
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 2: Scripts y LocalScripts
-- ----------------------------------------------------------------
local function escanearScripts(hallazgos)
	for _, v in ipairs(game:GetDescendants()) do
		-- LocalScript en lugar incorrecto (ServerScriptService)
		if v:IsA("LocalScript") and v.Parent then
			local parentName = v.Parent.Name:lower()
			if parentName:find("serverscript") or parentName:find("serverStorage") then
				table.insert(hallazgos, {
					categoria = "Script",
					nivel     = "ALTA",
					nombre    = "LocalScript en el servidor: " .. v.Name,
					detalle   = "Un LocalScript en ServerScriptService no corre. Probablemente deberia ser Script.",
					ruta      = getRuta(v),
				})
			end
		end

		-- Script (server) en StarterPlayerScripts o StarterGui
		if v:IsA("Script") and not v:IsA("LocalScript") and v.Parent then
			local parentName = v.Parent.Name:lower()
			if parentName:find("starter") or parentName:find("playergui") then
				table.insert(hallazgos, {
					categoria = "Script",
					nivel     = "ALTA",
					nombre    = "Script de servidor en cliente: " .. v.Name,
					detalle   = "Un Script en StarterGui/StarterPlayer no tiene autoridad de servidor.",
					ruta      = getRuta(v),
				})
			end
		end

		-- Scripts deshabilitados
		if (v:IsA("Script") or v:IsA("LocalScript")) and v.Disabled then
			table.insert(hallazgos, {
				categoria = "Script",
				nivel     = "BAJA",
				nombre    = "Script deshabilitado: " .. v.Name,
				detalle   = "Puede haber dejado conexiones activas o ser reactivado por un exploiter.",
				ruta      = getRuta(v),
			})
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 3: ModuleScripts sensibles
-- ----------------------------------------------------------------
local function escanearModules(hallazgos)
	local FALSOS_POSITIVOS = {
		"keyboard", "mouse", "camera", "controlmodule", "cameramodule",
		"playermodule", "mouselock", "boundkeys", "touchjump",
		"baseocclusionmode", "shifttoglide",
	}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local n = v.Name:lower()
			local esFalso = false
			for _, fp in ipairs(FALSOS_POSITIVOS) do
				if n:find(fp) then esFalso = true break end
			end
			if not esFalso then
				for _, p in ipairs(PALABRAS_MODULE) do
					if n:find(p) then
						table.insert(hallazgos, {
							categoria = "Modulo",
							nivel     = "ALTA",
							nombre    = "ModuleScript sensible: " .. v.Name,
							detalle   = "Podria contener datos confidenciales accesibles desde el cliente.",
							ruta      = getRuta(v),
						})
						break
					end
				end
			end
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 4: Valores sensibles expuestos
-- ----------------------------------------------------------------
local function escanearValores(hallazgos)
	local FALSOS_POSITIVOS = { "boundkeys", "mouselock", "controlmodule" }
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("BoolValue") then
			local n = v.Name:lower()
			local esFalso = false
			for _, fp in ipairs(FALSOS_POSITIVOS) do
				if n:find(fp) then esFalso = true break end
			end
			if not esFalso then
				for _, p in ipairs(PALABRAS_VALOR) do
					if n:find(p) then
						table.insert(hallazgos, {
							categoria = "Valor",
							nivel     = "ALTA",
							nombre    = "Valor sensible expuesto: " .. v.Name,
							detalle   = "Este valor esta accesible desde el cliente y puede ser leido o manipulado.",
							ruta      = getRuta(v),
						})
						break
					end
				end
			end
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 5: BindableEvents y BindableFunctions
-- ----------------------------------------------------------------
local function escanearBindables(hallazgos)
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("BindableEvent") or v:IsA("BindableFunction") then
			local ruta = getRuta(v)
			-- Solo los que están accesibles en ReplicatedStorage o StarterX son peligrosos
			if ruta:find("Replicated") or ruta:find("Starter") or ruta:find("Players") then
				table.insert(hallazgos, {
					categoria = "Bindable",
					nivel     = "BAJA",
					nombre    = "Bindable accesible: " .. v.Name,
					detalle   = "Puede ser invocado externamente si esta en un lugar accesible al cliente.",
					ruta      = ruta,
				})
			end
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 6: Character y jugador
-- ----------------------------------------------------------------
local function escanearJugador(hallazgos)
	local char = localPlayer.Character
	if not char then
		table.insert(hallazgos, {
			categoria = "Jugador",
			nivel     = "ALTA",
			nombre    = "Character es nil",
			detalle   = "El personaje no ha cargado. Scripts que accedan a .Character sin nil-check fallaran.",
			ruta      = getRuta(localPlayer),
		})
		return
	end

	if not char:FindFirstChildOfClass("Humanoid") then
		table.insert(hallazgos, {
			categoria = "Jugador",
			nivel     = "MEDIA",
			nombre    = "Humanoid no encontrado",
			detalle   = "Scripts que usen Humanoid sin verificar su existencia pueden generar errores.",
			ruta      = getRuta(char),
		})
	end

	if not char:FindFirstChild("HumanoidRootPart") then
		table.insert(hallazgos, {
			categoria = "Jugador",
			nivel     = "MEDIA",
			nombre    = "HumanoidRootPart no encontrado",
			detalle   = "Scripts que usen HumanoidRootPart sin nil-check fallaran.",
			ruta      = getRuta(char),
		})
	end
end

-- ----------------------------------------------------------------
-- Módulo 7: DataStores accesibles desde el cliente
-- ----------------------------------------------------------------
local function escanearDataStore(hallazgos)
	-- Si hay RemoteFunctions que contengan "data" o "save" en el nombre
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
			local n = v.Name:lower()
			if n:find("data") or n:find("save") or n:find("load") or n:find("store") then
				table.insert(hallazgos, {
					categoria = "DataStore",
					nivel     = "ALTA",
					nombre    = "Posible DataStore expuesto: " .. v.Name,
					detalle   = "Si este remote lee o escribe datos del jugador sin validacion, cualquiera puede manipular su perfil.",
					ruta      = getRuta(v),
				})
			end
		end
	end
end

-- ----------------------------------------------------------------
-- Módulo 8: Anti-cheat ausente
-- ----------------------------------------------------------------
local function escanearAntiCheat(hallazgos)
	local tieneAntiCheat = false
	local palabrasAC = { "anticheat", "anti_cheat", "cheatdetect", "hackdetect", "security" }

	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			local n = v.Name:lower()
			for _, p in ipairs(palabrasAC) do
				if n:find(p) then
					tieneAntiCheat = true
					break
				end
			end
		end
		if tieneAntiCheat then break end
	end

	if not tieneAntiCheat then
		table.insert(hallazgos, {
			categoria = "Seguridad",
			nivel     = "MEDIA",
			nombre    = "No se detecto sistema anti-cheat",
			detalle   = "No se encontro ningun script con nombre relacionado a anti-cheat o seguridad.",
			ruta      = "game",
		})
	end
end

-- ----------------------------------------------------------------
-- Módulo 9: Objetos en ReplicatedStorage que no deberían estar
-- ----------------------------------------------------------------
local function escanearReplicatedStorage(hallazgos)
	local rs = game:GetService("ReplicatedStorage")
	if not rs then return end

	local palabrasPeligrosas = { "admin", "config", "setting", "database", "secret", "key", "password" }

	for _, v in ipairs(rs:GetDescendants()) do
		local n = v.Name:lower()
		for _, p in ipairs(palabrasPeligrosas) do
			if n:find(p) and (v:IsA("ModuleScript") or v:IsA("StringValue") or v:IsA("Folder")) then
				table.insert(hallazgos, {
					categoria = "ReplicatedStorage",
					nivel     = "ALTA",
					nombre    = "Objeto sensible en ReplicatedStorage: " .. v.Name,
					detalle   = "Todo en ReplicatedStorage es visible para el cliente. Mueve datos sensibles a ServerStorage.",
					ruta      = getRuta(v),
				})
				break
			end
		end
	end
end

-- ================================================================
-- FUNCIÓN PRINCIPAL DE ESCANEO
-- ================================================================
local function escanearTodo()
	local hallazgos = {}

	escanearRemotes(hallazgos)
	escanearScripts(hallazgos)
	escanearModules(hallazgos)
	escanearValores(hallazgos)
	escanearBindables(hallazgos)
	escanearJugador(hallazgos)
	escanearDataStore(hallazgos)
	escanearAntiCheat(hallazgos)
	escanearReplicatedStorage(hallazgos)

	-- Eliminar duplicados por nombre+ruta
	local vistos = {}
	local unicos = {}
	for _, h in ipairs(hallazgos) do
		local key = h.nombre .. h.ruta
		if not vistos[key] then
			vistos[key] = true
			table.insert(unicos, h)
		end
	end

	-- Ordenar por severidad
	local orden = { ALTA=1, MEDIA=2, BAJA=3, INFO=4 }
	table.sort(unicos, function(a,b)
		if orden[a.nivel] == orden[b.nivel] then
			return a.categoria < b.categoria
		end
		return (orden[a.nivel] or 9) < (orden[b.nivel] or 9)
	end)

	return unicos
end

-- ================================================================
-- GENERAR TEXTO PARA COPIAR
-- ================================================================
local function generarTexto(hallazgos)
	local lineas = {}
	table.insert(lineas, "================================================")
	table.insert(lineas, "  REPORTE COMPLETO - Game Vulnerability Scanner")
	table.insert(lineas, "================================================")

	local cA, cM, cB = 0, 0, 0
	local cats = {}
	for _, h in ipairs(hallazgos) do
		if h.nivel=="ALTA"  then cA=cA+1 end
		if h.nivel=="MEDIA" then cM=cM+1 end
		if h.nivel=="BAJA"  then cB=cB+1 end
		cats[h.categoria] = (cats[h.categoria] or 0) + 1
	end

	table.insert(lineas, string.format("Total: %d  |  Alta: %d  |  Media: %d  |  Baja: %d", #hallazgos, cA, cM, cB))
	table.insert(lineas, "")

	local catActual = ""
	for _, h in ipairs(hallazgos) do
		if h.categoria ~= catActual then
			catActual = h.categoria
			table.insert(lineas, "--- " .. catActual:upper() .. " ---")
		end
		table.insert(lineas, string.format("[%s] %s", h.nivel, h.nombre))
		table.insert(lineas, "  Ruta   : " .. h.ruta)
		table.insert(lineas, "  Consejo: " .. h.detalle)
		table.insert(lineas, "")
	end

	table.insert(lineas, "================================================")
	return table.concat(lineas, "\n")
end

-- ================================================================
-- UI
-- ================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameScannerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Botón flotante
local launchBtn = mkBtn(screenGui, {
	sz   = UDim2.new(0, 140, 0, 34),
	pos  = UDim2.new(0, 14, 0.5, -17),
	bg   = C.btnScan,
	text = "Game Scanner",
	z    = 10,
	r    = 10,
	sc   = Color3.fromRGB(100, 130, 255),
})

-- Panel principal
local main = Instance.new("Frame", screenGui)
main.Name = "Main"
main.Size = UDim2.new(0, 460, 0, 520)
main.Position = UDim2.new(0.5, -230, 0.5, -260)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.ZIndex = 5
corner(main, 12)
stroke(main, C.border, 1.5)

-- Header
local hdr = Instance.new("Frame", main)
hdr.Size = UDim2.new(1, 0, 0, 42)
hdr.BackgroundColor3 = C.header
hdr.BorderSizePixel = 0
hdr.ZIndex = 6
corner(hdr, 12)
local hdrPatch = Instance.new("Frame", hdr)
hdrPatch.Size = UDim2.new(1, 0, 0.5, 0)
hdrPatch.Position = UDim2.new(0, 0, 0.5, 0)
hdrPatch.BackgroundColor3 = C.header
hdrPatch.BorderSizePixel = 0
hdrPatch.ZIndex = 6

mkLabel(hdr, {
	text = "Game Vulnerability Scanner",
	font = Enum.Font.GothamBold,
	size = 13, color = C.text,
	sz   = UDim2.new(1, -46, 1, 0),
	pos  = UDim2.new(0, 12, 0, 0), z = 7,
})

local closeBtn = mkBtn(hdr, {
	sz = UDim2.new(0, 26, 0, 26),
	pos = UDim2.new(1, -34, 0.5, -13),
	bg = C.btnClose, text = "X", z = 8, r = 6,
})

-- Stats bar (4 contadores)
local statsBar = Instance.new("Frame", main)
statsBar.Size = UDim2.new(1, -16, 0, 42)
statsBar.Position = UDim2.new(0, 8, 0, 50)
statsBar.BackgroundColor3 = C.panel
statsBar.BorderSizePixel = 0
statsBar.ZIndex = 6
corner(statsBar, 8)
stroke(statsBar, C.border, 1)

local statsLayout = Instance.new("UIListLayout", statsBar)
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.Padding = UDim.new(0, 1)
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local statDefs = {
	{ label = "TOTAL", color = C.textMuted, key = "total" },
	{ label = "ALTA",  color = C.alta,      key = "alta"  },
	{ label = "MEDIA", color = C.media,     key = "media" },
	{ label = "BAJA",  color = C.baja,      key = "baja"  },
}
local statLabels = {}

for i, def in ipairs(statDefs) do
	local cell = Instance.new("Frame", statsBar)
	cell.Size = UDim2.new(0.25, 0, 1, 0)
	cell.BackgroundTransparency = 1
	cell.ZIndex = 7
	cell.LayoutOrder = i

	local numLbl = mkLabel(cell, {
		text = "-", font = Enum.Font.GothamBold,
		size = 16, color = def.color,
		sz   = UDim2.new(1, 0, 0, 22),
		pos  = UDim2.new(0, 0, 0, 4),
		xa   = Enum.TextXAlignment.Center, z = 8,
	})
	mkLabel(cell, {
		text = def.label, font = Enum.Font.Gotham,
		size = 9, color = C.textDim,
		sz   = UDim2.new(1, 0, 0, 14),
		pos  = UDim2.new(0, 0, 0, 24),
		xa   = Enum.TextXAlignment.Center, z = 8,
	})
	statLabels[def.key] = numLbl
end

-- Toolbar botones
local toolbar = Instance.new("Frame", main)
toolbar.Size = UDim2.new(1, -16, 0, 30)
toolbar.Position = UDim2.new(0, 8, 0, 100)
toolbar.BackgroundTransparency = 1
toolbar.ZIndex = 6

local scanBtn = mkBtn(toolbar, {
	sz   = UDim2.new(0, 100, 0, 28),
	pos  = UDim2.new(0, 0, 0, 0),
	bg   = C.btnScan, text = "Escanear", z = 7,
})

local copyBtn = mkBtn(toolbar, {
	sz   = UDim2.new(0, 88, 0, 28),
	pos  = UDim2.new(0, 106, 0, 0),
	bg   = Color3.fromRGB(35, 35, 52),
	text = "Copiar", z = 7,
	sc   = C.border,
})
copyBtn.TextColor3 = C.textDim

-- Filtros de nivel
local filtros = { "TODOS", "ALTA", "MEDIA", "BAJA" }
local filtroBtns = {}
local filtroActual = "TODOS"

for i, f in ipairs(filtros) do
	local fb = mkBtn(toolbar, {
		sz   = UDim2.new(0, 56, 0, 28),
		pos  = UDim2.new(0, 200 + (i-1)*60, 0, 0),
		bg   = i == 1 and C.btnScan or Color3.fromRGB(35, 35, 52),
		text = f,
		tsize = 10, z = 7,
		sc   = C.border,
	})
	if i ~= 1 then fb.TextColor3 = C.textDim end
	filtroBtns[f] = fb
end

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -142)
scroll.Position = UDim2.new(0, 8, 0, 138)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 110)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 6
corner(scroll, 8)
stroke(scroll, C.border, 1)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local listPad = Instance.new("UIPadding", scroll)
listPad.PaddingTop    = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 6)
listPad.PaddingLeft   = UDim.new(0, 6)
listPad.PaddingRight  = UDim.new(0, 6)

-- ----------------------------------------------------------------
-- Ventana de copia
-- ----------------------------------------------------------------
local copyWindow = Instance.new("Frame", screenGui)
copyWindow.Size = UDim2.new(0, 420, 0, 320)
copyWindow.Position = UDim2.new(0.5, -210, 0.5, -160)
copyWindow.BackgroundColor3 = C.bg
copyWindow.BorderSizePixel = 0
copyWindow.Active = true
copyWindow.Draggable = true
copyWindow.Visible = false
copyWindow.ZIndex = 30
corner(copyWindow, 12)
stroke(copyWindow, C.border, 1.5)

local cwHdr = Instance.new("Frame", copyWindow)
cwHdr.Size = UDim2.new(1, 0, 0, 38)
cwHdr.BackgroundColor3 = C.header
cwHdr.BorderSizePixel = 0
cwHdr.ZIndex = 31
corner(cwHdr, 12)
local cwPatch = Instance.new("Frame", cwHdr)
cwPatch.Size = UDim2.new(1, 0, 0.5, 0)
cwPatch.Position = UDim2.new(0, 0, 0.5, 0)
cwPatch.BackgroundColor3 = C.header
cwPatch.BorderSizePixel = 0
cwPatch.ZIndex = 31

mkLabel(cwHdr, {
	text = "Selecciona todo (Ctrl+A) luego copia (Ctrl+C)",
	font = Enum.Font.GothamBold, size = 11, color = C.textMuted,
	sz = UDim2.new(1, -40, 1, 0), pos = UDim2.new(0, 10, 0, 0), z = 32,
})

local cwClose = mkBtn(cwHdr, {
	sz = UDim2.new(0, 26, 0, 26),
	pos = UDim2.new(1, -32, 0.5, -13),
	bg = C.btnClose, text = "X", z = 33, r = 6,
})

local reporteTB = Instance.new("TextBox", copyWindow)
reporteTB.Size = UDim2.new(1, -16, 1, -50)
reporteTB.Position = UDim2.new(0, 8, 0, 44)
reporteTB.BackgroundColor3 = C.panel
reporteTB.BorderSizePixel = 0
reporteTB.Text = ""
reporteTB.TextColor3 = C.text
reporteTB.TextSize = 10
reporteTB.Font = Enum.Font.Code
reporteTB.MultiLine = true
reporteTB.TextWrapped = true
reporteTB.TextXAlignment = Enum.TextXAlignment.Left
reporteTB.TextYAlignment = Enum.TextYAlignment.Top
reporteTB.ClearTextOnFocus = false
reporteTB.ZIndex = 32
corner(reporteTB, 8)
stroke(reporteTB, C.border, 1)
local tbPad = Instance.new("UIPadding", reporteTB)
tbPad.PaddingTop = UDim.new(0,8) tbPad.PaddingLeft = UDim.new(0,8)
tbPad.PaddingRight = UDim.new(0,8) tbPad.PaddingBottom = UDim.new(0,8)

-- ================================================================
-- RENDERIZAR TARJETAS
-- ================================================================
local ultimosHallazgos = {}

local function renderizarHallazgos(hallazgos, filtro)
	for _, ch in ipairs(scroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end

	local cA, cM, cB = 0, 0, 0
	for _, h in ipairs(hallazgos) do
		if h.nivel=="ALTA"  then cA=cA+1 end
		if h.nivel=="MEDIA" then cM=cM+1 end
		if h.nivel=="BAJA"  then cB=cB+1 end
	end
	statLabels.total.Text = tostring(#hallazgos)
	statLabels.alta.Text  = tostring(cA)
	statLabels.media.Text = tostring(cM)
	statLabels.baja.Text  = tostring(cB)

	-- Actualizar botón copiar
	if #hallazgos > 0 then
		copyBtn.BackgroundColor3 = C.btnCopy
		copyBtn.TextColor3 = C.white
	else
		copyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
		copyBtn.TextColor3 = C.textDim
	end

	local filtrados = {}
	for _, h in ipairs(hallazgos) do
		if filtro == "TODOS" or h.nivel == filtro then
			table.insert(filtrados, h)
		end
	end

	if #filtrados == 0 then
		local emptyCard = Instance.new("Frame", scroll)
		emptyCard.Size = UDim2.new(1, 0, 0, 50)
		emptyCard.BackgroundColor3 = C.card
		emptyCard.BorderSizePixel = 0
		emptyCard.LayoutOrder = 1
		emptyCard.ZIndex = 7
		corner(emptyCard, 7)
		mkLabel(emptyCard, {
			text = filtro == "TODOS" and "Sin vulnerabilidades detectadas" or "Sin hallazgos de nivel " .. filtro,
			font = Enum.Font.GothamBold, size = 12, color = C.green,
			sz = UDim2.new(1,0,1,0), xa = Enum.TextXAlignment.Center, z = 8,
		})
		return
	end

	local catActual = ""

	for i, h in ipairs(filtrados) do
		local col = NIVEL_COLOR[h.nivel] or C.baja

		-- Separador de categoría
		if h.categoria ~= catActual then
			catActual = h.categoria
			local sep = Instance.new("Frame", scroll)
			sep.Size = UDim2.new(1, 0, 0, 18)
			sep.BackgroundTransparency = 1
			sep.LayoutOrder = i * 10 - 1
			sep.ZIndex = 7
			mkLabel(sep, {
				text = catActual:upper(),
				font = Enum.Font.GothamBold, size = 9,
				color = C.textDim,
				sz = UDim2.new(1, -10, 1, 0),
				pos = UDim2.new(0, 8, 0, 0), z = 8,
			})
		end

		local card = Instance.new("Frame", scroll)
		card.Size = UDim2.new(1, 0, 0, 72)
		card.BackgroundColor3 = C.card
		card.BorderSizePixel = 0
		card.LayoutOrder = i * 10
		card.ZIndex = 7
		corner(card, 7)
		stroke(card, C.border, 1)

		local barra = Instance.new("Frame", card)
		barra.Size = UDim2.new(0, 3, 1, -10)
		barra.Position = UDim2.new(0, 0, 0, 5)
		barra.BackgroundColor3 = col
		barra.BorderSizePixel = 0
		barra.ZIndex = 8
		corner(barra, 3)

		local badge = Instance.new("Frame", card)
		badge.Size = UDim2.new(0, 52, 0, 16)
		badge.Position = UDim2.new(0, 10, 0, 8)
		badge.BackgroundColor3 = col
		badge.BorderSizePixel = 0
		badge.ZIndex = 8
		corner(badge, 4)
		mkLabel(badge, {
			text = h.nivel, font = Enum.Font.GothamBold,
			size = 9, color = C.white,
			sz = UDim2.new(1,0,1,0),
			xa = Enum.TextXAlignment.Center, z = 9,
		})

		mkLabel(card, {
			text = h.nombre, font = Enum.Font.GothamBold,
			size = 11, color = C.text,
			sz = UDim2.new(1,-72,0,16),
			pos = UDim2.new(0,68,0,7),
			trunc = Enum.TextTruncate.AtEnd, z = 8,
		})

		mkLabel(card, {
			text = "Ruta: " .. h.ruta, size = 9, color = C.textDim,
			sz = UDim2.new(1,-16,0,14),
			pos = UDim2.new(0,10,0,28),
			trunc = Enum.TextTruncate.AtEnd, z = 8,
		})

		mkLabel(card, {
			text = "Consejo: " .. h.detalle, size = 9, color = C.textMuted,
			sz = UDim2.new(1,-16,0,24),
			pos = UDim2.new(0,10,0,44),
			wrap = true, ya = Enum.TextYAlignment.Top, z = 8,
		})
	end
end

-- ================================================================
-- EVENTOS
-- ================================================================
scanBtn.MouseButton1Click:Connect(function()
	scanBtn.Text = "Escaneando..."
	scanBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
	task.wait(0.1)
	ultimosHallazgos = escanearTodo()
	renderizarHallazgos(ultimosHallazgos, filtroActual)
	scanBtn.Text = "Re-escanear"
	scanBtn.BackgroundColor3 = C.btnScan
end)

-- Filtros
for _, f in ipairs(filtros) do
	filtroBtns[f].MouseButton1Click:Connect(function()
		filtroActual = f
		for _, ff in ipairs(filtros) do
			filtroBtns[ff].BackgroundColor3 = Color3.fromRGB(35, 35, 52)
			filtroBtns[ff].TextColor3 = C.textDim
		end
		filtroBtns[f].BackgroundColor3 = C.btnScan
		filtroBtns[f].TextColor3 = C.white
		if #ultimosHallazgos > 0 then
			renderizarHallazgos(ultimosHallazgos, f)
		end
	end)
end

copyBtn.MouseButton1Click:Connect(function()
	if #ultimosHallazgos == 0 then return end
	local texto = generarTexto(ultimosHallazgos)

	if setclipboard then
		local ok = pcall(setclipboard, texto)
		if ok then
			copyBtn.Text = "Copiado!"
			copyBtn.BackgroundColor3 = Color3.fromRGB(40,160,80)
			task.wait(1.5)
			copyBtn.Text = "Copiar"
			copyBtn.BackgroundColor3 = C.btnCopy
			return
		end
	end

	if toclipboard then
		local ok = pcall(toclipboard, texto)
		if ok then
			copyBtn.Text = "Copiado!"
			copyBtn.BackgroundColor3 = Color3.fromRGB(40,160,80)
			task.wait(1.5)
			copyBtn.Text = "Copiar"
			copyBtn.BackgroundColor3 = C.btnCopy
			return
		end
	end

	-- Fallback: ventana con TextBox
	reporteTB.Text = texto
	copyWindow.Visible = true
	task.wait(0.1)
	reporteTB:CaptureFocus()
	reporteTB.SelectionStart = 1
	reporteTB.CursorPosition = #texto + 1
end)

cwClose.MouseButton1Click:Connect(function() copyWindow.Visible = false end)

launchBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	launchBtn.Text = main.Visible and "X Cerrar" or "Game Scanner"
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	launchBtn.Text = "Game Scanner"
end)

print("Game Vulnerability Scanner v1.0 listo.")
