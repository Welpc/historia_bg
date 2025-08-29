-- Creamos un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Creamos la bolita roja
local bola = Instance.new("Frame")
bola.Size = UDim2.new(0, 50, 0, 50) -- tamaño 50x50 (chiquita)
bola.Position = UDim2.new(0.5, -25, 0.5, -25) -- centrada
bola.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- rojo
bola.Parent = screenGui

-- Hacemos que sea redonda
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0) -- completamente redonda
corner.Parent = bola

-- Variables para arrastrar
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

-- Cuando toca/click
bola.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = bola.Position
	end
end)

-- Cuando suelta
bola.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Mientras mueve el dedo/mouse
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
-- Creamos un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Bola roja
local bola = Instance.new("Frame")
bola.Size = UDim2.new(0, 50, 0, 50)
bola.Position = UDim2.new(0.5, -25, 0.5, -25)
bola.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bola.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = bola

-- Variables de arrastre
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

-- Menú (oculto al inicio)
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 200, 0, 120)
menu.Position = UDim2.new(0.5, -100, 0.5, -150)
menu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menu.Visible = false
menu.Parent = screenGui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0.1, 0)
corner2.Parent = menu

-- Botón velocidad
local velocidadBtn = Instance.new("TextButton")
velocidadBtn.Size = UDim2.new(1, -20, 0, 40)
velocidadBtn.Position = UDim2.new(0, 10, 0, 10)
velocidadBtn.Text = "Velocidad"
velocidadBtn.TextColor3 = Color3.new(1, 1, 1)
velocidadBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
velocidadBtn.Parent = menu

-- Botón volar
local volarBtn = Instance.new("TextButton")
volarBtn.Size = UDim2.new(1, -20, 0, 40)
volarBtn.Position = UDim2.new(0, 10, 0, 60)
volarBtn.Text = "Volar"
volarBtn.TextColor3 = Color3.new(1, 1, 1)
volarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
volarBtn.Parent = menu

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
