local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Удаляем старый UI, если скрипт перезапускается
local uiName = "NeonGenesisUI"
if CoreGui:FindFirstChild(uiName) then
    CoreGui[uiName]:Destroy()
end

-- Основные настройки стиля
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(124, 58, 237), -- Неоновый фиолетовый
    Text = Color3.fromRGB(255, 255, 255),
    Element = Color3.fromRGB(35, 35, 40),
    ElementHover = Color3.fromRGB(45, 45, 50)
}

-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
-- Безопасность для инжекторов (используем gethui если доступно, иначе CoreGui)
local success, hui = pcall(function() return gethui() end)
ScreenGui.Parent = success and hui or CoreGui

local Library = {}

function Library:CreateWindow(titleText)
    local Window = {}
    
    -- Плавающая кнопка
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(0.95, -60, 0.5, -25)
    FloatingBtn.BackgroundColor3 = Theme.Accent
    FloatingBtn.Text = "UI"
    FloatingBtn.TextColor3 = Theme.Text
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.TextSize = 20
    FloatingBtn.Parent = ScreenGui
    
    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatingBtn

    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -50)
    ContentContainer.Position = UDim2.new(0, 10, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ContentContainer

    -- Анимация открытия/закрытия
    local isOpen = false
    FloatingBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 500, 0, 350),
                Position = UDim2.new(0.5, -250, 0.5, -175)
            }):Play()
        else
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            tween:Play()
            tween.Completed:Wait()
            MainFrame.Visible = false
        end
    end)
    
    -- API для создания элементов
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = Theme.Element
        Button.Text = text
        Button.TextColor3 = Theme.Text
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 14
        Button.AutoButtonColor = false
        Button.Parent = ContentContainer
        
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            -- Анимация клика
            local clickTween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
            clickTween:Play()
            clickTween.Completed:Wait()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
            
            if callback then callback() end
        end)
    end

    function Window:AddToggle(text, default, callback)
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
        ToggleFrame.BackgroundColor3 = Theme.Element
        ToggleFrame.Text = ""
        ToggleFrame.AutoButtonColor = false
        ToggleFrame.Parent = ContentContainer
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 40, 0, 20)
        Indicator.Position = UDim2.new(1, -50, 0.5, -10)
        Indicator.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 60, 65)
        Indicator.Parent = ToggleFrame
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
        
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = UDim2.new(0, default and 22 or 2, 0.5, -8)
        Circle.BackgroundColor3 = Color3.new(1, 1, 1)
        Circle.Parent = Indicator
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        
        local state = default
        ToggleFrame.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 65)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}):Play()
            if callback then callback(state) end
        end)
    end
    
    return Window
end

return Library
