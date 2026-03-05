local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

print("--- [ MONITORING PET DATA STARTED ] ---")

-- Fungsi untuk print tabel secara cantik
local function dump(t)
    local s, r = pcall(function() return HttpService:JSONEncode(t) end)
    return s and r or "Tabel terlalu kompleks/besar"
end

-- Lokasi RemoteEvents berdasarkan gambar folder Anda
local petFolder = ReplicatedStorage:WaitForChild("事件"):WaitForChild("公用"):WaitForChild("宠物")
local syncGlobal = petFolder:WaitForChild("同步")
local syncSingle = petFolder:WaitForChild("同步单个宠物")

local minPoten = 1.20

-- Handler untuk menampilkan detail pet saat data masuk
local function handlePetData(data)
    if not getgenv().AutoPetEnabled then return end
    if type(data) ~= "table" then return end
    
    local function printPetInfo(pet, label)
        print(string.format("\n--- DETAIL PET (%s) ---", label))
        -- Nama pet (seperti Featherbat Kit) dan Index Unik
        print("ID Unik:", pet["索引"] or "N/A")
        print("Level:", pet["等级"] or 1)
        
        -- Menampilkan Potential (资质) seperti 217.053 (HP) dan 178.318 (ATK)
        if pet["资质"] then
            print(string.format("HP Potential: %.3f%%", (pet["资质"][1] or 0) * 100))
            print(string.format("ATK Potential: %.3f%%", (pet["资质"][2] or 0) * 100))
            local success, result = pcall(function()
                return HttpService:JSONEncode(pet["资质"])
            end)

            if success then
                print(result) -- Akan menampilkan isi tabel seperti {"id": "1", "等级": 1, ...}
            else
                print("Tabel terlalu kompleks untuk di-encode")
            end
            
            -- Auto Favorite Pet Jika Max Potential Coefficient > minPoten dan belum di-favorite (收藏 == false/nil)
            if type(pet["最大资质系数"]) == "table" and type(pet["最大资质系数"][2]) == "number" and pet["最大资质系数"][2] > minPoten then
                local isFavorited = pet["收藏"]
                if isFavorited then
                    print("⏭️ Pet " .. (pet["索引"] or "N/A") .. " sudah di-favorite, skip.")
                else
                    local petId = pet["索引"]
                    if petId then
                        print("⭐ Auto Favorite Pet:", petId, "| Max Potential Coefficient:", pet["最大资质系数"][2])
                        local args = {
                            petId
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\229\174\160\231\137\169"):WaitForChild("\230\148\182\232\151\143"):FireServer(unpack(args))
                    end
                end
            end
        end
        
        -- Menampilkan Innate/Talent (天赋)
        if pet["天赋"] then
            print("Innate/Talent:")
            for i, talent in ipairs(pet["天赋"]) do
                print(string.format("  [%d] %s (Koefisien: %.4f)", i, talent["名称"], talent["系数"]))
            end
        end
    end

    -- Cek Pet yang sedang dipakai (装备中)
    if data["装备中"] and type(data["装备中"]) == "table" then
        printPetInfo(data["装备中"], "EQUIPPED")
    end

    -- Cek Pet di tas (背包)
    if data["背包"] and #data["背包"] > 0 then
        local petsToSell = {}
        local sellCount = 0
        
        for _, pet in ipairs(data["背包"]) do
            printPetInfo(pet, "BACKPACK")
            
            -- Auto Sell Logic
            if getgenv().AutoSellEnabled then
                local isFavorited = pet["收藏"]
                
                -- Cek apakah pet lemah (tidak memenuhi minimal potential)
                local isWeak = true
                if type(pet["最大资质系数"]) == "table" and type(pet["最大资质系数"][2]) == "number" and pet["最大资质系数"][2] > minPoten then
                    isWeak = false
                end
                
                local petId = pet["索引"]
                -- Kalau pet lemah dan tidak di-lock/favorited, masukkan ke list jual
                if isWeak and not isFavorited and petId then
                    petsToSell[petId] = true
                    sellCount = sellCount + 1
                end
            end
        end
        
        if sellCount > 0 then
            print("🛑 Menjual " .. sellCount .. " pet otomatis...")
            local args = { petsToSell }
            game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\229\174\160\231\137\169"):WaitForChild("\229\135\186\229\148\174"):FireServer(unpack(args))
            print("✅ Selesai menjual " .. sellCount .. " pet.")
        end
    end
end

-- Bersihkan koneksi lama jika script dieksekusi ulang
if getgenv().SwiptPetConnections then
    for _, conn in ipairs(getgenv().SwiptPetConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
getgenv().SwiptPetConnections = {}

-- Monitor semua event masuk
for _, remote in pairs(petFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") then
        local conn = remote.OnClientEvent:Connect(function(...)
            local args = {...}
            -- local sampleDumpStr = dump(args)
            -- writefile("PetData_sample.txt", sampleDumpStr)
            print("------------------------------------------")
            print("🔥 DATA DARI REMOTE: " .. remote.Name)
            if remote.Name == "同步" or remote.Name == "同步单个宠物" then
                handlePetData(args[1])
            else
                print("Isi Data: " .. dump(args))
            end
            print("------------------------------------------")
        end)
        table.insert(getgenv().SwiptPetConnections, conn)
    end
end
