-- Safe Global Environment Wrapper
local getgenv = (typeof(getgenv) == "function" and getgenv) or function() return _G end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy previous UI instances if re-executing
if PlayerGui:FindFirstChild("ScriptA") then
	PlayerGui.ScriptA:Destroy()
end

-- Global Auto Farm, Rebirth, Killer & Utility States
getgenv().AutoWeight = false
getgenv().AutoPushups = false
getgenv().AutoSitups = false
getgenv().AutoPunch = false
getgenv().AutoHandstands = false
getgenv().AutoWalk = false
getgenv().LockPosition = false
getgenv().AutoRebirth = false
getgenv().TargetRebirths = 0
getgenv().AutoKillAll = false
getgenv().OnlyKillOne = false
getgenv().KillWhitelist = {}

-- Color Palette Constants (Strictly Black & White)
local C_BLACK = Color3.fromRGB(0, 0, 0)
local C_DARK_BG = Color3.fromRGB(12, 12, 12)
local C_CARD_BG = Color3.fromRGB(22, 22, 22)
local C_BORDER = Color3.fromRGB(255, 255, 255)
local C_BORDER_DIM = Color3.fromRGB(80, 80, 80)
local C_WHITE = Color3.fromRGB(255, 255, 255)
local C_MUTED = Color3.fromRGB(150, 150, 150)

-- Helper Function: Abbreviate Large Numbers
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

-- Helper Function: Robust Recursive Stat Finder (Handles Subfolders & Partial Names)
local function findStatObject(statName)
	local targetLower = string.lower(statName)

	local function searchInstance(parent)
		for _, child in ipairs(parent:GetChildren()) do
			local childName = string.lower(child.Name)
			if (childName == targetLower or string.find(childName, targetLower)) and (child:IsA("ValueBase") or child:IsA("StringValue")) then
				return child
			end
			if #child:GetChildren() > 0 and not child:IsA("Player") then
				local found = searchInstance(child)
				if found then return found end
			end
		end
		return nil
	end

	-- Check standard priority locations first
	local priorityLocations = {
		LocalPlayer:FindFirstChild("leaderstats"),
		LocalPlayer:FindFirstChild("stats"),
		LocalPlayer:FindFirstChild("Stats"),
		LocalPlayer:FindFirstChild("Data"),
		LocalPlayer
	}

	for _, loc in ipairs(priorityLocations) do
		if loc then
			for _, child in ipairs(loc:GetChildren()) do
				local childName = string.lower(child.Name)
				if (childName == targetLower or string.find(childName, targetLower)) and (child:IsA("ValueBase") or child:IsA("StringValue")) then
					return child
				end
			end
		end
	end

	-- Fallback to deep recursive search
	return searchInstance(LocalPlayer)
end

local function getStatValue(statName)
	local statObj = findStatObject(statName)
	if statObj then
		return tonumber(statObj.Value) or 0
	end
	return 0
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
MainFrame.Size = UDim2.new(0.52, 0, 0.58, 0)
MainFrame.Position = UDim2.new(0.24, 0, 0.21, 0)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.05
MainFrame.BackgroundColor3 = C_DARK_BG
MainFrame.Parent = ScriptA

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = C_BORDER
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top Title Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(0.72, 0, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.SourceSansBold
TitleText.Text = "Alshehhi Hub X  v1.2.1  |  Credits: Rashed Ahmed Alshehhi"
TitleText.TextColor3 = C_WHITE
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TopBar

-- Minimize Button (-)
local Mini = Instance.new("TextButton")
Mini.Name = "Mini"
Mini.Size = UDim2.new(0, 30, 0, 30)
Mini.Position = UDim2.new(1, -68, 0, 3)
Mini.BackgroundTransparency = 1
Mini.Font = Enum.Font.SourceSansBold
Mini.Text = "—"
Mini.TextColor3 = C_MUTED
Mini.TextSize = 16
Mini.Parent = TopBar

-- Close Button (X)
local Exit = Instance.new("TextButton")
Exit.Name = "Exit"
Exit.Size = UDim2.new(0, 30, 0, 30)
Exit.Position = UDim2.new(1, -34, 0, 3)
Exit.BackgroundTransparency = 1
Exit.Font = Enum.Font.SourceSansBold
Exit.Text = "X"
Exit.TextColor3 = C_MUTED
Exit.TextSize = 15
Exit.Parent = TopBar

-- Top Bar Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 36)
Divider.BorderSizePixel = 0
Divider.BackgroundColor3 = C_BORDER_DIM
Divider.Parent = MainFrame

-- Floating Open/Close Toggle Button ("A")
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenToggle"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = C_BLACK
ToggleBtn.Font = Enum.Font.Creepster
ToggleBtn.Text = "A"
ToggleBtn.TextColor3 = C_WHITE
ToggleBtn.TextSize = 26
ToggleBtn.Visible = false
ToggleBtn.Parent = ScriptA

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- 2. Left Sidebar & Navigation Layout
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.24, 0, 1, -45)
Sidebar.Position = UDim2.new(0, 8, 0, 42)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

-- Right Content Container Frame
local Frames = Instance.new("Frame")
Frames.Name = "Frames"
Frames.Size = UDim2.new(0.73, -12, 1, -45)
Frames.Position = UDim2.new(0.25, 6, 0, 42)
Frames.BackgroundTransparency = 1
Frames.Parent = MainFrame

local tabNames = {"Home", "Main", "Rebirths", "Killer", "Crystal", "Status", "Soon"}
local tabButtons = {}
local contentFrames = {}

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Name = name .. "TabBtn"
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(35, 35, 35) or C_BLACK
	btn.BackgroundTransparency = (i == 1) and 0.2 or 0.6
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = "  " .. name
	btn.TextColor3 = (i == 1) and C_WHITE or C_MUTED
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = i
	btn.Parent = Sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Color = (i == 1) and C_WHITE or C_BORDER_DIM
	btnStroke.Thickness = 1
	btnStroke.Parent = btn

	local content = Instance.new("Frame")
	content.Name = name .. "Frame"
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Visible = (i == 1)
	content.Parent = Frames

	local headerLabel = Instance.new("TextLabel")
	headerLabel.Name = "HeaderLabel"
	headerLabel.Size = UDim2.new(1, 0, 0, 26)
	headerLabel.Position = UDim2.new(0, 0, 0, 0)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Font = Enum.Font.SourceSansBold
	headerLabel.Text = name
	headerLabel.TextColor3 = C_WHITE
	headerLabel.TextSize = 20
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerLabel.Parent = content

	tabButtons[name] = btn
	contentFrames[name] = content

	btn.MouseButton1Click:Connect(function()
		for _, frameName in ipairs(tabNames) do
			contentFrames[frameName].Visible = false
			tabButtons[frameName].BackgroundColor3 = C_BLACK
			tabButtons[frameName].BackgroundTransparency = 0.6
			tabButtons[frameName].TextColor3 = C_MUTED
			tabButtons[frameName]:FindFirstChildOfClass("UIStroke").Color = C_BORDER_DIM
		end

		content.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		btn.BackgroundTransparency = 0.2
		btn.TextColor3 = C_WHITE
		btn:FindFirstChildOfClass("UIStroke").Color = C_WHITE
	end)
end

-- Helper Function: B&W Toggle Switches
local function createToggleCard(parentScroll, title, initialValue, onToggleCallback, order)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.BackgroundColor3 = C_CARD_BG
	card.BackgroundTransparency = 0.2
	card.LayoutOrder = order
	card.Parent = parentScroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = C_BORDER_DIM
	stroke.Thickness = 1
	stroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.Text = title .. ":"
	label.TextColor3 = C_WHITE
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0.35, 0, 0.65, 0)
	toggleBtn.Position = UDim2.new(0.61, 0, 0.175, 0)
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.TextSize = 13
	toggleBtn.Parent = card

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 4)
	toggleCorner.Parent = toggleBtn

	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Thickness = 1
	toggleStroke.Parent = toggleBtn

	local active = initialValue

	local function updateStyle()
		if active then
			toggleBtn.Text = "ON"
			toggleBtn.BackgroundColor3 = C_WHITE
			toggleBtn.TextColor3 = C_BLACK
			toggleStroke.Color = C_WHITE
		else
			toggleBtn.Text = "OFF"
			toggleBtn.BackgroundColor3 = C_BLACK
			toggleBtn.TextColor3 = C_MUTED
			toggleStroke.Color = C_BORDER_DIM
		end
	end

	updateStyle()

	toggleBtn.MouseButton1Click:Connect(function()
		active = not active
		updateStyle()
		onToggleCallback(active)
	end)

	return card
end

-- 3. HOME TAB
local function setupHomeTab(homeFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "HomeScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C_BORDER_DIM
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = homeFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function createInputCard(title, placeholder, order, onFocusLost)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -6, 0, 42)
		card.BackgroundColor3 = C_CARD_BG
		card.BackgroundTransparency = 0.2
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = C_BORDER_DIM
		stroke.Thickness = 1
		stroke.Parent = card

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.55, 0, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSansBold
		label.Text = title .. ":"
		label.TextColor3 = C_WHITE
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = card

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0.35, 0, 0.65, 0)
		box.Position = UDim2.new(0.61, 0, 0.175, 0)
		box.BackgroundColor3 = C_BLACK
		box.Font = Enum.Font.SourceSansBold
		box.PlaceholderText = placeholder
		box.Text = ""
		box.TextColor3 = C_WHITE
		box.TextSize = 13
		box.Parent = card

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 4)
		boxCorner.Parent = box

		local boxStroke = Instance.new("UIStroke")
		boxStroke.Color = C_BORDER_DIM
		boxStroke.Thickness = 1
		boxStroke.Parent = box

		box.FocusLost:Connect(function()
			onFocusLost(box.Text)
		end)

		return box
	end

	-- WalkSpeed Section
	local currentSpeed = 16
	local speedBox = createInputCard("WalkSpeed", "16", 1, function(text)
		local num = tonumber(text)
		if num then
			currentSpeed = num
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
			end
		end
	end)

	RunService.Stepped:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			if speedBox.Text ~= "" and tonumber(speedBox.Text) then
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
			end
		end
	end)

	-- Infinite Jump Section
	local infJumpEnabled = false
	createToggleCard(scroll, "Infinite Jump", false, function(state)
		infJumpEnabled = state
	end, 2)

	UserInputService.JumpRequest:Connect(function()
		if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	-- Scale Character Size Section
	local currentScale = 1
	local function applyCharacterScale(character, targetScale)
		if not character or not targetScale then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local scaleNames = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale", "BodyTypeScale", "BodyProportionScale"}
			for _, scaleName in ipairs(scaleNames) do
				local val = humanoid:FindFirstChild(scaleName)
				if not val then
					val = Instance.new("NumberValue")
					val.Name = scaleName
					val.Parent = humanoid
				end
				val.Value = targetScale
			end
		end

		pcall(function()
			character:ScaleTo(targetScale)
		end)
	end

	createInputCard("Character Scale", "1 (Default)", 3, function(text)
		local num = tonumber(text)
		if num and num > 0 then
			currentScale = num
			if LocalPlayer.Character then
				applyCharacterScale(LocalPlayer.Character, currentScale)
			end
		end
	end)

	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		applyCharacterScale(char, currentScale)
	end)

	-- Credits Card
	local creditsCard = Instance.new("Frame")
	creditsCard.Size = UDim2.new(1, -6, 0, 42)
	creditsCard.BackgroundColor3 = C_CARD_BG
	creditsCard.BackgroundTransparency = 0.2
	creditsCard.LayoutOrder = 4
	creditsCard.Parent = scroll

	local credCorner = Instance.new("UICorner")
	credCorner.CornerRadius = UDim.new(0, 6)
	credCorner.Parent = creditsCard

	local credStroke = Instance.new("UIStroke")
	credStroke.Color = C_WHITE
	credStroke.Thickness = 1
	credStroke.Parent = creditsCard

	local credText = Instance.new("TextLabel")
	credText.Size = UDim2.new(1, -20, 1, 0)
	credText.Position = UDim2.new(0, 10, 0, 0)
	credText.BackgroundTransparency = 1
	credText.Font = Enum.Font.SourceSansBold
	credText.Text = "Created by: Rashed Ahmed Alshehhi"
	credText.TextColor3 = C_WHITE
	credText.TextSize = 14
	credText.TextXAlignment = Enum.TextXAlignment.Center
	credText.Parent = creditsCard
end

setupHomeTab(contentFrames["Home"])

-- 4. MAIN TAB: Auto Farming & Movement Utilities
local function setupMainTab(mainFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "MainScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C_BORDER_DIM
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	createToggleCard(scroll, "Auto Farm Weight", getgenv().AutoWeight, function(state) getgenv().AutoWeight = state end, 1)
	createToggleCard(scroll, "Auto Farm Pushups", getgenv().AutoPushups, function(state) getgenv().AutoPushups = state end, 2)
	createToggleCard(scroll, "Auto Farm Situps", getgenv().AutoSitups, function(state) getgenv().AutoSitups = state end, 3)
	createToggleCard(scroll, "Auto Farm Punch", getgenv().AutoPunch, function(state) getgenv().AutoPunch = state end, 4)
	createToggleCard(scroll, "Auto Farm Handstands", getgenv().AutoHandstands, function(state) getgenv().AutoHandstands = state end, 5)
	createToggleCard(scroll, "Auto Walk", getgenv().AutoWalk, function(state) getgenv().AutoWalk = state end, 6)
	createToggleCard(scroll, "Lock Position", getgenv().LockPosition, function(state) getgenv().LockPosition = state end, 7)
end

setupMainTab(contentFrames["Main"])

-- 5. REBIRTHS TAB: Auto Rebirth & Target System
local function setupRebirthsTab(rebirthFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "RebirthsScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C_BORDER_DIM
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = rebirthFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	-- Target Rebirths Input Card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.BackgroundColor3 = C_CARD_BG
	card.BackgroundTransparency = 0.2
	card.LayoutOrder = 1
	card.Parent = scroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = C_BORDER_DIM
	stroke.Thickness = 1
	stroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.Text = "Target Rebirths:"
	label.TextColor3 = C_WHITE
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.35, 0, 0.65, 0)
	box.Position = UDim2.new(0.61, 0, 0.175, 0)
	box.BackgroundColor3 = C_BLACK
	box.Font = Enum.Font.SourceSansBold
	box.PlaceholderText = "Infinite (0)"
	box.Text = ""
	box.TextColor3 = C_WHITE
	box.TextSize = 13
	box.Parent = card

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 4)
	boxCorner.Parent = box

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = C_BORDER_DIM
	boxStroke.Thickness = 1
	boxStroke.Parent = box

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		getgenv().TargetRebirths = num or 0
	end)

	-- Auto Rebirth Toggle
	createToggleCard(scroll, "Auto Rebirth", getgenv().AutoRebirth, function(state)
		getgenv().AutoRebirth = state
	end, 2)
end

setupRebirthsTab(contentFrames["Rebirths"])

-- 6. KILLER TAB: Auto Kill, Only 1 Person & Dynamic Whitelist
local function setupKillerTab(killerFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "KillerScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C_BORDER_DIM
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = killerFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	-- Auto Kill Toggle
	createToggleCard(scroll, "Auto Kill All", getgenv().AutoKillAll, function(state)
		getgenv().AutoKillAll = state
	end, 1)

	-- Only Kill 1 Person Toggle
	createToggleCard(scroll, "Only Kill 1 Person", getgenv().OnlyKillOne, function(state)
		getgenv().OnlyKillOne = state
	end, 2)

	-- Whitelist Section Header Card
	local headerCard = Instance.new("Frame")
	headerCard.Size = UDim2.new(1, -6, 0, 30)
	headerCard.BackgroundColor3 = C_CARD_BG
	headerCard.BackgroundTransparency = 0.2
	headerCard.LayoutOrder = 3
	headerCard.Parent = scroll

	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = UDim.new(0, 6)
	hCorner.Parent = headerCard

	local hStroke = Instance.new("UIStroke")
	hStroke.Color = C_BORDER_DIM
	hStroke.Thickness = 1
	hStroke.Parent = headerCard

	local hLabel = Instance.new("TextLabel")
	hLabel.Size = UDim2.new(1, -16, 1, 0)
	hLabel.Position = UDim2.new(0, 8, 0, 0)
	hLabel.BackgroundTransparency = 1
	hLabel.Font = Enum.Font.SourceSansBold
	hLabel.Text = "Player Whitelist (ON = Safe / Whitelisted):"
	hLabel.TextColor3 = C_WHITE
	hLabel.TextSize = 13
	hLabel.TextXAlignment = Enum.TextXAlignment.Left
	hLabel.Parent = headerCard

	-- Players List Container Frame
	local playerContainer = Instance.new("Frame")
	playerContainer.Size = UDim2.new(1, -6, 0, 180)
	playerContainer.BackgroundColor3 = C_CARD_BG
	playerContainer.BackgroundTransparency = 0.2
	playerContainer.LayoutOrder = 4
	playerContainer.Parent = scroll

	local pcCorner = Instance.new("UICorner")
	pcCorner.CornerRadius = UDim.new(0, 6)
	pcCorner.Parent = playerContainer

	local pcStroke = Instance.new("UIStroke")
	pcStroke.Color = C_BORDER_DIM
	pcStroke.Thickness = 1
	pcStroke.Parent = playerContainer

	local playerScroll = Instance.new("ScrollingFrame")
	playerScroll.Name = "PlayerListScroll"
	playerScroll.Size = UDim2.new(1, -8, 1, -8)
	playerScroll.Position = UDim2.new(0, 4, 0, 4)
	playerScroll.BackgroundTransparency = 1
	playerScroll.ScrollBarThickness = 3
	playerScroll.ScrollBarImageColor3 = C_BORDER_DIM
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	playerScroll.Parent = playerContainer

	local pListLayout = Instance.new("UIListLayout")
	pListLayout.Padding = UDim.new(0, 4)
	pListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pListLayout.Parent = playerScroll

	local function refreshPlayerList()
		for _, child in ipairs(playerScroll:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		local orderIdx = 1
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, -4, 0, 36)
				row.BackgroundColor3 = C_BLACK
				row.BackgroundTransparency = 0.4
				row.LayoutOrder = orderIdx
				row.Parent = playerScroll

				local rCorner = Instance.new("UICorner")
				rCorner.CornerRadius = UDim.new(0, 4)
				rCorner.Parent = row

				local rStroke = Instance.new("UIStroke")
				rStroke.Color = C_BORDER_DIM
				rStroke.Thickness = 1
				rStroke.Parent = row

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 8, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Font = Enum.Font.SourceSansBold
				nameLbl.Text = plr.Name
				nameLbl.TextColor3 = C_WHITE
				nameLbl.TextSize = 13
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.Parent = row

				local wlBtn = Instance.new("TextButton")
				wlBtn.Size = UDim2.new(0.32, 0, 0.7, 0)
				wlBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
				wlBtn.Font = Enum.Font.SourceSansBold
				wlBtn.TextSize = 12
				wlBtn.Parent = row

				local wCorner = Instance.new("UICorner")
				wCorner.CornerRadius = UDim.new(0, 4)
				wCorner.Parent = wlBtn

				local wStroke = Instance.new("UIStroke")
				wStroke.Thickness = 1
				wStroke.Parent = wlBtn

				local isWhitelisted = getgenv().KillWhitelist[plr.UserId] == true

				local function updateWlStyle()
					if isWhitelisted then
						wlBtn.Text = "WHITELISTED"
						wlBtn.BackgroundColor3 = C_WHITE
						wlBtn.TextColor3 = C_BLACK
						wStroke.Color = C_WHITE
					else
						wlBtn.Text = "TARGET"
						wlBtn.BackgroundColor3 = C_BLACK
						wlBtn.TextColor3 = C_MUTED
						wStroke.Color = C_BORDER_DIM
					end
				end

				updateWlStyle()

				wlBtn.MouseButton1Click:Connect(function()
					isWhitelisted = not isWhitelisted
					getgenv().KillWhitelist[plr.UserId] = isWhitelisted
					updateWlStyle()
				end)

				orderIdx += 1
			end
		end
	end

	refreshPlayerList()

	Players.PlayerAdded:Connect(refreshPlayerList)
	Players.PlayerRemoving:Connect(refreshPlayerList)
end

setupKillerTab(contentFrames["Killer"])

-- Background Execution Task (Farming Tools)
task.spawn(function()
	while task.wait(0.1) do
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local backpack = LocalPlayer:FindFirstChild("Backpack")
			local event = LocalPlayer:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")

			local farmMapping = {
				{State = getgenv().AutoWeight, Tool = "Weight"},
				{State = getgenv().AutoPushups, Tool = "Pushups"},
				{State = getgenv().AutoSitups, Tool = "Situps"},
				{State = getgenv().AutoPunch, Tool = "Punch"},
				{State = getgenv().AutoHandstands, Tool = "Handstands"}
			}

			for _, farm in ipairs(farmMapping) do
				if farm.State then
					pcall(function()
						local tool = char:FindFirstChild(farm.Tool) or (backpack and backpack:FindFirstChild(farm.Tool))
						if tool then
							if tool.Parent == backpack and hum then
								hum:EquipTool(tool)
							end
							tool:Activate()
						end
						if event then
							event:FireServer("rep")
						end
					end)
				end
			end
		end
	end
end)

-- Background Execution Task (Auto Rebirth clicking Players.LocalPlayer.PlayerGui.gameGui.rebirthMenu.confirmButton)
task.spawn(function()
	while task.wait(0.2) do
		if getgenv().AutoRebirth then
			pcall(function()
				local currentRebirths = getStatValue("Rebirths")
				local target = getgenv().TargetRebirths or 0

				if target > 0 and currentRebirths >= target then
					getgenv().AutoRebirth = false
					return
				end

				-- Target UI Button Path: Players.LocalPlayer.PlayerGui.gameGui.rebirthMenu.confirmButton
				local pGui = LocalPlayer:FindFirstChild("PlayerGui")
				local gameGui = pGui and pGui:FindFirstChild("gameGui")
				local rebirthMenu = gameGui and gameGui:FindFirstChild("rebirthMenu")
				local confirmButton = rebirthMenu and rebirthMenu:FindFirstChild("confirmButton")

				if confirmButton and typeof(firesignal) == "function" then
					firesignal(confirmButton.MouseButton1Click)
					firesignal(confirmButton.Activated)
				end

				-- Fallback Remote Events
				local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
				local rebirthRemote = ReplicatedStorage:FindFirstChild("rebirthEvent") 
					or ReplicatedStorage:FindFirstChild("RebirthEvent")
					or ReplicatedStorage:FindFirstChild("Rebirth")
					or (remotesFolder and (remotesFolder:FindFirstChild("Rebirth") or remotesFolder:FindFirstChild("rebirthEvent") or remotesFolder:FindFirstChild("RebirthEvent")))

				if rebirthRemote then
					if rebirthRemote:IsA("RemoteEvent") then
						rebirthRemote:FireServer()
					elseif rebirthRemote:IsA("RemoteFunction") then
						rebirthRemote:InvokeServer()
					end
				end
			end)
		end
	end
end)

-- Background Execution Task (Auto Kill System with Whitelist & Only 1 Person Mode)
task.spawn(function()
	while task.wait(0.2) do
		if getgenv().AutoKillAll then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local backpack = LocalPlayer:FindFirstChild("Backpack")
				local punchTool = char:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))

				if punchTool and punchTool.Parent == backpack and hum then
					hum:EquipTool(punchTool)
				end

				local targetPlayer = nil
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and not getgenv().KillWhitelist[plr.UserId] then
						local pChar = plr.Character
						if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChildOfClass("Humanoid") then
							local pHum = pChar:FindFirstChildOfClass("Humanoid")
							if pHum.Health > 0 then
								targetPlayer = plr
								break
							end
						end
					end
				end

				if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local targetRoot = targetPlayer.Character.HumanoidRootPart
					local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
					local myRoot = char.HumanoidRootPart

					myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
					myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

					if punchTool then
						pcall(function()
							punchTool:Activate()
						end)
					end

					local event = LocalPlayer:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")
					if event then
						pcall(function()
							event:FireServer("punch")
							event:FireServer("rep")
						end)
					end

					if targetHum.Health <= 0 then
						if getgenv().OnlyKillOne then
							getgenv().AutoKillAll = false
							getgenv().OnlyKillOne = false
							break
						end
					end
				end
			end
		end
	end
end)

-- Background Execution Task (Auto Walk)
RunService.RenderStepped:Connect(function()
	if getgenv().AutoWalk then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				hum:Move(Vector3.new(0, 0, -1), true)
			end
		end
	end
end)

-- Lock Position Execution
local lockedCFrame = nil

RunService.Stepped:Connect(function()
	if getgenv().LockPosition then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local root = char.HumanoidRootPart
			if not lockedCFrame then
				lockedCFrame = root.CFrame
			end
			root.CFrame = lockedCFrame
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	else
		lockedCFrame = nil
	end
end)

-- 7. STATUS TAB
local function setupStatusTab(statusFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "StatusScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C_BORDER_DIM
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
		card.Size = UDim2.new(1, -6, 0, 26)
		card.BackgroundColor3 = C_CARD_BG
		card.BackgroundTransparency = 0.2
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = C_BORDER_DIM
		stroke.Thickness = 1
		stroke.Parent = card

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ValueLabel"
		textLabel.Size = UDim2.new(1, -16, 1, 0)
		textLabel.Position = UDim2.new(0, 8, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = C_WHITE
		textLabel.TextSize = 13
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = initialText
		textLabel.Parent = card

		return textLabel
	end

	local fpsLabel = createStatCard("FPSCard", "FPS: --", 1)
	local pingLabel = createStatCard("PingCard", "Ping: -- ms", 2)
	createStatCard("AgeCard", "Account Age: " .. LocalPlayer.AccountAge .. " Days", 3)

	local frameCount = 0
	local lastTime = os.clock()
	RunService.RenderStepped:Connect(function()
		frameCount += 1
		local currentTime = os.clock()
		if currentTime - lastTime >= 1 then
			fpsLabel.Text = "FPS: " .. frameCount
			frameCount = 0
			lastTime = currentTime
			local ping = 0
			pcall(function()
				ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingLabel.Text = "Ping: " .. ping .. " ms"
		end
	end)

	local targetStats = {"Kills", "Strength", "Gems", "Rebirths", "Durability", "Agility", "Brawls"}
	local statLabels = {}

	for i, statName in ipairs(targetStats) do
		statLabels[statName] = createStatCard(statName .. "Card", statName .. ": 0", 10 + i)
	end

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

	LocalPlayer.ChildAdded:Connect(function()
		task.wait(0.5)
		initAllStats()
	end)
end

setupStatusTab(contentFrames["Status"])

-- 8. Universal Draggable Wrapper
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

-- 9. UI Controls
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
