-- SkyChanger para Brookhaven (solo tu cliente, funciona al 100% para ti)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Guardar estado original para restaurar
local original = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
}
local originalSkies = {}
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("Sky") then table.insert(originalSkies, v:Clone()) end
end

-- Presets (puedes cambiar los IDs por otros skyboxes válidos)
local presets = {
    Dia = {clock = 14, ambient = Color3.fromRGB(128,128,128), bright = 2,
        sky = {159454299,159454296,159454293,159454286,159454300,159454288}},
    Atardecer = {clock = 18, ambient = Color3.fromRGB(150,100,90), bright = 1.5,
        sky = {159454299,159454296,159454293,159454286,159454300,159454288}},
    Noche = {clock = 0, ambient = Color3.fromRGB(40,40,70), bright = 1,
        sky = {159454299,159454296,159454293,159454286,159454300,159454288}},
}

local active = nil -- preset activo

local function applyPreset(p)
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") and v.Name ~= "CustomSky" then v:Destroy() end
    end
    local sky = Lighting:FindFirstChild("CustomSky") or Instance.new("Sky")
    sky.Name = "CustomSky"
    local f = p.sky
    sky.SkyboxBk = "rbxassetid://"..f[1]
    sky.SkyboxDn = "rbxassetid://"..f[2]
    sky.SkyboxFt = "rbxassetid://"..f[3]
    sky.SkyboxLf = "rbxassetid://"..f[4]
    sky.SkyboxRt = "rbxassetid://"..f[5]
    sky.SkyboxUp = "rbxassetid://"..f[6]
    sky.StarCount = 3000
    sky.Parent = Lighting
    Lighting.ClockTime = p.clock
    Lighting.Ambient = p.ambient
    Lighting.OutdoorAmbient = p.ambient
    Lighting.Brightness = p.bright
end

-- Mantener el cielo aunque el servidor lo cambie
local conn = RunService.RenderStepped:Connect(function()
    if active then
        if not Lighting:FindFirstChild("CustomSky") or Lighting.ClockTime ~= active.clock then
            applyPreset(active)
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") and v.Name ~= "CustomSky" then v:Destroy() end
        end
    end
end)

local function restore()
    active = nil
    local s = Lighting:FindFirstChild("CustomSky")
    if s then s:Destroy() end
    for _, sk in ipairs(originalSkies) do sk:Clone().Parent = Lighting end
    for k, v in pairs(original) do Lighting[k] = v end
end

-- Interfaz
local old = LP.PlayerGui:FindFirstChild("SkyChanger")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SkyChanger"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 210)
frame.Position = UDim2.new(0.5, -110, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,26)
title.BackgroundTransparency = 1
title.Text = "Cambiar Cielo (solo tú lo ves)"
title.TextColor3 = Color3.fromRGB(200,220,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local function makeBtn(text, y, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9,0,0,30)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

makeBtn("Día", 32, Color3.fromRGB(46,190,130), function() active = presets.Dia; applyPreset(active) end)
makeBtn("Atardecer", 68, Color3.fromRGB(230,140,60), function() active = presets.Atardecer; applyPreset(active) end)
makeBtn("Noche", 104, Color3.fromRGB(88,130,255), function() active = presets.Noche; applyPreset(active) end)
makeBtn("Restaurar original", 140, Color3.fromRGB(235,80,90), restore)
makeBtn("Cerrar", 174, Color3.fromRGB(70,70,85), function()
    conn:Disconnect()
    restore()
    gui:Destroy()
end)

active = presets.Dia
applyPreset(active)
