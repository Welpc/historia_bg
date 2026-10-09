-- Cambiar el cielo en Brookhaven para todos los jugadores (intento)
-- ADVERTENCIA: En Brookhaven, el servidor controla el ciclo día/noche y el clima.
-- Este script modifica SOLO tu cliente. Para que otros lo vean, necesitarías
-- modificar el Lighting en el servidor, lo cual no es posible desde el cliente.
-- Sin embargo, intentaré usar métodos que a veces se replican a otros clientes.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ============================================================
-- MÉTODO 1: Modificar Lighting directamente (solo visible para ti)
-- ============================================================
local function setSkyForMe()
    -- Eliminar cielo anterior si existe
    local oldSky = Lighting:FindFirstChildOfClass("Sky")
    if oldSky then oldSky:Destroy() end
    
    -- Crear nuevo cielo
    local sky = Instance.new("Sky")
    sky.Name = "CustomSky"
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    sky.SunAngularSize = 21
    sky.MoonAngularSize = 21
    sky.StarCount = 3000
    sky.Parent = Lighting
    
    -- Cambiar colores de iluminación
    Lighting.Ambient = Color3.fromRGB(70, 70, 90)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14 -- 2 PM
    Lighting.GeographicLatitude = 0
    Lighting.FogColor = Color3.fromRGB(200, 200, 255)
    Lighting.FogStart = 100
    Lighting.FogEnd = 1000
    
    return true
end

-- ============================================================
-- MÉTODO 2: Buscar RemoteEvents del servidor de Brookhaven
-- ============================================================
-- Brookhaven tiene RemoteEvents en ReplicatedStorage para clima y cielo
-- Algunos pueden no tener validación server-side estricta

local function findSkyRemotes()
    local remotes = {}
    
    -- Buscar en ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("sky") or name:find("weather") or name:find("time") or name:find("lighting") or name:find("day") then
                table.insert(remotes, obj)
            end
        end
    end
    
    -- Buscar en Lighting
    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, obj)
        end
    end
    
    return remotes
end

-- ============================================================
-- MÉTODO 3: Intentar disparar RemoteEvents (si existen)
-- ============================================================
local function tryFireRemotes()
    local remotes = findSkyRemotes()
    local fired = 0
    
    for _, remote in ipairs(remotes) do
        local success = pcall(function()
            -- Intentar disparar con diferentes argumentos
            remote:FireServer("CustomSky")
            remote:FireServer("Sky", "CustomSky")
            remote:FireServer("SetSky", "CustomSky")
            remote:FireServer("Weather", "Clear")
            remote:FireServer("Time", 14)
            fired = fired + 1
        end)
    end
    
    return fired
end

-- ============================================================
-- MÉTODO 4: Modificar el Sky existente (a veces se replica)
-- ============================================================
local function modifyExistingSky()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then
        -- Modificar propiedades que a veces se replican
        pcall(function()
            sky.SkyboxBk = "rbxassetid://159454299"
            sky.SkyboxDn = "rbxassetid://159454296"
            sky.SkyboxFt = "rbxassetid://159454293"
            sky.SkyboxLf = "rbxassetid://159454286"
            sky.SkyboxRt = "rbxassetid://159454300"
            sky.SkyboxUp = "rbxassetid://159454288"
            sky.StarCount = 5000
        end)
        return true
    end
    return false
end

-- ============================================================
-- INTERFAZ
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkyChanger"
screenGui.ResetOnSpawn = false
screenGui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0.5, -110, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Position = UDim2.new(0, 0, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Cambiar Cielo - Brookhaven"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 40)
info.Position = UDim2.new(0.05, 0, 0, 30)
info.BackgroundTransparency = 1
info.Text = "El cielo solo será visible\npara ti (cliente local)"
info.TextColor3 = Color3.fromRGB(150, 150, 170)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextWrapped = true
info.Parent = frame

local function makeBtn(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 16)
statusLbl.Position = UDim2.new(0, 0, 0, 178)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Listo"
statusLbl.TextColor3 = Color3.fromRGB(140, 146, 170)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 9
statusLbl.Parent = frame

makeBtn("Aplicar cielo personalizado", 76, Color3.fromRGB(46, 190, 130), function()
    setSkyForMe()
    statusLbl.Text = "Cielo aplicado (solo cliente)"
end)

makeBtn("Intentar replicar a todos", 108, Color3.fromRGB(88, 130, 255), function()
    local fired = tryFireRemotes()
    local modified = modifyExistingSky()
    if fired > 0 then
        statusLbl.Text = "Remotes disparados: " .. fired
    elseif modified then
        statusLbl.Text = "Sky modificado (intento de réplica)"
    else
        statusLbl.Text = "No se encontraron remotes de cielo"
    end
end)

makeBtn("Restaurar cielo original", 140, Color3.fromRGB(235, 80, 90), function()
    local sky = Lighting:FindFirstChild("CustomSky")
    if sky then sky:Destroy() end
    statusLbl.Text = "Cielo restaurado"
end)

-- ============================================================
-- EJECUCIÓN AUTOMÁTICA AL CARGAR
-- ============================================================
setSkyForMe()

print("[SkyChanger] Cargado. Cielo modificado localmente.")
print("[SkyChanger] Para intentar replicar a otros, pulsa 'Intentar replicar a todos'.")
print("[SkyChanger] NOTA: En Brookhaven, el cielo es controlado por el servidor.")
print("[SkyChanger] Es probable que otros jugadores NO vean el cambio.")
