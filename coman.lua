-- AntiLag_Server.lua con Interfaz de Control
-- Pega en ServerScriptService

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIGURACIÓN
local CONFIG = {
    maxPartsPerPlayer = 300,
    maxTotalParts = 1500,
    maxEmittersPerPlayer = 40,
    maxSoundsPerPlayer = 30,
    maxExplosionsPerPlayer = 5,
    kickOnViolations = true,
    violationsUntilKick = 3,
    ownerDetectRadius = 40,
    remoteRateLimit = {
        maxCalls = 6,
        windowSeconds = 1.5,
    },
    cleanupInterval = 0.6,
    enabled = true,
}

-- Variable para controlar si el sistema está activo
local antiLagEnabled = CONFIG.enabled

-- Datos por jugador
local playerData = {}

-- Crear carpeta para remotos
local safeRemoteFolder = ReplicatedStorage:FindFirstChild("SafeRemoteFolder")
if not safeRemoteFolder then
    safeRemoteFolder = Instance.new("Folder")
    safeRemoteFolder.Name = "SafeRemoteFolder"
    safeRemoteFolder.Parent = ReplicatedStorage
end

-- Crear RemoteFunctions para controlar la interfaz
local toggleAntiLagRemote = Instance.new("RemoteFunction")
toggleAntiLagRemote.Name = "ToggleAntiLag"
toggleAntiLagRemote.Parent = safeRemoteFolder

local getAntiLagStatusRemote = Instance.new("RemoteFunction")
getAntiLagStatusRemote.Name = "GetAntiLagStatus"
getAntiLagStatusRemote.Parent = safeRemoteFolder

-- Función para enviar la interfaz a todos los jugadores
local function sendControlInterfaceToPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        local guiScript = Instance.new("LocalScript")
        guiScript.Name = "AntiLagControlGUI"
        
        guiScript.Source = [[
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local playerGui = player:WaitForChild("PlayerGui")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            -- Obtener los remotos
            local safeRemoteFolder = ReplicatedStorage:WaitForChild("SafeRemoteFolder")
            local toggleAntiLagRemote = safeRemoteFolder:WaitForChild("ToggleAntiLag")
            local getAntiLagStatusRemote = safeRemoteFolder:WaitForChild("GetAntiLagStatus")
            
            -- Crear la interfaz
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "AntiLagControl"
            screenGui.Parent = playerGui
            
            -- Marco principal (se puede mover)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 200, 0, 100)
            frame.Position = UDim2.new(0, 10, 0, 10)
            frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            frame.BorderSizePixel = 0
            frame.Active = true
            frame.Draggable = true
            frame.Parent = screenGui
            
            -- Título
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.Position = UDim2.new(0, 0, 0, 0)
            title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Text = "Control AntiLag"
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.Parent = frame
            
            -- Botón de activar
            local activateBtn = Instance.new("TextButton")
            activateBtn.Size = UDim2.new(0.45, 0, 0, 30)
            activateBtn.Position = UDim2.new(0.025, 0, 0, 40)
            activateBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
            activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            activateBtn.Text = "ACTIVAR"
            activateBtn.Font = Enum.Font.Gotham
            activateBtn.TextSize = 14
            activateBtn.Parent = frame
            
            -- Botón de desactivar
            local deactivateBtn = Instance.new("TextButton")
            deactivateBtn.Size = UDim2.new(0.45, 0, 0, 30)
            deactivateBtn.Position = UDim2.new(0.525, 0, 0, 40)
            deactivateBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            deactivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            deactivateBtn.Text = "DESACTIVAR"
            deactivateBtn.Font = Enum.Font.Gotham
            deactivateBtn.TextSize = 14
            deactivateBtn.Parent = frame
            
            -- Estado actual
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(1, 0, 0, 20)
            statusLabel.Position = UDim2.new(0, 0, 0, 80)
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Text = "Cargando estado..."
            statusLabel.Font = Enum.Font.Gotham
            statusLabel.TextSize = 12
            statusLabel.Parent = frame
            
            -- Función para actualizar la interfaz
            local function updateInterfaceStatus()
                local status = getAntiLagStatusRemote:InvokeServer()
                if status then
                    statusLabel.Text = "Estado: Activado"
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    statusLabel.Text = "Estado: Desactivado"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
            
            -- Conectar los botones
            activateBtn.MouseButton1Click:Connect(function()
                toggleAntiLagRemote:InvokeServer(true)
                updateInterfaceStatus()
            end)
            
            deactivateBtn.MouseButton1Click:Connect(function()
                toggleAntiLagRemote:InvokeServer(false)
                updateInterfaceStatus()
            end)
            
            -- Inicializar
            updateInterfaceStatus()
        ]]
        
        guiScript.Parent = player:FindFirstChild("PlayerScripts") or player:WaitForChild("PlayerGui")
    end
end

-- Configurar las RemoteFunctions
toggleAntiLagRemote.OnServerInvoke = function(player, enable)
    antiLagEnabled = enable
    print("AntiLag " .. (enable and "activado" or "desactivado") .. " por " .. player.Name)
    return true
end

getAntiLagStatusRemote.OnServerInvoke = function(player)
    return antiLagEnabled
end

-- Inicializar datos del jugador
local function initPlayer(p)
    playerData[p.UserId] = {
        parts = 0,
        emitters = 0,
        sounds = 0,
        explosions = 0,
        violations = 0,
        recentRemoteTimestamps = {},
    }
end

-- Limpiar datos del jugador
local function cleanupPlayerData(p)
    playerData[p.UserId] = nil
end

-- Encontrar jugador más cercano a una instancia
local function getNearestPlayerToInstance(inst)
    local nearestPlayer, nearestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local success, pos = pcall(function() return (inst.Position and inst.Position) or (inst:GetPivot().Position) end)
            if success and pos then
                local dist = (hrp.Position - pos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = p
                end
            end
        end
    end
    return nearestPlayer, nearestDist
end

-- Determinar propietario aproximado de un objeto
local function guessOwner(inst)
    local attr = inst:GetAttribute and inst:GetAttribute("CreatorUserId")
    if attr and Players:GetPlayerByUserId(attr) then
        return Players:GetPlayerByUserId(attr)
    end
    
    if inst:IsA("BasePart") or inst:GetPivot then
        local ok, _ = pcall(function() inst:GetPivot() end)
        if ok then
            local p, dist = getNearestPlayerToInstance(inst)
            if p and dist <= CONFIG.ownerDetectRadius then
                return p
            end
        end
    end
    return nil
end

-- Manejar nuevo objeto sospechoso
local function handleNewInstance(inst)
    if not antiLagEnabled then return end
    if not inst or not inst.Parent then return end

    if inst:IsDescendantOf(ReplicatedStorage) then return end

    local typ = inst.ClassName

    if inst:IsA("BasePart") or inst:IsA("ParticleEmitter") or inst:IsA("Sound") or inst:IsA("Explosion") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Beam") or inst:IsA("Trail") then
        local owner = guessOwner(inst)
        if owner then
            local d = playerData[owner.UserId]
            if not d then initPlayer(owner); d = playerData[owner.UserId] end

            if inst:IsA("BasePart") then
                d.parts = d.parts + 1
            elseif inst:IsA("ParticleEmitter") then
                d.emitters = d.emitters + 1
            elseif inst:IsA("Sound") then
                d.sounds = d.sounds + 1
            elseif inst:IsA("Explosion") then
                d.explosions = d.explosions + 1
            end

            if d.parts > CONFIG.maxPartsPerPlayer or d.emitters > CONFIG.maxEmittersPerPlayer or d.sounds > CONFIG.maxSoundsPerPlayer or d.explosions > CONFIG.maxExplosionsPerPlayer then
                d.violations = d.violations + 1
                pcall(function() inst:Destroy() end)
                warn(("AntiLag: Removed object of type %s from player %s (violation %d)"):format(typ, owner.Name, d.violations))

                if CONFIG.kickOnViolations and d.violations >= CONFIG.violationsUntilKick then
                    pcall(function()
                        owner:Kick("Se detectó comportamiento que causa lag.")
                    end)
                end
                return
            end
        else
            local totalParts = 0
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then totalParts = totalParts + 1 end
            end
            if totalParts > CONFIG.maxTotalParts then
                pcall(function() inst:Destroy() end)
                warn(("AntiLag: Removed object %s because workspace parts exceeded %d (total %d)"):format(inst:GetFullName(), CONFIG.maxTotalParts, totalParts))
                return
            end
        end
    end
end

-- Detectar objetos nuevos
workspace.DescendantAdded:Connect(function(inst)
    local ok, err = pcall(function() handleNewInstance(inst) end)
    if not ok then warn("AntiLag: error handling instance: "..tostring(err)) end
end)

-- Detectar scripts maliciosos
workspace.ChildAdded:Connect(function(child)
    if not antiLagEnabled then return end
    
    if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
        warn("AntiLag: Script added to Workspace -> removing: "..child:GetFullName())
        pcall(function() child:Destroy() end)
    end
end)

-- Inicializar jugadores existentes
for _, p in pairs(Players:GetPlayers()) do initPlayer(p) end

-- Manejar jugadores que se unen/van
Players.PlayerAdded:Connect(function(player)
    initPlayer(player)
    wait(2)
    sendControlInterfaceToPlayers()
end)

Players.PlayerRemoving:Connect(cleanupPlayerData)

-- Enviar interfaz a jugadores existentes
sendControlInterfaceToPlayers()

-- Limpieza periódica
spawn(function()
    while true do
        if antiLagEnabled then
            for uid, d in pairs(playerData) do
                d.parts = math.max(0, d.parts - 12)
                d.emitters = math.max(0, d.emitters - 3)
                d.sounds = math.max(0, d.sounds - 3)
            end
        end
        wait(CONFIG.cleanupInterval)
    end
end)

print("AntiLag_Server iniciado con interfaz de control.")
