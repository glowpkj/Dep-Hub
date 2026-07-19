local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GlobalState = _G.DepHub or {}
GlobalState.Settings = GlobalState.Settings or {}
GlobalState.AutoFarmEnabled = GlobalState.AutoFarmEnabled or false
GlobalState.CurrentSea = GlobalState.CurrentSea or 1
_G.DepHub = GlobalState

local CORNER_RADIUS = UDim.new(0, 0)
local AUTOFARM_URL = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/BloxFruits/scripts/autofarm.lua"
local TOGGLE_KEY = Enum.KeyCode.B

local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    TopBar = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(12, 12, 12),
    Content = Color3.fromRGB(8, 8, 8),
    Element = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(50, 50, 50),
    Separator = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(160, 160, 160),
    Accent = Color3.fromRGB(255, 255, 255),
}

local AutoFarmController = {
    IsRunning = false,
}

function AutoFarmController:Start()
    if self.IsRunning then
        return
    end
    GlobalState.AutoFarmEnabled = true
    self.IsRunning = true
    task.spawn(function()
        local ok, source = pcall(function()
            return game:HttpGet(AUTOFARM_URL)
        end)
        if not ok or not source or #source == 0 then
            warn("[Dep Hub] Auto Farm download failed.")
            self:Stop()
            return
        end
        if not GlobalState.AutoFarmEnabled then
            return
        end
        local compileOk, compiled = pcall(function()
            return loadstring(source)
        end)
        if not compileOk or not compiled then
            warn("[Dep Hub] Auto Farm compile failed.")
            self:Stop()
            return
        end
        local runOk, runErr = pcall(compiled)
        if not runOk then
            warn("[Dep Hub] Auto Farm runtime error: " .. tostring(runErr))
            self:Stop()
        end
    end)
end

function AutoFarmController:Stop()
    GlobalState.AutoFarmEnabled = false
    GlobalState.AutoFarmRunning = false
    self.IsRunning = false
end

local function getScreenParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    return ok and CoreGui or PlayerGui
end

local function applySquareCorner(instance)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS
    corner.Parent = instance
end

local function applyStroke(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = color or Theme.Stroke
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
end

local function createSectionLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextMuted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createToggle(parent, label, initialValue, onChanged)
    local enabled = initialValue == true
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.Element
    row.BorderSizePixel = 0
    row.Parent = parent
    applySquareCorner(row)
    applyStroke(row)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -52, 1, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 36, 1, 0)
    statusLabel.Position = UDim2.new(1, -48, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = enabled and "ON" or "OFF"
    statusLabel.TextColor3 = enabled and Theme.Accent or Theme.TextMuted
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 10
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.Parent = row

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        statusLabel.Text = enabled and "ON" or "OFF"
        statusLabel.TextColor3 = enabled and Theme.Accent or Theme.TextMuted
        if onChanged then
            onChanged(enabled)
        end
    end)
end

local function createDropdown(parent, label, options, defaultValue, onChanged)
    local selectedValue = defaultValue
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Theme.Element
    row.BorderSizePixel = 0
    row.Parent = parent
    applySquareCorner(row)
    applyStroke(row)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -12, 0, 18)
    nameLabel.Position = UDim2.new(0, 12, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local cycleButton = Instance.new("TextButton")
    cycleButton.Size = UDim2.new(1, -24, 0, 22)
    cycleButton.Position = UDim2.new(0, 12, 0, 24)
    cycleButton.BackgroundColor3 = Theme.Background
    cycleButton.Text = selectedValue
    cycleButton.TextColor3 = Theme.TextMuted
    cycleButton.Font = Enum.Font.GothamBold
    cycleButton.TextSize = 10
    cycleButton.BorderSizePixel = 0
    cycleButton.Parent = row
    applySquareCorner(cycleButton)
    applyStroke(cycleButton)

    cycleButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, selectedValue) or 1
        local nextIndex = currentIndex % #options + 1
        selectedValue = options[nextIndex]
        cycleButton.Text = selectedValue
        if onChanged then
            onChanged(selectedValue)
        end
    end)
end

local function createSlider(parent, label, minimum, maximum, defaultValue, onChanged)
    local currentValue = defaultValue
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Theme.Element
    row.BorderSizePixel = 0
    row.Parent = parent
    applySquareCorner(row)
    applyStroke(row)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 12, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, -12, 0, 18)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(currentValue)
    valueLabel.TextColor3 = Theme.TextMuted
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local decreaseButton = Instance.new("TextButton")
    decreaseButton.Size = UDim2.new(0, 28, 0, 20)
    decreaseButton.Position = UDim2.new(0, 12, 0, 24)
    decreaseButton.BackgroundColor3 = Theme.Background
    decreaseButton.Text = "-"
    decreaseButton.TextColor3 = Theme.Text
    decreaseButton.Font = Enum.Font.GothamBold
    decreaseButton.TextSize = 12
    decreaseButton.BorderSizePixel = 0
    decreaseButton.Parent = row
    applySquareCorner(decreaseButton)

    local increaseButton = Instance.new("TextButton")
    increaseButton.Size = UDim2.new(0, 28, 0, 20)
    increaseButton.Position = UDim2.new(1, -40, 0, 24)
    increaseButton.BackgroundColor3 = Theme.Background
    increaseButton.Text = "+"
    increaseButton.TextColor3 = Theme.Text
    increaseButton.Font = Enum.Font.GothamBold
    increaseButton.TextSize = 12
    increaseButton.BorderSizePixel = 0
    increaseButton.Parent = row
    applySquareCorner(increaseButton)

    local function applyValue(newValue)
        currentValue = math.clamp(newValue, minimum, maximum)
        valueLabel.Text = tostring(currentValue)
        if onChanged then
            onChanged(currentValue)
        end
    end

    decreaseButton.MouseButton1Click:Connect(function()
        applyValue(currentValue - 1)
    end)
    increaseButton.MouseButton1Click:Connect(function()
        applyValue(currentValue + 1)
    end)
end

local screenParent = getScreenParent()
local guiName = "DepHub_Sea" .. tostring(GlobalState.CurrentSea)
if screenParent:FindFirstChild(guiName) then
    screenParent[guiName]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = screenParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 640, 0, 430)
mainFrame.Position = UDim2.new(0.5, -320, 0.5, -215)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
applySquareCorner(mainFrame)
applyStroke(mainFrame, Theme.Separator)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Theme.TopBar
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
applySquareCorner(topBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -16, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEP HUB  |  SEA " .. tostring(GlobalState.CurrentSea)
titleLabel.TextColor3 = Theme.Text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local topSeparator = Instance.new("Frame")
topSeparator.Size = UDim2.new(1, 0, 0, 1)
topSeparator.Position = UDim2.new(0, 0, 1, 0)
topSeparator.BackgroundColor3 = Theme.Separator
topSeparator.BorderSizePixel = 0
topSeparator.Parent = topBar

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -34)
sidebar.Position = UDim2.new(0, 0, 0, 34)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarSeparator = Instance.new("Frame")
sidebarSeparator.Size = UDim2.new(0, 1, 1, 0)
sidebarSeparator.Position = UDim2.new(1, -1, 0, 0)
sidebarSeparator.BackgroundColor3 = Theme.Separator
sidebarSeparator.BorderSizePixel = 0
sidebarSeparator.Parent = sidebar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -8, 1, -8)
tabContainer.Position = UDim2.new(0, 4, 0, 4)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

local mainTabButton = Instance.new("TextButton")
mainTabButton.Size = UDim2.new(1, 0, 0, 30)
mainTabButton.BackgroundColor3 = Theme.Element
mainTabButton.Text = "  MAIN"
mainTabButton.TextColor3 = Theme.Text
mainTabButton.Font = Enum.Font.GothamBold
mainTabButton.TextSize = 11
mainTabButton.TextXAlignment = Enum.TextXAlignment.Left
mainTabButton.BorderSizePixel = 0
mainTabButton.Parent = tabContainer
applySquareCorner(mainTabButton)
applyStroke(mainTabButton)

local settingsTabButton = Instance.new("TextButton")
settingsTabButton.Size = UDim2.new(1, 0, 0, 30)
settingsTabButton.BackgroundColor3 = Theme.Element
settingsTabButton.Text = "  FARM"
settingsTabButton.TextColor3 = Theme.Text
settingsTabButton.Font = Enum.Font.GothamBold
settingsTabButton.TextSize = 11
settingsTabButton.TextXAlignment = Enum.TextXAlignment.Left
settingsTabButton.BorderSizePixel = 0
settingsTabButton.Parent = tabContainer
applySquareCorner(settingsTabButton)
applyStroke(settingsTabButton)

local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -131, 1, -34)
contentPanel.Position = UDim2.new(0, 131, 0, 34)
contentPanel.BackgroundColor3 = Theme.Content
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainFrame

local mainPage = Instance.new("ScrollingFrame")
mainPage.Name = "MainPage"
mainPage.Size = UDim2.new(1, -16, 1, -16)
mainPage.Position = UDim2.new(0, 8, 0, 8)
mainPage.BackgroundTransparency = 1
mainPage.BorderSizePixel = 0
mainPage.ScrollBarThickness = 3
mainPage.Visible = true
mainPage.CanvasSize = UDim2.new(0, 0, 0, 0)
mainPage.Parent = contentPanel

local settingsPage = Instance.new("ScrollingFrame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, -16, 1, -16)
settingsPage.Position = UDim2.new(0, 8, 0, 8)
settingsPage.BackgroundTransparency = 1
settingsPage.BorderSizePixel = 0
settingsPage.ScrollBarThickness = 3
settingsPage.Visible = false
settingsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsPage.Parent = contentPanel

local function bindPageLayout(page)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    return layout
end

bindPageLayout(mainPage)
bindPageLayout(settingsPage)

createSectionLabel(mainPage, "AUTOMATION")
createToggle(mainPage, "Auto Farm", false, function(state)
    if state then
        AutoFarmController:Start()
    else
        AutoFarmController:Stop()
    end
end)

createSectionLabel(settingsPage, "COMBAT")
createDropdown(settingsPage, "Farm Mode", { "Up", "Orbit", "Star" }, GlobalState.Settings.FarmMode or "Up", function(value)
    GlobalState.Settings.FarmMode = value
end)
createDropdown(settingsPage, "Farm Tool", { "Melee", "Sword", "Blox Fruit", "Gun" }, GlobalState.Settings.FarmTool or "Melee", function(value)
    GlobalState.Settings.FarmTool = value
end)
createToggle(settingsPage, "Bring Mobs", GlobalState.Settings.BringMobs ~= false, function(state)
    GlobalState.Settings.BringMobs = state
end)
createToggle(settingsPage, "Auto Buso", GlobalState.Settings.AutoBuso ~= false, function(state)
    GlobalState.Settings.AutoBuso = state
end)
createToggle(settingsPage, "Auto Click", GlobalState.Settings.AutoClick ~= false, function(state)
    GlobalState.Settings.AutoClick = state
end)

createSectionLabel(settingsPage, "DISTANCE")
createSlider(settingsPage, "Farm Distance", 5, 30, GlobalState.Settings.FarmDistance or 15, function(value)
    GlobalState.Settings.FarmDistance = value
    GlobalState.Settings.FarmPos = Vector3.new(0, value, 0)
end)
createSlider(settingsPage, "Bring Distance", 50, 400, GlobalState.Settings.BringDistance or 250, function(value)
    GlobalState.Settings.BringDistance = value
end)
createSlider(settingsPage, "Tween Speed", 50, 300, GlobalState.Settings.TweenSpeed or 220, function(value)
    GlobalState.Settings.TweenSpeed = value
end)

local function selectTab(showMain)
    mainPage.Visible = showMain
    settingsPage.Visible = not showMain
end

mainTabButton.MouseButton1Click:Connect(function()
    selectTab(true)
end)
settingsTabButton.MouseButton1Click:Connect(function()
    selectTab(false)
end)

local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.KeyCode == TOGGLE_KEY then
        uiVisible = not uiVisible
        mainFrame.Visible = uiVisible
    end
end)

print("[Dep Hub] Sea " .. tostring(GlobalState.CurrentSea) .. " UI ready.")
