local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://6394771700"
sound.Volume = 1
sound.Parent = character:WaitForChild("Head")

local hakiActive = false
local fadeTime = 0.3
local lastToggleTime = 0
local toggleCooldown = 1.4
local speedBoost = 8
local originalWalkSpeed = humanoid.WalkSpeed

local function getArmParts()
local parts = {}
if character:FindFirstChild("LeftUpperArm") then
for _, limbName in pairs({"LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftHand", "RightHand"}) do
local part = character:FindFirstChild(limbName)
if part and part:IsA("BasePart") then
table.insert(parts, part)
end
end
else
for _, limbName in pairs({"Left Arm", "Right Arm"}) do
local part = character:FindFirstChild(limbName)
if part and part:IsA("BasePart") then
table.insert(parts, part)
end
end
end
return parts
end

local originalColors = {}
for _, part in ipairs(getArmParts()) do
originalColors[part] = part.Color
end

local function setArmColor(color)
local parts = getArmParts()
for _, part in ipairs(parts) do
TweenService:Create(part, TweenInfo.new(fadeTime), {Color = color}):Play()
end
end

local function toggleHaki()
local currentTime = tick()
if currentTime - lastToggleTime < toggleCooldown then
return
end

hakiActive = not hakiActive
lastToggleTime = currentTime

local parts = getArmParts()

if hakiActive then
setArmColor(Color3.new(0,0,0))
sound:Play()

if humanoid then
humanoid.WalkSpeed = originalWalkSpeed + speedBoost
end
else
for _, part in ipairs(parts) do
local originalColor = originalColors[part]
if originalColor then
TweenService:Create(part, TweenInfo.new(fadeTime), {Color = originalColor}):Play()
end
end
if humanoid then
humanoid.WalkSpeed = originalWalkSpeed
end
end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == Enum.KeyCode.Q then
toggleHaki()
end
end)

player.CharacterAdded:Connect(function(char)
character = char
humanoid = character:WaitForChild("Humanoid")
sound.Parent = character:WaitForChild("Head")
originalColors = {}
for _, part in ipairs(getArmParts()) do
originalColors[part] = part.Color
end

if hakiActive then
setArmColor(Color3.new(0,0,0))
humanoid.WalkSpeed = originalWalkSpeed + speedBoost
else
humanoid.WalkSpeed = originalWalkSpeed
end
end)







local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera


local RANGE = 100000
local KEYBIND = Enum.KeyCode.E
local HIGHLIGHT_COLOR = Color3.fromRGB(0, 255, 0)
local COOLDOWN = 2

local obssound = Instance.new("Sound")
obssound.SoundId = "rbxassetid://7123371384"
obssound.Volume = 1
obssound.Looped = false
obssound.Parent = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
blur.Enabled = false
blur.Name = "SonicBlur"

local colorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Enabled = false
colorCorrection.Name = "SonicColorFX"

local EFFECT_COLORS = {
Active = { Contrast = 0.5, Saturation = 0.6, TintColor = Color3.fromRGB(87, 216, 255) },
Inactive = { Contrast = 0, Saturation = 0, TintColor = Color3.new(1, 1, 1) }
}

local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local hakiActive = false
local activeHighlights = {}
local lastToggle = 0

local targetGUIContainer = Instance.new("Folder")
targetGUIContainer.Name = "HakiTargets"
targetGUIContainer.Parent = player:WaitForChild("PlayerGui")

local function fadeSound(obssound, targetVolume, duration)
if not obssound then return end

local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(obssound, tweenInfo, {Volume = targetVolume})
tween:Play()

if targetVolume == 0 then
tween.Completed:Connect(function()
obssound:Stop()
obssound.Volume = 1
end)
end
end



local function setVisuals(enable)
colorCorrection.Enabled = true
blur.Enabled = true
local target = enable and EFFECT_COLORS.Active or EFFECT_COLORS.Inactive
local blurSize = enable and 6 or 0
TweenService:Create(blur, TWEEN_INFO, {Size = blurSize}):Play()
TweenService:Create(colorCorrection, TWEEN_INFO, {
Contrast = target.Contrast,
Saturation = target.Saturation,
TintColor = target.TintColor
}):Play()
if not enable then
task.delay(0.5, function()
if not hakiActive then
colorCorrection.Enabled = false
blur.Enabled = false
end
end)
end
end

local function createTargetGUI(target)
if not target:FindFirstChild("HumanoidRootPart") or not target:FindFirstChild("Humanoid") then return nil end

local humanoid = target.Humanoid

local billboard = Instance.new("BillboardGui")
billboard.Name = target.Name .. "_Haki"
billboard.Size = UDim2.new(0, 200, 0, 60)
billboard.StudsOffset = Vector3.new(0, 3, 0)
billboard.Adornee = target.HumanoidRootPart
billboard.AlwaysOnTop = true
billboard.Parent = targetGUIContainer

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = billboard

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = HIGHLIGHT_COLOR
nameLabel.Text = target.Name
nameLabel.TextScaled = true
nameLabel.Parent = frame

local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
healthLabel.Position = UDim2.new(0, 0, 0.3, 0)
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = HIGHLIGHT_COLOR
healthLabel.TextScaled = true
healthLabel.Parent = frame

local toolsLabel = Instance.new("TextLabel")
toolsLabel.Size = UDim2.new(1, 0, 0.4, 0)
toolsLabel.Position = UDim2.new(0, 0, 0.6, 0)
toolsLabel.BackgroundTransparency = 1
toolsLabel.TextColor3 = HIGHLIGHT_COLOR
toolsLabel.TextScaled = true
toolsLabel.TextWrapped = true
toolsLabel.Parent = frame

local updateConn
updateConn = RunService.RenderStepped:Connect(function()
if not target or not target.Parent then
billboard:Destroy()
updateConn:Disconnect()
return
end
healthLabel.Text = string.format("Health: %.0f / %.0f", humanoid.Health, humanoid.MaxHealth)

local toolNames = {}
local targetPlayer = Players:GetPlayerFromCharacter(target)
if targetPlayer then
for _, tool in pairs(targetPlayer.Backpack:GetChildren()) do
if tool:IsA("Tool") then table.insert(toolNames, tool.Name) end
end
if targetPlayer.Character then
for _, tool in pairs(targetPlayer.Character:GetChildren()) do
if tool:IsA("Tool") then table.insert(toolNames, tool.Name) end
end
end
end
if #toolNames > 0 then
toolsLabel.Text = "Tools: " .. table.concat(toolNames, ", ")
else
toolsLabel.Text = "Tools: None"
end
end)

return billboard
end

local function updateHaki()
for _, highlight in pairs(activeHighlights) do
if highlight and highlight.Billboard then
highlight.Billboard:Destroy()
end
if highlight.Highlight then
highlight.Highlight:Destroy()
end
end
activeHighlights = {}

local function addTarget(target)
if not target:FindFirstChild("HumanoidRootPart") or not target:FindFirstChild("Humanoid") then return end
local distance = (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
if distance > RANGE then return end

local highlight = Instance.new("Highlight")
highlight.Adornee = target
highlight.FillColor = HIGHLIGHT_COLOR
highlight.OutlineTransparency = 1
highlight.Parent = Workspace

local billboard = createTargetGUI(target)

table.insert(activeHighlights, {Highlight = highlight, Billboard = billboard})
end

for _, otherPlayer in pairs(Players:GetPlayers()) do
if otherPlayer ~= player and otherPlayer.Character then
addTarget(otherPlayer.Character)
end
end

for _, npc in pairs(Workspace:GetChildren()) do
if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
if not Players:GetPlayerFromCharacter(npc) then
addTarget(npc)
end
end
end
end

local function turnonhaki()
local now = tick()
if now - lastToggle < COOLDOWN then return end
lastToggle = now

hakiActive = not hakiActive
if hakiActive then
setVisuals(true)
if not obssound.IsPlaying then obssound:Play() end
fadeSound(obssound, 1, 0.5)
else
setVisuals(false)
fadeSound(obssound, 0, 1)
for _, highlight in pairs(activeHighlights) do
if highlight.Billboard then highlight.Billboard:Destroy() end
if highlight.Highlight then highlight.Highlight:Destroy() end
end
activeHighlights = {}
end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == KEYBIND then
turnonhaki()
end
end)

RunService.RenderStepped:Connect(function()
if hakiActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
updateHaki()
end
end)




local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local hakisound = "rbxassetid://136214321409042"
local zoomFOV = 30
local effectDuration = 4
local cooldownTime = 10
local camshakelevel = 1

local zoomTime = effectDuration * 0.45
local tintTime = effectDuration * 0.7
local fadeTime = effectDuration * 0.45

local onCooldown = false

local function createSound(parent)
local sound = Instance.new("Sound")
sound.SoundId = hakisound
sound.Volume = 1
sound.Parent = parent
return sound
end

local function createVFX(parent, color, texture, brightness, rate, lifetime)
local particle = Instance.new("ParticleEmitter")
particle.Brightness = brightness
particle.Color = ColorSequence.new(color)
particle.LightEmission = 0
particle.Orientation = Enum.ParticleOrientation.FacingCamera
particle.Size = NumberSequence.new({
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(0.985,9.75),
NumberSequenceKeypoint.new(1,0)
})
particle.Texture = texture
particle.Transparency = NumberSequence.new(0.95)
particle.ZOffset = 0
particle.EmissionDirection = Enum.NormalId.Top
particle.Lifetime = NumberRange.new(lifetime)
particle.Rate = rate
particle.Rotation = NumberRange.new(-360, 360)
particle.RotSpeed = NumberRange.new(-25, 25)
particle.Speed = NumberRange.new(0.003)
particle.Shape = Enum.ParticleEmitterShape.Box
particle.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
particle.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
particle.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
particle.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
particle.Parent = parent
return particle
end

local function createColorCorrection()
local cce = Instance.new("ColorCorrectionEffect")
cce.Name = "TintEffect"
cce.TintColor = Color3.fromRGB(255,255,255)
cce.Enabled = true
cce.Parent = Lighting
return cce
end

local tintEffect = createColorCorrection()

local function tweenTint(targetColor, time, callback)
local startColor = tintEffect.TintColor
local elapsed = 0
task.spawn(function()
while elapsed < time do
task.wait(0.03)
elapsed = elapsed + 0.03
local alpha = math.clamp(elapsed / time, 0, 1)
tintEffect.TintColor = Color3.new(
startColor.R + (targetColor.R - startColor.R) * alpha,
startColor.G + (targetColor.G - startColor.G) * alpha,
startColor.B + (targetColor.B - startColor.B) * alpha
)
end
if callback then callback() end
end)
end

local function shakeCamera(duration, magnitude)
local elapsed = 0
local originalCFrame = camera.CFrame
local connection
connection = RunService.RenderStepped:Connect(function(deltaTime)
if elapsed < duration then
local offset = Vector3.new(
(math.random() - 0.5) * 2 * magnitude,
(math.random() - 0.5) * 2 * magnitude,
(math.random() - 0.5) * 2 * magnitude
)
camera.CFrame = originalCFrame * CFrame.new(offset)
elapsed = elapsed + deltaTime
else
camera.CFrame = originalCFrame
if connection then connection:Disconnect() end
end
end)
end

local function fadehakisoundout(sound, fadeDuration)
local startVolume = sound.Volume
local elapsed = 0
task.spawn(function()
while elapsed < fadeDuration and sound.Parent do
task.wait(0.05)
elapsed = elapsed + 0.05
local alpha = math.clamp(elapsed / fadeDuration, 0, 1)
sound.Volume = startVolume * (1 - alpha)
end
if sound then
sound:Stop()
sound:Destroy()
end
end)
end

local function triggerhaki()
if onCooldown then return end
onCooldown = true
task.delay(cooldownTime, function() onCooldown = false end)

local char = player.Character
if not char then return end
local head = char:FindFirstChild("Head")
local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")
if not head or not humanoidRootPart or not humanoid then return end

local oldWalkSpeed = humanoid.WalkSpeed
local oldJumpPower = humanoid.JumpPower
humanoid.WalkSpeed = 0
humanoid.JumpPower = 0
task.delay(effectDuration, function()
if humanoid then
humanoid.WalkSpeed = oldWalkSpeed
humanoid.JumpPower = oldJumpPower
end
end)

local sound = createSound(head)
sound:Play()

local vfx1 = createVFX(head, Color3.new(1,1,1), "rbxassetid://18791624432", 10000, 20, 0.7)
local vfx2 = createVFX(head, Color3.new(1,0,0), "rbxassetid://12201347372", 100, 3, 0.7)
Debris:AddItem(vfx1, effectDuration)
Debris:AddItem(vfx2, effectDuration)

local tweenInfo = TweenInfo.new(zoomTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local zoomTween = TweenService:Create(camera, tweenInfo, {FieldOfView = zoomFOV})
zoomTween:Play()
task.delay(zoomTime + 0.3, function()
local resetTween = TweenService:Create(camera, tweenInfo, {FieldOfView = 70})
resetTween:Play()
end)

tweenTint(Color3.fromRGB(255,83,83), tintTime, function()
tweenTint(Color3.fromRGB(255,255,255), fadeTime)
end)

shakeCamera(0.5, camshakelevel)

local hitbox = Instance.new("Part")
hitbox.Size = Vector3.new(50,50,50)
hitbox.Transparency = 1
hitbox.Anchored = true
hitbox.CanCollide = false
hitbox.CFrame = humanoidRootPart.CFrame
hitbox.Parent = workspace

local stunnedNPCs = {}

hitbox.Touched:Connect(function(other)
if other.Parent then
local npcHumanoid = other.Parent:FindFirstChildOfClass("Humanoid")
if npcHumanoid and npcHumanoid.Health > 0 then
local root = other.Parent:FindFirstChild("HumanoidRootPart")
if root and not Players:GetPlayerFromCharacter(root.Parent) then
if not stunnedNPCs[npcHumanoid] then
stunnedNPCs[npcHumanoid] = {
WalkSpeed = npcHumanoid.WalkSpeed,
JumpPower = npcHumanoid.JumpPower
}
npcHumanoid.WalkSpeed = 0
npcHumanoid.JumpPower = 0

task.delay(8, function()
if npcHumanoid then
local oldValues = stunnedNPCs[npcHumanoid]
npcHumanoid.WalkSpeed = oldValues.WalkSpeed
npcHumanoid.JumpPower = oldValues.JumpPower
stunnedNPCs[npcHumanoid] = nil
end
end)
end
end
end
end
end)

local connection
connection = RunService.RenderStepped:Connect(function()
if humanoidRootPart and hitbox then
hitbox.CFrame = humanoidRootPart.CFrame
else
connection:Disconnect()
end
end)

task.delay(effectDuration, function()
if hitbox then hitbox:Destroy() end
if connection then connection:Disconnect() end

if sound then
fadehakisoundout(sound, 1.5)
end
end)
end

local function bindInput()
UserInputService.InputBegan:Connect(function(input, gp)
if gp then return end
if input.KeyCode == Enum.KeyCode.F then
triggerhaki()
end
end)
end

bindInput()

player.CharacterAdded:Connect(function()
task.wait(0.5)
bindInput()
end)
