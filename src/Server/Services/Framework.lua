local Players = game:GetService("Players")
--// Framework Service by TrollD3
--// started April 21, 2019

--// Services used by the Framework;
local Framework = {Client = {}}
local PlayerDataService, StoreService, MapVotingServer;

--//Name for RemoteEvent used by the Framework;
local GAME_EVENT = "GAME_EVENT"

--//Storage Locations for Game Objects used by the Game
local serverstore = game.ServerStorage
local repstore = game.ReplicatedStorage

--//Data used by the Game that changes frequently;
local GAME_DATA = {
   MIN_PLAYERS =1, --min players rewuired to start game
   INTERMISSION_TIME = 45,
   MODES = {"Classic", "Falling Barrels", "Fake Barrels"}, --"Classic" ; Juggernaut", "Throwing Barrels"; "Falling Barrels";   
   MAPS = {
	  --allowed maps on each mode
	  Classic = {"Dunes", "City", "Maze", "Gears","Outpost", "Orange Justice"}; --"City","Dunes","Maze", "Orange Justice", "Gears", 
      ["Falling Barrels"] = {"Maze", "City", "Dunes", "Outpost"}; --"City", "Maze", 
      ["Fake Barrels"] = {"City_FB", "OrangeJustice_FB"},
	  --Juggernaut = {};
	  --ThrowingBarrels={"Maze", "Dunes"};
   },
   CurrentMap = nil,
   CurrentMode = nil,
   CurrentMode_Script = nil,
   CurrentPlayers = {}, --players who are currently playing the game
   STATUS = nil, --Intermission, and Match
   AllowActions = false; --can player taunt, shoot, explode?
   MapIndex=0;
} 

---------------------------------------------------------------------------------------------------------------
---------------------------------------------CLIENT RELATED FUNCTIONS------------------------------------------
---------------------------------------------------------------------------------------------------------------

function Framework.Client:isAFK(plr)
   return PlayerDataService:isAFK(plr.Name)
end
function Framework.Client:changeAFK(plr, bool)
   PlayerDataService:isAFK(plr.Name, bool)
end
function Framework.Client:SendMapVote(plr,mapName)
    MapVotingServer:AddId(plr.UserId,mapName)
end

function Framework.Client:WantsSound(plr, bool)
   return PlayerDataService:WantsSound(plr.Name, bool)
end
function Framework.Client:WantsTips(plr, bool)
   return PlayerDataService:WantsTips(plr.Name, bool)
end
function Framework.Client:isPlaying(plr) --if in round
   for _, v in pairs(GAME_DATA.CurrentPlayers) do
	  if v == plr.Name then
		 return true
	  end
   end
   return false
end
function Framework.Client:GetStatus()
   return GAME_DATA.STATUS
end
function Framework.Client:ViewPlayerData(plr)
   return PlayerDataService:ViewPlayerData(plr);
end;
function Framework.Client:GetPlayerType(plr)
   return PlayerDataService:GetPlayerType(plr.Name)
end

function Framework.Client:GetInfo(plr, info)
   return Framework:ReturnInfo(info)
end

function Framework.Client:GetShopData()
    --return Data;
end;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------GAME RELATED FUNCTIONS--------------------------------------------
---------------------------------------------------------------------------------------------------------------
---intermission,Results,killsound, team_update, results,reset,playertype,status,

function Framework:ReturnInfo(info)
   --used to return any game information that other services might need
   if info == "Map" then
	  return GAME_DATA.CurrentMap
   elseif info == "Script" then
	  return GAME_DATA.CurrentMode_Script
   elseif info == "Mode" then
	  return GAME_DATA.CurrentMode
   elseif info == "Players" then
	  return GAME_DATA.CurrentPlayers;
   elseif info == "Time" then
	  return GAME_DATA.CurrentMode_Script.TIMER
   elseif info == "Intermission" then
	  return GAME_DATA.INTERMISSION_TIME
   elseif info == "Status" then
	  return GAME_DATA.STATUS
   end
end

function Framework:CanRoundStart() --checks if the game can start based on the num of players ready in lobby
   if #Framework:GetPlayers() >= GAME_DATA.MIN_PLAYERS then
	  return true
   end
   Framework:GAME_EVENT("UI","STATUS","Not Enough Players! " .. GAME_DATA.MIN_PLAYERS - #Framework:GetPlayers() .. " More Needed!") --tell client to get the best plr information
   return false
end

function Framework:SetStatus(Status)
   GAME_DATA.STATUS = Status;
end;

function Framework:Intermission() --Intermission for the Game
   Framework:SetStatus("INTERMISSION");
   Framework:GAME_EVENT("UI", "INTERMISSION", GAME_DATA.INTERMISSION_TIME)
   Framework:GAME_EVENT("UI", "MAPVOTING", MapVotingServer:SetChoices(GAME_DATA.MAPS[GAME_DATA.CurrentMode]))
   wait(GAME_DATA.INTERMISSION_TIME)
   Framework:GAME_EVENT("UI", "MAPVOTING", "Disable" )

end

function Framework:Shuffle(array) -- uses the fisher/yates algorthim to shuffle the given array
   math.randomseed(tick())
   local output = {}
   local random = math.random
   for index = 1, #array do
	  local offset = index - 1
	  local value = array[index]
	  local randomIndex = offset * random()
	  local flooredIndex = randomIndex - randomIndex % 1
	  if flooredIndex == offset then
		 output[#output + 1] = value
	  else
		 output[#output + 1] = output[flooredIndex + 1]
		 output[flooredIndex + 1] = value
	  end
   end
   return output
end

function Framework:GAME_EVENT(Type, EVENT,...)
   --Type == UI or ACTION, EVENT will be for UI, ... =  to UIText
   --print("SERVER EVENT: ",Type, EVENT);
   self:FireAllClientsEvent(GAME_EVENT, Type, EVENT,...);
   --handles events for the game to client. Handles UI, Sound, and any important game stuff
end

function Framework:CustomUIForPlayer(plr, Type, EVENT, ...)
    self:FireClientEvent(GAME_EVENT, plr, Type, EVENT,...);
end

function Framework:ChooseRound(Type) --introduce map voting in the future
    
   --chooses map and mode randomly
   --GAME_DATA.MAPS.Classic=Framework:Shuffle(GAME_DATA.MAPS.Classic) --keep this until map voting is implemented: Shuffles Maps allowed
    if Type == "Mode" then
        math.randomseed(os.time())

        local num = math.random(1,100)
		print(num)
        if #Framework:GetPlayers() <2 then 
            if num>=0 and num<=50 then
               GAME_DATA.CurrentMode = "Falling Barrels"
            elseif num>=50 and num<=100 then
               GAME_DATA.CurrentMode = "Fake Barrels"
            end
            GAME_DATA.CurrentMode_Script = require(script.Parent.Parent.Modules.GameModes[GAME_DATA.CurrentMode])
            return GAME_DATA.CurrentMode
        else
            if num>=1 and num<=33 then
                  GAME_DATA.CurrentMode = "Classic"
            elseif num>=34 and num<=66 then
                  GAME_DATA.CurrentMode = "Falling Barrels"
            elseif num>=67 and num<=100 then
                  GAME_DATA.CurrentMode = "Fake Barrels"
            end
            GAME_DATA.CurrentMode_Script = require(script.Parent.Parent.Modules.GameModes[GAME_DATA.CurrentMode])
            return GAME_DATA.CurrentMode
        end
    elseif Type == "Map" then
        GAME_DATA.CurrentMap = serverstore.Maps[MapVotingServer:GetMap()]:Clone()
        if workspace:FindFirstChild("Holder") ~= nil then
            GAME_DATA.CurrentMap.Parent = workspace.Holder
        else
            local holder = Instance.new("Folder")
            holder.Name = "Holder";
            GAME_DATA.CurrentMap.Parent = holder
            holder.Parent = workspace;
        end;
        return GAME_DATA.CurrentMap.Name
    end
   
end

function Framework:Reset()
   --resets game by setting certain vars nil or just resetting them;
   --print("Resetting the Game...")
   Framework:GAME_EVENT("UI", "RESET");
   MapVotingServer:ResetVote()
   for _,plr in pairs(game.Players:GetPlayers()) do
        PlayerDataService:SetPlayerType(plr.Name, "")
   end
   
   GAME_DATA.CurrentMap.Parent:ClearAllChildren();
   GAME_DATA.CurrentMode_Script:Reset()
   GAME_DATA.CurrentMode_Script, GAME_DATA.CurrentMap, GAME_DATA.CurrentMode = nil, nil, nil
   
   Framework:KillPlayers();
   GAME_DATA.CurrentPlayers = {};

   --clear any variables/folders
end

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////[END GAME FUNCTIONS]////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////

---------------------------------------------------------------------------------------------------------------
---------------------------------------------PLAYER RELATED FUNCTIONS------------------------------------------
---------------------------------------------------------------------------------------------------------------

function Framework:PlayerActions(bool)
   GAME_DATA.AllowTauntAndExplosions = bool
   Framework:GAME_EVENT("ACTION", bool)
end

function Framework:GetPlayers()
   --gets players for new round by seeing if they arent afk
   GAME_DATA.CurrentPlayers = {};
	for _, v in pairs(game.Players:GetPlayers()) do
		if not PlayerDataService:isAFK(v.Name) then --they arent afk!
		 table.insert(GAME_DATA.CurrentPlayers, v.Name)
	  end
   end
   return GAME_DATA.CurrentPlayers
end

function Framework:UpdateUIForPlayer(plr, uitype)
    self:FireClientEvent(GAME_EVENT, plr, "UI", uitype);
end


function Framework:SpawnBarrels(num)--Based off of MeltedPast's method
   local v3 = Vector3.new
   local cf = CFrame.new
   local start = GAME_DATA.CurrentMap.Top
   local no = GAME_DATA.CurrentMap.Buildings
   local no2 = GAME_DATA.CurrentMap.Spawns
   local custombarrels = {};
   for _,v in pairs (Framework:GetPlayers()) do
        
      local plrdata = PlayerDataService:ViewPlayerData(v)
      if plrdata == nil then continue end;
      if plrdata.EquippedItems.Color[1] ~= "DEFAULT" and plrdata.EquippedItems.Skin[1]=="" then
         table.insert(custombarrels, {Type = "Color"; Name = plrdata.EquippedItems.Color[1]})
      elseif plrdata.EquippedItems.Skin[1] ~= "DEFAULT" and plrdata.EquippedItems.Color[1]=="" then
         table.insert(custombarrels, {Type = "Skin"; Name = plrdata.EquippedItems.Skin[1]})
      end;
   end
   table.insert(custombarrels, {Name = "DEFAULT"})
   local barrels_per_skin = math.ceil(num/#custombarrels)
   local helper = function(num,barrel)
      --serverstore.gameObjects.Barrel:Clone() original barrel model
      for i = 1, num do
         local clone;
         if barrel.Name == "DEFAULT" then
            clone = serverstore.gameObjects.Barrel:Clone();
         else
            local ShopItems = repstore.Shop.ShopItems
            clone = ShopItems.Market[barrel.Type][barrel.Name]:Clone();
         end;
         local floors = GAME_DATA.CurrentMap.Floor:GetChildren()
         local choices = {}
         local vec =(start.CFrame *cf(math.random(-start.Size.X / 2, start.Size.X / 2), 0, math.random(-start.Size.Z / 2, start.Size.Z / 2))).p
         repeat
            game:GetService("RunService").Heartbeat:wait()
            local ray = Ray.new(vec, v3(0, -1, 0) * 1000)
            local part, pos = workspace:FindPartOnRayWithWhitelist(ray, floors)
            local region;
            if barrel.Name ~= "DEFAULT" then
               region = Region3.new(
               pos + v3(0, clone.body.Size.Y / 2, 0) - clone.body.Size / 2,
               pos + v3(0, clone.body.Size.Y / 2, 0) + clone.body.Size / 2
            )
            else
                region = Region3.new(
                    pos + v3(0, clone.Size.Y / 2, 0) - clone.Size / 2,
                    pos + v3(0, clone.Size.Y / 2, 0) + clone.Size / 2
                 )
            end
            local ps = workspace:FindPartsInRegion3WithWhiteList(region, {no,no2})
            --put in walls n such with "no"
            if part and #ps == 0 then
               table.insert(choices, pos)
            end
            for i, v in pairs(floors) do
               if v == part then
                  table.remove(floors, i)
               end
            end
            if #choices == 0 and not part then
               vec =
                  (start.CFrame *
                  cf(math.random(-start.Size.X / 2, start.Size.X / 2), 0, math.random(-start.Size.Z / 2, start.Size.Z / 2))).p
               floors = GAME_DATA.CurrentMap.Floor:GetChildren()
            end
         until #choices > 0 and not part
         if barrel.Name == "DEFAULT" then
            clone.CFrame = cf(choices[math.random(1, #choices)] + v3(0, clone.Size.Y / 2 + 0.1, 0))
            clone.CFrame = clone.CFrame * CFrame.Angles(math.rad(-90), 0, math.random(-999, 999) * math.pi / 999)
         else

            clone:SetPrimaryPartCFrame(cf(choices[math.random(1, #choices)] + v3(0, clone.body.Size.Y / 2 + 0.1, 0)))
            clone:SetPrimaryPartCFrame(clone:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(-90), 0, math.random(-999, 999) * math.pi / 999))
            for _,v in pairs (clone:GetChildren()) do
                if v.ClassName == "UnionOperation" then
                    v.Anchored = true
                end
            end
        end;
         clone.Parent = GAME_DATA.CurrentMap.Buildings.FakeBarrels
      end
   end;
   for _,v in pairs(custombarrels) do      
      helper(barrels_per_skin,v)
   end;

end

function Framework:EquipTools(Humans)
   for _, v in pairs(Humans) do
    if game.Players[v] == nil then continue end
	  local plr = game.Players[v]
	  local pistol = repstore.Tools.Pistol:Clone()
      pistol.Handle.BrickColor = BrickColor.random()
	  pistol.Parent = plr.Backpack
	  plr.Character.Humanoid:EquipTool(pistol)
   end
end

function Framework:SetWalkSpeed(Team,num)
	for _, v in pairs(Team) do
		if game.Players:FindFirstChild(v)~=nil then
			local char = game.Players[v].Character
			char.Humanoid.WalkSpeed = num
		end
	end
end

function Framework:SpawnPlayers()
	local Spawns = Framework:Shuffle(GAME_DATA.CurrentMap.Spawns:GetChildren())
	local num = 1;
	for _, v in pairs(GAME_DATA.CurrentPlayers) do
        for _,i in pairs (game.Players:GetPlayers()) do
            if i.Name== v  then --confirm that the player is still in the server
                local char = game.Players[v].Character
                spawn(function()
                    char.Humanoid.Sit = false
                    wait(0.1)
                    char.Humanoid.Sit = false
                end)
                
                char.UpperTorso.CFrame = Spawns[num].CFrame * CFrame.new(0, 2, 0)
                num = num + 1;
            end
        end
	end
end

function Framework:UpdatePlayerList(plr)
	for i, v in pairs(GAME_DATA.CurrentPlayers) do
      if v == plr.Name then
         table.remove(GAME_DATA.CurrentPlayers,i)
      end
   end
end

function Framework:KillPlayers()
   for _, v in pairs(GAME_DATA.CurrentPlayers) do
        if game.Players:FindFirstChild(v) and not PlayerDataService:isAFK(v) then
            local char = game.Players:FindFirstChild(v).Character or game.Players:FindFirstChild(v).CharacterAdded:Wait()
            char:FindFirstChild("Humanoid").Health = 0
        end
   end
end

function Framework:Start()
   print("Framework Loaded!")
   PlayerDataService = self.Services.PlayerDataService
   StoreService = self.Services.StoreService
   MapVotingServer = self.Modules.MapVotingServer
end

function Framework:Init()
   self:RegisterClientEvent(GAME_EVENT)
end
return Framework
