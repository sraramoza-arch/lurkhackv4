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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChudyKingGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.7, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.7
frame.Parent = ScreenGui
frame.Visible = true

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = frame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = frame
    btn.AutoButtonColor = true

    btn.MouseButton1Click:Connect(callback)
    return btn
end

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

local function teleportToBase()
    if hrp then
        hrp.CFrame = CFrame.new(basePosition)
    end
end

createButton("Toggle NoClip", toggleNoClip)
createButton("Teleport do bazy", teleportToBase)

-- Speed control
local speed = 16
local jumpPower = 50

local function setSpeed(value)
    speed = value
    humanoid.WalkSpeed = speed
end

local function setJump(value)
    jumpPower = value
    humanoid.JumpPower = jumpPower
end

createButton("Speed +5", function() setSpeed(speed + 5) end)
createButton("Speed -5", function() setSpeed(math.max(16, speed - 5)) end)
createButton("Jump +10", function() setJump(jumpPower + 10) end)
createButton("Jump -10", function() setJump(math.max(50, jumpPower - 10)) end)

setSpeed(speed)
setJump(jumpPower)

-- Automatyczne zapisywanie pozycji bazy po respawnie
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    basePosition = hrp.Position

    setSpeed(speed)
    setJump(jumpPower)
end)

-- Toggle GUI widoczności klawiszem 'RightMouseButton'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        frame.Visible = not frame.Visible
    end
end)
