-- Meme Sea Permanent Money Script with UI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Wait for leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local coin = leaderstats:FindFirstChild("Meme Coins") or leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Cash")

if not coin then
    warn("Could not find Coin variable!")
end

-- --- UI CONFIGURATION ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MemeSeaHacker"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Header.Parent = MainFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "HeaderLabel"
HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "Meme Sea Money"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font = Enum.Font.GothamBold
HeaderLabel.TextSize = 14
HeaderLabel.Parent = Header

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -10, 1, -40)
Content.Position = UDim2.new(0, 5, 0, 35)
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
MoneyLabel.Size = UDim2.new(1, 0, 0, 40)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "Coins: 0"
MoneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.TextSize = 16
MoneyLabel.Parent = Content

-- Timer Label
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Name = "TimerLabel"
TimerLabel.Size = UDim2.new(1, 0, 0, 20)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "Next update: 5s"
TimerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TimerLabel.Font = Enum.Font.Gotham
TimerLabel.TextSize = 12
TimerLabel.Parent = Content

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Hide/Show on Keybind (F8)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F8 then
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
    if coin then
        -- Force the value
        coin.Value = targetValue
        
        -- Update UI
        MoneyLabel.Text = "Coins: " .. formatNumber(coin.Value)
        TimerLabel.Text = "Next update: " .. countdown .. "s"
        countdown = countdown - 1
        
        if countdown <= 0 then
            countdown = updateInterval
        end
        
        -- Optional: Try to update DataStore for "permanent" feel
        pcall(function()
            local ds = game:GetService("DataStoreService"):GetDataStore("MemeSea_Coin_" .. player.UserId)
            ds:SetAsync("Balance", coin.Value)
        end)
    else
        StatusLabel.Text = "Status: Waiting for Coins..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end
