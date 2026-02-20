local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Konfigurasi Awal
local settings = {
    SkillID = 18, 
    SkillID2 = 1,
    SkillID3 = 2,
    DefaultDelay = 0.5,
    AutoSequence = false, -- Toggle untuk mode rotasi 1-27
    CurrentSeq = 1
}

-- Path Remote (Menggunakan string asli China agar lebih stabil di Mobile)
local skillPath = RS:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("技能")
local unequipRemote = skillPath:WaitForChild("卸下技能") -- \229\141\184\228\184\139\230\138\128\232\131\189
local equipRemote = skillPath:WaitForChild("装备技能") -- \232\163\133\229\164\135\230\138\128\232\131\189

--- UI SETUP ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillManagerUI"
screenGui.ResetOnSpawn = false 
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 160, 0, 130)
mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "SKILL AUTO FARM"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 13
title.Font = Enum.Font.GothamBold

local idInput = Instance.new("TextBox", mainFrame)
idInput.Size = UDim2.new(0.8, 0, 0, 25)
idInput.Position = UDim2.new(0.1, 0, 0.25, 0)
idInput.PlaceholderText = "Input ID (1-27)"
idInput.Text = tostring(settings.SkillID)
idInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
idInput.TextColor3 = Color3.new(1, 1, 1)
idInput.TextScaled = true

local updateBtn = Instance.new("TextButton", mainFrame)
updateBtn.Size = UDim2.new(0.8, 0, 0, 25)
updateBtn.Position = UDim2.new(0.1, 0, 0.48, 0)
updateBtn.Text = "SET SINGLE ID"
updateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
updateBtn.TextColor3 = Color3.new(1, 1, 1)
updateBtn.Font = Enum.Font.GothamSemibold

local seqBtn = Instance.new("TextButton", mainFrame)
seqBtn.Size = UDim2.new(0.8, 0, 0, 25)
seqBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
seqBtn.Text = "MODE: SINGLE"
seqBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
seqBtn.TextColor3 = Color3.new(1, 1, 1)
seqBtn.Font = Enum.Font.GothamSemibold

-- Fungsi Update ID (FIXED: Converts text to Number so the server accepts it)
updateBtn.MouseButton1Click:Connect(function()
    local numId = tonumber(idInput.Text)
    if numId then
        settings.SkillID = numId
        settings.AutoSequence = false
        seqBtn.Text = "MODE: SINGLE"
        updateBtn.Text = "ID SET TO " .. numId
        task.wait(1)
        updateBtn.Text = "SET SINGLE ID"
    else
        updateBtn.Text = "MUST BE NUMBER!"
        task.wait(1)
        updateBtn.Text = "SET SINGLE ID"
    end
end)

-- Fungsi Toggle Auto Sequence 1-27
seqBtn.MouseButton1Click:Connect(function()
    settings.AutoSequence = not settings.AutoSequence
    if settings.AutoSequence then
        seqBtn.Text = "MODE: SEQ 1-27"
        seqBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        seqBtn.Text = "MODE: SINGLE"
        seqBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
    end
end)

--- CUSTOM DRAG UNTUK MOBILE ---
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

--- FUNGSI PENCARI LABEL COOLDOWN ---
local function getCooldownLabel(slotIndex)
    local PlayerGui = player:WaitForChild("PlayerGui")
    local mainGui = PlayerGui:FindFirstChild("GUI")
    if not mainGui then return nil end

    local label = nil
    local slotName = "技能" .. slotIndex 

    pcall(function()
        label = mainGui["主界面"]["技能"]["按键"][slotName]["按钮"]["倒计时"]
        if not label or label.Text == nil then
            label = mainGui["主界面"]["技能"]["触摸"][slotName]["按钮"]["倒计时"]
        end
    end)
    return label
end

--- LOGIKA LOOPING UTAMA ---
local function startSkillCycle()
    print("Looping Skill Dimulai...")
    
    while true do
        for slot = 1, 3 do
            -- 1. SETUP SLOT (Equip Berantai)
            for i = 1, 3 do unequipRemote:FireServer(i) end
            task.wait(0.2)
            
            -- Tentukan ID yang akan dipakai
            local targetID = settings.SkillID
            if settings.AutoSequence then
                targetID = settings.CurrentSeq
                settings.CurrentSeq = settings.CurrentSeq + 1
                if settings.CurrentSeq > 27 then settings.CurrentSeq = 1 end -- Reset setelah 27
            end

            -- Eksekusi skill berdasarkan slot
            if slot == 1 then
                equipRemote:FireServer(targetID)
            elseif slot == 2 then
                equipRemote:FireServer(settings.SkillID2)
                task.wait(0.1)
                equipRemote:FireServer(targetID)
            elseif slot == 3 then
                equipRemote:FireServer(settings.SkillID2)
                task.wait(0.1)
                equipRemote:FireServer(settings.SkillID3)
                task.wait(0.1)
                equipRemote:FireServer(targetID)
            end
            
            print("Slot " .. slot+1 .. " siap (ID: "..targetID..").")

            -- 2. LOGIKA PAUSE & CHECK
            local cooldownLabel = getCooldownLabel(slot+1)
            
            if cooldownLabel then
                -- PAUSE: Menunggu sampai ada teks cooldown (Skill dipakai)
                while cooldownLabel.Text == "" do
                    task.wait(0.1)
                end
            else
                task.wait(settings.DefaultDelay)
            end
            
            task.wait(0.2)
        end
    end
end

-- Jalankan Script
task.spawn(startSkillCycle)
