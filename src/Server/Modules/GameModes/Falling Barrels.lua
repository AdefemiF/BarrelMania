-- Falling Barrels
-- Username
-- February 17, 2021

---// Services used by the FallingBarrels GameMode
local Framework = require(script.Parent.Parent.Parent.Services.Framework) --Functions of Game
local PlayerDataService = require(script.Parent.Parent.Parent.Services.PlayerDataService)
local RagDoll = require(script.Parent.Parent.Parent.Modules.RagDoll)
local DeathHandler = require(script.Parent.Parent.Parent.Services.DeathHandler)
local BarrelExplosions = require(script.Parent.Parent.Parent.Modules.BarrelExplosions)
local AddData = require(script.Parent.Parent.AddData);


---//Storage used by the Server
local serverstore = game.ServerStorage

local FallingBarrels = {
    EXIT_MODE = false,
    Num_of_Waves = 3;
    Barrels_per_Wave = 125;
    SpawnMultiplier = 1;
    DEFAULT_TIME = 150,
    BLAST_RADIUS = 23,
    DAMAGE_TAKEN = 60,
    TIMER = nil,
    MapName = nil,
    Humans = {},
    PlayerData = {};
}

function FallingBarrels:LeavingPlayer(plr)
    for i, v in pairs(FallingBarrels.PlayerData) do
        if plr == v.Name then
            table.remove(FallingBarrels.PlayerData, i)
            local plrTeam =  FallingBarrels.Humans
            for x,j in pairs (plrTeam) do
                if j==v.Name then
                    table.remove(plrTeam, x)
                    break;
                end;
            end
            return FallingBarrels:UpdateSpectate()
        end
    end
end;

function FallingBarrels:UpdateSpectate()
    local Spectate = {}
    for _, v in pairs(FallingBarrels.Humans) do
        table.insert(Spectate, v);
    end
    Framework:GAME_EVENT("UI", "UPDATESPECTATE",Spectate)
end

function FallingBarrels:CreateTeams()
    local Model = Instance.new("Model")
    Model.Name = "PlayerClones"
    Model.Parent = workspace.Holder;
    for _, plr in pairs(Framework:GetPlayers()) do
        if game.Players[plr] and game.Players[plr].Character  then 
            game.Players[plr].Character.Archivable = true;
            local Clone = game.Players[plr].Character:Clone()
            if Clone and Clone.PrimaryPart then
                Clone.PrimaryPart.CFrame = CFrame.new(999,999,999)
                Clone.PrimaryPart.Anchored = true;
                Clone.Parent = Model
                table.insert(FallingBarrels.Humans, plr)
                PlayerDataService:SetPlayerType(plr, "Human")
                table.insert(FallingBarrels.PlayerData, {Name = plr, Team = "Humans", POINTS = 0}) --blank slate for all players
            end   
        end
    end
end;

function FallingBarrels:KillFeed(plr2)
    for _,v in pairs (FallingBarrels.PlayerData) do
        if v.Name ==plr2 then
            plr2 = v;
        end;
    end;
    Framework:GAME_EVENT("UI", "KILLFEED", {Name = "System"; Team = "Barrels"}, plr2)
end
function FallingBarrels:UpdateTeams(plr) --removes from human table and adds to barrel table also accounts for when barrels leave the game
    for i, v in pairs(FallingBarrels.Humans) do
        if plr == v then
            table.remove(FallingBarrels.Humans, i)
            break
        end
    end
    FallingBarrels:UpdateSpectate()
    for _, y in pairs(FallingBarrels.PlayerData) do
        if y.Name ==plr then
            y.Team = "Dead"
            break;
        end;
    end;
end

function scaleModel(model, scale)
	local origin = model.PrimaryPart.Position
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local pos = part.Position
			local rotCf = part.CFrame - pos
			local fromOriginDir = pos - origin
			part.Size *= Vector3.new(scale, scale, scale)
			part.CFrame = rotCf + origin + fromOriginDir*scale
		end
	end
end

function FallingBarrels:KillWithinRadius(BlastPosition)
    spawn(function()
        local Radius = FallingBarrels.BLAST_RADIUS
        local ExposedPlayers = FallingBarrels.Humans;
        for _, v in pairs(ExposedPlayers) do
            if game.Players[v] == nil and game.Players[v].Character == nil  then continue end
            local char = game.Players[v].Character
            if (char.HumanoidRootPart.Position - BlastPosition).Magnitude <= Radius then --replicate this
                char.Humanoid:TakeDamage(FallingBarrels.DAMAGE_TAKEN)
            end
        end
    end)
end

function FallingBarrels:CalculateXP()
    for _, v in pairs(FallingBarrels.PlayerData) do
        v.POINTS = math.ceil(v.POINTS)
        v.PersonalData = AddData:Add_XP_CASH(v.Name, v.POINTS,v.Team ~= "Dead");
    end;
end;

function FallingBarrels:AddStats(num)
    for i, v in pairs(FallingBarrels.PlayerData) do
        if v.Team == "Humans" then
            FallingBarrels.PlayerData[i].POINTS +=num
        end;
    end;
end

function FallingBarrels:TheWaves()
    spawn(function() --UNion body
        local currentwave = 1;
        for x = 1,FallingBarrels.Num_of_Waves do
            if FallingBarrels.EXIT_MODE or #FallingBarrels.Humans <1  then break end;
            currentwave = x;
            Framework:GAME_EVENT("UI", "STATUS", "Falling Barrels: Wave ".. currentwave.."/"..FallingBarrels.Num_of_Waves)
            for i=0,FallingBarrels.Barrels_per_Wave do
                if FallingBarrels.EXIT_MODE or #FallingBarrels.Humans <1 then break end;
                local b = serverstore.gameObjects.GameBarrel:Clone();
                local particle = serverstore.gameObjects.FallingBarrelParticle:Clone();
                if not workspace.Holder:FindFirstChild(FallingBarrels.MapName) then break end;
                local barrelspawn = workspace.Holder[FallingBarrels.MapName].Top
                local attach1 = Instance.new("Attachment", b.original.Union)
                local attach2 = Instance.new("Attachment", b.original.body)
	            local trail = Instance.new("Trail",b.original)
                attach2.Position = attach2.Position + Vector3.new(0,0,1)
                particle.Parent = b.original.body;
                trail.Color = ColorSequence.new(Color3.fromHSV(math.random(300)/300, 1,2))
                trail.FaceCamera = true
                trail.Attachment0 = attach1
                trail.Attachment1 = attach2
                b.Parent = workspace.Holder[FallingBarrels.MapName].Buildings.FakeBarrels;
                scaleModel(b, math.random(1,2))
                               --start of me code!
                
                if math.random() < .2 then
    
                    local n = math.random(1,#FallingBarrels.Humans)
                    local p = game.Players:FindFirstChild(FallingBarrels.Humans[n])
                    
                    local spawnCF = (p.Character.PrimaryPart.CFrame - 
                        Vector3.new(0,p.Character.PrimaryPart.CFrame.Y - barrelspawn.CFrame.Y,0)) * 
                        CFrame.Angles(math.rad(math.random(0,90)),math.rad(math.random(0,90)),math.rad(math.random(0,90)))
                    
                    b:SetPrimaryPartCFrame(spawnCF)
            
                else
                    local spawnX, spawnZ = barrelspawn.Size.X*.85, barrelspawn.Size.Z*.85;
                    b:SetPrimaryPartCFrame(barrelspawn.CFrame *
                        CFrame.Angles(math.rad(math.random(0,90)),math.rad(math.random(0,90)),math.rad(math.random(0,90))) *
                        CFrame.new(math.random(-spawnX/2,spawnX/2),math.random(-spawnZ/2,spawnZ/2),0))
                end           
                            --end of me code!
                for _,v in pairs (b:GetDescendants()) do
                    if v.ClassName=="UnionOperation" or v.ClassName== "Part" then
                        v:SetNetworkOwner(nil)
                    end
                end;
                spawn(function()
                    wait(math.random(3,5))
                    BarrelExplosions:BarrelBoom(b)
                end)
                wait(.4)
            end
            if FallingBarrels.EXIT_MODE or #FallingBarrels.Humans <1 then break end;
            if x ==1 then
                FallingBarrels:AddStats(10)
            elseif x==2 then
                FallingBarrels:AddStats(20)
            elseif x==3 then
                FallingBarrels:AddStats(30)
            end
            wait(5)
        end
    end)
end;

function FallingBarrels:OnDeath(plr) --handles death for FallingBarrels game mode
    if PlayerDataService:GetPlayerType(plr.Name) == "Human" then
        FallingBarrels:UpdateTeams(plr.Name)
        local plrchar = plr.Character;
        if plrchar and plrchar:FindFirstChild("LowerTorso") then
            Framework:GAME_EVENT("UI", "INDICATOR", "SKULL", plr.Character.LowerTorso.Position, "Human")
        end
            RagDoll:Simulate(plr.Name)
        DeathHandler:DeathSound(plr.Character)
        FallingBarrels:KillFeed(plr.Name)
        
        if #FallingBarrels.Humans~=0 then
            Framework:CustomUIForPlayer(plr,"UI", "RESET",false);
            wait(.5)
            Framework:UpdateUIForPlayer(plr, "UPDATE");
        end
        plr:LoadCharacter()
        FallingBarrels:UpdateSpectate()

    end
end;

function FallingBarrels:Reset()
    FallingBarrels.PlayerData = {}
    FallingBarrels.TIMER = FallingBarrels.DEFAULT_TIME
    FallingBarrels.Humans = {}
    Framework:GAME_EVENT("UI", "SPECTATE", {})
    FallingBarrels.EXIT_MODE = false;
end

function FallingBarrels:CanRoundEnd(timer)
    --print("Humans: " .. #FallingBarrels.Humans)

    if #FallingBarrels.Humans <1 then
        FallingBarrels.EXIT_MODE = true
        Framework:PlayerActions(false)
        FallingBarrels:CalculateXP();
        return true, Framework:GAME_EVENT("UI", "RESULTS", "No Players", FallingBarrels.PlayerData)
    elseif timer <= 0 and #FallingBarrels.Humans >= 1 then
        FallingBarrels.EXIT_MODE = true
        Framework:PlayerActions(false)
        FallingBarrels:CalculateXP();
        return true, Framework:GAME_EVENT("UI", "RESULTS", "Humans", FallingBarrels.PlayerData)
    else
        return false, "Match In Progress"
    end
end

function FallingBarrels:Start()
    --print("Falling Barrels Mode Started")
    FallingBarrels.MapName = Framework:ReturnInfo("Map").Name;

    Framework:GAME_EVENT("UI", "STATUS", "Falling Barrels Mode Chosen!")
    Framework:GAME_EVENT("UI", "STATUS", "Spawning Objects")
    if workspace.Holder[FallingBarrels.MapName]:FindFirstChild("Animation") then  
        workspace.Holder[FallingBarrels.MapName].Animation.Disabled = false; 
    end;
    Framework:SetStatus("CUTSCENE")

    Framework:GAME_EVENT("UI", "STATUS", "Starting CutScene")
    Framework:GAME_EVENT("UI", "CUTSCENE")
    if workspace.Holder[FallingBarrels.MapName]:FindFirstChild("Animation") then  
        workspace.Holder[FallingBarrels.MapName].Animation.Disabled = false; 
    end;

    wait(20);
    FallingBarrels:CreateTeams()

    Framework:SetWalkSpeed(FallingBarrels.Humans, 0)
    Framework:SpawnPlayers()

    Framework:GAME_EVENT("UI", "ROUNDINTRO")
    Framework:GAME_EVENT("UI", "STATUS", "Falling Barrels");

    wait(12)

    Framework:SetWalkSpeed(FallingBarrels.Humans, 23)
    FallingBarrels:UpdateSpectate()

    Framework:GAME_EVENT("UI", "STATUS", "Remaining Time: ", FallingBarrels.DEFAULT_TIME)
    Framework:SetStatus("MATCH")
    local AllowActions = false
    delay(1, function() FallingBarrels:TheWaves() end)
    for i = FallingBarrels.DEFAULT_TIME, 0, -1 do
        FallingBarrels.TIMER = i
        if FallingBarrels.DEFAULT_TIME-i > 6 and not AllowActions then
            AllowActions = true;
			Framework:PlayerActions(true);
        end        
        if FallingBarrels:CanRoundEnd(i) then
            Framework:SetStatus("ROUNDEND");
            FallingBarrels.EXIT_MODE = true
            FallingBarrels:Reset()
            Framework:SetWalkSpeed(FallingBarrels.Humans, 0)
            break
        end
        FallingBarrels:UpdateSpectate()

        wait(1)
        FallingBarrels:AddStats(.5)
    end
end;

function FallingBarrels:Init() --initializes module
    print("Falling Barrels Mode Initialized")
    FallingBarrels:Start()
end

return FallingBarrels