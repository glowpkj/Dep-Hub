if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

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

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 520, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    createCorner(mainFrame, 10)
    createStroke(mainFrame, Color3.fromRGB(35, 35, 45), 1)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    createCorner(topBar, 10)

    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0, 10)
    topBarFix.Position = UDim2.new(0, 0, 1, -10)
    topBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    topBarFix.BorderSizePixel = 0
    topBarFix.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = hubTitle .. " <font color=\"rgb(120, 120, 140)\">| " .. gameName .. "</font>"
    titleLabel.RichText = true
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = topBar

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    makeDraggable(mainFrame, topBar)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 130, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = sidebar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.Parent = sidebar

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -140, 1, -50)
    contentArea.Position = UDim2.new(0, 135, 0, 45)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Sidebar = sidebar
    self.ContentArea = contentArea
    self.Tabs = {}
    self.ActiveTab = nil

    return self
end

function DepHubUI:CreateTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 32)
    tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(160, 160, 170)
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 12
    tabButton.Parent = self.Sidebar

    createCorner(tabButton, 6)

    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    tabContainer.Visible = false
    tabContainer.Parent = self.ContentArea

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 8)
    containerLayout.Parent = tabContainer

    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 10)
    end)

    local tabData = {
        Button = tabButton,
        Container = tabContainer
    }

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Container.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            tab.Button.TextColor3 = Color3.fromRGB(160, 160, 170)
        end
        tabContainer.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = tabData
    end)

    if #self.Tabs == 0 then
        tabContainer.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.ActiveTab = tabData
    end

    table.insert(self.Tabs, tabData)

    local TabElements = {}

    function TabElements:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -5, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(220, 220, 230)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = tabContainer

        createCorner(btn, 6)
        createStroke(btn, Color3.fromRGB(40, 40, 50), 1)

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    function TabElements:AddToggle(text, defaultState, callback)
        local state = defaultState or false

        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -5, 0, 34)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tabContainer

        createCorner(toggleFrame, 6)
        createStroke(toggleFrame, Color3.fromRGB(40, 40, 50), 1)

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.Position = UDim2.new(0, 10, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextSize = 12
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 32, 0, 18)
        indicator.Position = UDim2.new(1, -40, 0.5, -9)
        indicator.BackgroundColor3 = state and Color3.fromRGB(90, 140, 255) or Color3.fromRGB(40, 40, 50)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggleFrame

        createCorner(indicator, 9)

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = toggleFrame

        clickBtn.MouseButton1Click:Connect(function()
            state = not state
            indicator.BackgroundColor3 = state and Color3.fromRGB(90, 140, 255) or Color3.fromRGB(40, 40, 50)
            pcall(callback, state)
        end)
    end

    return TabElements
end

local UI = DepHubUI.new("Dep Hub", "Murder Mystery 2")

local MainTab = UI:CreateTab("Main")
local PlayerTab = UI:CreateTab("Player")

MainTab:AddButton("Test Button", function()
    print("Button Clicked!")
end)

MainTab:AddToggle("Auto Farm", false, function(toggled)
    print("Auto Farm:", toggled)
end)

PlayerTab:AddButton("Reset Speed", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)