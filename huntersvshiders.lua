-- Created with the help of GPT
--// LANDMINE REGION TOOL
--// Mobile-friendly / draggable / minimizable
--// Region outline / point markers / manual mine placement

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local LandmineEvent =
	ReplicatedStorage
		:WaitForChild("HunterCore")
		:WaitForChild("RemoteEvents")
		:WaitForChild("LandmineAction")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local SPACING = 3
local PLACE_DELAY = 3

--------------------------------------------------
-- POSITIONS
--------------------------------------------------

local posA = nil
local posB = nil

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "LandmineRegionTool"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 300)
main.Position = UDim2.new(0, 15, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = main

--------------------------------------------------
-- TITLE BAR
--------------------------------------------------

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -38, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💣 Landmine Region"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 28, 0, 26)
minimize.Position = UDim2.new(1, -32, 0, 3)
minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimize.BorderSizePixel = 0
minimize.Text = "−"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimize

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.Parent = main

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function makeButton(text, y)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -20, 0, 32)
	button.Position = UDim2.new(0, 10, 0, y)

	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderSizePixel = 0

	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 12
	button.Font = Enum.Font.Gotham

	button.Parent = content

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = button

	return button
end

local setA = makeButton("📍 Set Point A", 5)
local setB = makeButton("📍 Set Point B", 41)

local placeMine = makeButton("💣 Place Landmine", 77)
local fill = makeButton("💣 Fill Region", 113)
local stop = makeButton("🛑 Stop Filling", 149)
local clear = makeButton("Clear Selection", 185)

--------------------------------------------------
-- INPUT CREATOR
--------------------------------------------------

local function makeInput(text, y)

	local box = Instance.new("TextBox")

	box.Size = UDim2.new(1, -20, 0, 28)
	box.Position = UDim2.new(0, 10, 0, y)

	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.BorderSizePixel = 0

	box.Text = text
	box.TextColor3 = Color3.new(1, 1, 1)
	box.TextSize = 12
	box.Font = Enum.Font.Gotham

	box.ClearTextOnFocus = false

	box.Parent = content

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = box

	return box
end

--------------------------------------------------
-- DELAY
--------------------------------------------------

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, -20, 0, 16)
delayLabel.Position = UDim2.new(0, 10, 0, 223)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay between mines"
delayLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
delayLabel.TextSize = 10
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = content

local delayBox = makeInput(tostring(PLACE_DELAY), 239)

--------------------------------------------------
-- SPACING
--------------------------------------------------

local spacingLabel = Instance.new("TextLabel")
spacingLabel.Size = UDim2.new(1, -20, 0, 16)
spacingLabel.Position = UDim2.new(0, 10, 0, 269)
spacingLabel.BackgroundTransparency = 1
spacingLabel.Text = "Mine spacing"
spacingLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
spacingLabel.TextSize = 10
spacingLabel.Font = Enum.Font.Gotham
spacingLabel.TextXAlignment = Enum.TextXAlignment.Left
spacingLabel.Parent = content

local spacingBox = makeInput(tostring(SPACING), 285)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end

		end)

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

	end

end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local minimized = false

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	content.Visible = not minimized

	if minimized then
		main.Size = UDim2.new(0, 200, 0, 32)
		minimize.Text = "+"
	else
		main.Size = UDim2.new(0, 200, 0, 320)
		minimize.Text = "−"
	end

end)

--------------------------------------------------
-- REGION VISUALS
--------------------------------------------------

local visualFolder = Instance.new("Folder")
visualFolder.Name = "LandmineRegionVisuals"
visualFolder.Parent = workspace

local outlineParts = {}

local pointAVisual = nil
local pointBVisual = nil

--------------------------------------------------
-- CREATE OUTLINE PART
--------------------------------------------------

local function makeOutlinePart()

	local part = Instance.new("Part")

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)

	part.Transparency = 0.05

	part.Parent = visualFolder

	return part

end

--------------------------------------------------
-- DESTROY VISUALS
--------------------------------------------------

local function destroyVisuals()

	for _, part in ipairs(outlineParts) do
		part:Destroy()
	end

	table.clear(outlineParts)

	if pointAVisual then
		pointAVisual:Destroy()
		pointAVisual = nil
	end

	if pointBVisual then
		pointBVisual:Destroy()
		pointBVisual = nil
	end

end

--------------------------------------------------
-- POINT MARKER
--------------------------------------------------

local function createPointMarker(position, labelText)

	local part = Instance.new("Part")

	part.Name = labelText .. "Marker"

	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(1.5, 1.5, 1.5)

	part.Position = position + Vector3.new(0, 1.5, 0)

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)

	part.Parent = visualFolder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 80, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.new(1, 0, 0)
	label.TextStrokeTransparency = 0
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	return part

end

--------------------------------------------------
-- UPDATE REGION
--------------------------------------------------

local function updateSelection()

	destroyVisuals()

	if not posA or not posB then
		return
	end

	local minX = math.min(posA.X, posB.X)
	local maxX = math.max(posA.X, posB.X)

	local minZ = math.min(posA.Z, posB.Z)
	local maxZ = math.max(posA.Z, posB.Z)

	local y = math.min(posA.Y, posB.Y) + 0.15

	local width = math.max(maxX - minX, 0.5)
	local depth = math.max(maxZ - minZ, 0.5)

	local centerX = (minX + maxX) / 2
	local centerZ = (minZ + maxZ) / 2

	--------------------------------------------------
	-- OUTLINE THICKNESS
	--------------------------------------------------

	local thickness = 0.25

	--------------------------------------------------
	-- NORTH
	--------------------------------------------------

	local north = makeOutlinePart()

	north.Size = Vector3.new(
		width + thickness,
		thickness,
		thickness
	)

	north.Position = Vector3.new(
		centerX,
		y,
		minZ
	)

	table.insert(outlineParts, north)

	--------------------------------------------------
	-- SOUTH
	--------------------------------------------------

	local south = makeOutlinePart()

	south.Size = Vector3.new(
		width + thickness,
		thickness,
		thickness
	)

	south.Position = Vector3.new(
		centerX,
		y,
		maxZ
	)

	table.insert(outlineParts, south)

	--------------------------------------------------
	-- WEST
	--------------------------------------------------

	local west = makeOutlinePart()

	west.Size = Vector3.new(
		thickness,
		thickness,
		depth
	)

	west.Position = Vector3.new(
		minX,
		y,
		centerZ
	)

	table.insert(outlineParts, west)

	--------------------------------------------------
	-- EAST
	--------------------------------------------------

	local east = makeOutlinePart()

	east.Size = Vector3.new(
		thickness,
		thickness,
		depth
	)

	east.Position = Vector3.new(
		maxX,
		y,
		centerZ
	)

	table.insert(outlineParts, east)

	--------------------------------------------------
	-- POINT MARKERS
	--------------------------------------------------

	pointAVisual = createPointMarker(posA, "A")
	pointBVisual = createPointMarker(posB, "B")

end

--------------------------------------------------
-- SET A
--------------------------------------------------

setA.MouseButton1Click:Connect(function()

	local character = Player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	posA = root.Position

	setA.Text = string.format(
		"A: %.0f, %.0f, %.0f",
		posA.X,
		posA.Y,
		posA.Z
	)

	updateSelection()

end)

--------------------------------------------------
-- SET B
--------------------------------------------------

setB.MouseButton1Click:Connect(function()

	local character = Player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	posB = root.Position

	setB.Text = string.format(
		"B: %.0f, %.0f, %.0f",
		posB.X,
		posB.Y,
		posB.Z
	)

	updateSelection()

end)

--------------------------------------------------
-- DELAY UPDATE
--------------------------------------------------

delayBox.FocusLost:Connect(function()

	local value = tonumber(delayBox.Text)

	if value and value >= 0 then

		PLACE_DELAY = value
		delayBox.Text = tostring(PLACE_DELAY)

	else

		delayBox.Text = tostring(PLACE_DELAY)

	end

end)

--------------------------------------------------
-- SPACING UPDATE
--------------------------------------------------

spacingBox.FocusLost:Connect(function()

	local value = tonumber(spacingBox.Text)

	if value and value > 0 then

		SPACING = value
		spacingBox.Text = tostring(SPACING)

	else

		spacingBox.Text = tostring(SPACING)

	end

end)

--------------------------------------------------
-- PLACE ONE LANDMINE
--------------------------------------------------

placeMine.MouseButton1Click:Connect(function()

	local character = Player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	LandmineEvent:FireServer(
		"Place",
		root.Position
	)

	local oldText = placeMine.Text

	placeMine.Text = "💣 Placed!"

	task.delay(1, function()

		if placeMine then
			placeMine.Text = oldText
		end

	end)

end)

--------------------------------------------------
-- FILL MINES
--------------------------------------------------

local placing = false

fill.MouseButton1Click:Connect(function()

	if placing then
		return
	end

	if not posA or not posB then

		fill.Text = "Set A + B first!"

		task.wait(1.5)

		if not placing then
			fill.Text = "💣 Fill Region"
		end

		return
	end

	placing = true

	local minX = math.min(posA.X, posB.X)
	local maxX = math.max(posA.X, posB.X)

	local minZ = math.min(posA.Z, posB.Z)
	local maxZ = math.max(posA.Z, posB.Z)

	local y = (posA.Y + posB.Y) / 2

	--------------------------------------------------
	-- COUNT
	--------------------------------------------------

	local total = 0

	for x = minX, maxX, SPACING do

		for z = minZ, maxZ, SPACING do
			total += 1
		end

	end

	local current = 0

	--------------------------------------------------
	-- PLACE
	--------------------------------------------------

	for x = minX, maxX, SPACING do

		if not placing then
			break
		end

		for z = minZ, maxZ, SPACING do

			if not placing then
				break
			end

			current += 1

			fill.Text = string.format(
				"💣 %d / %d",
				current,
				total
			)

			LandmineEvent:FireServer(
				"Place",
				Vector3.new(
					x,
					y,
					z
				)
			)

			task.wait(PLACE_DELAY)

		end

	end

	placing = false

	fill.Text = "Finished!"

	task.wait(2)

	if not placing then
		fill.Text = "💣 Fill Region"
	end

end)

--------------------------------------------------
-- STOP
--------------------------------------------------

stop.MouseButton1Click:Connect(function()

	placing = false

	fill.Text = "Stopped"

	task.delay(1, function()

		if not placing then
			fill.Text = "💣 Fill Region"
		end

	end)

end)

--------------------------------------------------
-- CLEAR
--------------------------------------------------

clear.MouseButton1Click:Connect(function()

	placing = false

	posA = nil
	posB = nil

	destroyVisuals()

	setA.Text = "📍 Set Point A"
	setB.Text = "📍 Set Point B"

	fill.Text = "💣 Fill Region"

end)
