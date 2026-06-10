--[[
    Ultimate Auto Farm Obby Tower - Delta X VNG
    Full Features: Auto Teleport, Auto Collect, Anti-Ban, Anti-Kick, Player Actions
    Version: 2.0 Pro
]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

--// Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// Config
local Config = {
    Main = {
        Enabled = false,
        AutoRejoin = true,
        RejoinDelay = 5,
        MaxStages = 999,
        TeleportSpeed = 0.2,
    },
    
    Farm = {
        AutoCollect = true,
        CollectRadius = 50,
        CollectDelay = 0.5,
        AutoJump = true,
        JumpPower = 50,
        WalkSpeed = 50,
        Noclip = true,
        GodMode = false,
    },
    
    Anti = {
        AntiBan = true,
        AntiKick = true,
        AntiAFK = true,
        AntiTeleportDetect = true,
        AntiVoteKick = true,
        FPSBoost = true,
    },
    
    Visual = {
        ESP = true,
        ItemESP = true,
        PlayerESP = true,
        TracerLines = true,
        Distance = 1000,
    },
    
    Actions = {
        AutoRespawn = true,
        AutoRejoinServer = false,
        SpamEmotes = false,
        EmoteList = {"wave", "point", "dance", "laugh"},
        EmoteDelay = 10,
    }
}

--// Anti-Detection System
local AntiDetect = {
    __index = function(t, k)
        return rawget(t, k) or game:GetService(k)
    end
}
setmetatable(Players, AntiDetect)

--// Anti-Ban Protection
local function AntiBan()
    if not Config.Anti.AntiBan then return end
    
    -- Bảo vệ khỏi RemoteEvent Detection
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Chặn các report event
        if method == "FireServer" then
            if tostring(self):lower():find("report") or 
               tostring(self):lower():find("ban") or 
               tostring(self):lower():find("kick") or
               tostring(self):lower():find("anticheat") then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Chặn kick
    local oldKick = player.Kick
    player.Kick = function(self, ...)
        if Config.Anti.AntiKick then
            return nil
        end
        return oldKick(self, ...)
    end
    
    -- Chặn Teleport Detection
    if Config.Anti.AntiTeleportDetect then
        local oldFunc = hookfunction(player.RequestStreamAround, function(...)
            return
        end)
    end
end

--// Anti-VoteKick
local function AntiVoteKick()
    if not Config.Anti.AntiVoteKick then return end
    
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            if tostring(remote):lower():find("vote") or 
               tostring(remote):lower():find("kick") then
                remote.OnServerEvent:Connect(function(...)
                    return nil
                end)
            end
        end
    end
end

--// FPS Boost
local function FPSBoost()
    if not Config.Anti.FPSBoost then return end
    
    -- Tắt các hiệu ứng không cần thiết
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    -- Giảm graphics
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    
    -- Tăng FPS
    settings().Rendering.QualityLevel = 1
    UserSettings():GetService("UserGameSettings").MasterVolume = 0
end

--// Anti-AFK System
local function AntiAFK()
    if not Config.Anti.AntiAFK then return end
    
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    
    -- Loop Anti-AFK
    task.spawn(function()
        while Config.Anti.AntiAFK and Config.Main.Enabled do
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            task.wait(10)
        end
    end)
end

--// Noclip System
local function Noclip()
    if not Config.Farm.Noclip then return end
    
    task.spawn(function()
        while Config.Farm.Noclip and Config.Main.Enabled do
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

--// God Mode
local function GodMode()
    if not Config.Farm.GodMode then return end
    
    task.spawn(function()
        while Config.Farm.GodMode and Config.Main.Enabled do
            if humanoid then
                humanoid.MaxHealth = 9e9
                humanoid.Health = 9e9
            end
            task.wait(0.1)
        end
    end)
end

--// Item/Obby Detection System
local ItemDetector = {}
ItemDetector.Items = {}
ItemDetector.Obstacles = {}
ItemDetector.Checkpoints = {}
ItemDetector.Stages = {}

function ItemDetector:Scan()
    self.Items = {}
    self.Obstacles = {}
    self.Checkpoints = {}
    self.Stages = {}
    
    -- Tìm items (tiền, gem, vật phẩm)
    local itemKeywords = {
        "coin", "gem", "crystal", "diamond", "orb", "token", "money", 
        "treasure", "chest", "reward", "collect", "pickup", "item",
        "powerup", "boost", "speed", "jump", "shield"
    }
    
    -- Tìm stages/checkpoints
    local stageKeywords = {
        "stage", "checkpoint", "finish", "end", "win", "complete",
        "next", "portal", "door", "gate", "flag"
    }
    
    -- Tìm chướng ngại vật
    local obstacleColors = {
        Color3.new(1, 0, 0), -- Red
        Color3.new(1, 1, 0), -- Yellow
        Color3.new(1, 0, 1), -- Magenta
        Color3.new(1, 0.4, 0), -- Orange
        Color3.new(0, 0, 0), -- Black
    }
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 1 then
            local name = obj.Name:lower()
            
            -- Check items
            for _, keyword in ipairs(itemKeywords) do
                if name:find(keyword) or (obj.Parent and obj.Parent.Name:lower():find(keyword)) then
                    table.insert(self.Items, obj)
                    break
                end
            end
            
            -- Check stages
            for _, keyword in ipairs(stageKeywords) do
                if name:find(keyword) then
                    table.insert(self.Stages, obj)
                    break
                end
            end
            
            -- Check obstacles by color
            for _, color in ipairs(obstacleColors) do
                if obj.Color == color then
                    table.insert(self.Obstacles, obj)
                    break
                end
            end
        end
    end
end

--// ESP System
local ESP = {}
ESP.Objects = {}

function ESP:Create(object, color, name)
    if not Config.Visual.ESP then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Adornee = object
    highlight.Parent = object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = name
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    table.insert(self.Objects, {highlight = highlight, billboard = billboard})
end

function ESP:Clear()
    for _, obj in ipairs(self.Objects) do
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboard then obj.billboard:Destroy() end
    end
    self.Objects = {}
end

function ESP:Update()
    self:Clear()
    
    if not Config.Visual.ESP then return end
    
    -- Item ESP
    if Config.Visual.ItemESP then
        for _, item in ipairs(ItemDetector.Items) do
            self:Create(item, Color3.new(0, 1, 0), "💎 ITEM")
        end
    end
    
    -- Stage ESP
    for _, stage in ipairs(ItemDetector.Stages) do
        self:Create(stage, Color3.new(1, 1, 0), "🏁 STAGE")
    end
    
    -- Obstacle ESP
    for _, obstacle in ipairs(ItemDetector.Obstacles) do
        self:Create(obstacle, Color3.new(1, 0, 0), "⚠️ DANGER")
    end
    
    -- Player ESP
    if Config.Visual.PlayerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local distance = (humanoidRootPart.Position - head.Position).Magnitude
                    if distance <= Config.Visual.Distance then
                        self:Create(head, Color3.new(0, 0.7, 1), "👤 " .. plr.Name)
                    end
                end
            end
        end
    end
end

--// Auto Collect System
local function AutoCollect()
    if not Config.Farm.AutoCollect then return end
    
    for _, item in ipairs(ItemDetector.Items) do
        if item and item.Parent and humanoidRootPart then
            local distance = (humanoidRootPart.Position - item.Position).Magnitude
            if distance <= Config.Farm.CollectRadius then
                -- Teleport đến item
                local targetPos = item.Position + Vector3.new(0, 3, 0)
                humanoidRootPart.CFrame = CFrame.new(targetPos)
                task.wait(0.05)
                
                -- Thử pick up
                firetouchinterest(humanoidRootPart, item, 0)
                firetouchinterest(humanoidRootPart, item, 1)
                
                task.wait(Config.Farm.CollectDelay)
            end
        end
    end
end

--// Teleport to Stage
local function TeleportToStage(stage)
    if not stage or not humanoidRootPart then return false end
    
    local targetPos = stage.Position + Vector3.new(0, 5, 0)
    
    -- Smooth teleport với Tween
    local tweenInfo = TweenInfo.new(
        Config.Main.TeleportSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(targetPos)}
    )
    
    tween:Play()
    tween.Completed:Wait()
    
    return true
end

--// Obstacle Avoidance
local function AvoidObstacles()
    for _, obstacle in ipairs(ItemDetector.Obstacles) do
        if obstacle and humanoidRootPart then
            local distance = (humanoidRootPart.Position - obstacle.Position).Magnitude
            if distance < 8 then
                -- Nhảy qua
                if Config.Farm.AutoJump and humanoid then
                    humanoid.Jump = true
                    humanoid.JumpPower = Config.Farm.JumpPower
                end
                
                -- Bay qua nếu quá gần
                if distance < 3 then
                    local escapePos = humanoidRootPart.Position + Vector3.new(0, 15, 0)
                    humanoidRootPart.CFrame = CFrame.new(escapePos)
                    task.wait(0.2)
                end
            end
        end
    end
end

--// Auto Respawn
local function AutoRespawn()
    if not Config.Actions.AutoRespawn then return end
    
    if humanoid and humanoid.Health <= 0 then
        task.wait(2)
        -- Force respawn
        local bindable = Instance.new("BindableEvent")
        bindable.Event:Connect(function()
            player:LoadCharacter()
        end)
        bindable:Fire()
        bindable:Destroy()
    end
end

--// Auto Rejoin Server
local function AutoRejoinServer()
    if not Config.Actions.AutoRejoinServer or not Config.Main.AutoRejoin then return end
    
    if #Players:GetPlayers() < 2 then
        task.wait(Config.Main.RejoinDelay)
        TeleportService:Teleport(game.PlaceId, player)
    end
end

--// Emote Spammer
local function EmoteSpammer()
    if not Config.Actions.SpamEmotes then return end
    
    task.spawn(function()
        while Config.Actions.SpamEmotes and Config.Main.Enabled do
            local randomEmote = Config.Actions.EmoteList[math.random(1, #Config.Actions.EmoteList)]
            
            -- Gửi emote command
            local args = {
                [1] = randomEmote
            }
            
            pcall(function()
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                    "/e " .. randomEmote,
                    "All"
                )
            end)
            
            task.wait(Config.Actions.EmoteDelay)
        end
    end)
end

--// WalkSpeed/JumpPower Modifier
local function ModifyCharacter()
    if not character then return end
    
    if humanoid then
        humanoid.WalkSpeed = Config.Farm.WalkSpeed
        humanoid.JumpPower = Config.Farm.JumpPower
        humanoid.HipHeight = 3
    end
    
    -- Xóa fall damage
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

--// Main Farm Loop
local function FarmLoop()
    while Config.Main.Enabled do
        -- Update character reference
        if not character or not humanoidRootPart then
            character = player.Character
            if character then
                humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                humanoid = character:WaitForChild("Humanoid")
                ModifyCharacter()
            end
            task.wait(1)
            continue
        end
        
        -- Respawn check
        AutoRespawn()
        
        -- Scan environment
        ItemDetector:Scan()
        
        -- Update ESP
        pcall(function()
            ESP:Update()
        end)
        
        -- Modify character
        ModifyCharacter()
        
        -- Auto collect items
        AutoCollect()
        
        -- Find nearest stage
        local stages = ItemDetector.Stages
        if #stages > 0 then
            -- Sort by distance
            table.sort(stages, function(a, b)
                return (humanoidRootPart.Position - a.Position).Magnitude < 
                       (humanoidRootPart.Position - b.Position).Magnitude
            end)
            
            local nearestStage = stages[1]
            if nearestStage then
                -- Avoid obstacles first
                AvoidObstacles()
                
                -- Teleport to stage
                local success = TeleportToStage(nearestStage)
                
                if success then
                    -- Fire touch event
                    firetouchinterest(humanoidRootPart, nearestStage, 0)
                    firetouchinterest(humanoidRootPart, nearestStage, 1)
                    
                    -- Check for next stage
                    task.wait(0.2)
                    
                    -- Collect nearby items after reaching stage
                    AutoCollect()
                end
            end
        end
        
        -- Auto rejoin if needed
        AutoRejoinServer()
        
        -- Delay
        task.wait(Config.Farm.CollectDelay)
    end
end

--// GUI System
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateObbyFarm"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.65, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
    })
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBlack
    TitleText.Text = "🌟 ULTIMATE OBBY FARM 🌟"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 100)
    TitleText.TextSize = 16
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.1, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Scrolling Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = ScrollFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Size = UDim2.new(1, -10, 0, 800)
    
    -- Functions to create elements
    local function CreateToggle(parent, position, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Position = position
        ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.GothamSemibold
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.8, 0, 0.15, 0)
        ToggleButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        ToggleButton.AutoButtonColor = false
        
        local isOn = default
        ToggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn
            ToggleButton.Text = isOn and "ON" or "OFF"
            ToggleButton.BackgroundColor3 = isOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            callback(isOn)
        end)
        
        return ToggleFrame
    end
    
    local function CreateSection(parent, position, text)
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Parent = parent
        SectionLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        SectionLabel.BorderSizePixel = 0
        SectionLabel.Position = position
        SectionLabel.Size = UDim2.new(1, -10, 0, 25)
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.Text = text
        SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SectionLabel.TextSize = 14
    end
    
    local yOffset = 0
    
    -- Main Toggle
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "⚡ ENABLE FARM", Config.Main.Enabled, function(value)
        Config.Main.Enabled = value
        if value then
            task.spawn(FarmLoop)
        end
    end)
    yOffset = yOffset + 35
    
    -- Farm Section
    CreateSection(ContentFrame, UDim2.new(0, 0, 0, yOffset), "🎮 FARM SETTINGS")
    yOffset = yOffset + 30
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Auto Collect Items", Config.Farm.AutoCollect, function(value)
        Config.Farm.AutoCollect = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Noclip", Config.Farm.Noclip, function(value)
        Config.Farm.Noclip = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "God Mode", Config.Farm.GodMode, function(value)
        Config.Farm.GodMode = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Auto Jump", Config.Farm.AutoJump, function(value)
        Config.Farm.AutoJump = value
    end)
    yOffset = yOffset + 35
    
    -- Anti Section
    CreateSection(ContentFrame, UDim2.new(0, 0, 0, yOffset), "🛡️ ANTI-DETECTION")
    yOffset = yOffset + 30
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Anti-Ban", Config.Anti.AntiBan, function(value)
        Config.Anti.AntiBan = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Anti-Kick", Config.Anti.AntiKick, function(value)
        Config.Anti.AntiKick = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Anti-VoteKick", Config.Anti.AntiVoteKick, function(value)
        Config.Anti.AntiVoteKick = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "FPS Boost", Config.Anti.FPSBoost, function(value)
        Config.Anti.FPSBoost = value
        if value then FPSBoost() end
    end)
    yOffset = yOffset + 35
    
    -- Visual Section
    CreateSection(ContentFrame, UDim2.new(0, 0, 0, yOffset), "👁️ ESP")
    yOffset = yOffset + 30
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Item ESP", Config.Visual.ItemESP, function(value)
        Config.Visual.ItemESP = value
        ESP:Update()
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Player ESP", Config.Visual.PlayerESP, function(value)
        Config.Visual.PlayerESP = value
        ESP:Update()
    end)
    yOffset = yOffset + 35
    
    -- Actions Section
    CreateSection(ContentFrame, UDim2.new(0, 0, 0, yOffset), "⚡ ACTIONS")
    yOffset = yOffset + 30
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Auto Respawn", Config.Actions.AutoRespawn, function(value)
        Config.Actions.AutoRespawn = value
    end)
    yOffset = yOffset + 35
    
    CreateToggle(ContentFrame, UDim2.new(0, 0, 0, yOffset), "Spam Emotes", Config.Actions.SpamEmotes, function(value)
        Config.Actions.SpamEmotes = value
        if value then EmoteSpammer() end
    end)
    yOffset = yOffset + 35
    
    -- Rejoin Button
    local RejoinButton = Instance.new("TextButton")
    RejoinButton.Parent = ContentFrame
    RejoinButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    RejoinButton.BorderSizePixel = 0
    RejoinButton.Position = UDim2.new(0.05, 0, 0, yOffset)
    RejoinButton.Size = UDim2.new(0.9, 0, 0, 35)
    RejoinButton.Font = Enum.Font.GothamBold
    RejoinButton.Text = "🔄 REJOIN SERVER"
    RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RejoinButton.TextSize = 14
    
    RejoinButton.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    
    -- Update Canvas Size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 50)
    
    return ScreenGui
end

--// Initialize Everything
local function Initialize()
    -- Anti-Detection
    pcall(AntiBan)
    pcall(AntiVoteKick)
    pcall(AntiAFK)
    
    -- Create GUI
    local gui = CreateGUI()
    
    -- Start loops
    task.spawn(function()
        while task.wait(5) do
            if Config.Main.Enabled then
                pcall(function()
                    ItemDetector:Scan()
                    ESP:Update()
                    ModifyCharacter()
                end)
            end
        end
    end)
    
    -- Noclip loop
    task.spawn(Noclip)
    
    -- God Mode loop
    task.spawn(GodMode)
    
    -- Notification
    StarterGui:SetCore("SendNotification", {
        Title = "Ultimate Obby Farm",
        Text = "✅ Loaded Successfully! Press F3 to toggle",
        Duration = 5,
    })
    
    print("✅ Ultimate Obby Farm loaded!")
    print("📌 Features: Auto Farm, Auto Collect, Anti-Ban, ESP, Noclip, God Mode")
    print("🎯 Press F3 to toggle GUI")
end

--// Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        -- Toggle GUI visibility
        local gui = CoreGui:FindFirstChild("UltimateObbyFarm")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        -- Emergency stop
        Config.Main.Enabled = false
        ESP:Clear()
        StarterGui:SetCore("SendNotification", {
            Title = "EMERGENCY STOP",
            Text = "❌ All features disabled",
            Duration = 3,
        })
    end
end)

--// Character Events
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    task.wait(0.5)
    ModifyCharacter()
end)

--// Teleport Protection
player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        Config.Main.Enabled = false
        ESP:Clear()
    end
end)

--// Start
Initialize()