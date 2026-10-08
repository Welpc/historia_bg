local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Buscar la mascota equipada
local function getPet()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v.Name:lower():find("pet") or v:FindFirstChild("Humanoid")) then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 30 then
                return v
            end
        end
    end
    return nil
end

-- Buscar botones de necesidades dentro de la mascota
local function getNeedButtons(pet)
    local buttons = {}
    if not pet then return buttons end
    
    for _, v in ipairs(pet:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) then
            local name = (v.Name .. " " .. (v.Text or "")):lower()
            local needs = {"potty","hungry","thirsty","sleepy","dirty","play","school","salon","sick","bored","walk","ride","camping","beach","pizza"}
            for _, need in ipairs(needs) do
                if name:find(need) then
                    table.insert(buttons, {button = v, need = need})
                    break
                end
            end
        end
    end
    return buttons
end

-- Disparar el clic usando getconnections (MÉTODO QUE SÍ FUNCIONA EN MÓVIL)
local function fireClick(button)
    local success = false
    pcall(function()
        local conns = getconnections(button.MouseButton1Click)
        if conns then
            for _, conn in ipairs(conns) do
                if conn.Fire then
                    conn:Fire()
                    success = true
                end
            end
        end
    end)
    return success
end

-- Bucle principal
local running = false
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 160, 0, 40)
toggle.Position = UDim2.new(0.5, -80, 0.1, 0)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.Text = "INICIAR AUTO"
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.Font = Enum.Font.SourceSansBold
toggle.Parent = LocalPlayer.PlayerGui:WaitForChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "DETENER AUTO" or "INICIAR AUTO"
    toggle.BackgroundColor3 = running and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,170,0)
    
    if running then
        task.spawn(function()
            while running do
                local pet = getPet()
                if pet then
                    local btns = getNeedButtons(pet)
                    for _, data in ipairs(btns) do
                        if not running then break end
                        if fireClick(data.button) then
                            toggle.Text = "Clic: " .. data.need
                        end
                        task.wait(1 + math.random() * 2) -- pausa humana
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)
