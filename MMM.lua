-- Standalone Supabase Stat Sender
-- File: Supabase Stat Sender.lua

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    SUPABASE_URL = "https://jenqldfrbwzbnqkurwrm.supabase.co",
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplbnFsZGZyYnd6Ym5xa3Vyd3JtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODgzODkyNywiZXhwIjoyMDg0NDE0OTI3fQ.iQGIflsOWkorAm4Bs7k9Ho5PncsgP-5vVDUecAVq4EU",
    SYNC_INTERVAL = 60, -- Detik (Ganti sesuai keinginan, misal 60 detik)
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function parseNumber(text)
    local str = tostring(text):lower():gsub('%s+', ''):gsub(',', '')
    local numStr = str:gsub('[^%d%.]', '')
    if select(2, numStr:gsub('%.', '')) > 1 then return 0 end
    local multiplier = 1
    if str:find('k') then multiplier = 1000 elseif str:find('m') then multiplier = 1000000 end
    return (tonumber(numStr) or 0) * multiplier
end

local function getStat(pathTable)
    local current = LocalPlayer
    for _, name in ipairs(pathTable) do
        current = current:WaitForChild(name, 10)
        if not current then return nil end
    end
    return current
end

local function getGuildCoin()
    local success, coinText = pcall(function()
        return playerGui:WaitForChild('GUI')['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\133\172\228\188\154']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151']['\229\133\172\228\188\154\229\184\129']['\230\140\137\233\146\174']['\229\128\188'].Text
    end)
    return success and parseNumber(coinText) or 0
end

local statsMap = {
    Herb          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\232\141\137\232\141\175"}),
    Gold          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\135\145\229\184\129"}),
    Diamond       = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\146\187\231\159\179"}),
    WingCore      = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\190\189\230\160\184"}),
    PurpleDiamond = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\180\171\233\146\187"}),
    Ore           = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\159\191\231\159\179"}),
    WaterOfLife   = getStat({"\229\128\188", "\232\180\167\229\184\129", "\231\148\159\229\145\189\228\185\139\230\176\180"}),
    GuildName     = getStat({"\229\128\188", "\228\191\161\230\129\175", "\229\133\172\228\188\154\229\144\141\231\167\176"}),
    Soul          = getStat({"\229\128\188", "\232\180\167\229\184\129", "\233\173\130\231\129\181"})
}

-- ============================================================================
-- MAIN SENDER FUNCTION
-- ============================================================================

local function sendStats()
    print("🚀 [Stat Sender] Starting manual sync to Supabase...")
    
    local success, err = pcall(function()
        local Request = syn and syn.request or http and http.request or request
        if not Request then
            error("No HTTP Request function found (syn.request/http.request/request)")
        end

        -- Collect Data
        local wingCoreText = playerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\228\184\187\232\167\146']['\232\131\140\230\153\175']['\229\143\179\228\190\167\231\149\140\233\157\162']['\232\163\133\229\164\135']['\232\167\146\232\137\178']['\231\190\189\230\160\184']['\230\140\137\233\146\174']['\229\128\188'].text
        local levelText = playerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\231\173\137\231\186\167']['\230\140\137\233\146\174']['\229\155\190\230\160\135']['\231\173\137\231\186\167'].text
        
        local supabasePayload = {
            username = LocalPlayer.Name,
            name = LocalPlayer.DisplayName,
            user_id = LocalPlayer.UserId,
            guild = statsMap.GuildName and statsMap.GuildName.Value or "None",
            level = parseNumber(levelText),
            gold = statsMap.Gold and statsMap.Gold.Value or 0,
            wing_core = statsMap.WingCore and statsMap.WingCore.Value or 0,
            ore = statsMap.Ore and statsMap.Ore.Value or 0,
            herbs = statsMap.Herb and statsMap.Herb.Value or 0,
            soul = statsMap.Soul and statsMap.Soul.Value or 0,
            arena_point = statsMap.PurpleDiamond and statsMap.PurpleDiamond.Value or 0,
            guild_coin = getGuildCoin(),
            last_updated = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            owner_name = "idan"
        }

        local response = Request({
            Url = CONFIG.SUPABASE_URL .. "/rest/v1/account_stat?on_conflict=user_id",
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
                ['apikey'] = CONFIG.SUPABASE_KEY,
                ['Authorization'] = 'Bearer ' .. CONFIG.SUPABASE_KEY,
                ['Prefer'] = 'resolution=merge-duplicates'
            },
            Body = HttpService:JSONEncode(supabasePayload),
        })

        if response then
            print('--- Supabase Response ---')
            print('Status Code: ' .. tostring(response.StatusCode))
            print('Response Body: ' .. tostring(response.Body))
            
            if response.StatusCode == 201 or response.StatusCode == 200 or response.StatusCode == 204 then
                print('✅ [Stat Sender] Data synced successfully!')
            else
                warn('❌ [Stat Sender] Sync failed. Error Code: ' .. response.StatusCode)
            end
        else
            warn('❌ [Stat Sender] No response from Supabase')
        end
    end)

    if not success then
        warn("❌ [Stat Sender] Critical Error: " .. tostring(err))
    end
end

-- Run it in a loop
print("🔄 [Stat Sender] Loop started. Syncing every " .. CONFIG.SYNC_INTERVAL .. " seconds.")
while true do
    sendStats()
    task.wait(CONFIG.SYNC_INTERVAL)
end
