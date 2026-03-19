-- SuperPoderes MOVIL v3 - LocalScript
-- Coloca en: StarterPlayer > StarterPlayerScripts

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local FLIGHT_SPEED = 60
local WALK_SPEED   = 55
local HIT_RADIUS   = 18
local HIT_FORCE    = 220
local HIT_CD       = 0.5

local flying     = false
local speedOn    = false
local lastHit    = 0
local bv, bg     = nil, nil

local function getChar()  return player.Character or player.CharacterAdded:Wait() end
local function getHRP()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHuman() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════
-- GUI
-- ══════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "SPv3"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.Parent         = player.PlayerGui

-- Notif
local notif = Instance.new("TextLabel")
notif.Size                   = UDim2.new(0.6, 0, 0, 34)
notif.Position               = UDim2.new(0.2, 0, 0, 8)
notif.BackgroundColor3       = Color3.fromRGB(15,15,15)
notif.BackgroundTransparency = 0.25
notif.TextColor3             = Color3.fromRGB(255,220,50)
notif.Font                   = Enum.Font.GothamBold
notif.TextSize               = 13
notif.Text                   = "✅ Poderes listos"
notif.TextWrapped            = true
notif.ZIndex                 = 10
notif.Parent                 = gui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)

local function notify(msg, col)
    notif.Text = msg
    notif.TextColor3 = col or Color3.fromRGB(255,220,50)
    notif.TextTransparency = 0
    TweenService:Create(notif, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=1}):Play()
end

-- Botones pequeños apilados en esquina derecha
local COL_VOLAR_OFF = Color3.fromRGB(30,80,210)
local COL_SPEED_OFF = Color3.fromRGB(130,20,200)
local COL_GOLPE     = Color3.fromRGB(200,45,25)
local COL_ON        = Color3.fromRGB(20,170,70)

local function makeBtn(txt, col, yPos)
    local b = Instance.new("TextButton")
    b.Size                   = UDim2.new(0, 100, 0, 42)
    b.Position               = UDim2.new(1, -108, 0, yPos)
    b.BackgroundColor3       = col
    b.TextColor3             = Color3.fromRGB(255,255,255)
    b.Font                   = Enum.Font.GothamBold
    b.TextSize               = 13
    b.Text                   = txt
    b.AutoButtonColor        = false
    b.ZIndex                 = 5
    b.Parent                 = gui
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    local st = Instance.new("UIStroke")
    st.Thickness = 1.5; st.Color = Color3.fromRGB(255,255,255); st.Transparency = 0.65; st.Parent = b
    return b
end

local btnVolar = makeBtn("🛸 VOLAR\nOFF", COL_VOLAR_OFF, 90)
local btnSpeed = makeBtn("⚡ SPEED\nOFF", COL_SPEED_OFF, 143)
local btnGolpe = makeBtn("💥 GOLPE", COL_GOLPE, 196)

-- ══════════════════════════════════════
-- VUELO (usando AlignPosition + AlignOrientation — más confiable)
-- ══════════════════════════════════════
local alignPos, alignOri

local function enableFlight()
    local hrp   = getHRP()
    local human = getHuman()
    if not hrp or not human then return end

    -- Quitar gravedad
    human.PlatformStand = true

    -- BodyVelocity para mover
    bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(0, 0, 0)
    bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv.P         = 1e4
    bv.Parent    = hrp

    -- BodyGyro para orientación
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P         = 1e4
    bg.D         = 100
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp
end

local function disableFlight()
    if bv then bv:Destroy(); bv = nil end
    if bg then bg:Destroy(); bg = nil end
    local human = getHuman()
    if human then
        human.PlatformStand = false
    end
end

local function toggleFlight()
    flying = not flying
    if flying then
        enableFlight()
        btnVolar.BackgroundColor3 = COL_ON
        btnVolar.Text             = "🛸 VOLAR\n✅ ON"
        notify("🛸 Vuelo ON — muévete con joystick", Color3.fromRGB(80,255,160))
    else
        disableFlight()
        btnVolar.BackgroundColor3 = COL_VOLAR_OFF
        btnVolar.Text             = "🛸 VOLAR\nOFF"
        notify("🛸 Vuelo OFF")
    end
end

-- ══════════════════════════════════════
-- SPEED
-- ══════════════════════════════════════
local function toggleSpeed()
    speedOn = not speedOn
    local human = getHuman()
    if human then human.WalkSpeed = speedOn and WALK_SPEED or 16 end
    if speedOn then
        btnSpeed.BackgroundColor3 = COL_ON
        btnSpeed.Text             = "⚡ SPEED\n✅ ON"
        notify("⚡ Speed ON!", Color3.fromRGB(100,180,255))
    else
        btnSpeed.BackgroundColor3 = COL_SPEED_OFF
        btnSpeed.Text             = "⚡ SPEED\nOFF"
        notify("⚡ Speed OFF")
    end
end

-- ══════════════════════════════════════
-- GOLPE MEJORADO
-- Busca el jugador MÁS CERCANO y lo lanza
-- También hace daño si el juego lo permite
-- ══════════════════════════════════════
local function superPunch()
    local now = tick()
    if now - lastHit < HIT_CD then return end
    lastHit = now

    local myHRP = getHRP()
    if not myHRP then return end
    local myPos = myHRP.Position

    -- Encontrar el jugador más cercano
    local closest, closestDist, closestHRP = nil, HIT_RADIUS + 1, nil

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local oHRP = other.Character:FindFirstChild("HumanoidRootPart")
            if oHRP then
                local d = (oHRP.Position - myPos).Magnitude
                if d < closestDist then
                    closestDist  = d
                    closest      = other
                    closestHRP   = oHRP
                end
            end
        end
    end

    if closest and closestHRP then
        local oHuman = closest.Character:FindFirstChildOfClass("Humanoid")

        -- Dirección del golpe (hacia arriba y lejos)
        local dir = (closestHRP.Position - myPos)
        dir = Vector3.new(dir.X, 0, dir.Z).Unit  -- horizontal primero
        local launchDir = (dir + Vector3.new(0, 1.2, 0)).Unit  -- arco hacia arriba

        -- Aplicar fuerza fuerte
        local force = Instance.new("BodyVelocity")
        force.Velocity  = launchDir * HIT_FORCE
        force.MaxForce  = Vector3.new(1e7, 1e7, 1e7)
        force.P         = 1e6
        force.Parent    = closestHRP
        game:GetService("Debris"):AddItem(force, 0.2)

        -- Segundo impulso para que vuele bien
        task.delay(0.15, function()
            if closestHRP and closestHRP.Parent then
                local force2 = Instance.new("BodyVelocity")
                force2.Velocity  = Vector3.new(launchDir.X, 0.5, launchDir.Z) * (HIT_FORCE * 0.5)
                force2.MaxForce  = Vector3.new(1e7, 1e7, 1e7)
                force2.P         = 1e6
                force2.Parent    = closestHRP
                game:GetService("Debris"):AddItem(force2, 0.15)
            end
        end)

        -- Daño si el juego lo permite
        if oHuman then
            pcall(function()
                oHuman:TakeDamage(15)
            end)
        end

        -- Flash de pantalla
        local flash = Instance.new("Frame")
        flash.Size                   = UDim2.new(1,0,1,0)
        flash.BackgroundColor3       = Color3.fromRGB(255,60,0)
        flash.BackgroundTransparency = 0.4
        flash.ZIndex                 = 20
        flash.Parent                 = gui
        TweenService:Create(flash, TweenInfo.new(0.2), {BackgroundTransparency=1}):Play()
        game:GetService("Debris"):AddItem(flash, 0.25)

        notify("💥 ¡BOOM! " .. closest.Name .. " salió volando!", Color3.fromRGB(255,80,50))
    else
        notify("😶 Nadie cerca (radio: " .. HIT_RADIUS .. ")", Color3.fromRGB(180,180,180))
    end
end

-- ══════════════════════════════════════
-- CONECTAR BOTONES (Activated = funciona en móvil)
-- ══════════════════════════════════════
btnVolar.Activated:Connect(toggleFlight)
btnSpeed.Activated:Connect(toggleSpeed)
btnGolpe.Activated:Connect(superPunch)

-- ══════════════════════════════════════
-- LOOP DE VUELO
-- En móvil el joystick mueve al personaje,
-- cuando vuela lo detectamos con MoveDirection
-- ══════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    local hrp   = getHRP()
    local human = getHuman()
    if not hrp then return end

    local move = Vector3.new(0,0,0)

    -- Móvil: usar MoveDirection del humanoid (joystick virtual)
    if human then
        local md = human.MoveDirection
        if md.Magnitude > 0.1 then
            move = md  -- ya viene normalizado
        end
    end

    -- Teclado adicional (para Studio/PC)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then move -= Vector3.new(0,1,0) end

    -- En móvil mantener altura actual y moverse en XZ
    local vel = Vector3.new(move.X, move.Y, move.Z)
    if vel.Magnitude > 0 then vel = vel.Unit end
    bv.Velocity = vel * FLIGHT_SPEED

    -- Orientar hacia la cámara
    bg.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z))
end)

-- ══════════════════════════════════════
-- RESET AL REAPARECER
-- ══════════════════════════════════════
local function onCharAdded(char)
    flying = false; speedOn = false; bv = nil; bg = nil
    btnVolar.BackgroundColor3 = COL_VOLAR_OFF; btnVolar.Text = "🛸 VOLAR\nOFF"
    btnSpeed.BackgroundColor3 = COL_SPEED_OFF; btnSpeed.Text = "⚡ SPEED\nOFF"
    notify("🔄 Renaciste — poderes listos!")

    local human = char:WaitForChild("Humanoid")
    if speedOn then human.WalkSpeed = WALK_SPEED end

    human.Died:Connect(function()
        flying = false; speedOn = false
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
    end)
end

player.CharacterAdded:Connect(onCharAdded)
if player.Character then onCharAdded(player.Character) end

print("[SuperPoderes v3 MOVIL] Listo ✅")
