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
local skillPath = RS:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("技能")
local unequipRemote = skillPath:WaitForChild("\229\141\184\228\184\139\230\138\128\232\131\189")
local equipRemote = skillPath:WaitForChild("\232\163\133\229\164\135\230\138\128\232\131\189")

--- UI SETUP SIMPLE ---
-- Menggunakan ResetOnSpawn = false agar UI tidak hilang saat mati
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkillManagerUI"
screenGui.ResetOnSpawn = false 
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 150, 0, 100)
mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
-- mainFrame.Draggable = true -- DIHAPUS: Tidak support mobile

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SKILL ID SETTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 12

local idInput = Instance.new("TextBox", mainFrame)
idInput.Size = UDim2.new(0.8, 0, 0, 30)
idInput.Position = UDim2.new(0.1, 0, 0.35, 0)
idInput.PlaceholderText = "ID Baru (9)"
idInput.Text = settings.SkillID
idInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
idInput.TextColor3 = Color3.new(1, 1, 1)

local updateBtn = Instance.new("TextButton", mainFrame)
updateBtn.Size = UDim2.new(0.8, 0, 0, 25)
updateBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
updateBtn.Text = "UPDATE ID"
updateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
updateBtn.TextColor3 = Color3.new(1, 1, 1)

-- Fungsi Update ID dari UI
updateBtn.MouseButton1Click:Connect(function()
    if idInput.Text ~= "" then
        settings.SkillID = idInput.Text
        updateBtn.Text = "UPDATED!"
        task.wait(1)
        updateBtn.Text = "UPDATE ID"
    end
end)

--- CUSTOM DRAG UNTUK MOBILE & PC ---
local dragging
local dragInput
local dragStart
local startPos

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
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
-------------------------------------

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
    print("Looping Skill Dimulai (UI Aktif)...")
    
    while true do
        for slot = 1, 3 do
            -- 1. SETUP SLOT (Equip Berantai)
            for i = 1, 3 do unequipRemote:FireServer(i) end
            task.wait(0.2)
            
            -- Menggunakan settings.SkillID yang bisa berubah via UI
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

            -- 2. LOGIKA PAUSE & CHECK
            local cooldownLabel = getCooldownLabel(slot+1)
            
            if cooldownLabel then
                -- PAUSE: Menunggu sampai ada teks cooldown (Skill dipakai)
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

-- Jalankan Script
task.spawn(startSkillCycle)
