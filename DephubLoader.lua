--!strict
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration & Database
local GAMES_DATABASE: { [number]: { Name: string, ScriptUrl: string } } = {
    [142823291] = { Name = "Murder Mystery 2", ScriptUrl = "https://githubusercontent.com" }
}

-- Global Settings Initialization
_G.DepHub = _G.DepHub or {}
_G.DepHub.Settings = _G.DepHub.Settings or {
    AutoBuso = true,
    BringMobs = true,
    BringDistance = 250,
    FarmMode = "Up",
    FarmTool = "Melee",
    FarmDistance = 15,
    FarmPos = Vector3.new(0, 15, 0),
    TweenSpeed = 220,
    AutoClick = true,
    SmoothMode = false,
}

-- Helper: Get Safe ScreenGui Parent
local function getScreenParent(): Instance
    local success, _ = pcall(function() return CoreGui.Name end)
    return success and CoreGui or PlayerGui
end

-- Helper: Load and Execute Remote Script safely
local function loadRemoteScript(url: string): boolean
    if not url or #url == 0 then return false end

    local getSuccess, source = pcall(function() 
        return game:HttpGet(url) 
    end)
    if not getSuccess or type(source) ~= "string" or #source == 0 then 
        return false 
    end

    local compileSuccess, compiled = pcall(function() 
        return loadstring(source) 
    end)
    if not compileSuccess or type(compiled) ~= "function" then 
        return false 
    end

    local runSuccess, runErr = pcall(compiled)
    if not runSuccess then
        warn("[DepHub] Error executing script:", runErr)
        return false
    end

    return true
end

-- Helper: UI Builder Utilities
local function createCorner(parent: Instance, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent: Instance, color: Color3, thickness: number)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local screenParent = getScreenParent()
local currentGameData = GAMES_DATABASE[game.PlaceId]

--------------------------------------------------------------------------------
-- Unsupported Game UI
--------------------------------------------------------------------------------
if not currentGameData then
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "DepHub_Warning"
    warningGui.ResetOnSpawn = false
    warningGui.Parent = screenParent

    local warningFrame = Instance.new("Frame")
    warningFrame.Size = UDim2.new(0, 320, 0, 120)
    warningFrame.Position = UDim2.new(0.5, -160, 0.5, -60)
    warningFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    warningFrame.BorderSizePixel = 0
    warningFrame.Parent = warningGui

    createCorner(warningFrame, 8)
    createStroke(warningFrame, Color3.fromRGB(220, 80, 80), 1)

    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, -20, 1, -20)
    warningText.Position = UDim2.new(0, 10, 0, 10)
    warningText.BackgroundTransparency = 1
    warningText.Text = "Game not supported yet.\n\nPlaceId: " .. tostring(game.PlaceId)
    warningText.TextColor3 = Color3.fromRGB(240, 90, 90)
    warningText.Font = Enum.Font.GothamMedium
    warningText.TextSize = 13
    warningText.TextWrapped = true
    warningText.Parent = warningFrame

    task.wait(4)
    warningGui:Destroy()
    return
end

--------------------------------------------------------------------------------
-- Main Loading Screen UI
--------------------------------------------------------------------------------
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "DepHub_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = screenParent

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 360, 0, 170)
loadingFrame.Position = UDim2.new(0.5, -180, 0.5, -85)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

createCorner(loadingFrame, 10)
createStroke(loadingFrame, Color3.fromRGB(40, 40, 50), 1)

-- Title
local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 36)
loadingTitle.Position = UDim2.new(0, 0, 0, 20)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "DEP HUB"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 22
loadingTitle.Parent = loadingFrame

-- Status Label
local loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, -48, 0, 20)
loadingStatus.Position = UDim2.new(0, 24, 0, 68)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "Checking environment..."
loadingStatus.TextColor3 = Color3.fromRGB(170, 170, 180)
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextSize = 12
loadingStatus.TextXAlignment = Enum.TextXAlignment.Left
loadingStatus.Parent = loadingFrame

-- Progress Bar Background
local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(1, -48, 0, 6)
progressBackground.Position = UDim2.new(0, 24, 0, 100)
progressBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
progressBackground.BorderSizePixel = 0
progressBackground.Parent = loadingFrame

createCorner(progressBackground, 3)

-- Progress Bar Fill
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBackground

createCorner(progressBar, 3)

--------------------------------------------------------------------------------
-- Animation & Execution
--------------------------------------------------------------------------------
local function tweenBar(scale: number, duration: number)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(progressBar, tweenInfo, { Size = UDim2.new(scale, 0, 1, 0) })
    tween:Play()
    tween.Completed:Wait()
end

-- Step 1: Environment Check
tweenBar(0.35, 0.4)

-- Step 2: Game Identification
loadingStatus.Text = "Identifying: " .. currentGameData.Name .. "..."
tweenBar(0.65, 0.4)

-- Step 3: Script Download
loadingStatus.Text = "Downloading script..."
local scriptLoaded = loadRemoteScript(currentGameData.ScriptUrl)

if scriptLoaded then
    loadingStatus.Text = "Successfully loaded!"
    tweenBar(1, 0.3)
    task.wait(0.2)

    -- Smooth Exit Animation
    local exitTween = TweenService:Create(
        loadingFrame, 
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
        { Position = UDim2.new(0.5, -180, 1.2, 0) }
    )
    exitTween:Play()
    exitTween.Completed:Wait()
    loadingGui:Destroy()

    StarterGui:SetCore("SendNotification", {
        Title = "Dep Hub",
        Text = currentGameData.Name .. " loaded successfully!",
        Duration = 5
    })
else
    loadingStatus.Text = "Connection error. Failed to load."
    loadingStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
    
    task.wait(3)
    loadingGui:Destroy()
end