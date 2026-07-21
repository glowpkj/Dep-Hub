if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GAMES_DATABASE = {
    [142823291] = { Name = "Murder Mystery 2", ScriptUrl = "https://githubusercontent.com" }
}

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
    local ok = pcall(function() return CoreGui.Name end)
    return ok and CoreGui or PlayerGui
end

local function loadRemoteScript(url)
    local ok, source = pcall(function() return game:HttpGet(url) end)
    if not ok or not source or #source == 0 then return false end
    
    local compileOk, compiled = pcall(function() return loadstring(source) end)
    if not compileOk or not compiled then return false end
    
    local runOk, runErr = pcall(compiled)
    if not runOk then return false end
    
    return true
end

local currentGameData = GAMES_DATABASE[game.PlaceId]
local screenParent = getScreenParent()

if not currentGameData then
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "DepHub_Warning"
    warningGui.ResetOnSpawn = false
    warningGui.Parent = screenParent

    local warningFrame = Instance.new("Frame")
    warningFrame.Size = UDim2.new(0, 320, 0, 120)
    warningFrame.Position = UDim2.new(0.5, -160, 0.5, -60)
    warningFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    warningFrame.BorderSizePixel = 0
    warningFrame.Parent = warningGui

    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, -20, 1, -20)
    warningText.Position = UDim2.new(0, 10, 0, 10)
    warningText.BackgroundTransparency = 1
    warningText.Text = "This game is not supported by Dep Hub yet.\n\nPlaceId: " .. tostring(game.PlaceId)
    warningText.TextColor3 = Color3.fromRGB(220, 80, 80)
    warningText.Font = Enum.Font.GothamMedium
    warningText.TextSize = 13
    warningText.TextWrapped = true
    warningText.Parent = warningFrame
    
    task.wait(5)
    warningGui:Destroy()
    return
end

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
loadingStatus.Text = "Checking environment..."
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

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBackground

local tween1 = TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.3, 0, 1, 0) })
tween1:Play()
tween1.Completed:Wait()

loadingStatus.Text = "Identifying: " .. currentGameData.Name .. "..."
local tween2 = TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.6, 0, 1, 0) })
tween2:Play()
tween2.Completed:Wait()

loadingStatus.Text = "Downloading script..."
local scriptLoaded = loadRemoteScript(currentGameData.ScriptUrl)

if scriptLoaded then
    loadingStatus.Text = "Ready to inject!"
    local tween3 = TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
    tween3:Play()
    tween3.Completed:Wait()
    
    task.wait(0.15)
    
    local exitTween = TweenService:Create(loadingFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -180, 1.2, 0) })
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
    loadingStatus.TextColor3 = Color3.fromRGB(220, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    task.wait(3)
    loadingGui:Destroy()
end
