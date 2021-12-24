-- Fake Barrels
-- TrollD3
-- December 5, 2021

---// Services used by the FakeBarrels GameMode
local Framework = require(script.Parent.Parent.Parent.Services.Framework) --Functions of Game
local PlayerDataService = require(script.Parent.Parent.Parent.Services.PlayerDataService)
local RagDoll = require(script.Parent.Parent.Parent.Modules.RagDoll)
local DeathHandler = require(script.Parent.Parent.Parent.Services.DeathHandler)
local BarrelExplosions = require(script.Parent.Parent.Parent.Modules.BarrelExplosions)
local AddData = require(script.Parent.Parent.AddData);

---//Storage used by the Server
local serverstore = game.ServerStorage

local FakeBarrels = {
    DEFAULT_TIME = 65,
    DAMAGE_TAKEN = 100,
    TIMER = nil,
    MapName = nil,
    Humans = {},
    PlayerData = {};
    NumofCompleted = 0;
    WalkSpeed = 20;
    CorrectPoint = 15;
    CompletedPoints = 25;
}





function FakeBarrels:CreateTeams()
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
                table.insert(FakeBarrels.Humans, plr)
                PlayerDataService:SetPlayerType(plr, "Human")
                table.insert(FakeBarrels.PlayerData, {Name = plr, Team = "Humans", POINTS = 0, Completed = false}) --blank slate for all players
            end   
        end
    end
end



function FakeBarrels:KillFeed(plr)
    for _,v in pairs (FakeBarrels.PlayerData) do
        if v.Name ==plr then
            plr = v;
        end;
    end;
    Framework:GAME_EVENT("UI", "KILLFEED", {Name = "Game"; Team = "Barrels"}, plr)
end


function FakeBarrels:AddStats(plr,points)
    print(plr,points)
    for i, v in pairs(FakeBarrels.PlayerData) do
        if v.Name == plr then
            FakeBarrels.PlayerData[i].POINTS +=points
        end;
    end;
end
function FakeBarrels:CalculateXP()
    for _, v in pairs(FakeBarrels.PlayerData) do
        v.POINTS = math.ceil(v.POINTS)
        v.PersonalData = AddData:Add_XP_CASH(v.Name, v.POINTS,v.Completed == true);
    end;
end
function FakeBarrels:LeavingPlayer(plr)
    for i, v in pairs(FakeBarrels.Humans) do
        if plr == v then
            table.remove(FakeBarrels.Humans, i)
            break
        end
    end
    for i, v in pairs(FakeBarrels.PlayerData) do
        if plr == v.Name then
            table.remove(FakeBarrels.PlayerData, i)
            return FakeBarrels:UpdateSpectate()
        end
    end
end
function FakeBarrels:OnDeath(plr)
    if PlayerDataService:GetPlayerType(plr.Name) == "Human" then
        local plrchar = plr.Character;
        if plrchar and plrchar:FindFirstChild("LowerTorso") then
            Framework:GAME_EVENT("UI", "INDICATOR", "SKULL", plr.Character.LowerTorso.Position, "Human")
        end
            RagDoll:Simulate(plr.Name)
        DeathHandler:DeathSound(plr.Character)
        FakeBarrels:KillFeed(plr.Name)
        plr:LoadCharacter()
        if plr.Character:FindFirstChild("ForceField") then
            plr.Character:FindFirstChild("ForceField"):Destroy()
        end
        for _, v in pairs(FakeBarrels.PlayerData) do
            if plr.Name == v.Name then
                if v.Completed then
                    local spawns = Framework:ReturnInfo("Map").CompleteSpawn:GetChildren()
                    plr.Character.UpperTorso.CFrame = spawns[math.random(1, #spawns)].CFrame * CFrame.new(0, 2, 0)
                else
                    local spawns = Framework:ReturnInfo("Map").Spawns:GetChildren()
                    plr.Character.UpperTorso.CFrame = spawns[math.random(1, #spawns)].CFrame * CFrame.new(0, 2, 0)
                end
            end
        end
        plr.Character.Humanoid.WalkSpeed = FakeBarrels.WalkSpeed

    end
end
function FakeBarrels:UpdateSpectate()
    local Spectate = {}
    for _, v in pairs(FakeBarrels.Humans) do
        table.insert(Spectate, v);
    end
    Framework:GAME_EVENT("UI", "UPDATESPECTATE",Spectate)
end

function FakeBarrels:PlayerSuccess(plr)
    for _, v in pairs(FakeBarrels.PlayerData) do
        if plr == v.Name then
            v.Completed = true
            FakeBarrels.NumofCompleted+=1
            v.POINTS += (FakeBarrels.CompletedPoints/2)
        end
    end
end

function FakeBarrels:Reset()
    FakeBarrels.PlayerData = {}
    FakeBarrels.TIMER = FakeBarrels.DEFAULT_TIME
    FakeBarrels.Humans = {}
    Framework:GAME_EVENT("UI", "SPECTATE", {})
    FakeBarrels.NumofCompleted=0
end

function FakeBarrels:CanRoundEnd(timer)
    if timer<=0 or #FakeBarrels.Humans<=0 or FakeBarrels.NumofCompleted>=#FakeBarrels.Humans then
        Framework:PlayerActions(false)
        FakeBarrels:CalculateXP();
        return true, Framework:GAME_EVENT("UI", "RESULTS", "Nice", FakeBarrels.PlayerData)
    else
        return false, "Match In Progress"
    end
end

function FakeBarrels:SpawnBarrelGrid()
    local array = {}
    local spacing = 22
    local numX = 5;
    local numY = 6;
    local count = 0
    for row=1,numX do --> going to the right
        array[row] = {}
        for col=1,numY do -- going up
            array[row][col] = count
            count+=1
        end
    end
 
    local CFRef = Framework:ReturnInfo("Map").CFrameRef
    local holder = Framework:ReturnInfo("Map").Buildings.FakeBarrels

    local v3 = Vector3.new
    local correct_barrels = {}
    local function fitHolder(avg) -- avg of all spawn locations (should be the center)
        
        local clone = CFRef:Clone()
        clone.CFrame = clone.CFrame - clone.CFrame.p + avg
        clone.Parent = holder
        holder.PrimaryPart = clone
        holder:SetPrimaryPartCFrame(CFRef.CFrame)
        clone:Destroy()
        
    end
    local output_path = function(startx,starty)
        local clone = serverstore.gameObjects.FB_BARREL:Clone();
        local levels = 1
        local directions = {"up", "left", "right"}
        local prev_dir = ""
        local currentrow,currentcol = startx,starty
        local path = {{currentrow,currentcol}}
        
        repeat
            wait()
            local chosen_dir = directions[math.random(1,#directions)]
            --print("chosen dir:", chosen_dir, "currentpath:", currentrow,currentcol)
            if chosen_dir == "left" and prev_dir~="right" and currentrow~=1 then
                prev_dir = "left"
                table.insert (path, {currentrow-1,currentcol})
                currentrow -=1
            elseif  chosen_dir == "right" and prev_dir~="left" and currentrow ~=numX then
                prev_dir = "right"
                table.insert (path, {currentrow+1,currentcol})
                currentrow +=1
            elseif chosen_dir == "up" and currentcol ~=numY then
                prev_dir = "up"
                table.insert (path, {currentrow,currentcol+1})
                currentcol +=1
                levels +=1
            end
        until levels == numY or currentcol == numY
        --print("Path Complete: ", path)
        
        local total = v3()
        for row=1,numX do --> going to the right
            for col=1,numY do -- going up
                local part = clone:Clone()
                local newCF = CFRef.CFrame * CFrame.new(row*spacing,  col*spacing,0)
                part:SetPrimaryPartCFrame(newCF)
                total += newCF.p
                part.Parent = Framework:ReturnInfo("Map").Buildings.FakeBarrels
                part.original.body.Anchored = true
                for _,v in pairs (path) do
                    if v[1] == row and v[2] == col then
                        part.Name = "0000"
                        --part.body.Color = Color3.fromRGB(60, 128, 255)
                        --part.cen.Color = Color3.fromRGB(60, 128, 255)
                        table.insert(correct_barrels, part)
                    else
                        
                    end
                end
                    
            end
        end
        
        fitHolder(total/(numX * numY))
        
        for i,v in pairs (Framework:ReturnInfo("Map").Buildings.FakeBarrels:GetChildren()) do
            if v.Name ~= "0000" then
                local connect
                connect = v.original.body.Touched:connect(function(part)
                    if part and part.Parent:FindFirstChild("Humanoid") then
                        part.Parent.Humanoid.Health =0
                    end;
                    v.original.body.Anchored = false
                    FakeBarrels.AddStats(part.Parent.Name, 5)

                    v.original.body.Color = Color3.fromRGB(255, 31, 35)
                        v.original.body.Material = "Neon"
                        v.original.cen.Color = Color3.fromRGB(255, 31, 35)
                        v.original.cen.Material = "Neon"
                    BarrelExplosions:BarrelBoom(v,false)
                    local sound =Framework:ReturnInfo("Map").wrong:Clone()
                    sound.Parent = v
                    sound:Play()
                    connect:Disconnect()
                end)
            else
                local connect 
                    connect = v.original.body.Touched:connect(function(part)
                    if part and part.Parent:FindFirstChild("Humanoid") then
                        local plr = game.Players:GetPlayerFromCharacter(part.Parent)
                        Framework:CustomUIForPlayer(plr, "UI", "NICE", FakeBarrels.CorrectPoint)
                        FakeBarrels:AddStats(plr.Name, FakeBarrels.CorrectPoint)
                        v.original.body.Color = Color3.fromRGB(44, 190, 64)
                        v.original.body.Material = "Neon"
                        v.original.cen.Color = Color3.fromRGB(44, 190, 64)
                        v.original.cen.Material = "Neon"
                        local sound = Framework:ReturnInfo("Map").correct:Clone()
                        sound.Parent = v
                        sound:Play()
                        connect:Disconnect()
                    end
                end)
                
            end
        end
        --for i,v in pairs (path) do
        --	local part = clone:Clone()
        --	part.Parent = workspace.holder
        --	part:SetPrimaryPartCFrame(workspace.Part.CFrame *CFrame.new(5,0,-5) * CFrame.new(v[1]*23,  v[2]*23,0)) 
        --	--part.BrickColor = BrickColor.random()
        --end
        --wait(3)
        --local function shuffle(t)
        --	local j, temp
        --	for i = #t, 1, -1 do
        --		j = math.random(i)
        --		temp = t[i]
        --		t[i] = t[j]
        --		t[j] = temp
        --	end
        --end
        --shuffle((correct_barrels))
        return correct_barrels
    end
    return output_path(math.random(1,numX),1)
end

function FakeBarrels:ShowPath(correct_barrels)
    spawn(function()
        local num = 0
        while num <2 do
            local increm = 1
            while increm<= #correct_barrels do
                local chosen_barrel = correct_barrels[increm]
                chosen_barrel.original.body.Color = Color3.fromRGB(255, 163, 71)
                chosen_barrel.original.cen.Color = Color3.fromRGB(255, 163, 71)
                chosen_barrel.original.Union.Color = Color3.fromRGB(202, 202, 202)
                chosen_barrel.original.body.Material = "Neon"
    
                wait(.1)
                chosen_barrel.original.body.Color = Color3.fromRGB(252, 100, 92)
                chosen_barrel.original.cen.Color = Color3.fromRGB(252, 100, 92)
                chosen_barrel.original.Union.Color = Color3.fromRGB(184, 184, 184)
    
                chosen_barrel.original.body.Material = "SmoothPlastic"
    
                increm+=1
            end
            num+=1
        end
    
    end)
    
end

function FakeBarrels:HandleWins()
    local complete = Framework:ReturnInfo("Map").Goal
    local debounce = false

    complete.Touched:connect(function(part)
            if part and part.Parent:FindFirstChild("Humanoid") and not debounce then
                debounce = true
                FakeBarrels:PlayerSuccess(part.Parent.Name)
                local spawns = Framework:ReturnInfo("Map").CompleteSpawn:GetChildren()
                part.Parent.UpperTorso.CFrame = spawns[math.random(1, #spawns)].CFrame * CFrame.new(0, 2, 0)
                local plr = game.Players:GetPlayerFromCharacter(part.Parent)
                Framework:CustomUIForPlayer(plr, "UI", "NICE", FakeBarrels.CorrectPoint)
                wait(.1)
                debounce = false
            end
        
        
    end)

end


function FakeBarrels:Start()
    print("FakeBarrels Mode Started")
    FakeBarrels.MapName = Framework:ReturnInfo("Map").Name;

    Framework:GAME_EVENT("UI", "STATUS", "FakeBarrels Mode Chosen!")
    Framework:GAME_EVENT("UI", "STATUS", "Spawning Objects")
    Framework:SetStatus("CUTSCENE")
    Framework:GAME_EVENT("UI", "STATUS", "Starting CutScene")
    Framework:GAME_EVENT("UI", "CUTSCENE")
    if workspace.Holder[FakeBarrels.MapName]:FindFirstChild("Animation") then  
        workspace.Holder[FakeBarrels.MapName].Animation.Disabled = false; 
    end;

    wait(18) 
    local path = FakeBarrels:SpawnBarrelGrid()
    FakeBarrels:HandleWins()
    
    FakeBarrels:CreateTeams()

    Framework:SetWalkSpeed(FakeBarrels.Humans, 0)
    Framework:SpawnPlayers()

    Framework:GAME_EVENT("UI", "ROUNDINTRO")
    Framework:GAME_EVENT("UI", "STATUS", "Fake Barrels");

    wait(12)
    FakeBarrels:UpdateSpectate()


    Framework:GAME_EVENT("UI", "STATUS", "Remaining Time: ", FakeBarrels.DEFAULT_TIME)
    Framework:SetStatus("MATCH")

    local AllowActions = false
    FakeBarrels:ShowPath(path)
    AllowActions = true;
    Framework:PlayerActions(true);

    Framework:SetWalkSpeed(FakeBarrels.Humans, FakeBarrels.WalkSpeed)

    for i = FakeBarrels.DEFAULT_TIME, 0, -1 do
        FakeBarrels.TIMER = i
        if FakeBarrels:CanRoundEnd(i) then
            Framework:SetWalkSpeed(FakeBarrels.Humans, 0)

            Framework:SetStatus("ROUNDEND");
            FakeBarrels:Reset()
            Framework:SetWalkSpeed(FakeBarrels.Humans, 0)
            break
        end
        wait(1)
        --FakeBarrels:AddStats(.5)
    end

end

function FakeBarrels:Init()
    print("FakeBarrels Mode Initialized")
    FakeBarrels:Start()
end

return FakeBarrels
