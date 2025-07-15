--Copy and Paste held tool
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")

-- Create a folder to store our saved tools (persists through respawns)
local toolStorage = Instance.new("Folder")
toolStorage.Name = "HaidarEXE_ToolStorage"
toolStorage.Parent = ReplicatedStorage

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToolCopyGUI"
ScreenGui.ResetOnSpawn = false -- This keeps the GUI after respawning
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local RestoreButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")
local PasteButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- Main Frame (230x180 with rounded corners)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 230, 0, 180)
MainFrame.Position = UDim2.new(0, 15, 0, 15)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

-- Title Label
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 0, 20)
TitleLabel.Position = UDim2.new(0, 10, 0, 8)
TitleLabel.Text = "Tool Copy GUI BY HaidarEXE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Minimize Button (-)
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = MainFrame

-- Copy Button
CopyButton.Name = "CopyButton"
CopyButton.Size = UDim2.new(1, -20, 0, 35)
CopyButton.Position = UDim2.new(0, 10, 0, 40)
CopyButton.Text = "Copy Current Tool"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CopyButton.BorderSizePixel = 0
CopyButton.Parent = MainFrame

-- Paste Button
PasteButton.Name = "PasteButton"
PasteButton.Size = UDim2.new(1, -20, 0, 35)
PasteButton.Position = UDim2.new(0, 10, 0, 85)
PasteButton.Text = "Paste Saved Tool"
PasteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
PasteButton.BorderSizePixel = 0
PasteButton.Parent = MainFrame

-- Status Label
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 130)
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- Restore Button
RestoreButton.Name = "RestoreButton"
RestoreButton.Size = UDim2.new(0, 45, 0, 45)
RestoreButton.Position = UDim2.new(0, 15, 0, 15)
RestoreButton.Text = "+"
RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RestoreButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RestoreButton.BorderSizePixel = 0
RestoreButton.Visible = false
RestoreButton.Parent = ScreenGui

-- Add rounded corners to all elements
local function addCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
end

addCorners(CopyButton, 8)
addCorners(PasteButton, 8)
addCorners(MinimizeButton)
addCorners(RestoreButton, 8)

-- Handle character respawns
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    backpack = player:WaitForChild("Backpack")
end)

-- Function to save the currently held tool
local function copyCurrentTool()
    -- Clear old saved tools
    for _, child in ipairs(toolStorage:GetChildren()) do
        child:Destroy()
    end

    -- Check if character exists and has tools
    if not character then
        StatusLabel.Text = "Character not found!"
        task.delay(2, function() StatusLabel.Text = "" end)
        return
    end

    -- Find all tools in character (including equipped ones)
    local tools = {}
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("Tool") then
            table.insert(tools, item)
        end
    end

    -- Also check backpack
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, item)
        end
    end

    if #tools == 0 then
        StatusLabel.Text = "No tools found!"
        task.delay(2, function() StatusLabel.Text = "" end)
        return
    end

    -- Try to find the equipped tool first
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local equippedTool = humanoid and humanoid:FindFirstChildOfClass("Tool")

    -- If no equipped tool, use the first tool found
    local toolToCopy = equippedTool or tools[1]

    -- Clone the tool to storage
    local savedTool = toolToCopy:Clone()
    savedTool.Parent = toolStorage
    if savedTool:FindFirstChild("Handle") then
        savedTool.Handle.Anchored = true
        savedTool.Handle.CanCollide = false
    end

    StatusLabel.Text = "Copied: "..toolToCopy.Name
    task.delay(2, function() StatusLabel.Text = "" end)
end

-- Function to paste the saved tool
local function pasteSavedTool()
    -- Check if we have a saved tool
    local savedTool = toolStorage:FindFirstChildOfClass("Tool")
    if not savedTool then
        StatusLabel.Text = "No tool copied yet!"
        task.delay(2, function() StatusLabel.Text = "" end)
        return
    end

    -- Create a new copy of the tool
    local newTool = savedTool:Clone()
    if newTool:FindFirstChild("Handle") then
        newTool.Handle.Anchored = false
        newTool.Handle.CanCollide = true
    end
    newTool.Parent = backpack

    StatusLabel.Text = "Pasted: "..savedTool.Name
    task.delay(2, function() StatusLabel.Text = "" end)
end

-- Button connections
CopyButton.MouseButton1Click:Connect(copyCurrentTool)
PasteButton.MouseButton1Click:Connect(pasteSavedTool)

-- Dragging Function
local function makeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Make both frames draggable
makeDraggable(MainFrame)
makeDraggable(RestoreButton)

-- Minimize/Restore functionality
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    RestoreButton.Visible = true
end)

RestoreButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    RestoreButton.Visible = false
end)