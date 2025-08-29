-- ESP Local para Exploit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espObjects = {}

-- Función para crear ESP
local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    
    local function setupESP(character)
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if not humanoid or not head then return end
        
        -- Box ESP
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Thickness = 2
        box.Filled = false
        box.ZIndex = 1
        
        -- Name Tag
        local nameTag = Drawing.new("Text")
        nameTag.Visible = false
        nameTag.Color = Color3.fromRGB(255, 255, 255)
        nameTag.Size = 18
        nameTag.Center = true
        nameTag.Outline = true
        nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
        nameTag.Text = player.Name
        
        -- Health Bar
        local healthBar = Drawing.new("Line")
        healthBar.Visible = false
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Thickness = 3
        healthBar.ZIndex = 2
        
        espObjects[player] = {
            Box = box,
            NameTag = nameTag,
            HealthBar = healthBar,
            Character = character,
            Humanoid = humanoid,
            Head = head
        }
    end
    
    -- Conectar eventos
    if player.Character then
        setupESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        if espObjects[player] then
            espObjects[player].Box:Remove()
            espObjects[player].NameTag:Remove()
            espObjects[player].HealthBar:Remove()
            espObjects[player] = nil
        end
        setupESP(character)
    end)
    
    player.CharacterRemoving:Connect(function()
        if espObjects[player] then
            espObjects[player].Box:Remove()
            espObjects[player].NameTag:Remove()
            espObjects[player].HealthBar:Remove()
            espObjects[player] = nil
        end
    end)
end

-- Función para actualizar ESP
local function updateESP()
    for player, data in pairs(espObjects) do
        if not data.Character or not data.Character:FindFirstChild("Head") then
            data.Box:Remove()
            data.NameTag:Remove()
            data.HealthBar:Remove()
            espObjects[player] = nil
            continue
        end
        
        local head = data.Character.Head
        local humanoid = data.Character:FindFirstChildOfClass("Humanoid")
        
        if head and humanoid and humanoid.Health > 0 then
            local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                -- Calcular tamaño del ESP
                local distance = (workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude
                local scale = 1000 / distance
                
                -- Box ESP
                data.Box.Size = Vector2.new(scale * 2, scale * 3)
                data.Box.Position = Vector2.new(position.X - data.Box.Size.X / 2, position.Y - data.Box.Size.Y / 2)
                data.Box.Visible = espEnabled
                
                -- Name Tag
                data.NameTag.Position = Vector2.new(position.X, position.Y - data.Box.Size.Y / 2 - 20)
                data.NameTag.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "]"
                data.NameTag.Visible = espEnabled
                
                -- Health Bar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                
                data.HealthBar.From = Vector2.new(position.X - data.Box.Size.X / 2, position.Y + data.Box.Size.Y / 2 + 5)
                data.HealthBar.To = Vector2.new(position.X - data.Box.Size.X / 2 + data.Box.Size.X * healthPercent, position.Y + data.Box.Size.Y / 2 + 5)
                data.HealthBar.Color = healthColor
                data.HealthBar.Visible = espEnabled
                
                -- Cambiar color del box según el equipo
                if player.Team then
                    data.Box.Color = player.Team.Color
                else
                    data.Box.Color = Color3.fromRGB(255, 0, 0)
                end
            else
                data.Box.Visible = false
                data.NameTag.Visible = false
                data.HealthBar.Visible = false
            end
        else
            data.Box.Visible = false
            data.NameTag.Visible = false
            data.HealthBar.Visible = false
        end
    end
end

-- Función para toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- Crear ESP para todos los jugadores
        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end
        
        -- Conectar nuevos jugadores
        Players.PlayerAdded:Connect(function(player)
            createESP(player)
        end)
        
        -- Iniciar loop de actualización
        RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Last, updateESP)
        
        print("ESP Activado")
    else
        -- Desactivar todo
        for player, data in pairs(espObjects) do
            data.Box:Remove()
            data.NameTag:Remove()
            data.HealthBar:Remove()
        end
        espObjects = {}
        
        RunService:UnbindFromRenderStep("ESPUpdate")
        print("ESP Desactivado")
    end
end

-- Crear interfaz simple (opcional para exploit)
local function createGUI()
    -- Esto es opcional, dependiendo de tu exploit
    print("ESP Script Cargado")
    print("Usa: toggleESP() para activar/desactivar")
end

-- Inicializar
createGUI()

-- Devolver función de toggle
return {
    toggle = toggleESP,
    enabled = function() return espEnabled end
}