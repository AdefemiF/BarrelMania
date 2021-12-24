-- Classic
-- TrollD3
-- April 19, 2019

---// Services used by the Classic GameMode
local Framework = require(script.Parent.Parent.Parent.Services.Framework) --Functions of Game
local PlayerDataService = require(script.Parent.Parent.Parent.Services.PlayerDataService)
local RagDoll = require(script.Parent.Parent.Parent.Modules.RagDoll)
local DeathHandler = require(script.Parent.Parent.Parent.Services.DeathHandler)
local AddData = require(script.Parent.Parent.AddData);

---//Storage used by the Server
local serverstore = game.ServerStorage
local repstore    = game.ReplicatedStorage

----//Game Data used by the Classic Game Mode, includes game functions
local Classic = {
    HIT_POINTS = 25,
    DEFAULT_TIME = 150,
    BLAST_RADIUS = 15,
    TIMER = nil,
    MapName = nil;
    Humans = {},
    Barrels = {},
    PlayerData = {};
}

function Classic:CreateTeams() --Creates Teams and Data
    local Model = Instance.new("Model")
    Model.Name = "PlayerClones"
    Model.Parent = workspace.Holder;
    for _, plr in pairs(Framework:GetPlayers()) do
        if game.Players[plr] and game.Players[plr].Character then
            game.Players[plr].Character.Archivable = true;
            local Clone = game.Players[plr].Character:Clone()
            Clone.PrimaryPart.CFrame = CFrame.new(999,999,999)
            Clone.PrimaryPart.Anchored = true;
            Clone.Parent = Model
            table.insert(Classic.Humans, plr)
            PlayerDataService:SetPlayerType(plr, "Human")
            table.insert(Classic.PlayerData, {
                Name = plr, 
                Team = "Humans", 
                KILLS = 0, 
                DEATHS = 0, 
                POINTS = 0,
                PersonalData = {};
            }) --blank slate for all players
        end
    end;
    local num = #Classic.Humans
    Classic.Humans = Framework:Shuffle(Classic.Humans)
    repeat
        wait()
        local random = Random.new(os.time())
        random = random:NextInteger(1, #Classic.Humans)
        local plr = Classic.Humans[random]
        PlayerDataService:SetPlayerType(plr, "Barrel")
        for i, v in pairs(Classic.PlayerData) do
            if v.Name ==plr then
                Classic.PlayerData[i].Team = "Barrels"
                break;
            end;
        end;
        table.insert(Classic.Barrels, plr)
        table.remove(Classic.Humans, random)
    until #Classic.Humans <= math.floor(num / 1.25)
end
function Classic:GetExposedPlayers() --players exposed to the barrels
    return Classic.Humans
end

function Classic:UpdateSpectate() --
    local Spectate = {}
    for _, v in pairs(Classic.Humans) do
        table.insert(Spectate, v);
    end
    for _, v in pairs(Classic.Barrels) do
        table.insert(Spectate, v);
    end
    Framework:GAME_EVENT("UI", "UPDATESPECTATE",Spectate)
end

function Classic:LeavingPlayer(plr)
    for i, v in pairs(Classic.PlayerData) do
        if plr == v.Name then
            local plrTeam = Classic.PlayerData[i].Team
            table.remove(Classic.PlayerData, i)
            if plrTeam == "Humans" then
                plrTeam = Classic.Humans
            elseif plrTeam == "Barrels" then
                plrTeam = Classic.Barrels
            end;
            for x,j in pairs (plrTeam) do
                if j==v.Name then
                    table.remove(plrTeam, x)
                    break;
                end;
            end
            return  Classic:UpdateSpectate()
        end
    end
end;

function Classic:UpdateTeams(plr) --removes from human table and adds to barrel table also accounts for when barrels leave the game
    for i, v in pairs(Classic.Humans) do
        if plr == v then
            table.remove(Classic.Humans, i)
            table.insert(Classic.Barrels, plr)
            PlayerDataService:SetPlayerType(plr, "Barrel")
            for x, y in pairs(Classic.PlayerData) do
                if y.Name ==plr then
                    Classic.PlayerData[x].Team = "Barrels"
                    break;
                end;
            end;
            return Classic:UpdateSpectate()
        end
    end
end

function Classic:UpdateScore()
    Framework:GAME_EVENT("UI", "UPDATESCORE", tostring(#Classic.Humans), tostring(#Classic.Barrels))
end;

function Classic:AddStats(plr, Type)
    for i, v in pairs(Classic.PlayerData) do
        if v.Name ==plr then
            if Type == "KILLS" then
                Classic.PlayerData[i].KILLS = Classic.PlayerData[i].KILLS + 1
                Classic.PlayerData[i].POINTS += Classic.HIT_POINTS
            elseif Type == "HITBARREL" then
                Classic.PlayerData[i].POINTS += Classic.PlayerData[i].POINTS + math.ceil(Classic.HIT_POINTS * .8)
            elseif Type == "DEATHS" then
                Classic.PlayerData[i].DEATHS = Classic.PlayerData[i].DEATHS + 1
            end            
            break;
        end;
    end;
end

function Classic:CalculateXP(winner)
    local addWin = false
    for _, v in pairs(Classic.PlayerData) do
        if v.POINTS ==0 then
            v.POINTS = 5
        end
        v.POINTS = math.ceil(v.POINTS)
        if v.Team == winner then
            addWin = true
        end
        v.PersonalData = AddData:Add_XP_CASH(v.Name, v.POINTS, addWin);

    end;
end;

function Classic:KillFeed(plr1,plr2)
    for i,v in pairs (Classic.PlayerData) do
        if v.Name ==plr1 then
            plr1 = v;
        end
        if v.Name ==plr2 then
            plr2 = v;
        end;
    end;
    Framework:GAME_EVENT("UI", "KILLFEED", plr1, plr2)
end

function Classic:KillWithinRadius(plr, BlastPosition)
    spawn(function()
        local Radius = Classic.BLAST_RADIUS
        local ExposedPlayers = Classic:GetExposedPlayers();
        for _, v in pairs(ExposedPlayers) do
            if game.Players[v] == nil then continue end
            local char = game.Players[v].Character
            if (char.HumanoidRootPart.Position - BlastPosition).Magnitude <= Radius then --replicate this
                Framework:CustomUIForPlayer(plr, "UI", "NICE", Classic.HIT_POINTS)
                char.Humanoid:TakeDamage(60)
                Classic:AddStats(plr.Name, "HITBARREL")
                if plr and char.Humanoid.Health<=0 then
                    Classic:KillFeed(plr.Name,v)
                    Classic:AddStats(plr.Name, "KILLS")
                end
            end
        end
    end)
end


function Classic:Barrelize(plr)
    function Weld(part1, part2)
        local weld = Instance.new("Weld")
        weld.Part0 = part1
        weld.Part1 = part2
        weld.C0 = part1.CFrame:inverse()
        weld.C1 = part2.CFrame:inverse()
        weld.Parent = part1
    end
    
    for _, v in pairs(plr or Classic.Barrels) do
        if game.Players[v].Character ==nil then continue end
        local char = game.Players[v].Character
        for _, x in pairs(char:GetChildren()) do
            if x.ClassName == "Accessory" or x.Name == "Animate" then
                x:Destroy()
            elseif x.ClassName == "MeshPart" or x.Name == "Head" then
                x.Transparency = 1
                if x:FindFirstChild("face") then
                    x["face"]:Destroy()
                end
            elseif x.Name == "HumanoidRootPart" then
                local b,Offset;
                local plrdata = PlayerDataService:ViewPlayerData(game.Players[v])
                local ShopItems = repstore.Shop.ShopItems
                if plrdata.EquippedItems.Color[1] ~= "DEFAULT" and plrdata.EquippedItems.Skin[1]=="" then
                   b = ShopItems.Market["Color"][plrdata.EquippedItems.Color[1]]:Clone();
                elseif plrdata.EquippedItems.Skin[1] ~= "DEFAULT" and plrdata.EquippedItems.Color[1]=="" then
                    b = ShopItems.Market["Skin"][plrdata.EquippedItems.Skin[1]]:Clone();
                else
                    b = serverstore.gameObjects:FindFirstChild("PlayerBarrel"):Clone()
                    Offset = -.04

                end;
                if b.Name ~= "PlayerBarrel" and not Framework:ReturnInfo("Map").Buildings.FakeBarrels:FindFirstChild(b.Name) then
                    b = serverstore.gameObjects:FindFirstChild("PlayerBarrel"):Clone()
                    Offset = -.04
                elseif Framework:ReturnInfo("Map").Buildings.FakeBarrels:FindFirstChild(b.Name) then
                    Offset = -1.05
                end;
                for _,i in pairs(b:GetChildren()) do
                    i.CanCollide = false
                    i.CastShadow= false
                end;
                b.Parent = x
                b:SetPrimaryPartCFrame(x.CFrame * CFrame.Angles(-math.pi/2,0,math.pi) *CFrame.new(0,0,Offset))
                Weld(b.PrimaryPart,x)
            end
        end
    end
end

function Classic:OnDeath(plr,CalledTwice) --handles death for classic game mode
    Classic:AddStats("DEATHS", plr.Name)
    if PlayerDataService:GetPlayerType(plr.Name) == "Human" then
        Framework:CustomUIForPlayer(plr, "UI" , "RESPAWNUI")
        Framework:GAME_EVENT("UI", "INDICATOR", "SKULL", plr.Character.LowerTorso.Position, "Human")
        RagDoll:Simulate(plr.Name)
        DeathHandler:DeathSound(plr.Character)
        Classic:UpdateTeams(plr.Name)
        Classic:OnDeath(plr,true) --should do the barrel section;
    elseif PlayerDataService:GetPlayerType(plr.Name) == "Barrel" then
        spawn(function()
            if CalledTwice==nil or CalledTwice== false then 
                Framework:CustomUIForPlayer(plr, "UI" , "RESPAWNUI")
                Framework:GAME_EVENT("UI", "INDICATOR", "SKULL", plr.Character.LowerTorso.Position, "Barrel")
                for i, v in pairs(Classic.PlayerData) do
                    if v.Name ==plr.Name then
                        Classic.PlayerData[i].Team = "Barrels"
                        break;
                    end;
                end;  
            end;
            wait(2)
            plr:LoadCharacter()
            if plr.Character:FindFirstChild("ForceField") then
                plr.Character:FindFirstChild("ForceField"):Destroy()
            end
            Framework:GAME_EVENT("UI", "ShowAction")
            plr.Character.Humanoid.WalkSpeed = 27
            local spawns = Framework:ReturnInfo("Map").Spawns:GetChildren()
            plr.Character.UpperTorso.CFrame = spawns[math.random(1, #spawns)].CFrame * CFrame.new(0, 2, 0)
            Classic:Barrelize({plr.Name})
        end)
    end
    Framework:GAME_EVENT("UI", "INDICATOR", "DOT", Classic.Humans, Classic.Barrels)

end

function Classic:Reset()
    Classic.PlayerData = {}
    Classic.TIMER = Classic.DEFAULT_TIME
    Classic.Humans = {}
    Classic.Barrels = {}
    Framework:GAME_EVENT("UI", "SPECTATE", {})

end

function Classic:CanRoundEnd(timer)
    --print("Humans: " .. #Classic.Humans, "Barrels: " .. #Classic.Barrels)
    if timer <= 0 and #Classic.Humans >= 1 or #Classic.Barrels == 0 then
        Framework:PlayerActions(false)
        Classic:CalculateXP();
        return true, Framework:GAME_EVENT("UI", "RESULTS", "Humans", Classic.PlayerData)
    elseif #Classic.Humans == 0 then
        Framework:PlayerActions(false)
        Classic:CalculateXP();
        return true, Framework:GAME_EVENT("UI", "RESULTS", "Barrels", Classic.PlayerData)
    else
        return false, "Match In Progress"
    end
end
function Classic:Start()
    print("Classic Mode Started")
    --Framework:SetStatus("PREPARING CLASSIC");
    Classic.MapName = Framework:ReturnInfo("Map").Name;

    Framework:GAME_EVENT("UI", "STATUS", "Classic Mode Chosen!")
    Framework:GAME_EVENT("UI", "STATUS", "Spawning Objects")
    Framework:SpawnBarrels(100)
    Framework:SetStatus("CUTSCENE")
    Framework:GAME_EVENT("UI", "STATUS", "Starting CutScene")
    Framework:GAME_EVENT("UI", "CUTSCENE")

    if workspace.Holder[Classic.MapName]:FindFirstChild("Animation") then  
        workspace.Holder[Classic.MapName].Animation.Disabled = false; 
    end;

    wait(18) --to offset for cutscene 8 points max 1.4 secs
    --Framework:PlaySound("Stop");
    Classic:CreateTeams()

    Framework:SetWalkSpeed(Classic.Humans, 0)
    Framework:SetWalkSpeed(Classic.Barrels, 0)
    Classic:Barrelize()

    Framework:SpawnPlayers()

    Framework:GAME_EVENT("UI", "INDICATOR", "DOT", Classic.Humans, Classic.Barrels)
    Framework:GAME_EVENT("UI", "ROUNDINTRO")
    Framework:GAME_EVENT("UI", "STATUS", "The Red/Blue Icons will display the remaining players for both Teams!");

    wait(12)
    Framework:SetWalkSpeed(Classic.Humans, 23)
    Framework:SetWalkSpeed(Classic.Barrels, 27)
    Classic:UpdateSpectate()
    Framework:GAME_EVENT("UI", "STATUS", "Remaining Time: ", Classic.DEFAULT_TIME)
    Framework:SetStatus("MATCH")
    local AllowActions = false
    for i = Classic.DEFAULT_TIME, 0, -1 do
        --print("RemainingTime: "..i.." Humans: " .. #Classic.Humans, " Barrels: " .. #Classic.Barrels)
        Classic.TIMER = i
        if Classic.DEFAULT_TIME-i > 6 and not AllowActions then
            AllowActions = true;
			Framework:EquipTools(Classic.Humans);
			Framework:PlayerActions(true);
        end
       
        Classic:UpdateScore()
        if Classic:CanRoundEnd(i)  then
            Framework:SetStatus("ROUNDEND");
            Classic:Reset()
            Framework:SetWalkSpeed(Classic.Humans, 0)
            Framework:SetWalkSpeed(Classic.Barrels, 0)
            break
        end
        Classic:UpdateSpectate()
        wait(1)
    end
end

function Classic:Init() --initializes module
    print("Classic Mode Initialized")
    Classic:Start()
end

return Classic
