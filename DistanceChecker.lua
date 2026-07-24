--[[
	DistanceChecker.lua
	--------------------
	Client-side LocalScript.

	Put this in StarterPlayerScripts (or run it from a script executor).

	Three separate pieces:
	1. Input panel  - type two usernames (autocompletes on Enter / tap-away)
	2. Radar panel  - separate floating readout, ALWAYS visible, shows the
	                   live distance in studs and turns red/orange/green
	                   based on how close the two players are
	3. Minimized icon - a small square icon (like a floating app icon)
	                     that appears when you minimize the input panel;
	                     tap it to restore, drag it anywhere

	Notes:
	- Distance can only be measured for players currently in the same
	  server (it reads their Character's HumanoidRootPart position).
	- Autocomplete only suggests / fills names of players actually in
	  the game right now, and resolves on Enter or tap-away.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--=========================================================
-- Helpers
--=========================================================

local function new(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function getGuiParent()
	local ok, result = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and result then
		return result
	end
	return PlayerGui
end

--=========================================================
-- Proximity thresholds (studs)
--=========================================================

local CLOSE_DISTANCE = 15   -- red   : danger close
local MEDIUM_DISTANCE = 50  -- orange: getting near
-- anything farther than MEDIUM_DISTANCE = green

local COLOR_CLOSE = Color3.fromRGB(235, 80, 80)
local COLOR_MEDIUM = Color3.fromRGB(240, 170, 70)
local COLOR_FAR = Color3.fromRGB(110, 220, 140)
local COLOR_NEUTRAL = Color3.fromRGB(190, 190, 200)
local COLOR_ERROR = Color3.fromRGB(230, 120, 120)

--=========================================================
-- Layout constants
--=========================================================

local MOBILE = isMobile()

local WINDOW_WIDTH = MOBILE and 210 or 240
local TITLE_HEIGHT = 28
local PADDING = 8
local GAP = 6
local INPUT_CONTAINER_HEIGHT = 46

local BODY_CONTENT_HEIGHT = (INPUT_CONTAINER_HEIGHT * 2) + GAP
local WINDOW_HEIGHT = TITLE_HEIGHT + PADDING * 2 + BODY_CONTENT_HEIGHT

local ICON_SIZE = 50

local RADAR_WIDTH = MOBILE and 170 or 190
local RADAR_HEIGHT = 56

--=========================================================
-- Root GUI
--=========================================================

local guiParent = getGuiParent()

for _, container in ipairs({ PlayerGui, guiParent }) do
	local existing = container:FindFirstChild("DistanceCheckerGui")
	if existing then
		existing:Destroy()
	end
end

local screenGui = new("ScreenGui", {
	Name = "DistanceCheckerGui",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	Parent = guiParent,
})

--=========================================================
-- Shared: drag (with tap detection) + screen clamp
--=========================================================

local function clampToScreen(target)
	local screenSize = screenGui.AbsoluteSize
	if screenSize.X == 0 or screenSize.Y == 0 then
		return
	end

	local absPos = target.AbsolutePosition
	local absSize = target.AbsoluteSize
	local dx, dy = 0, 0

	if absPos.X < 0 then
		dx = -absPos.X
	elseif absPos.X + absSize.X > screenSize.X then
		dx = screenSize.X - (absPos.X + absSize.X)
	end

	if absPos.Y < 0 then
		dy = -absPos.Y
	elseif absPos.Y + absSize.Y > screenSize.Y then
		dy = screenSize.Y - (absPos.Y + absSize.Y)
	end

	if dx ~= 0 or dy ~= 0 then
		local pos = target.Position
		target.Position = UDim2.new(pos.X.Scale, pos.X.Offset + dx, pos.Y.Scale, pos.Y.Offset + dy)
	end
end

-- Makes `target` draggable via `handle`. If onTap is given, a press+release
-- with little to no movement counts as a tap and fires onTap() instead of
-- (or in addition to) a drag.
local function makeDraggable(handle, target, onTap)
	local dragging = false
	local dragStart, startPos
	local moved = false
	local TAP_TOLERANCE = 6

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					clampToScreen(target)
					if not moved and onTap then
						onTap()
					end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > TAP_TOLERANCE then
				moved = true
			end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--=========================================================
-- INPUT PANEL
--=========================================================

local mainFrame = new("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
	Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.3, 0),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.fromRGB(30, 30, 36),
	BorderSizePixel = 0,
	Parent = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })
new("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Parent = mainFrame })

local titleBar = new("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
	BackgroundColor3 = Color3.fromRGB(24, 24, 30),
	BorderSizePixel = 0,
	Parent = mainFrame,
})
new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = titleBar })
new("Frame", {
	Size = UDim2.new(1, 0, 0, 8),
	Position = UDim2.new(0, 0, 1, -8),
	BackgroundColor3 = Color3.fromRGB(24, 24, 30),
	BorderSizePixel = 0,
	ZIndex = titleBar.ZIndex,
	Parent = titleBar,
})

local titleLabel = new("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1,
	Text = "Distance Tracker",
	TextColor3 = Color3.fromRGB(235, 235, 240),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar,
})

local minimizeButton = new("TextButton", {
	Name = "MinimizeButton",
	Size = UDim2.new(0, 22, 0, 22),
	Position = UDim2.new(1, -52, 0.5, -11),
	BackgroundColor3 = Color3.fromRGB(50, 50, 60),
	Text = "-",
	TextColor3 = Color3.fromRGB(230, 230, 235),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = true,
	Parent = titleBar,
})
new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = minimizeButton })

local closeButton = new("TextButton", {
	Name = "CloseButton",
	Size = UDim2.new(0, 22, 0, 22),
	Position = UDim2.new(1, -26, 0.5, -11),
	BackgroundColor3 = Color3.fromRGB(120, 45, 45),
	Text = "X",
	TextColor3 = Color3.fromRGB(240, 235, 235),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = true,
	Parent = titleBar,
})
new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = closeButton })

local body = new("Frame", {
	Name = "Body",
	Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT),
	Position = UDim2.new(0, 0, 0, TITLE_HEIGHT),
	BackgroundTransparency = 1,
	Parent = mainFrame,
})
new("UIPadding", {
	PaddingTop = UDim.new(0, PADDING),
	PaddingBottom = UDim.new(0, PADDING),
	PaddingLeft = UDim.new(0, PADDING),
	PaddingRight = UDim.new(0, PADDING),
	Parent = body,
})
new("UIListLayout", {
	Padding = UDim.new(0, GAP),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = body,
})

local function buildPlayerInput(order, labelText)
	local container = new("Frame", {
		Name = labelText .. "Container",
		Size = UDim2.new(1, 0, 0, INPUT_CONTAINER_HEIGHT),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = body,
	})

	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		Text = labelText,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(170, 170, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local box = new("TextBox", {
		Name = "Input",
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 16),
		BackgroundColor3 = Color3.fromRGB(45, 45, 54),
		TextColor3 = Color3.fromRGB(240, 240, 245),
		PlaceholderText = "Username...",
		PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		ClearTextOnFocus = false,
		Text = "",
		ZIndex = 2,
		Parent = container,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box })
	new("UIStroke", { Color = Color3.fromRGB(65, 65, 75), Thickness = 1, Parent = box })

	local dropdown = new("Frame", {
		Name = "Dropdown",
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 46),
		BackgroundColor3 = Color3.fromRGB(40, 40, 48),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 5,
		Parent = container,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropdown })
	new("UIStroke", { Color = Color3.fromRGB(65, 65, 75), Thickness = 1, Parent = dropdown })
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdown })

	local ITEM_HEIGHT = 24
	local MAX_VISIBLE = 4

	local function clearDropdown()
		for _, child in ipairs(dropdown:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
	end

	local function hideDropdown()
		dropdown.Visible = false
		dropdown.Size = UDim2.new(1, 0, 0, 0)
	end

	local function getMatches(query)
		local lowerQuery = string.lower(query)
		local matches = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if string.sub(string.lower(plr.Name), 1, #lowerQuery) == lowerQuery then
				table.insert(matches, plr.Name)
			end
		end
		table.sort(matches)
		return matches
	end

	local function showMatches(query)
		clearDropdown()
		if query == "" then
			hideDropdown()
			return
		end

		local matches = getMatches(query)
		if #matches == 0 then
			hideDropdown()
			return
		end

		for i, name in ipairs(matches) do
			if i > MAX_VISIBLE then
				break
			end
			new("TextLabel", {
				Name = "Item_" .. name,
				Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
				BackgroundTransparency = 1,
				Text = "  " .. name,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.fromRGB(200, 200, 210),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				LayoutOrder = i,
				ZIndex = 6,
				Parent = dropdown,
			})
		end

		local visibleCount = math.min(#matches, MAX_VISIBLE)
		dropdown.Size = UDim2.new(1, 0, 0, visibleCount * ITEM_HEIGHT)
		dropdown.Visible = true
	end

	local function resolveAutocomplete()
		local text = box.Text
		if text == "" then
			return
		end

		local lowerText = string.lower(text)
		for _, plr in ipairs(Players:GetPlayers()) do
			if string.lower(plr.Name) == lowerText then
				box.Text = plr.Name
				return
			end
		end

		local matches = getMatches(text)
		if #matches > 0 then
			box.Text = matches[1]
		end
	end

	box:GetPropertyChangedSignal("Text"):Connect(function()
		showMatches(box.Text)
	end)
	box.Focused:Connect(function()
		showMatches(box.Text)
	end)
	box.FocusLost:Connect(function()
		hideDropdown()
		resolveAutocomplete()
	end)

	return box
end

local player1Box = buildPlayerInput(1, "Player 1")
local player2Box = buildPlayerInput(2, "Player 2")

makeDraggable(titleBar, mainFrame)

--=========================================================
-- MINIMIZED ICON (separate square, like a floating app icon)
--=========================================================

local minimizedIcon = new("TextButton", {
	Name = "MinimizedIcon",
	Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
	Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.3, 0),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.fromRGB(45, 95, 210),
	AutoButtonColor = false,
	Text = "",
	Visible = false,
	ZIndex = 10,
	Parent = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = minimizedIcon })
new("UIStroke", { Color = Color3.fromRGB(80, 140, 240), Thickness = 1.5, Parent = minimizedIcon })

new("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "DT",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Parent = minimizedIcon,
})

local iconStatusDot = new("Frame", {
	Name = "StatusDot",
	Size = UDim2.new(0, 10, 0, 10),
	Position = UDim2.new(1, -13, 1, -13),
	BackgroundColor3 = Color3.fromRGB(90, 90, 100),
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = minimizedIcon,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = iconStatusDot })
new("UIStroke", { Color = Color3.fromRGB(30, 30, 36), Thickness = 1.5, Parent = iconStatusDot })

--=========================================================
-- Minimize / restore logic
--=========================================================

local minimized = false

local function setMinimized(state)
	minimized = state
	if state then
		minimizedIcon.Position = mainFrame.Position
		mainFrame.Visible = false
		minimizedIcon.Visible = true
		clampToScreen(minimizedIcon)
	else
		mainFrame.Position = minimizedIcon.Position
		minimizedIcon.Visible = false
		mainFrame.Visible = true
		clampToScreen(mainFrame)
	end
end

minimizeButton.MouseButton1Click:Connect(function()
	setMinimized(true)
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

makeDraggable(minimizedIcon, minimizedIcon, function()
	setMinimized(false)
end)

--=========================================================
-- RADAR PANEL (separate floating readout, always visible)
--=========================================================

local radarFrame = new("Frame", {
	Name = "RadarFrame",
	Size = UDim2.new(0, RADAR_WIDTH, 0, RADAR_HEIGHT),
	Position = UDim2.new(1, -RADAR_WIDTH - 10, 0, 60),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Parent = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = radarFrame })
new("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Parent = radarFrame })

-- small drag grip at the top so it's obviously movable
local radarGrip = new("Frame", {
	Size = UDim2.new(0, 30, 0, 4),
	Position = UDim2.new(0.5, -15, 0, 6),
	BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	BorderSizePixel = 0,
	Parent = radarFrame,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = radarGrip })

local radarStatusDot = new("Frame", {
	Name = "StatusDot",
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0, 10, 0, 16),
	BackgroundColor3 = Color3.fromRGB(90, 90, 100),
	BorderSizePixel = 0,
	Parent = radarFrame,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = radarStatusDot })

local radarNamesLabel = new("TextLabel", {
	Size = UDim2.new(1, -26, 0, 14),
	Position = UDim2.new(0, 24, 0, 12),
	BackgroundTransparency = 1,
	Text = "No target set",
	TextColor3 = Color3.fromRGB(160, 160, 170),
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = radarFrame,
})

local radarDistanceLabel = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 26),
	Position = UDim2.new(0, 8, 0, 26),
	BackgroundTransparency = 1,
	Text = "-- studs",
	TextColor3 = COLOR_NEUTRAL,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = radarFrame,
})

makeDraggable(radarFrame, radarFrame)

--=========================================================
-- Live tracking loop
--=========================================================

local function findPlayerByName(name)
	local lowerName = string.lower(name)
	for _, plr in ipairs(Players:GetPlayers()) do
		if string.lower(plr.Name) == lowerName then
			return plr
		end
	end
	return nil
end

local function setStatus(active)
	local color = active and Color3.fromRGB(90, 220, 120) or Color3.fromRGB(90, 90, 100)
	radarStatusDot.BackgroundColor3 = color
	iconStatusDot.BackgroundColor3 = color
end

local function updateTracker()
	local name1 = player1Box.Text
	local name2 = player2Box.Text

	if name1 == "" or name2 == "" then
		radarNamesLabel.Text = "No target set"
		radarDistanceLabel.Text = "-- studs"
		radarDistanceLabel.TextColor3 = COLOR_NEUTRAL
		setStatus(false)
		return
	end

	local p1 = findPlayerByName(name1)
	local p2 = findPlayerByName(name2)

	if not p1 or not p2 then
		local missing = (not p1) and name1 or name2
		radarNamesLabel.Text = name1 .. " <-> " .. name2
		radarDistanceLabel.Text = ('"%s" not found'):format(missing)
		radarDistanceLabel.TextColor3 = COLOR_ERROR
		setStatus(false)
		return
	end

	if p1 == p2 then
		radarNamesLabel.Text = name1 .. " <-> " .. name2
		radarDistanceLabel.Text = "same player"
		radarDistanceLabel.TextColor3 = COLOR_ERROR
		setStatus(false)
		return
	end

	radarNamesLabel.Text = p1.Name .. " <-> " .. p2.Name

	local char1 = p1.Character
	local char2 = p2.Character
	local root1 = char1 and char1:FindFirstChild("HumanoidRootPart")
	local root2 = char2 and char2:FindFirstChild("HumanoidRootPart")

	if not root1 or not root2 then
		local missing = (not root1) and p1.Name or p2.Name
		radarDistanceLabel.Text = missing .. " not loaded"
		radarDistanceLabel.TextColor3 = COLOR_ERROR
		setStatus(false)
		return
	end

	local distance = (root1.Position - root2.Position).Magnitude
	radarDistanceLabel.Text = string.format("%.1f studs", distance)

	if distance <= CLOSE_DISTANCE then
		radarDistanceLabel.TextColor3 = COLOR_CLOSE
	elseif distance <= MEDIUM_DISTANCE then
		radarDistanceLabel.TextColor3 = COLOR_MEDIUM
	else
		radarDistanceLabel.TextColor3 = COLOR_FAR
	end

	setStatus(true)
end

local UPDATE_INTERVAL = 0.1
local timeSinceUpdate = 0

RunService.Heartbeat:Connect(function(dt)
	if not screenGui.Parent then
		return
	end
	timeSinceUpdate += dt
	if timeSinceUpdate >= UPDATE_INTERVAL then
		timeSinceUpdate = 0
		updateTracker()
	end
end)

print("[DistanceChecker] GUI loaded successfully. Parented to: " .. guiParent:GetFullName())
