-- Contenido del archivo esp.lua en GitHub
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espObjects = {}
local updateConnection = nil

-- Configuración de la GUI
local guiPosition = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2 - 60, 50)
local isDragging = false
local dragStart = Vector2.new(0, 0)
local startPos = Vector2.new(0, 0)

-- Crear elementos de la GUI
local bgBox = Drawing.new("Square")
bgBox.Visible = true
bgBox.Size = Vector2.new(120, 50)
bgBox.Position = guiPosition
bgBox.Color = Color3.fromRGB(40, 40, 40)
bgBox.Filled = true
bgBox.Thickness = 0

local buttonBox = Drawing.new("Square")
buttonBox.Visible = true
buttonBox.Size = Vector2.new(100, 40)
buttonBox.Position = Vector2.new(guiPosition.X + 10, guiPosition.Y + 5)
buttonBox.Color = Color3.fromRGB(255, 50, 50)
buttonBox.Filled = true
buttonBox.Thickness = 2

local buttonText = Drawing.new("Text")
buttonText.Visible = true
buttonText.Text = "ESP: OFF"
buttonText.Position = Vector2.new(guiPosition.X + 60, guiPosition.Y + 25)
buttonText.Color = Color3.fromRGB(255, 255, 255)
buttonText.Size = 16
buttonText.Center = true
buttonText.Outline = true

-- Función para actualizar el botón
local function updateButton()
    if espEnabled then
        buttonBox.Color = Color3.fromRGB(50, 200, 50)
        buttonText.Text = "ESP: ON"
    else
        buttonBox.Color = Color3.fromRGB(255, 50, 50)
        buttonText.Text = "ESP: OFF"
    end
end

-- Función para actualizar posición de la GUI
local function updateGUIPosition(newPos)
    guiPosition = newPos
    bgBox.Position = newPos
    buttonBox.Position = Vector2.new(newPos.X + 10, newPos.Y + 5)
    buttonText.Position = Vector2.new(newPos.X + 60, newPos.Y + 25)
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
    nameTag.Text = player.Name
    
    espObjects[player] = {Box = box, NameTag = nameTag}
end

-- Función para actualizar ESP
local function updateESP()
    for player, data in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                data.Box.Size = Vector2.new(50, 70)
                data.Box.Position = Vector2.new(position.X - 25, position.Y - 35)
                data.Box.Visible = espEnabled
                
                data.NameTag.Position = Vector2.new(position.X, position.Y - 50)
                data.NameTag.Visible = espEnabled
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
        -- ACTIVAR
        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end
        
        updateConnection = RunService.RenderStepped:Connect(updateESP)
        updateButton()
        
    else
        -- DESACTIVAR
        for _, data in pairs(espObjects) do
            pcall(function()
                data.Box:Remove()
                data.NameTag:Remove()
            end)
        end
        espObjects = {}
        
        if updateConnection then
            updateConnection:Disconnect()
        end
        
        updateButton()
    end
end

-- Detectar clics
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        
        -- Verificar si es clic en el botón
        if mousePos.X >= buttonBox.Position.X and mousePos.X <= buttonBox.Position.X + buttonBox.Size.X and
           mousePos.Y >= buttonBox.Position.Y and mousePos.Y <= buttonBox.Position.Y + buttonBox.Size.Y then
            toggleESP()
        
        -- Verificar si es clic en el fondo para arrastrar
        elseif mousePos.X >= bgBox.Position.X and mousePos.X <= bgBox.Position.X + bgBox.Size.X and
               mousePos.Y >= bgBox.Position.Y and mousePos.Y <= bgBox.Position.Y + bgBox.Size.Y then
            isDragging = true
            dragStart = input.Position
            startPos = bgBox.Position
            bgBox.Color = Color3.fromRGB(60, 60, 60)
        end
    end
end)

-- Manejar arrastre
UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newPos = Vector2.new(startPos.X + delta.X, startPos.Y + delta.Y)
        updateGUIPosition(newPos)
    end
end)

-- Soltar arrastre
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
        isDragging = false
        bgBox.Color = Color3.fromRGB(40, 40, 40)
    end
end)

print("✅ ESP GUI Cargada!")
print("👆 Click en el botón para activar")
print("🖱️  Arrastra el fondo para mover")

-- No return function() aquí - es código directo
