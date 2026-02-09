local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- 等待界面加载完成
local GUI = PlayerGui:WaitForChild("GUI")
local BaseUI = GUI:WaitForChild("\229\159\186\231\161\128")
local TimeIndicator = BaseUI:WaitForChild("\229\128\146\232\174\161\230\151\182\230\161\134")

local requestTradeEvent = ReplicatedStorage
    ["\228\186\139\228\187\182"]
    ["\229\133\172\231\148\168"]
    ["\228\186\164\230\152\147"]
    :WaitForChild("\231\148\179\232\175\183\228\186\164\230\152\147")

local confirmTradeEvent = ReplicatedStorage
    :WaitForChild("\228\186\139\228\187\182")
    :WaitForChild("\229\133\172\231\148\168")
    :WaitForChild("\228\186\164\230\152\147")
    :WaitForChild("\233\148\129\229\174\154\228\186\164\230\152\147")

local running = true

local function waitForTradeUI()
  local startTime = tick()
  local maxWaitTime = 10
  while tick() - startTime < maxWaitTime and running do
      local success, tradeUI = pcall(function()
          return LocalPlayer.PlayerGui.GUI["\228\186\140\231\186\167\231\149\140\233\157\162"]["\228\186\164\230\152\147"]["\228\186\164\230\152\147\231\149\140\233\157\162"]
      end)
      if success and tradeUI and tradeUI.Visible then
          return true
      end
      wait(0.1)
  end
  return false
end

-- 创建监控界面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Auto Accept Trade Monitor"
if syn then syn.protect_gui(screenGui) end
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 120)
mainFrame.Position = UDim2.new(0, 10, 1, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 20)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.Text = "Auto Accept Trade System"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0.5, 0)
infoLabel.Position = UDim2.new(0.05, 0, 0.1, 20)
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextSize = 18
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.TextYAlignment = Enum.TextYAlignment.Center
local textStroke = Instance.new("UIStroke")
textStroke.Color = Color3.fromRGB(255, 0, 0)
textStroke.Thickness = 0.1
textStroke.Parent = infoLabel
infoLabel.Text = "Auto Accept Trade System\nStarting..."
infoLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.9, 0, 0.25, 0)
closeButton.Position = UDim2.new(0.05, 0, 0.7, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Text = "Close System"
closeButton.Parent = mainFrame

-- 窗口拖拽系统
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- 关闭功能
closeButton.MouseButton1Click:Connect(function()
    running = false
    screenGui:Destroy()
end)

coroutine.wrap(function()
    while running do
        if TimeIndicator.Visible then            -- 获取交易邀请信息
            -- local tradeInviteText = "idaaaaaN"
            -- pcall(function()
            --     tradeInviteText = LocalPlayer.PlayerGui.GUI["\229\159\186\231\161\128"]["\229\128\146\232\174\161\230\151\182\230\161\134"]["\232\131\140\230\153\175"]["\229\134\133\229\174\185"].Text
            -- end)
            -- local invitingPlayer = tradeInviteText:match("(.+) has invited you to trade")
            -- if invitingPlayer then
            --     print("收到交易邀请来自:", invitingPlayer)
            -- end

            -- 直接触发交易请求
            pcall(function()
                requestTradeEvent:FireServer()
            end)
            wait(1.5)

            -- 确认交易
            if waitForTradeUI() then
                local success = pcall(function()
                    confirmTradeEvent:FireServer(true)
                end)
                if success then
                    warn("Trade confirmation interface appeared within the specified time")
                end
            else
                warn("Trade confirmation interface did not appear within the specified time")
            end

            wait(1)
        else
            wait(0.1)
        end
    end
end)()
