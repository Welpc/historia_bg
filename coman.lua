-- Script para Roblox que añade un botón para descargar la parte cliente del juego actual
-- ADVERTENCIA: Solo funciona en ejecutores de Roblox (exploits). No es un script de Roblox Studio.
-- El archivo descargado NO incluye scripts de servidor (ServerScriptService), solo la parte visible en el cliente.
-- Para abrirlo, usa Roblox Studio y luego exporta lo que necesites.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- 1. CREAR LA INTERFAZ (GUI) CON EL BOTÓN DE DESCARGA
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameDownloader"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame principal (contenedor del botón)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Descargador de Juegos"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

-- Botón de descarga
local downloadButton = Instance.new("TextButton")
downloadButton.Size = UDim2.new(0.9, 0, 0, 35)
downloadButton.Position = UDim2.new(0.05, 0, 0, 35)
downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
downloadButton.Text = "DESCARGAR JUEGO"
downloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downloadButton.Font = Enum.Font.SourceSansBold
downloadButton.TextSize = 14
downloadButton.Parent = mainFrame

-- Esquinas redondeadas del botón
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = downloadButton

-- ============================================================
-- 2. FUNCIÓN PRINCIPAL: CARGAR Y EJECUTAR UniversalSynSaveInstance
-- ============================================================
local function downloadGame()
    -- Cambiar el texto del botón para indicar progreso
    downloadButton.Text = "CARGANDO..."
    downloadButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    task.wait(0.1)

    -- Cargar el script UniversalSynSaveInstance desde GitHub
    local success, err = pcall(function()
        local Params = {
            RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
            SSI = "saveinstance",
        }
        local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
        local Options = {
            -- Modo de guardado: "full" para guardar todo lo posible
            Mode = "full",
            -- Guardar scripts locales (no de servidor)
            SavePlayers = true,
            -- Ignorar propiedades por defecto para reducir tamaño
            IgnoreDefaultProps = false,
            -- Incluir scripts (decompilados si es posible)
            Decompile = true,
            -- Ruta del archivo (puede cambiarse)
            FilePath = "game_dump.rbxlx",
            -- Mostrar estado en la consola
            ShowStatus = true,
        }
        synsaveinstance(Options)
    end)

    if success then
        downloadButton.Text = "¡DESCARGADO!"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        -- Restaurar después de 3 segundos
        task.wait(3)
        downloadButton.Text = "DESCARGAR JUEGO"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    else
        downloadButton.Text = "ERROR - Ver consola"
        downloadButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        warn("Error al descargar: " .. tostring(err))
        task.wait(3)
        downloadButton.Text = "DESCARGAR JUEGO"
        downloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end
end

-- ============================================================
-- 3. CONECTAR EL BOTÓN A LA FUNCIÓN
-- ============================================================
downloadButton.MouseButton1Click:Connect(downloadGame)

print("[GameDownloader] Script cargado. Botón añadido a la pantalla.")
print("[GameDownloader] ADVERTENCIA: Solo descarga la parte cliente. Los scripts de servidor NO se incluyen.")
