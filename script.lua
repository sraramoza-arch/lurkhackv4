local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local gui, btn, healBtn, closeBtn, notif, playerList, marker
local myBase, cooldown = nil, false

local function getBasePosition(base)
    if not base then return end
    if base:IsA("BasePart") then return base.Position end
    if base:IsA("Model") and base.PrimaryPart then return base.PrimaryPart.Position end
    if base:IsA("Folder") then
        for _,v in ipairs(base:GetChildren()) do
            if v:IsA("BasePart") then return v.Position end
            if v:IsA("Model") and v.PrimaryPart then return v.PrimaryPart.Position end
        end
    end
end

local function findBase()
    local myPos = char:WaitForChild("HumanoidRootPart").Position
    local minDist, found = math.huge, nil
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("base") or n:find("baza") or n:find("safe") or n:find("dom") then
            local pos = getBasePosition(obj)
            if pos then
                local dist = (pos-myPos).Magnitude
                if dist < minDist then minDist, found = dist, obj end
            end
        end
    end
    return found
end

local function setupBase()
    repeat wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    char = plr.Character
    myBase = findBase()
end
plr.CharacterAdded:Connect(setupBase)
setupBase()

local function createGui()
    if gui then gui:Destroy() end
    gui = Instance.new("ScreenGui")
    gui.Parent = plr.PlayerGui

    btn = Instance.new("TextButton", gui)
    btn.Text = "TP do bazy"
    btn.Size = UDim2.new(0,160,0,32)
    btn.Position = UDim2.new(0,0,0,120)
    btn.BackgroundColor3 = Color3.fromRGB(42,142,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16

    healBtn = Instance.new("TextButton", gui)
    healBtn.Text = "Autoheal"
    healBtn.Size = UDim2.new(0,100,0,26)
    healBtn.Position = UDim2.new(0,0,0,160)
    healBtn.BackgroundColor3 = Color3.fromRGB(35,220,60)
    healBtn.Font = Enum.Font.Gotham
    healBtn.TextSize = 14

    closeBtn = Instance.new("TextButton", gui)
    closeBtn.Text = "✖"
    closeBtn.Size = UDim2.new(0,26,0,26)
    closeBtn.Position = UDim2.new(0,0,0,200)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255,45,45)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16

    notif = Instance.new("TextLabel", gui)
    notif.Size = UDim2.new(0,200,0,26)
    notif.Position = UDim2.new(0,170,0,120)
    notif.BackgroundTransparency = 1
    notif.Text = ""
    notif.Visible = false
    notif.Font = Enum.Font.GothamBold
    notif.TextScaled = true

    playerList = Instance.new("Frame", gui)
    playerList.Size = UDim2.new(0,140,0,120)
    playerList.Position = UDim2.new(0,170,0,160)
    playerList.BackgroundColor3 = Color3.fromRGB(55,55,55)

    local plabel = Instance.new("TextLabel", playerList)
    plabel.Size = UDim2.new(1,0,0,20)
    plabel.Position = UDim2.new(0,0,0,0)
    plabel.BackgroundTransparency = 1
    plabel.Text = "TP do gracza"
    plabel.Font = Enum.Font.GothamBold
    plabel.TextSize = 14
    plabel.TextColor3 = Color3.fromRGB(35,220,60)

    local function refreshPlayers()
        for _,c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local y = 20
        for _,p in ipairs(game.Players:GetPlayers()) do
            if p ~= plr then
                local b = Instance.new("TextButton", playerList)
                b.Text = p.DisplayName
                b.Size = UDim2.new(1,0,0,18)
                b.Position = UDim2.new(0,0,0,y)
                b.BackgroundColor3 = Color3.fromRGB(42,142,255)
                b.Font = Enum.Font.Gotham
                b.TextSize = 12
                b.MouseButton1Click:Connect(function()
                    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then return end
                    plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
                    notif.Text = "TP do "..p.DisplayName
                    notif.Visible = true
                    wait(1.5)
                    notif.Visible = false
                end)
                y = y + 18
            end
        end
    end
    refreshPlayers()
    game.Players.PlayerAdded:Connect(function() wait(1) refreshPlayers() end)
    game.Players.PlayerRemoving:Connect(function() wait(1) refreshPlayers() end)

    btn.MouseButton1Click:Connect(function()
        if cooldown then return end
        if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then return end
        if myBase then
            local bp = getBasePosition(myBase)
            if bp then
                cooldown = true
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(bp + Vector3.new(0,4,0))
                notif.Text = "TP do bazy"
                notif.Visible = true
                wait(1.5)
                notif.Visible = false
                cooldown = false
            end
        end
    end)

    healBtn.MouseButton1Click:Connect(function()
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character:FindFirstChildOfClass("Humanoid").Health = plr.Character:FindFirstChildOfClass("Humanoid").MaxHealth
            notif.Text = "Autoheal"
            notif.Visible = true
            wait(1)
            notif.Visible = false
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if marker then marker:Destroy() end
    end)
end

createGui()
plr.CharacterAdded:Connect(function()
    wait(1)
    createGui()
    setupBase()
end)
