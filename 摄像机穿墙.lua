    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local TeleportService = game:GetService("TeleportService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local StarterGui = game:GetService("StarterGui")
    local ContextActionService = game:GetService("ContextActionService")
    local SoundService = game:GetService("SoundService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    local Teams = game:GetService("Teams")
    local InsertService = game:GetService("InsertService")
    local AssetService = game:GetService("AssetService")


    local function waitForChild(parent, childName)
        local child = parent:FindFirstChild(childName)
        if child then return child end
        while true do
            child = parent.ChildAdded:Wait()
            if child.Name == childName then return child end
        end
    end

    LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
