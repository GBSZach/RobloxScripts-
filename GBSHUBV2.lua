--// GBS Hub V2
--// Fully Customizable Mobile-Friendly Script Hub

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local GUI_PARENT = (syn and syn.protect_gui and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

--// Cleanup
local old = GUI_PARENT:FindFirstChild("GBSHub")
if old then old:Destroy() end

--// Data
local HubData = {
    settings = {
        scale = 1
    },

    scripts = {
        {
            title = "Infinite Yield",
            category = "Tools",
            code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
        },

        {
            title = "SimpleSpy",
            category = "Tools",
            code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()'
        },

        {
            title = "YARHM",
            category = "Universal",
            code = 'loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-YARHM-12403"))()'
        }
    }
}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GBSHub"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = GUI_PARENT

--// Blur
local blur = Instance.new("BlurEffect")
blur.Size = 10
blur.Parent = Lighting

--// Main
local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.68, 0.68)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local scale = Instance.new("UIScale")
scale.Scale = HubData.settings.scale
scale.Parent = main

--// Dragging
local dragging = false
local dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Top Bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,36)
top.BackgroundTransparency = 1
top.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "GBS Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1,1,1)
title.Parent = top

--// Buttons
local function makeTopButton(text, posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,28,0,28)
    btn.Position = UDim2.new(1,posX,0,4)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Parent = top

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    return btn
end

local settingsBtn = makeTopButton("⚙",-96)
local minimizeBtn = makeTopButton("—",-64)
local closeBtn = makeTopButton("✕",-32)

--// Tabs
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1,-20,0,34)
tabHolder.Position = UDim2.new(0,10,0,40)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,4)
tabLayout.Parent = tabHolder

--// Search
local search = Instance.new("TextBox")
search.Size = UDim2.new(1,-20,0,30)
search.Position = UDim2.new(0,10,0,78)
search.PlaceholderText = "Search scripts..."
search.Text = ""
search.BackgroundColor3 = Color3.fromRGB(30,30,30)
search.TextColor3 = Color3.new(1,1,1)
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.Parent = main
Instance.new("UICorner", search).CornerRadius = UDim.new(0,6)

--// Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-120)
scroll.Position = UDim2.new(0,10,0,114)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,4)
list.Parent = scroll

--// Notification
local function notify(text)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0,220,0,40)
    n.Position = UDim2.new(1,-230,1,-50)
    n.BackgroundColor3 = Color3.fromRGB(30,30,30)
    n.TextColor3 = Color3.new(1,1,1)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 14
    n.Text = text
    n.Parent = gui

    Instance.new("UICorner", n).CornerRadius = UDim.new(0,8)

    n.BackgroundTransparency = 1
    n.TextTransparency = 1

    TweenService:Create(n,TweenInfo.new(0.2),{
        BackgroundTransparency = 0,
        TextTransparency = 0
    }):Play()

    task.delay(2,function()
        TweenService:Create(n,TweenInfo.new(0.2),{
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()

        task.wait(0.2)
        n:Destroy()
    end)
end

--// Categories
local currentTab = "Universal"

local function getCategories()
    local categories = {}

    for _,scriptData in ipairs(HubData.scripts) do
        local cat = scriptData.category or "Universal"

        if not table.find(categories,cat) then
            table.insert(categories,cat)
        end
    end

    table.insert(categories,"Options")

    return categories
end

--// Script Card
local function createScriptCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,54)
    card.BackgroundColor3 = Color3.fromRGB(28,28,28)
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-90,0,24)
    title.Position = UDim2.new(0,10,0,6)
    title.BackgroundTransparency = 1
    title.Text = data.title
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local category = Instance.new("TextLabel")
    category.Size = UDim2.new(1,-90,0,18)
    category.Position = UDim2.new(0,10,0,26)
    category.BackgroundTransparency = 1
    category.Text = data.category
    category.TextColor3 = Color3.fromRGB(170,170,170)
    category.Font = Enum.Font.Gotham
    category.TextSize = 12
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = card

    local run = Instance.new("TextButton")
    run.Size = UDim2.new(0,60,0,26)
    run.Position = UDim2.new(1,-70,0.5,-13)
    run.BackgroundColor3 = Color3.fromRGB(60,120,255)
    run.Text = "RUN"
    run.TextColor3 = Color3.new(1,1,1)
    run.Font = Enum.Font.GothamBold
    run.TextSize = 14
    run.Parent = card
    Instance.new("UICorner", run).CornerRadius = UDim.new(0,6)

    run.MouseButton1Click:Connect(function()
        run.Text = "..."
        local ok,err = pcall(function()
            loadstring(data.code)()
        end)

        if ok then
            notify("Executed "..data.title)
        else
            warn(err)
            notify("Failed "..data.title)
        end

        task.wait(1)
        run.Text = "RUN"
    end)
end

--// Add Script Popup
local popup

local function openAddPopup()
    if popup then popup:Destroy() end

    popup = Instance.new("Frame")
    popup.Size = UDim2.new(0,300,0,260)
    popup.Position = UDim2.fromScale(0.5,0.5)
    popup.AnchorPoint = Vector2.new(0.5,0.5)
    popup.BackgroundColor3 = Color3.fromRGB(25,25,25)
    popup.Parent = gui
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0,8)

    local function createBox(place,y,sizeY)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1,-20,0,sizeY or 34)
        box.Position = UDim2.new(0,10,0,y)
        box.PlaceholderText = place
        box.Text = ""
        box.BackgroundColor3 = Color3.fromRGB(35,35,35)
        box.TextColor3 = Color3.new(1,1,1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.TextWrapped = true
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Parent = popup
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
        return box
    end

    local titleBox = createBox("Script Title",10)
    local codeBox = createBox("Loadstring / Lua Code",54,110)
    local catBox = createBox("Category (optional)",172)

    local add = Instance.new("TextButton")
    add.Size = UDim2.new(1,-20,0,36)
    add.Position = UDim2.new(0,10,1,-46)
    add.BackgroundColor3 = Color3.fromRGB(60,120,255)
    add.Text = "ADD SCRIPT"
    add.TextColor3 = Color3.new(1,1,1)
    add.Font = Enum.Font.GothamBold
    add.TextSize = 14
    add.Parent = popup
    Instance.new("UICorner", add).CornerRadius = UDim.new(0,6)

    add.MouseButton1Click:Connect(function()
        local cat = catBox.Text ~= "" and catBox.Text or "Universal"

        table.insert(HubData.scripts,{
            title = titleBox.Text,
            category = cat,
            code = codeBox.Text
        })

        popup:Destroy()
        notify("Added "..titleBox.Text)

        task.wait()
        loadTab(currentTab)
    end)
end

--// Export Backup
local function exportBackup()
    local encoded = HttpService:JSONEncode(HubData)

    if setclipboard then
        setclipboard("GBSHUB:"..encoded)
        notify("Backup copied!")
    else
        notify("Clipboard unsupported")
    end
end

--// Import Backup
local function importBackup()
    if popup then popup:Destroy() end

    popup = Instance.new("Frame")
    popup.Size = UDim2.new(0,320,0,240)
    popup.Position = UDim2.fromScale(0.5,0.5)
    popup.AnchorPoint = Vector2.new(0.5,0.5)
    popup.BackgroundColor3 = Color3.fromRGB(25,25,25)
    popup.Parent = gui

    Instance.new("UICorner", popup).CornerRadius = UDim.new(0,8)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-20,1,-70)
    box.Position = UDim2.new(0,10,0,10)
    box.MultiLine = true
    box.TextWrapped = true
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.PlaceholderText = "Paste backup..."
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(35,35,35)
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.Parent = popup

    local import = Instance.new("TextButton")
    import.Size = UDim2.new(1,-20,0,40)
    import.Position = UDim2.new(0,10,1,-50)
    import.BackgroundColor3 = Color3.fromRGB(60,120,255)
    import.Text = "IMPORT"
    import.TextColor3 = Color3.new(1,1,1)
    import.Font = Enum.Font.GothamBold
    import.TextSize = 14
    import.Parent = popup

    import.MouseButton1Click:Connect(function()
        local text = box.Text

        text = string.gsub(text,"GBSHUB:","")

        local ok,data = pcall(function()
            return HttpService:JSONDecode(text)
        end)

        if ok and data then
            HubData = data

            popup:Destroy()
            notify("Imported backup!")

            task.wait()
            loadTab(currentTab)
        else
            notify("Invalid backup")
        end
    end)
end

--// Load Tabs
function loadTab(tab)
    currentTab = tab

    for _,v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end

    if tab == "Options" then

        local function makeOption(text,callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.Parent = scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

            btn.MouseButton1Click:Connect(callback)
        end

        makeOption("Add Script",openAddPopup)

        makeOption("Small UI",function()
            scale.Scale = 0.8
        end)

        makeOption("Normal UI",function()
            scale.Scale = 1
        end)

        makeOption("Large UI",function()
            scale.Scale = 1.2
        end)

        makeOption("Export Backup",exportBackup)

        makeOption("Import Backup",importBackup)

        makeOption("Destroy GUI",function()
            blur:Destroy()
            gui:Destroy()
        end)

        return
    end

    for _,data in ipairs(HubData.scripts) do
        local category = data.category or "Universal"

        local searchText = string.lower(search.Text)

        if category == tab then
            if searchText == ""
            or string.find(string.lower(data.title),searchText) then
                createScriptCard(data)
            end
        end
    end
end

--// Create Tabs
local function refreshTabs()
    for _,v in ipairs(tabHolder:GetChildren()) do
        if not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end

    for _,tabName in ipairs(getCategories()) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(0,80,1,0)
        tab.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tab.Text = tabName
        tab.TextColor3 = Color3.new(1,1,1)
        tab.Font = Enum.Font.GothamBold
        tab.TextSize = 13
        tab.Parent = tabHolder

        Instance.new("UICorner", tab).CornerRadius = UDim.new(0,6)

        tab.MouseButton1Click:Connect(function()
            loadTab(tabName)
        end)
    end
end

--// Search Refresh
search:GetPropertyChangedSignal("Text"):Connect(function()
    loadTab(currentTab)
end)

--// Minimize
local miniButton

minimizeBtn.MouseButton1Click:Connect(function()
    main.Visible = false

    miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.fromOffset(50,50)
    miniButton.Position = UDim2.new(0,20,0.5,0)
    miniButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
    miniButton.Text = "+"
    miniButton.TextScaled = true
    miniButton.TextColor3 = Color3.new(1,1,1)
    miniButton.Parent = gui

    Instance.new("UICorner", miniButton).CornerRadius = UDim.new(1,0)

    miniButton.MouseButton1Click:Connect(function()
        main.Visible = true
        miniButton:Destroy()
    end)
end)

--// Close
closeBtn.MouseButton1Click:Connect(function()
    blur:Destroy()
    gui:Destroy()
end)

--// Settings Button
settingsBtn.MouseButton1Click:Connect(function()
    loadTab("Options")
end)

--// Init
refreshTabs()
loadTab("Universal")