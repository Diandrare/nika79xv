local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Konfigurasi Awal
local settings = {
    SkillID = "18", 
    SkillID2 = "1",
    SkillID3 = "2",
    DefaultDelay = 0.5
}

-- Path Remote
local skillPath = RS:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\230\138\128\232\131\189")
local unequipRemote = skillPath:WaitForChild("\229\141\184\228\184\139\230\138\128\232\131\189")
local equipRemote = skillPath:WaitForChild("\232\163\133\229\164\135\230\138\128\232\131\189")

--- DETEKSI PLATFORM ---
local isMobile = (UIS.TouchEnabled and not UIS.KeyboardEnabled)

--- UI SETUP (MOBILE FRIENDLY) ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "SkillManagerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frameWidth = isMobile and 220 or 150
local frameHeight = isMobile and 140 or 100
local fontSize = isMobile and 14 or 12
local btnFontSize = isMobile and 14 or 12
local inputHeight = isMobile and 36 or 30
local btnHeight = isMobile and 32 or 25

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = false

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 120, 255)
stroke.Thickness = 1
stroke.Transparency = 0.5

--- CUSTOM DRAG (WORKS ON MOBILE + PC) ---
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

--- TITLE ---
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SKILL ID SETTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = fontSize
title.Font = Enum.Font.GothamBold

--- INPUT BOX ---
local idInput = Instance.new("TextBox", mainFrame)
idInput.Size = UDim2.new(0.8, 0, 0, inputHeight)
idInput.Position = UDim2.new(0.1, 0, 0, 32)
idInput.PlaceholderText = "ID Baru (9)"
idInput.Text = settings.SkillID
idInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
idInput.TextColor3 = Color3.new(1, 1, 1)
idInput.TextSize = fontSize
idInput.Font = Enum.Font.Gotham
idInput.ClearTextOnFocus = false

local inputCorner = Instance.new("UICorner", idInput)
inputCorner.CornerRadius = UDim.new(0, 6)

local inputPadding = Instance.new("UIPadding", idInput)
inputPadding.PaddingLeft = UDim.new(0, 8)
inputPadding.PaddingRight = UDim.new(0, 8)

--- UPDATE BUTTON ---
local updateBtn = Instance.new("TextButton", mainFrame)
updateBtn.Size = UDim2.new(0.8, 0, 0, btnHeight)
updateBtn.Position = UDim2.new(0.1, 0, 1, -(btnHeight + 10))
updateBtn.Text = "UPDATE ID"
updateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
updateBtn.TextColor3 = Color3.new(1, 1, 1)
updateBtn.TextSize = btnFontSize
updateBtn.Font = Enum.Font.GothamBold
updateBtn.AutoButtonColor = true

local btnCorner = Instance.new("UICorner", updateBtn)
btnCorner.CornerRadius = UDim.new(0, 6)

--- TOGGLE BUTTON ---
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 36, 0, 36)
toggleBtn.Position = UDim2.new(1, -46, 0.4, 0)
toggleBtn.Text = "\226\154\161"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Visible = false

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 8)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(0, 120, 255)
toggleStroke.Thickness = 1

--- CLOSE BUTTON ---
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold

local closeBtnCorner = Instance.new("UICorner", closeBtn)
closeBtnCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    toggleBtn.Visible = true
end)
closeBtn.TouchTap:Connect(function()
    mainFrame.Visible = false
    toggleBtn.Visible = true
end)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    toggleBtn.Visible = false
end)
toggleBtn.TouchTap:Connect(function()
    mainFrame.Visible = true
    toggleBtn.Visible = false
end)

--- UPDATE FUNCTION ---
local function doUpdate()
    if idInput.Text ~= "" then
        settings.SkillID = idInput.Text
        updateBtn.Text = "UPDATED!"
        task.wait(1)
        updateBtn.Text = "UPDATE ID"
    end
end

updateBtn.MouseButton1Click:Connect(doUpdate)
updateBtn.TouchTap:Connect(doUpdate)

--- COOLDOWN LABEL ---
local function getCooldownLabel(slotIndex)
    local PlayerGui = player:WaitForChild("PlayerGui")
    local mainGui = PlayerGui:FindFirstChild("GUI")
    if not mainGui then return nil end
    local label = nil
    local slotName = "\230\138\128\232\131\189" .. slotIndex 
    pcall(function()
        label = mainGui["\228\184\187\231\149\140\233\157\162"]["\230\138\128\232\131\189"]["\230\140\137\233\148\174"][slotName]["\230\140\137\233\146\174"]["\229\128\146\232\174\161\230\151\182"]
        if not label or label.Text == nil then
            label = mainGui["\228\184\187\231\149\140\233\157\162"]["\230\138\128\232\131\189"]["\232\167\166\230\145\184"][slotName]["\230\140\137\233\146\174"]["\229\128\146\232\174\161\230\151\182"]
        end
    end)
    return label
end

--- MAIN LOOP ---
local function startSkillCycle()
    print("Looping Skill Dimulai (Mobile + PC)...")
    while true do
        for slot = 1, 3 do
            for i = 1, 3 do unequipRemote:FireServer(i) end
            task.wait(0.2)
            if slot == 1 then
                equipRemote:FireServer(settings.SkillID)
            elseif slot == 2 then
                equipRemote:FireServer(settings.SkillID2)
                task.wait(0.1)
                equipRemote:FireServer(settings.SkillID)
            elseif slot == 3 then
                equipRemote:FireServer(settings.SkillID2)
                task.wait(0.1)
                equipRemote:FireServer(settings.SkillID3)
                task.wait(0.1)
                equipRemote:FireServer(settings.SkillID)
            end
            print("Slot " .. slot+1 .. " siap ("..settings.SkillID.."). Menunggu skill...")
            local cooldownLabel = getCooldownLabel(slot+1)
            if cooldownLabel then
                while cooldownLabel.Text == "" do
                    task.wait(0.1)
                end
                print("Teks terdeteksi di Slot " .. slot+1)
                print("Lanjut ke slot selanjutnya.")
            else
                task.wait(settings.DefaultDelay)
            end
            task.wait(0.2)
        end
    end
end

task.spawn(startSkillCycle)
