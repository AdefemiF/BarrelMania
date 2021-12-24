--Client

-- Map Voting
-- TrollD3
-- October 29, 2021


--just gonna make a single function that pushes to the server everytime they push a button, maybe we should add a debounce tho so no spam?
--collect images of all the maps? Or just have it be text based for now?

local plr = game.Players.LocalPlayer.Character
local plrID = game.Players.LocalPlayer.UserId
local l = workspace:FindFirstChild("lobby building",true).L
local r = workspace:FindFirstChild("lobby building",true).R
local upY = l.buttons.b.press.CFrame.Y
local MapDecals = game.ReplicatedStorage.MapVotingIds

local tweenserv = game:GetService("TweenService")
local tweengoal = function(...)
	local goal = {}
	for _,v in pairs ({...}) do
		goal[v[1]]=v[2]
	end
	return goal
end
local tween = function(instances,info,goal)
	local tweens = {}
	if type(instances) ~= "table" then instances = {instances} end
	for _,v in pairs (instances) do
		local actual = tweenserv:Create(v,info,goal)
		table.insert(tweens,actual)
		actual:Play()
	end
	return tweens
end

local buttons = {}
local DecalDisplay = {b = {}, g = {}, o = {}}
local current = "none"
local debounce = false

for i = 1,3 do
	
	local Rv = r.maps:GetChildren()[i]
	local Lv = l.maps:GetChildren()[i]
	
	table.insert(buttons,r.buttons:GetChildren()[i].press)
	table.insert(buttons,l.buttons:GetChildren()[i].press)
	
	table.insert(DecalDisplay[Rv.Name],Rv.Model.Display)
	table.insert(DecalDisplay[Lv.Name],Lv.Model.Display)

end


local MapVoting = {}


local colorToNum = {b = 1, g = 2, o = 3} -- turns the button names into numbers (left to right)
local numToColor = {"b", "g", "o"}
local maps = {}

local Disabled = true -- true by default, server will make it false

local client_master = require(script.Parent.Parent.Controllers.CLIENT_MASTER)


function MapVoting:DisplayChoices(Choices) -- * names, ids will be client side
	maps = Choices
	Display(Choices)
end

function MapVoting:DisableVoting(b) -- * after round begins / afk / voting time
	
	Disabled = b
	if b then Reset() end
	
	MapVoting:SendChoice(false) -- resets player's vote (if there is any)
end


function MapVoting:SendChoice(Choice)

	client_master:SendMapVote(Choice)

end;






-- signal to server sent here (reduces redundancy)

local down = function(name)

	if Disabled then current = "none" return end
	debounce = true

	MapVoting:SendChoice(maps[colorToNum[name]])

	local color = Color3.fromHSV(Color3.toHSV(l.maps[name].neon.Color),1,1)
	tween(r.buttons[name].press,TweenInfo.new(.2),tweengoal({"CFrame",r.buttons[name].press.CFrame+Vector3.new(0,upY - 1 - l.buttons[name].press.CFrame.Y,0)}))
	tween(l.buttons[name].press,TweenInfo.new(.2),tweengoal({"CFrame",l.buttons[name].press.CFrame+Vector3.new(0,upY - 1 - l.buttons[name].press.CFrame.Y,0)}))
	tween({r.maps[name].neon,r.maps[name].neon2},TweenInfo.new(.2),tweengoal({"Color",color}))
	tween({l.maps[name].neon,l.maps[name].neon2},TweenInfo.new(.2),tweengoal({"Color",color}))
	current = name
	spawn(function() wait(.2) debounce = false end)
end

local up = function(name)
	if name == "none" then return end
	local color = Color3.fromHSV(Color3.toHSV(l.maps[name].neon.Color),.4,.3)
	tween(r.buttons[name].press,TweenInfo.new(.2),tweengoal({"CFrame",r.buttons[name].press.CFrame+Vector3.new(0,upY - l.buttons[name].press.CFrame.Y,0)}))
	tween(l.buttons[name].press,TweenInfo.new(.2),tweengoal({"CFrame",l.buttons[name].press.CFrame+Vector3.new(0,upY - l.buttons[name].press.CFrame.Y,0)}))
	tween({r.maps[name].neon,r.maps[name].neon2},TweenInfo.new(.2),tweengoal({"Color",color}))
	tween({l.maps[name].neon,l.maps[name].neon2},TweenInfo.new(.2),tweengoal({"Color",color}))
end

for _,v in pairs(buttons) do
	v.Touched:connect(function(part)
		if part:IsDescendantOf(plr) and not debounce and v.Parent.Name ~= current then
			up(current)
			down(v.Parent.Name)
		end
	end)
	v.click.MouseClick:connect(function()
		if not debounce and v.Parent.Name ~= current then
			up(current)
			down(v.Parent.Name)
		end
	end)
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(plr)

	for _,v in pairs(buttons) do
		v.Touched:connect(function(part)
			if part:IsDescendantOf(plr) and not debounce and v.Parent.Name ~= current then
				up(current)
				down(v.Parent.Name)
			end
		end)
	end

end)

function Reset()
	up(current)
	
	for _,q in pairs(DecalDisplay) do
		
		for _,v in pairs(q) do
			v:ClearAllChildren()
		end

	end
	
	current = "none"
end

function Display(names)
	
	for i,n in pairs(names) do
		
		if not MapDecals[n] then continue end
		
		for _,d in pairs(DecalDisplay[numToColor[i]]) do
			local c = MapDecals[n]:Clone()
			d:ClearAllChildren()
			c.Parent = d
		end
		
	end
		
end


return MapVoting