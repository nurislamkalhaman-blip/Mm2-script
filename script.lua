local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Получаем доступ к PlayerGui локального игрока
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local uiName = "NeonGenesisUI"
-- Удаляем старую копию при перезапуске скрипта
if PlayerGui:FindFirstChild(uiName) then
    PlayerGui[uiName]:Destroy()
end

-- Цветовая палитра (Dark Minimalist)
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(124, 58, 237), -- Фиолетовый неон
    Text = Color3.fromRGB(255, 255, 255),
    Element = Color3.fromRGB(35, 35, 40),
    ElementHover = Color3.fromRGB(45, 45, 50)
}

-- Создаем ScreenGui прямо в PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false -- Важно: UI не пропадет при респавне
ScreenGui.Parent = PlayerGui

local Library = {}

function Library:CreateWindow(titleText)
    local Window = {}
    
    -- Плавающая кнопка для открытия/закрытия
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(0.95, -60, 0.5, -25)
    FloatingBtn.BackgroundColor3 = Theme.Accent
    FloatingBtn.Text = "UI"
    FloatingBtn.TextColor3 = Theme.Text
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.TextSize = 18
    FloatingBtn.Parent = ScreenGui
    
    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0) -- Делает кнопку круглой
    FloatCorner.Parent = FloatingBtn

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 300) -- Оптимальный размер для телефонов и ПК
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    -- Верхняя панель (Topbar)
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    -- Контейнер со скроллом для элементов
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -55)
    ContentContainer.Position = UDim2.new(0, 10, 0, 48)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 3
    ContentContainer.ScrollBarImageColor3 = Theme.Accent
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Авторасширение
    ContentContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ContentContainer
    
    -- Автоматическое управление размером скролла при добавлении кнопок
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Перетаскивание окна (работает и на смартфонах)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- Плавное появление (Quint анимация)
    local isOpen = false
    FloatingBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 450, 0, 300),
                Position = UDim2.new(0.5, -225, 0.5, -150)
            }):Play()
        else
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            tween:Play()
            tween.Completed:Wait()
            if not isOpen then MainFrame.Visible = false end
        end
    end)
    
    -- Кнопка обычная
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 38)
        Button.BackgroundColor3 = Theme.Element
        Button.Text = "  " .. text
        Button.TextColor3 = Theme.Text
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 14
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.Parent = ContentContainer
        
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
        
        Button.MouseButton1Click:Connect(function()
            local clickTween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
            clickTween:Play()
            clickTween.Completed:Wait()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
            if callback then callback() end
        end)
    end

    -- Переключатель On/Off (Toggle)
    function Window:AddToggle(text, default, callback)
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
        ToggleFrame.BackgroundColor3 = Theme.Element
        ToggleFrame.Text = ""
        ToggleFrame.AutoButtonColor = false
        ToggleFrame.Parent = ContentContainer
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 38, 0, 20)
        Indicator.Position = UDim2.new(1, -48, 0.5, -10)
        Indicator.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 55, 60)
        Indicator.Parent = ToggleFrame
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
        
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = UDim2.new(0, default and 20 or 2, 0.5, -8)
        Circle.BackgroundColor3 = Color3.new(1, 1, 1)
        Circle.Parent = Indicator
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        
        local state = default
        ToggleFrame.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 60)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, state and 20 or 2, 0.5, -8)}):Play()
            if callback then callback(state) end
        end)
    end
    
    return Window
end

return Library

-- Инициализируем библиотеку
local MainWin = Library:CreateWindow("Delta Exploit Hub")

-- Создаем обычную кнопку
MainWin:AddButton("Активировать Fly (Полет)", function()
    print("Скрипт на полет успешно запущен!")
    -- Сюда вставляешь любой свой тяжелый скрипт на полет
end)

-- Создаем тумблер On/Off
MainWin:AddToggle("Бесконечные патроны", false, function(toggleState)
    if toggleState then
        print("Функция включена!")
    else
        print("Функция выключена!")
    end
end)
