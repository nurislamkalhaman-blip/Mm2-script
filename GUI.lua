local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ExistingGui = PlayerGui:FindFirstChild("UiName")

if ExistingGui then
ExistingGui:Destroy()

else

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "UiName"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Name = "Frame1"
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.Parent = ScreenGui
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(255,255,255)
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0,400,0,300)
end
