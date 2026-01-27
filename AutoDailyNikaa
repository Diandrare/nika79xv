-- Automatic Daily Cultivator
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local currentGameId = game.PlaceId
local TARGET_GAME_ID = 18645473062
-- Webhook Idan
-- webhookURL = 'https://discord.com/api/webhooks/1427270496797589606/Wg1Lt11GaVxKwrl3vlQCVuG4WqcH2VRkOOrEENCn5I-DHYx5IiXmmxptyIkN81fx_WGP'
-- Webhook Lotta
-- webhookURL = 'https://discord.com/api/webhooks/1452786397013344368/BeCA4Q38NHGm0NKyxKW_pxr2HWDVo7vaWFOzDFRO3Ob1wT6XadkBU9XIw-kM3cIY4bP7'
-- Webhook Nikaa
webhookURL = 'https://discord.com/api/webhooks/1453756431625883801/5hsjq08TPxLyWCQw6KInIbHNOIi9Dv_co8RgNi9YqEJq9t8quaTx4V0LAEoGJc1jk62D'

if currentGameId == TARGET_GAME_ID then
    print('Target game detected, executing script...')

    -- Wait for player and player GUI to exist
    local player = game:GetService('Players').LocalPlayer
    while not player:FindFirstChild('PlayerGui') do
        task.wait(1)
    end
    local playerGui = player.PlayerGui

    -- Function to safely find the loading GUI
    local function findLoadingGui()
        local maxAttempts = 30
        for i = 1, maxAttempts do
            local success, gui = pcall(function()
                return playerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162']['\229\138\160\232\189\189\233\161\181\233\157\162']
            end)
            if success and gui then
                return gui
            end
            task.wait(0.5)
        end
        return nil
    end

    -- Main waiting logic
    local loadingGui = findLoadingGui()

    if loadingGui then
        print('Loading...')

        -- Wait for it to become visible if not already
        if not loadingGui.Visible then
            local visibleChanged = false
            local connection = loadingGui
                :GetPropertyChangedSignal('Visible')
                :Connect(function()
                    visibleChanged = true
                end)

            -- Timeout after 25 seconds if never becomes visible
            local startTime = os.time()
            while not visibleChanged and os.time() - startTime < 25 do
                task.wait(0.1)
            end
            connection:Disconnect()
        end

        -- Now wait for it to become invisible
        if loadingGui.Visible then
            print('Waiting Loading to disappear...')
            while loadingGui.Parent and loadingGui.Visible do
                loadingGui:GetPropertyChangedSignal('Visible'):Wait()
                task.wait(0.1)
            end
        end
    else
        warn('⚠️ No Loading Screen，Executing Script...')
    end

    print('✅ Loading Complete, Continue Executing Script...')
    local playerGui = game.Players.LocalPlayer.PlayerGui
    local DonationUI = playerGui.GUI:WaitForChild('二级界面'):WaitForChild('公会')
    local DonationEvent = game:GetService('ReplicatedStorage')
            :WaitForChild('\228\186\139\228\187\182' --[[Event]])
            :WaitForChild('\229\133\172\231\148\168' --[[Public/Common]])
            :WaitForChild('\229\133\172\228\188\154' --[[Guild]])
            :WaitForChild('\230\141\144\231\140\174')
    local DonateButton = DonationUI:WaitForChild('捐献')
            :WaitForChild('背景')
            :WaitForChild('按钮')
            :WaitForChild('确定按钮')
    local Guidename = 'Guild Name'
    local donationController = {
        enabled = true,
        interval = 0.5,
        maxAttempts = 3,
        currentAttempts = 0,
    }
    local donationFinished = false

    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local Players = game:GetService('Players')
    local player = Players.LocalPlayer
    local GUI = player.PlayerGui:WaitForChild('GUI')
    local function getHerbValue()
        local herbText = '0'
        pcall(function()
            herbText =
                GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\232\141\137\232\141\175']['\229\128\188' --[[Value]]].Text
        end)

        local cleanedHerbText =
            tostring(herbText):lower():gsub('%s+', ''):gsub(',', '')
        if cleanedHerbText:find('k') then
            local numStr = cleanedHerbText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000
        elseif cleanedHerbText:find('m') then
            local numStr = cleanedHerbText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000000
        else
            return tonumber(cleanedHerbText) or 0
        end
    end

    local function getOREValue()
        local OREText = '0'
        pcall(function()
            OREText =
                game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159\229\143\179']['\231\159\191\231\159\179']['\229\128\188' --[[Value]]].Text
        end)

        local cleanedOREText =
            tostring(OREText):lower():gsub('%s+', ''):gsub(',', '')
        if cleanedOREText:find('k') then
            local numStr = cleanedOREText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000
        elseif cleanedOREText:find('m') then
            local numStr = cleanedOREText:gsub('[^%d%.]', '')
            return (tonumber(numStr) or 0) * 1000000
        else
            return tonumber(cleanedOREText) or 0
        end
    end
    -- Start Guild Donation
    local function executeDonation()
        pcall(function()
            DonationEvent:FireServer()
        end)
    end

    local function updateGuildDisplay()
        local counterText = DonateButton:WaitForChild('次数').Text
        local remaining = tonumber(counterText:match('%d+')) or 0
        return remaining
    end

    local function toggleGuildUI(state)
        pcall(function()
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]].Visible = state
        end)
    end

    local function donationLoop()
        while donationController.enabled do
            local success, remaining = pcall(updateGuildDisplay)

            if success and remaining > 0 then
                executeDonation()
                donationController.currentAttempts = 0
            else
                donationController.currentAttempts += 1
            end

            if
                donationController.currentAttempts
                >= donationController.maxAttempts
            then
                warn('[System] Too many consecutive failures, automatically stopping')
                donationController.enabled = false
            end

            -- 如果捐献次数为 0，标记完成
            if success and remaining == 0 then
                donationController.enabled = false
            end

            task.wait(donationController.interval)
        end
        donationFinished = true
    end
    -- End Guild Donation
    -- Start Buy Herbs
    local herbController = {
        enabled = true,
        interval = 0.2,
        maxAttempts = 5,
        currentAttempts = 0,
        highCostMode = false,
    }
    local function countSubstring(str, pattern)
        return select(2, str:gsub(pattern, ''))
    end
    local function parseNumber(text)
        local str = tostring(text):lower():gsub('%s+', ''):gsub(',', '')
        local numStr = str:gsub('[^%d%.]', '')

        if countSubstring(numStr, '%.') > 1 then
            return 0
        end

        local multiplier = 1
        if str:find('k') then
            multiplier = 1000
        elseif str:find('m') then
            multiplier = 1000000
        end

        return (tonumber(numStr) or 0) * multiplier
    end
    local function getDiamond()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\184\187\231\149\140\233\157\162']['\228\184\187\229\159\142']['\232\180\167\229\184\129\229\140\186\229\159\159']['\233\146\187\231\159\179']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
        )
    end

    local function getGuildCoin()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]]['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151' --[[Shop]]]['\229\133\172\228\188\154\229\184\129']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
        )
    end

    local function getRefreshCost()
        return parseNumber(
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]]['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151' --[[Shop]]]['\229\136\183\230\150\176']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].Text
        )
    end

    -- 界面控制函数
    local price = 400
    local herbBuyFinished = false
    local function herbLoop()
        while herbController.enabled do
            -- 等待捐献完成
            if not donationFinished then
                task.wait(1)
                continue -- 跳过本轮，直到捐献完成
            end

            -- 第一次开始买草药时提示
            if not herbController.started then
                print('[System] 开始自动购买草药')
                herbController.started = true
            end

            local boughtAny = false
            local money = getDiamond()
            local guilditemlist =
                game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\229\133\172\228\188\154' --[[Guild]]]['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\229\149\134\229\186\151' --[[Shop]]]['\229\136\151\232\161\168']

            local function tryBuy(slotIndex)
                local item = guilditemlist:GetChildren()[slotIndex]
                if item and item:FindFirstChild('\230\140\137\233\146\174') then
                    local button = item['\230\140\137\233\146\174']
                    if
                        button['\229\186\147\229\173\152'].Text == '1 Left'
                        and button['\229\144\141\231\167\176'].Text
                            == 'Herb'
                    then
                        if money >= price then
                            game:GetService('ReplicatedStorage')['\228\186\139\228\187\182' --[[Event]]]['\229\133\172\231\148\168' --[[Public/Common]]]['\229\133\172\228\188\154' --[[Guild]]]['\229\133\145\230\141\162']
                                :FireServer(slotIndex - 2)
                            money = money - price
                            boughtAny = true
                            return true
                        else
                            warn(
                                '[草药购买] 货币不足，跳过槽位 '
                                    .. slotIndex
                            )
                        end
                    end
                end
                return false
            end

            -- 遍历所有槽位
            for i = 1, 18 do
                if not herbController.enabled then
                    break
                end
                tryBuy(i)
            end

            local refreshCost = getRefreshCost()
            local diamond = getDiamond()
            local guildCoin = getGuildCoin()

            -- 高成本模式
            if refreshCost > 7000 then
                if not herbController.highCostMode then
                    print(
                        '[System] Entering high cost mode, ending herb purchase task'
                    )
                    herbController.highCostMode = true
                    if not herbBuyFinished then
                        herbBuyFinished = true
                    end
                    herbController.enabled = false
                end
                toggleGuildUI(false)
                task.wait(0.5)
                break
            else
                herbController.highCostMode = false
            end

            -- 正常刷新
            if
                diamond > refreshCost
                and guildCoin >= 400
                and diamond >= 18000
            then
                pcall(function()
                    ReplicatedStorage['\228\186\139\228\187\182' --[[Event]]]['\229\174\162\230\136\183\231\171\175']['\229\174\162\230\136\183\231\171\175UI']['\230\137\147\229\188\128\229\133\172\228\188\154']
                        :Fire()
                    task.wait(0.5)
                    ReplicatedStorage['\228\186\139\228\187\182' --[[Event]]]['\229\133\172\231\148\168' --[[Public/Common]]]['\229\133\172\228\188\154' --[[Guild]]]['\229\136\183\230\150\176\229\133\172\228\188\154\229\149\134\229\186\151']
                        :FireServer()
                end)
                task.wait(1.5)
            else
                print(
                    '[Herb Purchase] Refresh conditions not met, ending purchase task'
                )
                if not herbBuyFinished then
                    herbBuyFinished = true
                    herbController.enabled = false
                end
                toggleGuildUI(false)
                task.wait(0.5)
            end
        end -- 关闭 while
    end -- 关闭 function
    -- End Buy Herbs
    -- Start Webhook Utilities
    local function sendWebhook()
        local valueText =
            game:GetService('Players').LocalPlayer.PlayerGui.GUI['\228\186\140\231\186\167\231\149\140\233\157\162' --[[Secondary Interface]]]['\228\184\187\232\167\146']['\232\131\140\230\153\175' --[[Background]]]['\229\143\179\228\190\167\231\149\140\233\157\162']['\232\163\133\229\164\135']['\232\167\146\232\137\178']['\231\190\189\230\160\184']['\230\140\137\233\146\174']['\229\128\188' --[[Value]]].text
        local Players = game:GetService('Players')
        local LocalPlayer = Players.LocalPlayer
            or Players:GetPropertyChangedSignal('LocalPlayer'):Wait()
        local RobloxUsername = LocalPlayer.Name
        local RobloxDisplayName = LocalPlayer.DisplayName
        local Request = syn and syn.request or http and http.request or request
        local soul = LocalPlayer["\229\128\188"]["\232\180\167\229\184\129"]["\233\173\130\231\129\181"]

        local success, response = pcall(function()
            wait(5)
            return Request({
                Url = webhookURL,
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json',
                },
                Body = game:GetService('HttpService'):JSONEncode({
                    content = RobloxUsername
                        .. ' | '
                        .. RobloxDisplayName
                        .. ' | '
                        .. valueText
                        .. ' Wing Core | '
                        .. getHerbValue()
                        .. ' Herbs | '
                        .. getOREValue()
                        .. ' Ore | '
                        .. soul.Value
                        .. ' Soul',
                }),
            })
        end)
    end
    -- End Webhook Utilities
    -- Start Gem Investment
    local function gemInvest()
        for i = 1, 3 do
            local args = { i }
            ReplicatedStorage['\228\186\139\228\187\182' --[[Event]]]['\229\133\172\231\148\168' --[[Public/Common]]]['\229\149\134\229\186\151' --[[Shop]]]['\233\147\182\232\161\140']['\233\162\134\229\143\150\231\144\134\232\180\162']
                :FireServer(unpack(args))
        end
        wait(2)
        for i = 1, 3 do
            local args = { i }
            ReplicatedStorage['\228\186\139\228\187\182' --[[Event]]]['\229\133\172\231\148\168' --[[Public/Common]]]['\229\149\134\229\186\151' --[[Shop]]]['\233\147\182\232\161\140']['\232\180\173\228\185\176\231\144\134\232\180\162']
                :FireServer(unpack(args))
        end
    end
    -- End Gem Investment

    -- End Function

    -- Create UI for Information
    local infoGui = Instance.new('ScreenGui', playerGui)
    infoGui.Name = 'CultivatorStatus'

    local frame = Instance.new('Frame', infoGui)
    frame.Size = UDim2.new(0, 175, 0, 40)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.2

    local label = Instance.new('TextLabel', frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    -- Text Color Red
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextSize = 22
    label.Font = Enum.Font.SourceSansSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    -- End UI for Information
    label.Text = "Claiming Mail"
    ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\231\166\187\231\186\191\229\165\150\229\138\177"):WaitForChild("\233\162\134\229\165\150"):FireServer()
    ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\233\130\174\228\187\182"):WaitForChild("\233\162\134\229\143\150\229\133\168\233\131\168\233\130\174\228\187\182"):FireServer()
    label.Text = "Claimed Mail"
    wait(0.5)
    label.Text = "Investing Gems"
    gemInvest()
    label.Text = "Gems Invested"
    wait(0.5)
    -- Collect Herbs
    label.Text = "Collecting Herbs..."
    for i = 1, 6 do
        local args = { [1] = i, [2] = nil }
        ReplicatedStorage['\228\186\139\228\187\182' --[[Event]]]['\229\133\172\231\148\168' --[[Public/Common]]]['\229\134\156\231\148\176' --[[Farmland]]]['\233\135\135\233\155\134']
            :FireServer(unpack(args))
        wait(0.1)
    end
    label.Text = "Herbs Collected"
    -- Collected Herbs
    toggleGuildUI(true)
    wait(0.5)
    label.Text = "Guild Contributing..."
    donationLoop()
    label.Text = "Contributed"
    -- Send Webhook but continue the script while sending
    task.spawn(function()
        sendWebhook()
    end)
    wait(0.5)
    label.Text = "Herbs Purchasing..."
    herbLoop()
    label.Text = "Herbs Purchased"
    -- #Start Redeem Code
    -- wait(1)
    -- local args = {
    -- 	"HappyNewYear"
    -- }
    -- game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\230\191\128\230\180\187\231\160\129"):WaitForChild("\231\142\169\229\174\182\229\133\145\230\141\162\230\191\128\230\180\187\231\160\129"):FireServer(unpack(args))
    -- #End Redeem Code
    -- #Start Buy Soul from Arena Shop and Event Shop
    -- for i = 1,7 do
    --     wait(0.1)
    --     local args = {
    --         11
    --     }
    --     game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\231\171\158\230\138\128\229\156\186"):WaitForChild("\232\180\173\228\185\176"):FireServer(unpack(args))
    -- end
    -- for i = 1,10 do
    --     wait(0.1)
    --     local args = {
    --         24
    --     }
    --     game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\232\138\130\230\151\165\230\180\187\229\138\168"):WaitForChild("\232\180\173\228\185\176"):FireServer(unpack(args))
    -- end
    -- #End Buy Soul from Arena Shop and Event Shop
    wait(0.5)
    label.Text = "Spin Wheel..."
    local event = ReplicatedStorage:FindFirstChild('打开转盘', true)
    if event and event:IsA('BindableEvent') then
        event:Fire('打開轉盤')
    end
    wait(0.5)
    local player = game:GetService("Players").LocalPlayer
    local targetUI = player.PlayerGui.GUI["\228\186\140\231\186\167\231\149\140\233\157\162"]["\230\138\189\229\165\150\232\189\172\231\155\152"]
    targetUI.Visible = false
    wait(1)
    for i = 1, 3 do
        ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\232\189\172\231\155\152"):WaitForChild("\230\138\189\229\165\150"):FireServer()
        wait(0.3)
        local args = {
        Vector2.new(513.1136474609375, 85.01416015625),
        5
        }
        ReplicatedStorage:WaitForChild("\228\186\139\228\187\182"):WaitForChild("\229\133\172\231\148\168"):WaitForChild("\232\189\172\231\155\152"):WaitForChild("\233\162\134\229\165\150"):FireServer(unpack(args))
        wait(0.3)
    end
    label.Text = "Spin Wheel Completed"
    wait(1)
    frame.Size = UDim2.new(0, 225, 0, 40)
    label.Text = "Daily Cultivator Completed"
    wait(30)
    infoGui:Destroy()
else
    warn('Current game is not the target game, script not running.')
end
