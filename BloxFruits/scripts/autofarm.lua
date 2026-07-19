local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PosMon
local BringMobFarm = false
local SetCFarme = 1
local LevelRequire = 0
local MobName = ""
local QuestName = ""
local QuestLevel = 1
local Mon = ""
local NPCPosition = CFrame.new()
local MobCFrame = {}

local CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local RigController = require(LocalPlayer.PlayerScripts.CombatFramework.RigController)
local RigControllerR = getupvalues(RigController)[2]
local realbhit = require(ReplicatedStorage.CombatFramework.RigLib)
local cooldownfastattack = tick()

local function getAllBladeHits(Sizes)
    local Hits = {}
    local Client = LocalPlayer
    local Enemies = Workspace.Enemies:GetChildren()
    for i = 1, #Enemies do
        local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes + 5 then
            table.insert(Hits, Human.RootPart)
        end
    end
    return Hits
end

local function CurrentWeapon()
    local ac = CombatFrameworkR.activeController
    local ret = ac.blades[1]
    if not ret then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    pcall(function()
        while ret.Parent ~= LocalPlayer.Character do ret = ret.Parent end
    end)
    if not ret then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    return ret
end

local function AttackFunction()
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        for indexincrement = 1, 1 do
            local bladehit = getAllBladeHits(60)
            if #bladehit > 0 then
                local AcAttack8 = debug.getupvalue(ac.attack, 5)
                local AcAttack9 = debug.getupvalue(ac.attack, 6)
                local AcAttack7 = debug.getupvalue(ac.attack, 4)
                local AcAttack10 = debug.getupvalue(ac.attack, 7)
                local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
                local NumberAc13 = AcAttack7 * 798405
                
                ;(function()
                    NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
                    AcAttack8 = math.floor(NumberAc12 / AcAttack9)
                    AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
                end)()
                
                AcAttack10 = AcAttack10 + 1
                debug.setupvalue(ac.attack, 5, AcAttack8)
                debug.setupvalue(ac.attack, 6, AcAttack9)
                debug.setupvalue(ac.attack, 4, AcAttack7)
                debug.setupvalue(ac.attack, 7, AcAttack10)
                
                for k, v in pairs(ac.animator.anims.basic) do
                    v:Play(0.01, 0.01, 0.01)
                end                 
                
                if LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
                    ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(CurrentWeapon()))
                    ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
                    ReplicatedStorage.RigControllerEvent:FireServer("hit", bladehit, 2, "") 
                end
            end
        end
    end
end

local EnemySpawns = Instance.new("Folder", Workspace)
EnemySpawns.Name = "EnemySpawns"

for i, v in pairs(Workspace._WorldOrigin.EnemySpawns:GetChildren()) do
    if v:IsA("Part") then
        local EnemySpawnsX2 = v:Clone()
        local result = string.gsub(v.Name, "Lv. ", "")
        local result2 = string.gsub(result, "[%[%]]", "")
        local result3 = string.gsub(result2, "%d+", "")
        local result4 = string.gsub(result3, "%s+", "")
        EnemySpawnsX2.Name = result4
        EnemySpawnsX2.Parent = Workspace.EnemySpawns
        EnemySpawnsX2.Anchored = true
    end
end

local function GetIsLand(...)
    local RealtargetPos = {...}
    local targetPos = RealtargetPos[1]
    local RealTarget
    if type(targetPos) == "vector" then
        RealTarget = targetPos
    elseif type(targetPos) == "userdata" then
        RealTarget = targetPos.Position
    elseif type(targetPos) == "number" then
        RealTarget = CFrame.new(unpack(RealtargetPos))
        RealTarget = RealTarget.p
    end

    local ReturnValue
    local CheckInOut = math.huge
    if LocalPlayer.Team then
        for i, v in pairs(Workspace._WorldOrigin.PlayerSpawns:FindFirstChild(tostring(LocalPlayer.Team)):GetChildren()) do 
            local ReMagnitude = (RealTarget - v:GetModelCFrame().p).Magnitude
            if ReMagnitude < CheckInOut then
                CheckInOut = ReMagnitude
                ReturnValue = v.Name
            end
        end
        if ReturnValue then
            return ReturnValue
        end 
    end
end

local function Bypass(Point)
    if tween then tween:Cancel() end
    wait(0.5)
    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
    if LocalPlayer.Character:FindFirstChild("Head") then
        LocalPlayer.Character.Head:Destroy()
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = Point * CFrame.new(0, 50, 0)
    wait(.2)
    LocalPlayer.Character.HumanoidRootPart.CFrame = Point
    wait(.1)
    LocalPlayer.Character.HumanoidRootPart.CFrame = Point * CFrame.new(0, 50, 0)
    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    wait(.1)
    LocalPlayer.Character.HumanoidRootPart.CFrame = Point
    wait(0.5)
    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = Point * CFrame.new(900, 900, 900)
    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
    if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
        LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
    end
end

local function toTarget(...)
    local RealtargetPos = {...}
    local targetPos = RealtargetPos[1]
    local RealTarget
    if type(targetPos) == "vector" then
        RealTarget = CFrame.new(targetPos)
    elseif type(targetPos) == "userdata" then
        RealTarget = targetPos
    elseif type(targetPos) == "number" then
        RealTarget = CFrame.new(unpack(RealtargetPos))
    end

    if LocalPlayer.Character:WaitForChild("Humanoid").Health == 0 then 
        if tween then tween:Cancel() end 
        repeat wait() until LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
        wait(0.2) 
    end

    local Distance = (RealTarget.Position - LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).Magnitude
    local Speed = Distance < 1000 and 315 or 300

    if Distance > 3000 and (Name ~= "Fishman Commando [Lv. 400]" and Name ~= "Fishman Warrior [Lv. 375]") then
        pcall(function()
            if tween then tween:Cancel() end
            if LocalPlayer.Data:FindFirstChild("SpawnPoint").Value == tostring(GetIsLand(RealTarget)) then 
                wait(.1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("TeleportToSpawn")
            elseif LocalPlayer.Data:FindFirstChild("LastSpawnPoint").Value == tostring(GetIsLand(RealTarget)) then
                LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState(15)
                repeat wait() until LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = RealTarget
                wait(.08)
                LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState(15)
                repeat wait() until LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
                wait(.1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            end
        end)
        return
    end

    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    pcall(function()
        tween = TweenService:Create(LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = RealTarget})
        tween:Play()
    end)
end

local function InMyNetWork(object)
    if isnetworkowner then
        return isnetworkowner(object)
    else
        return (object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350
    end
end

local function EquipWeapon(Tool)
    pcall(function()
        if LocalPlayer.Backpack:FindFirstChild(Tool) then 
            local ToolHumanoid = LocalPlayer.Backpack:FindFirstChild(Tool) 
            LocalPlayer.Character.Humanoid:EquipTool(ToolHumanoid) 
        end
    end)
end

local function UnEquipWeapon(Weapon)
    if LocalPlayer.Character:FindFirstChild(Weapon) then
        LocalPlayer.Character:FindFirstChild(Weapon).Parent = LocalPlayer.Backpack
    end
end

local function QuestCheck()
    local Lvl = LocalPlayer.Data.Level.Value
    if Lvl >= 1 and Lvl <= 9 then
        if tostring(LocalPlayer.Team) == "Marines" then
            MobName = "Trainee [Lv. 5]"
            QuestName = "MarineQuest"
            QuestLevel = 1
            Mon = "Trainee"
            NPCPosition = CFrame.new(-2709.67944, 24.5206585, 2104.24585)
        elseif tostring(LocalPlayer.Team) == "Pirates" then
            MobName = "Bandit [Lv. 5]"
            Mon = "Bandit"
            QuestName = "BanditQuest1"
            QuestLevel = 1
            NPCPosition = CFrame.new(1059.99731, 16.9222069, 1549.28162)
        end
        return {[1] = QuestLevel, [2] = NPCPosition, [3] = MobName, [4] = QuestName, [5] = LevelRequire, [6] = Mon, [7] = MobCFrame}
    end
    
    local GuideModule = require(ReplicatedStorage.GuideModule)
    local Quests = require(ReplicatedStorage.Quests)
    for i, v in pairs(GuideModule["Data"]["NPCList"]) do
        for i1, v1 in pairs(v["Levels"]) do
            if Lvl >= v1 then
                if not LevelRequire then LevelRequire = 0 end
                if v1 > LevelRequire then
                    NPCPosition = i["CFrame"] or CFrame.new()
                    QuestLevel = i1
                    LevelRequire = v1
                end
            end
        end
    end
    
    for i, v in pairs(Quests) do
        for i1, v1 in pairs(v) do
            if v1["LevelReq"] == LevelRequire and i ~= "CitizenQuest" then
                QuestName = i
                for i2, v2 in pairs(v1["Task"]) do
                    MobName = i2
                    Mon = string.split(i2, " [Lv. " .. v1["LevelReq"] .. "]")[1]
                end
            end
        end
    end

    local matchingCFrames = {}
    local result = string.gsub(MobName, "Lv. ", "")
    local result2 = string.gsub(result, "[%[%]]", "")
    local result3 = string.gsub(result2, "%d+", "")
    local result4 = string.gsub(result3, "%s+", "")
    
    for i, v in pairs(Workspace.EnemySpawns:GetChildren()) do
        if v.Name == result4 then
            table.insert(matchingCFrames, v.CFrame)
        end
        MobCFrame = matchingCFrames
    end
    
    return {[1] = QuestLevel, [2] = NPCPosition, [3] = MobName, [4] = QuestName, [5] = LevelRequire, [6] = Mon, [7] = MobCFrame}
end

spawn(function()
    while true do wait()
        if setscriptable then setscriptable(LocalPlayer, "SimulationRadius", true) end
        if sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.DepHubSettings and _G.DepHubSettings.AutoFarmLevel and BringMobFarm then
                for i, v in pairs(Workspace.Enemies:GetChildren()) do
                    if not string.find(v.Name, "Boss") and (v.HumanoidRootPart.Position - PosMon.Position).magnitude <= 400 then
                        if InMyNetWork(v.HumanoidRootPart) then
                            v.HumanoidRootPart.CFrame = PosMon
                            v.Humanoid.JumpPower = 0
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.Transparency = 1
                            v.HumanoidRootPart.CanCollide = false
                            v.Head.CanCollide = false
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                            v.Humanoid:ChangeState(11)
                            v.Humanoid:ChangeState(14)
                        end
                    end
                end
            end
        end)
    end
end)

coroutine.wrap(function()
    while task.wait(.1) do
        local ac = CombatFrameworkR.activeController
        if ac and ac.equipped and _G.DepHubSettings and _G.DepHubSettings.AutoFarmLevel then
            AttackFunction()
            if tick() - cooldownfastattack > 1.5 then 
                wait(.01) 
                cooldownfastattack = tick() 
            end
        end
    end
end)()

spawn(function()
    while wait() do 
        if _G.DepHubSettings and _G.DepHubSettings.AutoFarmLevel then
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end
    end
end)

spawn(function()
    while wait() do 
        if _G.DepHubSettings and _G.DepHubSettings.AutoFarmLevel then
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("DepVelocity") then
                    if LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
                        LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
                    end
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.Name = "DepVelocity"
                    BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
                    BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        else
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("DepVelocity") then
                LocalPlayer.Character.HumanoidRootPart:FindFirstChild("DepVelocity"):Destroy()
            end
        end
    end
end)

spawn(function()
    while wait() do
        if _G.DepHubSettings and _G.DepHubSettings.AutoFarmLevel then
            local QuestC = LocalPlayer.PlayerGui.Main.Quest
            local currentQuestInfo = QuestCheck()
            
            if QuestC.Visible == true then
                if (currentQuestInfo[2].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 3000 then
                    Bypass(currentQuestInfo[2])
                end
                if Workspace.Enemies:FindFirstChild(currentQuestInfo[3]) then
                    for i, v in pairs(Workspace.Enemies:GetChildren()) do
                        if v.Name == currentQuestInfo[3] then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    if not string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, currentQuestInfo[6]) then
                                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                                    else
                                        PosMon = v.HumanoidRootPart.CFrame
                                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Head.CanCollide = false
                                        BringMobFarm = true
                                        
                                        local selectedWep = _G.DepHubSettings.SelectWeapon or "Melee"
                                        EquipWeapon(selectedWep)
                                        
                                        v.HumanoidRootPart.Transparency = 1
                                        toTarget(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 5))
                                    end
                                until not _G.DepHubSettings.AutoFarmLevel or not v.Parent or v.Humanoid.Health <= 0 or QuestC.Visible == false or not v:FindFirstChild("HumanoidRootPart")
                            end
                        end
                    end
                else
                    local selectedWep = _G.DepHubSettings.SelectWeapon or "Melee"
                    UnEquipWeapon(selectedWep)
                    if currentQuestInfo[7] and currentQuestInfo[7][SetCFarme] then
                        toTarget(currentQuestInfo[7][SetCFarme] * CFrame.new(0, 30, 5))
                        if (currentQuestInfo[7][SetCFarme].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 50 then
                            if SetCFarme >= #currentQuestInfo[7] then SetCFarme = 1 end
                            SetCFarme = SetCFarme + 1
                            wait(0.5)
                        end
                    end
                end
            else
                wait(0.5)
                if currentQuestInfo[7] and currentQuestInfo[7][1] then
                    if LocalPlayer.Data.LastSpawnPoint.Value == tostring(GetIsLand(currentQuestInfo[7][1])) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", currentQuestInfo[4], currentQuestInfo[1])
                        wait(0.5)
                        toTarget(currentQuestInfo[7][1] * CFrame.new(0, 30, 20))
                    else
                        if (currentQuestInfo[2].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 3000 then
                            Bypass(currentQuestInfo[2])
                        else
                            repeat wait() toTarget(currentQuestInfo[2]) until (currentQuestInfo[2].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 20 or not _G.DepHubSettings.AutoFarmLevel
                        end
                        if (currentQuestInfo[2].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                            BringMobFarm = false
                            wait(0.2)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", currentQuestInfo[4], currentQuestInfo[1])
                            wait(0.5)
                            toTarget(currentQuestInfo[7][1] * CFrame.new(0, 30, 20))
                        end
                    end
                end
            end
        end
    end
end)
