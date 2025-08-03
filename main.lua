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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChudyKingGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.7
frame.BorderSizePixel = 0
frame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Text = "Chudy King"
title.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame
-- Helper: Button
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = frame
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
end

-- Helper: Slider
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
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            local value = math.floor(minVal + (maxVal - minVal) * rel)
            label.Text = labelText .. ": " .. value
            callback(value)
        end
    end)
end
-- NoClip toggle
local function setNoClip(enabled)
    noClip = enabled
    if noClip then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Restore collisions
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Teleport do bazy (bez cofania)
local function teleportToBase()
    if isTeleporting then return end
    isTeleporting = true
    hrp.CFrame = CFrame.new(basePosition + Vector3.new(0, 5, 0))
    wait(0.5)
    isTeleporting = false
end

-- Inicjalizacja suwaków
local currentSpeed = humanoid.WalkSpeed
local currentJump = humanoid.JumpPower

createSlider("Speed", 8, 100, currentSpeed, function(val)
    humanoid.WalkSpeed = val
end)

createSlider("JumpPower", 10, 150, currentJump, function(val)
    humanoid.JumpPower = val
end)

-- Przycisk noClip
createButton("Toggle NoClip", function()
    setNoClip(not noClip)
end)

-- Przycisk teleport do bazy
createButton("Teleport do bazy", function()
    teleportToBase()
end)

-- Automatyczne ustawienie pozycji bazy przy starcie
basePosition = hrp.Position

-- Dwupalcowy gest ukrywający GUI (na telefon)
local touchCount = 0
UserInputService.TouchStarted:Connect(function()
    touchCount = touchCount + 1
    if touchCount == 2 then
        ScreenGui.Enabled = not ScreenGui.Enabled
        touchCount = 0
    end
end)
UserInputService.TouchEnded:Connect(function()
    if touchCount > 0 then
        touchCount = touchCount - 1
    end
end)
