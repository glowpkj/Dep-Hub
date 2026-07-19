--[[
    Dep Hub - Sea 1 UI
    Interface visual do First Sea: abas, toggles e carregamento remoto de scripts.
]]

-- ============================================================
-- SERVIÇOS & CONSTANTES
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Estilo quadrado/bracket: sem arredondamento
local CORNER_RADIUS = UDim.new(0, 0)

local AUTOFARM_URL = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/BloxFruits/scripts/autofarm.lua"
local TOGGLE_KEY = Enum.KeyCode.B

-- Flag global compartilhada com autofarm.lua (e outros módulos futuros)
_G.DepHub = _G.DepHub or {}
_G.DepHub.AutoFarmEnabled = false

-- ============================================================
-- TEMA
-- ============================================================

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

-- ============================================================
-- AUTO FARM — CONTROLE REMOTO
-- ============================================================

local AutoFarmController = {}
AutoFarmController.IsRunning = false

function AutoFarmController:Start()
    if self.IsRunning then
        return
    end

    _G.DepHub.AutoFarmEnabled = true
    self.IsRunning = true

    task.spawn(function()
        local ok, source = pcall(function()
            return game:HttpGet(AUTOFARM_URL)
        end)

        if not ok or not source or #source == 0 then
            warn("[Dep Hub] Falha ao baixar autofarm.lua")
            self:Stop()
            return
        end

        if not _G.DepHub.AutoFarmEnabled then
            return
        end

        local compileOk, compiled = pcall(function()
            return loadstring(source)
        end)

        if not compileOk or not compiled then
            warn("[Dep Hub] Falha ao compilar autofarm.lua")
            self:Stop()
            return
        end

        local runOk, runErr = pcall(compiled)

        if not runOk then
            warn("[Dep Hub] Erro ao executar autofarm.lua: " .. tostring(runErr))
            self:Stop()
        end
    end)
end

function AutoFarmController:Stop()
    _G.DepHub.AutoFarmEnabled = false
    self.IsRunning = false
    print("[Dep Hub] Auto Farm desativado.")
end

-- ============================================================
-- HELPERS DE UI
-- ============================================================

local function getParentGui()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    return ok and CoreGui or PlayerGui
end

local function applySquareCorner(instance)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS
    corner.Parent = instance
    return corner
end

local function applyStroke(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = color or Theme.Stroke
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- ============================================================
-- COMPONENTE: TOGGLE
-- ============================================================

local function createToggle(parent, label, onEnable, onDisable)
    local enabled = false

    local row = Instance.new("Frame")
    row.Name = label .. "_Toggle"
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Theme.Element
    row.BorderSizePixel = 0
    row.Parent = parent
    applySquareCorner(row)
    applyStroke(row)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 36, 1, 0)
    statusLabel.Position = UDim2.new(1, -48, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Theme.TextMuted
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

        if enabled then
            statusLabel.Text = "ON"
            statusLabel.TextColor3 = Theme.Accent
            if onEnable then
                onEnable()
            end
        else
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Theme.TextMuted
            if onDisable then
                onDisable()
            end
        end
    end)

    return row
end

-- ============================================================
-- CONSTRUÇÃO DA JANELA PRINCIPAL
-- ============================================================

local parentGui = getParentGui()

if parentGui:FindFirstChild("DepHub_Sea1") then
    parentGui.DepHub_Sea1:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DepHub_Sea1"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = UDim2.new(0, 620, 0, 400)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
applySquareCorner(mainFrame)
applyStroke(mainFrame, Theme.Separator)

-- Top bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Theme.TopBar
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
applySquareCorner(topBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -16, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEP HUB  |  SEA 1"
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

-- Sidebar (abas)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
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

-- Botão da aba "Main"
local mainTabButton = Instance.new("TextButton")
mainTabButton.Name = "MainTab"
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

local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0, 3, 0, 14)
tabIndicator.Position = UDim2.new(0, 2, 0.5, -7)
tabIndicator.BackgroundColor3 = Theme.Accent
tabIndicator.BorderSizePixel = 0
tabIndicator.Parent = mainTabButton

-- Painel de conteúdo
local contentPanel = Instance.new("Frame")
contentPanel.Name = "ContentPanel"
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
mainPage.CanvasSize = UDim2.new(0, 0, 0, 0)
mainPage.Parent = contentPanel

local pageLayout = Instance.new("UIListLayout")
pageLayout.Padding = UDim.new(0, 6)
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.Parent = mainPage

pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 8)
end)

-- ============================================================
-- ABA MAIN — AUTO FARM
-- ============================================================

createToggle(mainPage, "Auto Farm", function()
    AutoFarmController:Start()
end, function()
    AutoFarmController:Stop()
end)

-- ============================================================
-- ARRASTAR JANELA
-- ============================================================

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

-- ============================================================
-- ATALHO PARA MOSTRAR/OCULTAR UI (tecla B)
-- ============================================================

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

print("[Dep Hub] Sea 1 UI inicializada.")
