local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Flaga trybu anty-hit
local antiHitActive = false

-- Stworzenie GUI z przyciskiem
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AntiHitGui"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 140, 0, 50)
button.Position = UDim2.new(1, -160, 0.5, -25)  -- po prawej stronie, środek pionowo
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22
button.Text = "Anty-hit: WYŁ."
button.Parent = ScreenGui

-- Funkcja aktywująca anty-hit
local function activateAntiHit()
    antiHitActive = true
    button.Text = "Anty-hit: WŁ."
    
    -- Zamiana w bloczek
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0.2
            part.Size = Vector3.new(1,1,1)
            part.BrickColor = BrickColor.new("Really black")
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    
    humanoid.PlatformStand = true -- blokuje fizykę
    
    -- Blokowanie obrażeń
    humanoid.HealthChanged:Connect(function(health)
        if antiHitActive and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

-- Funkcja dezaktywująca anty-hit
local function deactivateAntiHit()
    antiHitActive = false
    button.Text = "Anty-hit: WYŁ."
    
    humanoid.PlatformStand = false
    
    -- Przywróć wygląd
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
            part.Size = Vector3.new(2, 2, 1) -- dostosuj jeśli trzeba
            part.BrickColor = BrickColor.new("Medium stone grey")
            part.Material = Enum.Material.Plastic
        end
    end
end

-- Przełączanie trybu po kliknięciu
button.MouseButton1Click:Connect(function()
    if antiHitActive then
        deactivateAntiHit()
    else
        activateAntiHit()
    end
end)
