-- Replication Handler
-- TrollD3
-- June 13, 2019

local Replication = {Client = {}}
local Replication_Event = "REPLICATION_EVENT"
local Framework, SecurityService, Ragdoll, BarrelExplosions;

function Replication.ExplosionHandler(plr) --Handles Barrel Explosions!
   --print("Explosion Executed For: " .. plr.Name)
   local barrel_hrp = plr.Character.HumanoidRootPart:FindFirstChildWhichIsA("Model")
   --Framework:SetWalkSpeed({plr.Name},0);
   
   BarrelExplosions:Boom(barrel_hrp,plr);
end

function Replication.TauntHandler(plr)
   local Anims = {3638717573, 3638714351, 3638711844}
   local Animation = Instance.new("Animation") -- create a new animation object
   Animation.AnimationId = "rbxassetid://" .. Anims[math.random(1, #Anims)] -- put your animation id over the zeroes
   local Track = plr.Character.Humanoid:LoadAnimation(Animation)
   local Sound = Instance.new("Sound")
   Sound.Volume = 0.6
   Sound.SoundId = "rbxassetid://" .. 1848780404
   Sound.Parent = plr.Character.Head
   Sound.TimePosition = 10.3
   Sound:Play()
   Track:Play()
   wait(5)
   Sound:Destroy()
   Track:Stop()
end

function Replication.Handler(plr, event, tuple)
   --insert secuity check
  -- print("Replication Handler: ", plr.Name, event, tuple)
   if event == "Shoot" and SecurityService:IsAllowedAction(event, plr.Name) then
      local GunModule = require(script.Parent.Parent.Modules.GunFramework.GunModule)
      GunModule:Fire(plr, tuple) --should just be direction
   elseif event == "Explode" and SecurityService:IsAllowedAction(event, plr.Name) then
      Replication.ExplosionHandler(plr)
   elseif event == "Taunt" and SecurityService:IsAllowedAction(event, plr.Name) then
      Replication.TauntHandler(plr)
   end
   SecurityService:ActionControl(plr.Name, "Clear")
end

function Replication:Replicate(Type, ...)
   if Type == "Shake" then
      self:FireAllClientsEvent(Replication_Event, Type, ...)
   elseif Type == "gunShake" then
      self:FireClientEvent(Replication_Event, ..., Type)
   end
end

function Replication.Client:Relay(plr, event, ...)
   local tuple = {...}
   Replication.Handler(plr, event, tuple)
end

function Replication:Start()
   Framework = self.Services.Framework
   SecurityService = self.Services.SecurityService
   Ragdoll = self.Modules.RagDoll
   BarrelExplosions = self.Modules.BarrelExplosions
end

function Replication:Init()
   self:RegisterClientEvent(Replication_Event)
end
return Replication
