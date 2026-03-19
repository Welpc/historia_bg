-- Botón para explotar BuyCandyEvent
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui", playerGui)
sg.ResetOnSpawn = false

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.5, -25)
btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
btn.Text = "DAR CANDY INFINITO"
btn.TextColor3 = Color3.white
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14

btn.MouseButton1Click:Connect(function()
    btn.Text = "Ejecutando..."
    for i = 1, 500 do
        game.ReplicatedStorage.BuyCandyEvent:FireServer()
        task.wait(0.05)
    end
    btn.Text = "LISTO :)"
end)
