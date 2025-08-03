local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "NoclipGUI"

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 100, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 100)
Button.Text = "Noclip: OFF"
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.BorderSizePixel = 2
Button.Draggable = true
Button.Active = true

local noclip = false

Button.MouseButton1Click:Connect(function()
    noclip = not noclip
    Button.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
