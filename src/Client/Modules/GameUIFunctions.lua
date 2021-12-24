
--//Module
local GameUIFunc        = {ActionCoolDown = 3; GameCountDown = 10; RespawnTime = 3.5;}; --Holds All of the functions below to be used in other scripts

--//Player UI Variables
local player            = game.Players.LocalPlayer
local PGUI              = player.PlayerGui.PlayerUI;
local GameUI            = player.PlayerGui.GameUI;
local Status            = GameUI.Status

local TimerUI           = Status.Time;
local ActionUI          = GameUI.ActionUI;
local KillFeedUI        = GameUI.killfeed;
local InGamePoints      = GameUI.inGamePoints;
local GameObjective     = GameUI.Objective;
local RespawnUI         = GameUI.Respawn;
local CutSceneUI        = GameUI.cutscene;

--//PlayerCamera
local Cam               = workspace.CurrentCamera;

--//Values
local GameTimer         = nil;
local BreakTimer        = false;
local KillFeed          = {[1] = nil; [2] = nil; [3] = nil;[4] = nil;[5] = nil;};
local GameMode          = nil;

local HealthBarLoop     = false

local tweenService      = game:GetService("TweenService")


GameUIFunc.UpdateStatus = function(Text,Timer)--Updates the Status UI
   Status.StatusText.Text = Text;
   if Timer then
	  GameUIFunc.ShowTimer();
	  GameUIFunc.StartTimer(Timer);
   end;
end;

GameUIFunc.UpdateTeamScore  = function(Team1,Team2) --Update Team Score
	if Team1 then
		Status.Team1.TextLabel.Text = Team2;
	end
	if Team2 then
		Status.Team2.TextLabel.Text = Team1;
	end
end

GameUIFunc.ClearRoundUI = function()--Clear GameUI by Tween
    KillFeedUI.Frame:ClearAllChildren()
	KillFeed = {[1] = nil; [2] = nil; [3] = nil;[4] = nil;[5] = nil;};
	TimerUI:TweenPosition(UDim2.fromScale(.28,0), "Out", "Quad", .6);
	Status.Team1:TweenPosition(UDim2.fromScale(0,.183), "Out", "Quad", .5);
	Status.Team2:TweenPosition(UDim2.fromScale(.7,.183), "Out", "Quad", .5);
	ActionUI:TweenPosition(UDim2.fromScale(.5,.6), "Out", "Quad", .5);
   game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)




end

GameUIFunc.ShowActions  = function(Type, isIntro)
    local function show()
        if GameMode =="Classic" then
            if Type == "Human" then
                ActionUI:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad", .5);
                ActionUI.Shoot.Visible = true
                ActionUI.Taunt.Visible = true
                ActionUI.Explode.Visible = false
                ActionUI.ActionCountDown:TweenPosition(UDim2.fromScale(.404,.875), "Out", "Quad", .5)

            else
                ActionUI:TweenPosition(UDim2.fromScale(.554,.5), "Out", "Quad", .5);
                ActionUI.Explode.Visible = true
                ActionUI.Taunt.Visible = false
                ActionUI.Shoot.Visible = false
                ActionUI.ActionCountDown:TweenPosition(UDim2.fromScale(.34,.862), "Out", "Quad", .5)

            end
        elseif GameMode == "Falling Barrels" or GameMode == "Fake Barrels" then
            ActionUI.Taunt.Visible = true
            ActionUI.Explode.Visible = false
            ActionUI.Shoot.Visible = false
            ActionUI:TweenPosition(UDim2.fromScale(.446,.5), "Out", "Quad", .5);
            ActionUI.ActionCountDown:TweenPosition(UDim2.fromScale(.45,.862), "Out", "Quad", .5)
        end;
    end;
    show()

    if isIntro==false then return end;
    ActionUI.Visible = true
    ActionUI.ActionCountDown.Visible = true;

    ActionUI.ActionCountDown:TweenSize(UDim2.fromScale(.166,.026), "Out", "Quad", .5)

    --Taunt: X = .446
    --game.StarterGui:SetCore("ResetButtonCallback", false);
	--ActionUI:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad", .5);
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	spawn(function()
		for i = 5,0,-1 do
			ActionUI.ActionCountDown.TextLabel.Text = "Actions/Tools will be activated in ".. i;
			wait(1)
		end;
		ActionUI.ActionCountDown:TweenSize(UDim2.fromScale(0,.026), "Out", "Quad", .5)
		ActionUI.ActionCountDown.TextLabel.Text = "";
	end)

end

GameUIFunc.KillFeed     = function(plr1,plr2) --when it 2 tables, when it gets sent plr = {name;team;}
    if plr1 == nil then plr1 = {Name= "PlayerLeft"; Team = "Barrels"}end
    if plr2 == nil then plr2 = {Name= "PlayerLeft"; Team = "Barrels"} end
	spawn(function()
		local ShiftUI = function(newUI,timer)
			for i=5,1,-1 do
				if i ~=1 and KillFeed[i-1]  then
					if i==5 or (tick() - timer >= 5) then
						spawn(function()
							repeat wait() 
								if KillFeed[i].Parent == nil then break end
								KillFeed[i].ImageTransparency = KillFeed[i].ImageTransparency +.1;
								KillFeed[i].plr1.TextTransparency = KillFeed[i].plr1.TextTransparency + .1;
								KillFeed[i].plr2.TextTransparency = KillFeed[i].plr2.TextTransparency + .1;
								KillFeed[i].ImageLabel.ImageTransparency = KillFeed[i].ImageLabel.ImageTransparency + .1;
							until KillFeed[i].ImageLabel.ImageTransparency >=1;
							KillFeed[i]:Destroy();
						end)
					end
                    if newUI == nil and KillFeed[i]==nil then return end;
					KillFeed[i] = KillFeed[i-1];
                    if newUI.Parent == nil and KillFeed[i].Parent == nil then return end;

					KillFeed[i]:TweenPosition(UDim2.fromScale(.01,KillFeed[i].Position.Y.Scale-.06), "Out", "Quad", .4);
				elseif i==1 then
					KillFeed[i] = newUI;
                    if newUI.Parent == nil then return end;
		            KillFeed[i]:TweenPosition(UDim2.fromScale(.01,.643), "Out", "Quad", .4);
				end
			end
        end
        local UI = KillFeedUI[plr1.Team]:Clone();
		UI.plr1.Text = plr1.Name;
        UI.plr2.Text = plr2.Name;
        UI.Parent = KillFeedUI.Frame;
		ShiftUI(UI,tick());
	end)
end

GameUIFunc.HidePlayerUI = function()
	PGUI.Enabled = false;
end

GameUIFunc.ShowPlayerUI = function()
	PGUI.Enabled = true;
end

GameUIFunc.HideStatusbar = function()
	GameUI.TopBar.Visible = false;
	GameUI.Status.Visible = false;
end

GameUIFunc.ShowStatusbar = function()
	GameUI.TopBar.Visible = true;
	GameUI.Status.Visible = true;
end

GameUIFunc.MatchSignal  = function(Signal) --GO or STOP
	local UI = GameUI[Signal];
	if Signal=="GO" then 
		UI:TweenSize(UDim2.fromScale(.32,.371), "Out", "Quad",.5);
		wait(1.3);
		UI:TweenSize(UDim2.fromScale(0,0), "Out", "Quad",.2);
	else
        HealthBarLoop = true
		BreakTimer = true; 
		UI:TweenSize(UDim2.fromScale(1,1), "Out", "Elastic" , .8)
		UI["Red Left"]:TweenPosition(UDim2.fromScale(-.184, .292), "Out", "Elastic", 1.3);
		UI["Blue Left"]:TweenPosition(UDim2.fromScale(-.163, .342), "Out", "Elastic", 1.3);
		UI["Red Right"]:TweenPosition(UDim2.fromScale(.881, .284), "Out", "Elastic", 1.3);
        UI["Blue Right"]:TweenPosition(UDim2.fromScale(.937, .33), "Out", "Elastic", 1.3);
        UI["Round"]:TweenSize(UDim2.fromScale(.514,.56), "Out", "Elastic", 1.3);
        UI["Over"]:TweenSize(UDim2.fromScale(.49,.545), "Out", "Elastic", 1.3);
		wait(4);
		UI:TweenSize(UDim2.fromScale(0,0), "Out", "Quad",.3);
		UI["Red Left"]:TweenPosition(UDim2.fromScale(-.4, .292), "Out", "Quad", .3);
		UI["Blue Left"]:TweenPosition(UDim2.fromScale(-.4, .342), "Out", "Quad", .3);
		UI["Red Right"]:TweenPosition(UDim2.fromScale(1.2, .284), "Out", "Quad", .3);
        UI["Blue Right"]:TweenPosition(UDim2.fromScale(1.2, .33), "Out", "Quad", .3);
        UI["Round"]:TweenSize(UDim2.fromScale(0,0), "Out", "Elastic", 1.3);
        UI["Over"]:TweenSize(UDim2.fromScale(0,0), "Out", "Elastic", 1.3);
        ActionUI.Visible = false
        ActionUI.Explode.Visible = false
        ActionUI.Shoot.Visible = false
        ActionUI.Taunt.Visible = false
		BreakTimer = false;


	end;
end

GameUIFunc.GameObjective = function(MatchType,PlayerType) --Changes per Type of Match
	local Rules = {
		Classic = {
			Human = "Classic Mode: You are Team Human! Your goal is to Stay alive till the round is over. Click to Shoot with your gun! "; 
			Barrel = "Classic Mode: You are Team Barrel! Your goal is to blow up the Humans by pressing 'E'. Good Luck!";
		};
        ["Falling Barrels"] = {
            Human = "Falling Barrels: You are a human! Your goal is to stay alive until the time runs out. Good Luck!"
        };
        ["Fake Barrels"] = {
            Human = "Fake Barrels: The goal of this game is to get to try to get to the other side! Remember the barrel paths!"
        }
   };  
   GameMode = MatchType;
   local GrayShade = GameUI.GrayShade:Clone();
   GrayShade.Parent = Cam;
   Status:TweenPosition(UDim2.fromScale(.41,.041), "Out", "Quad", .5)
   GameUIFunc.UpdateStatus(MatchType);
	GameObjective.Visible = true;
	spawn(function()
		GameObjective.Holder.TextLabel.Text = Rules[MatchType][PlayerType];
		GameObjective:TweenSize(UDim2.fromScale(.067,.038), "Out", "Elastic", .7);
		wait(GameUIFunc.GameCountDown);
		GameObjective:TweenSize(UDim2.fromScale(.0,.0), "Out", "Quad", .2);
		wait(.3)
        GameObjective.Visible = false;

   end)
   local didGrayTransition = false
	for i = GameUIFunc.GameCountDown+1,1,-.1 do
	  wait(.09)
	  GameObjective.Holder.TimerHolder.TextLabel.Text = "GAME STARTS IN:  "..i;
	  if i<3 then
		 didGrayTransition = true;
		 local TweenService = game:GetService("TweenService");
		 local transitionInfo = TweenInfo.new(3, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		 local tween = TweenService:Create(GrayShade, transitionInfo, {TintColor = Color3.fromRGB(255, 255, 255)})
		 tween:Play()
	  end;
   end
   didGrayTransition = false;
   GrayShade:Destroy();
end

GameUIFunc.CutSceneUI   = function(MapName,Creator,Mode)--Customize the CustScene UI init cutscene
    if Creator ==nil then
		CutSceneUI.Title:TweenPosition(UDim2.fromScale(-.15,.785), "Out", "Elastic", .2);
		CutSceneUI.Title.Frame:TweenPosition(UDim2.fromScale(-.7,.0), "Out", "Elastic", .2);
        CutSceneUI.Title.Desc:TweenPosition(UDim2.fromScale(-1.4,.0), "Out", "Elastic", .2);
		return;
	end
	local Round = {
		Colors = {
			["Orange Justice"] = Color3.fromRGB(255, 121, 11);
            ["OrangeJustice_FB"] = Color3.fromRGB(255, 121, 11);
			Maze =  Color3.fromRGB(255, 56, 76);
            Dunes =  Color3.fromRGB(196, 140, 77);
            Outpost = Color3.fromRGB(226, 164, 94);
            City = Color3.fromRGB(35, 219, 81);
            City_FB = Color3.fromRGB(35, 219, 81);
            Gears =  Color3.fromRGB(38, 39, 50)
		};
		Classic = {
			Desc = "Barrels vs Humans! You'll either be trying to survive or blow others up to bits!";
			Icon = "rbxassetid://5525771438";
		};
        ["Fake Barrels"] = {
			Desc = "Avoid the fake barrels and find the hidden path to reach the finish line!";
			Icon = "rbxassetid://5525771438";
		};
        ["Falling Barrels"] = {
            Desc = "Raining Barrels! Survive the Waves until the time runs out!";
            Icon = "http://www.roblox.com/asset/?id=6414883692";
        }

    }
	CutSceneUI.Title.Creator.Text = Creator;
	CutSceneUI.Title.MapName.Text = MapName;
	CutSceneUI.Title.Desc.GameDesc.Text = Round[Mode].Desc;
    CutSceneUI.Title.Desc.ICON.Image = Round[Mode].Icon
    CutSceneUI.Title.ImageColor3 = Round.Colors[MapName];
	CutSceneUI.Title:TweenPosition(UDim2.fromScale(0,.785), "Out", "Elastic" , .8)
	CutSceneUI.Title.Frame:TweenPosition(UDim2.fromScale(.79,0), "Out", "Elastic" , .8)
	CutSceneUI.Title.Desc:TweenPosition(UDim2.fromScale(.911,0), "Out", "Elastic" , .8)
	GameUIFunc.UpdateStatus("");
	Status:TweenPosition(UDim2.fromScale(.41,-.1), "Out", "Quad", .5)
end

GameUIFunc.RespawnUI    = function()--Customize the CustScene UI
	RespawnUI.Visible   = true
	RespawnUI:TweenSize(UDim2.fromScale(.183,.055), "Out", "Quad", .5); --{0.183, 0},{0.055, 0}
	for i = GameUIFunc.RespawnTime,0 , -.1 do
		RespawnUI.Button.TextLabel.Text = i.." secs"
	end
	RespawnUI:TweenSize(UDim2.fromScale(0,0), "Out", "Quad", .5);
	wait(.5)
	RespawnUI.Visible   = false
 
end;

GameUIFunc.Intermission = function(Timer)
	GameUIFunc.UpdateStatus("Intermission")
	GameUIFunc.ShowTimer();
	GameUIFunc.StartTimer(Timer);

end

GameUIFunc.NicePhrase   = function(Points)
    if Points == nil then return end;
	local KillPhrases = {"Awesome!";"Sweet Play!";"Cool!";"Keep it Up!";"Nice Work!";"Good Job!";"Sweet Skill!";}
	local UI = InGamePoints.PointUI:Clone();
    InGamePoints.Visible = true
    InGamePoints.Frame.Visible = true
	UI.Parent = InGamePoints.Frame;
	UI.Visible = true;
	UI.TextLabel.Text = KillPhrases[math.random(1,#KillPhrases)] .." +".. Points;
	UI:TweenSizeAndPosition(UDim2.fromScale(.066,.033),UDim2.fromScale(.455,.73), "Out", "Elastic", 2);
	spawn(function()
		wait(2)
		repeat wait() 
			UI.ImageTransparency = UI.ImageTransparency +.1;
			UI.TextLabel.TextTransparency = UI.TextLabel.TextTransparency +.1;
		until UI.TextLabel.TextTransparency>=1;
		UI:Destroy();
		UI = nil;
	end)
end;


GameUIFunc.ShowScore    = function()
	Status.Team1:TweenPosition(UDim2.fromScale(-.305,.183), "Out", "Quad", .5);
	Status.Team2:TweenPosition(UDim2.fromScale(1.036,.183), "Out", "Quad", .5);
end

GameUIFunc.ShowTimer    = function(Timer)
	--GameUIFunc.ShowScore();
	TimerUI:TweenPosition(UDim2.fromScale(.28,1), "Out", "Quad", .5);
end;

GameUIFunc.StartTimer   = function(Timer)
   GameTimer = Timer;
   local tempTimer = GameTimer
   spawn(function()
	 for i = GameTimer , 0,-1 do
		if BreakTimer then break end;
		   if tempTimer ~= GameTimer then break end;
		 TimerUI.img.Time.Text ="".. i;
		 wait(1)
	  end;
	  TimerUI:TweenPosition(UDim2.fromScale(.28,0), "Out", "Quad", .6);
	end)
end

GameUIFunc.MapPan = function(map)
   game:GetService("StarterGui"):SetCore("TopbarEnabled", false);
   local Cam = workspace.CurrentCamera;
   local data = game:GetService('HttpService'):JSONDecode(workspace.Holder[map].CutsceneData.Value);
   local rs = game:GetService("RunService").RenderStepped;
   local function tweenCam(c1,f1,time,fov,roll,num)
	  local c0,f0,fv0,r0,frames = CFrame.new(unpack(data[num-1].c1)),CFrame.new(unpack(data[num-1].f1)),data[num-1].FOV,data[num-1].Roll,time/0.008;
	  for i = 1,frames do
		 Cam.CameraType = "Scriptable";
		 Cam.CFrame = CFrame.new(c0.p:lerp(c1.p,i/frames),f0.p:lerp(f1.p,i/frames));
		 Cam.FieldOfView = (fv0+(fov-fv0)*(i*(1/frames)));
		 Cam:SetRoll(r0+(roll-r0)*(i*(1/frames)));
		 rs:Wait();
	  end;
   end;
   Cam.CameraSubject = nil;
   Cam.CameraType = "Scriptable";
   Cam.CFrame = CFrame.new(unpack(data[1].c1));
   Cam.Focus = CFrame.new(unpack(data[1].f1));
   Cam.FieldOfView = data[1].FOV;
   Cam:SetRoll(data[1].Roll);
   for i = 2,#data,2 do
	  tweenCam(CFrame.new(unpack(data[i].c1)),CFrame.new(unpack(data[i].f1)),data[i].step+0.1,data[i].FOV,data[i].Roll,i);
   end;
   Cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid;
   Cam.CameraType = "Custom";
   Cam.FieldOfView = 70;
   game:GetService("StarterGui"):SetCore("TopbarEnabled", true);
end

GameUIFunc.HealthBar = function(PlayerType)
    if PlayerType ~= "Human" then return end;
    spawn(function()
        HealthBarLoop = false
        local healthbar = GameUI.healthbar;
        local redbar = healthbar.bar.redbar
        local totalbarX,totalbarY = redbar.Size.X.Scale, redbar.Size.Y.Scale
        local smallheart = healthbar.bar.heartoutline
        
        local Blur = healthbar.Blur
        local CC = healthbar.ColorCorrection
        local heartbeat = healthbar.heartbeat

        
        local change_health = false
        local can_effect = true

        local create_effect = function(health)
            spawn(function()
                local newBlur, newCC
                if  can_effect and health<=50 then
                    can_effect = false
                    if Cam:FindFirstChild("Blur") == nil then
                        newBlur, newCC = Blur:Clone(), CC:Clone()
                        newBlur.Parent = Cam
                        newCC.Parent = Cam
                    else
                        newBlur = Cam:FindFirstChild("Blur") 
                        newCC = Cam:FindFirstChild("ColorCorrection")
                    end
                    if health<=50 then
                        tweenService:Create(newBlur, TweenInfo.new(1), {Size = 11}):Play()
                        tweenService:Create(newCC, TweenInfo.new(1), {TintColor = Color3.fromRGB(255, 74, 77)}):Play()
                        heartbeat:Play()
                        wait(6)
                        tweenService:Create(newBlur, TweenInfo.new(1), {Size = 3}):Play()
                        tweenService:Create(newCC, TweenInfo.new(1), {TintColor = Color3.fromRGB(255, 144, 146)}):Play()
                        wait(5)
                        heartbeat:Stop()
                        tweenService:Create(newBlur, TweenInfo.new(1), {Size = 0}):Play()
                        tweenService:Create(newCC, TweenInfo.new(1), {TintColor = Color3.fromRGB(255, 255, 255)}):Play()
                        can_effect = true
                    end
                    
                end
            end)
        end
        
        
        local color_health = function(health)
            if health <=50 and not change_health then
                change_health = true
                create_effect(health)
                tweenService:Create(redbar, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(105, 16, 16)}):Play()
                tweenService:Create(smallheart, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(105, 16, 16)}):Play()
            elseif health>50 and change_health then
                change_health = false
                tweenService:Create(redbar, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(255, 53, 53)}):Play()
                tweenService:Create(smallheart, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(255, 53, 53)}):Play()
            end
        end
        
        
        local update_health = function(health)
            redbar.Size = UDim2.fromScale((health/100)*totalbarX,totalbarY)
        end
        
        healthbar.Visible = true
        while wait(.1) do

            local char = player.Character

            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <1 then
                HealthBarLoop = true
            end
            update_health(char.Humanoid.Health)
            color_health(char.Humanoid.Health)
            if HealthBarLoop then
                wait(1)
                redbar.Size = UDim2.fromScale(.977,.79)
                healthbar.Visible = false
                tweenService:Create(redbar, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(255, 53, 53)}):Play()
                tweenService:Create(smallheart, TweenInfo.new(1), {ImageColor3 = Color3.fromRGB(255, 53, 53)}):Play()
                break
            end
        end
    end)
end




return GameUIFunc;