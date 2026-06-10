-- Ultimate Roblox Hub - Fixed & Enhanced
-- Tương thích: Delta X VNG

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Anti-Detection System
local function setupAntiDetection()
    -- Hook vào __namecall để chặn kick/ban
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" and self == LocalPlayer then
            return nil
        end
        
        if method == "FireServer" and tostring(self) == "Kick" then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Chặn RemoteEvent kicks
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("kick") or v.Name:lower():find("ban")) then
            v.Parent = nil
        end
    end
    
    -- Anti-Crash
    LocalPlayer.OnKicked:Connect(function()
        return nil
    end)
end

-- ESP System
local ESP = {
    Objects = {},
    Settings = {
        Enabled = false,
        Boxes = false,
        Tracers = false,
        Names = false,
        Health = false,
        Distance = false,
        BoxColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 0, 0)
    }
}

function ESP:Create(player)
    local drawings = {}
    
    -- Box ESP
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = self.Settings.BoxColor
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    drawings.Box = box
    
    -- Health Bar
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Transparency = 1
    healthBar.Filled = true
    drawings.HealthBar = healthBar
    
    local healthOutline = Drawing.new("Square")
    healthOutline.Visible = false
    healthOutline.Color = Color3.fromRGB(0, 0, 0)
    healthOutline.Thickness = 1
    healthOutline.Transparency = 1
    healthOutline.Filled = false
    drawings.HealthOutline = healthOutline
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = self.Settings.TracerColor
    tracer.Thickness = 2
    tracer.Transparency = 0.7
    drawings.Tracer = tracer
    
    -- Name
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.Name = nameTag
    
    -- Distance
    local distanceTag = Drawing.new("Text")
    distanceTag.Visible = false
    distanceTag.Color = Color3.fromRGB(200, 200, 200)
    distanceTag.Size = 12
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.Distance = distanceTag
    
    self.Objects[player] = drawings
end

function ESP:Remove(player)
    if self.Objects[player] then
        for _, drawing in pairs(self.Objects[player]) do
            drawing:Remove()
        end
        self.Objects[player] = nil
    end
end

function ESP:Update()
    for player, drawings in pairs(self.Objects) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local character = player.Character
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if head and hrp then
                local headPos = Camera:WorldToScreenPoint(head.Position)
                local hrpPos = Camera:WorldToScreenPoint(hrp.Position)
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
                
                local onScreen = headPos.Z > 0
                
                -- Toggle visibility based on settings
                local showESP = self.Settings.Enabled and onScreen
                
                if self.Settings.Boxes and showESP then
                    local size = Vector2.new(2000 / headPos.Z, 3500 / headPos.Z)
                    drawings.Box.Size = size
                    drawings.Box.Position = Vector2.new(headPos.X - size.X/2, headPos.Y - size.Y/2)
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                if self.Settings.Health and showESP then
                    local health = humanoid.Health
                    local maxHealth = humanoid.MaxHealth
                    local healthPercent = health / maxHealth
                    
                    local size = Vector2.new(2000 / headPos.Z, 3500 / headPos.Z)
                    local barWidth = 4
                    
                    drawings.HealthOutline.Size = Vector2.new(barWidth, size.Y)
                    drawings.HealthOutline.Position = Vector2.new(headPos.X - size.X/2 - barWidth - 2, headPos.Y - size.Y/2)
                    drawings.HealthOutline.Visible = true
                    
                    drawings.HealthBar.Size = Vector2.new(barWidth, size.Y * healthPercent)
                    drawings.HealthBar.Position = Vector2.new(headPos.X - size.X/2 - barWidth - 2, headPos.Y - size.Y/2 + size.Y * (1 - healthPercent))
                    drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    drawings.HealthBar.Visible = true
                else
                    drawings.HealthBar.Visible = false
                    drawings.HealthOutline.Visible = false
                end
                
                if self.Settings.Tracers and showESP then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                if self.Settings.Names and showESP then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 40)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
                
                if self.Settings.Distance and showESP then
                    drawings.Distance.Text = string.format("%.0fm", distance)
                    drawings.Distance.Position = Vector2.new(headPos.X, headPos.Y + 20)
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end
            end
        end
    end
end

-- Hitbox Expander
local Hitbox = {
    Enabled = false,
    Size = 10,
    OriginalSizes = {}
}

function Hitbox:StoreOriginalSizes(player)
    if not self.OriginalSizes[player] and player.Character then
        self.OriginalSizes[player] = {}
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                self.OriginalSizes[player][part] = part.Size
            end
        end
    end
end

function Hitbox:Expand()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:StoreOriginalSizes(player)
            
            if self.Enabled then
                local multiplier = self.Size / 10
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and self.OriginalSizes[player][part] then
                        part.Size = self.OriginalSizes[player][part] * multiplier
                    end
                end
            else
                if self.OriginalSizes[player] then
                    for part, originalSize in pairs(self.OriginalSizes[player]) do
                        if part and part.Parent then
                            part.Size = originalSize
                        end
                    end
                end
            end
        end
    end
end

-- Aimbot System
local Aimbot = {
    Enabled = false,
    Smoothing = 5,
    FOV = 100,
    TargetPart = "Head",
    VisibilityCheck = true,
    FOVCircle = nil
}

function Aimbot:CreateFOVCircle()
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Visible = false
    self.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    self.FOVCircle.Thickness = 1
    self.FOVCircle.Transparency = 0.5
    self.FOVCircle.NumSides = 100
end

function Aimbot:GetClosestPlayer()
    local closest = nil
    local shortest = self.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local target = player.Character:FindFirstChild(self.TargetPart)
            if target then
                local screenPos = Camera:WorldToScreenPoint(target.Position)
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                
                if distance < shortest and screenPos.Z > 0 then
                    -- Visibility check
                    if self.VisibilityCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hit and hit:IsDescendantOf(player.Character) then
                            shortest = distance
                            closest = player
                        end
                    else
                        shortest = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

-- UI Creation
local function createLoader()
    local loader = Instance.new("ScreenGui")
    loader.Name = "LoaderScreen"
    loader.Parent = game:GetService("CoreGui")
    loader.ResetOnSpawn = false
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    background.BorderSizePixel = 0
    background.Parent = loader
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    })
    gradient.Rotation = 45
    gradient.Parent = background
    
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 350, 0, 220)
    loadingFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Parent = background
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = loadingFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = loadingFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.Text = "🚀 LOADING SYSTEM"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.BackgroundTransparency = 1
    title.Parent = loadingFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 65)
    subtitle.Text = "by ScriptHub Premium"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.BackgroundTransparency = 1
    subtitle.Parent = loadingFrame
    
    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0.8, 0, 0, 10)
    loadingBar.Position = UDim2.new(0.1, 0, 0.5, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 5)
    barCorner.Parent = loadingBar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = loadingBar
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
    })
    fillGradient.Parent = fill
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fill
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0.6, 0)
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.BackgroundTransparency = 1
    status.Parent = loadingFrame
    
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.new(1, 0, 0, 20)
    dots.Position = UDim2.new(0, 0, 0.68, 0)
    dots.Text = ""
    dots.TextColor3 = Color3.fromRGB(0, 170, 255)
    dots.Font = Enum.Font.Gotham
    dots.TextSize = 12
    dots.BackgroundTransparency = 1
    dots.Parent = loadingFrame
    
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 20)
    version.Position = UDim2.new(0, 0, 0.9, 0)
    version.Text = "v2.5.0 | Delta X VNG"
    version.TextColor3 = Color3.fromRGB(100, 100, 100)
    version.Font = Enum.Font.Gotham
    version.TextSize = 10
    version.BackgroundTransparency = 1
    version.Parent = loadingFrame
    
    -- Loading animation
    spawn(function()
        local phases = {
            {text = "Loading core components...", progress = 30},
            {text = "Setting up anti-detection...", progress = 50},
            {text = "Initializing ESP system...", progress = 70},
            {text = "Loading hitbox expander...", progress = 85},
            {text = "Setting up aimbot...", progress = 95},
            {text = "Loading UI...", progress = 100}
        }
        
        for _, phase in ipairs(phases) do
            status.Text = phase.text
            fill:TweenSize(UDim2.new(phase.progress/100, 0, 1, 0), "Out", "Quad", 0.5)
            
            for i = 1, 3 do
                dots.Text = string.rep(".", i)
                wait(0.3)
            end
            
            wait(0.2)
        end
        
        wait(0.5)
        fill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.1)
        wait(0.2)
        loader:Destroy()
    end)
end

local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateHub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main container
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 15)
    SidebarCorner.Parent = Sidebar
    
    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = TitleBar
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
    })
    TitleGradient.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.Text = "🎮 ULTIMATE HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TitleBar
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0, 7)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 24
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 10)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -80, 0, 7)
    MinimizeBtn.Text = "─"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 10)
    MinCorner.Parent = MinimizeBtn
    
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame.Size = minimized and UDim2.new(0, 550, 0, 50) or UDim2.new(0, 550, 0, 450)
        Sidebar.Visible = not minimized
    end)
    
    -- Tab buttons
    local tabs = {
        {name = "🎯 ESP", icon = ""},
        {name = "📦 Hitbox", icon = ""},
        {name = "🎯 Aimbot", icon = ""},
        {name = "⚙️ Settings", icon = ""}
    }
    
    local tabButtons = {}
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 45)
        btn.Text = tab.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = Sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Enabled = false
        btnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
        })
        btnGradient.Parent = btn
        
        table.insert(tabButtons, {button = btn, gradient = btnGradient})
    end
    
    -- Content pages
    local pages = {}
    for i = 1, #tabs do
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -180, 1, -10)
        page.Position = UDim2.new(0, 170, 0, 55)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = (i == 1)
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        page.Parent = MainFrame
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.Parent = page
        
        local UIPadding = Instance.new("UIPadding")
        UIPadding.PaddingTop = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 10)
        UIPadding.PaddingRight = UDim.new(0, 10)
        UIPadding.Parent = page
        
        table.insert(pages, page)
    end
    
    -- Tab switching
    local function switchTab(index)
        for i, page in ipairs(pages) do
            page.Visible = (i == index)
        end
        for i, data in ipairs(tabButtons) do
            data.gradient.Enabled = (i == index)
            data.button.BackgroundColor3 = (i == index) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 50)
        end
    end
    
    for i, data in ipairs(tabButtons) do
        data.button.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end
    
    -- Create Toggle function
    local function createToggle(parent, text, default, callback)
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(1, 0, 0, 45)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        toggle.BorderSizePixel = 0
        toggle.Parent = parent
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0.05, 0, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = toggle
        
        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 45, 0, 24)
        switch.Position = UDim2.new(0.85, 0, 0.5, -12)
        switch.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
        switch.BorderSizePixel = 0
        switch.Parent = toggle
        
        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(0, 12)
        switchCorner.Parent = switch
        
        local switchKnob = Instance.new("Frame")
        switchKnob.Size = UDim2.new(0, 18, 0, 18)
        switchKnob.Position = UDim2.new(default and 1 or 0, default and -21 or 3, 0.5, -9)
        switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchKnob.BorderSizePixel = 0
        switchKnob.Parent = switch
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = switchKnob
        
        local enabled = default
        local function updateSwitch()
            switch.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
            switchKnob:TweenPosition(UDim2.new(enabled and 1 or 0, enabled and -21 or 3, 0.5, -9), "Out", "Quad", 0.2)
        end
        
        local switchBtn = Instance.new("TextButton")
        switchBtn.Size = UDim2.new(1, 0, 1, 0)
        switchBtn.BackgroundTransparency = 1
        switchBtn.Text = ""
        switchBtn.Parent = switch
        
        switchBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            updateSwitch()
            if callback then callback(enabled) end
        end)
        
        if default and callback then
            spawn(function() callback(true) end)
        end
        
        return toggle
    end
    
    -- Create Slider function
    local function createSlider(parent, text, min, max, default, callback)
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 60)
        slider.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        slider.BorderSizePixel = 0
        slider.Parent = parent
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 10)
        sliderCorner.Parent = slider
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.Position = UDim2.new(0.85, 0, 0, 5)
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.BackgroundTransparency = 1
        valueLabel.Parent = slider
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.75, 0, 0, 25)
        label.Position = UDim2.new(0.05, 0, 0, 5)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.Parent = slider
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(0.8, 0, 0, 6)
        sliderBar.Position = UDim2.new(0.1, 0, 0, 40)
        sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = slider
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 3)
        barCorner.Parent = sliderBar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill
        
        local sliderBtn = Instance.new("Frame")
        sliderBtn.Size = UDim2.new(0, 16, 0, 16)
        sliderBtn.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
        sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderBtn.BorderSizePixel = 0
        sliderBtn.Parent = sliderBar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = sliderBtn
        
        local btnDrag = Instance.new("TextButton")
        btnDrag.Size = UDim2.new(2, 0, 2, 0)
        btnDrag.Position = UDim2.new(-0.5, 0, -0.5, 0)
        btnDrag.BackgroundTransparency = 1
        btnDrag.Text = ""
        btnDrag.Parent = sliderBtn
        
        local value = default
        local dragging = false
        
        btnDrag.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position.X
                local barPos = sliderBar.AbsolutePosition.X
                local barSize = sliderBar.AbsoluteSize.X
                local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                
                value = math.floor((min + (max - min) * percent) * 10) / 10
                
                fill.Size = UDim2.new(percent, 0, 1, 0)
                sliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
                valueLabel.Text = tostring(value)
                
                if callback then callback(value) end
            end
        end)
        
        return slider
    end
    
    -- ESP Page
    local espGroup = Instance.new("TextLabel")
    espGroup.Size = UDim2.new(1, 0, 0, 25)
    espGroup.Text = "ESP SETTINGS"
    espGroup.TextColor3 = Color3.fromRGB(0, 170, 255)
    espGroup.Font = Enum.Font.GothamBold
    espGroup.TextSize = 16
    espGroup.TextXAlignment = Enum.TextXAlignment.Left
    espGroup.BackgroundTransparency = 1
    espGroup.Parent = pages[1]
    
    createToggle(pages[1], "ESP Master", ESP.Settings.Enabled, function(v)
        ESP.Settings.Enabled = v
    end)
    createToggle(pages[1], "Box ESP", ESP.Settings.Boxes, function(v)
        ESP.Settings.Boxes = v
    end)
    createToggle(pages[1], "Tracers", ESP.Settings.Tracers, function(v)
        ESP.Settings.Tracers = v
    end)
    createToggle(pages[1], "Names", ESP.Settings.Names, function(v)
        ESP.Settings.Names = v
    end)
    createToggle(pages[1], "Health Bar", ESP.Settings.Health, function(v)
        ESP.Settings.Health = v
    end)
    createToggle(pages[1], "Distance", ESP.Settings.Distance, function(v)
        ESP.Settings.Distance = v
    end)
    
    -- Hitbox Page
    local hitboxGroup = Instance.new("TextLabel")
    hitboxGroup.Size = UDim2.new(1, 0, 0, 25)
    hitboxGroup.Text = "HITBOX SETTINGS"
    hitboxGroup.TextColor3 = Color3.fromRGB(0, 170, 255)
    hitboxGroup.Font = Enum.Font.GothamBold
    hitboxGroup.TextSize = 16
    hitboxGroup.TextXAlignment = Enum.TextXAlignment.Left
    hitboxGroup.BackgroundTransparency = 1
    hitboxGroup.Parent = pages[2]
    
    createToggle(pages[2], "Hitbox Expander", Hitbox.Enabled, function(v)
        Hitbox.Enabled = v
    end)
    createSlider(pages[2], "Hitbox Size", 1, 30, Hitbox.Size, function(v)
        Hitbox.Size = v
    end)
    
    -- Aimbot Page
    local aimbotGroup = Instance.new("TextLabel")
    aimbotGroup.Size = UDim2.new(1, 0, 0, 25)
    aimbotGroup.Text = "AIMBOT SETTINGS"
    aimbotGroup.TextColor3 = Color3.fromRGB(0, 170, 255)
    aimbotGroup.Font = Enum.Font.GothamBold
    aimbotGroup.TextSize = 16
    aimbotGroup.TextXAlignment = Enum.TextXAlignment.Left
    aimbotGroup.BackgroundTransparency = 1
    aimbotGroup.Parent = pages[3]
    
    createToggle(pages[3], "Aimbot", Aimbot.Enabled, function(v)
        Aimbot.Enabled = v
        if Aimbot.FOVCircle then
            Aimbot.FOVCircle.Visible = v
        end
    end)
    createSlider(pages[3], "Smoothing", 1, 20, Aimbot.Smoothing, function(v)
        Aimbot.Smoothing = v
    end)
    createSlider(pages[3], "FOV", 30, 500, Aimbot.FOV, function(v)
        Aimbot.FOV = v
    end)
    createToggle(pages[3], "Visibility Check", Aimbot.VisibilityCheck, function(v)
        Aimbot.VisibilityCheck = v
    end)
    
    -- Settings Page
    local settingsGroup = Instance.new("TextLabel")
    settingsGroup.Size = UDim2.new(1, 0, 0, 25)
    settingsGroup.Text = "PROTECTION SETTINGS"
    settingsGroup.TextColor3 = Color3.fromRGB(0, 170, 255)
    settingsGroup.Font = Enum.Font.GothamBold
    settingsGroup.TextSize = 16
    settingsGroup.TextXAlignment = Enum.TextXAlignment.Left
    settingsGroup.BackgroundTransparency = 1
    settingsGroup.Parent = pages[4]
    
    createToggle(pages[4], "Anti-Ban/Kick", false, function(v)
        if v then
            setupAntiDetection()
        end
    end)
    
    createToggle(pages[4], "Auto-Attach", false, function(v)
        -- Always attach to new players
    end)
    
    -- Switch to first tab
    switchTab(1)
    
    return ScreenGui
end

-- Initialize everything
createLoader()

-- Wait for loader to finish
wait(3)

-- Setup systems
setupAntiDetection()
Aimbot:CreateFOVCircle()

-- Create UI
local ui = createUI()

-- Player tracking for ESP
Players.PlayerAdded:Connect(function(player)
    ESP:Create(player)
    Hitbox:StoreOriginalSizes(player)
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:Remove(player)
    if Hitbox.OriginalSizes[player] then
        Hitbox.OriginalSizes[player] = nil
    end
end)

-- Initialize for existing players
for _, player in ipairs(Players:GetPlayers()) do
    ESP:Create(player)
    Hitbox:StoreOriginalSizes(player)
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    ESP:Update()
    
    if Aimbot.Enabled then
        local target = Aimbot:GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.TargetPart) then
            local targetPart = target.Character[Aimbot.TargetPart]
            local currentCFrame = Camera.CFrame
            local smoothness = 1 / Aimbot.Smoothing
            
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentCFrame.Position, targetPart.Position), smoothness)
        end
        
        -- Update FOV circle
        if Aimbot.FOVCircle then
            Aimbot.FOVCircle.Radius = Aimbot.FOV
            Aimbot.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            Aimbot.FOVCircle.Visible = true
        end
    elseif Aimbot.FOVCircle then
        Aimbot.FOVCircle.Visible = false
    end
    
    Hitbox:Expand()
end)

print("Ultimate Hub loaded successfully!")
print("Features: ESP | Hitbox | Aimbot | Anti-Ban")