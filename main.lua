local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Automatyczne wykrywanie pozycji bazy (gdzie byłeś na starcie)
local basePosition = hrp.Position

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChudyKingGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local noClip = false
local noclipConnection
local isAntihitActive = false
local carryingItem = false

local originalSize = hrp.Size
local originalTransparency = {}
local originalCanCollide = {}

-- GUI setup
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, -160, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = ScreenGui
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Text = "Chudy King"
title.Parent = frame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = frame

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 22
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(75, 75, 75) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    return btn
end

local function createSlider(name, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 70)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Text = name .. ": " .. tostring(math.floor(default))
    label.Parent = container

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 30)
    sliderBar.Position = UDim2.new(0, 0, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderBar.Parent = container

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    slider.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    slider.Parent = sliderBar

    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local relativePos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            slider.Size = UDim2.new(relativePos, 0, 1, 0)
            local val = math.floor(min + (max - min) * relativePos)
            label.Text = name .. ": " .. tostring(val)
            callback(val)
        end
    end)

    return container
end

-- NoClip logic
local function setNoClip(enabled)
    noClip = enabled
    if noClip then
        noclipConnection = RunService.Stepped:Connect(function()
            if character and character.Parent then
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
        if character and character.Parent then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Speed i Jump
local desiredSpeed = humanoid.WalkSpeed
local desiredJump = humanoid.JumpPower

RunService.Heartbeat:Connect(function()
    if humanoid then
        humanoid.WalkSpeed = desiredSpeed
        humanoid.JumpPower = desiredJump
    end
end)

-- Teleport do bazy (poprawiony, żeby nie cofało)
local isTeleporting = false

local function teleportToBase()
    if isTeleporting then return end
    isTeleporting = true

    humanoid.PlatformStand = true  -- blokada fizyki by uniknąć cofania
    hrp.CFrame = CFrame.new(basePosition + Vector3.new(0, 5, 0))
    wait(0.3)
    humanoid.PlatformStand = false

    isTeleporting = false
end

-- Anty-hit (blok)
local function enableAntiHit()
    if isAntihitActive then return end
    isAntihitActive = true
    -- Zapisz oryginalne wartości
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            originalTransparency[part] = part.Transparency
            originalCanCollide[part] = part.CanCollide
            part.Transparency = 0.3
            part.CanCollide = false
            part.Size = Vector3.new(1, 1, 1)
        end
    end
    hrp.Size = Vector3.new(1,1,1)

    humanoid.MaxHealth = math.huge
    humanoid.Health = humanoid.MaxHealth

    humanoid.HealthChanged:Connect(function()
        if isAntihitActive and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function disableAntiHit()
    if not isAntihitActive then return end
    isAntihitActive = false
    for part, trans in pairs(originalTransparency) do
        if part and part.Parent then
            part.Transparency = trans
        end
    end
    for part, col in pairs(originalCanCollide) do
        if part and part.Parent then
            part.CanCollide = col
        end
    end
    hrp.Size = originalSize

    humanoid.MaxHealth = 100
    if humanoid.Health > humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
end

-- Funkcja sprawdzająca czy gracz niesie brainrota (lub inny item)
local function checkCarryingItem()
    local carrying = false
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Model") or child:IsA("Tool") then
            if string.find(child.Name:lower(), "brainrot") or string.find(child.Name:lower(), "stealitem") then
                carrying = true
                break
            end
        end
    end
    return carrying
end

-- Obsługa anty-hit na podstawie przedmiotu
RunService.Heartbeat:Connect(function()
    local carryingNow = checkCarryingItem()
    if carryingNow and not isAntihitActive then
        enableAntiHit()
    elseif not carryingNow and isAntihitActive then
        disableAntiHit()
    end
end)

-- GUI elementy
createSlider("Speed", 8, 100, humanoid.WalkSpeed, function(val)
    desiredSpeed = val
end)

createSlider("JumpPower", 10, 150, humanoid.JumpPower, function(val)
    desiredJump = val
end)

createButton("Toggle NoClip", function()
    setNoClip(not noClip)
end)

createButton("Teleport do bazy", teleportToBase)

-- Przycisk do chowania/otwierania GUI (ikona)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "≡"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 30
toggleButton.Parent = ScreenGui
toggleButton.ZIndex = 10

toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

frame.Visible = true
