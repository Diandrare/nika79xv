local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Get data sync event
local dataSyncEvent = ReplicatedStorage
    ["\228\186\139\228\187\182"]          -- Event
    ["\229\174\162\230\136\183\231\171\175"] -- Client Module
    ["\229\174\162\230\136\183\231\171\175\233\152\181\230\179\149"] -- Rune Sync Controller
    ["\233\152\181\230\179\149\230\149\176\230\141\174\229\143\152\229\140\150"] -- Data Update Event

-- Favorite Rune Event
local eventFolder = ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\233\152\181\230\179\149")
local favoriteRuneEvent = eventFolder:WaitForChild("\230\148\182\232\151\143")
local deleteRuneEvent = eventFolder:WaitForChild("\229\135\186\229\148\174")

-- Add a table to keep track of runes we have already favorited
local favoritedRunes = {}

local runeType = {
    [1] = "Sun",
    [2] = "Tree",
    [3] = "Water",
    [4] = "Fire",
    [5] = "Earth",
}

-- Fungsi untuk print tabel secara cantik
local function dump(t)
    local s, r = pcall(function() return HttpService:JSONEncode(t) end)
    return s and r or "Tabel terlalu kompleks/besar"
end

local WEBHOOK_URL = 'https://discord.com/api/webhooks/1479205750126678126/E_YwMMsqQIBaBnBESgihGO3zKqFuS2rzK9R0KIP_pPWYsOWcfSfPo67bnWCHXZGTCiNd'

-- Function to send Discord webhook
local function sendDiscordWebhook(index, crit, hpr, bossDmg, gold, ats, critValue, runeType, dr)
    local data = {
        ["content"] = tostring(runeType) .. " - " .. tostring(crit) .. "CR - " .. tostring(critValue),
        ["embeds"] = {{
            ["title"] = "🌟 New Good Rune Found & Favorited! 🌟",
            ["description"] = "A rune meeting the criteria has been automatically favorited.",
            ["color"] = 16766720, -- Yellow color
            ["fields"] = {
                { ["name"] = "Rune Index", ["value"] = tostring(index), ["inline"] = false },
                { ["name"] = "Rune Type", ["value"] = tostring(runeType), ["inline"] = false },
                { ["name"] = "Critical Rate", ["value"] = tostring(crit), ["inline"] = true },
                { ["name"] = "Critical Value", ["value"] = tostring(critValue), ["inline"] = true },
                { ["name"] = "HP Recovery", ["value"] = tostring(hpr), ["inline"] = true },
                { ["name"] = "Boss Damage", ["value"] = tostring(bossDmg), ["inline"] = true },
                { ["name"] = "Extra Gold", ["value"] = tostring(gold), ["inline"] = true },
                { ["name"] = "ATS Boost", ["value"] = tostring(ats), ["inline"] = true },
                { ["name"] = "Dodge Rate", ["value"] = tostring(dr), ["inline"] = true }
            },
            ["footer"] = { ["text"] = "Rune Auto Favorite & Sell Script" }
        }}
    }

    local jsonData = game:GetService('HttpService'):JSONEncode(data)

    local success = pcall(function()
        local Request = syn and syn.request or http and http.request or request
        if Request then
            Request({
                Url = WEBHOOK_URL,
                Method = 'POST',
                Headers = { ['Content-Type'] = 'application/json' },
                Body = jsonData,
            })
        else
            warn("Request function not found (executor might not support http requests)")
        end
    end)
    return success
end

-- Fungsi untuk menghitung Peluang Kritikal (Critical Hit Rate)
function calculateCriticalRate(coefficient, quality)
    -- 1. Menghitung multiplier dasar dari Kualitas item
    local baseMultiplier = (0.4 * quality) - 1.6
    
    -- 2. Mengalikan koefisien dengan multiplier dasar
    local rawValue = coefficient * baseMultiplier
    
    -- 3. Membulatkan hasil ke 3 angka di belakang koma
    -- Ditambah 0.5 sebelum di-floor agar pembulatannya akurat secara matematis
    local finalValue = math.floor((rawValue * 1000) + 0.5) / 1000
    
    return finalValue
end

-- Bersihkan koneksi lama jika script dieksekusi ulang
if getgenv().SwiptRuneConnections then
    for _, conn in ipairs(getgenv().SwiptRuneConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
getgenv().SwiptRuneConnections = {}

-- Listen for data updates
local conn = dataSyncEvent.Event:Connect(function(data)
    if not getgenv().AutoRuneEnabled then return end
    
    local runesData = data["背包"] -- Backpack/Inventory
    local runesToSell = {}
    local sellCount = 0

    for _, rune in ipairs(runesData) do
        local index = rune["索引"] -- Index
        local runeTipe = tonumber(rune["类型"]) or 0 -- Type
        local attributes = rune["属性"] -- Attributes
        local isLocked = rune["锁定"] -- Often used for favorite/lock status, if available
        local quality = rune["品质"] -- Quality
        local typeRune = runeType[runeTipe] or "Unknown"

        local goldCount, critCount, expCount, HprCount, bossDamageCount, atsBoostCount, drCount = 0, 0, 0, 0, 0, 0, 0
        local crit = 0
        local hpr = 0
        local bossDmg = 0
        local gold = 0
        local ats = 0
        local dr = 0
        local attrMap = {}

        -- Count attributes
        for _, attr in ipairs(attributes) do
            local name = attr["名称"] -- Name
            local coef = attr["系数"] -- Coefficient
            -- print("Rune Attribute Name: " .. tostring(name))
            attrMap[name] = (attrMap[name] or 0) + 1
            if name == "金币额外获取" then -- Extra Gold Acquisition
                goldCount += 1
                -- print("Extra Gold +1")
            elseif name == "暴击概率" then -- Critical Hit Probability
                critCount += 1
                -- coef dikalikan 3.2 dan dibulatkan 3 angka dibelakang koma
                crit += calculateCriticalRate(coef, quality)
                -- print("Critical Rate +1")
            elseif name == "经验额外获取" then -- Extra EXP Acquisition
                expCount += 1
                -- print("Extra EXP +1")
            elseif name == "生命恢复百分比" then -- HP Recovery
                HprCount += 1
                -- print("HP Recovery +1")
            elseif string.find(name, "首领") or name == "Boss伤害" then -- Boss Damage
                bossDamageCount += 1
                -- print("Boss Damage +1")
            elseif name == "攻击速度百分比" then -- ATS Boost
                atsBoostCount += 1
                -- print("ATS Boost +1")
            elseif name == "闪避概率" then -- Dodge Rate
                drCount += 1
                -- print("Dodge Rate +1")
            end
        end

        -- Is Rune Good?
        local isGoodRune = (critCount >= 3) or (HprCount >= 3) or (bossDamageCount >= 3) or (atsBoostCount >= 4) or (drCount >= 4) or (goldCount >= 4)

        if isGoodRune then
            -- Auto Favorite Rune (Only run once per rune)
            if not favoritedRunes[index] and not isLocked then
                -- local args = {
                --     index -- using the rune's unique index
                -- }
                -- favoriteRuneEvent:FireServer(unpack(args))
                favoritedRunes[index] = true -- Mark as favorited so we don't spam
                
                -- Send Discord Webhook
                task.spawn(function()
                    pcall(function()
                        sendDiscordWebhook(index, critCount, HprCount, bossDamageCount, goldCount, atsBoostCount, crit, typeRune, drCount)
                    end)
                end)
            end
        else
            -- Add to Sell List if AutoSellEnabled is ON, not Locked, and not Nil
            if getgenv().AutoSellEnabled and not isLocked and index then
                runesToSell[index] = true
                sellCount = sellCount + 1
            end
        end
    end

    -- Process bulk sell/delete
    if sellCount > 0 then
        local args = {
            runesToSell
        }
        deleteRuneEvent:FireServer(unpack(args))
        print("Process completed, deleted " .. tostring(sellCount) .. " bad runes.")
    else
        print("Process completed, no runes to delete.")
    end
end)
table.insert(getgenv().SwiptRuneConnections, conn)

print("Auto rune processing script loaded - improved rules")
