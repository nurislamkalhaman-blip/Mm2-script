print("--- ЗАПУСК UI СКРИПТА v2 ---")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local uiName = "NeonGenesisUI_V2"

if PlayerGui:FindFirstChild(uiName) then
    PlayerGui[uiName]:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 35),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(124, 58, 237),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 155),
    Element = Color3.fromRGB(35, 35, 40)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Универсальная функция для перетаскивания (теперь работает и для окна, и для кнопки)
local function MakeDraggable(dragArea, moveTarget)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local Library = {}

function Library:CreateWindow(titleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Плавающая кнопка
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(1, -70, 0.5, -25)
    FloatingBtn.BackgroundColor3 = Theme.Accent
    FloatingBtn.Text = "UI"
    FloatingBtn.TextColor3 = Theme.Text
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.TextSize = 18
    FloatingBtn.Parent = ScreenGui
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
    
    -- Делаем кнопку перетаскиваемой!
    MakeDraggable(FloatingBtn, FloatingBtn)

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    
    -- Верхняя панель
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Parent = MainFrame
    MakeDraggable(Topbar, MainFrame) -- Окно перетаскивается за Topbar
    
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

    -- Боковая панель для вкладок
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 120, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    -- Контейнер для содержимого вкладок (правая часть)
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -120, 1, -40)
    ContentArea.Position = UDim2.new(0, 120, 0, 40)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Изменение размера окна (Уголок внизу справа)
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = "◢"
    ResizeHandle.TextColor3 = Theme.Accent
    ResizeHandle.TextSize = 14
    ResizeHandle.Parent = MainFrame

    local resizing, resizeStart, startSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    ResizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local resizeInput = input
            UserInputService.InputChanged:Connect(function(inpt)
                if inpt == resizeInput and resizing then
                    local delta = inpt.Position - resizeStart
                    -- Ограничиваем минимальный и максимальный размер окна
                    local newWidth = math.clamp(startSize.X.Offset + delta.X, 350, 800)
                    local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 250, 600)
                    MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end)
        end
    end)

    -- Открытие/Закрытие по плавающей кнопке (игнорируем клик, если мы ее перетаскивали)
    local isOpen = false
    local clickTime = 0
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            clickTime = tick()
        end
    end)
    FloatingBtn.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and (tick() - clickTime < 0.2) then
            isOpen = not isOpen
            MainFrame.Visible = isOpen
            if isOpen then
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 350)}):Play()
            end
        end
    end)

    -- ФУНКЦИЯ ДОБАВЛЕНИЯ ВКЛАДОК
    function Window:AddTab(tabName)
        local Tab = {}
        
        -- Кнопка вкладки в сайдбаре
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 14
        TabBtn.Parent = Sidebar
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 1, -10)
        Indicator.Position = UDim2.new(0, 0, 0, 5)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.Visible = false
        Indicator.Parent = TabBtn
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

        -- Страница вкладки
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, -20, 1, -20)
        TabPage.Position = UDim2.new(0, 10, 0, 10)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.Visible = false
        TabPage.Parent = ContentArea
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        table.insert(Window.Tabs, {Btn = TabBtn, Page = TabPage, Ind = Indicator})

        -- Логика переключения
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                t.Btn.TextColor3 = Theme.TextDark
                t.Ind.Visible = false
            end
            TabPage.Visible = true
            TabBtn.TextColor3 = Theme.Text
            Indicator.Visible = true
        end)

        -- Делаем первую созданную вкладку активной по умолчанию
        if #Window.Tabs == 1 then
            TabPage.Visible = true
            TabBtn.TextColor3 = Theme.Text
            Indicator.Visible = true
        end

        -- ФУНКЦИИ ВНУТРИ ВКЛАДКИ (Кнопки, Тумблеры)
        function Tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 38)
            Button.BackgroundColor3 = Theme.Element
            Button.Text = "  " .. text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.GothamSemibold
            Button.TextSize = 14
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.AutoButtonColor = false
            Button.Parent = TabPage
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            
            Button.MouseButton1Click:Connect(function()
                local tween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
                tween:Play()
                tween.Completed:Wait()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
                if callback then callback() end
            end)
        end

        function Tab:AddToggle(text, default, callback)
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, 0, 0, 38)
            ToggleBtn.BackgroundColor3 = Theme.Element
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Parent = TabPage
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleBtn
            
            local Ind = Instance.new("Frame")
            Ind.Size = UDim2.new(0, 38, 0, 20)
            Ind.Position = UDim2.new(1, -48, 0.5, -10)
            Ind.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 55, 60)
            Ind.Parent = ToggleBtn
            Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = UDim2.new(0, default and 20 or 2, 0.5, -8)
            Circle.BackgroundColor3 = Color3.new(1, 1, 1)
            Circle.Parent = Ind
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
            
            local state = default
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 55, 60)}):Play()
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 20 or 2, 0.5, -8)}):Play()
                if callback then callback(state) end
            end)
        end
        
        return Tab
    end
    
    return Window
end

------------------------------------------------------
-- КАК ЭТИМ ПОЛЬЗОВАТЬСЯ (Пишем свои читы тут)
------------------------------------------------------

-- 1. Создаем наше окошко
local MainWin = Library:CreateWindow("Delta Pro Hub")

-- 2. Создаем вкладки
local TabESP = MainWin:AddTab("👁 ESP")
local TabCombat = MainWin:AddTab("⚔️ Combat")
local TabPlayer = MainWin:AddTab("🏃 Player")

-- 3. Наполняем вкладку ESP
TabESP:AddToggle("Включить подсветку игроков", false, function(state)
    print("ESP статус: ", state)
end)

-- 4. Наполняем вкладку Combat
TabCombat:AddButton("Убить всех (Kill All)", function()
    print("Пытаемся уничтожить весь сервер!")
end)

TabCombat:AddToggle("Silent Aim", false, function(state)
    print("Аимбот: ", state)
end)

-- 5. Наполняем вкладку Player
TabPlayer:AddButton("Выдать 1000 Скорости", function()
    local p = game.Players.LocalPlayer
    if p.Character and p.Character:FindFirstChild("Humanoid") then
        p.Character.Humanoid.WalkSpeed = 1000
    end
end)
