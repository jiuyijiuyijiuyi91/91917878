local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local meshId = "rbxassetid://123868628922938"
local textureId = "rbxassetid://130835890695065"

local followOffset = Vector3.new(-2, 1.4, 2)
local moveSpeed = 40
local rotationResponsiveness = 10
local trailSmoothness = 0.2
local maxDistance = 50

local followerPart = Instance.new("Part")
followerPart.Size = Vector3.new(1, 1, 1)
followerPart.Anchored = false
followerPart.CanCollide = false
followerPart.Massless = true
followerPart.Parent = workspace

local followerMesh = Instance.new("SpecialMesh")
followerMesh.MeshType = Enum.MeshType.FileMesh
followerMesh.MeshId = meshId
followerMesh.TextureId = textureId
followerMesh.Scale = Vector3.new(1.2, 1.2, 1.2)
followerMesh.Parent = followerPart

local velocityController = Instance.new("BodyVelocity")
velocityController.MaxForce = Vector3.new(1e5, 1e5, 1e5)
velocityController.Velocity = Vector3.zero
velocityController.Parent = followerPart

local humanoidRoot

local function onCharacterAdded(character)
	humanoidRoot = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	onCharacterAdded(player.Character)
end

RunService.Heartbeat:Connect(function(deltaTime)
	if not humanoidRoot then return end

	local targetPosition =
		humanoidRoot.Position +
		humanoidRoot.CFrame:VectorToWorldSpace(followOffset)

	if (followerPart.Position - humanoidRoot.Position).Magnitude > maxDistance then
		followerPart.CFrame = CFrame.new(targetPosition)
		velocityController.Velocity = Vector3.zero
		return
	end

	local movementDirection = targetPosition - followerPart.Position
	velocityController.Velocity = (movementDirection / deltaTime) * trailSmoothness

	local desiredCFrame =
		CFrame.new(
			followerPart.Position,
			followerPart.Position + humanoidRoot.CFrame.LookVector
		) * CFrame.Angles(0, math.rad(180), 0)

	followerPart.CFrame = followerPart.CFrame:Lerp(
		desiredCFrame,
		math.clamp(rotationResponsiveness * deltaTime, 0, 1)
	)
end)





local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function attachMesh(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local meshPart = Instance.new("Part")
	meshPart.Size = Vector3.new(2, 1, 2)
	meshPart.Anchored = false
	meshPart.CanCollide = false
	meshPart.Parent = character

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://16452551899"
	mesh.TextureId = "rbxassetid://16431605291"
	mesh.Parent = meshPart

	local weld = Instance.new("Weld")
	weld.Part0 = meshPart
	weld.Part1 = rootPart
	weld.C0 = CFrame.new(-1, 1, 0) * CFrame.Angles(0, math.rad(180), 0)
	weld.Parent = meshPart

	local originalC0 = weld.C0
	local newC0 = CFrame.new(-0.3, 0, -1.5) * CFrame.Angles(0, math.rad(180), 45)
	local isMoved = false

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://27758613"
	local animTrack = humanoid:LoadAnimation(animation)
	animTrack.Looped = true

	local function toggleMesh()
		if isMoved then
			weld.C0 = originalC0

			animTrack:Stop()

			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		else
			weld.C0 = newC0

			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0

			animTrack:Play()
		end
		isMoved = not isMoved
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.E then
			toggleMesh()
		end
	end)
end

player.CharacterAdded:Connect(function(character)
	attachMesh(character)
end)

if player.Character then
	attachMesh(player.Character)
end





local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeathNote"
ScreenGui.Parent = CoreGui

local BookCover = Instance.new("Frame")
BookCover.Size = UDim2.new(0, 320, 0, 450)
BookCover.Position = UDim2.new(0.5, -160, 0.5, -225)
BookCover.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
BookCover.BorderSizePixel = 0
BookCover.Active = true
BookCover.Draggable = true
BookCover.Parent = ScreenGui

local BookCorner = Instance.new("UICorner")
BookCorner.CornerRadius = UDim.new(0, 6)
BookCorner.Parent = BookCover

local SpineShadow = Instance.new("Frame")
SpineShadow.Size = UDim2.new(0.05, 0, 1, 0)
SpineShadow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpineShadow.BorderSizePixel = 0
SpineShadow.Parent = BookCover

local Title = Instance.new("TextLabel")
Title.Text = "DEATH NOTE"
Title.Font = Enum.Font.SpecialElite
Title.TextSize = 40
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.Size = UDim2.new(1, 0, 0, 70)
Title.Position = UDim2.new(0, 0, 0.02, 0)
Title.BackgroundTransparency = 1
Title.Parent = BookCover

local PageArea = Instance.new("Frame")
PageArea.Size = UDim2.new(0.9, 0, 0.75, 0)
PageArea.Position = UDim2.new(0.05, 0, 0.2, 0)
PageArea.BackgroundColor3 = Color3.fromRGB(240, 238, 225)
PageArea.BorderSizePixel = 0
PageArea.Parent = BookCover

local PageCorner = Instance.new("UICorner")
PageCorner.CornerRadius = UDim.new(0, 4)
PageCorner.Parent = PageArea

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 0, 40)
InputBox.Position = UDim2.new(0, 10, 0, 10)
InputBox.BackgroundTransparency = 1
InputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
InputBox.Font = Enum.Font.SpecialElite
InputBox.TextSize = 28
InputBox.PlaceholderText = "victim's name"
InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.Text = ""
InputBox.Parent = PageArea

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 1, 0)
Line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Line.BackgroundTransparency = 0.8
Line.Parent = InputBox

local SuggestionScroll = Instance.new("ScrollingFrame")
SuggestionScroll.Size = UDim2.new(1, 0, 0.85, -20)
SuggestionScroll.Position = UDim2.new(0, 0, 0, 50)
SuggestionScroll.BackgroundTransparency = 1
SuggestionScroll.BorderSizePixel = 0
SuggestionScroll.ScrollBarThickness = 3
SuggestionScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
SuggestionScroll.Parent = PageArea

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = SuggestionScroll


local function Kill(TargetName)
	local TargetChar
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and string.lower(v.Name) == string.lower(TargetName) then
			TargetChar = v
			break
		end
	end

	if TargetChar and TargetChar ~= LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart")

		if RootPart and TargetRoot then
			local OriginalPos = RootPart.CFrame
			local FlingTime = 1.0
			local StartTime = tick()

			local Camera = workspace.CurrentCamera
			local OriginalCameraType = Camera.CameraType
			local OriginalCameraSubject = Camera.CameraSubject
			local FrozenCFrame = Camera.CFrame

			Camera.CameraType = Enum.CameraType.Scriptable
			Camera.CFrame = FrozenCFrame

			local NoclipConnection
			local FlingConnection

			NoclipConnection = RunService.Stepped:Connect(function()
				if Character then
					for _, part in pairs(Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)

			FlingConnection = RunService.Heartbeat:Connect(function()
				if tick() - StartTime > FlingTime or not TargetRoot.Parent or not RootPart.Parent then
					if NoclipConnection then NoclipConnection:Disconnect() end
					if FlingConnection then FlingConnection:Disconnect() end

					RootPart.Velocity = Vector3.new(0, 0, 0)
					RootPart.RotVelocity = Vector3.new(0, 0, 0)
					RootPart.CFrame = OriginalPos + Vector3.new(0, 5, 0)

					task.wait(0.1)
					if Character then
						for _, part in pairs(Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = true
							end
						end
					end

					Camera.CameraType = OriginalCameraType
					Camera.CameraSubject = OriginalCameraSubject
				else
					Camera.CFrame = FrozenCFrame
					RootPart.CFrame = TargetRoot.CFrame
					RootPart.Velocity = Vector3.new(100000, 100000, 100000)
					RootPart.RotVelocity = Vector3.new(100000, 100000, 100000)
				end
			end)
		end
	end
end



local function UpdateList()
	for _, child in pairs(SuggestionScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local Text = string.lower(InputBox.Text)
	if Text == "" then return end

	local Found = {}

	local function AddBtn(Name)
		if table.find(Found, Name) then return end
		table.insert(Found, Name)

		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, -20, 0, 30)
		Btn.Position = UDim2.new(0, 10, 0, 0)
		Btn.BackgroundTransparency = 1
		Btn.TextColor3 = Color3.fromRGB(50, 50, 50)
		Btn.Text = Name
		Btn.Font = Enum.Font.IndieFlower
		Btn.TextSize = 24
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = SuggestionScroll

		local BtnLine = Instance.new("Frame")
		BtnLine.Size = UDim2.new(1, 0, 0, 1)
		BtnLine.Position = UDim2.new(0, 0, 1, 0)
		BtnLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		BtnLine.BackgroundTransparency = 0.8
		BtnLine.Parent = Btn

		Btn.MouseButton1Click:Connect(function()
			InputBox.Text = Name
			InputBox:ReleaseFocus()
			Kill(Name)
			InputBox.Text = ""
			UpdateList()
		end)
	end

	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= LocalPlayer.Name then
			if string.find(string.lower(v.Name), Text) then
				AddBtn(v.Name)
			end
		end
	end
end

InputBox:GetPropertyChangedSignal("Text"):Connect(UpdateList)
InputBox.FocusLost:Connect(function(Enter)
	if Enter then
		Kill(InputBox.Text)
		InputBox.Text = ""
		UpdateList()
	end
end)

local UserInputService = game:GetService("UserInputService")

local ToggleSound = Instance.new("Sound")
ToggleSound.SoundId = "rbxassetid://95995953662374"
ToggleSound.Volume = 1
ToggleSound.Parent = BookCover

ScreenGui.Enabled = false
local Enabled = false

local function ToggleDeathNote()
	Enabled = not Enabled
	ScreenGui.Enabled = Enabled
	ToggleSound:Play()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.E then
			ToggleDeathNote()
		end
	end
end)
