-- Minimal Mobile QSX Aimlock (Final)
-- Smoothness reduced for snappier look

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local LocalPlayer= Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- SETTINGS
local Smoothness = 0.075   -- lower for snappier tracking
local FOVRadius  = 130

-- STATE
local aimlockOn = false

-- SOUND
local lockSound = Instance.new("Sound", LocalPlayer:WaitForChild("PlayerGui"))
lockSound.SoundId = "rbxassetid://12221967"
lockSound.Volume  = 1

-- GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

-- DRAG HELPER
local function makeDraggable(frame)
    local dragging, startPos, startInput, dragInput
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging   = true
            startPos   = frame.Position
            startInput = inp.Position
            inp.Changed:Connect(function()
                if inp.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement then
            dragInput=inp
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp==dragInput then
            local delta=inp.Position - startInput
            frame.Position=UDim2.new(
                startPos.X.Scale, startPos.X.Offset+delta.X,
                startPos.Y.Scale, startPos.Y.Offset+delta.Y
            )
        end
    end)
end

-- PANEL
local panel=Instance.new("Frame", screenGui)
panel.Size=UDim2.new(0,240,0,100)
panel.Position=UDim2.new(0,20,0.5,-50)
panel.BackgroundColor3=Color3.fromRGB(30,30,30)
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,8)
makeDraggable(panel)

-- TITLE
local title=Instance.new("TextLabel", panel)
title.Size=UDim2.new(1,0,0,30)
title.Position=UDim2.new(0,0,0,4)
title.Text="QSX Aimlock"
title.Font=Enum.Font.GothamBold
title.TextSize=18
title.TextColor3=Color3.new(1,1,1)
title.BackgroundTransparency=1

-- TOGGLE BUTTON
local btn=Instance.new("TextButton", panel)
btn.Size=UDim2.new(0,200,0,36)
btn.Position=UDim2.new(0.5,-100,0,50)
btn.BackgroundColor3=Color3.fromRGB(60,120,255)
btn.TextColor3=Color3.new(1,1,1)
btn.Font=Enum.Font.Gotham
btn.TextSize=15
btn.Text="Toggle Aimlock: OFF"
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

-- FOV CIRCLE
local circle=Instance.new("Frame", screenGui)
circle.AnchorPoint=Vector2.new(0.5,0.5)
circle.Position   =UDim2.new(0.5,0,0.5,0)
circle.Size       =UDim2.new(0,FOVRadius*2,0,FOVRadius*2)
circle.BackgroundTransparency=1
local stroke=Instance.new("UIStroke", circle)
stroke.Thickness=2
stroke.Color=Color3.fromRGB(255,0,0)
Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)

-- TOGGLE LOGIC
btn.MouseButton1Click:Connect(function()
    aimlockOn = not aimlockOn
    btn.Text   = "Toggle Aimlock: " .. (aimlockOn and "ON" or "OFF")
    stroke.Color = aimlockOn
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,0,0)
    if aimlockOn then
        lockSound:Play()
    end
end)

-- HELPERS
local function getTorso(ch)
    return ch and (ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("HumanoidRootPart"))
end

local function getClosestInCircle()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local bestDist = FOVRadius
    local bestPlr  = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local torso = getTorso(plr.Character)
            if hum and torso and hum.Health>0 then
                local pos,on = Camera:WorldToViewportPoint(torso.Position)
                if on then
                    local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if dist<bestDist then
                        bestDist, bestPlr = dist, plr
                    end
                end
            end
        end
    end
    return bestPlr
end

-- AIMLOCK LOOP
RunService.RenderStepped:Connect(function()
    if aimlockOn then
        local target = getClosestInCircle()
        if target and target.Character then
            local torso = getTorso(target.Character)
            if torso then
                local cf = CFrame.new(Camera.CFrame.Position, torso.Position)
                Camera.CFrame = Camera.CFrame:Lerp(cf, Smoothness)
            end
        end
    end
end)
