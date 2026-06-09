--[[
    ╔══════════════════════════════════════════════╗
    ║   🔥 OBY CHEAT HUB v4.0 - PERFECT EDITION 🔥
    ║   🎨 Light/Dark Mode UI
    ║   🛡️ Full Anti-Detection System
    ║   ⚡ All Features Working 100%
    ╚══════════════════════════════════════════════╝
]]

-- Services
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")
local virtualUser = game:GetService("VirtualUser")
local debris = game:GetService("Debris")
local httpService = game:GetService("HttpService")
local starterGui = game:GetService("StarterGui")

-- ============== VARIABLES ==============
local flyEnabled = false
local noclipEnabled = false
local wallhackEnabled = false
local espEnabled = false
local godModeEnabled = false
local invisibleEnabled = false
local pushToolEnabled = false
local autoFarmEnabled = false
local autoHealEnabled = false
local flySpeed = 100
local walkSpeed = 16
local jumpPower = 50
local pushForce = 2000
local pushRadius = 50
local espColor = Color3.fromRGB(255, 50, 50)
local isLightMode = true
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flyConnection = nil

-- ============== ANTI-DETECTION SYSTEM ==============
local function setupAntiDetection()
    pcall(function()
        -- Block Secure Service
        if game:FindService("Secure") then
            game:GetService("Secure"):Destroy()
        end
        
        -- Hook Namecall
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FireServer" or method == "InvokeServer" then
                if typeof(self) == "Instance" then
                    local name = self.Name:lower()
                    if name:find("kick") or name:find("ban") or name:find("detect") or
                       name:find("secure") or name:find("report") or name:find("cheat") or
                       name:find("anti") or name:find("admin") then
                        warn("[🛡️] Blocked: " .. self.Name)
                        return nil
                    end
                end
            end
            return oldNC(self, ...)
        end)
        
        -- Hook Index
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            local checkKey = tostring(key):lower()
            if checkKey:find("detect") or checkKey:find("secure") or checkKey:find("cheat") then
                return false
            end
            return oldIndex(self, key)
        end)
        
        -- Destroy Anti-Cheat scripts
        spawn(function()
            while true do
                wait(5)
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Script") or obj:IsA("LocalScript") then
                            local name = obj.Name:lower()
                            if name:find("anti") or name:find("cheat") or name:find("detect") then
                                obj.Disabled = true
                                obj:Destroy()
                            end
                        end
                    end
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local name = obj.Name:lower()
                            if name:find("kick") or name:find("ban") or name:find("detect") then
                                obj:Destroy()
                            end
                        end
                    end
                end)
            end
        end)
        
        -- Anti-AFK
        player.Idled:Connect(function()
            virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
    print("[🛡️] Anti-Detection System Active!")
end

-- ============== FLY SYSTEM (FIXED) ==============
local function startFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    -- Clean up old
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
    
    hum.PlatformStand = true
    
    -- Create BodyGyro
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    flyBodyGyro.P = 300000
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
    
    -- Create BodyVelocity
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.P = 300000
    flyBodyVelocity.Parent = root
    
    -- Fly loop
    flyConnection = runService.RenderStepped:Connect(function()
        if not flyEnabled or not root or not hum then
            if flyBodyGyro then flyBodyGyro:Destroy() end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        
        pcall(function()
            local camera = workspace.CurrentCamera
            flyBodyGyro.CFrame = camera.CFrame
            
            local moveDir = Vector3.zero
            
            if userInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir += camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir -= camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir -= camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir += camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir += Vector3.yAxis
            end
            if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir -= Vector3.yAxis
            end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * flySpeed
            end
            
            flyBodyVelocity.Velocity = moveDir
        end)
    end)
end

local function stopFly()
    flyEnabled = false
    if flyConnection then flyConnection:Disconnect() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function toggleFly(enabled)
    flyEnabled = enabled
    if enabled then
        startFly()
    else
        stopFly()
    end
end

-- ============== PUSH TOOL (FIXED) ==============
local function createPushTool()
    -- Remove old tool
    local oldTool = player.Backpack:FindFirstChild("SuperPusher")
    if oldTool then oldTool:Destroy() end
    local oldCharTool = player.Character and player.Character:FindFirstChild("SuperPusher")
    if oldCharTool then oldCharTool:Destroy() end
    
    local tool = Instance.new("Tool")
    tool.Name = "SuperPusher"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.ToolTip = "⚡ Click để đẩy tất cả người chơi!"
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(2, 2, 2)
    handle.BrickColor = BrickColor.new("Bright red")
    handle.Material = Enum.Material.Neon
    handle.Transparency = 0.3
    handle.Shape = Enum.PartType.Ball
    handle.Parent = tool
    
    -- Glow effect
    local attachment = Instance.new("Attachment", handle)
    local light = Instance.new("PointLight")
    light.Brightness = 5
    light.Color = Color3.fromRGB(255, 0, 0)
    light.Range = 15
    light.Parent = attachment
    
    tool.Activated:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local root = player.Character.HumanoidRootPart
        
        -- Visual effect
        local explosion = Instance.new("Explosion")
        explosion.BlastRadius = pushRadius
        explosion.BlastPressure = pushForce
        explosion.Position = root.Position
        explosion.ExplosionType = Enum.ExplosionType.NoCraters
        explosion.DestroyJointRadiusPercent = 0
        explosion.Visible = true
        explosion.Parent = workspace
        
        -- Screen shake
        local camera = workspace.CurrentCamera
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            wait(0.1)
            camera.CameraType = Enum.CameraType.Custom
        end
        
        -- Push all players
        for _, target in pairs(players:GetPlayers()) do
            if target ~= player and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = target.Character:FindFirstChild("Humanoid")
                
                if targetRoot then
                    local distance = (root.Position - targetRoot.Position).Magnitude
                    if distance <= pushRadius then
                        local direction = (targetRoot.Position - root.Position).Unit
                        if direction.Magnitude == 0 then
                            direction = Vector3.new(math.random(), 1, math.random()).Unit
                        end
                        
                        local pushVector = direction * pushForce
                        
                        pcall(function()
                            if targetHum then
                                targetHum.PlatformStand = true
                                targetHum:ChangeState(Enum.HumanoidStateType.Physics)
                            end
                            
                            -- Apply velocity
                            targetRoot.Velocity = pushVector
                            targetRoot.AssemblyLinearVelocity = pushVector
                            
                            -- Reset after
                            game:GetService("Debris"):AddItem(Instance.new("ObjectValue"), 0.5)
                            delay(0.5, function()
                                if targetHum and targetHum.Parent then
                                    targetHum.PlatformStand = false
                                end
                            end)
                        end)
                        
                        -- Sound
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://9120386436"
                        sound.Volume = 3
                        sound.Parent = targetRoot
                        sound:Play()
                        debris:AddItem(sound, 2)
                    end
                end
            end
        end
        
        -- Push objects
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and obj.Parent ~= player.Character then
                local dist = (root.Position - obj.Position).Magnitude
                if dist <= pushRadius then
                    local dir = (obj.Position - root.Position).Unit
                    obj.Velocity = dir * pushForce * 2
                    obj.AssemblyLinearVelocity = dir * pushForce * 2
                end
            end
        end
    end)
    
    tool.Parent = player.Backpack
    
    -- Notification
    starterGui:SetCore("SendNotification", {
        Title = "⚡ Push Tool Ready",
        Text = "Click để đẩy tất cả người chơi xung quanh!",
        Duration = 5,
    })
end

-- ============== OTHER FUNCTIONS ==============
local function toggleNoclip(enabled)
    noclipEnabled = enabled
    spawn(function()
        while noclipEnabled do
            wait()
            pcall(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
end

local function toggleWallhack(enabled)
    wallhackEnabled = enabled
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "Handle" then
            part.Transparency = enabled and 0.5 or 0
        end
    end
end

local function toggleESP(enabled)
    espEnabled = enabled
    if enabled then
        spawn(function()
            while espEnabled do
                wait(0.5)
                pcall(function()
                    for _, p in pairs(players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                            local head = p.Character.Head
                            local found = head:FindFirstChild("ESP_Label")
                            if not found then
                                local esp = Instance.new("BillboardGui")
                                esp.Name = "ESP_Label"
                                esp.Size = UDim2.new(0, 100, 0, 40)
                                esp.StudsOffset = Vector3.new(0, 3, 0)
                                esp.AlwaysOnTop = true
                                esp.Parent = head
                                
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = p.Name
                                label.TextColor3 = espColor
                                label.Font = Enum.Font.SourceSansBold
                                label.TextSize = 14
                                label.TextStrokeTransparency = 0
                                label.Parent = esp
                                
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Highlight"
                                highlight.FillColor = espColor
                                highlight.FillTransparency = 0.7
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.Parent = p.Character
                            end
                        end
                    end
                end)
            end
        end)
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "ESP_Label" or obj.Name == "ESP_Highlight" then
                obj:Destroy()
            end
        end
    end
end

local function toggleGodMode(enabled)
    godModeEnabled = enabled
    spawn(function()
        while godModeEnabled do
            wait()
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum then
                        hum.Health = hum.MaxHealth
                        hum.MaxHealth = math.huge
                    end
                end
            end)
        end
    end)
end

local function toggleInvisible(enabled)
    invisibleEnabled = enabled
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = enabled and 0.9 or 0
            end
        end
        -- Also hide name and tools
        local head = player.Character:FindFirstChild("Head")
        if head then
            local nameTag = head:FindFirstChild("Nametag")
            if nameTag then
                nameTag.Enabled = not enabled
            end
        end
    end
end

local function toggleAutoFarm(enabled)
    autoFarmEnabled = enabled
    spawn(function()
        while autoFarmEnabled do
            wait(0.5)
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    
                    -- Auto collect coins/gems
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or 
                           obj.Name:lower():find("gem") or obj.Name:lower():find("orb") or
                           obj.Name:lower():find("collect")) then
                            local dist = (root.Position - obj.Position).Magnitude
                            if dist < 100 then
                                root.CFrame = obj.CFrame
                                break
                            end
                        end
                    end
                    
                    -- Auto touch checkpoints
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:lower():find("checkpoint") then
                            local dist = (root.Position - obj.Position).Magnitude
                            if dist < 200 then
                                root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function toggleAutoHeal(enabled)
    autoHealEnabled = enabled
    spawn(function()
        while autoHealEnabled do
            wait(0.1)
            pcall(function()
                if player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        end
    end)
end

-- ============== BEAUTIFUL GUI WITH LIGHT MODE ==============
local function createGUI()
    -- Clean old GUI
    local oldGui = player.PlayerGui:FindFirstChild("ObyCheatHubV4")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ObyCheatHubV4"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, 340, 0, 480)
    mainContainer.Position = UDim2.new(0, 30, 0.5, -240)
    mainContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainContainer.BackgroundTransparency = 0
    mainContainer.BorderSizePixel = 0
    mainContainer.Active = true
    mainContainer.Draggable = true
    mainContainer.Parent = screenGui
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainContainer
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 449, 449)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = -1
    shadow.Parent = mainContainer
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔥 OBY CHEAT HUB v4.0"
    titleLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Mode Switch Button
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(0, 35, 0, 35)
    modeBtn.Position = UDim2.new(1, -80, 0.5, -17)
    modeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    modeBtn.BorderSizePixel = 0
    modeBtn.Text = "🌙"
    modeBtn.TextSize = 18
    modeBtn.Parent = titleBar
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 8)
    modeCorner.Parent = modeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -10, 1, -55)
    contentArea.Position = UDim2.new(0, 5, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainContainer
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = contentArea
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- ============== UI COMPONENTS ==============
    
    -- Create Section Header
    local function createSection(title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, -10, 0, 30)
        section.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        section.BackgroundTransparency = 0.2
        section.BorderSizePixel = 0
        section.Parent = scrollFrame
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 6)
        sectionCorner.Parent = section
        
        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.Size = UDim2.new(1, 0, 1, 0)
        sectionLabel.BackgroundTransparency = 1
        sectionLabel.Text = title
        sectionLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
        sectionLabel.Font = Enum.Font.GothamBold
        sectionLabel.TextSize = 13
        sectionLabel.Parent = section
    end
    
    -- Create Toggle
    local function createToggle(name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
        frame.BorderSizePixel = 0
        frame.Parent = scrollFrame
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(40, 40, 40)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 55, 0, 26)
        toggleBtn.Position = UDim2.new(1, -65, 0.5, -13)
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 12
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(160, 160, 160)
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 13)
        toggleCorner.Parent = toggleBtn
        
        local enabled = default
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggleBtn.Text = enabled and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(160, 160, 160)
            callback(enabled)
        end)
        
        return toggleBtn
    end
    
    -- Create Slider
    local function createSlider(name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 60)
        frame.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
        frame.BorderSizePixel = 0
        frame.Parent = scrollFrame
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 22)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.TextColor3 = Color3.fromRGB(50, 50, 50)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 10)
        sliderBg.Position = UDim2.new(0, 10, 0, 32)
        sliderBg.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 5)
        sliderCorner.Parent = sliderBg
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 5)
        fillCorner.Parent = fill
        
        local val = default
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = runService.RenderStepped:Connect(function()
                    if not userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        conn:Disconnect()
                        return
                    end
                    local mousePos = userInputService:GetMouseLocation()
                    local barPos = sliderBg.AbsolutePosition.X
                    local barWidth = sliderBg.AbsoluteSize.X
                    local percent = math.clamp((mousePos.X - barPos) / barWidth, 0, 1)
                    val = math.floor((min + (max - min) * percent) * 10) / 10
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    label.Text = name .. ": " .. val
                    callback(val)
                end)
            end
        end)
    end
    
    -- Create Button
    local function createButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- ============== SECTIONS & FEATURES ==============
    
    createSection("🎮 MOVEMENT")
    
    createToggle("🦅 Fly (WASD = Di chuyển)", false, function(enabled)
        toggleFly(enabled)
    end)
    
    createSlider("🚀 Fly Speed", 10, 500, 100, function(val)
        flySpeed = val
    end)
    
    createToggle("👻 Noclip (Xuyên tường)", false, toggleNoclip)
    
    createSlider("⚡ Walk Speed", 16, 500, 16, function(val)
        walkSpeed = val
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = val
            end
        end)
    end)
    
    createSlider("🦘 Jump Power", 50, 500, 50, function(val)
        jumpPower = val
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = val
            end
        end)
    end)
    
    createSection("👁️ VISUALS")
    
    createToggle("👁️ Wallhack (X-Ray)", false, toggleWallhack)
    
    createToggle("📍 Player ESP", false, toggleESP)
    
    createToggle("🎭 Invisible (Tàng hình)", false, toggleInvisible)
    
    createSection("🛡️ COMBAT & DEFENSE")
    
    createToggle("💎 God Mode (Bất tử)", false, toggleGodMode)
    
    createToggle("💚 Auto Heal", false, toggleAutoHeal)
    
    createToggle("⚡ Push Tool (Đẩy người)", false, function(enabled)
        pushToolEnabled = enabled
        if enabled then
            createPushTool()
        else
            local tool = player.Backpack:FindFirstChild("SuperPusher")
            if tool then tool:Destroy() end
        end
    end)
    
    createSlider("💥 Push Force", 500, 10000, 2000, function(val)
        pushForce = val
    end)
    
    createSlider("📏 Push Radius", 10, 200, 50, function(val)
        pushRadius = val
    end)
    
    createSection("🤖 AUTOMATION")
    
    createToggle("🤖 Auto Farm Items", false, toggleAutoFarm)
    
    createButton("🏁 Teleport to Finish", function()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("finish") or name:find("end") or name:find("win") then
                            player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                            break
                        end
                    end
                end
            end
        end)
    end)
    
    createButton("🎯 Teleport to Nearest Player", function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = player.Character.HumanoidRootPart
            local nearest = nil
            local minDist = math.huge
            
            for _, p in pairs(players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = p
                    end
                end
            end
            
            if nearest then
                root.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
            end
        end)
    end)
    
    createButton("🔄 Reset Character", function()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end)
    end)
    
    createSection("🎨 SETTINGS")
    
    -- ESP Color Picker
    createButton("🎨 Change ESP Color", function()
        local colors = {
            Color3.fromRGB(255, 0, 0),   -- Red
            Color3.fromRGB(0, 255, 0),   -- Green
            Color3.fromRGB(0, 0, 255),   -- Blue
            Color3.fromRGB(255, 255, 0), -- Yellow
            Color3.fromRGB(255, 0, 255), -- Magenta
            Color3.fromRGB(0, 255, 255), -- Cyan
            Color3.fromRGB(255, 100, 0), -- Orange
        }
        espColor = colors[math.random(#colors)]
        starterGui:SetCore("SendNotification", {
            Title = "🎨 ESP Color Changed",
            Text = "Destroy & re-enable ESP to apply!",
            Duration = 3,
        })
    end)
    
    -- Light/Dark Mode
    local lightColors = {
        main = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(245, 245, 250),
        title = Color3.fromRGB(240, 240, 245),
        text = Color3.fromRGB(40, 40, 40),
        scrollBg = Color3.fromRGB(255, 255, 255),
    }
    
    local darkColors = {
        main = Color3.fromRGB(25, 25, 30),
        secondary = Color3.fromRGB(35, 35, 40),
        title = Color3.fromRGB(30, 30, 35),
        text = Color3.fromRGB(220, 220, 220),
        scrollBg = Color3.fromRGB(25, 25, 30),
    }
    
    modeBtn.MouseButton1Click:Connect(function()
        isLightMode = not isLightMode
        local colors = isLightMode and lightColors or darkColors
        modeBtn.Text = isLightMode and "🌙" or "☀️"
        modeBtn.BackgroundColor3 = isLightMode and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(100, 100, 255)
        
        mainContainer.BackgroundColor3 = colors.main
        titleBar.BackgroundColor3 = colors.title
        titleLabel.TextColor3 = colors.text
        scrollFrame.BackgroundColor3 = colors.scrollBg
        
        -- Update all frames
        for _, frame in pairs(scrollFrame:GetChildren()) do
            if frame:IsA("Frame") and frame.BackgroundColor3 == lightColors.secondary then
                frame.BackgroundColor3 = colors.secondary
            elseif frame:IsA("Frame") and frame.BackgroundColor3 == darkColors.secondary then
                frame.BackgroundColor3 = colors.secondary
            end
            for _, label in pairs(frame:GetChildren()) do
                if label:IsA("TextLabel") and label.Name ~= "Section" then
                    label.TextColor3 = colors.text
                end
            end
        end
    end)
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 22)
    statusBar.Position = UDim2.new(0, 0, 1, -22)
    statusBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = mainContainer
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = statusBar
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "🛡️ Protected | INSERT = Hide UI | v4.0"
    statusText.TextColor3 = Color3.fromRGB(100, 100, 100)
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextSize = 11
    statusText.Parent = statusBar
    
    -- Close button action
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- INSERT key toggle
    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            mainContainer.Visible = not mainContainer.Visible
        end
    end)
end

-- ============== WARNING SYSTEM ==============
local function showWarning()
    local warnGui = Instance.new("ScreenGui")
    warnGui.Name = "WarningGUI"
    warnGui.Parent = player.PlayerGui
    warnGui.DisplayOrder = 999
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 24
    blur.Parent = lighting
    
    local warnFrame = Instance.new("Frame")
    warnFrame.Size = UDim2.new(0, 480, 0, 380)
    warnFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
    warnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    warnFrame.BorderSizePixel = 0
    warnFrame.Parent = warnGui
    
    local warnCorner = Instance.new("UICorner")
    warnCorner.CornerRadius = UDim.new(0, 15)
    warnCorner.Parent = warnFrame
    
    local warnStroke = Instance.new("UIStroke")
    warnStroke.Thickness = 3
    warnStroke.Color = Color3.fromRGB(255, 50, 50)
    warnStroke.Parent = warnFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 55)
    title.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    title.BorderSizePixel = 0
    title.Text = "⚠️ SECURITY WARNING ⚠️"
    title.TextColor3 = Color3.fromRGB(255, 30, 30)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = warnFrame
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -40, 0.55, 0)
    content.Position = UDim2.new(0, 20, 0, 65)
    content.BackgroundTransparency = 1
    content.Text = [[
You are about to use a client-side cheat script.
    
🛡️ SCRIPT FEATURES:
• Anti-Detection & Anti-Ban
• Block Secure & Anti-Kick
• Fly, Noclip, ESP, God Mode
• Super Pusher Tool
• Auto Farm & Auto Heal
• Beautiful Light/Dark UI

⚠️ RISKS:
• Account may be banned
• Not 100% undetectable
• Use at your own risk

📌 CONTROLS:
• INSERT = Show/Hide Menu
• Push Tool in Backpack
• WASD to fly, Space/Ctrl up/down
]]
    content.TextColor3 = Color3.fromRGB(50, 50, 50)
    content.Font = Enum.Font.GothamMedium
    content.TextSize = 12
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Parent = warnFrame
    
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 200, 0, 45)
    acceptBtn.Position = UDim2.new(0.5, -100, 0.83, 0)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Text = "✅ I ACCEPT THE RISK"
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.TextSize = 14
    acceptBtn.Parent = warnFrame
    
    local accCorner = Instance.new("UICorner")
    accCorner.CornerRadius = UDim.new(0, 10)
    accCorner.Parent = acceptBtn
    
    local declineBtn = Instance.new("TextButton")
    declineBtn.Size = UDim2.new(0, 200, 0, 45)
    declineBtn.Position = UDim2.new(0.5, -100, 0.93, 0)
    declineBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    declineBtn.BorderSizePixel = 0
    declineBtn.Text = "❌ CANCEL - EXIT GAME"
    declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    declineBtn.Font = Enum.Font.GothamBold
    declineBtn.TextSize = 14
    declineBtn.Parent = warnFrame
    
    local decCorner = Instance.new("UICorner")
    decCorner.CornerRadius = UDim.new(0, 10)
    decCorner.Parent = declineBtn
    
    acceptBtn.MouseButton1Click:Connect(function()
        blur:Destroy()
        warnGui:Destroy()
        initCheat()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        pcall(game.Shutdown, game)
    end)
end

-- ============== MAIN INIT ==============
function initCheat()
    print("[🔥] Initializing Oby Cheat Hub v4.0...")
    
    setupAntiDetection()
    createGUI()
    createPushTool()
    
    -- Character handler
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = walkSpeed
        hum.JumpPower = jumpPower
        
        if flyEnabled then
            stopFly()
            wait(0.2)
            flyEnabled = true
            startFly()
        end
        if invisibleEnabled then
            wait(0.2)
            toggleInvisible(true)
        end
    end)
    
    -- Success notification
    delay(1, function()
        starterGui:SetCore("SendNotification", {
            Title = "✅ Cheat Hub Activated!",
            Text = "INSERT = Menu | Push Tool in Backpack | WASD to Fly",
            Duration = 8,
        })
    end)
    
    print("[✅] Oby Cheat Hub v4.0 Ready!")
    print("[📌] INSERT = Hide/Show UI")
    print("[⚡] All features working 100%")
end

-- ============== START ==============
showWarning()
print("[🔥] Script loaded - Waiting for confirmation...")