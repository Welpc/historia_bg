-- SuperPoderes MOVIL - LocalScript
-- Coloca en: StarterPlayer > StarterPlayerScripts

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local FLIGHT_SPEED = 80
local WALK_SPEED   = 60
local HIT_RADIUS   = 20
local HIT_FORCE    = 250
local HIT_COOLDOWN = 0.6

local flying     = false
local speedBoost = false
local lastHit    = 0
local bv, bg     = nil, nil

local function getChar()  return player.Character or player.CharacterAdded:Wait() end
local function getHRP()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHuman() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "SPGui"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.Parent         = player.PlayerGui

-- Notif arriba
local notif = Instance.new("TextLabel")
notif.Size                   = UDim2.new(0.7, 0, 0, 46)
notif.Position               = UDim2.new(0.15, 0, 0, 10)
notif.BackgroundColor3       = Color3.fromRGB(20, 20, 20)
notif.BackgroundTransparency = 0.2
notif.TextColor3             = Color3.fromRGB(255, 220, 50)
notif.Font                   = Enum.Font.GothamBold
notif.TextSize               = 16
notif.Text                   = "✅ SuperPoderes listo!"
notif.TextWrapped            = true
notif.ZIndex                 = 10
notif.Parent                 = gui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)

local function notify(msg, color)
    notif.Text             = msg
    notif.TextColor3       = color or Color3.fromRGB(255, 220, 50)
    notif.TextTransparency = 0
    TweenService:Create(notif,
        TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { TextTransparency = 1 }
    ):Play()
end

-- ─── Función para crear botones GRANDES para móvil ──────────────
local function makeBtn(labelText, bgColor, yPos)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(0.55, 0, 0, 70)   -- grande para dedo
    btn.Position               = UDim2.new(0.72, 0, 0, yPos)
    btn.BackgroundColor3       = bgColor
    btn.TextColor3             = Color3.fromRGB(255, 255, 255)
    btn.Font                   = Enum.Font.GothamBold
    btn.TextSize               = 18
    btn.Text                   = labelText
    btn.AutoButtonColor        = false   -- lo manejamos manual
    btn.ZIndex                 = 5
    btn.Parent                 = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness    = 2
    stroke.Color        = Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.6
    stroke.Parent       = btn
    return btn
end

local COL_OFF_VOLAR = Color3.fromRGB(40, 80, 200)
local COL_OFF_SPEED = Color3.fromRGB(140, 30, 200)
local COL_OFF_GOLPE = Color3.fromRGB(200, 50, 30)
local COL_ON        = Color3.fromRGB(30, 180, 80)

local btnVolar = makeBtn("🛸 VOLAR\nOFF", COL_OFF_VOLAR, 80)
local btnSpeed = makeBtn("⚡ SPEED\nOFF", COL_OFF_SPEED, 165)
local btnGolpe = makeBtn("💥 GOLPE\nEXPLOSIVO",  COL_OFF_GOLPE, 250)

-- ════════════════════════════════════════════
-- VUELO
-- ════════════════════════════════════════════
local function enableFlight()
    local hrp   = getHRP()
    local human = getHuman()
    if not hrp or not human then return end
    human.PlatformStand = true

    bv          = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent   = hrp

    bg           = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P         = 1e4
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp
end

local function disableFlight()
    local human = getHuman()
    if bv then bv:Destroy(); bv = nil end
    if bg then bg:Destroy(); bg = nil end
    if human then human.PlatformStand = false end
end

local function toggleFlight()
    flying = not flying
    if flying then
        enableFlight()
        btnVolar.BackgroundColor3 = COL_ON
        btnVolar.Text             = "🛸 VOLAR\n✅ ON"
        notify("🛸 Vuelo ACTIVADO!", Color3.fromRGB(100, 255, 180))
    else
        disableFlight()
        btnVolar.BackgroundColor3 = COL_OFF_VOLAR
        btnVolar.Text             = "🛸 VOLAR\nOFF"
        notify("🛸 Vuelo desactivado")
    end
end

-- ════════════════════════════════════════════
-- VELOCIDAD
-- ════════════════════════════════════════════
local function toggleSpeed()
    speedBoost = not speedBoost
    local human = getHuman()
    if human then
        human.WalkSpeed = speedBoost and WALK_SPEED or 16
    end
    if speedBoost then
        btnSpeed.BackgroundColor3 = COL_ON
        btnSpeed.Text             = "⚡ SPEED\n✅ ON"
        notify("⚡ Super Velocidad ON!", Color3.fromRGB(100, 200, 255))
    else
        btnSpeed.BackgroundColor3 = COL_OFF_SPEED
        btnSpeed.Text             = "⚡ SPEED\nOFF"
        notify("⚡ Velocidad normal")
    end
end

-- ════════════════════════════════════════════
-- GOLPE
-- ════════════════════════════════════════════
local function superPunch()
    local now = tick()
    if now - lastHit < HIT_COOLDOWN then return end
    lastHit = now

    local myHRP = getHRP()
    if not myHRP then return end

    local hit = false
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local oHRP   = other.Character:FindFirstChild("HumanoidRootPart")
            local oHuman = other.Character:FindFirstChildOfClass("Humanoid")
            if oHRP and oHuman and oHuman.Health > 0 then
                if (oHRP.Position - myHRP.Position).Magnitude <= HIT_RADIUS then
                    local dir   = (oHRP.Position - myHRP.Position).Unit
                    local force = Instance.new("BodyVelocity")
                    force.Velocity  = (dir + Vector3.new(0, 0.7, 0)).Unit * HIT_FORCE
                    force.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
                    force.P         = 1e5
                    force.Parent    = oHRP
                    game:GetService("Debris"):AddItem(force, 0.18)
                    hit = true
                end
            end
        end
    end

    -- Flash de pantalla
    local flash = Instance.new("Frame")
    flash.Size                   = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3       = Color3.fromRGB(255, 80, 0)
    flash.BackgroundTransparency = 0.45
    flash.ZIndex                 = 20
    flash.Parent                 = gui
    TweenService:Create(flash, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    game:GetService("Debris"):AddItem(flash, 0.3)

    if hit then
        notify("💥 ¡BOOOOM! ¡A volar!", Color3.fromRGB(255, 80, 80))
    else
        notify("😶 Nadie cerca (radio " .. HIT_RADIUS .. " studs)", Color3.fromRGB(200,200,200))
    end
end

-- ════════════════════════════════════════════
-- CONECTAR BOTONES — usando Activated (funciona en MOVIL)
-- ════════════════════════════════════════════
btnVolar.Activated:Connect(function()
    toggleFlight()
end)

btnSpeed.Activated:Connect(function()
    toggleSpeed()
end)

btnGolpe.Activated:Connect(function()
    superPunch()
end)

-- ════════════════════════════════════════════
-- LOOP DE VUELO
-- ════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    local hrp = getHRP()
    if not hrp then return end

    local move = Vector3.new(0, 0, 0)
    -- Movimiento con joystick/teclado
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move += Vector3.new(0, 1, 0)      end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then move -= Vector3.new(0, 1, 0)      end

    bv.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.new(0, 0, 0)) * FLIGHT_SPEED
    bg.CFrame   = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
end)

-- ════════════════════════════════════════════
-- RESET AL MORIR / REAPARECER
-- ════════════════════════════════════════════
local function onCharAdded(char)
    flying = false; speedBoost = false; bv = nil; bg = nil
    btnVolar.BackgroundColor3 = COL_OFF_VOLAR; btnVolar.Text = "🛸 VOLAR\nOFF"
    btnSpeed.BackgroundColor3 = COL_OFF_SPEED; btnSpeed.Text = "⚡ SPEED\nOFF"
    notify("🔄 Renaciste — poderes listos!")

    local human = char:WaitForChild("Humanoid")
    human.Died:Connect(function()
        flying = false; speedBoost = false
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end)
end

player.CharacterAdded:Connect(onCharAdded)
if player.Character then onCharAdded(player.Character) end

print("[SuperPoderes MOVIL] Listo ✅")
