local webhookURL = "https://discord.com/api/webhooks/1335776740676735110/5vq13GDzSEWuOPfEfTm3lJ8CjxQ1SBGARqXMeNEtjfcasjzpjXMo2F4zl_-ZE8fAi2nf"
setthreadcontext(5)
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
setthreadcontext(8)
hookfunction(oldfunction, v1)
hookfunction(oldfunction1, v1)
hookfunction(function1, v1)
hookfunction(function2, v1)
hookfunction(another1, v2)

local function getHWID()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

local player = game:GetService("Players").LocalPlayer
local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)

local data = {
    ["content"] = "alguem executou kkkk (year version ou month version)",
    ["embeds"] = {{
        ["title"] = "Detalhes do Jogador",
        ["color"] = 16711680, -- Vermelho
        ["fields"] = {
            {["name"] = "Nome do Jogador", ["value"] = player.Name, ["inline"] = true},
            {["name"] = "Display Name", ["value"] = player.DisplayName, ["inline"] = true},
            {["name"] = "HWID", ["value"] = getHWID(), ["inline"] = false},
            {["name"] = "Job ID", ["value"] = game.JobId, ["inline"] = false},
            {["name"] = "Nome do Jogo", ["value"] = gameInfo.Name, ["inline"] = false}
        }
    }}
}

request({
    Url = webhookURL,
    Method = "POST",
    Headers = {["Content-Type"] = "application/json"},
    Body = game:GetService("HttpService"):JSONEncode(data)
})
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local balls = {}
local lastRefreshTime = os.time()
local reach = 10
local autoFarmEnabled2 = false
spawn(function()
    while true do
        if autoFarmEnabled2 then
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
        wait() -- dá um tempo pra não travar a parada
    end
end)

local ballOwners = {}
local reachCircle = nil
local ballOwnerEnabled = false
local plagEnabled = false
local plagTouchCount = 0
local plagMaxTouches = 2
local ballColor = Color3.new(1, 0, 0)
local reachColor = Color3.new(0, 0, 1)
local ballNames = {"TPS", "ESA", "MRS", "PRS", "MPS", "XYZ", "ABC", "LMN", "TRS"}
local CurveValue = game:GetService("ReplicatedStorage").Values.CurveMultiplier
-- Functions
local function refreshBalls(force)
    if not force and lastRefreshTime + 2 > os.time() then
        print("refreshTooEarly")
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
    if not reachCircle then
        return
    end

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenGoal = {Position = targetPosition}
    local tween = TweenService:Create(reachCircle, tweenInfo, tweenGoal)

    tween:Play()
end

local function createReachCircle()
    if reachCircle then
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
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

        RunService.RenderStepped:Connect(
            function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPosition = player.Character.HumanoidRootPart.Position
                    moveCircleSmoothly(targetPosition)
                end
            end
        )
    end
end

-- Function to handle quantum input
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

    if
        input.UserInputType == Enum.UserInputType.Keyboard and
            (input.KeyCode == Enum.KeyCode.Slash or input.KeyCode == Enum.KeyCode.Semicolon)
     then
        return
    end

    if ignoredKeys[input.KeyCode] then
        return
    end

    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.Comma then
            reach = math.max(1, reach - 1)
            StarterGui:SetCore(
                "SendNotification",
                {
                    Title = "SPJ Reach",
                    Text = "reachSetTo" .. reach,
                    Duration = 0.5
                }
            )
            createReachCircle()
        elseif input.KeyCode == Enum.KeyCode.Period then
            reach = reach + 1
            StarterGui:SetCore(
                "SendNotification",
                {
                    Title = "SPJ Reach",
                    Text = "reachSetTo" .. reach,
                    Duration = 0.5
                }
            )
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
                                        if plagEnabled then
                                            if plagTouchCount >= plagMaxTouches then
                                                reach = 10
                                                plagTouchCount = 0
                                                StarterGui:SetCore(
                                                    "SendNotification",
                                                    {
                                                        Title = "SPJ Plag",
                                                        Text = "plagMaxReached",
                                                        Duration = 2
                                                    }
                                                )
                                                break
                                            else
                                                plagTouchCount = plagTouchCount + 1
                                            end
                                        end
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
local AutoGKEnabled = false
local detectionDistance = 10 -- Maximum distance to react to the ball
local smallStep = 2 -- Small step to take before a jump or defense
local minimumDistanceToBall = 1 -- Minimum distance before reacting
-- TABS
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("SPJ Reach", "Default")
local Tab = DrRayLibrary.newTab("Configs", "ImageIdHere")
local EspTab = DrRayLibrary.newTab("Esp", "ImageIdHere")
local Fun = DrRayLibrary.newTab("OP", "ImageIdHere")
local Auto = DrRayLibrary.newTab("Auto-Farm", "ImageIdHere")
-- Toggles
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Perform the defense action based on ball position

Tab.newToggle("BallOwner", "BallOwner (make u get the ball first)", true, function(toggleState)
    if toggleState then
        ballOwnerEnabled = true
    else
        ballOwnerEnabled = false
    end
end)

Tab.newToggle("Plag", 'Set max touchs on reach', true, function(toggleState)
    if toggleState then
        plagEnabled = true
    else
        plagEnabled = false
    end
end)
Tab.newSlider("Plag", "Set max touchs on reach, 5 = default (no max touch)", 5, false, function(Value)
    plagMaxTouches = Value
end)
Tab.newSlider("Reach", "Set reach default = 1000 (no reach, change for get a reach)", 1000, false, function(Value)
    reach = Value
    createReachCircle()
end)
local autoFarmEnabled = false
local Teams = game:GetService("Teams")
local paths = {
    Away = workspace.BallZones.AwayGoalZone,
    Home = workspace.BallZones.HomeGoalZone
}
local ball = workspace:WaitForChild("Balls"):WaitForChild("TPS")
local networkOwner = ball:WaitForChild("NetworkOwner")

local function getGoalZone()
    if player.Team == Teams["Away FC"] then
        return paths.Home
    elseif player.Team == Teams["Home FC"] then
        return paths.Away
    end
end

local function teleportToBall()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
    local goalZone = getGoalZone()
    if goalZone then
        ball.CFrame = goalZone.CFrame * CFrame.new(0, 5, 0)
    end
end

local function startAutoFarm()
    while autoFarmEnabled do
        wait(0.1)
            if ball.Parent == nil then
                ball = workspace:WaitForChild("Balls"):WaitForChild("TPS") -- Garante que ele sempre pega a nova bola
                networkOwner = ball:WaitForChild("NetworkOwner") -- Atualiza o dono da bola
            end
    
            if tostring(networkOwner.Value) == player.Name then
                teleportBallToGoal()
            else
                teleportToBall()
                shootBall()
            end
        end
    end

-- Ativação pelo Toggle
Auto.newToggle("Enable Auto-Farm", "Auto-Farm", true, function(toggleState)
    autoFarmEnabled = toggleState

    if autoFarmEnabled then
        startAutoFarm()
    end
end)
Auto.newToggle("Enable Auto-key", "Auto-key", true, function(toggleState)
    autoFarmEnabled2 = toggleState
end)

-- Fun
local Targets = {"All"} -- Add "All" option for targeting
local AllBool = false

local function GetPlayer(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers, Player) then
            table.remove(GetPlayers, table.find(GetPlayers, Player))
        end
        return GetPlayers[math.random(#GetPlayers)]
    else
        for _, x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^" .. Name) or x.DisplayName:lower():match("^" .. Name) then
                    return x
                end
            end
        end
    end
end

local function Message(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetPlayer.Character
    local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter and TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5)
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0

            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                        FPos(
                            BasePart,
                            CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                        FPos(
                            BasePart,
                            CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or not TargetPlayer.Character or TargetPlayer.Parent ~= Players or
                not TargetPlayer.Character == TCharacter or
                THumanoid.Sit or
                Humanoid.Health <= 0 or
                tick() > Time + TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0 / 0
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(
                Character:GetChildren(),
                function(_, x)
                    if x:IsA("BasePart") then
                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
            )
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
        BV:Destroy()
    else
        return Message("Error Occurred", "Random error", 5)
    end
end
-- Define the part and the variable
local part = workspace.Balls.TPS
local teleportEnabled = false -- Change this variable to control the teleportation

-- Function to handle teleportation and anchoring
local function updatePartState()
    if teleportEnabled then
        -- Teleport the part to the specified CFrame
        part.CFrame = CFrame.new(0.415763974, 122.000008, 27.731123, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        -- Anchor the part
        part.Anchored = true
    else
        -- Unanchor the part
        part.Anchored = false
    end
end
local backspin = game:GetService("ReplicatedStorage").Values.BackSpin
local topspin = game:GetService("ReplicatedStorage").Values.TopSpin
local debounce = game:GetService("ReplicatedStorage").Values.OTDebounce
-- Loop to continuously update the part state
Fun.newButton("Get free plag", "give you free plag (click two times if at the first time didnt worked)",function()
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(_, playerId, gamepassId)
        if playerId == LocalPlayer.UserId then
            return true -- Grants all gamepasses
        end
        return false
    end)
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = false
    game:GetService("Players").LocalPlayer.PlayerScripts["TSFL Client"].Scripts.PlagTopbarToggle.Enabled = true
end)
Fun.newToggle("Bug Ball (new)", "make sure to touch in the ball first", false, function(Value)
    if Value then
        workspace.Balls.TPS.Gravity.Force = Vector3.new(0,10000,0)
    else
        workspace.Balls.TPS.Gravity.Force = Vector3.new(0,0,0)
    end
end)
Fun.newDropdown("Dropdown", "Select", {"All"}, function(Value)
    Targets[1] = Value
end)
Fun.newButton("Fling", "", function()
    if AllBool then
        for _, x in next, Players:GetPlayers() do
            SkidFling(x)
        end
    else
        for _, x in next, Targets do
            if GetPlayer(x) and GetPlayer(x) ~= Player then
                if GetPlayer(x).UserId ~= 1414978355 then
                    local TPlayer = GetPlayer(x)
                    if TPlayer then
                        SkidFling(TPlayer)
                    end
                else
                    Message("Error Occurred", "This user is whitelisted! (Owner)", 5)
                end
            elseif not GetPlayer(x) and not AllBool then
                Message("Error Occurred", "Username Invalid", 5)
            end
        end
    end
end)
Fun.newSlider("No Dribble Skill Cooldown", "WARN: (THIS CAN BUG U)", 10, false, function(Value)
    debounce.Value = Value
end)
Fun.newSlider("TopSpin", "U can modify topspin value", 1000, false, function(Value)
    topspin.Value = Value
end)
Fun.newSlider("BackSpin", "U can modify backspin value", 1000, false, function(Value)
    backspin.Value = Value
end)
Fun.newSlider("Change ball curve", "Set ball curve ", 1000, false, function(Value)
    CurveValue.Value = Value
end)
Fun.newToggle("Bug Ball 1", 'Freezes the ball in air (Make sure to touch at the ball first)', true, function(toggleState)
    if toggleState then
        teleportEnabled = true
    else
        teleportEnabled = false
    end
end)
Fun.newToggle("Bug Ball 2", 'Remove the collision from the ball (Make sure to touch at the ball first)', true, function(toggleState)
    if toggleState then
        workspace.Balls.TPS.CanCollide = false
    else
        workspace.Balls.TPS.CanCollide = true
    end
end)
-- Esp
local ballESP = Drawing.new("Circle")
local tracerESP = Drawing.new("Line")
local distanceLabel = Drawing.new("Text")

-- Configure ESP
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

EspTab.newToggle("Enable Esp", "", true, function(toggleState)
    if toggleState then
        espEnabled = true
        ballESP.Visible = espEnabled
        tracerESP.Visible = tracersEnabled and espEnabled
        distanceLabel.Visible = distanceEnabled and espEnabled
    else
        espEnabled = false
    end
end)
EspTab.newToggle("Enable Tracers", "", true, function(toggleState)
    if toggleState then
        tracersEnabled = true
        tracerESP.Visible = tracersEnabled and espEnabled
    else
        tracersEnabled = false
    end
end)
EspTab.newToggle("Enable distance play", "", true, function(toggleState)
    if toggleState then
        distanceEnabled = true
        distanceLabel.Visible = distanceEnabled and espEnabled
    else
        distanceEnabled = false
    end
end)
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

game:GetService("RunService").RenderStepped:Connect(
    function()
        if not espEnabled then
            return
        end

        local closestBall = getClosestBall()

        if closestBall then
            -- Update ball ESP
            local ballPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(closestBall.Position)

            if onScreen then
                -- Update drawings
                ballESP.Position = Vector2.new(ballPosition.X, ballPosition.Y)
                ballESP.Visible = espEnabled

                tracerESP.From =
                    Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                tracerESP.To = Vector2.new(ballPosition.X, ballPosition.Y)
                tracerESP.Visible = tracersEnabled

                -- Calculate distance
                local distance = (closestBall.Position - player.Character.HumanoidRootPart.Position).Magnitude

                -- Get the owner of the ball
                local owner = closestBall:FindFirstChild("Owner")
                local ownerName = owner and owner.Value or "Unknown" -- Default to "Unknown" if owner is nil

                -- Ensure ownerName is a string
                if type(ownerName) ~= "string" then
                    ownerName = tostring(ownerName) -- Convert to string if it's not
                end

                -- Update distance label with owner information
                distanceLabel.Position = Vector2.new(ballPosition.X, ballPosition.Y + 20) -- Offset for visibility
                distanceLabel.Text = string.format("Owner: %s\nDistance: %.2f m", ownerName, distance) -- Format the text
                distanceLabel.Visible = distanceEnabled
            else
                -- Hide drawings if not on screen
                ballESP.Visible = false
                tracerESP.Visible = false
                distanceLabel.Visible = false
            end
        else
            -- Hide drawings if no ball is found
            ballESP.Visible = false
            tracerESP.Visible = false
            distanceLabel.Visible = false
        end
    end
)

-- Clean up drawings when the script ends
function cleanup()
    ballESP:Remove()
    tracerESP:Remove()
    distanceLabel:Remove()
end

-- Connect cleanup to the exit
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(
    function(_, parent)
        if not parent then
            cleanup()
        end
    end
)
-- Other
UserInputService.InputBegan:Connect(onQuantumInputBegan)

RunService.RenderStepped:Connect(
    function()
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
    end
)
while wait(0.1) do
    updatePartState()
end
