--[[
        WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackoutOverlay"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = coreGui

local blackoutFrame = Instance.new("Frame")
blackoutFrame.Size = UDim2.new(1, 0, 1, 0)
blackoutFrame.Position = UDim2.new(0, 0, 0, 0)
blackoutFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackoutFrame.BackgroundTransparency = 0
blackoutFrame.ZIndex = 999999
blackoutFrame.Visible = true
blackoutFrame.Parent = screenGui

-- Toggle Functionality
userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.L then
                blackoutFrame.Visible = not blackoutFrame.Visible
        end
end)
