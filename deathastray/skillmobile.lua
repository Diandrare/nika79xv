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
local skillPath = RS:WaitForChild("äº‹ä»¶"):WaitForChild("å…¬ç”¨"):WaitForChild("æŠ€èƒ½")
local unequipRemote = skillPath:WaitForChild("\229\141\184\228\184\139\230\138\128\232\131\189")
local equipRemote = skillPath:WaitForChild("\232\163\133\229\164\135\230\138\128\232\131\189")

--- UI SETUP SIMPLE ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "SkillManagerUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 150, 0, 100)
mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Agar bisa digeser di layar

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

--- FUNGSI PENCARI LABEL COOLDOWN ---
local function getCooldownLabel(slotIndex)
    local PlayerGui = player:WaitForChild("PlayerGui")
    local mainGui = PlayerGui:FindFirstChild("GUI")
    if not mainGui then return nil end

    local label = nil
    local slotName = "æŠ€èƒ½" .. slotIndex 

    pcall(function()
        label = mainGui["ä¸»ç•Œé¢"]["æŠ€èƒ½"]["æŒ‰é”®"][slotName]["æŒ‰é’®"]["å€’è®¡æ—¶"]
        if not label or label.Text == nil then
            label = mainGui["ä¸»ç•Œé¢"]["æŠ€èƒ½"]["è§¦æ‘¸"][slotName]["æŒ‰é’®"]["å€’è®¡æ—¶"]
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

                -- Jika kamu ingin menunggu cooldown habis sebelum pindah, 
                -- buka komentar (uncomment) bagian di bawah ini:
                -- while cooldownLabel.Text ~= "" do
                --     task.wait(0.1)
                -- end
                
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
