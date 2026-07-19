local GlobalState = _G.DepHub
if not GlobalState or not GlobalState.AutoFarmEnabled then
    return
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerData = LocalPlayer:WaitForChild("Data")
local PlayerLevel = PlayerData:WaitForChild("Level")
local WorkspaceMap = workspace:WaitForChild("Map")
local WorkspaceNPCs = workspace:WaitForChild("NPCs")
local WorkspaceEnemies = workspace:WaitForChild("Enemies")
local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes")
local CommRemote = ReplicatedRemotes:WaitForChild("CommF_")
local QuestGui = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Quest")
local QuestTitleLabel = QuestGui.Container.QuestTitle.Title

local Settings = GlobalState.Settings
local CurrentSea = GlobalState.CurrentSea or 1

local GameData = {
    Sea = CurrentSea,
    MaxLevel = ({ 700, 1500, 2550 })[CurrentSea] or 700,
}

local BossRegistry = {
    ["Mob Leader"] = true,
    ["The Gorilla King"] = true,
    ["Yeti"] = true,
    ["Ember"] = true,
    ["Vice Admiral"] = true,
    ["Wysper"] = true,
    ["Thunder God"] = true,
    ["Cursed Captain"] = true,
    ["Darkbeard"] = true,
    ["Order"] = true,
    ["Diamond"] = true,
    ["Fajita"] = true,
    ["Cake Queen"] = true,
    ["Stone"] = true,
    ["Hydra Leader"] = true,
    ["Kilo Admiral"] = true,
    ["Captain Elephant"] = true,
    ["Beautiful Pirate"] = true,
    ["Cake Prince"] = true,
    ["Dough King"] = true,
    ["rip_indra True Form"] = true,
}

local PortalLocations = ({
    {
        ["Sky Island 1"] = Vector3.new(-4652, 873, -1754),
        ["Sky Island 2"] = Vector3.new(-7895, 5547, -380),
        ["Under Water Island"] = Vector3.new(61164, 15, 1820),
        ["Under Water Island Entrace"] = Vector3.new(3865, 20, -1926),
    },
    {
        ["Flamingo Mansion"] = Vector3.new(-317, 331, 597),
        ["Flamingo Room"] = Vector3.new(2283, 15, 867),
        ["Cursed Ship"] = Vector3.new(923, 125, 32853),
        ["Zombie Island"] = Vector3.new(-6509, 83, -133),
    },
    {
        Mansion = Vector3.new(-12464, 376, -7566),
        ["Hydra Island"] = Vector3.new(5651, 1015, -350),
        ["Temple of Time"] = Vector3.new(28286, 14897, 103),
        ["Sea Castle"] = Vector3.new(-5090, 319, -3146),
        ["Great Tree"] = Vector3.new(2953, 2282, -7217),
    },
})[CurrentSea] or {}

local ActiveTween = nil
local ToolEquipTimestamp = 0
local AxisOffsetCache = Vector3.zero
local AxisOffsetTimestamp = 0
local OrbitAngle = 0

local EnemyLocationRegistry = {}

local function FireRemote(remoteName, ...)
    return CommRemote:InvokeServer(remoteName, ...)
end

local function IsCharacterAlive(character)
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character.PrimaryPart
    return humanoid and rootPart and humanoid.Health > 0
end

local function IsBossName(enemyName)
    return BossRegistry[enemyName] == true
end

local function NormalizeQuestText(textValue)
    return string.gsub(string.lower(textValue), "-", "")
end

local function EnableBusoHaki()
    if not Settings.AutoBuso then
        return
    end
    pcall(function()
        FireRemote("Buso")
    end)
end

local function PerformAutoClick()
    if not Settings.AutoClick then
        return
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
end

local TeleportManager = {
    LastTeleportTimestamp = 0,
    LastTargetCFrame = nil,
    BypassCooldown = 0,
    SpawnVector = Vector3.new(0, -25.2, 0),
    GreatTreeCFrame = CFrame.new(28610, 14897, 105),
    RouteIndex = 1,
}

function TeleportManager:StopTween(rootPart)
    if ActiveTween then
        pcall(function()
            ActiveTween:Cancel()
        end)
        ActiveTween = nil
    end
    if rootPart then
        rootPart.Anchored = false
    end
end

function TeleportManager:GetNearestPortal(targetPosition)
    local closestDistance = math.huge
    local closestPosition = nil
    local closestName = nil
    for portalName, portalPosition in pairs(PortalLocations) do
        local distance = (targetPosition - portalPosition).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            closestPosition = portalPosition
            closestName = portalName
        end
    end
    return closestPosition, closestName, closestDistance
end

function TeleportManager:TeleportTo(targetCFrame, speedMultiplier, skipYAxisFix)
    local character = LocalPlayer.Character
    if not IsCharacterAlive(character) then
        return
    end

    local humanoid = character.Humanoid
    local rootPart = character.PrimaryPart

    if humanoid.Sit then
        humanoid.Sit = false
        return
    end

    if tick() - self.LastTeleportTimestamp < 1 and self.LastTargetCFrame == targetCFrame then
        return
    end

    self:StopTween(rootPart)

    local targetPosition = targetCFrame.Position
    local travelDistance = (rootPart.Position - targetPosition).Magnitude
    local tweenSpeed = Settings.TweenSpeed or 220

    local portalPosition, portalName, portalDistance = self:GetNearestPortal(targetPosition)
    local portalRouteDistance = portalPosition and ((targetPosition - portalPosition).Magnitude + 300) or math.huge

    if portalPosition and tick() - self.BypassCooldown >= 8 and portalRouteDistance < travelDistance then
        if portalName == "Great Tree" then
            self:TeleportTo(self.GreatTreeCFrame, nil, true)
            FireRemote("RaceV4Progress", "TeleportBack")
        else
            task.wait(0.2)
            local entrancePosition = targetPosition
            if (targetPosition - portalPosition).Magnitude >= 50 then
                entrancePosition = portalPosition + (targetPosition - rootPart.Position).Unit * 40
            end
            FireRemote("requestEntrance", entrancePosition)
            self.BypassCooldown = tick()
        end
        return
    end

    if not skipYAxisFix then
        local flattenedPosition = Vector3.new(rootPart.Position.X, targetPosition.Y, rootPart.Position.Z)
        if (rootPart.Position - flattenedPosition).Magnitude > 75 then
            rootPart.CFrame = CFrame.new(flattenedPosition)
            task.wait(0.1)
        end
    end

    if travelDistance < 150 and not speedMultiplier then
        rootPart.CFrame = targetCFrame
    else
        local tweenDuration = travelDistance / (speedMultiplier or tweenSpeed)
        if travelDistance < 380 then
            tweenDuration = travelDistance / (tweenSpeed * 2)
        end
        ActiveTween = TweenService:Create(rootPart, TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear), {
            CFrame = targetCFrame,
        })
        ActiveTween:Play()
    end

    self.LastTeleportTimestamp = tick()
    self.LastTargetCFrame = targetCFrame
end

function TeleportManager:FollowRoute(routeList, speedMultiplier)
    if not routeList or #routeList == 0 then
        return
    end
    if self.RouteIndex > #routeList then
        self.RouteIndex = 1
    end
    local routePoint = routeList[self.RouteIndex]
    if typeof(routePoint) == "CFrame" then
        routePoint = routePoint.Position
    end
    local character = LocalPlayer.Character
    if character and character.PrimaryPart and (character.PrimaryPart.Position - routePoint).Magnitude < 5 then
        self.RouteIndex += 1
    else
        self:TeleportTo(CFrame.new(routePoint), speedMultiplier)
    end
end

local WeaponManager = {}

function WeaponManager:GetToolByCategory(toolCategory)
    local searchOrder = { LocalPlayer.Backpack, LocalPlayer.Character }
    for _, container in ipairs(searchOrder) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item.ToolTip == toolCategory then
                    return item
                end
            end
        end
    end
    return nil
end

function WeaponManager:EquipSelectedTool(forceCategory)
    local selectedCategory = forceCategory or Settings.FarmTool or "Melee"
    local character = LocalPlayer.Character
    if not IsCharacterAlive(character) then
        return false
    end

    local equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool and equippedTool.ToolTip == selectedCategory then
        return true
    end

    local targetTool = self:GetToolByCategory(selectedCategory)
    if not targetTool then
        local fallbackOrder = { "Melee", "Sword", "Blox Fruit", "Gun" }
        for _, fallbackCategory in ipairs(fallbackOrder) do
            targetTool = self:GetToolByCategory(fallbackCategory)
            if targetTool then
                Settings.FarmTool = fallbackCategory
                break
            end
        end
    end

    if targetTool then
        character.Humanoid:EquipTool(targetTool)
        ToolEquipTimestamp = tick()
        return true
    end

    return false
end

local QuestManager = {
    QuestList = {},
    QuestPositions = {},
    EnemyRouteCache = {},
    CurrentQuest = nil,
    CachedBossQuest = nil,
    CachedBossName = nil,
    CachedLevel = 0,
    QuestDebounceTimestamp = 0,
    QuestDebounceKey = "",
    QuestNpcOffset = CFrame.new(0, 0, 2.5),
    IsReady = false,
}

function QuestManager:Initialize()
    local questsModule = ReplicatedStorage:WaitForChild("Quests", 9)
    local guideModule
    
    pcall(function()
        guideModule = require(ReplicatedStorage:WaitForChild("GuideModule", 9))
    end)

    local tbl_quests = {}
    if questsModule then
        if questsModule:IsA("ModuleScript") then
            pcall(function() tbl_quests = require(questsModule) end)
        else
            -- Se não for um ModuleScript, tenta ler como uma tabela se o ambiente permitir
            pcall(function() tbl_quests = shared.Quests or {} end)
        end
    end

    local function registerQuestTask(taskData)
        local enemyNames = {}
        for taskKey, _ in pairs(taskData) do
            if taskKey ~= "Level" then
                EnemyLocationRegistry[taskKey] = EnemyLocationRegistry[taskKey] or {}
                table.insert(enemyNames, taskKey)
            end
        end
        return enemyNames
    end

    for questName, questData in pairs(tbl_quests) do
        if typeof(questData) == "table" and questData.Task then
            for questIndex, taskData in pairs(questData.Task) do
                local enemyNames = registerQuestTask(taskData)
                table.insert(self.QuestList, {
                    Name = questName,
                    Count = questIndex,
                    Enemy = {
                        Name = enemyNames,
                        Level = taskData.Level or 0,
                        Position = {},
                    },
                })
            end
        end
    end

    table.sort(self.QuestList, function(firstQuest, secondQuest)
        return firstQuest.Enemy.Level < secondQuest.Enemy.Level
    end)

    if guideModule and guideModule.Data and guideModule.Data.NPCList then
        for _, npcData in pairs(guideModule.Data.NPCList) do
            self.QuestPositions[npcData.NPCName] = CFrame.new(npcData.Position)
        end
    end

    self.IsReady = true
end

function QuestManager:GetLevelCap()
    if CurrentSea == 1 then
        return 700
    elseif CurrentSea == 2 then
        return 1500
    end
    return PlayerLevel.Value
end

function QuestManager:SelectQuestForLevel()
    local levelCap = math.clamp(PlayerLevel.Value, 0, self:GetLevelCap())
    local selectedQuest = nil
    local selectedBossQuest = nil
    local selectedBossName = nil

    for _, questEntry in ipairs(self.QuestList) do
        local primaryEnemyName = questEntry.Enemy.Name[1]
        local enemyLevel = questEntry.Enemy.Level

        if IsBossName(primaryEnemyName) then
            if enemyLevel <= levelCap and levelCap - 50 <= enemyLevel then
                selectedBossName = primaryEnemyName
                selectedBossQuest = questEntry
            end
        elseif levelCap >= enemyLevel then
            selectedQuest = questEntry
        else
            break
        end
    end

    self.CurrentQuest = selectedQuest
    self.CachedBossQuest = selectedBossQuest
    self.CachedBossName = selectedBossName
    self.CachedLevel = PlayerLevel.Value
    return selectedQuest
end

function QuestManager:GetActiveQuest()
    if self.CachedLevel ~= PlayerLevel.Value or not self.CurrentQuest then
        return self:SelectQuestForLevel()
    end
    if self.CachedBossName and CombatManager:IsEnemySpawned(self.CachedBossName) then
        return self.CachedBossQuest
    end
    return self.CurrentQuest
end

function QuestManager:GetQuestNpcCFrame(questName)
    if self.QuestPositions[questName] then
        return self.QuestPositions[questName]
    end
    local npcModel = WorkspaceNPCs:FindFirstChild(questName) or ReplicatedStorage.NPCs:FindFirstChild(questName)
    if npcModel then
        return npcModel:GetPivot()
    end
    return nil
end

function QuestManager:IsQuestActive(enemyNames)
    if not QuestGui.Visible then
        return false
    end
    local questText = NormalizeQuestText(QuestTitleLabel.Text)
    if typeof(enemyNames) == "string" then
        return string.find(questText, NormalizeQuestText(enemyNames)) ~= nil
    end
    for _, enemyName in ipairs(enemyNames) do
        if string.find(questText, NormalizeQuestText(enemyName)) then
            return enemyName
        end
    end
    return false
end

function QuestManager:BeginQuest(questName, questIndex, npcCFrame)
    if npcCFrame and LocalPlayer:DistanceFromCharacter(npcCFrame.Position) >= 5 then
        TeleportManager:TeleportTo(npcCFrame * self.QuestNpcOffset)
        return "TeleportingToNpc"
    end

    local debounceKey = tostring(questIndex) .. questName
    if self.QuestDebounceTimestamp > 0 and tick() - self.QuestDebounceTimestamp < 75 and self.QuestDebounceKey == debounceKey then
        return "QuestDebounce"
    end

    task.wait(0.35)
    FireRemote("StartQuest", questName, questIndex)
    self.QuestDebounceTimestamp = tick()
    self.QuestDebounceKey = debounceKey
    return "QuestStarted"
end

local CombatManager = {
    AxisOffsetCache = Vector3.zero,
    AxisOffsetTimestamp = 0,
}

function CombatManager:IsEnemySpawned(enemyIdentifier)
    if typeof(enemyIdentifier) == "table" then
        for _, enemyName in ipairs(enemyIdentifier) do
            local enemyModel = WorkspaceEnemies:FindFirstChild(enemyName)
            if enemyModel and IsCharacterAlive(enemyModel) then
                return enemyModel
            end
        end
        return nil
    end
    local enemyModel = WorkspaceEnemies:FindFirstChild(enemyIdentifier)
    if enemyModel and IsCharacterAlive(enemyModel) then
        return enemyModel
    end
    return nil
end

function CombatManager:GetRandomAxisOffset()
    if tick() - self.AxisOffsetTimestamp <= 0.4 then
        return self.AxisOffsetCache
    end
    local horizontalAxis = math.random() <= 0.5 and "X" or "Z"
    local horizontalDirection = math.random() <= 0.5 and 1 or -1
    local farmDistance = Settings.FarmDistance or 15
    local offset = Vector3.new(0, 8, 0)
    if horizontalAxis == "X" then
        offset += Vector3.new(farmDistance * horizontalDirection, 0, 0)
    else
        offset += Vector3.new(0, 0, farmDistance * horizontalDirection)
    end
    self.AxisOffsetCache = offset
    self.AxisOffsetTimestamp = tick()
    return offset
end

function CombatManager:BringEnemies(primaryTarget, bringAllNearby)
    if not Settings.BringMobs then
        return
    end
    local targetRoot = primaryTarget.PrimaryPart
    if not targetRoot then
        return
    end
    local bringDistance = Settings.BringDistance or 250
    for _, enemyModel in ipairs(WorkspaceEnemies:GetChildren()) do
        if enemyModel ~= primaryTarget then
            local enemyHumanoid = enemyModel:FindFirstChildOfClass("Humanoid")
            local enemyRoot = enemyModel.PrimaryPart
            if enemyHumanoid and enemyRoot and enemyHumanoid.Health > 0 then
                local shouldBring = bringAllNearby
                if not shouldBring then
                    shouldBring = (enemyRoot.Position - targetRoot.Position).Magnitude <= bringDistance
                end
                if shouldBring then
                    enemyRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                    enemyRoot.Velocity = Vector3.zero
                    enemyHumanoid.WalkSpeed = 0
                end
            end
        end
    end
end

function CombatManager:ApplyFarmPosition(enemyRoot, farmModeOverride)
    local selectedFarmMode = farmModeOverride or Settings.FarmMode or "Up"
    if selectedFarmMode == "Up" then
        local elevatedCFrame = enemyRoot.CFrame + (Settings.FarmPos or Vector3.new(0, 15, 0))
        if LocalPlayer:DistanceFromCharacter(elevatedCFrame.Position) >= 5 then
            TeleportManager:TeleportTo(elevatedCFrame)
        end
    elseif selectedFarmMode == "Star" then
        local starCFrame = enemyRoot.CFrame + self:GetRandomAxisOffset()
        if LocalPlayer:DistanceFromCharacter(starCFrame.Position) >= 5 then
            TeleportManager:TeleportTo(starCFrame)
        end
    elseif selectedFarmMode == "Orbit" then
        OrbitAngle += 3.5
        local orbitRadius = Settings.FarmDistance or 15
        local orbitCFrame = CFrame.new(
            math.cos(math.rad(OrbitAngle)) * orbitRadius,
            8,
            math.sin(math.rad(OrbitAngle)) * orbitRadius
        ) + enemyRoot.Position
        TeleportManager:TeleportTo(orbitCFrame)
    end
end

function CombatManager:AttackEnemy(enemyModel, shouldBring, bringAllNearby, farmModeOverride)
    if not enemyModel or not IsCharacterAlive(enemyModel) then
        return false
    end

    if shouldBring then
        self:BringEnemies(enemyModel, bringAllNearby)
    end

    if tick() - ToolEquipTimestamp >= 1 then
        WeaponManager:EquipSelectedTool()
    end

    EnableBusoHaki()

    local enemyRoot = enemyModel.PrimaryPart
    if not enemyRoot then
        return false
    end

    local selectedFarmMode = farmModeOverride or Settings.FarmMode or "Up"
    if selectedFarmMode == "Orbit" then
        while GlobalState.AutoFarmEnabled and Settings.FarmMode == "Orbit" and IsCharacterAlive(enemyModel) do
            if tick() - ToolEquipTimestamp >= 1 then
                WeaponManager:EquipSelectedTool()
            end
            EnableBusoHaki()
            self:ApplyFarmPosition(enemyRoot, "Orbit")
            PerformAutoClick()
            task.wait(Settings.SmoothMode and 0.1 or 0)
            if not GlobalState.AutoFarmEnabled then
                break
            end
        end
    else
        self:ApplyFarmPosition(enemyRoot, selectedFarmMode)
        PerformAutoClick()
    end

    return true
end

local FarmEngine = {
    StatusMessage = "Idle",
}

function FarmEngine:SetNoClipState(isEnabled)
    local character = LocalPlayer.Character
    if not character then
        return
    end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = not isEnabled
        end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and isEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end

function FarmEngine:ResolveEnemyTarget(enemyNames)
    local spawnedEnemy = CombatManager:IsEnemySpawned(enemyNames)
    if spawnedEnemy then
        return spawnedEnemy
    end
    if typeof(enemyNames) == "table" then
        for _, enemyName in ipairs(enemyNames) do
            local replicatedEnemy = ReplicatedStorage:FindFirstChild(enemyName)
            if replicatedEnemy then
                return replicatedEnemy
            end
        end
    end
    return nil
end

function FarmEngine:RunLevelFarmCycle()
    local activeQuest = QuestManager:GetActiveQuest()
    if not activeQuest then
        self.StatusMessage = "NoQuestAvailable"
        task.wait(1)
        return
    end

    local enemyNames = activeQuest.Enemy.Name
    local questVerification = QuestManager:IsQuestActive(enemyNames)

    if questVerification and IsBossName(typeof(questVerification) == "string" and questVerification or enemyNames[1]) then
        local bossModel = CombatManager:IsEnemySpawned(typeof(questVerification) == "string" and questVerification or enemyNames)
        if bossModel then
            self.StatusMessage = "KillingBoss"
            CombatManager:AttackEnemy(bossModel, true, false)
            return
        end
    end

    if not questVerification then
        self.StatusMessage = "StartingQuest"
        QuestManager:BeginQuest(activeQuest.Name, activeQuest.Count, QuestManager:GetQuestNpcCFrame(activeQuest.Name))
        return
    end

    local targetEnemyName = typeof(questVerification) == "string" and questVerification or enemyNames[1]
    local enemyModel = CombatManager:IsEnemySpawned(targetEnemyName)
    if enemyModel then
        self.StatusMessage = "Killing_" .. enemyModel.Name
        CombatManager:AttackEnemy(enemyModel, true, false)
        return
    end

    local enemyRoutes = activeQuest.Enemy.Position
    if enemyRoutes and #enemyRoutes > 0 then
        TeleportManager:FollowRoute(enemyRoutes)
    else
        local npcCFrame = QuestManager:GetQuestNpcCFrame(activeQuest.Name)
        if npcCFrame then
            TeleportManager:TeleportTo(npcCFrame * QuestManager.QuestNpcOffset)
        end
    end

    self.StatusMessage = "WaitingSpawn_" .. targetEnemyName
end

function FarmEngine:Start()
    QuestManager:Initialize()

    task.spawn(function()
        while GlobalState.AutoFarmEnabled do
            pcall(function()
                self:SetNoClipState(true)
                self:RunLevelFarmCycle()
            end)
            task.wait(0.15)
        end
        self:SetNoClipState(false)
        TeleportManager:StopTween(LocalPlayer.Character and LocalPlayer.Character.PrimaryPart)
        GlobalState.AutoFarmRunning = false
        print("[Dep Hub] Auto Farm stopped.")
    end)

    GlobalState.AutoFarmRunning = true
    print("[Dep Hub] Auto Farm started | Sea " .. tostring(CurrentSea) .. " | Mode " .. tostring(Settings.FarmMode))
end

FarmEngine:Start()
