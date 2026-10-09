-- Panel de cambio de cielo para todos (intento por RemoteEvents)
-- Escanea TODOS los RemoteEvents y RemoteFunctions del juego
-- Dispara combinaciones de nombres y argumentos relacionados con cielo/clima
-- ADVERTENCIA: La mayoría de servidores rechazan esto. Solo funciona en juegos con RemoteEvents mal protegidos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local old = LP:WaitForChild("PlayerGui"):FindFirstChild("SkyForAll")
if old then old:Destroy() end

-- ============================================================
-- TEMA
-- ============================================================
local C = {
	bg      = Color3.fromRGB(18, 20, 28),
	header  = Color3.fromRGB(28, 31, 42),
	card    = Color3.fromRGB(32, 35, 48),
	btn     = Color3.fromRGB(46, 50, 68),
	accent  = Color3.fromRGB(88, 130, 255),
	good    = Color3.fromRGB(46, 190, 130),
	warn    = Color3.fromRGB(255, 150, 60),
	danger  = Color3.fromRGB(235, 80, 90),
	text    = Color3.fromRGB(235, 238, 250),
	dim     = Color3.fromRGB(140, 146, 170),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function round(o, r)
	new("UICorner", {CornerRadius = UDim.new(0, r)}, o)
end

local function label(parent, text, size, pos, textSize, color, align)
	return new("TextLabel", {
		Size = size, Position = pos, BackgroundTransparency = 1, Text = text,
		TextColor3 = color or C.text, Font = Enum.Font.GothamMedium,
		TextSize = textSize or 12, TextXAlignment = align or Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function button(parent, text, size, pos, color, textSize)
	color = color or C.btn
	local b = new("TextButton", {
		Size = size, Position = pos, BackgroundColor3 = color, Text = text,
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = textSize or 13,
		AutoButtonColor = false, BorderSizePixel = 0,
	}, parent)
	round(b, 8)
	b:SetAttribute("base", color)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = b:GetAttribute("base"):Lerp(Color3.new(1,1,1), 0.25)}):Play()
		end
	end)
	b.InputEnded:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = b:GetAttribute("base")}):Play()
	end)
	return b
end

-- ============================================================
-- INTERFAZ
-- ============================================================
local gui = new("ScreenGui", {Name = "SkyForAll", ResetOnSpawn = false, IgnoreGuiInset = false}, LP.PlayerGui)

local fab = button(gui, "🌤", UDim2.new(0, 42, 0, 42), UDim2.new(0, 8, 0.5, -21), C.accent, 20)
fab.ZIndex = 5
round(fab, 21)

local W, H = 250, 360
local panel = new("Frame", {
	Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0, 58, 0.5, -H/2),
	BackgroundColor3 = C.bg, BackgroundTransparency = 0.04, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(panel, 14)
new("UIStroke", {Color = Color3.fromRGB(70, 76, 105), Thickness = 1, Transparency = 0.4}, panel)

local uiScale = new("UIScale", {}, panel)
local function updateScale()
	local vp = workspace.CurrentCamera.ViewportSize
	uiScale.Scale = math.clamp(vp.Y / 430, 0.7, 1)
end
updateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

local header = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.header, BorderSizePixel = 0}, panel)
label(header, "🌤  Sky for All", UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), 13)
local closeBtn = button(header, "✕", UDim2.new(0, 28, 0, 24), UDim2.new(1, -34, 0, 6), C.danger, 12)

local body = new("Frame", {Size = UDim2.new(1, -20, 1, -44), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1}, panel)

-- Info
local infoCard = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = C.card, BorderSizePixel = 0}, body)
round(infoCard, 10)
label(infoCard, "Escanea RemoteEvents del juego", UDim2.new(1, -16, 0, 16), UDim2.new(0, 10, 0, 6), 11, C.dim)
local statusLbl = label(infoCard, "Listo. Pulsa Escanear.", UDim2.new(1, -16, 0, 16), UDim2.new(0, 10, 0, 26), 10, C.accent)

-- ============================================================
-- ESCANEO DE REMOTES
-- ============================================================
local remotesFound = {}
local firedCount = 0

local SKY_KEYWORDS = {
	"sky", "skybox", "weather", "climate", "time", "lighting", "day",
	"night", "sun", "moon", "atmosphere", "environment", "storm",
	"rain", "snow", "fog", "cloud", "sunset", "sunrise", "dark",
	"light", "color", "theme", "set", "change", "update", "admin",
}

local function isSkyRelated(name)
	local lower = name:lower()
	for _, kw in ipairs(SKY_KEYWORDS) do
		if lower:find(kw) then return true, kw end
	end
	return false, nil
end

local function scanRemotes()
	remotesFound = {}
	local roots = {
		ReplicatedStorage,
		game:GetService("ServerStorage"),
		game:GetService("Lighting"),
		workspace,
		game:GetService("Players"),
	}

	for _, root in ipairs(roots) do
		local ok, descendants = pcall(function() return root:GetDescendants() end)
		if ok and descendants then
			for _, obj in ipairs(descendants) do
				if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
					local related, kw = isSkyRelated(obj.Name)
					if related then
						table.insert(remotesFound, {remote = obj, keyword = kw, fullName = obj:GetFullName()})
					end
				end
			end
		end
	end
	return #remotesFound
end

-- ============================================================
-- DISPARAR REMOTES CON COMBINACIONES
-- ============================================================
local SKY_PRESETS = {
	"CustomSky", "Sky", "Skybox", "ChangeSky", "SetSky", "UpdateSky",
	"SetSkybox", "SkyboxCustom", "Weather", "SetWeather", "ChangeWeather",
	"Time", "SetTime", "SetTimeOfDay", "Day", "Night", "Sunset", "Sunrise",
	"SetLighting", "Lighting", "Atmosphere", "SetAtmosphere",
	"Storm", "Rain", "Snow", "Fog", "Cloudy", "Clear", "Dark", "Light",
	"Admin", "SetAdmin", "Command", "SetProperty", "Update", "Change",
}

local SKY_ARGS = {
	"CustomSky", "Skybox", "Sky", "Storm", "Rain", "Snow", "Clear",
	"Night", "Day", "Sunset", "Sunrise", "Dark", "Light", "Fog",
	14, 0, 12, 18, 6, -- horas del día
	Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255),
}

local function fireAll()
	local fired = 0
	for _, entry in ipairs(remotesFound) do
		local remote = entry.remote
		for _, preset in ipairs(SKY_PRESETS) do
			pcall(function()
				if remote:IsA("RemoteEvent") then
					remote:FireServer(preset)
					remote:FireServer("Sky", preset)
					remote:FireServer("SetSky", preset)
					remote:FireServer("Weather", preset)
					remote:FireServer("Time", preset)
				elseif remote:IsA("RemoteFunction") then
					remote:InvokeServer(preset)
					remote:InvokeServer("Sky", preset)
				end
				fired = fired + 1
			end)
		end
	end
	return fired
end

-- ============================================================
-- CAMBIO LOCAL (fallback siempre funciona para ti)
-- ============================================================
local function applyLocalSky()
	local oldSky = Lighting:FindFirstChildOfClass("Sky")
	if oldSky then oldSky:Destroy() end
	local sky = Instance.new("Sky")
	sky.Name = "CustomSky"
	sky.SkyboxBk = "rbxassetid://159454299"
	sky.SkyboxDn = "rbxassetid://159454296"
	sky.SkyboxFt = "rbxassetid://159454293"
	sky.SkyboxLf = "rbxassetid://159454286"
	sky.SkyboxRt = "rbxassetid://159454300"
	sky.SkyboxUp = "rbxassetid://159454288"
	sky.StarCount = 5000
	sky.Parent = Lighting
	Lighting.ClockTime = 0
	Lighting.Brightness = 1
end

-- ============================================================
-- BOTONES
-- ============================================================
local scanBtn = button(body, "🔍 ESCANEAR REMOTES", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 58), C.accent, 12)
local fireBtn = button(body, "🚀 DISPARAR A TODOS", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 98), C.good, 12)
local localBtn = button(body, "🌤 APLICAR LOCAL (solo tú)", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 138), C.warn, 11)
local stopBtn = button(body, "🛑 DETENER", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 174), C.danger, 11)

-- Lista de remotes encontrados
label(body, "Remotes encontrados:", UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 208), 10, C.dim)
local scrollFrame = new("ScrollingFrame", {
	Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 0, 224),
	BackgroundColor3 = C.card, BorderSizePixel = 0, ScrollBarThickness = 4,
	ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(0, 0, 0, 0),
}, body)
round(scrollFrame, 8)
local listLayout = new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, scrollFrame)

scanBtn.MouseButton1Click:Connect(function()
	statusLbl.Text = "Escaneando..."
	local n = scanRemotes()
	-- Limpiar lista
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	-- Añadir a la lista
	for i, entry in ipairs(remotesFound) do
		local lbl = label(scrollFrame, i .. ". " .. entry.remote.Name .. " [" .. entry.keyword .. "]", UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 0, (i-1)*20), 9, C.text)
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #remotesFound * 20 + 5)
	statusLbl.Text = "Encontrados: " .. n .. " remotes"
end)

fireBtn.MouseButton1Click:Connect(function()
	if #remotesFound == 0 then
		statusLbl.Text = "Primero escanea remotes"
		return
	end
	statusLbl.Text = "Disparando..."
	local n = fireAll()
	firedCount = firedCount + n
	statusLbl.Text = "Disparos: " .. n .. " (total " .. firedCount .. ")"
end)

localBtn.MouseButton1Click:Connect(function()
	applyLocalSky()
	statusLbl.Text = "Cielo local aplicado"
end)

stopBtn.MouseButton1Click:Connect(function()
	firedCount = 0
	statusLbl.Text = "Detenido"
end)

-- ============================================================
-- ARRASTRAR / CERRAR
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = panel.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local d = i.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)
fab.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

print("[SkyForAll] Cargado. Escanea remotes y dispara combinaciones.")
print("[SkyForAll] Si el servidor valida los remotes, no funcionará para otros.")
