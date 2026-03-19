-- SuperPoderes GUI LocalScript
-- Coloca en: StarterPlayer > StarterPlayerScripts
-- Tiene botones en pantalla que puedes tocar/clickear

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- ─── CONFIG ────────────────────────────────────────────────────
local FLIGHT_SPEED  = 80
local WALK_SPEED    = 60
local HIT_RADIUS    = 20
local HIT_FORCE     = 250
local HIT_COOLDOWN  = 0.6
-- ───────────────────────────────────────────────────────────────

local flying     = false
local speedBoost = false
local lastHit    = 0
local bv, bg     = nil, nil

local function getChar()  return player.Character or player.CharacterAdded:Wait() end
local function getHRP()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHuman() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ════════════════════════════════════════════════
--  GUI
-- ════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "SuperPoderGUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.Parent         = player.PlayerGui

-- Notificación
local notif = Instance.new("TextLabel")
notif.Size                   = UDim2.new(0, 320, 0, 44)
notif.Position               = UDim2.new(0.5, -160, 0, 12)
notif.BackgroundColor3       = Color3.fromRGB(15,15,15)
notif.BackgroundTransparency = 0.2
notif.TextColor3             = Color3.fromRGB(255, 220, 50)
notif.Font                   = Enum.Font.GothamBold
notif.TextSize               = 17
notif.Text                   = "✅ SuperPoderes cargado"
notif.ZIndex                 = 10
notif.Parent                 = gui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0,10)

local function notify(msg, color)
    notif.Text          = msg
    notif.TextColor3    = color or Color3.fromRGB(255,220,50)
    notif.TextTransparency = 0
    TweenService:Create(notif, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
end

-- ─── Contenedor de botones ──────────────────────────────────────
local frame = Instance.new("Frame")
frame.Size                   = UDim2.new(0, 230, 0, 200)
frame.Position               = UDim2.new(1, -245, 0.5, -100)
frame.BackgroundColor3       = Color3.fromRGB(10,10,10)
frame.BackgroundTransparency = 0.25
frame.Parent                 = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel")
title.Size            = UDim2.new(1,0,0,32)
title.BackgroundTransparency = 1
title.TextColor3      = Color3.fromRGB(255,255,255)
title.Font            = Enum.Font.GothamBold
title.TextSize        = 15
title.Text            = "⚡ SUPER PODERES"
title.Parent          = frame

-- ─── Función para crear botones ─────────────────────────────────
local function makeBtn(text, color, yPos)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, -20, 0, 48)
    btn.Position               = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3       = color
    btn.TextColor3             = Color3.fromRGB(255,255,255)
    btn.Font                   = Enum.Font.GothamBold
    btn.TextSize               = 17
    btn.Text                   = text
    btn.AutoButtonColor        = true
    btn.Parent                 = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    -- Sombra/borde
    local stroke = Instance.new("UIStroke")
    stroke.Color     = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.7
    stroke.Parent    = btn

    return btn
end

local btnVolar  = makeBtn("🛸  VOLAR  —  OFF", Color3.fromRGB(40,80,200),  36)
local btnSpeed  = makeBtn("⚡  SPEED  —  OFF", Color3.fromRGB(160,40,200), 94)
local btnGolpe  = makeBtn("💥  GOLPE EXPLOSIVO",Color3.fromRGB(200,60,30), 152)

-- ════════════════════════════════════════════════
--  VUELO
-- ════════════════════════════════════════════════
local function enableFlight()
    local hrp   = getHRP()
    local human = getHuman()
    if not hrp or not human then return end
    human.PlatformStand = true

    bv           = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(0,0,0)
    bv.MaxForce  = Vector3.new(1e5,1e5,1e5)
    bv.Parent    = hrp

    bg           = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
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
        btnVolar.Text             = "🛸  VOLAR  —  ON ✅"
        btnVolar.BackgroundColor3 = Color3.fromRGB(30,180,90)
        notify("🛸 Vuelo ON — usa WASD para moverte, Q/E subir/bajar", Color3.fromRGB(100,255,180))
    else
        disableFlight()
        btnVolar.Text             = "🛸  VOLAR  —  OFF"
        btnVolar.BackgroundColor3 = Color3.fromRGB(40,80,200)
        notify("🛸 Vuelo OFF", Color3.fromRGB(200,200,200))
    end
end

-- ════════════════════════════════════════════════
--  VELOCIDAD
-- ════════════════════════════════════════════════
local function toggleSpeed()
    speedBoost = not speedBoost
    local human = getHuman()
    if human then
        human.WalkSpeed = speedBoost and WALK_SPEED or 16
    end
    if speedBoost then
        btnSpeed.Text             = "⚡  SPEED  —  ON ✅"
        btnSpeed.BackgroundColor3 = Color3.fromRGB(30,180,90)
        notify("⚡ Super Velocidad ON", Color3.fromRGB(100,200,255))
    else
        btnSpeed.Text             = "⚡  SPEED  —  OFF"
        btnSpeed.BackgroundColor3 = Color3.fromRGB(160,40,200)
        notify("⚡ Velocidad normal", Color3.fromRGB(200,200,200))
    end
end

-- ════════════════════════════════════════════════
--  GOLPE EXPLOSIVO
-- ════════════════════════════════════════════════
local function superPunch()
    local now = tick()
    if now - lastHit < HIT_COOLDOWN then
        notify("⏳ Espera un momento...", Color3.fromRGB(255,150,50))
        return
    end
    lastHit = now

    local myHRP = getHRP()
    if not myHRP then return end

    local hit = false
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local otherHRP   = other.Character:FindFirstChild("HumanoidRootPart")
            local otherHuman = other.Character:FindFirstChildOfClass("Humanoid")
            if otherHRP and otherHuman and otherHuman.Health > 0 then
                local dist = (otherHRP.Position - myHRP.Position).Magnitude
                if dist <= HIT_RADIUS then
                    local dir = (otherHRP.Position - myHRP.Position).Unit
                    local force = Instance.new("BodyVelocity")
                    force.Velocity  = (dir + Vector3.new(0, 0.7, 0)).Unit * HIT_FORCE
                    force.MaxForce  = Vector3.new(1e6,1e6,1e6)
                    force.P         = 1e5
                    force.Parent    = otherHRP
                    game:GetService("Debris"):AddItem(force, 0.18)
                    hit = true
                end
            end
        end
    end

    -- Flash visual
    local flash = Instance.new("Frame")
    flash.Size                   = UDim2.new(1,0,1,0)
    flash.BackgroundColor3       = Color3.fromRGB(255,100,0)
    flash.BackgroundTransparency = 0.5
    flash.ZIndex                 = 20
    flash.Parent                 = gui
    TweenService:Create(flash, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
    game:GetService("Debris"):AddItem(flash, 0.3)

    if hit then
        notify("💥 ¡BOOOOM! ¡A volar!", Color3.fromRGB(255,80,80))
    else
        notify("😶 No hay nadie cerca (radio: "..HIT_RADIUS.." studs)", Color3.fromRGB(200,200,200))
    end
end

-- ════════════════════════════════════════════════
--  CONECTAR BOTONES
-- ════════════════════════════════════════════════
btnVolar.MouseButton1Click:Connect(toggleFlight)
btnSpeed.MouseButton1Click:Connect(toggleSpeed)
btnGolpe.MouseButton1Click:Connect(superPunch)

-- También funciona con teclado
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F then toggleFlight()
    elseif inp.KeyCode == Enum.KeyCode.G then toggleSpeed()
    elseif inp.KeyCode == Enum.KeyCode.H then superPunch()
    end
end)

-- ════════════════════════════════════════════════
--  LOOP DE VUELO
-- ════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    local hrp = getHRP()
    if not hrp then return end

    local move = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then move -= Vector3.new(0,1,0) end

    bv.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.new(0,0,0)) * FLIGHT_SPEED
    bg.CFrame   = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
end)

-- ════════════════════════════════════════════════
--  RESET AL MORIR
-- ════════════════════════════════════════════════
local function onCharAdded(char)
    flying = false; speedBoost = false; bv = nil; bg = nil
    btnVolar.Text = "🛸  VOLAR  —  OFF"; btnVolar.BackgroundColor3 = Color3.fromRGB(40,80,200)
    btnSpeed.Text = "⚡  SPEED  —  OFF"; btnSpeed.BackgroundColor3 = Color3.fromRGB(160,40,200)
    notify("🔄 Renaciste — poderes listos!", Color3.fromRGB(255,220,50))

    local human = char:WaitForChild("Humanoid")
    human.Died:Connect(function()
        flying = false; speedBoost = false
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end)

    -- Aplicar velocidad si estaba activa
    if speedBoost then human.WalkSpeed = WALK_SPEED end
end

player.CharacterAdded:Connect(onCharAdded)
if player.Character then onCharAdded(player.Character) end

print("[SuperPoderes GUI] Listo ✅")
