-- LocalScript dentro de StarterGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemovesGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Crear el TextButton azul
local button = Instance.new("TextButton")
button.Name = "ListarRemoves"
button.Size = UDim2.new(0, 220, 0, 50)
button.Position = UDim2.new(0.5, -110, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(30, 100, 220)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "🔍 Ver Removes del Juego"
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.BorderSizePixel = 0
button.Parent = screenGui

-- Redondear el botón
local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(0, 10)
uiCornerBtn.Parent = button

-- Panel de resultados (oculto al inicio)
local panel = Instance.new("ScrollingFrame")
panel.Name = "ResultPanel"
panel.Size = UDim2.new(0, 340, 0, 400)
panel.Position = UDim2.new(0.5, -170, 0, 80)
panel.BackgroundColor3 = Color3.fromRGB(15, 20, 40)
panel.BorderSizePixel = 0
panel.ScrollBarThickness = 6
panel.Visible = false
panel.Parent = screenGui

local uiCornerPanel = Instance.new("UICorner")
uiCornerPanel.CornerRadius = UDim.new(0, 12)
uiCornerPanel.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = panel

-- Función para añadir línea de texto al panel
local function addLabel(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 24)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel
end

-- Función principal al hacer click
button.MouseButton1Click:Connect(function()
	-- Limpiar panel anterior
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	-- Buscar todos los RemoteEvent y RemoteFunction en el juego
	local removes = {}

	local function buscarRemoves(parent, ruta)
		for _, obj in ipairs(parent:GetChildren()) do
			if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				table.insert(removes, {
					nombre = obj.Name,
					tipo = obj.ClassName,
					ruta = ruta .. "." .. obj.Name
				})
			end
			-- Buscar recursivamente
			local ok, _ = pcall(function()
				buscarRemoves(obj, ruta .. "." .. obj.Name)
			end)
		end
	end

	buscarRemoves(game, "game")

	-- Mostrar resultados
	panel.Visible = true

	local total = #removes
	addLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(30, 100, 220))
	addLabel("  📡 TOTAL DE REMOTES: " .. total, Color3.fromRGB(100, 200, 255))
	addLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(30, 100, 220))

	if total == 0 then
		addLabel("  ⚠️ No se encontraron Remotes.", Color3.fromRGB(255, 200, 50))
	else
		for i, r in ipairs(removes) do
			local color = r.tipo == "RemoteEvent"
				and Color3.fromRGB(100, 255, 150)
				or Color3.fromRGB(255, 180, 80)

			addLabel(string.format("  [%d] %s (%s)", i, r.nombre, r.tipo), color)
			addLabel("       📁 " .. r.ruta, Color3.fromRGB(160, 160, 200))
		end
	end

	-- Ajustar tamaño del canvas
	panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)

	-- Botón para cerrar
	button.Text = "❌ Cerrar panel"
	button.BackgroundColor3 = Color3.fromRGB(180, 30, 30)

	local conn
	conn = button.MouseButton1Click:Connect(function()
		panel.Visible = false
		button.Text = "🔍 Ver Removes del Juego"
		button.BackgroundColor3 = Color3.fromRGB(30, 100, 220)
		conn:Disconnect()
	end)
end)
