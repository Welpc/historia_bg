-- SuperPoderes LocalScript
-- Coloca este script en StarterPlayer > StarterPlayerScripts
-- Controles:
--   F        → Activar/Desactivar vuelo
--   Q/E      → Subir / Bajar mientras vuelas
--   G        → Activar/Desactivar super velocidad
--   Clic     → Golpe explosivo (manda a volar a los jugadores cercanos)

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- ─── Configuración ─────────────────────────────────────────────
local FLIGHT_SPEED     = 60      -- velocidad de vuelo
local WALK_SPEED       = 50      -- velocidad al correr (normal ~16)
local HIT_RADIUS       = 15      -- radio del golpe explosivo (studs)
local HIT_FORCE        = 180     -- fuerza del lanzamiento
local HIT_COOLDOWN     = 0.8     -- segundos entre golpes
-- ───────────────────────────────────────────────────────────────

local flying        = false
local speedBoost    = false
local lastHit       = 0
local bodyVelocity  = nil
local bodyGyro      = nil

-- ─── Utilidades ────────────────────────────────────────────────
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHuman()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ─── Notificación en pantalla ───────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "SuperPoderUI"
screenGui.ResetOnSpawn   = false
screenGui.Parent         = player.PlayerGui

local notifLabel = Instance.new("TextLabel")
notifLabel.Size            = UDim2.new(0, 300, 0, 40)
notifLabel.Position        = UDim2.new(0.5, -150, 0, 20)
notifLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
notifLabel.BackgroundTransparency = 0.3
notifLabel.TextColor3      = Color3.fromRGB(255, 220, 50)
notifLabel.Font            = Enum.Font.GothamBold
notifLabel.TextSize        = 18
notifLabel.Text            = ""
notifLabel.Parent          = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = notifLabel

local function notify(msg)
    notifLabel.Text = msg
    notifLabel.TextTransparency = 0
    local tween = TweenService:Create(
        notifLabel,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { TextTransparency = 1 }
    )
    tween:Play()
end

-- ─── HUD de estado ──────────────────────────────────────────────
local hudFrame = Instance.new("Frame")
hudFrame.Size              = UDim2.new(0, 180, 0, 70)
hudFrame.Position          = UDim2.new(0, 16, 0.5, -35)
hudFrame.BackgroundColor3  = Color3.fromRGB(10, 10, 10)
hudFrame.BackgroundTransparency = 0.35
hudFrame.Parent            = screenGui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)

local function makeHudLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -12, 0, 28)
    lbl.Position          = UDim2.new(0, 6, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 15
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Text              = text
    lbl.TextColor3        = Color3.fromRGB(200, 200, 200)
    lbl.Parent            = hudFrame
    return lbl
end

local flyLabel   = makeHudLabel("🛸 Vuelo  [F]: OFF", 4)
local speedLabel = makeHudLabel("⚡ Speed  [G]: OFF", 34)

local function updateHUD()
    flyLabel.Text   = flying     and "🛸 Vuelo  [F]: ON"  or "🛸 Vuelo  [F]: OFF"
    speedLabel.Text = speedBoost and "⚡ Speed  [G]: ON"  or "⚡ Speed  [G]: OFF"
    flyLabel.TextColor3   = flying     and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(180,180,180)
    speedLabel.TextColor3 = speedBoost and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(180,180,180)
end
updateHUD()

-- ─── VUELO ──────────────────────────────────────────────────────
local function enableFlight()
    local hrp   = getHRP()
    local human = getHuman()
    if not hrp or not human then return end

    human.PlatformStand = true

    bodyVelocity          = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent   = hrp

    bodyGyro                    = Instance.new("BodyGyro")
    bodyGyro.MaxTorque          = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P                  = 1e4
    bodyGyro.CFrame             = hrp.CFrame
    bodyGyro.Parent             = hrp

    notify("🛸 Vuelo ACTIVADO — Q/E para subir/bajar")
end

local function disableFlight()
    local hrp   = getHRP()
    local human = getHuman()

    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end

    if human then human.PlatformStand = false end
    notify("🛸 Vuelo DESACTIVADO")
end

local function toggleFlight()
    flying = not flying
    if flying then enableFlight() else disableFlight() end
    updateHUD()
end

-- ─── VELOCIDAD ──────────────────────────────────────────────────
local function toggleSpeed()
    speedBoost = not speedBoost
    local human = getHuman()
    if human then
        human.WalkSpeed = speedBoost and WALK_SPEED or 16
    end
    notify(speedBoost and "⚡ Super Velocidad ON" or "⚡ Velocidad normal")
    updateHUD()
end

-- ─── GOLPE EXPLOSIVO ────────────────────────────────────────────
local function superPunch()
    local now = tick()
    if now - lastHit < HIT_COOLDOWN then return end
    lastHit = now

    local myHRP = getHRP()
    if not myHRP then return end

    local hit = false
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local otherHuman = otherPlayer.Character:FindFirstChildOfClass("Humanoid")

            if otherHRP and otherHuman and otherHuman.Health > 0 then
                local dist = (otherHRP.Position - myHRP.Position).Magnitude

                if dist <= HIT_RADIUS then
                    -- Dirección del golpe
                    local dir = (otherHRP.Position - myHRP.Position).Unit

                    -- Aplicar fuerza con BodyVelocity temporal
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity  = (dir + Vector3.new(0, 0.6, 0)).Unit * HIT_FORCE
                    bv.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
                    bv.P         = 1e5
                    bv.Parent    = otherHRP

                    -- Quitar la fuerza después de un momento
                    game:GetService("Debris"):AddItem(bv, 0.15)

                    -- Daño opcional (comentado para no hacer trampas muy obvias)
                    -- otherHuman:TakeDamage(25)

                    hit = true
                end
            end
        end
    end

    if hit then
        notify("💥 ¡BOOM! ¡Mandado a volar!")
        -- Efecto visual rápido en pantalla
        local flash = Instance.new("Frame")
        flash.Size                    = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3        = Color3.fromRGB(255, 120, 0)
        flash.BackgroundTransparency  = 0.6
        flash.ZIndex                  = 10
        flash.Parent                  = screenGui
        TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        game:GetService("Debris"):AddItem(flash, 0.4)
    else
        notify("😶 Nadie cerca para golpear")
    end
end

-- ─── INPUT ──────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end  -- ignorar si el juego procesó el input

    if input.KeyCode == Enum.KeyCode.F then
        toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.G then
        toggleSpeed()
    end
end)

-- Golpe con clic izquierdo
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if flying or true then   -- disponible siempre
            superPunch()
        end
    end
end)

-- ─── LOOP DE VUELO ──────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not flying or not bodyVelocity or not bodyGyro then return end

    local hrp = getHRP()
    if not hrp then return end

    local camDir   = camera.CFrame.LookVector
    local moveVec  = Vector3.new(0, 0, 0)

    -- Movimiento basado en cámara
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVec = moveVec + camDir
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVec = moveVec - camDir
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVec = moveVec - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVec = moveVec + camera.CFrame.RightVector
    end
    -- Subir / Bajar
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        moveVec = moveVec + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
        moveVec = moveVec - Vector3.new(0, 1, 0)
    end

    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit
    end

    bodyVelocity.Velocity = moveVec * FLIGHT_SPEED

    -- Girar hacia donde apunta la cámara
    bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
end)

-- ─── Restablecer al morir ────────────────────────────────────────
player.CharacterAdded:Connect(function(char)
    flying     = false
    speedBoost = false
    bodyVelocity = nil
    bodyGyro     = nil
    updateHUD()
    notify("🔄 Personaje renació — poderes listos")

    local human = char:WaitForChild("Humanoid")
    human.Died:Connect(function()
        flying = false
        speedBoost = false
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end
    end)
end)

print("[SuperPoderes] Script cargado correctamente ✅")
print("  F = Vuelo ON/OFF | G = Speed ON/OFF | Clic = Golpe explosivo")
