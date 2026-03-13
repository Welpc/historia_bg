local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("ToggleSpeed")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,150,0,50)
button.Position = UDim2.new(0,20,0,20)
button.BackgroundColor3 = Color3.fromRGB(0,120,255)
button.Text = "Speed 40"
button.TextColor3 = Color3.new(1,1,1)
button.TextScaled = true
button.Parent = gui

button.MouseButton1Click:Connect(function()
    remote:FireServer()
end)
