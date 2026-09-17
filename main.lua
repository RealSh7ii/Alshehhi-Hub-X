-- Meme Sea Money Script (Mobile Optimized)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Target PlayerData
local PlayerData = player:WaitForChild("PlayerData")
local moneyVar = PlayerData:WaitForChild("Money")
local totalMoneyVar = PlayerData:WaitForChild("Total_Money")

-- --- UI CONFIGURATION ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MemeSeaHacker"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 120) -- Smaller for mobile
MainFrame.Position = UDim2.new(0.5, -100, 0.1, 10) -- Top center by default
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.1
MainFrame.Parent = ScreenGui

-- Drag Handle (Top part of the frame)
local DragFrame = Instance.new("Frame")
DragFrame.Name = "DragFrame"
DragFrame.Size = UDim2.new(1, 0, 0, 25)
DragFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DragFrame.Parent = MainFrame

local DragLabel = Instance.new("TextLabel")
DragLabel.Name = "DragLabel"
DragLabel.Size = UDim2.new(1, 0, 1, 0)
DragLabel.BackgroundTransparency = 1
DragLabel.Text = "  Meme Sea Money"
DragLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DragLabel.Font = Enum.Font.GothamBold
DragLabel.TextSize = 14
DragLabel.Parent = DragFrame

-- Close Button (Right side of header)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = DragFrame

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -10, 1, -30)
Content.Position = UDim2.new(0, 5, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Active"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = Content

-- Money Label
local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Name = "MoneyLabel"
MoneyLabel.Size = UDim2.new(1, 0, 0, 30)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "Money: 0"
MoneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.TextSize = 14
MoneyLabel.Parent = Content

-- Timer Label
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Name = "TimerLabel"
TimerLabel.Size = UDim2.new(1, 0, 0, 20)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "Next: 5s"
TimerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TimerLabel.Font = Enum.Font.Gotham
TimerLabel.TextSize = 11
TimerLabel.Parent = Content

-- Mobile Drag Logic
local dragging = false
local dragInput
local dragStart
local startPos

MainFrame.InputChanged:Connect(function(input)
    if input.InputType == Enum.InputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

-- Close Button (Mobile Click)
CloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        ScreenGui:Destroy()
    end
end)

-- Hide/Show on Keybind (F8 or Volume Down)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F8 or input.KeyCode == Enum.KeyCode.VolumeDown then
        if ScreenGui.Enabled then
            ScreenGui.Enabled = false
        else
            ScreenGui.Enabled = true
        end
    end
end)

ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- --- LOGIC ---
local function formatNumber(num)
    if num >= 1000000000 then
        return string.format("%.2fB", num/1000000000)
    elseif num >= 1000000 then
        return string.format("%.2fM", num/1000000)
    elseif num >= 1000 then
        return string.format("%.2fK", num/1000)
    else
        return tostring(num)
    end
end

local targetValue = 999999999999
local updateInterval = 5
local countdown = updateInterval

while task.wait(1) do
    if moneyVar then
        moneyVar.Value = targetValue
    end
    if totalMoneyVar then
        totalMoneyVar.Value = targetValue
    end

    -- Update UI
    MoneyLabel.Text = "Money: " .. formatNumber(moneyVar.Value or 0)
    TimerLabel.Text = "Next: " .. countdown .. "s"
    countdown = countdown - 1
    
    if countdown <= 0 then
        countdown = updateInterval
    end
end
