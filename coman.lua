-- Script para Roblox que descarga el juego completo incluyendo scripts, parts y modelos
-- ADVERTENCIA: Solo funciona en ejecutores de Roblox (exploits). No es un script de Roblox Studio.
-- La decompilación de scripts puede fallar en scripts muy ofuscados.
-- Los scripts de servidor (ServerScriptService) NO se pueden descargar porque no se replican al cliente.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. INTERFAZ CON BOTÓN DE DESCARGA COMPLETA
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FullGameDownloader"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Descarga Completa del Juego"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Listo para descargar"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

local downloadButton = Instance.new("TextButton")
downloadButton.Size = UDim2.new(0.9, 0, 0, 35)
downloadButton.Position = UDim2.new(0.05, 0, 0, 55)
downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
downloadButton.Text = "DESCARGAR TODO"
downloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downloadButton.Font = Enum.Font.SourceSansBold
downloadButton.TextSize = 14
downloadButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = downloadButton

-- ============================================================
-- 2. FUNCIÓN PRINCIPAL CON OPCIONES AVANZADAS
-- ============================================================
local function fullDownload()
    downloadButton.Text = "DESCARGANDO..."
    downloadButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    statusLabel.Text = "Cargando UniversalSynSaveInstance..."
    task.wait(0.1)

    local success, err = pcall(function()
        local Params = {
            RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
            SSI = "saveinstance",
        }
        local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

        local Options = {
            -- Modo completo: guarda todo lo posible
            Mode = "full",

            -- Guardar scripts locales (client scripts, module scripts)
            SavePlayers = true,
            -- Guardar scripts aunque estén ofuscados (intenta decompilar)
            Decompile = true,
            -- Ignorar propiedades por defecto para reducir tamaño
            IgnoreDefaultProps = false,
            -- Incluir scripts de todos los servicios posibles
            IsolateStarterPlayer = true,
            -- Guardar terrain (terreno)
            SaveTerrain = true,
            -- Guardar lighting y efectos
            SaveLighting = true,
            -- Guardar sound service
            SaveSoundService = true,
            -- Incluir objetos de ReplicatedStorage, ReplicatedFirst, StarterGui, StarterPack
            SaveReplicated = true,
            -- Ruta del archivo (cambiar si es necesario)
            FilePath = "full_game_dump.rbxlx",
            -- Mostrar estado en consola
            ShowStatus = true,
            -- Intentar decompilar scripts de servidor si están accesibles (raro)
            TryServerScripts = true,
            -- Nivel de compresión (nil = sin compresión, 1-9)
            Compression = 6,
        }

        synsaveinstance(Options)
    end)

    if success then
        downloadButton.Text = "¡DESCARGADO!"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        statusLabel.Text = "Archivo: full_game_dump.rbxlx"
        task.wait(4)
        downloadButton.Text = "DESCARGAR TODO"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        statusLabel.Text = "Listo para descargar"
    else
        downloadButton.Text = "ERROR - Ver consola"
        downloadButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        statusLabel.Text = "Error: " .. tostring(err):sub(1, 30)
        warn("Error al descargar: " .. tostring(err))
        task.wait(4)
        downloadButton.Text = "DESCARGAR TODO"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        statusLabel.Text = "Listo para descargar"
    end
end

downloadButton.MouseButton1Click:Connect(fullDownload)

-- ============================================================
-- 3. FUNCIÓN ADICIONAL: DESCARGAR SOLO SCRIPTS (MÁS RÁPIDO)
-- ============================================================
local function downloadScriptsOnly()
    statusLabel.Text = "Extrayendo scripts..."
    task.wait(0.1)

    local scriptsFound = {}
    local services = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer"),
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("Chat"),
        game:GetService("LocalizationService"),
        workspace,
    }

    for _, service in ipairs(services) do
        for _, descendant in ipairs(service:GetDescendants()) do
            if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
                table.insert(scriptsFound, descendant)
            end
        end
    end

    -- Crear archivo de texto con todos los scripts
    local output = "=== SCRIPTS ENCONTRADOS: " .. #scriptsFound .. " ===\n\n"

    for i, scriptObj in ipairs(scriptsFound) do
        output = output .. "--- [" .. i .. "] " .. scriptObj:GetFullName() .. " (" .. scriptObj.ClassName .. ") ---\n"
        output = output .. scriptObj.Source .. "\n\n"
    end

    -- Guardar archivo (usando writefile del ejecutor)
    if writefile then
        writefile("scripts_dump.txt", output)
        statusLabel.Text = "Scripts guardados en scripts_dump.txt"
        print("[FullDownloader] Scripts guardados en scripts_dump.txt")
    else
        statusLabel.Text = "writefile no disponible"
        print("[FullDownloader] Su ejecutor no soporta writefile")
    end

    task.wait(3)
    statusLabel.Text = "Listo para descargar"
end

-- Añadir segundo botón para scripts
local scriptsButton = Instance.new("TextButton")
scriptsButton.Size = UDim2.new(0.9, 0, 0, 30)
scriptsButton.Position = UDim2.new(0.05, 0, 0, 92)
scriptsButton.BackgroundColor3 = Color3.fromRGB(100, 60, 180)
scriptsButton.Text = "SOLO SCRIPTS (.txt)"
scriptsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptsButton.Font = Enum.Font.SourceSansBold
scriptsButton.TextSize = 12
scriptsButton.Parent = mainFrame

local scriptsCorner = Instance.new("UICorner")
scriptsCorner.CornerRadius = UDim.new(0, 8)
scriptsCorner.Parent = scriptsButton

scriptsButton.MouseButton1Click:Connect(downloadScriptsOnly)

print("[FullDownloader] Script cargado. Use los botones en pantalla.")
print("[FullDownloader] ADVERTENCIA: Los scripts de servidor NO se pueden descargar.")
