local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local v = require(game:GetService("StarterPlayer").StarterPlayerScripts["TSFL Client"].Modules.BallNetworking)
local x = require(game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Modules.BallNetworking)
local oldfunction = x.IsDistanceTooBig
local oldfunction1 = v.IsDistanceTooBig
local function1 = x.VerifyHit
local function2 = v.VerifyHit
local another1 = x.IsBallBoundingHitbox
local function v1()
  return false
end
local function v2()
  return true
end
hookfunction(oldfunction, v1)
hookfunction(oldfunction1, v1)
hookfunction(function1, v1)
hookfunction(function2, v1)
hookfunction(another1, v2)


local Window = Fluent:CreateWindow({
    Title = "SPJ Reach (Futsal)",
    SubTitle = "by alr_dev",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "house" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Customization = Window:AddTab({ Title = "Customization", Icon = "palette" })
}

local Options = Fluent.Options

-- Core game services
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Player
-- Ball and reach variables
local balls = {}
local lastRefreshTime = os.time()
local reach = 10
local ballOwners = {}
local reachCircle = nil
local ballOwnerEnabled = false
local ballColor = Color3.new(1, 0, 0)
local reachColor = Color3.new(0, 0, 1)
local ballNames = {"TPS", "ESA", "MRS", "PRS", "MPS", "XYZ", "ABC", "LMN", "TRS"}
local autoRefreshEnabled = false

-- ESP setup
local ballESP = Drawing.new("Circle")
local tracerESP = Drawing.new("Line")
local distanceLabel = Drawing.new("Text")

ballESP.Size = 0.3
ballESP.Color = Color3.fromRGB(255, 0, 0)
ballESP.Thickness = 1
ballESP.Transparency = 0.1
ballESP.Filled = true

tracerESP.Thickness = 2
tracerESP.Color = Color3.fromRGB(0, 255, 0)
tracerESP.Transparency = 0.5

distanceLabel.Size = 20
distanceLabel.Color = Color3.fromRGB(255, 255, 255)
distanceLabel.Center = true
distanceLabel.Outline = true

local espEnabled = false
local tracersEnabled = false
local distanceEnabled = false

-- Get Free Plag functionality
local function activateFreePlag()
    hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(_, playerId, gamepassId)
        if playerId == LocalPlayer.UserId then
            return true
        end
        return false
    end)
    
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = false
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = true
    
    Fluent:Notify({
        Title = "Free Plag",
        Content = "Plag functionality activated!",
        Duration = 5
    })
end

-- Ball refresh function
local function refreshBalls(force)
    if not force and lastRefreshTime + 2 > os.time() then
        return
    end
    lastRefreshTime = os.time()
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and table.find(ballNames, v.Name) then
            table.insert(balls, v)
            v.Color = ballColor
        end
    end
end

-- Reach circle functions
local function moveCircleSmoothly(targetPosition)
    if not reachCircle then return end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenGoal = {Position = targetPosition}
    local tween = TweenService:Create(reachCircle, tweenInfo, tweenGoal)
    tween:Play()
end

local function createReachCircle()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if reachCircle then
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
        reachCircle.Color = reachColor
    else
        reachCircle = Instance.new("Part")
        reachCircle.Parent = Workspace
        reachCircle.Shape = Enum.PartType.Ball
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
        reachCircle.Anchored = true
        reachCircle.CanCollide = false
        reachCircle.Transparency = 0.8
        reachCircle.Material = Enum.Material.ForceField
        reachCircle.Color = reachColor
        reachCircle.Position = player.Character.HumanoidRootPart.Position

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and reachCircle then
                local targetPosition = player.Character.HumanoidRootPart.Position
                moveCircleSmoothly(targetPosition)
            end
        end)
    end
end

-- Quantum input handler
local function onQuantumInputBegan(input, gameProcessedEvent)
    local ignoredKeys = {
        [Enum.KeyCode.W] = true,
        [Enum.KeyCode.A] = true,
        [Enum.KeyCode.S] = true,
        [Enum.KeyCode.D] = true,
        [Enum.KeyCode.Space] = true,
        [Enum.KeyCode.Slash] = true,
        [Enum.KeyCode.Semicolon] = true
    }

    if input.UserInputType == Enum.UserInputType.Keyboard and
       (input.KeyCode == Enum.KeyCode.Slash or input.KeyCode == Enum.KeyCode.Semicolon) then
        return
    end

    if ignoredKeys[input.KeyCode] then return end

    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.Comma then
            reach = math.max(1, reach - 1)
            StarterGui:SetCore("SendNotification", {
                Title = "SPJ Reach",
                Text = "Reach set to " .. reach,
                Duration = 0.5
            })
            createReachCircle()
        elseif input.KeyCode == Enum.KeyCode.Period then
            reach = reach + 1
            StarterGui:SetCore("SendNotification", {
                Title = "SPJ Reach",
                Text = "Reach set to " .. reach,
                Duration = 0.5
            })
            createReachCircle()
        else
            refreshBalls(false)
            for _, legName in pairs({"Right Leg", "Left Leg"}) do
                local leg = player.Character:FindFirstChild(legName)
                if leg then
                    for _, v in pairs(leg:GetDescendants()) do
                        if v.Name == "TouchInterest" and v.Parent then
                            for _, e in pairs(balls) do
                                if (e.Position - leg.Position).magnitude < reach then
                                    if ballOwnerEnabled or (not ballOwners[e] or ballOwners[e] == player) then
                                        if not ballOwners[e] then
                                            ballOwners[e] = player
                                        end
                                        firetouchinterest(e, v.Parent, 0)
                                        firetouchinterest(e, v.Parent, 1)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Get closest ball
local function getClosestBall()
    local closestBall = nil
    local closestDistance = math.huge
    for _, ball in pairs(workspace.Balls:GetChildren()) do
        if ball:IsA("Part") then
            local distance = (ball.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    return closestBall
end

-- UI Elements
do
    Fluent:Notify({
        Title = "SPJ Reach (Mps Futsal)",
        Content = "The script has been loaded.",
        Duration = 8
    })

    -- Get Free Plag Button
    Tabs.Main:AddButton({
        Title = "Get Free Plag",
        Description = "Activates free plag functionality",
        Callback = function()
            Window:Dialog({
                Title = "Confirm Free Plag",
                Content = "Are you sure you want to activate free plag?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            activateFreePlag()
                            print("Free Plag activated")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Free Plag activation cancelled")
                        end
                    }
                }
            })
        end
    })

    -- Ball Owner Toggle
    Tabs.Main:AddToggle("BallOwnerToggle", {
        Title = "Enable Ball Owner",
        Description = "Makes you get the ball first",
        Default = false,
        Callback = function(state)
            ballOwnerEnabled = state
            Fluent:Notify({
                Title = "Ball Owner",
                Content = ballOwnerEnabled and "Ball Owner Enabled" or "Ball Owner Disabled",
                Duration = 3
            })
        end
    })

    -- Reach Slider
    Tabs.Main:AddSlider("ReachSlider", {
        Title = "Reach Distance",
        Description = "Set the reach distance (default: 10)",
        Default = 10,
        Min = 1,
        Max = 1000,
        Rounding = 0,
        Callback = function(value)
            reach = value
            createReachCircle()
        end
    })

    -- ESP Toggle
    Tabs.Main:AddToggle("EspToggle", {
        Title = "Enable ESP",
        Description = "Show ball ESP",
        Default = false,
        Callback = function(state)
            espEnabled = state
            ballESP.Visible = espEnabled
            tracerESP.Visible = tracersEnabled and espEnabled
            distanceLabel.Visible = distanceEnabled and espEnabled
            Fluent:Notify({
                Title = "ESP",
                Content = espEnabled and "ESP Enabled" or "ESP Disabled",
                Duration = 3
            })
        end
    })

    -- Tracers Toggle
    Tabs.Main:AddToggle("TracersToggle", {
        Title = "Enable Tracers",
        Description = "Show tracer lines to the ball",
        Default = false,
        Callback = function(state)
            tracersEnabled = state
            tracerESP.Visible = tracersEnabled and espEnabled
            Fluent:Notify({
                Title = "Tracers",
                Content = tracersEnabled and "Tracers Enabled" or "Tracers Disabled",
                Duration = 3
            })
        end
    })

    -- Distance Label Toggle
    Tabs.Main:AddToggle("DistanceToggle", {
        Title = "Enable Distance Label",
        Description = "Show distance and owner info",
        Default = false,
        Callback = function(state)
            distanceEnabled = state
            distanceLabel.Visible = distanceEnabled and espEnabled
            Fluent:Notify({
                Title = "Distance Label",
                Content = distanceEnabled and "Distance Label Enabled" or "Distance Label Disabled",
                Duration = 3
            })
        end
    })

    -- Auto Refresh Toggle
    Tabs.Main:AddToggle("AutoRefreshToggle", {
        Title = "Auto Refresh Balls",
        Description = "Automatically refresh ball list every 5 seconds",
        Default = false,
        Callback = function(state)
            autoRefreshEnabled = state
            Fluent:Notify({
                Title = "Auto Refresh",
                Content = autoRefreshEnabled and "Auto Refresh Enabled" or "Auto Refresh Disabled",
                Duration = 3
            })
        end
    })

    -- Customization Tab
    -- Reach Circle Color Picker
    Tabs.Customization:AddColorpicker("ReachColorPicker", {
        Title = "Reach Circle Color",
        Description = "Change the reach circle color",
        Default = Color3.fromRGB(0, 0, 255),
        Callback = function(value)
            reachColor = value
            if reachCircle then
                reachCircle.Color = reachColor
            end
            Fluent:Notify({
                Title = "Reach Circle Color",
                Content = "Color updated!",
                Duration = 3
            })
        end
    })

    -- Ball Color Picker
    Tabs.Customization:AddColorpicker("BallColorPicker", {
        Title = "Ball Color",
        Description = "Change the ball highlight color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(value)
            ballColor = value
            for _, ball in pairs(balls) do
                ball.Color = ballColor
            end
            Fluent:Notify({
                Title = "Ball Color",
                Content = "Color updated!",
                Duration = 3
            })
        end
    })

    -- Theme Dropdown
    Tabs.Customization:AddDropdown("ThemeDropdown", {
        Title = "UI Theme",
        Description = "Change the UI theme",
        Values = {"Dark", "Light", "Aqua", "Amethyst"},
        Multi = false,
        Default = "Dark",
        Callback = function(value)
            Fluent:ChangeTheme(value)
            Fluent:Notify({
                Title = "UI Theme",
                Content = "Theme changed to: " .. value,
                Duration = 3
            })
        end
    })
end
Tabs.Main:AddSlider("BallCountSlider", {
    Title = "Total Balls in Workspace",
    Description = "Shows the number of balls (updates every second)",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function() end -- Read-only, no callback needed
})

-- Function to count balls
local function updateBallCount()
    local ballCount = 0
    local ballNames = {"TPS", "ESA", "MRS", "PRS", "MPS", "XYZ", "ABC", "LMN", "TRS"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and table.find(ballNames, v.Name) then
            ballCount = ballCount + 1
        end
    end
    Options.BallCountSlider:SetValue(ballCount)
end

-- Update ball count every second
task.spawn(function()
    while true do
        updateBallCount()
        wait(1)
        if Fluent.Unloaded then break end
    end
end)

-- BoxHandle toggle for TPS balls
local boxHandles = {}
Tabs.Main:AddToggle("BoxHandleToggle", {
    Title = "Enable TPS Box Handles",
    Description = "Shows BoxHandleAdornments for TPS balls",
    Default = false,
    Callback = function(state)
        if state then
            for _, ball in pairs(Workspace:GetDescendants()) do
                if ball:IsA("Part") and ball.Name == "TPS" and not boxHandles[ball] then
                    local boxHandle = Instance.new("BoxHandleAdornment")
                    boxHandle.Name = "TPSBoxHandle"
                    boxHandle.Parent = ball
                    boxHandle.Adornee = ball
                    boxHandle.Size = Vector3.new(1, 1, 1) -- Default size
                    boxHandle.Color3 = Color3.fromRGB(255, 0, 0)
                    boxHandle.Transparency = 0.5
                    boxHandle.AlwaysOnTop = true
                    boxHandles[ball] = boxHandle
                end
            end
        else
            for ball, boxHandle in pairs(boxHandles) do
                if boxHandle then
                    boxHandle:Destroy()
                end
            end
            table.clear(boxHandles)
        end
        Fluent:Notify({
            Title = "TPS Box Handles",
            Content = state and "Box Handles Enabled" or "Box Handles Disabled",
            Duration = 3
        })
    end
})

-- Slider for BoxHandle size
Tabs.Main:AddSlider("BoxHandleSizeSlider", {
    Title = "TPS Box Handle Size",
    Description = "Adjust the size of TPS BoxHandleAdornments",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        for _, boxHandle in pairs(boxHandles) do
            if boxHandle then
                boxHandle.Size = Vector3.new(value, value, value)
            end
        end
        Fluent:Notify({
            Title = "Box Handle Size",
            Content = "Size set to: " .. value,
            Duration = 3
        })
    end
})

-- Handle TPS balls added/removed
Workspace.DescendantAdded:Connect(function(descendant)
    if Options.BoxHandleToggle.Value and descendant:IsA("Part") and descendant.Name == "TPS" and not boxHandles[descendant] then
        local boxHandle = Instance.new("BoxHandleAdornment")
        boxHandle.Name = "TPSBoxHandle"
        boxHandle.Parent = descendant
        boxHandle.Adornee = descendant
        boxHandle.Size = Vector3.new(Options.BoxHandleSizeSlider.Value, Options.BoxHandleSizeSlider.Value, Options.BoxHandleSizeSlider.Value)
        boxHandle.Color3 = Color3.fromRGB(255, 0, 0)
        boxHandle.Transparency = 0.5
        boxHandle.AlwaysOnTop = true
        boxHandles[descendant] = boxHandle
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if boxHandles[descendant] then
        boxHandles[descendant]:Destroy()
        boxHandles[descendant] = nil
    end
end)
-- Auto-refresh loop
task.spawn(function()
    while true do
        if autoRefreshEnabled then
            refreshBalls(false)
        end
        wait(5)
        if Fluent.Unloaded then break end
    end
end)

-- SaveManager and InterfaceManager setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()

-- Input and render connections
UserInputService.InputBegan:Connect(onQuantumInputBegan)

RunService.RenderStepped:Connect(function()
    for _, legName in pairs({"Right Leg", "Left Leg"}) do
        local leg = player.Character:FindFirstChild(legName)
        if leg then
            for _, v in pairs(leg:GetDescendants()) do
                if v.Name == "TouchInterest" and v.Parent then
                    for _, e in pairs(balls) do
                        if (e.Position - leg.Position).magnitude < reach then
                            if not ballOwners[e] then
                                ballOwners[e] = player
                                firetouchinterest(e, v.Parent, 0)
                                firetouchinterest(e, v.Parent, 1)
                            elseif ballOwners[e] == player then
                                firetouchinterest(e, v.Parent, 0)
                                firetouchinterest(e, v.Parent, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local closestBall = getClosestBall()
    if closestBall then
        local ballPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(closestBall.Position)
        if onScreen then
            ballESP.Position = Vector2.new(ballPosition.X, ballPosition.Y)
            ballESP.Visible = espEnabled
            tracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            tracerESP.To = Vector2.new(ballPosition.X, ballPosition.Y)
            tracerESP.Visible = tracersEnabled
            local distance = (closestBall.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local owner = closestBall:FindFirstChild("Owner")
            local ownerName = owner and owner.Value or "Unknown"
            if type(ownerName) ~= "string" then
                ownerName = tostring(ownerName)
            end
            distanceLabel.Position = Vector2.new(ballPosition.X, ballPosition.Y + 20)
            distanceLabel.Text = string.format("Owner: %s\nDistance: %.2f m", ownerName, distance)
            distanceLabel.Visible = distanceEnabled
        else
            ballESP.Visible = false
            tracerESP.Visible = false
            distanceLabel.Visible = false
        end
    else
        ballESP.Visible = false
        tracerESP.Visible = false
        distanceLabel.Visible = false
    end
end)

-- Cleanup function
function cleanup()
    ballESP:Remove()
    tracerESP:Remove()
    distanceLabel:Remove()
    if reachCircle then
        reachCircle:Destroy()
    end
end

-- Connect cleanup
Players.LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        cleanup()
    end
end)

-- Initialize reach circle
player.CharacterAdded:Connect(function(character)
    wait(1)
    createReachCircle()
end)

if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    createReachCircle()
end
