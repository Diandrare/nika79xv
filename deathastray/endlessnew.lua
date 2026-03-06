local RS = game:GetService("ReplicatedStorage")

local selectStage = RS
:FindFirstChild("\228\186\139\228\187\182")
:FindFirstChild("\229\133\172\231\148\168")
:FindFirstChild("\229\133\179\229\141\161")
:FindFirstChild("\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161")

local startBattle = RS
:FindFirstChild("\228\186\139\228\187\182")
:FindFirstChild("\229\133\172\231\148\168")
:FindFirstChild("\230\136\152\230\150\151")
:FindFirstChild("\230\155\180\230\150\176\229\141\143\229\138\169\231\155\174\230\160\135")

getgenv().AutoEndless = true

while getgenv().AutoEndless do

    pcall(function()
        selectStage:FireServer(127)
        task.wait(1)
        startBattle:FireServer()
    end)

    task.wait(5)

end
