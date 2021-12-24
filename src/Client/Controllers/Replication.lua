-- Replication
-- TrollD3
-- June 15, 2019
local Replication = { AllowExplosionsAndTaunt = false; ActionDelay = 8;}
local CAS = game:GetService("ContextActionService")
local ReplicationHandler, CameraShaker,Framework;
local camera;
local plr;
local character;
local CanExplode = false;
local CanTaunt = false;
local player = game.Players.LocalPlayer;
local PlayerGui = player.PlayerGui;
local GameUI = PlayerGui:FindFirstChild("GameUI") or PlayerGui:WaitForChild("GameUI");
local ActionUI = GameUI.ActionUI;

local TauntUI = ActionUI:FindFirstChild("Taunt") or ActionUI:WaitForChild("Taunt")
local ExplodeUI = ActionUI:FindFirstChild("Explode") or ActionUI:WaitForChild("Explode")


local Sim_Actions = function(Action) --simulates the button clicks
	local ColorSwitch = {
		Explode = {In = Color3.fromRGB(124, 31, 37); Out = Color3.fromRGB(255, 76, 85);};
		Taunt = {In = Color3.fromRGB(117, 63, 35); Out = Color3.fromRGB(222, 123, 73);};
		Shoot = {In = Color3.fromRGB(38, 77, 117); Out = Color3.fromRGB(85, 170, 255);};
	}; 
	spawn(function()
		ActionUI[Action].DropShadow:TweenPosition(UDim2.fromOffset(0,0), "Out", "Quad", .2);
		ActionUI[Action].ImageColor3 = ColorSwitch[Action].In;
		ActionUI[Action].TextLabel.TextColor3 = Color3.fromRGB(190, 190, 190);	
		wait(Replication.ActionDelay);
		ActionUI[Action].DropShadow:TweenPosition(UDim2.fromOffset(4,4), "Out", "Quad", .2); 
		ActionUI[Action].ImageColor3 = ColorSwitch[Action].Out;
		ActionUI[Action].TextLabel.TextColor3 = Color3.fromRGB(255,255,255);	
	end)
end

--CHECK THE CONDITIONS FOR FIRING THE ACTIONS
local function startAction(actionName, userInputState)
--Tweak this for Multiple GameModes
--print(actionName, userInputState, Replication.AllowExplosionsAndTaunt, Framework:GetPlayerType(plr)=="Barrel", CanExplode)
   if actionName == "Explode" and userInputState == Enum.UserInputState.Begin and Replication.AllowExplosionsAndTaunt and Framework:GetPlayerType(plr)=="Barrel"  and not CanExplode  then
      CanExplode = true;
      ReplicationHandler:Relay("Explode");
      --print("StartAction Function Fired")
      Sim_Actions(actionName);
      wait(Replication.ActionDelay);

      CanExplode = false;
   elseif actionName == "Taunt" and userInputState == Enum.UserInputState.Begin and Framework:GetPlayerType(plr)=="Human"  and Replication.AllowExplosionsAndTaunt and not CanTaunt then
      CanTaunt = true;
      ReplicationHandler:Relay("Taunt");
      Sim_Actions(actionName)
      wait(Replication.ActionDelay);

      CanTaunt = false;
   end
end

local function startActionTouch(actionName) -- for mobile tapping
    if actionName == "Explode"  and Replication.AllowExplosionsAndTaunt and Framework:GetPlayerType(plr)=="Barrel"  and not CanExplode  then
        CanExplode = true;
        ReplicationHandler:Relay("Explode");
        --print("StartAction Function Fired")
        Sim_Actions(actionName);
        wait(Replication.ActionDelay);
  
        CanExplode = false;
     elseif actionName == "Taunt" and Framework:GetPlayerType(plr)=="Human"  and Replication.AllowExplosionsAndTaunt and not CanTaunt then
        CanTaunt = true;
        ReplicationHandler:Relay("Taunt");
        Sim_Actions(actionName)
        wait(Replication.ActionDelay);
  
        CanTaunt = false;
     end
end

TauntUI.MouseButton1Down:connect(function()
    startActionTouch("Taunt")
end)
ExplodeUI.MouseButton1Down:connect(function()
    startActionTouch("Explode")
end)


function Replication:ActionEnabled(bool) --remake this to add gamemodes changes
    Replication.AllowExplosionsAndTaunt = bool;
    if bool then 
        CAS:BindAction("Explode", startAction, false, Enum.KeyCode.E);--this will vary per game mode
        CAS:BindAction("Taunt", startAction, false, Enum.KeyCode.T);
        --print("Binded Actions Completed")
    else
        --CAS:UnbindAllActions();
        CAS:UnbindAction("Explode");
        CAS:UnbindAction("Taunt");
    end;
end;


function Replication:Start()
   plr  = game.Players.LocalPlayer;
   character = plr.Character;
   ReplicationHandler = self.Services.ReplicationHandler;
   Framework = self.Services.Framework;
   camera  = workspace.CurrentCamera;
   CameraShaker = self.Modules.CameraShake;
   local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
      camera.CFrame = camera.CFrame * shakeCFrame;
   end);
   ReplicationHandler["REPLICATION_EVENT"]:Connect(function(Type,pos)
      if Type == "Shake" then
         if character and character:FindFirstChild("Head") then
            local mag = (character.Head.Position -pos).Magnitude;
            if mag>70 then return end;
            camShake:Start();
            if mag<=15 then
                  camShake:Shake(CameraShaker.Presets.Explosion);
            elseif mag>15 and mag<25 then
                  camShake:Shake(CameraShaker.Presets.Bump);
            elseif mag>25 and mag<33 then
                  camShake:Shake(CameraShaker.Presets.Bump2);
            end;
         end
      elseif Type=="gunShake" then
         camShake:Start();
         camShake:Shake(CameraShaker.Presets.Bump);
      end;
   end);
end;

function Replication:Init()
end;
return Replication