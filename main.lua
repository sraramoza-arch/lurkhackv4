local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Flaga trybu anty-hit
local antiHitActive = false

-- Stworzenie prostego GUI z przyciskiem
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AntiHitGui"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 140, 0, 50)
button.Position = UDim2.new(0.5, -70, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22
button.Text = "Anty-hit: WYŁ."
button.Parent = ScreenGui

-- Zmiana wyglądu na bloczek
local function activateAntiHit()
    antiHitActive = true
    button.Text = "Anty-hit: WŁ."
    
    -- Zmniejsz rozmiar i zmień wygląd
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0.2
            part.Size = Vector3.new(1,1,1)
            part.BrickColor = BrickColor.new("Really black")
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    
    humanoid.PlatformStand = true -- blokuje fizykę postaci by uniknąć odrzutu
    
    -- Anti hit - blokowanie obrażeń
    humanoid.HealthChanged:Connect(function(health)
        if antiHitActive and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function deactivateAntiHit()
    antiHitActive = false
    button.Text = "Anty-hit: WYŁ."
    
    -- Przywróć normalny wygląd
    character:WaitForChild("Humanoid").PlatformStand = false
    
    -- Przywróć rozmiary i wygląd
    -- Możesz rozszerzyć o przywrócenie oryginalnych wartości jeśli masz zapisane wcześniej
    -- Tutaj na szybko przywracamy standardowe wartości
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
            part.Size = Vector3.new(2, 2, 1) -- standardowe rozmiary np. tu dostosuj do modelu
            part.BrickColor = BrickColor.new("Medium stone grey")
            part.Material = Enum.Material.Plastic
        end
    end
end

button.MouseButton1Click:Connect(function()
    if antiHitActive then
        deactivateAntiHit()
    else
        activateAntiHit()
    end
end)
