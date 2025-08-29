-- Creamos un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Bola roja (drag)
local bola = Instance.new("Frame")
bola.Size = UDim2.new(0, 50, 0, 50)
bola.Position = UDim2.new(0.5, -25, 0.5, -25)
bola.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bola.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = bola

-- Variables para arrastrar
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

-- Menú (oculto al inicio)
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 220, 0, 150)
menu.Position = UDim2.new(0.5, -110, 0.5, -150)
menu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menu.Visible = false
menu.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0.1, 0)
corner2.Parent = menu

-- Botón Volar
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 200, 0, 50)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.Text = "✈️ Activar/Desactivar Volar"
FlyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Parent = menu

-- Botón Velocidad
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0, 200, 0, 50)
SpeedButton.Position = UDim2.new(0, 10, 0, 80)
SpeedButton.Text = "🏃‍♂️ Activar/Desactivar Velocidad"
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Parent = menu

-- Animación LED del menú
task.spawn(function()
	while true do
		for h = 0, 1, 0.01 do
			menu.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			task.wait(0.05)
		end
	end
end)

-- Abrir / cerrar menú al clickear la bola
bola.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		menu.Visible = not menu.Visible
	end
end)

-- Arrastrar la bola
bola.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = bola.Position
	end
end)

bola.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		bola.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)
