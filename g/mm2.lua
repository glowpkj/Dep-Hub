if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function getScreenParent()
    local ok = pcall(function() return CoreGui.Name end)
    return ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local screenParent = getScreenParent()

local existingUI = screenParent:FindFirstChild("DepHub_UI")
if existingUI then
    existingUI:Destroy()
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local DepHubUI = {}
DepHubUI.__index = DepHubUI

function DepHubUI.new(hubTitle, gameName)
    local self = setmetatable({}, DepHubUI)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DepHub_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = screenParent

    local openButton = Instance.new("TextButton")
    openButton.Name = "OpenToggleBtn"
    openButton.Size = UDim2.new(0, 45, 0, 45)
    openButton.Position = UDim2.new(0, 20, 0.5, -22)
    openButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    openButton.Text = "DEP"
    openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 12
    openButton.Parent = screenGui

    createCorner(openButton, 22)
    createStroke(openButton, Color3.fromRGB(40, 40, 40), 1)
    makeDraggable(openButton, openButton)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 540, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    createCorner(mainFrame, 8)
    createStroke(mainFrame, Color3.fromRGB(30, 30, 30), 1)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    createCorner(topBar, 8)
    createStroke(topBar, Color3.fromRGB(25, 25, 25), 1)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = hubTitle .. " <font color=\"rgb(120, 120, 120)\">| " .. gameName .. "</font>"
    titleLabel.RichText = true
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -36, 0, 6)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.Parent = topBar

    makeDraggable(mainFrame, topBar)

    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(0, 180, 0, 26)
    searchContainer.Position = UDim2.new(1, -225, 0, 8)
    searchContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    searchContainer.BorderSizePixel = 0
    searchContainer.Parent = topBar

    createCorner(searchContainer, 5)
    createStroke(searchContainer, Color3.fromRGB(35, 35, 35), 1)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -12, 1, 0)
    searchBox.Position = UDim2.new(0, 8, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 135, 1, -42)
    sidebar.Position = UDim2.new(0, 0, 0, 42)
    sidebar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    createStroke(sidebar, Color3.fromRGB(20, 20, 20), 1)

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.Parent = sidebar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 8)
    tabPadding.PaddingLeft = UDim.new(0, 6)
    tabPadding.PaddingRight = UDim.new(0, 6)
    tabPadding.Parent = sidebar

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -145, 1, -50)
    contentArea.Position = UDim2.new(0, 140, 0, 46)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    local isOpen = true

    local function toggleUI()
        isOpen = not isOpen
        if isOpen then
            mainFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 540, 0, 360),
                BackgroundTransparency = 0
            }):Play()
        else
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 540, 0, 0),
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                if not isOpen then
                    mainFrame.Visible = false
                end
            end)
        end
    end

    closeBtn.MouseButton1Click:Connect(toggleUI)
    openButton.MouseButton1Click:Connect(toggleUI)

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Sidebar = sidebar
    self.ContentArea = contentArea
    self.SearchBox = searchBox
    self.Tabs = {}
    self.ActiveTab = nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        if self.ActiveTab then
            for _, item in ipairs(self.ActiveTab.Elements) do
                if item.Frame then
                    if query == "" then
                        item.Frame.Visible = true
                    else
                        local match = string.find(string.lower(item.SearchName), query) ~= nil
                        item.Frame.Visible = match
                    end
                end
            end
        end
    end)

    return self
end

function DepHubUI:CreateTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(120, 120, 120)
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 11
    tabButton.Parent = self.Sidebar

    createCorner(tabButton, 5)
    local tabStroke = createStroke(tabButton, Color3.fromRGB(25, 25, 25), 1)

    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    tabContainer.Visible = false
    tabContainer.Parent = self.ContentArea

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 6)
    containerLayout.Parent = tabContainer

    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 10)
    end)

    local tabData = {
        Button = tabButton,
        Container = tabContainer,
        Elements = {},
        Stroke = tabStroke
    }

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Container.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                TextColor3 = Color3.fromRGB(120, 120, 120)
            }):Play()
            tab.Stroke.Color = Color3.fromRGB(25, 25, 25)
        end

        tabContainer.Visible = true
        TweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        tabStroke.Color = Color3.fromRGB(70, 70, 70)
        self.ActiveTab = tabData
        self.SearchBox.Text = ""
    end)

    if #self.Tabs == 0 then
        tabContainer.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabStroke.Color = Color3.fromRGB(70, 70, 70)
        self.ActiveTab = tabData
    end

    table.insert(self.Tabs, tabData)

    local TabElements = {}

    function TabElements:AddSection(titleText)
        local secFrame = Instance.new("Frame")
        secFrame.Size = UDim2.new(1, -6, 0, 22)
        secFrame.BackgroundTransparency = 1
        secFrame.Parent = tabContainer

        local secLabel = Instance.new("TextLabel")
        secLabel.Size = UDim2.new(1, 0, 1, 0)
        secLabel.BackgroundTransparency = 1
        secLabel.Text = string.upper(titleText)
        secLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
        secLabel.Font = Enum.Font.GothamBold
        secLabel.TextSize = 10
        secLabel.TextXAlignment = Enum.TextXAlignment.Left
        secLabel.Parent = secFrame

        table.insert(tabData.Elements, { SearchName = titleText, Frame = secFrame })
    end

    function TabElements:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = tabContainer

        createCorner(btn, 5)
        local stroke = createStroke(btn, Color3.fromRGB(28, 28, 28), 1)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(18, 18, 18) }):Play()
            stroke.Color = Color3.fromRGB(50, 50, 50)
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(8, 8, 8) }):Play()
            stroke.Color = Color3.fromRGB(28, 28, 28)
        end)

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        table.insert(tabData.Elements, { SearchName = text, Frame = btn })
    end

    function TabElements:AddToggle(text, defaultState, callback)
        local state = defaultState or false

        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -6, 0, 32)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tabContainer

        createCorner(toggleFrame, 5)
        local stroke = createStroke(toggleFrame, Color3.fromRGB(28, 28, 28), 1)

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.Position = UDim2.new(0, 10, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextSize = 11
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 28, 0, 14)
        indicator.Position = UDim2.new(1, -36, 0.5, -7)
        indicator.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 25)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggleFrame

        createCorner(indicator, 7)

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = toggleFrame

        clickBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 25)
            }):Play()
            pcall(callback, state)
        end)

        table.insert(tabData.Elements, { SearchName = text, Frame = toggleFrame })
    end

    return TabElements
end

local UI = DepHubUI.new("Dep Hub", "Murder Mystery 2")
local MainTab = UI:CreateTab("Main")

MainTab:AddSection("Automation")
MainTab:AddToggle("Auto Farm", false, function(state)
end)

MainTab:AddButton("Teleport to Lobby", function()
end)