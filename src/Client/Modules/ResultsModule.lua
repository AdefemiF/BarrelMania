-- Results Module
-- TrollD3
-- November 8, 2020



local ResultsModule   = {}

---//Services
local TweenService    = game:GetService("TweenService");
local ShopClerk     = require(script.Parent.Parent.Controllers.ShopClerk);


--//PlayerRelated Vars

local plr             = game.Players.LocalPlayer
local PGUI            = plr.PlayerGui;
local ResultsUI       = PGUI.GameUI.Results;


--CurrentCamera
local cam             = workspace.CurrentCamera;

--//LeaderBoard Objects
local ClonesModels
local Leaderboard     = game.ReplicatedStorage.Results.Leaderboard;
local CamPositions    = nil;
local RankGui         = nil;
local Stage           = nil;

--//ResultsUI



--//CameraSpeed
local num             = 1;

--//Animations
local VictoryAnim     = {"http://www.roblox.com/asset/?id=507777623"; "http://www.roblox.com/asset/?id=507770239" ;"http://www.roblox.com/asset/?id=507770818" }



local Setup = function(LB,Data)
    Stage = LB.Stage;
    RankGui = LB.Rank;
    ClonesModels = Instance.new("Model")
    ClonesModels.Name = "Clones"
    ClonesModels.Parent = cam;
    table.sort(Data,function(a,b) return a.POINTS > b.POINTS end)
    for i,_ in pairs (Stage:GetChildren()) do
        if i>3 then break end;
        if  i<=#Data and Data[i].Name ~= nil then
            local plrs = workspace.Holder.PlayerClones[Data[i].Name]:Clone();
            plrs.Archivable = true;
            local humanoid = plrs.Humanoid;
            RankGui[""..i].Names.Button.TextLabel.Text = Data[i].Name;
            plrs.PrimaryPart.CFrame = Stage[""..i].Platform.CFrame * CFrame.new(0,3,0);
            plrs.Parent = ClonesModels;
            local animation = Instance.new("Animation");
            animation.AnimationId = VictoryAnim[i]
            local animationTrack = humanoid:LoadAnimation(animation);
            animationTrack.Looped = true;
            animationTrack:Play()
        end;
    end
    local UIListLayout = ResultsUI.BarrelGraphic.Folder.UIListLayout:Clone();
    UIListLayout.Parent = ResultsUI.BarrelGraphic.LeaderBoard
    for i = 1,#Data,1 do
        local Card = ResultsUI.BarrelGraphic.Folder.UIListLayout.Button:Clone()
        if Data[i].Name then
            Card.plrname.Text = Data[i].Name
            Card.placenum.Text = "#"..i
            Card.points.Text = Data[i].POINTS;
            Card.Parent = ResultsUI.BarrelGraphic.LeaderBoard;
            if Data[i].Team =="Barrels" then
                Card.ImageColor3 = Color3.fromRGB(255,73,76);
            else
                Card.ImageColor3 = Color3.fromRGB(72, 146, 220);
            end
        end;
        if Data[i].Name==plr.Name then
            Card.ImageColor3 = Color3.fromRGB(250, 214, 10);
            local labeling = {"st", "nd", "rd", "th","th","th","th","th","th","th","th","th","th","th","th","th"}
            local PersonalData = Data[i].PersonalData;
            local PlacingText = ResultsUI.BarrelGraphic.Stats.Place.placing --.Text
            local XPText = ResultsUI.BarrelGraphic.Stats.XP.amount --.Text; "+ "
            local CashText = ResultsUI.BarrelGraphic.Stats.Cash.amount --.Text + "$ "
            local LVLUP = ResultsUI.BarrelGraphic.Stats.LVLUP
            PlacingText.Text = i..""..labeling[i];
            XPText.Text = "+"..tostring(PersonalData.XP_GAINED);
            CashText.Text = "+"..tostring(PersonalData.CASH_GAINED);
            ShopClerk:UpdateUserData(PersonalData);


            if PersonalData.didLevelUp  then
                LVLUP.Visible = true;
                spawn(function()
                    wait(12)
                    LVLUP.Sound:Play();
                    for i = 1,100 do 
                        LVLUP.TextColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255));
                        wait(.1)
                    end
                end)
            else
                LVLUP.Visible = false;
            end;
        end;
    end;
end;




ResultsModule.Activate = function(Data)

    local LB = Leaderboard:Clone();
    RankGui = LB.Rank;
    CamPositions = LB.Cams;
    LB.Parent = cam;
    local ColorRank = LB.center.Model.Light
    
    --//Camera Positions for Tween
    local p1              = {CFrame =  CamPositions.p1.CFrame}
    local p2              = {CFrame =  CamPositions.p2.CFrame}
    local p3              = {CFrame =  CamPositions.p3.CFrame}
    local p4              = {CFrame =  CamPositions.p4.CFrame}
    local p5              = {CFrame =  CamPositions.p5.CFrame}

    Setup(LB,Data)
    cam.CameraSubject = plr.Character.Humanoid
    cam.CFrame = p1.CFrame * CFrame.new(0,0,-14)
    cam.CameraType = Enum.CameraType.Scriptable;
    RankGui["3"].Place.ExtentsOffset = Vector3.new(0,-7,0);
    TweenService:Create(cam, TweenInfo.new(num), p1):Play();
    TweenService:Create(ColorRank,TweenInfo.new(num),{Color  = Color3.fromRGB(173, 102, 74)}):Play() --Create Color Tween
    wait(4)
    TweenService:Create(cam, TweenInfo.new(num), p2):Play();
    TweenService:Create(ColorRank,TweenInfo.new(num),{Color  = Color3.fromRGB(194, 194, 194)}):Play() --Create Color Tween

    wait(4)
    RankGui["3"].Place.ExtentsOffset = Vector3.new(0,-10,0);
    RankGui["2"].Place.ExtentsOffset = Vector3.new(0,-7,0);
    TweenService:Create(cam, TweenInfo.new(num), p3):Play();
    TweenService:Create(ColorRank,TweenInfo.new(num),{Color  = Color3.fromRGB(194, 159, 33)}):Play() --Create Color Tween


    wait(4)
    RankGui["1"].Place.ExtentsOffset = Vector3.new(-1,-7,0);
    RankGui["1"].Names.ExtentsOffset = Vector3.new(-1,0,0);
    RankGui["2"].Place.ExtentsOffset = Vector3.new(-2,-12,0);
    RankGui["2"].Names.ExtentsOffset = Vector3.new(-2,0,0);
    RankGui["3"].Place.ExtentsOffset = Vector3.new(0,0,0);
    RankGui["3"].Names.ExtentsOffset = Vector3.new(0,15,0);
    TweenService:Create(cam, TweenInfo.new(num), p4):Play();

    ResultsUI.Visible = true
    ResultsUI:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad",.5);
    wait(4)
    TweenService:Create(cam, TweenInfo.new(num*3), p5):Play();    
    spawn(function()
        wait(4)
        cam.CameraType = Enum.CameraType.Custom;
        cam.CameraSubject = plr.Character.Humanoid

        ResultsUI:TweenPosition(UDim2.fromScale(.9,.5), "Out", "Quad",.5);
        LB:Destroy();
        ClonesModels:Destroy()
        ResultsUI.BarrelGraphic.LeaderBoard:ClearAllChildren()
        ResultsUI.Visible = false

    end)
    


end;







return ResultsModule