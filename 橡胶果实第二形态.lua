local Animations = {
	Idle1 = "rbxassetid://134878791451155",
	Walk  = "rbxassetid://73485678861586",
	Run   = "rbxassetid://73485678861586",
	Jump  = "rbxassetid://656117878",
	Fall  = "rbxassetid://656115606",
	Intro = "rbxassetid://121760229357537"
}

local gear2startsound = "rbxassetid://106654269561138"
local gear2start = 2
local gear2speed = 60
local gear2jumppower = 70

local player = game.Players.LocalPlayer
local canUseSoru = false

local function applyAnimations(char)
	local animate = char:WaitForChild("Animate")
	animate.idle.Animation1.AnimationId = Animations.Idle1
	animate.walk.WalkAnim.AnimationId = Animations.Walk
	if animate:FindFirstChild("run") then
		animate.run.RunAnim.AnimationId = Animations.Run
	end
	animate.jump.JumpAnim.AnimationId = Animations.Jump
	if animate:FindFirstChild("fall") then
		animate.fall.FallAnim.AnimationId = Animations.Fall
	end
end

local function addSmoke(char)
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			local smoke = Instance.new("ParticleEmitter")
			smoke.Texture = "rbxassetid://258128463"
			smoke.Rate = 10
			smoke.Lifetime = NumberRange.new(0.5, 1)
			smoke.Speed = NumberRange.new(0.5, 1)
			smoke.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
			smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
			smoke.Rotation = NumberRange.new(0, 360)
			smoke.RotSpeed = NumberRange.new(-10, 10)
			smoke.LightEmission = 0.5
			smoke.Parent = part
		end
	end
end

local function playIntro(char)
	local humanoid = char:WaitForChild("Humanoid")
	local animate = char:WaitForChild("Animate")
	animate.Disabled = true

	local originalWalk = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	local anim = Instance.new("Animation")
	anim.AnimationId = Animations.Intro
	local track = humanoid:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0)
	track:AdjustWeight(0)

	for i = 1, 20 do
		track:AdjustWeight(i / 20)
		task.wait(1 / 20)
	end

	local sound = Instance.new("Sound")
	sound.SoundId = gear2startsound
	sound.Volume = 3
	sound.Parent = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	sound:Play()

	local targetColor = Color3.fromRGB(250, 161, 161)
	local parts = {}
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			table.insert(parts, part)
		end
	end
	local originalColors = {}
	for i, part in ipairs(parts) do
		originalColors[i] = part.Color
	end
	for step = 1, 30 do
		local alpha = step / 30
		for i, part in ipairs(parts) do
			part.Color = originalColors[i]:Lerp(targetColor, alpha)
		end
		task.wait(gear2start / 30)
	end

	humanoid.WalkSpeed = gear2speed
	humanoid.JumpPower = gear2jumppower

	track:Stop()
	track:Destroy()
	sound:Destroy()

	applyAnimations(char)
	addSmoke(char)
	animate.Disabled = false
	canUseSoru = true
end

local function setupCharacter(char)
	canUseSoru = false
	playIntro(char)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	setupCharacter(player.Character)
end


local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local animationId = "rbxassetid://121760229357537"
local animation
local animationTrack
local humanoid

local animationPlaying = false
local inputLocked = false
local canUseAnimation = false

local prevWalkSpeed
local prevJumpPower
local prevAutoRotate

local function pose()
	prevWalkSpeed = humanoid.WalkSpeed
	prevJumpPower = humanoid.JumpPower
	prevAutoRotate = humanoid.AutoRotate

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.AutoRotate = false
end

local function unpose()
	humanoid.WalkSpeed = prevWalkSpeed
	humanoid.JumpPower = prevJumpPower
	humanoid.AutoRotate = prevAutoRotate
end

local function stopAnimation()
	if animationTrack then
		animationTrack:Stop(0.2)
	end
	animationPlaying = false
	inputLocked = false
	unpose()
end

local function playAnimation()
	if not humanoid or not animationTrack then return end
	inputLocked = true
	pose()
	animationTrack:Play(0.2, 1, 1)
	animationPlaying = true

	animationTrack.Stopped:Connect(function()
		stopAnimation()
	end)
end

local function setcharacterup(char)
	humanoid = char:WaitForChild("Humanoid")
	animation = Instance.new("Animation")
	animation.AnimationId = animationId
	animationTrack = humanoid:LoadAnimation(animation)
end

player.CharacterAdded:Connect(function(char)
	setcharacterup(char)
end)

if player.Character then
	setcharacterup(player.Character)
end

delay(3, function()
	canUseAnimation = true
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		if not canUseAnimation then return end

		if not animationPlaying then
			playAnimation()
		else
			stopAnimation()
		end
	elseif inputLocked then
		return Enum.ContextActionResult.Sink
	end
end)



local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(char)
	character = char
end)

local debounce = false

local soruduration = 1
local soruspeed = 200
local sorujump = 100

local sorustart = "rbxassetid://132566914518085"
local soruend = "rbxassetid://132566914518085"

local function makeparticle(parent, props)
	local emitter = Instance.new("ParticleEmitter")
	for prop, val in pairs(props) do
		emitter[prop] = val
	end
	emitter.VelocityInheritance = 1
	emitter.LockedToPart = true
	emitter.Parent = parent
	return emitter
end

local function activateinvis(character)
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local savedCFrame = hrp.CFrame

	character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
	wait(0.15)

	local seat = Instance.new("Seat")
	seat.Anchored = false
	seat.CanCollide = false
	seat.Name = "invischair"
	seat.Transparency = 1
	seat.CFrame = savedCFrame
	seat.Parent = Workspace

	local weld = Instance.new("Weld")
	weld.Part0 = seat
	weld.Part1 = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = seat

	return seat
end

UserInputService.InputBegan:Connect(function(input, chat)
	if chat then return end
	if input.KeyCode == Enum.KeyCode.F and not debounce and canUseSoru then
		debounce = true

		local character = player.Character
		if not character or not character:FindFirstChild("Humanoid") then
			debounce = false
			return
		end


		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

		local startSound = Instance.new("Sound")
		startSound.SoundId = sorustart
		startSound.Volume = 1
		startSound.Parent = root
		startSound:Play()

		local invisSeat = activateinvis(character)

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 1
			elseif part:IsA("ParticleEmitter") then
				part.Enabled = false
			end
		end

		local oldSpeed = humanoid.WalkSpeed
		local oldJump = humanoid.JumpPower

		humanoid.WalkSpeed = soruspeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = sorujump

		local vfxAttachment
		local emitter1, emitter2
		if torso then
			vfxAttachment = Instance.new("Attachment")
			vfxAttachment.Name = "VFXAttachment"
			vfxAttachment.Parent = torso

			emitter1 = makeparticle(vfxAttachment, {
				Texture = "rbxassetid://13801691431",
				Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)),
				Lifetime = NumberRange.new(0.05, 0.4),
				Rate = 0,
				Rotation = NumberRange.new(-90),
				Speed = NumberRange.new(0.6, 13),
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.101, 1.94),
					NumberSequenceKeypoint.new(0.187, 0.0625),
					NumberSequenceKeypoint.new(0.303, 2.81),
					NumberSequenceKeypoint.new(0.433, 0.188),
					NumberSequenceKeypoint.new(0.551, 2.81),
					NumberSequenceKeypoint.new(0.683, 0),
					NumberSequenceKeypoint.new(0.799, 2.87),
					NumberSequenceKeypoint.new(0.905, 0.125),
					NumberSequenceKeypoint.new(1, 3.25)
				}),
				Squash = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.112),
					NumberSequenceKeypoint.new(0.0636, -0.338),
					NumberSequenceKeypoint.new(0.102, 1.88),
					NumberSequenceKeypoint.new(0.151, -0.188),
					NumberSequenceKeypoint.new(0.217, 2.21),
					NumberSequenceKeypoint.new(0.31, -0.188),
					NumberSequenceKeypoint.new(0.398, 2.32),
					NumberSequenceKeypoint.new(0.507, -0.188),
					NumberSequenceKeypoint.new(0.575, 2.29),
					NumberSequenceKeypoint.new(0.695, 0.225),
					NumberSequenceKeypoint.new(0.768, 2.21),
					NumberSequenceKeypoint.new(0.887, 1.09),
					NumberSequenceKeypoint.new(1, 1.95)
				}),
				LightEmission = 0,
				LightInfluence = 1,
				Orientation = Enum.ParticleOrientation.FacingCamera,
				SpreadAngle = Vector2.new(360, -360),
				Shape = Enum.ParticleEmitterShape.Box,
				ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
				Brightness = 15,
				ZOffset = 2,
				RotSpeed = NumberRange.new(-10, 10),
				TimeScale = 0.3
			})
			emitter1:Emit(12)


			emitter2 = makeparticle(vfxAttachment, {
				Texture = "rbxassetid://13801691431",
				Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
				Lifetime = NumberRange.new(0.05, 0.4),
				Rate = 0,
				Rotation = NumberRange.new(-90),
				Speed = NumberRange.new(0.6, 13),
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.101, 1.94),
					NumberSequenceKeypoint.new(0.187, 0.0625),
					NumberSequenceKeypoint.new(0.303, 2.81),
					NumberSequenceKeypoint.new(0.433, 0.188),
					NumberSequenceKeypoint.new(0.551, 2.81),
					NumberSequenceKeypoint.new(0.683, 0),
					NumberSequenceKeypoint.new(0.799, 2.87),
					NumberSequenceKeypoint.new(0.905, 0.125),
					NumberSequenceKeypoint.new(1, 3.25)
				}),
				Squash = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.112),
					NumberSequenceKeypoint.new(0.0636, -0.338),
					NumberSequenceKeypoint.new(0.102, 1.88),
					NumberSequenceKeypoint.new(0.151, -0.188),
					NumberSequenceKeypoint.new(0.217, 2.21),
					NumberSequenceKeypoint.new(0.31, -0.188),
					NumberSequenceKeypoint.new(0.398, 2.32),
					NumberSequenceKeypoint.new(0.507, -0.188),
					NumberSequenceKeypoint.new(0.575, 2.29),
					NumberSequenceKeypoint.new(0.695, 0.225),
					NumberSequenceKeypoint.new(0.768, 2.21),
					NumberSequenceKeypoint.new(0.887, 1.09),
					NumberSequenceKeypoint.new(1, 1.95)
				}),
				LightEmission = 0,
				LightInfluence = 1,
				Orientation = Enum.ParticleOrientation.FacingCamera,
				SpreadAngle = Vector2.new(360, -360),
				Shape = Enum.ParticleEmitterShape.Box,
				ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
				Brightness = 15,
				ZOffset = 1.5,
				RotSpeed = NumberRange.new(-10, 10),
				TimeScale = 0.3
			})
			emitter2:Emit(18)
		end

		task.wait(soruduration)

		local function isOnGround(hum)
			return hum and hum.FloorMaterial ~= Enum.Material.Air
		end

		while humanoid and not isOnGround(humanoid) do
			task.wait(0.1)
		end

		humanoid.WalkSpeed = oldSpeed
		humanoid.JumpPower = oldJump

		for _, part in ipairs(character:GetDescendants()) do
			if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
				part.Transparency = 0
			end
		end

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("ParticleEmitter") and part.Name ~= "VFXEmitter" then
				part.Enabled = true
			end
		end


		if invisSeat then
			invisSeat:Destroy()
		end

		local endSound = Instance.new("Sound")
		endSound.SoundId = soruend
		endSound.Volume = 1
		endSound.Parent = root
		endSound:Play()

		if vfxAttachment then
			vfxAttachment:Destroy()
		end

		debounce = false
	end
end)
