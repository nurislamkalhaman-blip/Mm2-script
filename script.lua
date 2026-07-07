-- ==========================================
-- ЧАСТЬ 1: ОСНОВА GUI И АНИМАЦИИ ОТКРЫТИЯ
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Настраиваем защиту для Экзекуторов (если gethui() нет, кидаем в PlayerGui)
local targetGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Delta_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetGui

-- Цветовая палитра (Темная тема)
local Colors = {
    MainBg = Color3.fromRGB(25, 25, 30),
    SidebarBg = Color3.fromRGB(18, 18, 22),
    ElementBg = Color3.fromRGB(35, 35, 42),
    Accent = Color3.fromRGB(80, 200, 120), -- Зеленый
    Red = Color3.fromRGB(220, 60, 60),
    Text = Color3.fromRGB(240, 240, 240)
}

-- Плавающая кнопка для открытия/закрытия (удобно для телефона)
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleGuiBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleGuiBtn.BackgroundColor3 = Colors.Accent
ToggleGuiBtn.Text = "🔮"
ToggleGuiBtn.TextSize = 25
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0) -- Круглая кнопка
ToggleCorner.Parent = ToggleGuiBtn

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Colors.MainBg
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Боковая панель для вкладок
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Colors.SidebarBg
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingBottom = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 5)
SidebarPadding.PaddingRight = UDim.new(0, 5)
SidebarPadding.Parent = Sidebar

-- Контейнер для содержимого вкладок
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -120, 1, 0)
ContentContainer.Position = UDim2.new(0, 120, 0, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Логика скрытия/показа GUI с анимацией
local isGuiOpen = true
ToggleGuiBtn.MouseButton1Click:Connect(function()
    isGuiOpen = not isGuiOpen
    local targetSize = isGuiOpen and UDim2.new(0, 500, 0, 300) or UDim2.new(0, 0, 0, 0)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize})
    tween:Play()
end)

-- Драг (возможность перетаскивать окно, актуально даже на мобилках)
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)
-- ==========================================
-- ЧАСТЬ 2: ГЕНЕРАТОР ЭЛЕМЕНТОВ
-- ==========================================

local Library = {}
local TabsList = {}

-- 1. Функция создания Вкладки (Tab)
function Library:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Colors.ElementBg
    TabButton.Text = name
    TabButton.TextColor3 = Colors.Text
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 14
    TabButton.Parent = Sidebar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    -- Скрытый фрейм для элементов этой вкладки
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = false
    TabFrame.Parent = ContentContainer

    -- АВТО-РАЗМЕТКА (Именно она не дает элементам слипаться!)
    local FrameLayout = Instance.new("UIListLayout")
    FrameLayout.Padding = UDim.new(0, 10)
    FrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
    FrameLayout.Parent = TabFrame

    local FramePadding = Instance.new("UIPadding")
    FramePadding.PaddingTop = UDim.new(0, 10)
    FramePadding.PaddingLeft = UDim.new(0, 10)
    FramePadding.PaddingRight = UDim.new(0, 10)
    FramePadding.Parent = TabFrame

    table.insert(TabsList, {Btn = TabButton, Frame = TabFrame})

    -- Логика переключения вкладок
    TabButton.MouseButton1Click:Connect(function()
        for _, tabInfo in ipairs(TabsList) do
            tabInfo.Frame.Visible = false
            tabInfo.Btn.BackgroundColor3 = Colors.ElementBg
        end
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = Colors.Accent
    end)

    -- Делаем первую вкладку активной по умолчанию
    if #TabsList == 1 then
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = Colors.Accent
    end

    local TabElements = {}

    -- 2. Функция создания базовой кнопки
    function TabElements:CreateButton(btnText, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.BackgroundColor3 = Colors.ElementBg
        Button.Text = btnText
        Button.TextColor3 = Colors.Text
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 14
        Button.Parent = TabFrame
        
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Button.MouseButton1Click:Connect(function()
            -- Анимация клика
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Accent}):Play()
            task.wait(0.1)
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Colors.ElementBg}):Play()
            callback()
        end)
    end

    -- 3. Функция создания Тумблера (Toggle: Вкл/Выкл) с красно-зеленой анимацией
    function TabElements:CreateToggle(toggleText, callback)
        local toggled = false

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
        ToggleBtn.BackgroundColor3 = Colors.ElementBg
        ToggleBtn.Text = "   " .. toggleText
        ToggleBtn.TextColor3 = Colors.Text
        ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ToggleBtn.Font = Enum.Font.GothamSemibold
        ToggleBtn.TextSize = 14
        ToggleBtn.Parent = TabFrame
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

        local IndicatorBg = Instance.new("Frame")
        IndicatorBg.Size = UDim2.new(0, 40, 0, 20)
        IndicatorBg.Position = UDim2.new(1, -50, 0.5, -10)
        IndicatorBg.BackgroundColor3 = Colors.Red -- По умолчанию красный
        IndicatorBg.Parent = ToggleBtn
        Instance.new("UICorner", IndicatorBg).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = UDim2.new(0, 2, 0.5, -8)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Parent = IndicatorBg
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        ToggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            local goalPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local goalColor = toggled and Colors.Accent or Colors.Red

            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = goalPos}):Play()
            TweenService:Create(IndicatorBg, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
            
            callback(toggled)
        end)
    end

    -- 4. Функция создания Слайдера (Ползунка) - Идеально для Delta / Touch
    function TabElements:CreateSlider(sliderText, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundColor3 = Colors.ElementBg
        SliderFrame.Parent = TabFrame
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = sliderText .. ": " .. tostring(min)
        Label.TextColor3 = Colors.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 14
        Label.Parent = SliderFrame

        local BarBg = Instance.new("Frame")
        BarBg.Size = UDim2.new(1, -20, 0, 8)
        BarBg.Position = UDim2.new(0, 10, 0, 30)
        BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        BarBg.Parent = SliderFrame
        Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Colors.Accent
        Fill.Parent = BarBg
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = sliderText .. ": " .. tostring(value)
            callback(value)
        end

        SliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end

    -- Авто-коррекция скролла (чтобы можно было листать список вниз)
    TabFrame.ChildAdded:Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, FrameLayout.AbsoluteContentSize.Y + 20)
    end)

    return TabElements
end
-- ==========================================
-- ЧАСТЬ 3: СОЗДАНИЕ МЕНЮ И ЭЛЕМЕНТОВ
-- ==========================================

-- Создаем вкладки
local CombatTab = Library:CreateTab("🗡 Combat")
local AimTab = Library:CreateTab("🎯 Aim")
local TeleportTab = Library:CreateTab("🏃 Teleport")

-- Заполняем Вкладку Combat
CombatTab:CreateToggle("Auto-Hit (Авто-удар)", function(state)
    if state then
        print("Авто-удар включен! Зеленый цвет работает.")
    else
        print("Авто-удар выключен! Красный цвет.")
    end
end)

CombatTab:CreateButton("Убить всех (Тест)", function()
    print("Кнопка Убить всех нажата!")
end)

CombatTab:CreateSlider("Скорость атаки", 1, 100, function(value)
    print("Скорость установлена на: " .. value)
end)

-- Заполняем Вкладку Aim
AimTab:CreateToggle("Aimbot Нож", function(state)
    print("Аимбот статус: " .. tostring(state))
end)

AimTab:CreateToggle("Показать Хитбоксы", function(state)
    print("Хитбоксы: " .. tostring(state))
end)

AimTab:CreateSlider("Размер хитбокса", 1, 25, function(value)
    print("Новый размер хитбокса: " .. value)
end)

-- Заполняем Вкладку Teleport
TeleportTab:CreateButton("ТП к Лобби", function()
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        -- Пример базового ТП (координаты лобби нужно менять под конкретную карту MM2)
        print("Телепортация в Лобби...")
    end
end)

TeleportTab:CreateButton("ТП к Шерифу", function()
    print("Ищу шерифа и телепортируюсь...")
end)

TeleportTab:CreateToggle("Авто-ТП Gun Drop", function(state)
    print("ТП к пистолету: " .. tostring(state))
end)

print("🚀 Скрипт GUI успешно загружен! Нажми на 🔮 на экране.")
