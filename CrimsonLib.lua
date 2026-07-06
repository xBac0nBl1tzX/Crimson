--// CrimsonLib - Base GUI

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Crimson = {}

local Tab = {}
Tab.__index = Tab

local Tabs = {}
local CurrentTab = nil
-- Remove old GUI
pcall(function()
	local old = PlayerGui:FindFirstChild("CrimsonLib")
	if old then
		old:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrimsonLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Fix square bottom of topbar
local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(1, 0, 0, 12)
Fill.Position = UDim2.new(0, 0, 1, -12)
Fill.BackgroundColor3 = TopBar.BackgroundColor3
Fill.BorderSizePixel = 0
Fill.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🩸 CrimsonLib"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Button creator
local function CreateTopButton(text, xPos)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 28, 0, 28)
	Button.Position = UDim2.new(1, xPos, 0, 4)
	Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Button.BorderSizePixel = 0
	Button.Font = Enum.Font.GothamBold
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(255,255,255)
	Button.TextSize = 16

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	Button.Parent = TopBar

	return Button
end

local Minimize = CreateTopButton("—", -96)
local Maximize = CreateTopButton("□", -64)
local Close = CreateTopButton("✕", -32)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Color3.fromRGB(18,18,18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0,8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0,10)
SidebarPadding.Parent = Sidebar

-- Content Area
local Page = Instance.new("ScrollingFrame")
Page.Name = TabName
Page.Size = UDim2.new(1,0,1,0)
Page.CanvasSize = UDim2.new(0,0,0,0)
Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
Page.ScrollBarThickness = 6
Page.ScrollingDirection = Enum.ScrollingDirection.Y
Page.BackgroundTransparency = 1
Page.BorderSizePixel = 0
Page.Visible = false
Page.Parent = Content

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0,10)
ContentCorner.Parent = Content

print("CrimsonLib Base Loaded")

--// TopBar Dragging

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	TweenService:Create(
		Main,
		TweenInfo.new(0.05, Enum.EasingStyle.Linear),
		{
			Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		}
	):Play()
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

--// Window Controls

local TweenService = game:GetService("TweenService")

local NormalSize = Main.Size
local NormalPosition = Main.Position

local Maximized = false
local Minimized = false

local SavedContentSize = Content.Size

local TweenInfoWindow = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

-- Minimize
Minimize.MouseButton1Click:Connect(function()
	if Maximized then return end

	if not Minimized then
		Minimized = true

		Content.Visible = false
		Sidebar.Visible = false

		TweenService:Create(Main, TweenInfoWindow, {
			Size = UDim2.new(0, 650, 0, 36)
		}):Play()

	else
		Minimized = false

		TweenService:Create(Main, TweenInfoWindow, {
			Size = NormalSize
		}):Play()

		task.wait(0.25)

		Content.Visible = true
		Sidebar.Visible = true
	end
end)

-- Maximize / Restore
Maximize.MouseButton1Click:Connect(function()

	if Minimized then return end

	if not Maximized then
		Maximized = true

		NormalSize = Main.Size
		NormalPosition = Main.Position

		Maximize.Text = "❐"

		TweenService:Create(Main, TweenInfoWindow, {
			Size = UDim2.new(0.9,0,0.9,0),
			Position = UDim2.new(0.05,0,0.05,0)
		}):Play()

	else
		Maximized = false

		Maximize.Text = "□"

		TweenService:Create(Main, TweenInfoWindow, {
			Size = NormalSize,
			Position = NormalPosition
		}):Play()

	end
end)

-- Close
Close.MouseButton1Click:Connect(function()

	local Scale = Instance.new("UIScale")
	Scale.Parent = Main
	Scale.Scale = 1

	TweenService:Create(Scale, TweenInfo.new(
		0.2,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.In
	), {
		Scale = 0.8
	}):Play()

	TweenService:Create(Main, TweenInfo.new(
		0.2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	), {
		BackgroundTransparency = 1
	}):Play()

	task.wait(0.2)

	ScreenGui:Destroy()
end)

--// Top Button Animations

local function AnimateButton(Button)
	local Scale = Instance.new("UIScale")
	Scale.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Parent = Button
	Stroke.Color = Color3.fromRGB(170, 0, 30)
	Stroke.Thickness = 0
	Stroke.Transparency = 1

	local HoverInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local ClickInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function HoverIn()
		TweenService:Create(Button, HoverInfo, {
			BackgroundColor3 = Color3.fromRGB(170, 0, 30)
		}):Play()

		TweenService:Create(Scale, HoverInfo, {
			Scale = 1.08
		}):Play()

		TweenService:Create(Stroke, HoverInfo, {
			Transparency = 0,
			Thickness = 1.5
		}):Play()
	end

	local function HoverOut()
		TweenService:Create(Button, HoverInfo, {
			BackgroundColor3 = Color3.fromRGB(30,30,30)
		}):Play()

		TweenService:Create(Scale, HoverInfo, {
			Scale = 1
		}):Play()

		TweenService:Create(Stroke, HoverInfo, {
			Transparency = 1,
			Thickness = 0
		}):Play()
	end

	local function Click()
		local Down = TweenService:Create(Scale, ClickInfo, {
			Scale = 0.9
		})

		local Up = TweenService:Create(Scale, ClickInfo, {
			Scale = 1.08
		})

		Down:Play()
		Down.Completed:Wait()
		Up:Play()
	end

	Button.MouseEnter:Connect(HoverIn)
	Button.MouseLeave:Connect(HoverOut)

	Button.MouseButton1Down:Connect(Click)
end

AnimateButton(Minimize)
AnimateButton(Maximize)
AnimateButton(Close)

--// Splash Screen

function Crimson:CreateSplash(Settings)

	print("Splash called")

	local Text = Settings.Text or "Loading..."

	local Splash = Instance.new("Frame")
	Splash.Name = "Splash"
	Splash.Size = UDim2.new(1,0,1,0)
	Splash.Position = UDim2.new(0,0,0,0)
	Splash.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Splash.BorderSizePixel = 0
	Splash.ZIndex = 999
	Splash.Parent = ScreenGui

    print("Splash parented")

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1,0,1,0)
	Label.Position = UDim2.new(0,0,0,0)
	Label.Font = Enum.Font.GothamBold
	Label.Text = ""
	Label.TextSize = 32
	Label.TextColor3 = Color3.fromRGB(255,255,255)
	Label.TextStrokeTransparency = 0.7
	Label.ZIndex = 1000
	Label.Parent = Splash

	local Scale = Instance.new("UIScale")
	Scale.Scale = 0.95
	Scale.Parent = Label

	-- Fade in
	Splash.BackgroundTransparency = 1

	TweenService:Create(
		Splash,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{
			BackgroundTransparency = 0
		}
	):Play()

	TweenService:Create(
		Scale,
		TweenInfo.new(0.35, Enum.EasingStyle.Back),
		{
			Scale = 1
		}
	):Play()

	-- Typewriter (75ms per letter)
	for i = 1, #Text do
		Label.Text = string.sub(Text,1,i)
		task.wait(0.075)
	end

	task.wait(5)

	-- Fade out
	TweenService:Create(
		Splash,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad),
		{
			BackgroundTransparency = 1
		}
	):Play()

	TweenService:Create(
		Label,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad),
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	):Play()

	task.wait(0.4)

	Splash:Destroy()

end

--// Tab System

function Crimson:CreateTab(TabName)

	-- Sidebar Button
	local Button = Instance.new("TextButton")
	Button.Name = TabName
	Button.Size = UDim2.new(1, -16, 0, 36)
	Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Button.BorderSizePixel = 0
	Button.Text = TabName
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 16
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Parent = Sidebar

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0,8)
	ButtonCorner.Parent = Button

	-- Content Page
	local Page = Instance.new("Frame")
	Page.Name = TabName
	Page.Size = UDim2.new(1,0,1,0)
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = Content

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)
	
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,8)
	Layout.Parent = Page


	
	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,10)
	Padding.PaddingLeft = UDim.new(0,10)
	Padding.PaddingRight = UDim.new(0,10)
	Padding.Parent = Page

	-- First tab becomes active
	if not CurrentTab then
		CurrentTab = Page
		Page.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(170,0,30)
	end

	Button.MouseButton1Click:Connect(function()

		if CurrentTab then
			CurrentTab.Visible = false

			for _,v in ipairs(Sidebar:GetChildren()) do
				if v:IsA("TextButton") then
					v.BackgroundColor3 = Color3.fromRGB(25,25,25)
				end
			end
		end

		CurrentTab = Page
		Page.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(170,0,30)

	end)

	local NewTab = setmetatable({}, Tab)

NewTab.Page = Page
NewTab.Button = Button

table.insert(Tabs, NewTab)

return NewTab

end

function Tab:CreateButton(Settings)

	local Title = Settings.Title or "Button"
	local Callback = Settings.Callback or function() end

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,0,0,38)
	Button.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Button.BorderSizePixel = 0
	Button.Text = Title
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 16
	Button.TextColor3 = Color3.fromRGB(255,255,255)
	Button.Parent = self.Page

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	local Scale = Instance.new("UIScale")
	Scale.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Parent = Button
	Stroke.Color = Color3.fromRGB(170,0,30)
	Stroke.Thickness = 0
	Stroke.Transparency = 1

	local HoverInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local ClickInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, HoverInfo, {
			BackgroundColor3 = Color3.fromRGB(40,40,40)
		}):Play()

		TweenService:Create(Scale, HoverInfo, {
			Scale = 1.02
		}):Play()

		TweenService:Create(Stroke, HoverInfo, {
			Transparency = 0,
			Thickness = 1.5
		}):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, HoverInfo, {
			BackgroundColor3 = Color3.fromRGB(28,28,28)
		}):Play()

		TweenService:Create(Scale, HoverInfo, {
			Scale = 1
		}):Play()

		TweenService:Create(Stroke, HoverInfo, {
			Transparency = 1,
			Thickness = 0
		}):Play()
	end)

	Button.MouseButton1Down:Connect(function()
		local Down = TweenService:Create(Scale, ClickInfo, {
			Scale = 0.96
		})

		local Up = TweenService:Create(Scale, ClickInfo, {
			Scale = 1.02
		})

		Down:Play()
		Down.Completed:Wait()
		Up:Play()

		pcall(Callback)
	end)

	return Button

end

function Tab:CreateToggle(Settings)

	local Title = Settings.Title or "Toggle"
	local State = Settings.Default or false
	local Callback = Settings.Callback or function() end

	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1,0,0,38)
	Toggle.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Toggle.BorderSizePixel = 0
	Toggle.Text = ""
	Toggle.Parent = self.Page

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Toggle

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0,12,0,0)
	TitleLabel.Size = UDim2.new(1,-90,1,0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.new(1,1,1)
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Toggle

	local Status = Instance.new("TextLabel")
	Status.BackgroundTransparency = 1
	Status.AnchorPoint = Vector2.new(1,0)
	Status.Position = UDim2.new(1,-12,0,0)
	Status.Size = UDim2.new(0,60,1,0)
	Status.Font = Enum.Font.GothamBold
	Status.TextSize = 16
	Status.Parent = Toggle

	local function Update()
		if State then
			Status.Text = "ON"
			Status.TextColor3 = Color3.fromRGB(0,255,120)
		else
			Status.Text = "OFF"
			Status.TextColor3 = Color3.fromRGB(255,60,60)
		end
	end

	Update()

	Toggle.MouseButton1Click:Connect(function()
		State = not State
		Update()
		pcall(function()
			Callback(State)
		end)
	end)

	return Toggle

end

function Tab:CreateTextbox(Settings)

	local Title = Settings.Title or "Textbox"
	local Placeholder = Settings.Placeholder or "Type here..."
	local Callback = Settings.Callback or function() end

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1,0,0,68)
	Frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Frame.BorderSizePixel = 0
	Frame.Parent = self.Page

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Frame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0,12,0,6)
	TitleLabel.Size = UDim2.new(1,-24,0,18)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Color3.new(1,1,1)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Frame

	local Box = Instance.new("TextBox")
	Box.Position = UDim2.new(0,12,0,30)
	Box.Size = UDim2.new(1,-24,0,28)
	Box.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Box.BorderSizePixel = 0
	Box.ClearTextOnFocus = false
	Box.PlaceholderText = Placeholder
	Box.Text = ""
	Box.TextColor3 = Color3.new(1,1,1)
	Box.PlaceholderColor3 = Color3.fromRGB(150,150,150)
	Box.Font = Enum.Font.Gotham
	Box.TextSize = 15
	Box.Parent = Frame

	local BoxCorner = Instance.new("UICorner")
	BoxCorner.CornerRadius = UDim.new(0,6)
	BoxCorner.Parent = Box

	Box.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			pcall(function()
				Callback(Box.Text)
			end)
		end
	end)

	return Box

end

function Tab:CreateDropdown(Settings)

	local Title = Settings.Title or "Dropdown"
	local Options = Settings.Options or {}
	local Selected = Settings.Default or Options[1] or "None"
	local Callback = Settings.Callback or function() end

	local Open = false

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1,0,0,38)
	Holder.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Holder.BorderSizePixel = 0
	Holder.ClipsDescendants = true
	Holder.Parent = self.Page

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Holder

	local MainButton = Instance.new("TextButton")
	MainButton.Size = UDim2.new(1,0,0,38)
	MainButton.BackgroundTransparency = 1
	MainButton.Text = ""
	MainButton.Parent = Holder

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0,12,0,0)
	TitleLabel.Size = UDim2.new(0.5,0,1,0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Color3.new(1,1,1)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Holder

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Position = UDim2.new(0.5,0,0,0)
	ValueLabel.Size = UDim2.new(0.5,-12,1,0)
	ValueLabel.Font = Enum.Font.Gotham
	ValueLabel.Text = Selected.." ▼"
	ValueLabel.TextSize = 15
	ValueLabel.TextColor3 = Color3.fromRGB(220,220,220)
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = Holder

	local List = Instance.new("Frame")
	List.BackgroundTransparency = 1
	List.Position = UDim2.new(0,0,0,38)
	List.Size = UDim2.new(1,0,0,0)
	List.Parent = Holder

	local Layout = Instance.new("UIListLayout")
	Layout.Parent = List

	local function RefreshHeight()
		List.Size = UDim2.new(1,0,0,#Options*32)

		if Open then
			TweenService:Create(
				Holder,
				TweenInfo.new(0.2,Enum.EasingStyle.Quart),
				{
					Size = UDim2.new(1,0,0,38+(#Options*32))
				}
			):Play()
		else
			TweenService:Create(
				Holder,
				TweenInfo.new(0.2,Enum.EasingStyle.Quart),
				{
					Size = UDim2.new(1,0,0,38)
				}
			):Play()
		end
	end

	MainButton.MouseButton1Click:Connect(function()
		Open = not Open
		ValueLabel.Text = Selected .. (Open and " ▲" or " ▼")
		RefreshHeight()
	end)

	for _,Option in ipairs(Options) do

		local OptionButton = Instance.new("TextButton")
		OptionButton.Size = UDim2.new(1,0,0,32)
		OptionButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
		OptionButton.BorderSizePixel = 0
		OptionButton.Text = Option
		OptionButton.Font = Enum.Font.Gotham
		OptionButton.TextSize = 15
		OptionButton.TextColor3 = Color3.new(1,1,1)
		OptionButton.Parent = List

		local OC = Instance.new("UICorner")
		OC.CornerRadius = UDim.new(0,6)
		OC.Parent = OptionButton

		OptionButton.MouseButton1Click:Connect(function()

			Selected = Option
			ValueLabel.Text = Selected .. " ▼"

			Open = false
			RefreshHeight()

			pcall(function()
				Callback(Option)
			end)

		end)

	end

	RefreshHeight()

	return Holder

end

function Tab:CreateSlider(Settings)
	local Title = Settings.Title or "Slider"
	local Min = Settings.Min or 0
	local Max = Settings.Max or 100
	local Increment = Settings.Increment or 1
	local Value = Settings.Default or Min
	local Callback = Settings.Callback or function() end

	Value = math.clamp(Value, Min, Max)

	local Slider = {}

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1,0,0,60)
	Frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Frame.BorderSizePixel = 0
	Frame.Parent = self.Page

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Frame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0,12,0,6)
	TitleLabel.Size = UDim2.new(0.6,0,0,18)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.new(1,1,1)
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Frame

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Position = UDim2.new(0.6,0,0,6)
	ValueLabel.Size = UDim2.new(0.4,-12,0,18)
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextColor3 = Color3.fromRGB(220,220,220)
	ValueLabel.TextSize = 16
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = Frame

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(1,-24,0,8)
	Bar.Position = UDim2.new(0,12,0,38)
	Bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Bar.BorderSizePixel = 0
	Bar.Parent = Frame

	local BarCorner = Instance.new("UICorner")
	BarCorner.CornerRadius = UDim.new(1,0)
	BarCorner.Parent = Bar

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(0,0,1,0)
	Fill.BackgroundColor3 = Color3.fromRGB(170,0,30)
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1,0)
	FillCorner.Parent = Fill

	local Knob = Instance.new("TextButton")
	Knob.Size = UDim2.new(0,24,0,24)
	Knob.AnchorPoint = Vector2.new(0.5,0.5)
	Knob.Position = UDim2.new(0,0,0.5,0)
	Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Knob.Text = ""
	Knob.BorderSizePixel = 0
	Knob.AutoButtonColor = false
	Knob.Parent = Bar

	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1,0)
	KnobCorner.Parent = Knob

	local dragging = false
	local UIS = game:GetService("UserInputService")

	local function UpdateVisual()
		local percent = (Value - Min) / (Max - Min)
		Fill.Size = UDim2.new(percent,0,1,0)
		Knob.Position = UDim2.new(percent,0,0.5,0)
		ValueLabel.Text = tostring(Value)
	end

	local function SetValue(percent)
		percent = math.clamp(percent,0,1)

		local newValue = Min + ((Max-Min) * percent)
		newValue = math.floor(newValue / Increment + 0.5) * Increment
		newValue = math.clamp(newValue,Min,Max)

		if newValue ~= Value then
			Value = newValue
			UpdateVisual()
			pcall(function()
				Callback(Value)
			end)
		end
	end

	Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true

			local percent = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
			SetValue(percent)
		end
	end)

	Knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local percent = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
			SetValue(percent)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	function Slider:Set(NewValue)
		NewValue = math.clamp(NewValue,Min,Max)
		Value = NewValue
		UpdateVisual()
		pcall(function()
			Callback(Value)
		end)
	end

	function Slider:Get()
		return Value
	end

	UpdateVisual()

	return Slider
end

--// Notifications
local NotificationHolder = ScreenGui:FindFirstChild("NotificationHolder")

if not NotificationHolder then
	NotificationHolder = Instance.new("Frame")
	NotificationHolder.Name = "NotificationHolder"
	NotificationHolder.AnchorPoint = Vector2.new(1,0)
	NotificationHolder.Position = UDim2.new(1,-15,0,15)
	NotificationHolder.Size = UDim2.new(0,320,1,-30)
	NotificationHolder.BackgroundTransparency = 1
	NotificationHolder.Parent = ScreenGui

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,8)
	Layout.FillDirection = Enum.FillDirection.Vertical
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = NotificationHolder
end

function Crimson:CreateNotif(Settings)

	local Title = Settings.Title or "Notification"
	local Text = Settings.Text or ""
	local Duration = Settings.Duration or 3

	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(0,300,0,70)
	Notif.BackgroundColor3 = Color3.fromRGB(22,22,22)
	Notif.BorderSizePixel = 0
	Notif.ClipsDescendants = true
	Notif.Parent = NotificationHolder

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Notif

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(170,0,30)
	Stroke.Thickness = 2
	Stroke.Parent = Notif

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0,12,0,8)
	TitleLabel.Size = UDim2.new(1,-24,0,20)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.fromRGB(170,0,30)
	TitleLabel.TextSize = 17
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Notif

	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0,12,0,30)
	TextLabel.Size = UDim2.new(1,-24,0,32)
	TextLabel.Font = Enum.Font.Gotham
	TextLabel.Text = Text
	TextLabel.TextWrapped = true
	TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Top
	TextLabel.Parent = Notif

	local Scale = Instance.new("UIScale")
	Scale.Scale = 0.9
	Scale.Parent = Notif

	Notif.Position = UDim2.new(1,350,0,0)
	Notif.BackgroundTransparency = 1
	TitleLabel.TextTransparency = 1
	TextLabel.TextTransparency = 1
	Stroke.Transparency = 1

	TweenService:Create(
		Notif,
		TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0,0,0,0),
			BackgroundTransparency = 0
		}
	):Play()

	TweenService:Create(
		Scale,
		TweenInfo.new(0.25,Enum.EasingStyle.Back),
		{
			Scale = 1
		}
	):Play()

	TweenService:Create(
		TitleLabel,
		TweenInfo.new(0.25),
		{
			TextTransparency = 0
		}
	):Play()

	TweenService:Create(
		TextLabel,
		TweenInfo.new(0.25),
		{
			TextTransparency = 0
		}
	):Play()

	TweenService:Create(
		Stroke,
		TweenInfo.new(0.25),
		{
			Transparency = 0
		}
	):Play()

	task.delay(Duration,function()

		TweenService:Create(
			Notif,
			TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
			{
				Position = UDim2.new(1,350,0,0),
				BackgroundTransparency = 1
			}
		):Play()

		TweenService:Create(
			Scale,
			TweenInfo.new(0.25),
			{
				Scale = 0.9
			}
		):Play()

		TweenService:Create(
			TitleLabel,
			TweenInfo.new(0.25),
			{
				TextTransparency = 1
			}
		):Play()

		TweenService:Create(
			TextLabel,
			TweenInfo.new(0.25),
			{
				TextTransparency = 1
			}
		):Play()

		TweenService:Create(
			Stroke,
			TweenInfo.new(0.25),
			{
				Transparency = 1
			}
		):Play()

		task.wait(0.3)
		Notif:Destroy()

	end)

end

function Tab:CreateText(Settings)

	local Text = Settings.Text or "Text"

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,0,0,24)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = Text
	Label.TextSize = 15
	Label.TextColor3 = Color3.fromRGB(255,255,255)
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top
	Label.AutomaticSize = Enum.AutomaticSize.Y
	Label.Parent = self.Page

	return Label

end

function Tab:CreateSection(Settings)

	local Title = Settings.Title or "Section"

	local Section = Instance.new("Frame")
	Section.Size = UDim2.new(1,0,0,26)
	Section.BackgroundTransparency = 1
	Section.Parent = self.Page

	local LeftLine = Instance.new("Frame")
	LeftLine.Size = UDim2.new(0.3,-8,0,2)
	LeftLine.Position = UDim2.new(0,0,0.5,-1)
	LeftLine.BackgroundColor3 = Color3.fromRGB(170,0,30)
	LeftLine.BorderSizePixel = 0
	LeftLine.Parent = Section

	local RightLine = Instance.new("Frame")
	RightLine.Size = UDim2.new(0.3,-8,0,2)
	RightLine.AnchorPoint = Vector2.new(1,0)
	RightLine.Position = UDim2.new(1,0,0.5,-1)
	RightLine.BackgroundColor3 = Color3.fromRGB(170,0,30)
	RightLine.BorderSizePixel = 0
	RightLine.Parent = Section

	local Label = Instance.new("TextLabel")
	Label.AnchorPoint = Vector2.new(0.5,0.5)
	Label.Position = UDim2.new(0.5,0,0.5,0)
	Label.Size = UDim2.new(0.35,0,1,0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.GothamBold
	Label.Text = Title
	Label.TextSize = 16
	Label.TextColor3 = Color3.fromRGB(170,0,30)
	Label.Parent = Section

	return Section

end

return Crimson
