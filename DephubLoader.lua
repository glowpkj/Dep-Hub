if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Função para tocar áudios com limpeza automática
local function playAudio(soundId)
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

-- Toca o som "DepHub" após 1 segundo da execução do Loader
task.spawn(function()
    task.wait(1)
    playAudio("123699567415290")
end)

local GAMES_DATABASE = {
    [142823291] = { 
        Name = "Murder Mystery 2", 
        ScriptUrl = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/g/mm2.lua" 
    }
}

local function getScreenParent()
    local ok = pcall(function() return CoreGui.Name end)
    return ok and CoreGui or PlayerGui
end

local screenParent = getScreenParent()
local currentGameData = GAMES_DATABASE[game.PlaceId]

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

if not currentGameData then
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "DepHub_Warning"
    warningGui.ResetOnSpawn = false
    warningGui.Parent = screenParent

    local warningFrame = Instance.new("Frame")
    warningFrame.Size = UDim2.new(0, 340, 0, 130)
    warningFrame.Position = UDim2.new(0.5, -170, 0.5, -65)
    warningFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    warningFrame.BorderSizePixel = 0
    warningFrame.Parent = warningGui

    createCorner(warningFrame, 8)
    createStroke(warningFrame, Color3.fromRGB(220, 80, 80), 1)

    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, -20, 1, -20)
    warningText.Position = UDim2.new(0, 10, 0, 10)
    warningText.BackgroundTransparency = 1
    warningText.Text = "Game not supported by Dep Hub.\n\nPlaceId: " .. tostring(game.PlaceId)
    warningText.TextColor3 = Color3.fromRGB(240, 90, 90)
    warningText.Font = Enum.Font.GothamMedium
    warningText.TextSize = 13
    warningText.TextWrapped = true
    warningText.Parent = warningFrame

    task.wait(4)
    warningGui:Destroy()
    return
end

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "DepHub_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = screenParent

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 380, 0, 180)
loadingFrame.Position = UDim2.new(0.5, -190, 0.5, -90)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

createCorner(loadingFrame, 10)
createStroke(loadingFrame, Color3.fromRGB(40, 40, 50), 1)

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 36)
loadingTitle.Position = UDim2.new(0, 0, 0, 20)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "DEP HUB"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 22
loadingTitle.Parent = loadingFrame

local loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, -48, 0, 32)
loadingStatus.Position = UDim2.new(0, 24, 0, 60)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "Waiting for game..."
loadingStatus.TextColor3 = Color3.fromRGB(170, 170, 180)
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextSize = 11
loadingStatus.TextXAlignment = Enum.TextXAlignment.Left
loadingStatus.TextWrapped = true
loadingStatus.Parent = loadingFrame

local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(1, -48, 0, 6)
progressBackground.Position = UDim2.new(0, 24, 0, 105)
progressBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
progressBackground.BorderSizePixel = 0
progressBackground.Parent = loadingFrame

createCorner(progressBackground, 3)

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBackground

createCorner(progressBar, 3)

local function tweenBar(scale, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(progressBar, tweenInfo, { Size = UDim2.new(scale, 0, 1, 0) })
    tween:Play()
    tween.Completed:Wait()
end

repeat task.wait() until game:IsLoaded()
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

tweenBar(0.25, 0.3)

loadingStatus.Text = "Identifying: " .. currentGameData.Name .. "..."
tweenBar(0.5, 0.3)

loadingStatus.Text = "Downloading script..."

local fetchSuccess, rawSource = pcall(function()
    return game:HttpGet(currentGameData.ScriptUrl)
end)

if not fetchSuccess then
    loadingStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
    loadingStatus.Text = "HTTP Error: " .. tostring(rawSource)
    task.wait(6)
    loadingGui:Destroy()
    return
end

if type(rawSource) ~= "string" or #rawSource == 0 or rawSource:find("404: Not Found") then
    loadingStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
    loadingStatus.Text = "Error: Invalid script content or 404 URL."
    task.wait(6)
    loadingGui:Destroy()
    return
end

tweenBar(0.75, 0.3)

local compileSuccess, compiledFunc = pcall(function()
    return loadstring(rawSource)
end)

if not compileSuccess or type(compiledFunc) ~= "function" then
    loadingStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
    loadingStatus.Text = "Compile Error: " .. tostring(compiledFunc)
    task.wait(6)
    loadingGui:Destroy()
    return
end

loadingStatus.Text = "Executing script..."
tweenBar(0.9, 0.2)

local runSuccess, runErr = pcall(compiledFunc)

if not runSuccess then
    loadingStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    progressBar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
    loadingStatus.Text = "Runtime Error: " .. tostring(runErr)
    task.wait(6)
    loadingGui:Destroy()
    return
end

loadingStatus.Text = "Successfully loaded!"
tweenBar(1, 0.2)
task.wait(0.2)

local exitTween = TweenService:Create(
    loadingFrame, 
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
    { Position = UDim2.new(0.5, -190, 1.2, 0) }
)
exitTween:Play()
exitTween.Completed:Wait()
loadingGui:Destroy()

StarterGui:SetCore("SendNotification", {
    Title = "Dep Hub",
    Text = currentGameData.Name .. " loaded successfully!",
    Duration = 5
})