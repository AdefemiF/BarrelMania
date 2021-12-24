--Current Module
local UIFunctions    = {};

--//Player Camera
local cam = workspace.CurrentCamera;

--//Player
local plr = game.Players.LocalPlayer;

--//UserInterface
local UI             = game.Players.LocalPlayer.PlayerGui
local PGUI           = UI.PlayerUI;
local MenuButtons    = PGUI.MenuButtons;
local Spectate       = PGUI.Spectate;
local Settings       = PGUI.Settings;
local TipUI          = PGUI.Tip;
local CurrentFrame   = nil;
local Debounce       = false;
local IsLive         = false;
local LevelUI        = PGUI.LevelUI;
--//Other UI Modules
local ShopFunctions  = require(script.Parent.ShopMaster)

--TipCounter for Tip Event
local send_tip_event = 0;

--Spectate Variables
local SpectateTable  = {};
local Current_Index  = 1;


--SoundController
local SoundController = require(script.Parent.SoundMaster)
local MasterSound     = UI.SoundHolder.MASTER
--Press Sound
local Press = UI.SoundHolder.Press


UIFunctions.IncreasePlayerXP = function(PlayerData)
    local DefaultPos = UDim2.fromScale(.323,.611) --{0.323, 0},{0.611, 0}
    local spacing = 580;
    if PlayerData["didLevelUp"] ==true then
        LevelUI.PinkBar.Load.Size = DefaultPos  
    else
        local IncreaseAmount = PlayerData["XP"]/PlayerData["XP_NEEDED_LVL_UP"];
        IncreaseAmount = (IncreaseAmount * spacing) /1000;
        LevelUI.PinkBar.Load.Size = UDim2.fromScale(.323 + IncreaseAmount , .611)
    end;
    LevelUI.Level.Text = tostring(PlayerData.LEVEL)
    LevelUI.XPLEFT.Text = tostring(PlayerData.XP) .. "/".. tostring(PlayerData.XP_NEEDED_LVL_UP);
end;

UIFunctions.SendTip  = function()--sends a tip! Send it every intermission or start of a match but make sure they arent playing/10-15min
   if send_tip_event%2~=0 then return end;
   send_tip_event = send_tip_event+1;
   local Tips = {
	  "Screenshot Bug Reports (F9) and send them to Our Discord!";
      "If you are lagging, reduce your graphics in the roblox settings!";
	  "Love you guys so much! Thanks for supporting our game! -TrollD3";
	  "Tell us what you like and don't like! Have a new idea? Shoot us a message in Discord!";
	  "Feeling Generous? Send us a donation! It would help cover college tuition costs!";
	  "If you see any hacking/anything sus, screenshot the user and let us know!";
	  "Follow our main group page and our twitter (@MysticStudios_) for updates and behind the scenes news!";
	  "Interested in joining our inner circle? Stay active in our Discord!";
	  "Want to talk with the developers and mods? Join our community Discord!";
      "Remember to have fun! Be nice to everyone! :D"
   }; 
	spawn(function()
		local num = math.random(1,#Tips)
		local chosen = Tips[num];
		TipUI.Title.Text = "TIP #"..num;
		TipUI.TextBox.Text = chosen;
		TipUI:TweenPosition(UDim2.fromScale(0.9,0.66), "Out", "Quad", 0.4);
		wait(8)
		TipUI:TweenPosition(UDim2.fromScale(1.1,0.66), "Out", "Quad", 0.4);
		
	end);
end;

UIFunctions.SimulateClick = function(obj) --Smiluates CLick with UI elements
	obj.DropShadow:TweenPosition(UDim2.fromOffset(-.8,-.8), "Out", "Quad" ,.07 );
	wait(.1)
	obj.DropShadow:TweenPosition(UDim2.fromOffset(4,4), "Out", "Quad" ,.07 );
end

UIFunctions.OpenFrame = function(FrameName)--opens the specific frame into view by tween!
	if not Debounce then 
		Debounce = true;	
		spawn(function()
			if FrameName=="Settings"then
				if CurrentFrame==FrameName then  --off
					Settings:TweenPosition(UDim2.fromScale(.5,-.5),"Out", "Quad",.4); 
					CurrentFrame = nil;
                elseif CurrentFrame ==nil then
					CurrentFrame = FrameName;
					Settings:TweenPosition(UDim2.fromScale(.5,.5),"Out", "Quad",.4);
				end;
			elseif FrameName =="Shop" and CurrentFrame ~= "Spectate" and CurrentFrame~= "Settings" then
				Spectate:TweenPosition(UDim2.fromScale(.5,.7),"Out", "Quad",.4); 
				Settings:TweenPosition(UDim2.fromScale(.5,-.5),"Out", "Quad",.4); 
				CurrentFrame = FrameName;
                ShopFunctions.Setup();
                SoundController.Play("ShopMusic")
                CurrentFrame = nil;

			elseif FrameName == "Spectate" then
				if CurrentFrame==FrameName then --off
					Spectate:TweenPosition(UDim2.fromScale(.5,.7),"Out", "Quad",.4); 
					cam.CameraSubject = plr.Character.Humanoid
					CurrentFrame = nil;
                elseif CurrentFrame ==nil then
					CurrentFrame = FrameName;
					Spectate:TweenPosition(UDim2.fromScale(.5,.5),"Out", "Quad",.4);
                    Spectate.name.TextLabel.Text = "Click arrows to spectate another player!"

				end;
				--repeat wait(1/30) v.button.Rotation = v.button.Rotation +20 until v.button.Rotation>=90
            end	
            Debounce = false;
		end)
	end;
end

UIFunctions.UpdateSpectate  = function(array1,bool)
    if bool == false then return end
    --local LiveAlert = MenuButtons.Spectate.live;
    if #array1 <=0 then SpectateTable = {} return end;
    if array1 and #array1 >= 1 then
        SpectateTable = {}
        for _,v in pairs (array1) do
            if v == plr.Name then continue end;
            table.insert(SpectateTable, v);
        end;
    end
    table.sort(SpectateTable, function(a, b) return a:lower() < b:lower() end)
    --[[
    if #SpectateTable>0 then
        if not isLive then 
            IsLive = true;
            LiveAlert:TweenSize(UDim2.fromScale(.675,.213), "Out", "Elastic", 0.4)
            local function helper(Color1,Color2)
                spawn(function()
                    for Alpha = 0, 1, 0.01 do
                        LiveAlert.ImageColor3 = LiveAlert.ImageColor3:lerp(Color1, Alpha)
                        LiveAlert.TextLabel.TextColor3 = LiveAlert.TextLabel.TextColor3:lerp(Color2, Alpha)
                        wait()
                    end
                end)
            end;

            while IsLive do
                helper(Color3.fromRGB(255, 79, 82),Color3.fromRGB(255, 255,255));
                wait(3);
                helper(Color3.fromRGB(255, 255,255) , Color3.fromRGB(255, 79, 82));
                wait(3);
            end;
        end;
    else
        LiveAlert:TweenSize(UDim2.fromScale(0,0), "Out", "Elastic", 0.4)
        IsLive = false;
        LiveAlert.ImageColor3 = LiveAlert.ImageColor3:lerp(Color3.fromRGB(255,255,255),2);
        LiveAlert.TextLabel.TextColor3 = LiveAlert.TextLabel.TextColor3:lerp(Color3.fromRGB(255, 79, 82),2);

    end;
    --]]


end

for _,v in pairs (MenuButtons:GetChildren()) do --Configures Actions for Button Onclick
	if v.ClassName =="ImageButton" then 
        v.button.MouseButton1Click:connect(function()
            --Button Pressed Sound
            Press:Play()
			UIFunctions.OpenFrame(v.Name) 
			UIFunctions.SimulateClick(v)
		end);
	end;
end;

for _,v in pairs (Settings:GetChildren()) do --Configures the Settings Frame and its equivalent ACTIONSS
	if v.Name == "Volume" or v.Name=="AFK" then
		for _,x in pairs (v:GetChildren()) do
            x.MouseButton1Click:connect(function()
                --Button Pressed Sound
                Press:Play()
				while (not _G.Aero) do wait() end
				local aero = _G.Aero
				local Framework = aero.Services.Framework
				if v.Name == "Volume" then --Kill the main Sounds manually
					if x.Name =="OFF" then
						x.ImageColor3 = Color3.fromRGB(255, 79, 82);
						v.ON.ImageColor3 = Color3.fromRGB(255,255,255)
                        Framework:WantsSound(false);
                        MasterSound.Volume = 0;
                        SoundController.Enabled(false)
					elseif x.Name =="ON" then
						x.ImageColor3 = Color3.fromRGB(63, 227, 51);
						v.OFF.ImageColor3 = Color3.fromRGB(255,255,255)
                        Framework:WantsSound(true);
                        MasterSound.Volume = 0.4;
                        SoundController.Enabled(true)
					end;
				elseif v.Name == "AFK" then
					if x.Name =="OFF" then
						x.ImageColor3 = Color3.fromRGB(255, 79, 82);
						v.ON.ImageColor3 = Color3.fromRGB(255,255,255)
						Framework:changeAFK(false);
					elseif x.Name =="ON" then
						x.ImageColor3 = Color3.fromRGB(63, 227, 51);
						v.OFF.ImageColor3 = Color3.fromRGB(255,255,255)
						Framework:changeAFK(true);
					end;
				end;
			end)
		end;
	end
end;

local debounce = false;

for _,v in pairs (Spectate:GetChildren()) do
    v.MouseButton1Click:connect(function()
        --Button Pressed Sound
        Press:Play()
        if not debounce then
            debounce = true; --no spam clicking
            if #SpectateTable ==0 then
                Spectate.name.TextLabel.Text  = "No Players Yet!";
                wait(1)
                Spectate.name.TextLabel.Text = "Click arrows to spectate another player!"
            elseif v.Name =="left" then
                if Current_Index <=1 then Current_Index = 1 end;
                if Current_Index>1 and  SpectateTable[Current_Index-1]~=nil then 
                    Current_Index-=1;
                end;
            elseif v.Name =="right" then
                if Current_Index>=#SpectateTable then Current_Index = #SpectateTable end
                if SpectateTable[Current_Index+1]~=nil then 
                    Current_Index+=1;
                end;
            end
            if SpectateTable[Current_Index] ~= nil then
                local viewofplayer = game.Players:FindFirstChild(SpectateTable[Current_Index]) or nil
                if viewofplayer then
                    cam.CameraSubject = game.Players[SpectateTable[Current_Index]].Character.Humanoid
                    Spectate.name.TextLabel.Text = SpectateTable[Current_Index]
                else
                    Spectate.name.TextLabel.Text = SpectateTable[Current_Index].." cannot be shown"
                end
            end;
            wait(.1)
            debounce = false
        end
	end)
end


return UIFunctions;

--local plr1 = {Name = "TrollD3"; Team = "Human"};
--local plr2 = {Name = "Shadow"; Team = "Barrel"};



--GameUIFuncs.KillFeed(plr1,plr2);
--wait(1);
--GameUIFuncs.KillFeed(plr2,plr1);
--
--GameUIFuncs.Sim_Actions("Taunt")
--print("Fire");
--


--Specatet Code
--if #CurrentPlayers ==0 then
--   Spectate.plr.Text = "No Players Yet!";
--else
--   if v.Name == "prev" and Spectate_Num-1>=1 then
--      Spectate_Num = Spectate_Num-1;
--      cam.CameraSubject = game.Players[CurrentPlayers[Spectate_Num]].Character.Humanoid
--      Spectate.plr.Text = game.Players[CurrentPlayers[Spectate_Num]].Name;
--   elseif v.Name == "next" and Spectate_Num+1<=#CurrentPlayers then
--      Spectate_Num = Spectate_Num+1;
--      cam.CameraSubject = game.Players[CurrentPlayers[Spectate_Num]].Character.Humanoid
--      Spectate.plr.Text = game.Players[CurrentPlayers[Spectate_Num]].Name;
--   end;
--end;

