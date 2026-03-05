local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FreezeUI"
screenGui.ResetOnSpawn = false -- Keeps the UI even if the player dies
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.8, -50) -- Positioned near the bottom center
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Altitude Freeze"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(0.5, -80, 0.5, -5)
toggleButton.Text = "Turn ON"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- 2. State & Logic
local isFrozen = false

local function toggleFreeze()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    isFrozen = not isFrozen
    
    if isFrozen then
        -- Update UI to show OFF state
        toggleButton.Text = "Turn OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        
        -- Teleport the character up to a medium altitude
        local mediumAltitude = 25
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, mediumAltitude, 0)

        -- Freeze the character by anchoring all their body parts
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        print("Frozen at medium altitude!")
    else
        -- Update UI to show ON state
        toggleButton.Text = "Turn ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Unfreeze the character by unanchoring all their body parts
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        print("Unfrozen!")
    end
end

-- 3. Connect Button Click
toggleButton.MouseButton1Click:Connect(toggleFreeze)
