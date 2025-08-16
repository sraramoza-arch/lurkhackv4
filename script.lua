--[[
    LurkhackV4 Ultimate - Zaawansowany multi-tool do Roblox
    Autor: sraramoza-arch (2024)
    Poprawka pod DeltaExecutor: parentowanie GUI do PlayerGui
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local myBase = nil
local gui, btn, notif, healBtn, playerList, marker, closeBtn
local cooldown = false

-- Ustawienia GUI
local guiColor = Color3.fromRGB(42, 142, 255)
local accentColor = Color3.fromRGB(35, 220, 60)
local errorColor = Color3.fromRGB(255, 45, 45)

-- Pomocnicze funkcje
local function playSound(id, vol)
    local s = Instance.new("Sound", game.SoundService)
    s.SoundId = "rbxassetid://"..tostring(id)
    s.Volume = vol or 0.6
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

local function showNotification(msg, color, time)
    notif.Text = msg
    notif.TextColor3 = color or Color3.new(1,1,1)
    notif.Visible = true
    wait(time or 2.5)
    notif.Visible = false
end

local function getBasePosition(base)
    if not base then return nil end
    if base:IsA("BasePart") then
        return base.Position
    elseif base:IsA("Model") and base.PrimaryPart then
        return base.PrimaryPart.Position
    elseif base:IsA("Folder") then
        for _,v in ipairs(base:GetChildren()) do
            if v:IsA("BasePart") then
                return v.Position
            elseif v:IsA("Model") and v.PrimaryPart then
                return v.PrimaryPart.Position
            end
        end
    end
    return nil
end

local function markBaseOnMap(pos)
    if marker then marker:Destroy() end
    marker = Instance.new("Part")
    marker.Anchored = true
    marker.CanCollide = false
    marker.Size = Vector3.new(1,1,1)
    marker.Shape = Enum.PartType.Ball
    marker.Position = pos
    marker.Color = Color3.fromRGB(255, 255, 0)
    marker.Material = Enum.Material.Neon
    marker.Transparency = 0.3
    marker.Parent = workspace
    game:GetService("Debris"):AddItem(marker, 20)
end

-- Wykrywanie bazy (Part, Model, Folder)
local function findMyBase()
    local myPos = char:WaitForChild("HumanoidRootPart").Position
    local minDist, nearestBase = math.huge, nil
    for _, obj in ipairs(workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("base") or name:find("baza") or name:find("safe") or name:find("dom") then
            local pos = getBasePosition(obj)
            if pos then
                local dist = (pos - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestBase = obj
                end
            end
        end
    end
    return nearestBase
end

-- Automatyczna detekcja bazy po respawnie
local function setupBaseDetection()
    repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    char = player.Character
    myBase = findMyBase()
    if myBase then
        local bpos = getBasePosition(myBase)
        showNotification("Baza wykryta: "..myBase.Name, accentColor)
        if bpos then markBaseOnMap(bpos) end
    else
        showNotification("Nie znaleziono bazy!", errorColor)
    end
end
player.CharacterAdded:Connect(setupBaseDetection)
setupBaseDetection()

-- GUI setup (parent do PlayerGui zamiast CoreGui)
local function createGui()
    if gui and gui.Parent then gui:Destroy() end
    gui = Instance.new("ScreenGui")
    gui.Name = "LurkhackV4Ultimate"
    gui.Parent = player:WaitForChild("PlayerGui")

    btn = Instance.new("TextButton", gui)
    btn.Text = "Szybki powrót do bazy"
    btn.Size = UDim2.new(0,220,0,40)
    btn.Position = UDim2.new(0,100,0,120)
    btn.BackgroundColor3 = guiColor
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.Draggable = true

    healBtn = Instance.new("TextButton", gui)
    healBtn.Text = "Autoheal"
    healBtn.Size = UDim2.new(0,120,0,28)
    healBtn.Position = UDim2.new(0,100,0,170)
    healBtn.BackgroundColor3 = accentColor
    healBtn.TextSize = 16
    healBtn.Font = Enum.Font.Gotham
    healBtn.Draggable = true

    closeBtn = Instance.new("TextButton", gui)
    closeBtn.Text = "✖"
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(0,100,0,220)
    closeBtn.BackgroundColor3 = errorColor
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Draggable = true

    notif = Instance.new("TextLabel", gui)
    notif.Size = UDim2.new(0.35,0,0,32)
    notif.Position = UDim2.new(0.32,0,0,36)
    notif.BackgroundTransparency = 1
    notif.Text = ""
    notif.Visible = false
    notif.Font = Enum.Font.GothamBold
    notif.TextScaled = true
    notif.ZIndex = 10

    -- Lista graczy do teleportu
    playerList = Instance.new("Frame", gui)
    playerList.Size = UDim2.new(0,160,0,140)
    playerList.Position = UDim2.new(0,340,0,120)
    playerList.BackgroundColor3 = Color3.fromRGB(55,55,55)
    playerList.Visible = true
    playerList.Draggable = true

    local plabel = Instance.new("TextLabel", playerList)
    plabel.Size = UDim2.new(1,0,0,28)
    plabel.Position = UDim2.new(0,0,0,0)
    plabel.BackgroundTransparency = 1
    plabel.Text = "Teleport do gracza:"
    plabel.Font = Enum.Font.GothamBold
    plabel.TextSize = 16
    plabel.TextColor3 = accentColor

    local function refreshPlayerList()
        for _,obj in ipairs(playerList:GetChildren()) do
            if obj:IsA("TextButton") then obj:Destroy() end
        end
        local y = 28
        for _,pl in ipairs(game.Players:GetPlayers()) do
            if pl ~= player then
                local plyBtn = Instance.new("TextButton", playerList)
                plyBtn.Text = pl.DisplayName
                plyBtn.Size = UDim2.new(1,0,0,22)
                plyBtn.Position = UDim2.new(0,0,0,y)
                plyBtn.BackgroundColor3 = guiColor
                plyBtn.TextSize = 14
                plyBtn.Font = Enum.Font.Gotham
                plyBtn.MouseButton1Click:Connect(function()
                    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")) then
                        showNotification("Gracz jest martwy!", errorColor)
                        playSound(12221967, 0.3)
                        return
                    end
                    local hrp = player.Character.HumanoidRootPart
                    local target = pl.Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
                    hrp.CFrame = CFrame.new(target)
                    showNotification("Teleport do "..pl.DisplayName, accentColor)
                    playSound(9118822329, 0.7)
                end)
                y = y + 24
            end
        end
    end
    refreshPlayerList()
    game.Players.PlayerAdded:Connect(function() wait(1) refreshPlayerList() end)
    game.Players.PlayerRemoving:Connect(function() wait(1) refreshPlayerList() end)

    -- Funkcja teleportu do bazy
    btn.MouseButton1Click:Connect(function()
        if cooldown then showNotification("Odczekaj chwilę...", errorColor) playSound(12221967, 0.3) return end
        if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
            showNotification("Musisz być żywy!", errorColor)
            playSound(12221967, 0.3)
            return
        end
        if myBase then
            local basePos = getBasePosition(myBase)
            if not basePos then
                showNotification("Nie mogę znaleźć pozycji bazy!", errorColor)
                playSound(12221967, 0.3)
                return
            end
            cooldown = true
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(basePos + Vector3.new(0,4,0))
            playSound(9118822329, 0.7)
            showNotification("Teleportowano do bazy!", accentColor)
            markBaseOnMap(basePos)
            wait(2.5)
            cooldown = false
        else
            showNotification("Brak wykrytej bazy!", errorColor)
            playSound(12221967, 0.3)
        end
    end)

    -- Autoheal
    healBtn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
                showNotification("Autoheal wykonany!", accentColor)
                playSound(184020026, 0.7)
            else
                showNotification("Masz pełne zdrowie!", accentColor)
            end
        else
            showNotification("Brak humanoida!", errorColor)
        end
    end)

    -- Zamknięcie GUI/skryptu
    closeBtn.MouseButton1Click:Connect(function()
        showNotification("Wyłączanie skryptu...", errorColor, 1.2)
        gui:Destroy()
        if marker then marker:Destroy() end
    end)

    showNotification("LurkhackV4 Ultimate włączony!", accentColor, 2.5)
end

createGui()

-- Autoregeneracja GUI po respawnie
player.CharacterAdded:Connect(function()
    wait(1)
    createGui()
    setupBaseDetection()
end)

-- KONIEC SKRYPTU
