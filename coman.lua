-- LocalScript dentro de StarterPlayerScripts o StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Función para obtener el personaje y sus partes
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local character, humanoid, hrp = getCharacter()

-- Actualizar referencias al respawnear
player.CharacterAdded:Connect(function(char)
    character, humanoid, hrp = getCharacter()
end)

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.Position = UDim2.new(0.5, -110, 0.5, -70)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BackgroundTransparency = 0.2
Frame.Parent = ScreenGui

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 200, 0, 50)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.Text = "✈️ Activar/Desactivar Volar"
FlyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Parent = Frame

local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0, 200, 0, 50)
SpeedButton.Position = UDim2.new(0, 10, 0, 80)
SpeedButton.Text = "🏃‍♂️ Activar/Desactivar Velocidad"
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Parent = Frame

-- Variables de control
local flyingEnabled = false
local flying = false
local speedy = false
local flyVel

-- Activar/desactivar vuelo
local function toggleFly()
    flyingEnabled = not flyingEnabled
    if flyingEnabled then
        flyVel = Instance.new("BodyVelocity")
        flyVel.Name = "FlyVelocity"
        flyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyVel.Velocity = Vector3.new(0,0,0)
        flyVel.Parent = hrp
    else
        if flyVel then
            flyVel:Destroy()
            flyVel = nil
        end
        flying = false
    end
end

-- Activar/desactivar velocidad
local function toggleSpeed()
    speedy = not speedy
    if humanoid then
        humanoid.WalkSpeed = speedy and 100 or 16
    end
end

FlyButton.MouseButton1Click:Connect(toggleFly)
SpeedButton.MouseButton1Click:Connect(toggleSpeed)

-- Detectar tecla de salto
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if flyingEnabled and input.KeyCode == Enum.KeyCode.Space then
        flying = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if flyingEnabled and input.KeyCode == Enum.KeyCode.Space then
        flying = false
    end
end)

-- Mantener vuelo
RunService.RenderStepped:Connect(function()
    if flyingEnabled and flyVel and hrp then
        local moveDir = humanoid.MoveDirection * 50
        local upVel = flying and 50 or 0 -- subir solo mientras mantienes Space
        flyVel.Velocity = moveDir + Vector3.new(0, upVel, 0)
    end
end)
