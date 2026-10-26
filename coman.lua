--[[
=============================================================
   VUELO + VELOCIDAD SIGILOSOS  —  Delta Executor
   Hecho por Venice
-------------------------------------------------------------
   F                -> Vuelo ON / OFF
   W A S D          -> Moverse
   Espacio / Shift  -> Subir / Bajar
   + / -            -> Velocidad de vuelo
   G                -> Speed ON / OFF
   [ / ]            -> Velocidad al caminar
=============================================================
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

-- ================== CONFIGURACIÓN ==================
local CONFIG = {
    -- "BodyVelocity" = mas estable
    -- "CFrame"       = CERO instancias en el personaje (maximo sigilo)
    MetodoVuelo       = "BodyVelocity",

    VelocidadVuelo    = 60,    -- studs/seg al volar
    VelocidadCaminar  = 40,    -- studs/seg al correr (16 = normal)

    UsarPlatformStand = false, -- true = mas suave | false = mas sigiloso
    BloquearVelocidad = false, -- true = re-aplica tu velocidad si el juego la cambia
}

local volando     = false
local speedOn     = false
local velVuelo    = CONFIG.VelocidadVuelo
local velCaminar  = CONFIG.VelocidadCaminar
local velOriginal = 16
local bv, bg

-- ======================= GUI =======================
local gui = Instance.new("ScreenGui")
gui.Name           = "FlyStealth"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 180, 0, 104)
panel.Position         = UDim2.new(0, 20, 0, 140)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
panel.BorderSizePixel  = 0
panel.Active           = true
panel.Draggable        = true
panel.Parent           = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local function crearBoton(texto, y)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, -20, 0, 28)
    b.Position         = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(52, 52, 62)
    b.TextColor3       = Color3.fromRGB(255, 255, 255)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.Text             = texto
    b.BorderSizePixel  = 0
    b.Parent           = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local btnVuelo = crearBoton("VUELO: OFF", 8)
local btnSpeed = crearBoton("SPEED: OFF", 42)

local lblInfo = Instance.new("TextLabel")
lblInfo.Size                   = UDim2.new(1, -20, 0, 16)
lblInfo.Position               = UDim2.new(0, 10, 0, 78)
lblInfo.BackgroundTransparency = 1
lblInfo.TextColor3             = Color3.fromRGB(175, 175, 190)
lblInfo.Font                   = Enum.Font.Gotham
lblInfo.TextSize               = 12
lblInfo.Text                   = "Vuelo: " .. velVuelo .. "  |  Correr: " .. velCaminar
lblInfo.Parent                 = panel

local function actualizarInfo()
    lblInfo.Text = "Vuelo: " .. velVuelo .. "  |  Correr: " .. velCaminar
end

-- ==================== VUELO ====================
local function detenerVuelo()
    volando = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    btnVuelo.Text = "VUELO: OFF"
    btnVuelo.BackgroundColor3 = Color3.fromRGB(52, 52, 62)

    if CONFIG.UsarPlatformStand then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function iniciarVuelo()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    volando = true
    btnVuelo.Text = "VUELO: ON"
    btnVuelo.BackgroundColor3 = Color3.fromRGB(38, 140, 80)

    if CONFIG.UsarPlatformStand then hum.PlatformStand = true end

    if CONFIG.MetodoVuelo == "BodyVelocity" then
        bv = Instance.new("BodyVelocity")
        bv.Name     = "FlyBV"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent   = hrp

        bg = Instance.new("BodyGyro")
        bg.Name     
