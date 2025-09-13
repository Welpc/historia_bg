-- AntiLag_Server.lua con Interfaz de Control
-- Pega en ServerScriptService

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")

-- CONFIG -----------------------------------------------------
local CONFIG = {
    maxPartsPerPlayer = 300,      -- partes permitidas por jugador (aprox)
    maxTotalParts = 1500,         -- total partes en workspace antes de empezar a limpiar
    maxEmittersPerPlayer = 40,    -- particle emitters por jugador
    maxSoundsPerPlayer = 30,
    maxExplosionsPerPlayer = 5,
    kickOnViolations = true,
    violationsUntilKick = 3,
    ownerDetectRadius = 40,       -- si un objeto aparece cerca del character se asume dueño
    remoteRateLimit = {           -- rate limit para remotos (calls por segundo)
        maxCalls = 6,
        windowSeconds = 1.5,
    },
    cleanupInterval = 0.6,        -- cada cuánto revisar (segundos)
    enabled = true,               -- estado inicial del sistema
}
-- END CONFIG -------------------------------------------------

-- Variable para controlar si el sistema está activo
local antiLagEnabled = CONFIG.enabled

-- datos por jugador
local playerData = {}

-- crea un RemoteEvent para uso seguro (si quieres que tus propios remotes pasen por validación)
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
        -- Crear la interfaz para el jugador
        local guiScript = Instance.new("LocalScript")
        guiScript.Name = "AntiLagControlGUI"
        
        -- Script de la interfaz
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
            
            -- Marco principal
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
                    activateBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
                    deactivateBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                else
                    statusLabel.Text = "Estado: Desactivado"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    activateBtn.BackgroundColor3 = Color3.fromRGB(30, 90, 40)
                    deactivateBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
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
    -- Solo permitir a admins cambiar el estado
    if player:GetRankInGroup(0) > 0 then  -- Ajusta según tu sistema de permisos
        antiLagEnabled = enable
        print("AntiLag " .. (enable and "activado" or "desactivado") .. " por " .. player.Name)
        return true
    else
        warn("Intento no autorizado de cambiar estado AntiLag por " .. player.Name)
        return false
    end
end

getAntiLagStatusRemote.OnServerInvoke = function(player)
    return antiLagEnabled
end

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

local function cleanupPlayerData(p)
    playerData[p.UserId] = nil
end

-- util: devuelve jugador más cercano a una instancia (por distancia al HumanoidRootPart)
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

-- decide "propietario" aproximado de un objeto
local function guessOwner(inst)
    -- Si tiene atributo CreatorUserId lo usamos
    local attr = inst:GetAttribute and inst:GetAttribute("CreatorUserId")
    if attr and Players:GetPlayerByUserId(attr) then
        return Players:GetPlayerByUserId(attr)
    end
    -- si la instancia tiene posición, buscamos jugador cercano
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

-- manejar nuevo objeto sospechoso
local function handleNewInstance(inst)
    if not antiLagEnabled then return end  -- No hacer nada si está desactivado
    if not inst or not inst.Parent then return end

    -- Ignorar instancias del servicio Locked/CollectionService u objetos del propio sistema
    if inst:IsDescendantOf(ReplicatedStorage) then return end

    local typ = inst.ClassName

    -- Solo checamos tipos que causan lag mayormente
    if inst:IsA("BasePart") or inst:IsA("ParticleEmitter") or inst:IsA("Sound") or inst:IsA("Explosion") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Beam") or inst:IsA("Trail") then
        local owner = guessOwner(inst)
        if owner then
            local d = playerData[owner.UserId]
            if not d then initPlayer(owner); d = playerData[owner.UserId] end

            -- actualizar contadores aproximados por tipo
            if inst:IsA("BasePart") then
                d.parts = d.parts + 1
            elseif inst:IsA("ParticleEmitter") then
                d.emitters = d.emitters + 1
            elseif inst:IsA("Sound") then
                d.sounds = d.sounds + 1
            elseif inst:IsA("Explosion") then
                d.explosions = d.explosions + 1
            end

            -- chequeos por jugador
            if d.parts > CONFIG.maxPartsPerPlayer or d.emitters > CONFIG.maxEmittersPerPlayer or d.sounds > CONFIG.maxSoundsPerPlayer or d.explosions > CONFIG.maxExplosionsPerPlayer then
                -- contamos una violación
                d.violations = d.violations + 1
                -- eliminamos el objeto inmediatamente
                pcall(function() inst:Destroy() end)
                warn(("AntiLag: Removed object of type %s from player %s (violation %d)"):format(typ, owner.Name, d.violations))

                if CONFIG.kickOnViolations and d.violations >= CONFIG.violationsUntilKick then
                    -- kick
                    pcall(function()
                        owner:Kick("Se detectó comportamiento que causa lag. Si es legítimo, contacta al staff.")
                    end)
                end
                return
            end
        else
            -- Sin owner aproximado: revisamos conteo global y limpiamos si workspace tiene demasiadas partes
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

-- conexión para detectar objetos nuevos en workspace
workspace.DescendantAdded:Connect(function(inst)
    -- pequeño pcall por seguridad
    local ok, err = pcall(function() handleNewInstance(inst) end)
    if not ok then warn("AntiLag: error handling instance: "..tostring(err)) end
end)

-- detectamos scripts colocados en Workspace (scripts maliciosos)
workspace.ChildAdded:Connect(function(child)
    if not antiLagEnabled then return end  -- No hacer nada si está desactivado
    
    if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
        -- destruimos scripts que aparezcan en workspace directamente
        warn("AntiLag: Script added to Workspace -> removing: "..child:GetFullName())
        pcall(function() child:Destroy() end)
    end
end)

-- FUNCTION: Create a "safe" RemoteEvent with server-side validation wrapper
local function createSafeRemote(name)
    local r = Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = safeRemoteFolder

    local function onServerInvoke(player, ...)
        if not antiLagEnabled then return end  -- No hacer nada si está desactivado
        
        -- rate limiting:
        local data = playerData[player.UserId]
        if not data then initPlayer(player); data = playerData[player.UserId] end
        local now = tick()
        table.insert(data.recentRemoteTimestamps, now)
        -- remove old timestamps
        local cutoff = now - CONFIG.remoteRateLimit.windowSeconds
        local i = 1
        while i <= #data.recentRemoteTimestamps do
            if data.recentRemoteTimestamps[i] < cutoff then
                table.remove(data.recentRemoteTimestamps, i)
            else
                i = i + 1
            end
        end
        if #data.recentRemoteTimestamps > CONFIG.remoteRateLimit.maxCalls then
            data.violations = data.violations + 1
            warn(("AntiLag: %s exceeded remote rate limit (calls=%d)"):format(player.Name, #data.recentRemoteTimestamps))
            if data.violations >= CONFIG.violationsUntilKick then
                pcall(function() player:Kick("Exceso de acciones sospechosas (rate limit).") end)
            end
            return
        end

        -- VALIDACIÓN BÁSICA de args (ejemplo): bloquear strings demasiado largos o tablas masivas
        local args = {...}
        for _, a in ipairs(args) do
            if type(a) == "string" and #a > 500 then
                warn("AntiLag: blocked oversized string from " .. player.Name)
                return
            elseif type(a) == "table" then
                -- tables grandes podrían ser intento de spam; rechazamos tablas con >200 keys
                local count = 0
                for _ in pairs(a) do
                    count = count + 1
                    if count > 200 then break end
                end
                if count > 200 then
                    warn("AntiLag: blocked oversized table from " .. player.Name)
                    return
                end
            end
        end

        -- Si pasa validación: el desarrollador debe conectar r.OnServerEvent para manejar la acción
        -- (No hacemos nada por defecto)
    end

    r.OnServerEvent:Connect(function(player, ...)
        -- llamamos al validador que también puede ser usado para acciones
        onServerInvoke(player, ...)
    end)

    return r
end

-- crear un RemoteEvent por defecto (puedes crear más)
createSafeRemote("SafeAction")

-- init players existentes y limpiar jugadores desconectados
for _, p in pairs(Players:GetPlayers()) do initPlayer(p) end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(cleanupPlayerData)

-- Enviar interfaz a jugadores cuando se unen
Players.PlayerAdded:Connect(function(player)
    initPlayer(player)
    wait(2) -- Esperar a que el cliente esté listo
    sendControlInterfaceToPlayers()
end)

-- Enviar interfaz a jugadores existentes
sendControlInterfaceToPlayers()

-- limpieza periódica para prevenir contadores erróneos (recontar global rápido si hace falta)
spawn(function()
    while true do
        if antiLagEnabled then
            -- opcional: reducción gradual de contadores (
