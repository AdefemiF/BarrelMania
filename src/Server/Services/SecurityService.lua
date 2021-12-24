-- Security Service
-- TrollD3
-- August 1, 2019
local SecurityService = {Client = {}}
local Framework, PlayerDataService
local ProfileService = require(script.Parent.Parent.Modules.ProfileService)

local SecuritySession = {}
local ADMINS = {"TrollD3", "MeltedPast"}
local Delay = 8 -- SECONDS
local Event_Limit = 7

SecurityService.Template = {
   EventsCalled = 0,
   TauntTimer = tick(),
   ExplodeTimer = tick(),
   ShootTimer = tick(),
   CurrentAction = ""; --cant taunt while shooting/ can shoot/explode while taunt
   KickNum = 0;
   isBanned = false;
}
local BanService = {};

local SecurityProfile = ProfileService.GetProfileStore("Security", SecurityService.Template)

game.Players.PlayerAdded:Connect(function(player) --creates security profile for every player that enters the game
   local PlayerProfile = SecurityProfile:LoadProfileAsync(string.format(player.UserId),"ForceLoad")--.Mock for testing
   if PlayerProfile.Data.isBanned then player:Kick("perma banned for breaking rules.") end;
   SecuritySession[player.Name] = PlayerProfile.Data
end)

game.Players.PlayerRemoving:Connect(function(player)
   spawn(function()
      local Mode = Framework:ReturnInfo("Script")
      if Mode then
         Mode:LeavingPlayer(player.Name)
      end
   end)
    local succ,result = pcall(function()
      local SaveData = SecuritySession[player.Name];
      SaveData:Release();
      player:Kick();
      SecuritySession[player.Name] = nil;
   end)
   
   
   

end)

function BanService:CommenceBan(player,msg)
--add ban to player and wipe their data
   if SecuritySession[player.Name] ~= nil then
    SecuritySession[player.Name].isBanned = true;
      PlayerDataService:WipePlayerData(player)
      if msg then
         player:Kick(msg)
      else
         player:Kick("perma banned for cheating/breaking rules. Data is wiped.")
      end
   end
end;

function BanService:Warn(player,msg)
   if SecuritySession[player.Name] ~= nil then
        SecuritySession[player.Name].KickNum +=1;
      if SecuritySession[player.Name].KickNum>=2 then
         BanService:CommenceBan(player,msg)
      end
      if msg then
         player:Kick(msg)
      else
         player:Kick("kicked for sus activity, repeat of such will result in perm ban")
      end
   end
end;

local TimerCheck = function(plr, Action, time)
   if Action == "Explode" then
      --print("ExplodingTime: " .. tostring(SecuritySession[plr].ExplodeTimer))
      if time - SecuritySession[plr].ExplodeTimer >= Delay then
         SecuritySession[plr].ExplodeTimer = time - SecuritySession[plr].ExplodeTimer
         return true
      end
   elseif Action == "Taunt" then
      if time - SecuritySession[plr].TauntTimer >= Delay then
         SecuritySession[plr].TauntTimer = time - SecuritySession[plr].TauntTimer
         return true
      end
   elseif Action == "Shoot" then
      if time - SecuritySession[plr].ShootTimer >= 1.5 then
         SecuritySession[plr].ShootTimer = time - SecuritySession[plr].ShootTimer
         return true
      end
   end
   --print(Action, "Failed!", tostring(time - SecuritySession[plr].ExplodeTimer))
   return false
end

function SecurityService:SpamDetection(plr) --more than 7  detected events within the delay period
   spawn(
      function()
         local timer = tick()
         while wait() do
            if timer - tick() >= 5 then
               break
            end
            if SecuritySession[plr].EventsCalled > Event_Limit then
               return BanService:Warn(plr,"Excessive Event Calls, repeat will be perm banned")
            end
         end
         return false
      end
   )
end

function SecurityService:ActionControl(plr, Type, Action)
   if Type == "Set" then
      SecuritySession[plr].CurrentAction = Action
   elseif Type == "Clear" then
      SecuritySession[plr].CurrentAction = ""
   end
end

function SecurityService:IsAllowedAction(ActionType, plr)
   SecuritySession[plr].EventsCalled = SecuritySession[plr].EventsCalled + 1
   SecurityService:SpamDetection(plr)
   if ActionType == "Shoot" then
      if not PlayerDataService:isAFK(plr) and PlayerDataService:GetPlayerType(plr) == "Human" and
            TimerCheck(plr, ActionType, tick())
       then SecurityService:ActionControl(plr, "Set", ActionType)
      end
      return true
   elseif ActionType == "Explode" then
      if PlayerDataService:isAFK(plr) == false and PlayerDataService:GetPlayerType(plr) == "Barrel" and
            TimerCheck(plr, ActionType, tick())
       then 
         --print(PlayerDataService:isAFK(plr),PlayerDataService:GetPlayerType(plr) == "Barrel",TimerCheck(plr, ActionType, tick()))
         SecurityService:ActionControl(plr, "Set", ActionType)
         return true
      end
   elseif ActionType == "Taunt" then
      if
         TimerCheck(plr, ActionType, tick()) and PlayerDataService:isAFK(plr) == false and
            PlayerDataService:GetPlayerType(plr) == "Human"
       then
         SecurityService:ActionControl(plr, "Set", ActionType)
         return true
      end
   end
   return false
end

function SecurityService:Start()
    print("Security Service Running!")
    Framework = self.Services.Framework
    PlayerDataService = self.Services.PlayerDataService
end
function SecurityService:Init()
end
return SecurityService
