local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local noClip = false
local noclipConnection

local basePosition = hrp.Position
local isTeleporting = false

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChudyKingGUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.7
frame.BorderSizePixel = 0
frame.Parent = ScreenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Text = "Chudy King"
title.Parent = frame

-- UIListLayout for buttons/sliders
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame

-- Helper: Create Button
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Position = UDim2.new(0.5, 0, 0, 0)
    btn.Parent = frame
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Helper: Create Slider (for touch)
local function createSlider(labelText, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local label = Instance.new("TextLabel")
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderBg.Parent = container
    sliderBg.ClipsDescendants = true
    sliderBg.AnchorPoint = Vector2.new(0, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.Parent = sliderBg

    local dragging = false

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderBg.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local relativePos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            local value = math.floor(minVal + (maxVal - minVal) * relativePos)
            label.Text = labelText .. ": " .. value
            callback(value)
        end
    end)

    return container
end

-- NoClip toggle
local function toggleNoClip()
    noClip = not noClip
    if noClip then
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local speed = 16
local jumpPower = 50

local function setSpeed(value)
    speed = value
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = speed
    end
end

local function setJump(value)
    jumpPower = value
    if humanoid and humanoid.Parent then
        humanoid.JumpPower = jumpPower
    end
end

local function teleportToBase()
    if isTeleporting or not hrp then return end
    isTeleporting = true

    -- Wyłącz kolizję by uniknąć cofnięcia
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- Kilkukrotne ustawienie pozycji, aby wymusić teleport
    for i = 1, 5 do
        hrp.CFrame = CFrame.new(basePosition)
        wait(0.1)
    end

    -- Mały delay by serwer zaakceptował pozycję
    wait(1)

    -- Włącz kolizję z powrotem
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end

    isTeleporting = false
end

-- Buttons
createButton("Toggle NoClip", toggleNoClip)
createButton("Teleport do bazy", teleportToBase)

-- Sliders
createSlider("Speed", 16, 100, speed, setSpeed)
createSlider("Jump Power", 50, 150, jumpPower, setJump)

-- Set initial values
setSpeed(speed)
setJump(jumpPower)

-- Update character refs on respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    basePosition = hrp.Position

    setSpeed(speed)
    setJump(jumpPower)
end)

-- Toggle GUI visibility with two-finger tap (mobile friendly)
UserInputService.TouchTapInWorld:Connect(function(touches)
    if #touches == 2 then
        frame.Visible = not frame.Visible
    end
end)
