local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local task = task


speed = true
jump = true

local isUsingSetA = true


local Mode = "Red"

local Colors = {
    Red = {
    Main = Color3.fromRGB(255, 64, 64),
    Title = Color3.fromRGB(200, 0, 0),
    Stroke = Color3.fromRGB(150, 0, 0),
    Text = Color3.fromRGB(255, 200, 200),
    Label = Color3.fromRGB(255, 180, 180)
    },
    Black = {
        Main = Color3.fromRGB(30,30,30),
        Title = Color3.fromRGB(50,50,50),
        Stroke = Color3.fromRGB(150,150,150),
        Text = Color3.fromRGB(200,200,200),
        Label = Color3.fromRGB(180,180,180)
    }
}

local currentColors = Colors[Mode]


local animSetA = {
    idle = "rbxassetid://0",
    walk = "rbxassetid://0",
    jump = "rbxassetid://0"
}

local animSetB = {
    idle = "rbxassetid://120873587634730",
    walk = "rbxassetid://107806791584829",
    jump = "rbxassetid://139390570947836"
}

local currentSet = animSetB
local walkTrack, idleTrack, jumpTrack
local runningConnection, jumpingConnection, landedConnection
local speedEnforcer, jumpEnforcer


local function playRetroTrack(track)
    if not track then return end
    if track.IsPlaying then track:Stop() end
    track:Play()

    track:AdjustSpeed(3)

    coroutine.wrap(function()
        while track.IsPlaying do
            task.wait(0.1 + math.random() * 0.1)
            if track.IsPlaying then
                track:AdjustSpeed(0)
                task.wait(0.15)
                track:AdjustSpeed(3)
            end
        end
    end)()
end


local SPAWN_ANIM_ID = "rbxassetid://73844251271714"
local function playSpawnAnimation(character, callback)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local spawnAnim = Instance.new("Animation")
    spawnAnim.AnimationId = SPAWN_ANIM_ID
    local spawnTrack = animator:LoadAnimation(spawnAnim)
    spawnTrack.Looped = false
    spawnTrack.Priority = Enum.AnimationPriority.Action


    local torsoParts = {"UpperTorso", "LowerTorso"}
    local originalCollides = {}
    for _, partName in ipairs(torsoParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            originalCollides[part] = part.CanCollide
        end
    end

    spawnTrack:Play()


    local enforceConnection
    enforceConnection = RunService.Heartbeat:Connect(function()
        if spawnTrack.IsPlaying then
            for _, partName in ipairs(torsoParts) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        else
            enforceConnection:Disconnect()

            for part, collide in pairs(originalCollides) do
                if part and part.Parent then
                    part.CanCollide = collide
                end
            end
            if callback then callback() end
        end
    end)


    coroutine.wrap(function()
        while spawnTrack.IsPlaying do
            task.wait(0.1 + math.random() * 0.05)
            if spawnTrack.IsPlaying then
                spawnTrack:AdjustSpeed(0)
                task.wait(0.15)
                spawnTrack:AdjustSpeed(1)
            end
        end
    end)()
end

local function safeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        conn:Disconnect()
    end
end


local function applyAnimations(character)
    local humanoid = character:WaitForChild("Humanoid")

    safeDisconnect(runningConnection)
    safeDisconnect(jumpingConnection)
    safeDisconnect(landedConnection)
    safeDisconnect(speedEnforcer)
    safeDisconnect(jumpEnforcer)

    for _, track in ipairs({walkTrack, idleTrack, jumpTrack}) do
        if track then pcall(function() track:Stop() end) end
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    if speed then
        humanoid.WalkSpeed = 34
        speedEnforcer = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= 34 then
                humanoid.WalkSpeed = 34
            end
        end)
    end

    if jump then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 75
        humanoid.JumpHeight = 7.2
        jumpEnforcer = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Parent then
                if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end
                if humanoid.JumpPower ~= 75 then humanoid.JumpPower = 75 end
                if humanoid.JumpHeight ~= 7.2 then humanoid.JumpHeight = 7.2 end
            end
        end)
    end

    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = currentSet.walk
    walkTrack = animator:LoadAnimation(walkAnim)
    walkTrack.Looped = true
    walkTrack.Priority = Enum.AnimationPriority.Movement

    local idleAnim = Instance.new("Animation")
    idleAnim.AnimationId = currentSet.idle
    idleTrack = animator:LoadAnimation(idleAnim)
    idleTrack.Looped = true
    idleTrack.Priority = Enum.AnimationPriority.Idle

    local jumpAnim = Instance.new("Animation")
    jumpAnim.AnimationId = currentSet.jump
    jumpTrack = animator:LoadAnimation(jumpAnim)
    jumpTrack.Looped = true
    jumpTrack.Priority = Enum.AnimationPriority.Action

    runningConnection = humanoid.Running:Connect(function(speedVal)
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            if speedVal > 0 then
                if idleTrack.IsPlaying then idleTrack:Stop() end
                if not walkTrack.IsPlaying then walkTrack:Play() end
            else
                if walkTrack.IsPlaying then walkTrack:Stop() end
                if not idleTrack.IsPlaying then playRetroTrack(idleTrack) end
            end
        end
    end)

    jumpingConnection = humanoid.Jumping:Connect(function(isActive)
        if isActive then
            if walkTrack.IsPlaying then walkTrack:Stop() end
            if idleTrack.IsPlaying then idleTrack:Stop() end
            jumpTrack:Play()
            coroutine.wrap(function()
                task.wait()
                pcall(function() jumpTrack:AdjustSpeed(0) end)
            end)()
        end
    end)

    landedConnection = humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Landed then
            pcall(function() jumpTrack:AdjustSpeed(1) end)
            if jumpTrack.IsPlaying then jumpTrack:Stop() end
            if humanoid.MoveDirection and humanoid.MoveDirection.Magnitude > 0 then
                if not walkTrack.IsPlaying then walkTrack:Play() end
            else
                if not idleTrack.IsPlaying then playRetroTrack(idleTrack) end
            end
        end
    end)

    if not idleTrack.IsPlaying then
        playRetroTrack(idleTrack)
    end
end



local function initializeGUI()
    if player.PlayerGui:FindFirstChild("AnimToggleGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimToggleGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = currentColors.Main
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    mainFrame.Visible = true


local glitchOverlay = Instance.new("Frame")
glitchOverlay.Size = UDim2.new(1,0,1,0)
glitchOverlay.Position = UDim2.new(0,0,0,0)
glitchOverlay.BackgroundColor3 = Color3.fromRGB(255,0,0)
glitchOverlay.BackgroundTransparency = 1
glitchOverlay.BorderSizePixel = 0
glitchOverlay.ZIndex = 101
glitchOverlay.Parent = mainFrame


local function spawnMainFrameTear()
    local tear = Instance.new("Frame")
    tear.Size = UDim2.new(1,0,0,math.random(2,4))
    tear.Position = UDim2.new(0,math.random(-5,5),math.random(),0)
    tear.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    tear.BackgroundTransparency = 0

    tear.Rotation = math.random(-2,2)
    tear.ZIndex = 999
    tear.BorderSizePixel = 0
    tear.Parent = mainFrame

    local offsetX, offsetY = math.random(-20,20), math.random(-10,10)
    local dur = 0.08 + math.random()*0.07
    TweenService:Create(tear, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
        Position = tear.Position + UDim2.new(0, offsetX, 0, offsetY)
    }):Play()

    task.delay(dur+0.05, function()
        if tear then tear:Destroy() end
    end)
end


task.spawn(function()
    while mainFrame and mainFrame.Parent do

        glitchOverlay.BackgroundTransparency = math.random(70,90)/100
        task.wait(0.05 + math.random()*0.05)
        TweenService:Create(glitchOverlay, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
            BackgroundTransparency = 1
        }):Play()


        local burst = math.random(2,5)
        for i = 1, burst do
            spawnMainFrameTear()
            task.wait(math.random()*0.02)
        end


        local origPos = mainFrame.Position
        local jitterX = math.random(-1,1)
        local jitterY = math.random(-1,1)
        TweenService:Create(mainFrame, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
            Position = origPos + UDim2.new(0,jitterX,0,jitterY)
        }):Play()
        task.wait(0.03)
        TweenService:Create(mainFrame, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
            Position = origPos
        }):Play()
    end
end)

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0
    uiScale.Parent = mainFrame
    TweenService:Create(uiScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()

    local outline = Instance.new("UIStroke")
    outline.Color = currentColors.Stroke
    outline.Thickness = 3
    outline.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,40)
    titleBar.BackgroundColor3 = currentColors.Title
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = currentColors.Stroke
    titleStroke.Thickness = 3
    titleStroke.Parent = titleBar

    for _, pos in ipairs({20, 50}) do
        local circ = Instance.new("Frame")
        circ.Size = UDim2.new(0,15,0,15)
        circ.Position = UDim2.new(0,pos,0.5,-7)
        circ.BackgroundColor3 = currentColors.Main
        circ.BorderSizePixel = 0
        circ.Parent = titleBar
        local uic = Instance.new("UICorner")
        uic.CornerRadius = UDim.new(1,0)
        uic.Parent = circ
        local stroke = Instance.new("UIStroke")
        stroke.Color = currentColors.Stroke
        stroke.Thickness = 2
        stroke.Parent = circ
    end

    local oval = Instance.new("Frame")
    oval.Size = UDim2.new(0,50,0,20)
    oval.Position = UDim2.new(1,-70,0.5,-10)
    oval.BackgroundColor3 = currentColors.Main
    oval.BorderSizePixel = 0
    oval.Parent = titleBar
    local ovalCorner = Instance.new("UICorner")
    ovalCorner.CornerRadius = UDim.new(1,0)
    ovalCorner.Parent = oval
    local ovalStroke = Instance.new("UIStroke")
    ovalStroke.Color = currentColors.Stroke
    ovalStroke.Thickness = 2
    ovalStroke.Parent = oval

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,100,0,50)
    button.Position = UDim2.new(0.5,-50,0.5,-12.5)
    button.Text = "Toggle Anim"
    button.TextColor3 = currentColors.Text
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    button.Parent = mainFrame
    local bstroke = Instance.new("UIStroke")
    bstroke.Color = currentColors.Stroke
    bstroke.Thickness = 3
    bstroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,30)
    label.Position = UDim2.new(0,0,1,-30)
    label.BackgroundTransparency = 1
    label.Text = "Made By R_MP6"
    label.TextColor3 = currentColors.Label
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        isUsingSetA = not isUsingSetA
        currentSet = isUsingSetA and animSetA or animSetB
        if player.Character then
            applyAnimations(player.Character)
        end
    end)
end


if player.Character then
    playSpawnAnimation(player.Character, function()
        applyAnimations(player.Character)
        initializeGUI()
    end)
end

player.CharacterAdded:Connect(function(character)
    currentSet = isUsingSetA and animSetA or animSetB
    playSpawnAnimation(character, function()
        applyAnimations(character)
        initializeGUI()
    end)
end)


StarterGui:SetCore("SendNotification", {
    Title = "Faker R15 Animations",
    Text = "Script has successfully launched!",
    Duration = 4
})

StarterGui:SetCore("SendNotification", {
    Title = "Script Creator",
    Text = "Made by R_MP6",
    Duration = 4
})
