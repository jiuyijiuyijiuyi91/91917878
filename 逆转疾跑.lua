local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local function setupTool(character)
local humanoid = character:WaitForChild("Humanoid")
local tool = Instance.new("Tool")
tool.Name = "逆转疾跑"
tool.RequiresHandle = false
tool.Parent = player.Backpack
local DEFAULT_SPEED = humanoid.WalkSpeed
local BOOST_SPEED = DEFAULT_SPEED * 16
local DEFAULT_FOV = camera.FieldOfView
local BOOST_FOV = 130
local FOV_DELAY = 0.8
local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://121480327509940"
local idleTrack = humanoid:LoadAnimation(idleAnim)
local runAnim = Instance.new("Animation")
runAnim.AnimationId = "rbxassetid://82598234841035"
local runTrack = humanoid:LoadAnimation(runAnim)
local slowAnim = Instance.new("Animation")
slowAnim.AnimationId = "rbxassetid://121350640829746"
local boosted = false
local speedTween
local runTime = 0
local fovTween
local slowAnimationPlaying = false
local assetId = "rbxassetid://70681471980871"
local model
local followConnection
local Offset = Vector3.new(
0,
-18,
10
)

local function spawnAndFollowModel()
if model then return end
local objects = game:GetObjects(assetId)
if #objects > 0 then
model = objects[1]
model.Parent = workspace
if model:IsA("Model") then
if not model.PrimaryPart then
local primary = model:FindFirstChildWhichIsA("BasePart")
if primary then
model.PrimaryPart = primary
end
end
for _, part in ipairs(model:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
part.Massless = true
end
end
if model.PrimaryPart then
local spawnSound = Instance.new("Sound")
spawnSound.SoundId = "rbxassetid://122261039674349"
spawnSound.Volume = 1
spawnSound.Parent = model.PrimaryPart
spawnSound:Play()
spawnSound.Ended:Connect(function()
spawnSound:Destroy()
end)
end
end
end
if not followConnection and model and model.PrimaryPart then
followConnection = RunService.RenderStepped:Connect(function()
if not model or not model.PrimaryPart or not humanoid or not humanoid.RootPart then
if followConnection then
followConnection:Disconnect()
followConnection = nil
end
if model then
model:Destroy()
model = nil
end
return
end
if humanoid.MoveDirection.Magnitude == 0 then
if followConnection then
followConnection:Disconnect()
followConnection = nil
end
if model then
model:Destroy()
model = nil
end
return
end
local rootCFrame = humanoid.RootPart.CFrame
local lookVector = rootCFrame.LookVector
local spawnCFrame = rootCFrame + rootCFrame:VectorToWorldSpace(Offset)
local facingRotation = CFrame.new(Vector3.new(), lookVector)
model:SetPrimaryPartCFrame(CFrame.new(spawnCFrame.Position) * facingRotation)
end)
end
end
local function stopAndDestroyModel()
if followConnection then
followConnection:Disconnect()
followConnection = nil
end
if model then
model:Destroy()
model = nil
end
end
function tweenFOV(target, time)
if fovTween then fovTween:Cancel() end
fovTween = TweenService:Create(camera, TweenInfo.new(time, Enum.EasingStyle.Linear), {FieldOfView = target})
fovTween:Play()
if target == BOOST_FOV then
spawnAndFollowModel()
else
stopAndDestroyModel()
end
end
local function playIdle()
if boosted and humanoid.MoveDirection.Magnitude == 0 and not idleTrack.IsPlaying and not slowAnimationPlaying then
idleTrack:Play(0.3)
end
end
local function stopIdle()
if idleTrack.IsPlaying then
idleTrack:Stop(0.3)
end
end
local function playRun()
if boosted and humanoid.MoveDirection.Magnitude > 0 and not runTrack.IsPlaying and not slowAnimationPlaying then
runTrack:Play(0.3)
end
end
local function stopRun()
if runTrack.IsPlaying then
runTrack:Stop(0.3)
end
end
local function startBoost()
if slowAnimationPlaying then return end
if speedTween then speedTween:Cancel() end
speedTween = TweenService:Create(humanoid, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {WalkSpeed = BOOST_SPEED})
speedTween:Play()
end
local function stopBoost()
if speedTween then speedTween:Cancel() end
humanoid.WalkSpeed = DEFAULT_SPEED
end
local function enableBoost()
boosted = true
playIdle()
end
local function disableBoost()
boosted = false
stopIdle()
stopRun()
stopBoost()
tweenFOV(DEFAULT_FOV, 0.3)
end
local function playSlowAnimation()
slowAnimationPlaying = true
stopIdle()
stopRun()
if speedTween then speedTween:Cancel() end
humanoid.WalkSpeed = 1.5
local slowTrack = humanoid:LoadAnimation(slowAnim)
slowTrack:Play(0.5)
slowTrack.TimePosition = 4.5
slowTrack:AdjustSpeed(1)
task.delay(3, function()
slowTrack:Stop(0.5)
slowAnimationPlaying = false
if boosted and humanoid.MoveDirection.Magnitude > 0 then
if speedTween then speedTween:Cancel() end
speedTween = TweenService:Create(humanoid, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {WalkSpeed = BOOST_SPEED})
speedTween:Play()
playRun()
else
humanoid.WalkSpeed = DEFAULT_SPEED
playIdle()
end
end)
end
tool.Equipped:Connect(function()
task.defer(function()
humanoid:UnequipTools()
end)
if slowAnimationPlaying then
return
end
if boosted then
if humanoid.MoveDirection.Magnitude > 0 then
playSlowAnimation()
return
else
disableBoost()
end
else
enableBoost()
end
end)
RunService.RenderStepped:Connect(function(dt)
if boosted and not slowAnimationPlaying then
if humanoid.MoveDirection.Magnitude > 0 then
runTime += dt
stopIdle()
playRun()
startBoost()
if humanoid.WalkSpeed >= 16 then
runTrack:AdjustSpeed(1.5)
else
runTrack:AdjustSpeed(1)
end
if runTime >= FOV_DELAY and camera.FieldOfView ~= BOOST_FOV then
tweenFOV(BOOST_FOV, 0.3)
end
else
runTime = 0
stopRun()
stopBoost()
playIdle()
runTrack:AdjustSpeed(1)
if camera.FieldOfView ~= DEFAULT_FOV then
tweenFOV(DEFAULT_FOV, 0.3)
end
end
else
runTime = 0
end
end)
humanoid.Died:Connect(function()
disableBoost()
end)
end
player.CharacterAdded:Connect(setupTool)
if player.Character then
setupTool(player.Character)
end
