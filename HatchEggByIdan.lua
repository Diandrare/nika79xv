local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = Players.LocalPlayer

-- =========================
-- Configuration Constants
-- =========================
local CONFIG = {
    MIN_EGG_COUNT = 1,              -- Minimum egg count (backpack has >= this value can hatch, set to 1 means hatch whenever there's an egg)
    HATCH_TIME = 600,               -- Hatch completion time (seconds)
    LAST_EGG_HATCH_TIME = 630,      -- Last egg hatch time (seconds, 10m 30s, used for forced opening when no data refresh)
    SERVER_REFRESH_INTERVAL = 5,   -- Server data refresh interval (seconds)
    MAIN_LOOP_INTERVAL = 1,         -- Main loop check interval (seconds)
    EGG_PLACE_WAIT_TIME = 2,        -- Wait time after placing an egg before checking progress (seconds)
    DEBUG_MODE = true,              -- Whether to enable debug output
}

-- =========================
-- Game Data Keys (Chinese -> English mapping)
-- =========================
local KEYS = {
    BACKPACK = '背包',
    INCUBATING = '孵化中',
    PROGRESS = '孵化进度',
    INDEX = '索引',
}

-- =========================
-- Helper 获取 RemoteEvent
-- =========================
local function getRemote(path)
    local current = ReplicatedStorage
    for _, name in ipairs(path) do
        current = current:WaitForChild(name)
    end
    return current
end

-- =========================
-- RemoteEvents
-- =========================
local remoteFetchServer = getRemote({
    '\228\186\139\228\187\182',
    '\229\133\172\231\148\168',
    '\229\174\160\231\137\169\232\155\139',
    '\230\148\182\232\151\143',
})
local remoteHatch = getRemote({
    '\228\186\139\228\187\182',
    '\229\133\172\231\148\168',
    '\229\174\160\231\137\169\232\155\139',
    '\229\188\128\229\144\175',
})
local remotePlaceEgg = getRemote({
    '\228\186\139\228\187\182',
    '\229\133\172\231\148\168',
    '\229\174\160\231\137\169\232\155\139',
    '\229\173\181\229\140\150',
})
local remoteReceiveData = getRemote({
    '\228\186\139\228\187\182',
    '\229\133\172\231\148\168',
    '\229\174\160\231\137\169\232\155\139',
    '\229\144\140\230\173\165',
})

-- =========================
-- Data Storage
-- =========================
local latestData = { [KEYS.BACKPACK] = {}, [KEYS.INCUBATING] = {} }

-- =========================
-- State Management
-- =========================
local lastHatchTime = 0      -- Last egg opening time
local lastPlaceTime = 0      -- Last egg placement time
local lastRefreshTime = 0    -- Last server data refresh time
local placeEggWaitTime = 0   -- Wait deadline after placing an egg
local lastEggPlaceTime = 0   -- Last egg placement time (used when backpack is empty)
local OPERATION_COOLDOWN = 0.5  -- Operation cooldown (seconds)
local scriptEnabled = true   -- Script running state
local scriptRunning = true    -- Global flag to stop loops on termination

-- =========================
-- Debug Output Functions
-- =========================
local function debugPrint(...)
    if CONFIG.DEBUG_MODE then
        print(...)
    end
end

-- =========================
-- Recursive Table Print (for debugging)
-- =========================
local function printTable(t, indent, seen)
    if not CONFIG.DEBUG_MODE then
        return
    end
    indent = indent or ''
    seen = seen or {}
    if seen[t] then
        print(indent .. tostring(t) .. ' : (Already printed)')
        return
    end
    seen[t] = true
    for k, v in pairs(t) do
        if type(v) == 'table' then
            print(indent .. tostring(k) .. ' : table')
            printTable(v, indent .. '    ', seen)
        else
            print(indent .. tostring(k) .. ' : ' .. tostring(v))
        end
    end
end

-- =========================
-- Safely Get Hatching Progress
-- =========================
local function getIncubatingProgress()
    local incubating = latestData[KEYS.INCUBATING]
    if incubating and type(incubating) == 'table' then
        return incubating[KEYS.PROGRESS] or 0
    end
    return 0
end

-- =========================
-- Safely Get Backpack Count
-- =========================
local function getBackpackCount()
    local backpack = latestData[KEYS.BACKPACK]
    return backpack and #backpack or 0
end

-- =========================
-- UI Helpers (Draggable)
-- =========================
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =========================
-- UI Creation (Compact, Draggable)
-- =========================
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'AutoHatchUI'
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

local MainFrame = Instance.new('Frame')
MainFrame.Name = 'MainFrame'
MainFrame.Size = UDim2.new(0.3, 0, 0.18, 0) -- Smaller size
MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

makeDraggable(MainFrame) -- Make it draggable

local UICorner = Instance.new('UICorner')
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new('TextLabel')
TitleLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
TitleLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = 'Auto Hatch Egg'
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = false
TitleLabel.TextSize = 8
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new('TextButton')
CloseButton.Size = UDim2.new(0.12, 0, 0.2, 0)
CloseButton.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = 'X'
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 8
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new('UICorner')
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local InfoLabel = Instance.new('TextLabel')
InfoLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
InfoLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextScaled = false
InfoLabel.TextSize = 8
InfoLabel.TextWrapped = true
InfoLabel.Text = 'Loading...'
InfoLabel.Parent = MainFrame

-- =========================
-- UI Event Listeners
-- =========================
CloseButton.MouseButton1Click:Connect(function()
    scriptRunning = false
    ScreenGui:Destroy()
end)

-- =========================
-- Update UI Display
-- =========================
local function updateUI()
    if not scriptRunning then return end
    
    local backpackCount = getBackpackCount()
    local incubatingProgress = getIncubatingProgress()
    local totalCount = backpackCount + (incubatingProgress > 0 and 1 or 0)
    local remainingTime = math.max(0, CONFIG.HATCH_TIME - incubatingProgress)
    
    local statusText = 'Backpack: %d | Total: %d\n'
    if not scriptEnabled then
        statusText = statusText .. 'SYSTEM DISABLED'
    elseif incubatingProgress > 0 then
        statusText = statusText .. 'Progress: %ds | Left: %ds'
        statusText = statusText:format(backpackCount, totalCount, incubatingProgress, remainingTime)
    else
        statusText = statusText .. 'Status: Waiting to Hatch'
        statusText = statusText:format(backpackCount, totalCount)
    end
    
    InfoLabel.Text = statusText
end

-- =========================
-- Initial Data Read from Memory
-- =========================
local function initializeData()
    local latestTable = nil
    local seenTables = {}
    for i, obj in ipairs(getgc(true)) do
        if type(obj) == 'table' then
            local incubating = rawget(obj, KEYS.INCUBATING)
            if incubating ~= nil then
                local address = tostring(obj)
                if not seenTables[address] then
                    seenTables[address] = true
                    latestTable = obj
                end
            end
        end
    end
    
    latestData[KEYS.BACKPACK] = latestTable and latestTable[KEYS.BACKPACK] or {}
    latestData[KEYS.INCUBATING] = latestTable and latestTable[KEYS.INCUBATING] or {}
    updateUI()
    
    debugPrint('===== Initial Backpack Data =====')
    printTable(latestData[KEYS.BACKPACK])
    debugPrint('===== Initial Incubating Data =====')
    printTable(latestData[KEYS.INCUBATING])
end

initializeData()

-- =========================
-- RemoteEvent Callback Update latestData
-- =========================
remoteReceiveData.OnClientEvent:Connect(function(data)
    if type(data) == 'table' then
        latestData[KEYS.BACKPACK] = type(data[KEYS.BACKPACK]) == 'table' and data[KEYS.BACKPACK] or {}
        latestData[KEYS.INCUBATING] = type(data[KEYS.INCUBATING]) == 'table' and data[KEYS.INCUBATING] or {}
        
        debugPrint('===== RemoteEvent Updated Backpack =====')
        printTable(latestData[KEYS.BACKPACK])
        debugPrint('===== RemoteEvent Updated Incubating =====')
        printTable(latestData[KEYS.INCUBATING])
        
        updateUI()
    end
end)

-- =========================
-- Randomly Select Backpack Egg to Hatch (only if not already hatching)
-- =========================
local function placeRandomEggIfNone()
    -- Check cooldown
    local currentTime = tick()
    if currentTime - lastPlaceTime < OPERATION_COOLDOWN then
        return
    end
    
    -- Check if already hatching
    if getIncubatingProgress() > 0 then
        return
    end
    
    local backpack = latestData[KEYS.BACKPACK] or {}
    if #backpack == 0 then
        return
    end
    
    -- Randomly select and place an egg
    local randomEgg = backpack[math.random(1, #backpack)]
    local isLastEgg = #backpack == 1  -- Is it the last egg?
    
    local success, err = pcall(function()
        remotePlaceEgg:FireServer(randomEgg[KEYS.INDEX])
    end)
    
    if success then
        lastPlaceTime = currentTime
        placeEggWaitTime = currentTime + CONFIG.EGG_PLACE_WAIT_TIME  -- Set wait deadline
        
        -- If it's the last egg, record placement time for timer-based opening
        if isLastEgg then
            lastEggPlaceTime = currentTime
            print('Placing random egg index:', randomEgg[KEYS.INDEX], '(Last egg) Waiting', CONFIG.EGG_PLACE_WAIT_TIME, 's to check progress, will force open in', CONFIG.LAST_EGG_HATCH_TIME, 's')
        else
            print('Placing random egg index:', randomEgg[KEYS.INDEX], 'Waiting', CONFIG.EGG_PLACE_WAIT_TIME, 's to check progress')
        end
    else
        warn('Failed to place egg:', err)
    end
end

-- =========================
-- Open Egg
-- =========================
local function hatchEgg()
    local currentTime = tick()
    if currentTime - lastHatchTime < OPERATION_COOLDOWN then
        print('[Hatch] On cooldown, remaining', OPERATION_COOLDOWN - (currentTime - lastHatchTime), 's')
        return
    end
    
    local incubatingProgress = getIncubatingProgress()
    print('[Hatch] Attempting to open egg. Progress:', incubatingProgress, 's, Requirement:', CONFIG.HATCH_TIME, 's')
    
    local success, err = pcall(function()
        remoteHatch:FireServer()
    end)
    
    if success then
        lastHatchTime = currentTime
        print('[Hatch] Success! Hatching complete, egg opened!')
        -- Brief delay after opening to allow server data update
        wait(0.5)
    else
        warn('[Hatch] Failed:', err)
    end
end

-- =========================
-- Force Refresh Server Data
-- =========================
local function refreshServerData()
    local currentTime = tick()
    if currentTime - lastRefreshTime < CONFIG.SERVER_REFRESH_INTERVAL then
        return
    end
    
    local backpack = latestData[KEYS.BACKPACK] or {}
    if #backpack == 0 then
        return
    end
    
    local randomEgg = backpack[math.random(1, #backpack)]
    local success, err = pcall(function()
        remoteFetchServer:FireServer(randomEgg[KEYS.INDEX])
    end)
    
    if success then
        lastRefreshTime = currentTime
        debugPrint('Forced server data refresh, egg index:', randomEgg[KEYS.INDEX])
    else
        warn('Failed to refresh server data:', err)
    end
end

-- =========================
-- Force Refresh Server Data Every N Seconds
-- =========================
spawn(function()
    while scriptRunning do
        wait(CONFIG.MAIN_LOOP_INTERVAL)
        if scriptEnabled then
            refreshServerData()
        end
    end
end)

-- =========================
-- Auto Hatch and Open Cycle
-- =========================
spawn(function()
    while scriptRunning do
        wait(CONFIG.MAIN_LOOP_INTERVAL)
        
        if scriptEnabled then
            local currentTime = tick()
        local backpackCount = getBackpackCount()
        local incubatingProgress = getIncubatingProgress()
        local hasIncubatingEgg = incubatingProgress > 0
        local remainingTime = math.max(0, CONFIG.HATCH_TIME - incubatingProgress)
        local totalEggCount = backpackCount + (hasIncubatingEgg and 1 or 0)
        local isLastEggSituation = backpackCount == 0 and hasIncubatingEgg  -- Last egg case: backpack empty and egg incubating
        
        -- If an egg was just placed, skip check for new egg within wait period (but hatching check remains)
        local isWaitingForUpdate = currentTime < placeEggWaitTime
        
        -- Debug output (every 10 seconds)
        if math.floor(currentTime) % 10 == 0 then
            local timeSinceLastEgg = isLastEggSituation and (currentTime - lastEggPlaceTime) or 0
            print(string.format('[MainLoop] Backpack:%d Progress:%ds Remaining:%ds Waiting:%s HasEgg:%s LastEgg:%s%s', 
                backpackCount, incubatingProgress, remainingTime, 
                tostring(isWaitingForUpdate), tostring(hasIncubatingEgg), tostring(isLastEggSituation),
                isLastEggSituation and string.format(' Elapsed:%ds', timeSinceLastEgg) or ''))
        end
        
        -- Prioritize hatching check (unaffected by wait period)
        if incubatingProgress >= CONFIG.HATCH_TIME then
            print('[MainLoop] Hatch completion detected! Opening egg. Progress:', incubatingProgress, '>=', CONFIG.HATCH_TIME)
            hatchEgg()
            lastEggPlaceTime = 0  -- Reset last egg timer
        -- If last egg case, use timer to decide if it's time to open (10m 30s)
        elseif isLastEggSituation and lastEggPlaceTime > 0 then
            local timeSinceLastEgg = currentTime - lastEggPlaceTime
            if timeSinceLastEgg >= CONFIG.LAST_EGG_HATCH_TIME then
                print('[MainLoop] Last egg timer reached! Forced opening. Elapsed:', timeSinceLastEgg, 's >=', CONFIG.LAST_EGG_HATCH_TIME, 's')
                hatchEgg()
                lastEggPlaceTime = 0  -- Reset last egg timer
            end
        -- If remaining time <= 0 but progress not updated, try opening (prevents data lag)
        elseif hasIncubatingEgg and remainingTime <= 0 and incubatingProgress > 0 then
            print('[MainLoop] Remaining time <= 0, forced hatch attempt! Progress:', incubatingProgress, 'Remaining:', remainingTime)
            hatchEgg()
            lastEggPlaceTime = 0  -- Reset last egg timer
        -- Check if hatching is possible (backpack has egg >= min count AND not currently hatching AND not in wait period)
        -- Note: only checks backpack count, so even 1 egg can be hatched
        elseif not isWaitingForUpdate and backpackCount >= CONFIG.MIN_EGG_COUNT and not hasIncubatingEgg then
            print('[MainLoop] Preparing to hatch, Backpack count:', backpackCount, 'Total eggs:', totalEggCount)
            placeRandomEggIfNone()
        end
        
        end
        -- Update UI
        updateUI()
    end
end)
