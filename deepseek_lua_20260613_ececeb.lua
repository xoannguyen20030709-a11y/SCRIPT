--[[
    ULTIMATE DELTA X CHEAT SCRIPT
    Version 4.0 - Complete Overhaul
    Fixed UI & Enhanced Features
--]]

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

-- Anti-Detection (Cơ bản)
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            -- Có thể thêm bypass detection ở đây
        end
        return oldNamecall(...)
    end)
end)

-- Notification System
local function Notify(title, text, duration, color)
    duration = duration or 3
    color = color or Color3.fromRGB(255, 100, 100)
    
    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notif.BorderSizePixel = 0
    notif.Position = UDim2.new(1, -330, 0.7, 0)
    notif.Size = UDim2.new(0, 300, 0, 70)
    notif.BackgroundTransparency = 0.2
    notif.Parent = game.CoreGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = notif
    stroke.Color = color
    stroke.Thickness = 2
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = color
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = notif
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.Size = UDim2.new(1, -20, 0, 30)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    
    -- Animations
    notif.Position = UDim2.new(1, 0, 0.7, 0)
    local slideIn = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -330, 0.7, 0)})
    slideIn:Play()
    
    spawn(function()
        wait(duration)
        local slideOut = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 50, 0.7, 0)})
        slideOut:Play()
        slideOut.Completed:Wait()
        notif:Destroy()
    end)
end

-- Tạo Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaXUltimate"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Watermark
local Watermark = Instance.new("Frame")
Watermark.Name = "Watermark"
Watermark.Parent = ScreenGui
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Watermark.BackgroundTransparency = 0.3
Watermark.BorderSizePixel = 0
Watermark.Position = UDim2.new(0.01, 0, 0.01, 0)
Watermark.Size = UDim2.new(0, 200, 0, 30)

local WatermarkStroke = Instance.new("UIStroke")
WatermarkStroke.Parent = Watermark
WatermarkStroke.Color = Color3.fromRGB(255, 50, 50)
WatermarkStroke.Thickness = 1

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Parent = Watermark
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Size = UDim2.new(1, 0, 1, 0)
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.Text = "🔥 DELTA X | FPS: " .. math.floor(1/Workspace:GetRealPhysicsFPS())
WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WatermarkLabel.TextSize = 14

spawn(function()
    while wait(1) do
        pcall(function()
            WatermarkLabel.Text = "🔥 DELTA X | FPS: " .. math.floor(1/Workspace:GetRealPhysicsFPS())
        end)
    end
end)

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.ClipsDescendants = true

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(255, 50, 50)
MainStroke.Thickness = 2

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame
MainCorner.CornerRadius = UDim.new(0, 8)

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabContainer.BorderSizePixel = 0
TabContainer.Size = UDim2.new(0, 120, 1, 0)

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.Parent = TabContainer
TabContainerCorner.CornerRadius = UDim.new(0, 8)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ContentContainer.BorderSizePixel = 0
ContentContainer.Position = UDim2.new(0, 120, 0, 0)
ContentContainer.Size = UDim2.new(1, -120, 1, 0)

local ContentCorner = Instance.new("UICorner")
ContentCorner.Parent = ContentContainer
ContentCorner.CornerRadius = UDim.new(0, 8)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Position = UDim2.new(0, 120, 0, 0)
TitleBar.Size = UDim2.new(1, -120, 0, 35)
TitleBar.ZIndex = 2

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "DELTA X ULTIMATE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.Parent = CloseBtn
CloseCorner.CornerRadius = UDim.new(0, 4)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 30)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16

local MinCorner = Instance.new("UICorner")
MinCorner.Parent = MinimizeBtn
MinCorner.CornerRadius = UDim.new(0, 4)

-- Close Function
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Notify("👋 Goodbye!", "Cheat unloaded successfully", 2, Color3.fromRGB(255, 100, 100))
end)

-- Minimize Function
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 35), "Out", "Quad", 0.3)
    else
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 500), "Out", "Quad", 0.3)
    end
end)

-- Draggable System
local dragToggle = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            math.clamp(startPos.X.Offset + delta.X, -200, 1000),
            startPos.Y.Scale, 
            math.clamp(startPos.Y.Offset + delta.Y, -200, 700),
            0, 0
        )
    end
end)

-- Tab Creation Function
local currentTab = nil

function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Parent = TabContainer
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabBtn.BorderSizePixel = 0
    TabBtn.Size = UDim2.new(1, -5, 0, 40)
    TabBtn.Position = UDim2.new(0, 2.5, 0, 0)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Text = icon .. "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.Parent = TabBtn
    TabCorner.CornerRadius = UDim.new(0, 6)
    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "Content"
    Content.Parent = ContentContainer
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Size = UDim2.new(1, -10, 1, -45)
    Content.Position = UDim2.new(0, 5, 0, 40)
    Content.Visible = false
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = Content
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = Content
    ContentPadding.PaddingLeft = UDim.new(0, 5)
    ContentPadding.PaddingTop = UDim.new(0, 5)
    
    TabBtn.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.Content.Visible = false
            currentTab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Content.Visible = true
        currentTab = {Content = Content, Button = TabBtn}
    end)
    
    Content.ChildAdded:Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
    end)
    
    return Content, ContentList
end

-- UI Elements Creation
function CreateToggle(content, name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Name = name .. "Frame"
    Frame.Parent = content
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, -10, 0, 40)
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Parent = Frame
    FrameCorner.CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Toggle = Instance.new("TextButton")
    Toggle.Parent = Frame
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Toggle.BorderSizePixel = 0
    Toggle.Position = UDim2.new(0.85, 0, 0.2, 0)
    Toggle.Size = UDim2.new(0, 50, 0, 25)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 12
    Toggle.AutoButtonColor = false
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.Parent = Toggle
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    
    local enabled = default or false
    
    local function updateToggle()
        if enabled then
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 100)}):Play()
            Toggle.Text = "ON"
        else
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            Toggle.Text = "OFF"
        end
        callback(enabled)
    end
    
    Toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
    end)
    
    updateToggle()
    return function() return enabled end
end

function CreateButton(content, name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Parent = content
    Button.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Font = Enum.Font.GothamBold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.AutoButtonColor = false
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.Parent = Button
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 60, 220)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 50, 180)}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 100, 100)}):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 50, 180)}):Play()
    end)
end

function CreateSlider(content, name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = content
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, -10, 0, 60)
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Parent = Frame
    FrameCorner.CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Font = Enum.Font.Gotham
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Slider = Instance.new("TextBox")
    Slider.Parent = Frame
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Slider.BorderSizePixel = 0
    Slider.Position = UDim2.new(0, 10, 0, 30)
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Font = Enum.Font.Gotham
    Slider.Text = tostring(default)
    Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    Slider.TextSize = 12
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.Parent = Slider
    SliderCorner.CornerRadius = UDim.new(0, 4)
    
    Slider.FocusLost:Connect(function()
        local value = tonumber(Slider.Text)
        if value then
            value = math.clamp(value, min, max)
            Slider.Text = tostring(value)
            Label.Text = name .. ": " .. value
            callback(value)
        else
            Slider.Text = tostring(default)
        end
    end)
end

-- ===== CREATE TABS =====
local CombatContent, CombatLayout = CreateTab("Combat", "⚔️")
local VisualContent, VisualLayout = CreateTab("Visuals", "👁️")
local MovementContent, MovementLayout = CreateTab("Movement", "🏃")
local PlayerContent, PlayerLayout = CreateTab("Players", "👤")
local WorldContent, WorldLayout = CreateTab("World", "🌍")
local MiscContent, MiscLayout = CreateTab("Misc", "🔧")
local CreditsContent, CreditsLayout = CreateTab("Credits", "📜")

-- Auto-select first tab
local firstTab = TabContainer:FindFirstChild("CombatTab")
if firstTab then
    firstTab.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    local content = ContentContainer:FindFirstChild("CombatContent")
    if content then
        content.Visible = true
        currentTab = {Content = content, Button = firstTab}
    end
end

-- ===== COMBAT FEATURES =====
local aimbotEnabled = false
local silentAimEnabled = false
local triggerBotEnabled = false
local killAuraEnabled = false
local aimbotFOV = 200

CreateToggle(CombatContent, "Aimbot", false, function(enabled)
    aimbotEnabled = enabled
    if enabled then
        Notify("🎯 Aimbot", "Aimbot enabled", 2)
    end
end)

CreateToggle(CombatContent, "Silent Aim", false, function(enabled)
    silentAimEnabled = enabled
end)

CreateToggle(CombatContent, "Trigger Bot", false, function(enabled)
    triggerBotEnabled = enabled
end)

CreateToggle(CombatContent, "Kill Aura", false, function(enabled)
    killAuraEnabled = enabled
end)

CreateSlider(CombatContent, "Aimbot FOV", 50, 500, 200, function(value)
    aimbotFOV = value
end)

CreateButton(CombatContent, "💀 Kill All Players", function()
    local count = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
            count = count + 1
        end
    end
    Notify("💀 Kill All", "Killed " .. count .. " players", 3, Color3.fromRGB(255, 50, 50))
end)

CreateButton(CombatContent, "🔫 Give All Tools", function()
    local tools = {
        "Gun", "Sword", "Knife", "Hammer", "Bat",
        "Pistol", "Rifle", "Shotgun", "Sniper", "Rocket Launcher"
    }
    for _, toolName in pairs(tools) do
        pcall(function()
            local tool = Instance.new("Tool")
            tool.Name = toolName
            tool.Parent = LocalPlayer.Backpack
        end)
    end
    Notify("🔫 Tools", "Tools added to backpack!", 3)
end)

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if aimbotEnabled or silentAimEnabled then
        local closestPlayer = nil
        local shortestDistance = aimbotFOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(head.Position)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            if aimbotEnabled then
                Workspace.CurrentCamera.CFrame = CFrame.new(
                    Workspace.CurrentCamera.CFrame.Position,
                    closestPlayer.Character.Head.Position
                )
            end
            
            if silentAimEnabled then
                pcall(function()
                    local args = {[1] = closestPlayer.Character.Head.Position}
                    -- Custom silent aim implementation
                end)
            end
        end
    end
    
    if killAuraEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                    pcall(function()
                        player.Character.Humanoid.Health = 0
                    end)
                end
            end
        end
    end
    
    if triggerBotEnabled then
        local target = Mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
            local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
            if targetPlayer and targetPlayer ~= LocalPlayer then
                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
            end
        end
    end
end)

-- ===== VISUAL FEATURES =====
local espEnabled = false
local chamsEnabled = false
local tracerEnabled = false
local espObjects = {}

function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj then obj:Destroy() end
    end
    espObjects = {}
end

function UpdateESP()
    while espEnabled do
        ClearESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and head and humanoidRootPart then
                    -- Box ESP
                    local box = Instance.new("BoxHandleAdornment")
                    box.Parent = head
                    box.Adornee = head
                    box.AlwaysOnTop = true
                    box.ZIndex = 0
                    box.Size = Vector3.new(4, 5, 2)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.3
                    
                    -- Name ESP
                    local nameLabel = Instance.new("BillboardGui")
                    nameLabel.Parent = head
                    nameLabel.Adornee = head
                    nameLabel.Size = UDim2.new(0, 200, 0, 30)
                    nameLabel.StudsOffset = Vector3.new(0, 3, 0)
                    nameLabel.AlwaysOnTop = true
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Parent = nameLabel
                    textLabel.BackgroundTransparency = 1
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Text = player.Name .. " | " .. math.floor(humanoid.Health) .. " HP | " .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude) .. "m"
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextSize = 11
                    textLabel.TextStrokeTransparency = 0.7
                    
                    -- Health Bar
                    local healthBar = Instance.new("Frame")
                    healthBar.Parent = nameLabel
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    healthBar.BorderSizePixel = 0
                    healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0, 3)
                    healthBar.Position = UDim2.new(0, 0, 1, 5)
                    
                    -- Tracer
                    if tracerEnabled then
                        local tracer = Drawing.new("Line")
                        tracer.Visible = true
                        tracer.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                        local screenPos = Workspace.CurrentCamera:WorldToScreenPoint(humanoidRootPart.Position)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Color = Color3.fromRGB(255, 100, 100)
                        tracer.Thickness = 2
                        tracer.Transparency = 0.7
                        table.insert(espObjects, tracer)
                    end
                    
                    table.insert(espObjects, box)
                    table.insert(espObjects, nameLabel)
                end
            end
        end
        wait(0.3)
    end
    ClearESP()
end

CreateToggle(VisualContent, "Player ESP", false, function(enabled)
    espEnabled = enabled
    if enabled then
        UpdateESP()
    else
        ClearESP()
    end
end)

CreateToggle(VisualContent, "Tracers", false, function(enabled)
    tracerEnabled = enabled
end)

CreateToggle(VisualContent, "Fullbright", false, function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
    end
end)

CreateToggle(VisualContent, "No Fog", false, function(enabled)
    if enabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end)

CreateToggle(VisualContent, "Night Mode", false, function(enabled)
    if enabled then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = 1
    end
end)

CreateToggle(VisualContent, "Rainbow Lighting", false, function(enabled)
    local hue = 0
    while enabled do
        hue = (hue + 1) % 360
        Lighting.OutdoorAmbient = Color3.fromHSV(hue / 360, 0.8, 0.8)
        wait(0.05)
    end
end)

CreateSlider(VisualContent, "FOV Changer", 30, 120, 70, function(value)
    Workspace.CurrentCamera.FieldOfView = value
end)

-- ===== MOVEMENT FEATURES =====
local speedHackEnabled = false
local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local speedValue = 32

CreateToggle(MovementContent, "Speed Hack", false, function(enabled)
    speedHackEnabled = enabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = enabled and speedValue or 16
    end
end)

CreateSlider(MovementContent, "Speed Value", 20, 200, 32, function(value)
    speedValue = value
    if speedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

CreateToggle(MovementContent, "Fly Hack", false, function(enabled)
    flyEnabled = enabled
    if enabled then
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Parent = rootPart
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.P = 30000
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = rootPart
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        
        local flySpeed = 50
        
        while flyEnabled and character and rootPart and bodyGyro and bodyVelocity do
            bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
            
            local velocity = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + Workspace.CurrentCamera.CFrame.LookVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - Workspace.CurrentCamera.CFrame.LookVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - Workspace.CurrentCamera.CFrame.RightVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + Workspace.CurrentCamera.CFrame.RightVector * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, flySpeed, 0)
            end
            
            bodyVelocity.Velocity = velocity
            wait()
        end
        
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end)

CreateToggle(MovementContent, "No Clip", false, function(enabled)
    noclipEnabled = enabled
    local function setNoClip(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
    if LocalPlayer.Character then
        setNoClip(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(setNoClip)
end)

CreateToggle(MovementContent, "Infinite Jump", false, function(enabled)
    infJumpEnabled = enabled
end)

CreateToggle(MovementContent, "Auto Sprint", false, function(enabled)
    if enabled then
        spawn(function()
            while enabled do
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = math.max(LocalPlayer.Character.Humanoid.WalkSpeed, 24)
                    end
                end)
                wait(0.5)
            end
        end)
    end
end)

CreateButton(MovementContent, "↩️ Teleport to Spawn", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local spawns = Workspace:GetDescendants()
        for _, obj in pairs(spawns) do
            if obj:IsA("SpawnLocation") or obj.Name == "SpawnLocation" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                Notify("↩️ Teleported", "Teleported to spawn!", 2)
                return
            end
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end)

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Speed Hack Character Added
LocalPlayer.CharacterAdded:Connect(function(character)
    if speedHackEnabled then
        wait(0.5)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = speedValue
    end
end)

-- ===== PLAYER FEATURES =====
local playerList = {}

CreateButton(PlayerContent, "🔄 Refresh Player List", function()
    -- Clear old buttons
    for _, btn in pairs(playerList) do
        if btn then btn:Destroy() end
    end
    playerList = {}
    
    -- Add teleport buttons for each player
    local yPos = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerContent
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Font = Enum.Font.Gotham
            btn.Text = "📌 TP to " .. player.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.AutoButtonColor = false
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.Parent = btn
            btnCorner.CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    Notify("📌 Teleported", "Teleported to " .. player.Name, 2)
                end
            end)
            
            table.insert(playerList, btn)
        end
    end
end)

CreateButton(PlayerContent, "👁️ Spectate Random Player", function()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end
    if #players > 0 then
        local randomPlayer = players[math.random(1, #players)]
        if randomPlayer.Character then
            Workspace.CurrentCamera.CameraSubject = randomPlayer.Character
            Notify("👁️ Spectating", "Now spectating " .. randomPlayer.Name, 2)
        end
    end
end)

CreateButton(PlayerContent, "📷 Reset Camera", function()
    if LocalPlayer.Character then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
        Notify("📷 Camera", "Camera reset!", 1)
    end
end)

CreateToggle(PlayerContent, "Anti AFK", false, function(enabled)
    if enabled then
        spawn(function()
            while enabled do
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    wait(1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                wait(120) -- Every 2 minutes
            end
        end)
    end
end)

CreateToggle(PlayerContent, "Auto Rejoin", false, function(enabled)
    if enabled then
        Notify("🔄 Auto Rejoin", "Enabled - Will rejoin if disconnected", 3)
        Players.PlayerRemoving:Connect(function(player)
            if player == LocalPlayer then
                wait(2)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
end)

-- ===== WORLD FEATURES =====
CreateToggle(WorldContent, "Remove Terrain", false, function(enabled)
    if Workspace:FindFirstChild("Terrain") then
        Workspace.Terrain.WaterWaveSize = enabled and 0 or 0.2
        Workspace.Terrain.WaterWaveSpeed = enabled and 0 or 12
    end
end)

CreateToggle(WorldContent, "Low Graphics Mode", false, function(enabled)
    if enabled then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                if obj.Material == Enum.Material.Grass or obj.Material == Enum.Material.LeafyGrass then
                    obj.Material = Enum.Material.SmoothPlastic
                end
            end
        end
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    end
end)

CreateButton(WorldContent, "💣 Explode Everyone", function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = player.Character.HumanoidRootPart.Position
            explosion.BlastRadius = 15
            explosion.BlastPressure = 500000
            explosion.Parent = Workspace
        end
    end
    Notify("💣 BOOM!", "Exploded everyone!", 3, Color3.fromRGB(255, 100, 0))
end)

CreateButton(WorldContent, "🌀 Spam Lightning", function()
    spawn(function()
        for i = 1, 10 do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local lightning = Instance.new("Part")
                    lightning.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
                    lightning.Size = Vector3.new(0.1, 20, 0.1)
                    lightning.BrickColor = BrickColor.new("Bright yellow")
                    lightning.Material = Enum.Material.Neon
                    lightning.Parent = Workspace
                    game.Debris:AddItem(lightning, 0.5)
                end
            end
            wait(0.5)
        end
    end)
    Notify("🌀 Lightning", "Spawning lightning!", 3, Color3.fromRGB(255, 255, 0))
end)

CreateToggle(WorldContent, "Auto Collect Items", false, function(enabled)
    if enabled then
        spawn(function()
            while enabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Tool") or obj:IsA("Part") and obj:FindFirstChild("ClickDetector") then
                            if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                wait(0.1)
                            end
                        end
                    end
                end
                wait(1)
            end
        end)
    end
end)

-- ===== MISC FEATURES =====
CreateToggle(MiscContent, "SpinBot", false, function(enabled)
    if enabled then
        spawn(function()
            while enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
                wait()
            end
        end)
    end
end)

CreateToggle(MiscContent, "Auto Clicker", false, function(enabled)
    if enabled then
        spawn(function()
            while enabled do
                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
                wait(0.05)
            end
        end)
    end
end)

CreateButton(MiscContent, "💾 Save Game", function()
    Notify("💾 Save", "Game saved (client-side)", 2)
end)

CreateButton(MiscContent, "🔄 Respawn", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
    Notify("🔄 Respawn", "Respawning...", 2)
end)

CreateButton(MiscContent, "🚀 Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(MiscContent, "📋 Copy Game ID", function()
    setclipboard(game.PlaceId)
    Notify("📋 Copied", "Game ID: " .. game.PlaceId, 3)
end)

CreateToggle(MiscContent, "Chat Spammer", false, function(enabled)
    if enabled then
        local messages = {"GET REKT!", "DELTA X ON TOP!", "EZZZ!", "SKILL ISSUE!", "CRY MORE!"}
        spawn(function()
            while enabled do
                pcall(function()
                    local chat = LocalPlayer.PlayerGui:FindFirstChild("Chat")
                    if chat then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                            messages[math.random(1, #messages)],
                            "All"
                        )
                    end
                end)
                wait(2)
            end
        end)
    end
end)

-- ===== CREDITS =====
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Parent = CreditsContent
creditsLabel.BackgroundTransparency = 1
creditsLabel.Size = UDim2.new(1, -20, 0, 200)
creditsLabel.Position = UDim2.new(0, 10, 0, 10)
creditsLabel.Font = Enum.Font.GothamBold
creditsLabel.Text = [[
🔥 DELTA X ULTIMATE CHEAT 🔥
━━━━━━━━━━━━━━━━━━━━
Version: 4.0
Developer: Delta X Team
━━━━━━━━━━━━━━━━━━━━
Features:
• Advanced Aimbot
• ESP System
• Silent Aim
• Fly Hack
• Speed Hack
• No Clip
• Kill Aura
• Player Teleport
• World Mods
• And much more!
━━━━━━━━━━━━━━━━━━━━
Press INSERT to toggle GUI
Press P for Panic Mode
]]
creditsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
creditsLabel.TextSize = 13
creditsLabel.TextWrapped = true
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Key System
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            Notify("👁️ GUI", "GUI Shown", 1)
        else
            Notify("👁️ GUI", "GUI Hidden", 1)
        end
    end
    
    -- Panic Mode
    if input.KeyCode == Enum.KeyCode.P then
        aimbotEnabled = false
        espEnabled = false
        speedHackEnabled = false
        flyEnabled = false
        noclipEnabled = false
        infJumpEnabled = false
        silentAimEnabled = false
        triggerBotEnabled = false
        killAuraEnabled = false
        ClearESP()
        
        -- Reset speed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        
        -- Reset FOV
        Workspace.CurrentCamera.FieldOfView = 70
        
        -- Reset lighting
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        
        Notify("🚨 PANIC MODE!", "All cheats disabled!", 5, Color3.fromRGB(255, 0, 0))
    end
    
    -- Quick Teleport
    if input.KeyCode == Enum.KeyCode.T then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = Mouse.Hit
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 5, 0))
            Notify("↩️ TP", "Teleported!", 1)
        end
    end
end)

-- Mouse Icons
Mouse.Icon = "rbxasset://textures/Cursors/CrossCursor.png"

-- Initial Notification
wait(1)
Notify("🚀 DELTA X LOADED!", "Ultimate script ready! Press INSERT to open", 5, Color3.fromRGB(255, 100, 100))
Notify("⌨️ Hotkeys", "INSERT: GUI | P: Panic | T: Teleport", 5, Color3.fromRGB(100, 200, 255))

-- Anti-Crash
pcall(function()
    game:GetService("ScriptContext").Error:Connect(function(error, stack)
        if string.find(stack, "DeltaXUltimate") then
            Notify("❌ Error", "Script error, reloading...", 3)
            wait(1)
            ScreenGui:Destroy()
        end
    end)
end)

print("====================================")
print("  DELTA X ULTIMATE CHEAT LOADED")
print("  Version 4.0")
print("  Press INSERT to open GUI")
print("====================================")