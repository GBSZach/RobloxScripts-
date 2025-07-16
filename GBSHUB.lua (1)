-- GBS Hub (All-in-One, Mobile-Friendly, Rayfield Style, Tabs, Drag Support)

local scriptTabs = {
    ["FE Scripts (Universal)"] = {
        { name = "Fling Script", url = "https://raw.githubusercontent.com/hellohellohell012321/KAWAII-FREAKY-FLING/main/kawaii_freaky_fling.lua" },
        { name = "YARHM", url = "https://rawscripts.net/raw/Universal-Script-YARHM-12403" }
    },
    ["Trolling"] = {
        { name = "Talentless Piano", url = "https://raw.githubusercontent.com/hellohellohell012321/TALENTLESS/main/TALENTLESS" },
        { name = "Tornado Script", url = "https://raw.githubusercontent.com/GBSZach/TornadoScript/refs/heads/main/tornadoscript.lua" },
        { name = "Slap Tower", url = "https://raw.githubusercontent.com/Rawbr10/Roblox-Scripts/refs/heads/main/Slap-Tower-Script" }
    },
    ["Tools"] = {
        { name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source" },
        { name = "SimpleSpy", url = "https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua" },
        { name = "Tool Giver", url = "https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gametoolgiver.lua" },
        { name = "Copy Tool (Held)", url = "https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/heldtoolpaster.lua" }
    },
    ["Other"] = {
        { name = "Grow A Garden", url = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" },
        { name = "Case RNG Auto Roll", url = "https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/caserollingrngautoroll.lua" }
    }
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local GUI_PARENT = (syn and syn.protect_gui and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

local old = GUI_PARENT:FindFirstChild("ScriptHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ScriptHub"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = GUI_PARENT

local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(25, 55, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 32)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamSemibold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "GBS Hub"
title.Parent = main

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 24, 0, 24)
minimize.Position = UDim2.new(1, -32, 0, 6)
minimize.BackgroundColor3 = Color3.fromRGB(40, 70, 40)
minimize.Text = "–"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Parent = main

local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0, 130, 1, -40)
tabPanel.Position = UDim2.new(0, 10, 0, 40)
tabPanel.BackgroundTransparency = 1
tabPanel.Parent = main

local tabList = Instance.new("UIListLayout", tabPanel)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Position = UDim2.new(0, 150, 0, 42)
scrollFrame.Size = UDim2.new(1, -160, 1, -52)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = main

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

local function showTab(tabName)
    scrollFrame:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout", scrollFrame)
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 4)

    for _, script in ipairs(scriptTabs[tabName] or {}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = "► " .. script.name
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            btn.Text = "⌛ Running..."
            task.spawn(function()
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(script.url, true))()
                end)
                btn.Text = ok and ("✔ " .. script.name) or ("✖ " .. script.name)
                if not ok then warn("ScriptHub Error:", err) end
                task.wait(1.5)
                btn.Text = "► " .. script.name
            end)
        end)
    end
end

for tabName, _ in pairs(scriptTabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    tabBtn.TextColor3 = Color3.new(1, 1, 1)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 16
    tabBtn.Text = tabName
    tabBtn.Parent = tabPanel
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    tabBtn.MouseButton1Click:Connect(function()
        showTab(tabName)
    end)
end

showTab("FE Scripts (Universal)")

-- draggable maximize button memory
local lastMiniPos = UDim2.new(0.5, 0, 0.5, 0)
local minimizedBtn

local function minimizeWindow()
    main.Visible = false
    if minimizedBtn then minimizedBtn:Destroy() end

    minimizedBtn = Instance.new("TextButton")
    minimizedBtn.Size = UDim2.fromOffset(60, 60)
    minimizedBtn.Position = lastMiniPos
    minimizedBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    minimizedBtn.Text = "+"
    minimizedBtn.TextScaled = true
    minimizedBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
    minimizedBtn.Font = Enum.Font.GothamBold
    minimizedBtn.Parent = gui
    Instance.new("UICorner", minimizedBtn).CornerRadius = UDim.new(0, 8)

    local dragging, dragStart, startPos
    minimizedBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = minimizedBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            minimizedBtn.Position = UDim2.new(0, newX, 0, newY)
            lastMiniPos = minimizedBtn.Position
        end
    end)

    minimizedBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        minimizedBtn:Destroy()
    end)
end
minimize.Activated:Connect(minimizeWindow)

local function responsive()
    local w, h = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
    main.Size = UDim2.fromScale(0.5, 0.5)
    if math.min(w, h) <= 768 then
        main.Size = UDim2.fromScale(0.85, 0.6)
    end
end
responsive()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
