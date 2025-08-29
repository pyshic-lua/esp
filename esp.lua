return function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local espEnabled = false
    local espObjects = {}
    local updateConnection = nil
    local dragging = false
    local dragInput, dragStart, startPos

    -- Obtener el centro de la pantalla
    local function getScreenCenter()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end

    -- Crear GUI con Drawing en el centro
    local function createDrawingGUI()
        local center = getScreenCenter()
        
        -- Crear fondo del botón
        local bgBox = Drawing.new("Square")
        bgBox.Visible = true
        bgBox.Size = Vector2.new(120, 60)
        bgBox.Position = Vector2.new(center.X - 60, center.Y - 30)
        bgBox.Color = Color3.fromRGB(40, 40, 40)
        bgBox.Filled = true
        bgBox.Thickness = 0
        
        -- Crear botón
        local buttonBox = Drawing.new("Square")
        buttonBox.Visible = true
        buttonBox.Size = Vector2.new(100, 40)
        buttonBox.Position = Vector2.new(center.X - 50, center.Y - 20)
        buttonBox.Color = Color3.fromRGB(255, 50, 50)
        buttonBox.Filled = true
        buttonBox.Thickness = 2
        
        -- Texto del botón
        local buttonText = Drawing.new("Text")
        buttonText.Visible = true
        buttonText.Text = "ESP: OFF"
        buttonText.Position = Vector2.new(center.X, center.Y)
        buttonText.Color = Color3.fromRGB(255, 255, 255)
        buttonText.Size = 16
        buttonText.Center = true
        buttonText.Outline = true
        
        -- Texto de instrucción
        local infoText = Drawing.new("Text")
        infoText.Visible = true
        infoText.Text = "Arrastra para mover"
        infoText.Position = Vector2.new(center.X, center.Y + 40)
        infoText.Color = Color3.fromRGB(180, 180, 180)
        infoText.Size = 12
        infoText.Center = true
        infoText.Outline = false
        
        return {
            Background = bgBox,
            Button = buttonBox,
            Text = buttonText,
            Info = infoText,
            Position = Vector2.new(center.X - 60, center.Y - 30)
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

    -- Función para actualizar posiciones de la GUI
    local function updateGUIPosition(newPos)
        gui.Position = newPos
        gui.Background.Position = newPos
        gui.Button.Position = Vector2.new(newPos.X + 10, newPos.Y + 10)
        gui.Text.Position = Vector2.new(newPos.X + 60, newPos.Y + 30)
        gui.Info.Position = Vector2.new(newPos.X + 60, newPos.Y + 70)
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

    -- Detectar clic en el botón y arrastre
    local function checkClick(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local bgPos = gui.Background.Position
            local bgSize = gui.Background.Size
            
            -- Verificar si el clic está dentro del fondo de la GUI
            if mousePos.X >= bgPos.X and mousePos.X <= bgPos.X + bgSize.X and
               mousePos.Y >= bgPos.Y and mousePos.Y <= bgPos.Y + bgSize.Y then
                
                -- Verificar si es clic en el botón (área más pequeña)
                local buttonPos = gui.Button.Position
                local buttonSize = gui.Button.Size
                
                if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                   mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
                    toggleESP()
                else
                    -- Iniciar arrastre
                    dragging = true
                    dragStart = input.Position
                    startPos = gui.Background.Position
                    
                    -- Cambiar color durante arrastre
                    gui.Background.Color = Color3.fromRGB(60, 60, 60)
                end
            end
        end
    end

    -- Función para manejar el arrastre
    local function handleDrag(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = Vector2.new(startPos.X + delta.X, startPos.Y + delta.Y)
            updateGUIPosition(newPos)
        end
    end

    -- Función para soltar el arrastre
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                -- Restaurar color
                gui.Background.Color = Color3.fromRGB(40, 40, 40)
            end
        end
    end

    -- Conectar eventos
    UserInputService.InputBegan:Connect(checkClick)
    UserInputService.InputChanged:Connect(handleDrag)
    UserInputService.InputEnded:Connect(endDrag)

    -- Limpiar al cerrar
    game:GetService("UserInputService").WindowFocusReleased:Connect(function()
        if dragging then
            dragging = false
            gui.Background.Color = Color3.fromRGB(40, 40, 40)
        end
    end)

    print("🎯 ESP SCRIPT CARGADO!")
    print("📍 GUI en el centro de la pantalla")
    print("👆 Click en el botón para activar/desactivar")
    print("🖱️  Arrastra el fondo para mover la GUI")
end
