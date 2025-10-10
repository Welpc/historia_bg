-- Sistema de Vuelo estilo Blockman Go para Roblox
-- Colocar este script en StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variables de vuelo
local isFlying = false
local flySpeed = 50
local verticalSpeed = 30
local bodyVelocity
local bodyGyro
local flightConnection

-- Controles
local moveUp = false
local moveDown = false
local touchpadVector = Vector2.new(0, 0)
local touchpadActive = false

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Función para crear botones
local function createButton(name, position, size, backgroundColor)
	local button = Instance.new("ImageButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = backgroundColor or Color3.fromRGB(60, 60, 60)
	button.BackgroundTransparency = 0.5
	button.BorderSizePixel = 0
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = button

	return button
end

-- Botón de vuelo (ala)
local flyButton = createButton(
	"FlyButton",
	UDim2.new(1, -70, 0.55, 0),
	UDim2.new(0, 60, 0, 60),
	Color3.fromRGB(70, 70, 70)
)

-- Crear icono de ala personalizado
local flyIcon = Instance.new("Frame")
flyIcon.Size = UDim2.new(0.6, 0, 0.4, 0)
flyIcon.Position = UDim2.new(0.2, 0, 0.3, 0)
flyIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
flyIcon.BorderSizePixel = 0
flyIcon.Parent = flyButton

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(1, 0)
flyCorner.Parent = flyIcon

-- Botón subir (flecha arriba) - OCULTO AL INICIO
local upButton = createButton(
	"UpButton",
	UDim2.new(1, -70, 0.59, -68),
	UDim2.new(0, 60, 0, 50),
	Color3.fromRGB(60, 60, 60)
)
upButton.Visible = false

local upArrow = Instance.new("TextLabel")
upArrow.Size = UDim2.new(1, 0, 1, 0)
upArrow.BackgroundTransparency = 1
upArrow.Text = "▲"
upArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
upArrow.TextSize = 20
upArrow.Font = Enum.Font.GothamBold
upArrow.Parent = upButton

-- Botón bajar (flecha abajo) - OCULTO AL INICIO
local downButton = createButton(
	"DownButton",
	UDim2.new(1, -70, 0.56, 60),
	UDim2.new(0, 60, 0, 50),
	Color3.fromRGB(60, 60, 60)
)
downButton.Visible = false

local downArrow = Instance.new("TextLabel")
downArrow.Size = UDim2.new(1, 0, 1, 0)
downArrow.BackgroundTransparency = 1
downArrow.Text = "▼"
downArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
downArrow.TextSize = 20
downArrow.Font = Enum.Font.GothamBold
downArrow.Parent = downButton

-- Función para manejar el touchpad de Roblox
local function handleTouchpad(actionName, inputState, inputObject)
	if actionName == "FlightTouchpad" then
		if inputState == Enum.UserInputState.Begin then
			touchpadActive = true
			touchpadVector = Vector2.new(0, 0)
		elseif inputState == Enum.UserInputState.Change then
			if touchpadActive then
				-- Usar el vector de movimiento del touchpad
				touchpadVector = Vector2.new(inputObject.Delta.X, inputObject.Delta.Y)

				-- Limitar la magnitud máxima
				if touchpadVector.Magnitude > 10 then
					touchpadVector = touchpadVector.Unit * 10
				end
			end
		elseif inputState == Enum.UserInputState.End then
			touchpadActive = false
			touchpadVector = Vector2.new(0, 0)
		end
		return Enum.ContextActionResult.Sink
	end
end

-- Función para activar vuelo
local function startFlying()
	if isFlying then return end
	isFlying = true

	-- Cambiar color del botón cuando está activo
	flyButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)

	-- Mostrar botones de flechas
	upButton.Visible = true
	downButton.Visible = true

	-- Crear BodyVelocity
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = rootPart

	-- Crear BodyGyro
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
	bodyGyro.P = 10000
	bodyGyro.D = 500
	bodyGyro.Parent = rootPart

	humanoid.PlatformStand = true

	-- Activar el touchpad de Roblox para móvil
	ContextActionService:BindAction("FlightTouchpad", handleTouchpad, false, Enum.UserInputType.Touch)

	-- Iniciar loop de vuelo constante
	flightConnection = RunService.Heartbeat:Connect(function()
		if not isFlying or not bodyVelocity or not bodyGyro then return end

		-- Obtener dirección de la cámara
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame

		-- Movimiento combinado (teclado + touchpad)
		local moveDirection = Vector3.new(0, 0, 0)

		-- Controles de teclado (PC)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + cameraCFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - cameraCFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - cameraCFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + cameraCFrame.RightVector
		end

		-- Controles de touchpad (Móvil) - como el de Roblox
		if touchpadActive and touchpadVector.Magnitude > 0 then
			-- Convertir el vector 2D del touchpad a dirección 3D del mundo
			local worldDirection = (cameraCFrame.LookVector * -touchpadVector.Y) + (cameraCFrame.RightVector * touchpadVector.X)
			moveDirection = moveDirection + worldDirection
		end

		-- Eliminar componente Y para movimiento horizontal puro
		moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)

		-- Normalizar dirección si hay input
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end

		-- Aplicar velocidad horizontal
		local velocity = moveDirection * flySpeed

		-- Aplicar movimiento vertical
		if moveUp then
			velocity = velocity + Vector3.new(0, verticalSpeed, 0)
		elseif moveDown then
			velocity = velocity + Vector3.new(0, -verticalSpeed, 0)
		end

		bodyVelocity.Velocity = velocity

		-- Orientar el personaje según la cámara (solo rotación horizontal)
		local lookVector = cameraCFrame.LookVector
		local horizontalLookVector = Vector3.new(lookVector.X, 0, lookVector.Z)

		if horizontalLookVector.Magnitude > 0 then
			bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + horizontalLookVector)
		end
	end)
end

-- Función para desactivar vuelo
local function stopFlying()
	if not isFlying then return end
	isFlying = false

	flyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

	-- Ocultar botones de flechas
	upButton.Visible = false
	downButton.Visible = false

	-- Desconectar el loop de vuelo
	if flightConnection then
		flightConnection:Disconnect()
		flightConnection = nil
	end

	-- Desactivar el touchpad
	ContextActionService:UnbindAction("FlightTouchpad")

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	humanoid.PlatformStand = false
	moveUp = false
	moveDown = false
	touchpadActive = false
	touchpadVector = Vector2.new(0, 0)
end

-- Botón de vuelo toggle
flyButton.MouseButton1Click:Connect(function()
	if isFlying then
		stopFlying()
	else
		startFlying()
	end
end)

-- Botón subir
upButton.MouseButton1Down:Connect(function()
	moveUp = true
end)

upButton.MouseButton1Up:Connect(function()
	moveUp = false
end)

-- Botón bajar
downButton.MouseButton1Down:Connect(function()
	moveDown = true
end)

downButton.MouseButton1Up:Connect(function()
	moveDown = false
end)

-- Soporte para teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.F then
		if isFlying then
			stopFlying()
		else
			startFlying()
		end
	elseif input.KeyCode == Enum.KeyCode.Space and isFlying then
		moveUp = true
	elseif input.KeyCode == Enum.KeyCode.LeftShift and isFlying then
		moveDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		moveUp = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		moveDown = false
	end
end)

-- Manejar touch directo en la pantalla (como backup)
UserInputService.TouchStarted:Connect(function(input, gameProcessed)
	if gameProcessed or not isFlying then return end

	-- Si el touch no es en los botones UI, activar movimiento
	local touchPos = input.Position
	local guiObjects = screenGui:GetGuiObjectsAtPosition(touchPos.X, touchPos.Y)

	if #guiObjects == 0 then
		-- Touch en área vacía de la pantalla - podrías usar esto para movimiento alternativo
	end
end)

-- Manejar respawn del personaje
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	-- Detener vuelo si el personaje muere y respawn
	stopFlying()

	-- Reconectar evento died
	humanoid.Died:Connect(function()
		stopFlying()
	end)
end)

-- Limpiar al morir
humanoid.Died:Connect(function()
	stopFlying()
end)

print("Sistema de vuelo Blockman Go cargado!")
print("Presiona el botón de ala o tecla F para volar")
print("Usa WASD para moverte y los botones/Space/Shift para subir/bajar")
print("En móvil: desliza el dedo en la pantalla para moverte (como en Roblox normal)")
