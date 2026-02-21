local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local DISTANCE_THRESHOLD = 20

local isTeleporting = false
local canCheck = false

task.delay(7, function()
    canCheck = true
    print("Startup delay finished. Auto-Hopper is now active.")
end)

local function checkDistances()
    if isTeleporting or not canCheck then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local localPos = character.HumanoidRootPart.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local otherCharacter = player.Character
            if otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart") then
                local otherPos = otherCharacter.HumanoidRootPart.Position
                local distance = (localPos - otherPos).Magnitude
                
                if distance <= DISTANCE_THRESHOLD then
                    isTeleporting = true
                    print("Player " .. player.Name .. " is too close ("..math.floor(distance).." studs)! Hopping servers...")
                    
                    -- Simple teleport to another server of the same place
                    -- Note: This attempts to rejoin the same PlaceId, usually finding a new server.
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    break
                end
            end
        end
    end
end

-- Connect the check to every frame
RunService.Heartbeat:Connect(checkDistances)
print("Auto-Hopper initialized. Safe distance: " .. DISTANCE_THRESHOLD .. " studs.")
