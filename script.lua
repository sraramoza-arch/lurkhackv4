local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local myBase = nil

-- Automatyczne wykrywanie bazy po starcie gry
local function findMyBase()
    local myPos = char:WaitForChild("HumanoidRootPart").Position
    local minDist, nearestBase = math.huge, nil
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (
            obj.Name:lower():find("base") or
            obj.Name:lower():find("baza") or
            obj.Name:lower():find("safe")
        ) then
            local dist = (obj.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                nearestBase = obj
            end
        end
    end
    return nearestBase
end

-- Detekcja po respawnie i na starcie
local function setupBaseDetection()
    repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    char = player.Character
    myBase = findMyBase()
end
player.CharacterAdded:Connect(setupBaseDetection)
setupBaseDetection()

-- GUI z przyciskiem
local gui = Instance.new("ScreenGui", game.CoreGui)
local btn = Instance.new("TextButton", gui)
btn.Text = "Szybko do bazy"
btn.Size = UDim2.new(0,200,0,50)
btn.Position = UDim2.new(0,100,0,100)
btn.BackgroundColor3 = Color3.fromRGB(45,170,45)
btn.TextSize = 22

-- Szybki płynny ruch (Tween, 0.4 sekundy)
local TweenService = game:GetService("TweenService")
btn.MouseButton1Click:Connect(function()
    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
    if myBase then
        local hrp = player.Character.HumanoidRootPart
        local targetPos = myBase.Position -- tylko do bazy, nie nad nią
        local tweenInfo = TweenInfo.new(
            0.4, -- czas ruchu (0.4 sekundy = bardzo szybko)
            Enum.EasingStyle.Linear
        )
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 0 end
        local tween = TweenService:Create(hrp, tweenInfo, {Position = targetPos})
        tween:Play()
        tween.Completed:Wait()
        if hum then hum.WalkSpeed = 16 end
    end
end) 
