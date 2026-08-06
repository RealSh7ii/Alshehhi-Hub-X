-- Safe Global Environment Wrapper (Prevents getgenv nil errors everywhere)
local getgenv = (typeof(getgenv) == "function" and getgenv) or function() return _G end

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

-- Global Auto Farm States
getgenv().AutoWeight = false
getgenv().AutoPushups = false
getgenv().AutoSitups = false
getgenv().AutoPunch = false
getgenv().AutoHandstands = false

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
MainFrame.Size = UDim2.new(0.52, 0, 0.54, 0)
MainFrame.Position = UDim2.new(0.24, 0, 0.23, 0)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.15
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Parent = ScriptA

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
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
TitleText.Text = "Alshehhi Hub X  v1.0.0  |  Credits: Rashed Ahmed Alshehhi"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
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
Mini.TextColor3 = Color3.fromRGB(170, 170, 170)
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
Exit.TextColor3 = Color3.fromRGB(170, 170, 170)
Exit.TextSize = 15
Exit.Parent = TopBar

-- Top Bar Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 36)
Divider.BorderSizePixel = 0
Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Divider.Parent = MainFrame

-- Floating Open/Close Toggle Button ("A")
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenToggle"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ToggleBtn.Font = Enum.Font.Creepster
ToggleBtn.Text = "A"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 26
ToggleBtn.Visible = false
ToggleBtn.Parent = ScriptA

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 0, 0)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

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
	btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(20, 20, 20)
	btn.BackgroundTransparency = (i == 1) and 0.2 or 0.6
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = "  " .. name
	btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = i
	btn.Parent = Sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnStroke.Color = (i == 1) and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(50, 50, 50)
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
	headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	headerLabel.TextSize = 20
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerLabel.Parent = content

	tabButtons[name] = btn
	contentFrames[name] = content

	btn.MouseButton1Click:Connect(function()
		for _, frameName in ipairs(tabNames) do
			contentFrames[frameName].Visible = false
			tabButtons[frameName].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			tabButtons[frameName].BackgroundTransparency = 0.6
			tabButtons[frameName].TextColor3 = Color3.fromRGB(160, 160, 160)
			tabButtons[frameName]:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(50, 50, 50)
		end

		content.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		btn.BackgroundTransparency = 0.2
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(220, 40, 40)
	end)
end

-- 3. HOME TAB
local function setupHomeTab(homeFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "HomeScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = homeFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function createCard(name, order)
		local card = Instance.new("Frame")
		card.Name = name
		card.Size = UDim2.new(1, -6, 0, 42)
		card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		card.BackgroundTransparency = 0.3
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(45, 45, 45)
		stroke.Thickness = 1
		stroke.Parent = card

		return card
	end

	-- WalkSpeed Section
	local speedCard = createCard("SpeedCard", 1)
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
	speedLabel.Position = UDim2.new(0, 10, 0, 0)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Font = Enum.Font.SourceSansBold
	speedLabel.Text = "WalkSpeed:"
	speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	speedLabel.TextSize = 14
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.Parent = speedCard

	local speedBox = Instance.new("TextBox")
	speedBox.Name = "SpeedBox"
	speedBox.Size = UDim2.new(0.38, 0, 0.65, 0)
	speedBox.Position = UDim2.new(0.58, 0, 0.175, 0)
	speedBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	speedBox.Font = Enum.Font.SourceSansBold
	speedBox.PlaceholderText = "16"
	speedBox.Text = ""
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.TextSize = 13
	speedBox.Parent = speedCard

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 4)
	boxCorner.Parent = speedBox

	local currentSpeed = 16
	speedBox.FocusLost:Connect(function()
		local num = tonumber(speedBox.Text)
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
	local jumpCard = createCard("JumpCard", 2)
	local jumpLabel = Instance.new("TextLabel")
	jumpLabel.Size = UDim2.new(0.5, 0, 1, 0)
	jumpLabel.Position = UDim2.new(0, 10, 0, 0)
	jumpLabel.BackgroundTransparency = 1
	jumpLabel.Font = Enum.Font.SourceSansBold
	jumpLabel.Text = "Infinite Jump:"
	jumpLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	jumpLabel.TextSize = 14
	jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
	jumpLabel.Parent = jumpCard

	local jumpToggle = Instance.new("TextButton")
	jumpToggle.Name = "JumpToggle"
	jumpToggle.Size = UDim2.new(0.38, 0, 0.65, 0)
	jumpToggle.Position = UDim2.new(0.58, 0, 0.175, 0)
	jumpToggle.BackgroundColor3 = Color3.fromRGB(150, 35, 35)
	jumpToggle.Font = Enum.Font.SourceSansBold
	jumpToggle.Text = "OFF"
	jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	jumpToggle.TextSize = 13
	jumpToggle.Parent = jumpCard

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 4)
	toggleCorner.Parent = jumpToggle

	local infJumpEnabled = false
	jumpToggle.MouseButton1Click:Connect(function()
		infJumpEnabled = not infJumpEnabled
		if infJumpEnabled then
			jumpToggle.Text = "ON"
			jumpToggle.BackgroundColor3 = Color3.fromRGB(35, 150, 35)
		else
			jumpToggle.Text = "OFF"
			jumpToggle.BackgroundColor3 = Color3.fromRGB(150, 35, 35)
		end
	end)

	UserInputService.JumpRequest:Connect(function()
		if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	-- Character Size Scaling Section
	local sizeCard = createCard("SizeCard", 3)
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(0.5, 0, 1, 0)
	sizeLabel.Position = UDim2.new(0, 10, 0, 0)
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.Font = Enum.Font.SourceSansBold
	sizeLabel.Text = "Character Size Scale:"
	sizeLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	sizeLabel.TextSize = 14
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.Parent = sizeCard

	local sizeBox = Instance.new("TextBox")
	sizeBox.Name = "SizeBox"
	sizeBox.Size = UDim2.new(0.38, 0, 0.65, 0)
	sizeBox.Position = UDim2.new(0.58, 0, 0.175, 0)
	sizeBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	sizeBox.Font = Enum.Font.SourceSansBold
	sizeBox.PlaceholderText = "1 (Default)"
	sizeBox.Text = ""
	sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	sizeBox.TextSize = 13
	sizeBox.Parent = sizeCard

	local sizeBoxCorner = Instance.new("UICorner")
	sizeBoxCorner.CornerRadius = UDim.new(0, 4)
	sizeBoxCorner.Parent = sizeBox

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

	sizeBox.FocusLost:Connect(function()
		local num = tonumber(sizeBox.Text)
		if num and num > 0 then
			currentScale = num
			if LocalPlayer.Character then
				applyCharacterScale(LocalPlayer.Character, currentScale)
			end
		end
	end)

	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if sizeBox.Text ~= "" and tonumber(sizeBox.Text) then
			applyCharacterScale(char, currentScale)
		end
	end)

	-- Credits Section
	local creditsCard = createCard("CreditsCard", 4)
	creditsCard:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(180, 40, 40)

	local credText = Instance.new("TextLabel")
	credText.Size = UDim2.new(1, -20, 1, 0)
	credText.Position = UDim2.new(0, 10, 0, 0)
	credText.BackgroundTransparency = 1
	credText.Font = Enum.Font.SourceSansBold
	credText.Text = "Created by: Rashed Ahmed Alshehhi"
	credText.TextColor3 = Color3.fromRGB(255, 255, 255)
	credText.TextSize = 14
	credText.TextXAlignment = Enum.TextXAlignment.Center
	credText.Parent = creditsCard
end

setupHomeTab(contentFrames["Home"])

-- 4. MAIN TAB: Auto Farming Utilities (Weight, Pushups, Situps, Punch, Handstands)
local function setupMainTab(mainFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "MainScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function createFarmToggle(title, genvKey, order)
		local card = Instance.new("Frame")
		card.Name = genvKey .. "Card"
		card.Size = UDim2.new(1, -6, 0, 42)
		card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		card.BackgroundTransparency = 0.3
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(45, 45, 45)
		stroke.Thickness = 1
		stroke.Parent = card

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.5, 0, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSansBold
		label.Text = title .. ":"
		label.TextColor3 = Color3.fromRGB(240, 240, 240)
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = card

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Name = genvKey .. "Toggle"
		toggleBtn.Size = UDim2.new(0.38, 0, 0.65, 0)
		toggleBtn.Position = UDim2.new(0.58, 0, 0.175, 0)
		toggleBtn.BackgroundColor3 = getgenv()[genvKey] and Color3.fromRGB(35, 150, 35) or Color3.fromRGB(150, 35, 35)
		toggleBtn.Font = Enum.Font.SourceSansBold
		toggleBtn.Text = getgenv()[genvKey] and "ON" or "OFF"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleBtn.TextSize = 13
		toggleBtn.Parent = card

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 4)
		toggleCorner.Parent = toggleBtn

		toggleBtn.MouseButton1Click:Connect(function()
			getgenv()[genvKey] = not getgenv()[genvKey]
			if getgenv()[genvKey] then
				toggleBtn.Text = "ON"
				toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 150, 35)
			else
				toggleBtn.Text = "OFF"
				toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 35, 35)
			end
		end)
	end

	-- Create Farming Toggles
	createFarmToggle("Auto Farm Weight", "AutoWeight", 1)
	createFarmToggle("Auto Farm Pushups", "AutoPushups", 2)
	createFarmToggle("Auto Farm Situps", "AutoSitups", 3)
	createFarmToggle("Auto Farm Punch", "AutoPunch", 4)
	createFarmToggle("Auto Farm Handstands", "AutoHandstands", 5)
end

setupMainTab(contentFrames["Main"])

-- Auto Farm Background Execution Loop
task.spawn(function()
	while task.wait(0.1) do
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local backpack = LocalPlayer:FindFirstChild("Backpack")
			local event = LocalPlayer:FindFirstChild("muscleEvent") or game:GetService("ReplicatedStorage"):FindFirstChild("muscleEvent")

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

-- 5. STATUS TAB
local function setupStatusTab(statusFrame)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "StatusScroll"
	scroll.Size = UDim2.new(1, 0, 1, -32)
	scroll.Position = UDim2.new(0, 0, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
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
		card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		card.BackgroundTransparency = 0.3
		card.LayoutOrder = order
		card.Parent = scroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(45, 45, 45)
		stroke.Thickness = 1
		stroke.Parent = card

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ValueLabel"
		textLabel.Size = UDim2.new(1, -16, 1, 0)
		textLabel.Position = UDim2.new(0, 8, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
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
			local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
			pingLabel.Text = "Ping: " .. ping .. " ms"
		end
	end)

	local targetStats = {"Kills", "Strength", "Gems", "Rebirths", "Durability", "Agility", "Brawls"}
	local statLabels = {}

	for i, statName in ipairs(targetStats) do
		statLabels[statName] = createStatCard(statName .. "Card", statName .. ": 0", 10 + i)
	end

	local function findStatObject(statName)
		local targetLower = string.lower(statName)
		local locations = {
			LocalPlayer,
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

-- 6. Universal Dragging Function
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

-- 7. UI Window Controls
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
