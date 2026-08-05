local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
	label.Size = UDim2.new(0.5, 0, 0.15, 0)
	label.Position = UDim2.new(0.02, 0, 0.02, 0)
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

-- 2. Universal Dragging Function
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

-- Apply drag functionality to both MainFrame and ToggleBtn
makeDraggable(MainFrame)
makeDraggable(ToggleBtn)

-- 3. UI Controls
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
