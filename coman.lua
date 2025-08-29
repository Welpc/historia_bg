-- Creamos un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Creamos el botón rojo
local boton = Instance.new("TextButton")
boton.Size = UDim2.new(0, 100, 0, 50)
boton.Position = UDim2.new(0.5, -50, 0.5, -25) -- centrado
boton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
boton.Text = "Mover"
boton.Parent = screenGui

-- Variables para arrastrar
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

-- Cuando empieza el toque/click
boton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or 
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = boton.Position
	end
end)

-- Cuando termina el toque/click
boton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or 
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Mientras mueves el dedo/mouse
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		boton.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)
