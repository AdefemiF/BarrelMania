-- Indicator Module
-- TrollD3
-- September 29, 2020



--//Local Player
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera

--//Storage for Indicators
local ReplicatedStorage = game.ReplicatedStorage;
local Dot = ReplicatedStorage.Indicators.Dot;
local Skull = ReplicatedStorage.Indicators.Skull

--//Colors Used For Indicators
local Red,Blue = Color3.fromRGB(255, 90, 93), Color3.fromRGB(87, 188, 255);

local IndicatorModule = {}

IndicatorModule.ShowTeamMembers = function(CurrentPlrType,Humans,Barrels)
    spawn(function()
        if CurrentPlrType == "Human" then
            for _,v in pairs (Humans) do
                if v==plr.Name then continue end
                local char = game.Players[v].Character
                if char.LowerTorso:FindFirstChild("Dot") then char.LowerTorso:FindFirstChild("Dot"):Destroy(); end;
                local newdot = Dot:Clone()
                newdot.ImageLabel.ImageColor3 = Blue
                newdot.Parent = char.LowerTorso
            end;
        elseif CurrentPlrType == "Barrel" then
            for _,v in pairs (Humans) do
                local char = game.Players[v].Character
                if char.LowerTorso:FindFirstChild("Dot") then char.LowerTorso:FindFirstChild("Dot"):Destroy(); end;
            end
            for _,v in pairs (Barrels) do
                if v==plr.Name then continue end
                local char = game.Players[v].Character
                if char.LowerTorso:FindFirstChild("Dot") then char.LowerTorso:FindFirstChild("Dot"):Destroy(); end;
                local newdot = Dot:Clone()
                newdot.ImageLabel.ImageColor3 = Red
                newdot.Parent = char.LowerTorso
    
            end;
        end;
    end)
end;


IndicatorModule.SpawnSkull = function(location,Team)
    spawn(function() 
		--local Switch = false;
        local SkullClone = Skull:Clone()
		local BP = Instance.new("BodyPosition")
		BP.Position = location
        BP.Parent = SkullClone
        SkullClone.Position = location
        SkullClone.Parent = cam
        local imglabel = SkullClone.BillboardGui.ImageLabel;
        if Team =="Human" then imglabel.ImageColor3 = Blue
        elseif Team =="Barrel" then imglabel.ImageColor3 =Red;
        end;
        game:GetService("Debris"):AddItem(SkullClone,5)
        for i = 0,48 do
			wait(.1)
			BP.Position = BP.Position + Vector3.new(0,math.sin(i/1.7),0);
--[[
			if i%20==0 and Switch then
				Switch=false;
			elseif i%20==0 and not Switch then
				Switch =true;
			end
			if Switch then
				imglabel.Rotation = imglabel.Rotation -1;
			else
				imglabel.Rotation = imglabel.Rotation +1;
            end
--]]
        end
	end)
end;






return IndicatorModule