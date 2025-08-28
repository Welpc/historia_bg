-- LocalScript dentro de StarterPlayerScripts o StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Esperar al personaje
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local character, humanoid, hrp = getCharacter()

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

-- Botón Volar
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 200, 0, 50)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.Text = "?? Activar/Desactivar Volar"
FlyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Parent = Frame

-- Botón Velocidad
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0, 200, 0, 50)
SpeedButton.Position = UDim2.new(0, 10, 0, 80)
SpeedButton.Text = "????? Activar/Desactivar Velocidad"
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Parent = Frame

-- Variables de control
local flying = false
local speedy = false
local flyVel

-- Función de vuelo
local function toggleFly()
    flying = not flying
    if flying then
        flyVel = Instance.new("BodyVelocity")
        flyVel.Name = "FlyVel"
        flyVel.MaxForce = Vector3.new(4000, 4000, 4000)
        flyVel.Velocity = Vector3.new(0, 0, 0)
        flyVel.Parent = hrp
    else
        if flyVel then
            flyVel:Destroy()
            flyVel = nil
        end
    end
end

-- Función de velocidad
local function toggleSpeed()
    speedy = not speedy
    if speedy then
        humanoid.WalkSpeed = 100
    else
        humanoid.WalkSpeed = 16
    end
end

-- Conectar botones
FlyButton.MouseButton1Click:Connect(toggleFly)
SpeedButton.MouseButton1Click:Connect(toggleSpeed)

-- Actualizar vuelo en cada frame
RunService.RenderStepped:Connect(function()
    if flying and flyVel then
        local direction = Vector3.new(0,0,0)
        local move = humanoid.MoveDirection
        direction = move * 50
        -- Mantener un poco de altura
        direction = direction + Vector3.new(0, 50, 0)
        flyVel.Velocity = direction
    end
end)
