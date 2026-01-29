if not game:IsLoaded() then
    game.Loaded:Wait()
end

local currentGameId = game.PlaceId
local TARGET_GAME_ID = 18645473062

if currentGameId == TARGET_GAME_ID then
    print('检测到目标游戏，正在执行脚本...')
    
    -- Waiting PlayerGUI
    local player = game:GetService('Players').LocalPlayer
    repeat task.wait(1) until player:FindFirstChild('PlayerGui')
    
    -- #Start Redeem Code
    wait(2) -- Jeda After load the game
    local codes_list = {
        "ilovethisgame",
        "welcome",
        "30klikes",
        "40klikes",
        "halloween",
        "artistkapouki",
        "45klikes",
        "60klikes",
    }
    
    for i, code in ipairs(codes_list) do
        local args = { [1] = code }
        game:GetService("ReplicatedStorage"):WaitForChild("\228\186\139\228\187\182", 10)
            :WaitForChild("\229\133\172\231\148\168", 10)
            :WaitForChild("\230\191\128\230\180\187\231\160\129", 10)
            :WaitForChild("\231\142\169\229\174\182\229\133\145\230\141\162\230\191\128\230\180\187\231\160\129", 10)
            :FireServer(unpack(args))
        warn("Mencoba klaim kode: " .. code)
        wait(1) -- Jeda Klaim
    end
    -- #End Redeem Code

    -- ... NVM GOT DELETE BY NIKAA. ...
    -- (MaybeThisNika)

    wait(0.5)
    -- ...
else
    warn('Current game is not the target game, script not running.')
end
