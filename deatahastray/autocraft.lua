if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- tunggu data player
local values = player:WaitForChild("值", 10)
if not values then
    warn("Folder 值 tidak ditemukan")
    return
end

local privileges = values:WaitForChild("特权", 10)
if not privileges then
    warn("Folder 特权 tidak ditemukan")
    return
end

-- unlock auto craft
local autoCraft = privileges:WaitForChild("自动炼制", 5)
local superCraft = privileges:WaitForChild("超级炼制", 5)

if autoCraft and superCraft then
    superCraft.Value = false
    autoCraft.Value = true
    print("✅ Auto Craft (Gamepass) berhasil diaktifkan")
else
    warn("❌ Auto Craft value tidak ditemukan")
end
