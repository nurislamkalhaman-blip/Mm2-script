local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0,50,0,50)
Btn.Position = UDim2.new(1, -110, 1, -220)
Btn.AnchorPoint = Vector2.new(0.5, 0.5)
Btn.Text = "Tp"
Btn.TextSize = 18
Btn.Font = Enum.Font.GothamBold
Btn.BackgroundColor3 = Color3.new(224,224,224)
Btn.TextColor3 = Color3.new(0,0,0)
Btn.OutlineColor = Color3.new(0,0,0)
Btn.Parent = ScreenGui

local PlayerPos = nil

local function PlayerPosGet()
  local Char = LocalPlayer.Character
  if Char and Char:FindFirstChild("HumanoidRootPart") then
    PlayerPos = Char.HumanoidRootPart.CFrame
  end
end

local function Teleport()
  local Char = LocalPlayer.Character
  if Char and Char:FindFirstChild("HumanoidRootPart") then
    if PlayerPos ~= nil then
      Char.HumanoidRootPart.CFrame = PlayerPos
    end
  end
end


  

