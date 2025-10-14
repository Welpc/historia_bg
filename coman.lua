-- Configuración del vuelo
local velocidadVuelo = 10 -- Velocidad a la que el jugador se mueve hacia arriba
local velocidadMovimiento = 5 -- Velocidad a la que el jugador se mueve hacia los lados o hacia adelante/atrás

-- Servicios
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Obtener el carácter del jugador
local jugador = Players.LocalPlayer
local caracter = jugador.Character or jugador.CharacterAdded:Wait()

-- Esperar a que el carácter esté listo
while not caracter do
	caracter = jugador.Character
	wait()
end

-- Obtener el humanoide y la parte raíz
local humano = caracter:WaitForChild("Humanoid")
local parteRaiz = caracter:WaitForChild("HumanoidRootPart")

-- Variables para controlar el vuelo
local estaVolando = false

-- Función para hacer que el jugador vuele
local function volar()
	if not estaVolando then
		estaVolando = true
		humano.JumpPower = velocidadVuelo * 10 -- Ajusta el poder de salto para simular el impulso hacia arriba
		humano.Jump = true -- Hacer que el jugador salte hacia arriba
	end
end

-- Función para detener el vuelo
local function detenerVuelo()
	estaVolando = false
	humano.JumpPower = 50 -- Restablecer el poder de salto
end

-- Conexión para eventos de input
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then -- Cambia Enum.KeyCode.Space por cualquier otra tecla que desees
		volar()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then -- Cambia Enum.KeyCode.Space por cualquier otra tecla que desees
		detenerVuelo()
	end
end)

-- Mover al jugador hacia arriba mientras se mantiene la tecla
RunService.RenderStepped:Connect(function()
	if estaVolando then
		parteRaiz.Velocity = Vector3.new(parteRaiz.Velocity.X, velocidadVuelo, parteRaiz.Velocity.Z)
	end
end)
