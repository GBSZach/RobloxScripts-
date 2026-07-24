--[[
	DistanceChecker.lua
	--------------------
	Client-side LocalScript.

	Put this in StarterPlayerScripts (or run it from a script executor).
	Creates a draggable, minimizable, mobile-friendly GUI where you can
	type two player names (with autocomplete against players currently
	in the server) and see a LIVE, continuously-updating distance
	between them in studs.

	Notes:
	- Distance can only be measured for players currently in the same
	  server (it reads their Character's HumanoidRootPart position).
	- Autocomplete only suggests / fills names of players who are
	  actually in the game right now.
	- Autocomplete resolves when you press Enter or tap out of the
	  textbox (not by clicking a suggestion).
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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

-- Most mobile executors expose gethui()/get_hidden_ui() which parents a
-- GUI to a protected CoreGui-like container that survives PlayerGui resets
-- and is harder for games to strip. Fall back to PlayerGui if unavailable
-- (e.g. running as a normal LocalScript in StarterPlayerScripts).
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
-- Layout constants (kept small so it doesn't dominate a phone screen)
--=========================================================

local MOBILE = isMobile()

local WINDOW_WIDTH = MOBILE and 220 or 250
local TITLE_HEIGHT = 28
local PADDING = 8
local GAP = 6
local INPUT_CONTAINER_HEIGHT = 46
local BUTTON_HEIGHT = 0 -- no manual button anymore, tracking is automatic
local RESULT_HEIGHT = 30

local BODY_CONTENT_HEIGHT = (INPUT_CONTAINER_HEIGHT * 2) + GAP + RESULT_HEIGHT
local WINDOW_HEIGHT = TITLE_HEIGHT + PADDING * 2 + BODY_CONTENT_HEIGHT + GAP

--=========================================================
-- Root GUI
--=========================================================

local guiParent = getGuiParent()

-- Clean up any previous copy so re-running the script doesn't stack GUIs
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
-- Main window
--=========================================================

-- AnchorPoint (0,0) = top-left. This means when the frame resizes
-- (minimize/restore) it grows/shrinks from its top-left corner instead
-- of its center, so the title bar (drag handle + buttons) never moves
-- off-screen just because the window expanded.
local mainFrame = new("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
	Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.35, -WINDOW_HEIGHT / 2),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.fromRGB(30, 30, 36),
	BorderSizePixel = 0,
	ClipsDescendants = false,
	Parent = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })
new("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Parent = mainFrame })

-- Title bar (drag handle)
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

local liveDot = new("Frame", {
	Name = "LiveDot",
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0, 10, 0.5, -4),
	BackgroundColor3 = Color3.fromRGB(90, 90, 100),
	BorderSizePixel = 0,
	Parent = titleBar,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = liveDot })

local titleLabel = new("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -76, 1, 0),
	Position = UDim2.new(0, 24, 0, 0),
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

-- Body (everything below the title bar)
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

--=========================================================
-- Reusable "labeled textbox with autocomplete" builder
--=========================================================

-- Returns the TextBox plus a getter for "is this box currently a valid
-- in-game player name".
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
	local boxStroke = new("UIStroke", {
		Color = Color3.fromRGB(65, 65, 75),
		Thickness = 1,
		Parent = box,
	})

	-- Live suggestions shown WHILE TYPING (visual only, not clickable).
	-- Resolution/autofill happens on FocusLost (Enter key or tapping away).
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

	-- Resolve the typed text into an actual player name: exact match wins
	-- (just fixes casing), otherwise the first alphabetical prefix match.
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
		-- if no matches at all, leave the text as-is so the user can see
		-- what they typed; the tracker will just report "not found".
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

--=========================================================
-- Result label (live-updating)
--=========================================================

local resultLabel = new("TextLabel", {
	Name = "ResultLabel",
	Size = UDim2.new(1, 0, 0, RESULT_HEIGHT),
	LayoutOrder = 3,
	BackgroundTransparency = 1,
	Text = "Enter two usernames above.",
	TextColor3 = Color3.fromRGB(200, 200, 210),
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextWrapped = true,
	Parent = body,
})

local function setResult(text, color)
	resultLabel.Text = text
	resultLabel.TextColor3 = color or Color3.fromRGB(200, 200, 210)
end

local function findPlayerByName(name)
	local lowerName = string.lower(name)
	for _, plr in ipairs(Players:GetPlayers()) do
		if string.lower(plr.Name) == lowerName then
			return plr
		end
	end
	return nil
end

--=========================================================
-- Live tracking loop
--=========================================================

local UPDATE_INTERVAL = 0.1 -- 10x/sec, smooth but not wasteful
local timeSinceUpdate = 0
local trackingActive = false

local function setLiveDot(active)
	trackingActive = active
	liveDot.BackgroundColor3 = active
		and Color3.fromRGB(90, 220, 120)
		or Color3.fromRGB(90, 90, 100)
end

local function updateTracker()
	local name1 = player1Box.Text
	local name2 = player2Box.Text

	if name1 == "" or name2 == "" then
		setResult("Enter two usernames above.")
		setLiveDot(false)
		return
	end

	local p1 = findPlayerByName(name1)
	local p2 = findPlayerByName(name2)

	if not p1 then
		setResult(('"%s" not found in this server.'):format(name1), Color3.fromRGB(230, 120, 120))
		setLiveDot(false)
		return
	end
	if not p2 then
		setResult(('"%s" not found in this server.'):format(name2), Color3.fromRGB(230, 120, 120))
		setLiveDot(false)
		return
	end
	if p1 == p2 then
		setResult("Enter two different players.", Color3.fromRGB(230, 180, 120))
		setLiveDot(false)
		return
	end

	local char1 = p1.Character
	local char2 = p2.Character
	local root1 = char1 and char1:FindFirstChild("HumanoidRootPart")
	local root2 = char2 and char2:FindFirstChild("HumanoidRootPart")

	if not root1 then
		setResult(('%s\'s character not loaded.'):format(p1.Name), Color3.fromRGB(230, 120, 120))
		setLiveDot(false)
		return
	end
	if not root2 then
		setResult(('%s\'s character not loaded.'):format(p2.Name), Color3.fromRGB(230, 120, 120))
		setLiveDot(false)
		return
	end

	local distance = (root1.Position - root2.Position).Magnitude
	setResult(('%s <-> %s: %s studs'):format(p1.Name, p2.Name, string.format("%.1f", distance)), Color3.fromRGB(130, 220, 150))
	setLiveDot(true)
end

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

--=========================================================
-- Dragging (mouse + touch)
--=========================================================

local function clampToScreen()
	local screenSize = screenGui.AbsoluteSize
	if screenSize.X == 0 or screenSize.Y == 0 then
		return
	end

	local absPos = mainFrame.AbsolutePosition
	local absSize = mainFrame.AbsoluteSize
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
		local pos = mainFrame.Position
		mainFrame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + dx, pos.Y.Scale, pos.Y.Offset + dy)
	end
end

local function makeDraggable(dragHandle, target)
	local dragging = false
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					clampToScreen()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

makeDraggable(titleBar, mainFrame)

--=========================================================
-- Minimize / restore
--=========================================================

local minimized = false
local expandedSize = mainFrame.Size
local minimizedSize = UDim2.new(0, 150, 0, TITLE_HEIGHT)

local function setMinimized(state)
	minimized = state
	body.Visible = not state

	local goalSize = state and minimizedSize or expandedSize
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Size = goalSize })
	tween:Play()
	tween.Completed:Connect(function()
		clampToScreen()
	end)
	minimizeButton.Text = state and "+" or "-"
end

minimizeButton.MouseButton1Click:Connect(function()
	setMinimized(not minimized)
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

print("[DistanceChecker] GUI loaded successfully. Parented to: " .. guiParent:GetFullName())
