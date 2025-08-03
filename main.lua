-- Chudy King stealth v1.4 - finalna wersja z automatycznym zapisem bazy

do
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Stan funkcji
    local noClipEnabled = false
    local antiHitEnabled = false
    local speedValue = 16
    local jumpPowerValue = 50

    -- Eventy
    local noclipConnection
    local debounce = false

    -- AUTOMATYCZNE ZAPISANIE POZYCJI BAZY przy starcie
    local basePosition = hrp.Position

    -- Pomoc: bezpieczne odłączenie eventów
    local function safeDisconnect(conn)
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end

    local function onCharacterAdded(char)
        character = char
        humanoid = character:WaitForChild("Humanoid")
        hrp = character:WaitForChild("HumanoidRootPart")

        -- Reset parametry
        humanoid.WalkSpeed = speedValue
        humanoid.JumpPower = jumpPowerValue

        -- Ustawienie no clip i antyhit
        if noClipEnabled then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        if antiHitEnabled then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.5
                end
            end
        else
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    -- GUI

    local function genRandomName(len)
        local charset = {}
        for c = 48, 57  do table.insert(charset, string.char(c)) end -- 0-9
        for c = 65, 90  do table.insert(charset, string.char(c)) end -- A-Z
        for c = 97, 122 do table.insert(charset, string.char(c)) end -- a-z
        local name = ""
        for i = 1, len do
            name = name .. charset[math.random(1, #charset)]
        end
        return name
    end

    local guiName = genRandomName(12)
    local frameName = genRandomName(12)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = guiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 360)
    frame.Position = UDim2.new(0.8, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.85
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Name = frameName
    frame.Parent = ScreenGui
    frame.Visible = false -- start hidden

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = frame

    local function createButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.BackgroundTransparency = 0.15
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = text
        btn.AutoButtonColor = true
        btn.Parent = frame
        btn.ClipsDescendants = true
        btn.BorderSizePixel = 0

        btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.05 end)
        btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.15 end)

        btn.MouseButton1Click:Connect(function()
            if debounce then return end
            debounce = true
            callback()
            wait(0.2)
            debounce = false
        end)
        return btn
    end

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 50)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 14
    infoLabel.Text = "Chudy King v1.4\nAutor: ChatGPT\nBaza zapisana: " .. tostring(basePosition)
    infoLabel.TextWrapped = true
    infoLabel.Parent = frame

    -- Funkcje

    local function toggleNoClip()
        noClipEnabled = not noClipEnabled
        if noClipEnabled then
            noclipConnection = RunService.Stepped:Connect(function()
                if character then
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            infoLabel.Text = "Chudy King v1.4\nNoClip: ON\nBaza zapisana: " .. tostring(basePosition)
        else
            safeDisconnect(noclipConnection)
            noclipConnection = nil
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            infoLabel.Text = "Chudy King v1.4\nNoClip: OFF\nBaza zapisana: " .. tostring(basePosition)
        end
    end

    local function toggleAntiHit()
        antiHitEnabled = not antiHitEnabled
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = antiHitEnabled and 0.5 or 0
                end
            end
        end
        infoLabel.Text = "Chudy King v1.4\nAntiHit: " .. (antiHitEnabled and "ON" or "OFF") .. "\nBaza zapisana: " .. tostring(basePosition)
    end

    local function setSpeed(newSpeed)
        speedValue = newSpeed
        if humanoid then
            humanoid.WalkSpeed = speedValue
        end
        infoLabel.Text = "Chudy King v1.4\nSpeed: " .. speedValue .. "\nBaza zapisana: " .. tostring(basePosition)
    end

    local function setJumpPower(newJump)
        jumpPowerValue = newJump
        if humanoid then
            humanoid.JumpPower = jumpPowerValue
        end
        infoLabel.Text = "Chudy King v1.4\nJumpPower: " .. jumpPowerValue .. "\nBaza zapisana: " .. tostring(basePosition)
    end

    local function resetSpeedJump()
        setSpeed(16)
        setJumpPower(50)
    end

    local function hasBrainrot()
        if not character then return false end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and string.find(part.Name:lower(), "brainrot") then
                return true
            end
        end
        return false
    end

    local function teleportToBase()
        if not character or not hrp then
            infoLabel.Text = "Brak postaci lub HumanoidRootPart"
            return
        end

        if hasBrainrot() then
            hrp.CFrame = CFrame.new(basePosition)
            infoLabel.Text = "Teleportowano do bazy!\nBaza zapisana: " .. tostring(basePosition)
        else
            infoLabel.Text = "Nie masz wybranego Brainrota!\nBaza zapisana: " .. tostring(basePosition)
        end
    end

    createButton("Toggle NoClip", toggleNoClip)
    createButton("Toggle AntiHit", toggleAntiHit)
    createButton("Speed +5", function() setSpeed(speedValue + 5) end)
    createButton("Speed -5", function() setSpeed(math.max(16, speedValue - 5)) end)
    createButton("Jump +10", function() setJumpPower(jumpPowerValue + 10) end)
    createButton("Jump -10", function() setJumpPower(math.max(50, jumpPowerValue - 10)) end)
    createButton("Reset Speed/Jump", resetSpeedJump)
    createButton("Teleport do bazy", teleportToBase)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            frame.Visible = not frame.Visible
            if frame.Visible then
                frame.BackgroundTransparency = 0.5
                wait(0.15)
                frame.BackgroundTransparency = 0.85
            end
        end
    end)

    setSpeed(speedValue)
    setJumpPower(jumpPowerValue)
end
