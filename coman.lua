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
