--[[
    Dep Hub - Loader Principal
    Executa primeiro. Detecta o Sea atual e carrega o módulo de UI correspondente.
]]

-- ============================================================
-- CONFIGURAÇÃO
-- ============================================================

local PLACE_IDS = {
    Sea1 = 2753915549,
    Sea2 = 4442272121,
    Sea3 = 7405815058,
}

-- Base raw do GitHub (ajuste branch/repo se necessário)
local GITHUB_SEAS = "https://raw.githubusercontent.com/glowpkj/Dep-Hub/refs/heads/main/BloxFruits/Seas/"

-- ============================================================
-- UTILITÁRIOS
-- ============================================================

--- Baixa e executa um script remoto com tratamento de erro.
local function loadRemoteScript(url, label)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not source or #source == 0 then
        warn("[Dep Hub] Falha ao baixar " .. label .. ": " .. tostring(source))
        return false
    end

    local compileOk, compiled = pcall(function()
        return loadstring(source)
    end)

    if not compileOk or not compiled then
        warn("[Dep Hub] Falha ao compilar " .. label)
        return false
    end

    local runOk, runErr = pcall(compiled)

    if not runOk then
        warn("[Dep Hub] Erro ao executar " .. label .. ": " .. tostring(runErr))
        return false
    end

    print("[Dep Hub] " .. label .. " carregado com sucesso.")
    return true
end

-- ============================================================
-- DETECÇÃO DE SEA
-- ============================================================

local currentPlaceId = game.PlaceId

print("[Dep Hub] PlaceId detectado: " .. tostring(currentPlaceId))

if currentPlaceId == PLACE_IDS.Sea1 then
    -- Sea 1: carrega interface e lógica de abas do First Sea
    loadRemoteScript(GITHUB_SEAS .. "Sea1.lua", "Sea 1 UI")

elseif currentPlaceId == PLACE_IDS.Sea2 then
    -- TODO: adicionar link quando Sea2.lua estiver pronto
    print("[Dep Hub] Sea 2 detectado — módulo ainda não disponível.")
    -- loadRemoteScript(GITHUB_SEAS .. "Sea2.lua", "Sea 2 UI")

elseif currentPlaceId == PLACE_IDS.Sea3 then
    -- TODO: adicionar link quando Sea3.lua estiver pronto
    print("[Dep Hub] Sea 3 detectado — módulo ainda não disponível.")
    -- loadRemoteScript(GITHUB_SEAS .. "Sea3.lua", "Sea 3 UI")

else
    warn("[Dep Hub] Jogo não suportado. PlaceId: " .. tostring(currentPlaceId))
end
