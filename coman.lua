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
local flying = false
local speedy = false
local flyForce

-- Función de vuelo
local function toggleFly()
    flying = not flying
    if flying then
        flyForce = Instance.new("BodyVelocity")
        flyForce.Name = "FlyForce"
        flyForce.MaxForce = Vector3.new(1e5, 1e5, 1e5) -- suficiente para contrarrestar gravedad
        flyForce.Velocity = Vector3.new(0,0,0)
        flyForce.Parent = hrp
    else
        if flyForce then
            flyForce:Destroy()
            flyForce = nil
        end
    end
end

-- Función de velocidad
local function toggleSpeed()
    speedy = not speedy
    humanoid.WalkSpeed = speedy and 100 or 16
end

-- Conectar botones
FlyButton.MouseButton1Click:Connect(toggleFly)
SpeedButton.MouseButton1Click:Connect(toggleSpeed)

-- Mantener vuelo
RunService.RenderStepped:Connect(function()
    if flying and flyForce then
        local moveDir = humanoid.MoveDirection * 50
        -- Agregar fuerza hacia arriba para contrarrestar gravedad
        flyForce.Velocity = moveDir + Vector3.new(0, workspace.Gravity, 0)
    end
end)
