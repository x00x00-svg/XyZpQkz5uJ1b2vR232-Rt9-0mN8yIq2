local success = pcall(function()
    local testFunc = function() return "original" end
    local hooked = hookfunction(testFunc, function() return "hooked" end)
    assert(testFunc() == "hooked")
end)

if not success then 
return error('hookfunction is not supported.') 
end

setthreadcontext(5)
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
setthreadcontext(8)

loadstring(game:HttpGet('https://raw.githubusercontent.com/x00x00-svg/XyZpQkz5uJ1b2vR232-Rt9-0mN8yIq2/refs/heads/main/maybe.luau'))()
local function getexecutor()
    local exec = identifyexecutor()
    return tostring(exec)
end
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
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Customization = Window:AddTab({ Title = "Customization", Icon = "palette" }),
    fun = Window:AddTab({ Title = "Fun", Icon = "star" }),
    esp = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    AutoFarm = Window:AddTab({ Title = "AutoFarm", Icon = "dollar-sign" }),
    Status = Window:AddTab({ Title = "Status", Icon = "signal" })
}

local Options = Fluent.Options
Tabs.Status:AddParagraph({
    Title = "Script Status",
    Content = "Alive: 🟢"
})
Tabs.Status:AddParagraph({
    Title = "Executor",
    Content = getexecutor()
})
Tabs.Status:AddParagraph({
    Title = "Script Version",
    Content = "0.2.3"
})
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


do
    Fluent:Notify({
        Title = "SPJ Reach (Mps Futsal)",
        Content = "The script has been loaded.",
        Duration = 8
    })


    Tabs.fun:AddButton({
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


    Tabs.esp:AddToggle("EspToggle", {
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


    Tabs.esp:AddToggle("TracersToggle", {
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


    Tabs.esp:AddToggle("DistanceToggle", {
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


end
Tabs.Main:AddSlider("BallCountSlider", {
    Title = "Total Balls in Workspace",
    Description = "Shows the number of balls (updates every second)",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function() end 
})


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


task.spawn(function()
    while true do
        updateBallCount()
        wait(1)
        if Fluent.Unloaded then break end
    end
end)

Tabs.fun:AddSlider("BoxHandleSizeSlider", {
    Title = "Changed cooldown of dribble",
    Description = "Adjust cooldown of dribble",
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.OTDebounce.Value = value
    end
})
Tabs.fun:AddSlider('ModifyCurve', {
    Title = 'Modify Curve',
    Description = 'Change the curve of the ball',
    Default = 1,
    Min = 0.5,
    Max = 10,
    Rounding = 2,
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.CurveMultiplier.Value = value
    end
})
Tabs.fun:AddSlider('ModifyBackSpin', {
    Title = 'Modify Back Spin',
    Description = 'Change the back spin of the ball',
    Default = 0,
    Min = 0.5,
    Max = 10,
    Rounding = 2,
    Callback = function(value)
        game:GetService("ReplicatedStorage").Values.BackSpin.Value = value
    end
})
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

Tabs.AutoFarm:AddToggle("AutoFarmToggle", {
    Title = "Enable AutoFarm",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
    end
})

Tabs.AutoFarm:AddToggle("AutoKeyToggle", {
    Title = "Enable AutoKey",
    Default = false,
    Callback = function(Value)
        autoKeyEnabled = Value
    end
})


local camera = workspace.CurrentCamera

_G.TPSBallSpeed = 200

local BALL_FOLDER = workspace:WaitForChild("Balls")
local BALL_NAME_PREFIX = "TPS"

local ContextActionService = game:GetService("ContextActionService")

local camera = workspace.CurrentCamera

local controlling = false
local currentBall = nil
local moveInput = {
	forward = false,
	left = false,
	right = false,
	up = false,
	down = false
}

local function getTPSBall()
	for _, obj in ipairs(BALL_FOLDER:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name:sub(1, #BALL_NAME_PREFIX) == BALL_NAME_PREFIX then
			return obj
		end
	end
	return nil
end

local function onMoveAction(actionName, inputState, input)
	if not controlling then return Enum.ContextActionResult.Pass end

	local isPressed = inputState == Enum.UserInputState.Begin
	local key = input.KeyCode

	if key == Enum.KeyCode.W then moveInput.forward = isPressed end
	if key == Enum.KeyCode.A then moveInput.left = isPressed end
	if key == Enum.KeyCode.S then moveInput.backward = isPressed end
	if key == Enum.KeyCode.D then moveInput.right = isPressed end
	if key == Enum.KeyCode.Space then moveInput.up = isPressed end
	if key == Enum.KeyCode.LeftShift then moveInput.down = isPressed end

	return Enum.ContextActionResult.Sink
end

local function bindBallControls()
	ContextActionService:BindAction("TPSBallMovement", onMoveAction, false,
		Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
		Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
end

local function unbindBallControls()
	ContextActionService:UnbindAction("TPSBallMovement")
end

local function startControlling(ball)
	currentBall = ball
	camera.CameraSubject = ball
	camera.CameraType = Enum.CameraType.Custom
	controlling = true
	bindBallControls()
end

local function stopControlling()
	camera.CameraSubject = player.Character:FindFirstChild("Humanoid") or player.Character:FindFirstChildWhichIsA("BasePart")
	camera.CameraType = Enum.CameraType.Custom
	currentBall = nil
	controlling = false
	unbindBallControls()
end

RunService.RenderStepped:Connect(function()
	if not controlling or not currentBall then return end

	local camCF = camera.CFrame
	local moveDir = Vector3.zero

	if moveInput.forward then moveDir += camCF.LookVector end
	if moveInput.backward then moveDir -= camCF.LookVector end
	if moveInput.left then moveDir -= camCF.RightVector end
	if moveInput.right then moveDir += camCF.RightVector end
	if moveInput.up then moveDir += Vector3.new(0, 1, 0) end
	if moveInput.down then moveDir -= Vector3.new(0, 1, 0) end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit * math.clamp(_G.TPSBallSpeed or 0, 0, 300)
		currentBall.Velocity = moveDir
	else
		currentBall.Velocity *= 0.9
	end
end)

-- === UI Integration ===
Tabs.fun:AddToggle("ControlBallToggle", {
	Title = "Enable Ball Control",
	Description = "Toggle free-fly control of the TPS ball",
	Default = false,
	Callback = function(state)
		if state then
			local ball = getTPSBall()
			if ball then
				startControlling(ball)
			else
				warn("No TPS ball found!")
			end
		else
			stopControlling()
		end
	end
})

Tabs.fun:AddSlider("BallSpeedSlider", {
	Title = "Control Speed",
	Description = "Set your ball fly speed (0–300)",
	Default = _G.TPSBallSpeed,
	Min = 0,
	Max = 300,
	Rounding = 0,
	Callback = function(value)
		_G.TPSBallSpeed = value
	end
})

local Keybind = Tabs.fun:AddKeybind("BallControlKeybind", {
    Title = "Toggle Ball Control (Keybind)",
    Mode = "Toggle", 
    Default = "U",

    Callback = function(state)

        if state then
            local ball = getTPSBall()
            if ball then
                startControlling(ball)
            else
                warn("No TPS ball found!")
            end
        else
            stopControlling()
        end

        Options.ControlBallToggle:SetValue(state)
    end,

    ChangedCallback = function(newKey)
        
    end
})


task.spawn(function()
    while true do
        if autoRefreshEnabled then
            refreshBalls(false)
        end
        wait(5)
        if Fluent.Unloaded then break end
    end
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("spjreach")
SaveManager:SetFolder("spjreach/mpsfutsal")
InterfaceManager:BuildInterfaceSection(Tabs.Customization)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()


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


function cleanup()

    ballESP:Remove()
    tracerESP:Remove()
    distanceLabel:Remove()
    Fluent:Notify({
        Title = "Error",
        Content = "The script was closed, please report this error to the developer. Code error: 161218 (PLAYER UNLOADED)",
        Duration = 5
    })
    if reachCircle then
        reachCircle:Destroy()
    end
end


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
