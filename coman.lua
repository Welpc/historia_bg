-- ============================================================
--  StarterPlayerScripts_Scanner.lua
--  Versión adaptada de RemoveVulnerabilityScanner enfocada
--  en LocalScripts dentro de StarterPlayerScripts.
--
--  USO: Pega en el Command Bar de Roblox Studio y Enter.
-- ============================================================

local SEPARADOR = string.rep("=", 60)

-- ----------------------------------------------------------------
-- Patrones peligrosos (misma estructura que RemoveVulnerabilityScanner)
-- ----------------------------------------------------------------
local PATRONES = {
	{
		pattern  = ":Remove%s*%(",
		nombre   = "Uso de :Remove() obsoleto",
		nivel    = "ALTA",
		consejo  = "Reemplaza :Remove() por :Destroy(). "
		         .. ":Remove() está obsoleto y puede causar errores inesperados.",
	},
	{
		pattern  = "Destroy%s*%(%s*%)",
		nombre   = ":Destroy() sin nil-check previo",
		nivel    = "MEDIA",
		consejo  = "Verifica que el objeto exista antes de llamar :Destroy().\n"
		         .. "  if obj and obj.Parent then obj:Destroy() end",
	},
	{
		pattern  = "FindFirstChild%s*%b()%s*:[A-Za-z]",
		nombre   = "Llamada directa sobre FindFirstChild sin nil-check",
		nivel    = "ALTA",
		consejo  = "FindFirstChild puede devolver nil.\n"
		         .. "  local obj = parent:FindFirstChild('Nombre')\n"
		         .. "  if obj then obj:Destroy() end",
	},
	{
		pattern  = "WaitForChild%s*%(%s*['\"][^'\"]+['\"]%s*%)",
		nombre   = "WaitForChild sin timeout",
		nivel    = "MEDIA",
		consejo  = "Sin timeout puede colgar el LocalScript indefinidamente.\n"
		         .. "  local obj = parent:WaitForChild('Nombre', 5)\n"
		         .. "  if obj then ... end",
	},
	{
		pattern  = "%.Character%s*%.",
		nombre   = "Acceso a Character sin nil-check",
		nivel    = "ALTA",
		consejo  = "Character puede ser nil si el jugador no ha spawneado.\n"
		         .. "  local char = player.Character or player.CharacterAdded:Wait()",
	},
	{
		pattern  = ":FireServer%s*%(",
		nombre   = "FireServer sin validación de datos",
		nivel    = "MEDIA",
		consejo  = "El servidor siempre debe validar los datos recibidos de FireServer.\n"
		         .. "Nunca confíes en datos enviados desde el cliente.",
	},
	{
		pattern  = ":InvokeServer%s*%(",
		nombre   = "InvokeServer sin pcall",
		nivel    = "ALTA",
		consejo  = "InvokeServer puede lanzar error si el servidor falla.\n"
		         .. "  local ok, res = pcall(function()\n"
		         .. "    return remote:InvokeServer(datos)\n"
		         .. "  end)",
	},
	{
		pattern  = "%w+:Connect%s*%(.-function",
		nombre   = "Conexión sin guardar referencia para Disconnect",
		nivel    = "MEDIA",
		consejo  = "Guarda la conexión para poder limpiarla:\n"
		         .. "  local conn = evento:Connect(function() ... end)\n"
		         .. "  -- al limpiar: conn:Disconnect()",
	},
	{
		pattern  = "loadstring%s*%(",
		nombre   = "loadstring() — ejecución dinámica de código",
		nivel    = "ALTA",
		consejo  = "Permite ejecutar código arbitrario. Elimínalo salvo que sea estrictamente necesario.",
	},
	{
		pattern  = "require%s*%(%s*%d+%s*%)",
		nombre   = "require() con ID numérico externo",
		nivel    = "ALTA",
		consejo  = "Cargar módulos por ID numérico puede traer código malicioso de Toolbox.\n"
		         .. "Usa require() con rutas locales dentro de tu juego.",
	},
	{
		pattern  = "^%s*wait%s*%(",
		nombre   = "Uso de wait() global obsoleto",
		nivel    = "MEDIA",
		consejo  = "Reemplaza wait() por task.wait(). El wait() global está obsoleto y es menos preciso.",
	},
	{
		pattern  = "PlayerGui%s*%.",
		nombre   = "Acceso a PlayerGui sin verificar existencia",
		nivel    = "BAJA",
		consejo  = "PlayerGui puede no estar listo de inmediato.\n"
		         .. "  local gui = player:WaitForChild('PlayerGui', 5)",
	},
	{
		pattern  = "%.Backpack%s*%.",
		nombre   = "Acceso a Backpack sin nil-check",
		nivel    = "BAJA",
		consejo  = "Verifica que Backpack exista antes de accederlo.",
	},
	{
		pattern  = "Instance%.new%b()%s*$",
		nombre   = "Instance.new() sin asignar a variable",
		nivel    = "MEDIA",
		consejo  = "Guarda la instancia en una variable para poder destruirla luego\n"
		         .. "y evitar memory leaks.",
	},
	{
		pattern  = "pcall%s*%(",
		nombre   = "Resultado de pcall ignorado",
		nivel    = "BAJA",
		consejo  = "Captura siempre el resultado:\n"
		         .. "  local ok, err = pcall(function() ... end)\n"
		         .. "  if not ok then warn(err) end",
		ignorar_si_asignado = true,
	},
}

-- ----------------------------------------------------------------
-- Prefijos visuales por nivel
-- ----------------------------------------------------------------
local PREFIJO = {
	ALTA  = "🔴 [ALTA]  ",
	MEDIA = "🟡 [MEDIA] ",
	BAJA  = "🔵 [BAJA]  ",
}

-- ----------------------------------------------------------------
-- Escanea el Source de un script línea por línea
-- ----------------------------------------------------------------
local function escanearScript(script)
	local fuente
	local ok = pcall(function() fuente = script.Source end)
	if not ok or not fuente or fuente == "" then return {} end

	local hallazgos = {}
	local lineas = fuente:split("\n")

	for num, linea in ipairs(lineas) do
		local sinComentario = linea:match("^(.-)%-%-.*$") or linea
		if sinComentario:match("^%s*$") then continue end

		for _, patron in ipairs(PATRONES) do
			if sinComentario:find(patron.pattern) then

				-- Caso especial: pcall solo vulnerable si su resultado no se asigna
				if patron.ignorar_si_asignado then
					local tieneAsignacion = linea:match("=%s*pcall") or
					                        (linea:match("local%s+%w") and linea:match("pcall"))
					if tieneAsignacion then goto continuar end
				end

				table.insert(hallazgos, {
					linea  = num,
					codigo = linea:match("^%s*(.-)%s*$"),
					patron = patron,
				})
				break -- un hallazgo por línea para no duplicar
			end
			::continuar::
		end
	end

	return hallazgos
end

-- ----------------------------------------------------------------
-- Recorre StarterPlayerScripts buscando LocalScripts y ModuleScripts
-- ----------------------------------------------------------------
local function recopilarScripts()
	local raiz = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
	if not raiz then
		warn("❌ No se encontró StarterPlayerScripts.")
		return {}
	end

	local lista = {}
	for _, desc in ipairs(raiz:GetDescendants()) do
		if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			table.insert(lista, desc)
		end
	end
	return lista
end

-- ----------------------------------------------------------------
-- Muestra el reporte completo en el Output
-- ----------------------------------------------------------------
local function mostrarReporte(resultados)
	local cAlta, cMedia, cBaja, cArchivos = 0, 0, 0, 0

	print("\n" .. SEPARADOR)
	print("  REPORTE — StarterPlayerScripts Scanner")
	print(SEPARADOR)

	for _, resultado in ipairs(resultados) do
		if #resultado.hallazgos > 0 then
			cArchivos = cArchivos + 1
			print(string.format("\n📄 %s  (%d hallazgo(s))",
				resultado.ruta, #resultado.hallazgos))
			print(string.rep("-", 50))

			for _, h in ipairs(resultado.hallazgos) do
				local nivel = h.patron.nivel
				print(string.format("  %s %s",
					PREFIJO[nivel] or "⚪", h.patron.nombre))
				print(string.format("    Línea %d: %s", h.linea, h.codigo))
				print(string.format("    💡 %s\n", h.patron.consejo))

				if nivel == "ALTA"  then cAlta  = cAlta  + 1 end
				if nivel == "MEDIA" then cMedia = cMedia + 1 end
				if nivel == "BAJA"  then cBaja  = cBaja  + 1 end
			end
		end
	end

	print(SEPARADOR)
	print(string.format("  Scripts analizados : %d", #resultados))
	print(string.format("  Con problemas      : %d", cArchivos))
	print(string.format("  🔴 Alta severidad  : %d", cAlta))
	print(string.format("  🟡 Media severidad : %d", cMedia))
	print(string.format("  🔵 Baja severidad  : %d", cBaja))
	print(SEPARADOR .. "\n")

	if cAlta == 0 and cMedia == 0 and cBaja == 0 then
		print("✅ ¡Sin vulnerabilidades encontradas en StarterPlayerScripts!")
	else
		warn(string.format(
			"StarterPlayerScripts Scanner: %d alta, %d media, %d baja. Revisa el Output.",
			cAlta, cMedia, cBaja
		))
	end
end

-- ----------------------------------------------------------------
-- EJECUCIÓN
-- ----------------------------------------------------------------
print("🔍 StarterPlayerScripts Scanner iniciando...")

local scripts    = recopilarScripts()
local resultados = {}

for _, script in ipairs(scripts) do
	table.insert(resultados, {
		ruta      = script:GetFullName(),
		hallazgos = escanearScript(script),
	})
end

mostrarReporte(resultados)
