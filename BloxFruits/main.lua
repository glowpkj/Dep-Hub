pcall(function()
    if rconsoleclear then rconsoleclear() end
end)
pcall(function()
    if rconsolename then rconsolename("Dep Hub") end
end)
pcall(function()
    if cleardata then cleardata() end
end)
pcall(function()
    if console and console.clear then console.clear() end
end)

print("[Dep Hub] Executed successfully.")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PLACE_IDS = {
    [2753915549] = 1,
    [4442272121] = 2,
    [7405815058] = 3,
}

local GITHUB_BASE = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/BloxFruits/Seas/Sea"

local CORNER_RADIUS = UDim.new(0, 0)

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

local function getScreenParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    return ok and CoreGui or PlayerGui
end

local function loadRemoteScript(url, label)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not source or #source == 0 then
        warn("[Dep Hub] Download failed: " .. label)
        return false
    end
    local compileOk, compiled = pcall(function()
        return loadstring(source)
    end)
    if not compileOk or not compiled then
        warn("[Dep Hub] Compile failed: " .. label)
        return false
    end
    local runOk, runErr = pcall(compiled)
    if not runOk then
        warn("[Dep Hub] Runtime error (" .. label .. "): " .. tostring(runErr))
        return false
    end
    print("[Dep Hub] " .. label .. " loaded.")
    return true
end

local currentSea = PLACE_IDS[game.PlaceId]
local screenParent = getScreenParent()

if not currentSea then
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "DepHub_Warning"
    warningGui.ResetOnSpawn = false
    warningGui.Parent = screenParent

    local warningFrame = Instance.new("Frame")
    warningFrame.Size = UDim2.new(0, 320, 0, 120)
    warningFrame.Position = UDim2.new(0.5, -160, 0.5, -60)
    warningFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    warningFrame.BorderSizePixel = 0
    warningFrame.Parent = warningGui

    local warningCorner = Instance.new("UICorner")
    warningCorner.CornerRadius = CORNER_RADIUS
    warningCorner.Parent = warningFrame

    local warningStroke = Instance.new("UIStroke")
    warningStroke.Color = Color3.fromRGB(50, 50, 50)
    warningStroke.Parent = warningFrame

    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, -20, 1, -20)
    warningText.Position = UDim2.new(0, 10, 0, 10)
    warningText.BackgroundTransparency = 1
    warningText.Text = "Dep Hub supports Blox Fruits only."
    warningText.TextColor3 = Color3.fromRGB(200, 200, 200)
    warningText.Font = Enum.Font.Gotham
    warningText.TextSize = 13
    warningText.TextWrapped = true
    warningText.Parent = warningFrame
    return
end

_G.DepHub.CurrentSea = currentSea

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "DepHub_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = screenParent

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 360, 0, 180)
loadingFrame.Position = UDim2.new(0.5, -180, 0.5, -90)
loadingFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = CORNER_RADIUS
loadingCorner.Parent = loadingFrame

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = Color3.fromRGB(45, 45, 45)
loadingStroke.Parent = loadingFrame

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 36)
loadingTitle.Position = UDim2.new(0, 0, 0, 24)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "DEP HUB"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 22
loadingTitle.Parent = loadingFrame

local loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, -24, 0, 20)
loadingStatus.Position = UDim2.new(0, 12, 0, 68)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "Initializing..."
loadingStatus.TextColor3 = Color3.fromRGB(160, 160, 160)
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextSize = 11
loadingStatus.TextXAlignment = Enum.TextXAlignment.Left
loadingStatus.Parent = loadingFrame

local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(1, -48, 0, 4)
progressBackground.Position = UDim2.new(0, 24, 0, 110)
progressBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressBackground.BorderSizePixel = 0
progressBackground.Parent = loadingFrame

local progressBackgroundCorner = Instance.new("UICorner")
progressBackgroundCorner.CornerRadius = CORNER_RADIUS
progressBackgroundCorner.Parent = progressBackground

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBackground

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = CORNER_RADIUS
progressBarCorner.Parent = progressBar

local loadingSteps = {
    { text = "Loading game services...", progress = 0.2, delay = 0.3 },
    { text = "Detecting sea (Sea " .. tostring(currentSea) .. ")...", progress = 0.45, delay = 0.35 },
    { text = "Preparing interface...", progress = 0.7, delay = 0.35 },
    { text = "Syncing modules...", progress = 0.9, delay = 0.3 },
    { text = "Ready.", progress = 1, delay = 0.25 },
}

for _, step in ipairs(loadingSteps) do
    loadingStatus.Text = step.text
    local progressTween = TweenService:Create(
        progressBar,
        TweenInfo.new(step.delay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(step.progress, 0, 1, 0) }
    )
    progressTween:Play()
    progressTween.Completed:Wait()
end

task.wait(0.15)

local exitTween = TweenService:Create(
    loadingFrame,
    TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
    { Position = UDim2.new(0.5, -180, 1.2, 0) }
)
exitTween:Play()
exitTween.Completed:Wait()
loadingGui:Destroy()

local seaUrl = GITHUB_BASE .. tostring(currentSea) .. ".lua"
loadRemoteScript(seaUrl, "Sea " .. tostring(currentSea) .. " UI")
