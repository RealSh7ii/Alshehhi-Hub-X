local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy previous UI instances if re-executing
if PlayerGui:FindFirstChild("ScriptA") then
	PlayerGui.ScriptA:Destroy()
end

-- Helper Function: Abbreviate Large Numbers (1K, 1.5M, 2B, etc.)
local function formatNumber(value)
	local num = tonumber(value)
	if not num then return tostring(value or 0) end

	local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}
	local absNum = math.abs(num)
	local tier = 1

	while absNum >= 1000 and tier < #suffixes do
		absNum /= 1000
		tier += 1
	end

	local sign = num < 0 and "-" or ""
	if tier == 1 then
		return sign .. tostring(math.floor(absNum))
	else
		local formatted = string.format("%.2f", absNum):gsub("%.?0+$", "")
		return sign .. formatted .. suffixes[tier]
	end
end

-- 1. ScreenGui Setup
local ScriptA = Instance.new("ScreenGui")
ScriptA.Name = "ScriptA"
ScriptA.Enabled = true
ScriptA.ResetOnSpawn = false
ScriptA.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScriptA.Parent = PlayerGui

-- Main UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.54, 0, 0.52, 0)
MainFrame.Position = UDim2.new(0.24, -11, 0.24, 4)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.2
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Parent = ScriptA

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local UIAspectRatio = Instance.new("UIAspectRatioConstraint")
UIAspectRatio.AspectRatio = 1.341
UIAspectRatio.Parent = MainFrame

-- Top Bar Divider
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, 0, 0, 2)
Frame.Position = UDim2.new(0, 0, 0.11, 0)
Frame.BorderSizePixel = 0
Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
Frame.Parent = MainFrame

-- Title Text
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(0.33, 0, 0.07, 0)
TextLabel.Position = UDim2.new(0.03, 0, 0.01, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Alshehhi Hub X | Version: 1.0.0"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextWrapped = true
TextLabel.Parent = MainFrame

local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
UITextSizeConstraint.MaxTextSize = 17
UITextSizeConstraint.Parent = TextLabel

-- Minimize Button (-)
local Mini = Instance.new("TextButton")
Mini.Name = "Mini"
Mini.Size = UDim2.new(0.07, 0, 0.08, 0)
Mini.Position = UDim2.new(0.84, 0, 0, 0)
Mini.BackgroundTransparency = 1
Mini.Font = Enum.Font.SourceSans
Mini.Text = "—"
Mini.TextColor3 = Color3.fromRGB(158, 158, 158)
Mini.TextScaled = true
Mini.Parent = MainFrame

-- Close Button (X)
local Exit = Instance.new("TextButton")
Exit.Name = "Exit"
Exit.Size = UDim2.new(0.07, 0, 0.08, 0)
Exit.Position = UDim2.new(0.91, 0, 0, 0)
Exit.BackgroundTransparency = 1
Exit.Font = Enum.Font.SourceSans
Exit.Text = "x"
Exit.TextColor3 = Color3.fromRGB(158, 158, 158)
Exit.TextScaled = true
Exit.Parent = MainFrame

-- Floating Toggle Button (Open/Close UI)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenToggle"
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Font = Enum.Font.Creepster
ToggleBtn.Text = "A"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 24
ToggleBtn.Visible = false
ToggleBtn.Parent = ScriptA

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.Parent = ToggleBtn

-- Content Container
local Frames = Instance.new("Frame")
Frames.Name = "Frames"
Frames.Size = UDim2.new(0.72, 0, 0.86, 0)
Frames.Position = UDim2.new(0.27, 0, 0.11, 0)
Frames.BackgroundTransparency = 1
Frames.Parent = MainFrame

-- Navigation Tabs Setup
local tabNames = {"Home", "Main", "Rebirths", "Killer", "Crystal", "Status", "Soon"}
local tabButtons = {}
local contentFrames = {}

local startY = 0.15
local ySpacing = 0.11

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.23, 0, 0.09, 0)
	btn.Position = UDim2.new(0.02, 0, startY + (i - 1) * ySpacing, 0)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BackgroundTransparency = 0.8
	btn.Font = Enum.Font.SourceSans
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = MainFrame

	local corner = Instance.new("UICorner")
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255, 0, 0)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.8
	stroke.Parent = btn

	local content = Instance.new("Frame")
	content.Name = name .. "Frame"
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Visible = (i == 1)
	content.Parent = Frames

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0.12, 0)
	label.Position = UDim2.new(0.02, 0, 0.01, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content

	tabButtons[name] = btn
	contentFrames[name] = content

	btn.MouseButton1Click:Connect(function()
		for _, frame in pairs(contentFrames) do
			frame.Visible = false
		end
		content.Visible = true
	end)
end

-- 2. STATUS TAB: Dynamic Formatted Player Stats Tracker
local function setupStatusTab(statusFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "StatusScroll"
	scroll.Size = UDim2.new(0.96, 0, 0.85, 0)
	scroll.Position = UDim2.new(0.02, 0, 0.13, 0)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = statusFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function createStatCard(name, initialText, order)
		local card = Instance.new("Frame")
		card.Name = name
		card.Size = UDim2.new(1, -6, 0, 24)
		card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		card.BackgroundTransparency = 0.4
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(50, 50, 50)
		stroke.Thickness = 1
		stroke.Parent = card

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ValueLabel"
		textLabel.Size = UDim2.new(1, -10, 1, 0)
		textLabel.Position = UDim2.new(0, 8, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = initialText
		textLabel.Parent = card

		return textLabel
	end

	-- Core System Stats
	local fpsLabel = createStatCard("FPSCard", "FPS: --", 1)
	local pingLabel = createStatCard("PingCard", "Ping: -- ms", 2)
	createStatCard("AgeCard", "Account Age: " .. LocalPlayer.AccountAge .. " Days", 3)

	-- Update FPS and Ping
	local frameCount = 0
	local lastTime = os.clock()
	RunService.RenderStepped:Connect(function()
		frameCount += 1
		local currentTime = os.clock()
		if currentTime - lastTime >= 1 then
			fpsLabel.Text = "FPS: " .. frameCount
			frameCount = 0
			lastTime = currentTime
			local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
			pingLabel.Text = "Ping: " .. ping .. " ms"
		end
	end)

	-- Stats list to auto-track
	local targetStats = {
		"Kills",
		"Strength",
		"Gems",
		"Rebirths",
		"Durability",
		"Agility",
		"Brawls"
	}

	local statLabels = {}

	for i, statName in ipairs(targetStats) do
		statLabels[statName] = createStatCard(statName .. "Card", statName .. ": 0", 10 + i)
	end

	-- Case-Insensitive Stat Searcher across LocalPlayer and leaderstats
	local function findStatObject(statName)
		local targetLower = string.lower(statName)
		local locations = {
			LocalPlayer, -- Checked first for direct children like LocalPlayer.agility, LocalPlayer.gems, etc.
			LocalPlayer:FindFirstChild("leaderstats"),
			LocalPlayer:FindFirstChild("stats"),
			LocalPlayer:FindFirstChild("PrivateStats"),
			LocalPlayer:FindFirstChild("Data")
		}

		for _, loc in ipairs(locations) do
			if loc then
				for _, child in ipairs(loc:GetChildren()) do
					if string.lower(child.Name) == targetLower and (child:IsA("ValueBase") or child:IsA("StringValue")) then
						return child
					end
				end
			end
		end
		return nil
	end

	-- Bind values and update UI when stat values change
	local function bindStat(statName)
		local statObj = findStatObject(statName)
		local label = statLabels[statName]

		if statObj then
			label.Text = statName .. ": " .. formatNumber(statObj.Value)
			statObj:GetPropertyChangedSignal("Value"):Connect(function()
				label.Text = statName .. ": " .. formatNumber(statObj.Value)
			end)
		else
			label.Text = statName .. ": Not Found / 0"
		end
	end

	local function initAllStats()
		for _, statName in ipairs(targetStats) do
			bindStat(statName)
		end
	end

	task.spawn(initAllStats)

	-- Rescan if stat values or leaderstats load in late
	LocalPlayer.ChildAdded:Connect(function()
		task.wait(0.5)
		initAllStats()
	end)
end

setupStatusTab(contentFrames["Status"])

-- 3. Universal Dragging Function
local function makeDraggable(guiObject)
	local dragging = false
	local dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(MainFrame)
makeDraggable(ToggleBtn)

-- 4. UI Controls
Mini.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	ToggleBtn.Visible = false
end)

Exit.MouseButton1Click:Connect(function()
	ScriptA:Destroy()
end)
