loadstring([[
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local espEnabled = false
    local espObjects = {}

    -- Crear GUI simple
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPGui"
    screenGui.Parent = game.CoreGui

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "ESP: OFF"
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.BorderSizePixel = 0
    button.Parent = screenGui

    -- Función para crear ESP con Billboards (TAMAÑO FIJO)
    local function createESP(player)
        if player == LocalPlayer then return end
        if espObjects[player] then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if not humanoid or not head then return end
        
        -- Crear Highlight (caja alrededor del jugador)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        highlight.Parent = character
        
        -- Crear Billboard para el nombre (tamaño fijo en la pantalla)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Name"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false
        billboard.Adornee = head
        billboard.Parent = head
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 14
        nameLabel.Text = player.Name
        nameLabel.Parent = billboard
        
        espObjects[player] = {
            Highlight = highlight,
            Billboard = billboard,
            Character = character
        }
    end

    -- Función para actualizar ESP
    local function updateESP()
        for player, data in pairs(espObjects) do
            if data.Character and data.Character.Parent then
                local humanoid = data.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    data.Highlight.Enabled = espEnabled
                    data.Billboard.Enabled = espEnabled
                    
                    -- Color según equipo
                    if player.Team then
                        data.Highlight.FillColor = player.Team.Color
                    else
                        data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    data.Highlight.Enabled = false
                    data.Billboard.Enabled = false
                end
            else
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        end
    end

    -- Función para toggle ESP
    local function toggleESP()
        espEnabled = not espEnabled
        
        if espEnabled then
            -- ACTIVAR
            for _, player in ipairs(Players:GetPlayers()) do
                createESP(player)
            end
            
            -- Conectar nuevos jugadores
            Players.PlayerAdded:Connect(function(newPlayer)
                createESP(newPlayer)
            end)
            
            button.Text = "ESP: ON"
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            
        else
            -- DESACTIVAR
            for player, data in pairs(espObjects) do
                if data.Highlight then
                    data.Highlight:Destroy()
                end
                if data.Billboard then
                    data.Billboard:Destroy()
                end
            end
            espObjects = {}
            
            button.Text = "ESP: OFF"
            button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end

    -- Conectar el botón
    button.MouseButton1Click:Connect(toggleESP)

    -- Actualizar cada frame
    RunService.Heartbeat:Connect(updateESP)

    print("✅ ESP CARGADO - MÉTODO GARANTIZADO")
    print("👆 Click en el botón rojo")
    print("📏 Tamaño FIJO garantizado")
    print("🎯 Sin problemas de escalado")
]])()
