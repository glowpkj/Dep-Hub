--[[
    Dep Hub - Loader Principal com Tela de Carregamento
    Detecta o Sea atual, mostra uma animação de carregamento estilizada e inicia a UI.
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration de IDs e Repositório
local PLACE_IDS = {
    Sea1 = 2753915549,
    Sea2 = 4442272121,
    Sea3 = 7405815058,
}
local GITHUB_SEAS = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/BloxFruits/Seas/"

-- Função para garantir onde a UI vai ser injetada (CoreGui ou PlayerGui)
local function getParentGui()
    local ok = pcall(function() return CoreGui.Name end)
    return ok and CoreGui or PlayerGui
end

-- ============================================================
-- CRIAÇÃO DA TELA DE CARREGAMENTO (ESTILO BRACKET)
-- ============================================================
local parentGui = getParentGui()
if parentGui:FindFirstChild("DepHub_LoaderUI") then
    parentGui.DepHub_LoaderUI:Destroy()
end

local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "DepHub_LoaderUI"
loaderGui.ResetOnSpawn = false
loaderGui.Parent = parentGui

-- Frame Principal do Loader
local bgFrame = Instance.new("Frame")
bgFrame.Name = "Background"
bgFrame.Size = UDim2.new(0, 350, 0, 180)
bgFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
bgFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bgFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
bgFrame.BorderSizePixel = 2
bgFrame.Parent = loaderGui

-- Título do Loader
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEP HUB | INITIALIZING"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 16
titleLabel.Parent = bgFrame

-- Texto de Status (O que está acontecendo)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 20)
statusLabel.Position = UDim2.new(0, 20, 0, 70)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Analisando servidor..."
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = bgFrame

-- Barra de Carregamento (Fundo)
local barBackground = Instance.new("Frame")
barBackground.Size = UDim2.new(1, -40, 0, 15)
barBackground.Position = UDim2.new(0, 20, 0, 105)
barBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
barBackground.BorderColor3 = Color3.fromRGB(40, 40, 40)
barBackground.BorderSizePixel = 1
barBackground.Parent = bgFrame

-- Barra de Carregamento (Preenchimento)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0) -- Começa em 0%
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Cor Branca idêntica ao Accent do Sea1
barFill.BorderSizePixel = 0
barFill.Parent = barBackground

-- Porcentagem em Texto
local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(1, -40, 0, 20)
percentLabel.Position = UDim2.new(0, 20, 0, 130)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLabel.Font = Enum.Font.Code
percentLabel.TextSize = 12
percentLabel.TextXAlignment = Enum.TextXAlignment.Center
percentLabel.Parent = bgFrame

-- Função para atualizar a barra visualmente com efeito Tween suave
local function updateProgress(percentage, text)
    statusLabel.Text = text
    percentLabel.Text = tostring(percentage) .. "%"
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(barFill, tweenInfo, {Size = UDim2.new(percentage / 100, 0, 1, 0)})
    tween:Play()
    task.wait(0.4) -- Espera a animação da barra completar
end

-- ============================================================
-- PROCESSO DE VERIFICAÇÃO E CARREGAMENTO
-- ============================================================

task.spawn(function()
    task.wait(0.5)
    updateProgress(20, "Checando credenciais do executor...")
    task.wait(0.6)
    
    local currentPlaceId = game.PlaceId
    updateProgress(45, "Buscando ID do mapa atual: " .. tostring(currentPlaceId))
    task.wait(0.5)

    local targetScript = ""
    local labelScript = ""

    if currentPlaceId == PLACE_IDS.Sea1 then
        targetScript = "Sea1.lua"
        labelScript = "Sea 1 UI"
    elseif currentPlaceId == PLACE_IDS.Sea2 then
        targetScript = "Sea2.lua"
        labelScript = "Sea 2 UI"
    elseif currentPlaceId == PLACE_IDS.Sea3 then
        targetScript = "Sea3.lua"
        labelScript = "Sea 3 UI"
    end

    if targetScript ~= "" then
        updateProgress(70, "Conectando ao GitHub de @glowpkj...")
        
        local url = GITHUB_SEAS .. targetScript
        local ok, source = pcall(function()
            return game:HttpGet(url)
        end)

        if ok and source and #source > 0 then
            updateProgress(90, "Compilando codificação do " .. labelScript .. "...")
            
            local compileOk, compiled = pcall(function()
                return loadstring(source)
            end)

            if compileOk and compiled then
                updateProgress(100, "Dep Hub pronto! Inicializando menu...")
                task.wait(0.5)
                
                -- Remove a tela de carregamento antes de abrir o menu real
                loaderGui:Destroy()
                
                -- Executa a UI do Sea
                pcall(compiled)
            else
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                updateProgress(90, "Erro crítico na compilação do código.")
            end
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            updateProgress(70, "Erro: Repositório offline ou link inválido.")
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        updateProgress(0, "Erro: Jogo atual não suportado pelo Dep Hub.")
    end
end)
