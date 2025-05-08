-- Checking for hookfunction support
local success = pcall(function()
    local testFunc = function() return "original" end
    local hooked = hookfunction(testFunc, function() return "hooked" end)
    assert(testFunc() == "hooked")
end)

if not success then 
    return error('hookfunction is not supported.') 
end
setthreadcontext(5)
local v = require(game:GetService("StarterPlayer").StarterPlayerScripts["TSFL Client"].Modules.BallNetworking)
local x = require(game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Modules.BallNetworking)
-- Loading Rayfield UI Library
setthreadcontext(8)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Hooking functions
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

-- Executor identification
local function getexecutor()
    local exec = identifyexecutor()
    return tostring(exec)
end

-- Creating Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "SPJ Reach (Futsal)",
    LoadingTitle = "SPJ Reach",
    LoadingSubtitle = "by alr_dev",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "spjreach/mpsfutsal",
        FileName = "config"
    },
    KeySystem = false
})

-- Creating Tabs
local Tabs = {
    Main = Window:CreateTab("Main", "box"),
    Customization = Window:CreateTab("Customization", "palette"),
    Fun = Window:CreateTab("Fun", "star"),
    ESP = Window:CreateTab("ESP", "eye"),
    Settings = Window:CreateTab("Settings", "settings"),
    AutoFarm = Window:CreateTab("AutoFarm", "dollar-sign"),
    Status = Window:CreateTab("Status", "signal")
}

-- Status Tab Content
Tabs.Status:CreateLabel("Script Status: 🟢 Alive")
Tabs.Status:CreateLabel("Script Version: 0.2.2")
Tabs.Status:CreateLabel("Executor: " .. getexecutor())

-- Services
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

-- Variables
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
local tpsBoxHandleEnabled = false
local ballHitboxSize = 1

-- ESP Setup
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

-- Free Plag Function
local function activateFreePlag()
    hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(_, playerId, gamepassId)
        if playerId == LocalPlayer.UserId then
            return true
        end
        return false
    end)
    
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = false
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = true
    
    Rayfield:Notify({
        Title = "Free Plag",
        Content = "Plag functionality activated!",
        Duration = 5,
        Image = "bell"
    })
end

-- Ball Refresh Function
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

-- Smooth Circle Movement
local function moveCircleSmoothly(targetPosition)
    if not reachCircle then return end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenGoal = {Position = targetPosition}
    local tween = TweenService:Create(reachCircle, tweenInfo, tweenGoal)
    tween:Play()
end

-- Reach Circle Creation
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

-- Input Handling
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

-- Get Closest Ball
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
    Rayfield:Notify({
        Title = "SPJ Reach (Mps Futsal)",
        Content = "The script has been loaded.",
        Duration = 8,
        Image = "bell"
    })

    Tabs.Fun:CreateButton({
        Name = "Get Free Plag",
        Description = "Activates free plag functionality",
        Callback = function()
            Rayfield:Prompt({
                Title = "Confirm Free Plag",
                Content = "Are you sure you want to activate free plag?",
                Actions = {
                    {
                        Name = "Confirm",
                        Callback = function()
                            activateFreePlag()
                            print("Free Plag activated")
                        end
                    },
                    {
                        Name = "Cancel",
                        Callback = function()
                            print("Free Plag activation cancelled")
                        end
                    }
                }
            })
        end
    })

    Tabs.Main:CreateToggle({
        Name = "Enable Ball Owner",
        CurrentValue = false,
        Description = "Makes you get the ball first",
        Callback = function(state)
            ballOwnerEnabled = state
            Rayfield:Notify({
                Title = "Ball Owner",
                Content = ballOwnerEnabled and "Ball Owner Enabled" or "Ball Owner Disabled",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.Main:CreateSlider({
        Name = "Reach Distance",
        Range = {1, 1000},
        Increment = 1,
        CurrentValue = 10,
        Description = "Set the reach distance",
        Callback = function(value)
            reach = value
            createReachCircle()
        end
    })

    Tabs.ESP:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Description = "Show ball ESP",
        Callback = function(state)
            espEnabled = state
            ballESP.Visible = espEnabled
            tracerESP.Visible = tracersEnabled and espEnabled
            distanceLabel.Visible = distanceEnabled and espEnabled
            Rayfield:Notify({
                Title = "ESP",
                Content = espEnabled and "ESP Enabled" or "ESP Disabled",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.ESP:CreateToggle({
        Name = "Enable Tracers",
        CurrentValue = false,
        Description = "Show tracer lines to the ball",
        Callback = function(state)
            tracersEnabled = state
            tracerESP.Visible = tracersEnabled and espEnabled
            Rayfield:Notify({
                Title = "Tracers",
                Content = tracersEnabled and "Tracers Enabled" or "Tracers Disabled",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.ESP:CreateToggle({
        Name = "Enable Distance Label",
        CurrentValue = false,
        Description = "Show distance and owner info",
        Callback = function(state)
            distanceEnabled = state
            distanceLabel.Visible = distanceEnabled and espEnabled
            Rayfield:Notify({
                Title = "Distance Label",
                Content = distanceEnabled and "Distance Label Enabled" or "Distance Label Disabled",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.Main:CreateToggle({
        Name = "Auto Refresh Balls",
        CurrentValue = false,
        Description = "Automatically refresh ball list every 5 seconds",
        Callback = function(state)
            autoRefreshEnabled = state
            Rayfield:Notify({
                Title = "Auto Refresh",
                Content = autoRefreshEnabled and "Auto Refresh Enabled" or "Auto Refresh Disabled",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.Customization:CreateColorPicker({
        Name = "Reach Circle Color",
        Color = Color3.fromRGB(0, 0, 255),
        Description = "Change the reach circle color",
        Callback = function(value)
            reachColor = value
            if reachCircle then
                reachCircle.Color = reachColor
            end
            Rayfield:Notify({
                Title = "Reach Circle Color",
                Content = "Color updated!",
                Duration = 3,
                Image = "bell"
            })
        end
    })

    Tabs.Customization:CreateColorPicker({
        Name = "Ball Color",
        Color = Color3.fromRGB(255, 0, 0),
        Description = "Change the ball highlight color",
        Callback = function(value)
            ballColor = value
            for _, ball in pairs(balls) do
                ball.Color = ballColor
            end
            Rayfield:Notify({
                Title = "Ball Color",
                Content = "Color updated!",
                Duration = 3,
                Image = "bell"
            })
        end
    })
end

-- Ball Count Slider
local ballCountSlider = Tabs.Main:CreateSlider({
    Name = "Total Balls in Workspace",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Description = "Shows the number of balls (updates every second)",
    Callback = function() end
})

-- Update Ball Count
local function updateBallCount()
    local ballCount = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and table.find(ballNames, v.Name) then
            ballCount = ballCount + 1
        end
    end
    ballCountSlider:Set(ballCount)
end

task.spawn(function()
    while true do
        updateBallCount()
        wait(1)
    end
end)


-- Update Box Handle Size
local function updateBoxHandleSize(value)
    ballHitboxSize = value
    for _, ball in pairs(Workspace:GetDescendants()) do
        if ball:IsA("Part") and ball.Name == "TPS" then
            ball.Size = Vector3.new(value, value, value)
            local boxHandle = ball:FindFirstChild("TPSBoxHandle")
            if boxHandle and boxHandle:IsA("BoxHandleAdornment") then
                boxHandle.Size = ball.Size
            end
        end
    end
end

Tabs.Main:CreateSlider({
    Name = "Ball Hitbox",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Description = "Resize the ball hitbox",
    Callback = function(value)
        updateBoxHandleSize(value)
        Rayfield:Notify({
            Title = "Size Updated",
            Content = "Ball and BoxHandle size: " .. value,
            Duration = 3
        })
    end
})

Tabs.Fun:CreateSlider({
    Name = "Dribble Cooldown",
    Range = {0, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Description = "Adjust cooldown of dribble",
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.OTDebounce.Value = value
    end
})

Tabs.Fun:CreateSlider({
    Name = "Modify Curve",
    Range = {0.5, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Description = "Change the curve of the ball",
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.CurveMultiplier.Value = value
    end
})

Tabs.Fun:CreateSlider({
    Name = "Modify Back Spin",
    Range = {0.5, 10},
    Increment = 0.1,
    CurrentValue = 0,
    Description = "Change the back spin of the ball",
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.BackSpin.Value = value
    end
})

-- AutoFarm
local autoFarmEnabled = false
local autoKeyEnabled = false

local function getGoalZone()
    local Teams = game:GetService("Teams")
    local paths = {
        Away = workspace.BallZones.AwayGoalZone,
        Home = workspace.BallZones.HomeGoalZone
    }
    if player.Team == Teams["Away FC"] then
        return paths.Home
    elseif player.Team == Teams["Home FC"] then
        return paths.Away
    end
end

local function teleportToBall()
    local ball = workspace:WaitForChild("Balls"):WaitForChild("TPS")
    if ball and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
    end
end

local function shootBall()
    local shootTool = player.Backpack:FindFirstChild("Dribble")
    if shootTool then
        player.Character.Humanoid:EquipTool(shootTool)
    end
end

local function teleportBallToGoal()
    local ball = workspace:WaitForChild("Balls"):WaitForChild("TPS")
    local goalZone = getGoalZone()
    if ball and goalZone then
        ball.CFrame = goalZone.CFrame * CFrame.new(0, 5, 0)
    end
end

task.spawn(function()
    while true do
        if autoFarmEnabled then
            local ball = workspace:WaitForChild("Balls"):WaitForChild("TPS")
            local networkOwner = ball:WaitForChild("NetworkOwner")
            if tostring(networkOwner.Value) == player.Name then
                teleportBallToGoal()
            else
                teleportToBall()
                shootBall()
            end
        end
        wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if autoKeyEnabled then
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
        wait()
    end
end)

Tabs.AutoFarm:CreateToggle({
    Name = "Enable AutoFarm",
    CurrentValue = false,
    Callback = function(Value)
        autoFarmEnabled = Value
    end
})

Tabs.AutoFarm:CreateToggle({
    Name = "Enable AutoKey",
    CurrentValue = false,
    Callback = function(Value)
        autoKeyEnabled = Value
    end
})



task.spawn(function()
    while true do
        if autoRefreshEnabled then
            refreshBalls(false)
        end
        wait(5)
    end
end)

-- Input and Render Connections
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

-- Cleanup Function
function cleanup()
    ballESP:Remove()
    tracerESP:Remove()
    distanceLabel:Remove()
    Rayfield:Notify({
        Title = "Error",
        Content = "The script was closed, please report this error to the developer. Code error: 161218 (PLAYER UNLOADED)",
        Duration = 5,
        Image = "bell"
    })
    if reachCircle then
        reachCircle:Destroy()
    end
end

-- Player Events
Players.LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        cleanup()
    end
end)

player.CharacterAdded:Connect(function(character)
    wait(1)
    createReachCircle()
end)

if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    createReachCircle()
end
