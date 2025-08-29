-- ESP CON GUI - VERSIÓN CORREGIDA
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espObjects = {}
local updateConnection = nil

-- Crear GUI con Drawing (para evitar conflictos)
local function createDrawingGUI()
    -- Crear fondo del botón
    local bgBox = Drawing.new("Square")
    bgBox.Visible = true
    bgBox.Size = Vector2.new(110, 50)
    bgBox.Position = Vector2.new(20, 20)
    bgBox.Color = Color3.fromRGB(30, 30, 30)
    bgBox.Filled = true
    bgBox.Thickness = 0
    
    -- Crear botón
    local buttonBox = Drawing.new("Square")
    buttonBox.Visible = true
    buttonBox.Size = Vector2.new(100, 40)
    buttonBox.Position = Vector2.new(25, 25)
    buttonBox.Color = Color3.fromRGB(255, 50, 50)
    buttonBox.Filled = true
    buttonBox.Thickness = 2
    
    -- Texto del botón
    local buttonText = Drawing.new("Text")
    buttonText.Visible = true
    buttonText.Text = "ESP: OFF"
    buttonText.Position = Vector2.new(50, 35)
    buttonText.Color = Color3.fromRGB(255, 255, 255)
    buttonText.Size = 16
    buttonText.Center = true
    buttonText.Outline = true
    
    return {
        Background = bgBox,
        Button = buttonBox,
        Text = buttonText
    }
end

-- Crear la GUI
local gui = createDrawingGUI()

-- Función para actualizar el botón
local function updateButton()
    if espEnabled then
        gui.Button.Color = Color3.fromRGB(50, 200, 50)
        gui.Text.Text = "ESP: ON"
    else
        gui.Button.Color = Color3.fromRGB(255, 50, 50)
        gui.Text.Text = "ESP: OFF"
    end
end

-- Función para crear ESP
local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameTag.Text = player.Name
    
    espObjects[player] = {
        Box = box,
        NameTag = nameTag
    }
end

-- Función para actualizar ESP
local function updateESP()
    for player, data in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude
                local scale = 1000 / distance
                
                data.Box.Size = Vector2.new(scale * 2, scale * 3)
                data.Box.Position = Vector2.new(position.X - data.Box.Size.X / 2, position.Y - data.Box.Size.Y / 2)
                data.Box.Visible = espEnabled
                
                data.NameTag.Position = Vector2.new(position.X, position.Y - data.Box.Size.Y / 2 - 15)
                data.NameTag.Visible = espEnabled
                
                if player.Team then
                    data.Box.Color = player.Team.Color
                end
            else
                data.Box.Visible = false
                data.NameTag.Visible = false
            end
        else
            data.Box.Visible = false
            data.NameTag.Visible = false
        end
    end
end

-- Función para toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- ACTIVAR ESP
        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end
        
        Players.PlayerAdded:Connect(function(newPlayer)
            createESP(newPlayer)
        end)
        
        if updateConnection then
            updateConnection:Disconnect()
        end
        updateConnection = RunService.RenderStepped:Connect(updateESP)
        
        updateButton()
        print("✅ ESP ACTIVADO")
        
    else
        -- DESACTIVAR ESP
        for _, data in pairs(espObjects) do
            pcall(function()
                data.Box:Remove()
                data.NameTag:Remove()
            end)
        end
        espObjects = {}
        
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        
        updateButton()
        print("✅ ESP DESACTIVADO")
    end
end

-- Detectar clic en el botón
local function checkClick(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        local buttonPos = gui.Button.Position
        local buttonSize = gui.Button.Size
        
        if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
           mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
            toggleESP()
        end
    end
end

-- Conectar el evento de clic
game:GetService("UserInputService").InputBegan:Connect(checkClick)

print("🎯 ESP SCRIPT CARGADO!")
print("👆 Haz click en el botón de la esquina")
print("📍 Posición: Esquina superior izquierda")

-- Auto-activar después de 2 segundos (opcional)
delay(2, function()
    if not espEnabled then
        toggleESP()
    end
end)
