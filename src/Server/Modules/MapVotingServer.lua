-- server


-- Map Voting Server
-- TrollD3
-- November 3, 2021

local maps = {}

local MapVoting = {}
local MarketPlaceService = game:GetService("MarketplaceService")

local function copyT(t)
	local tab = {}
	
	for _,v in pairs(t) do
		table.insert(tab,v)
	end
	return tab
end


local l = workspace:FindFirstChild("lobby building",true).L
local r = workspace:FindFirstChild("lobby building",true).R
local count = {b = 0, g = 0, o = 0}
local countDisplay = {b = {}, g = {}, o = {}}
for i = 1,3 do

	local Rv = r.maps:GetChildren()[i]
	local Lv = l.maps:GetChildren()[i]

	table.insert(countDisplay[Rv.Name],Rv.Model.Count)
	table.insert(countDisplay[Lv.Name],Lv.Model.Count)

end


local function activateVote(b)

	local t = .8
	if b then t = 0 end

	for _,v in pairs(l.Parent.VOTE:GetChildren()) do
		for _,q in pairs(v:GetChildren()) do
			q.Transparency = t
		end
	end

end


function MapVoting:SetChoices(OGchoices) -- * many choices, spits out 3
	    
    maps = {}
	
	local choices = copyT(OGchoices)
	
    if #choices < 3 then
        
        maps = choices
        for _ = 1,3 - #choices do
            table.insert(maps, choices[math.random(1,#choices)])
        end
        
    else
        for _ = 1,3 do
            table.insert(maps,table.remove(choices,math.random(1,#choices)))
        end
    end
	
	activateVote(true)
	
    return maps
    
end

function MapVoting:GetChoices()
    return maps
end
local tally = {} -- dictionary of dictionaries {id = {map , count = 1 by default}}

local function countTally()
    local i = 0
	for _,v in pairs(tally) do
        if v.count and v.count > 0 then i+= 1 end
    end
    return i
end



local numToColor = {"b","g","o"}

local function displayCount()

	for i = 1,3 do 

		for _,q in pairs(countDisplay[numToColor[i]]) do

			q.SurfaceGui.TextLabel.Text = tostring(count[numToColor[i]])

		end

	end

end

local function updateCount() -- what actually matters (calls displayCount)
	
	local newCount = {b = 0, g = 0, o = 0}
	
	local mapVotes = {} -- actual names of maps
	
	for _,v in pairs(maps) do mapVotes[v] = 0 end
	
	if #maps < 1 then count = newCount displayCount() return end

	for _,v in pairs(tally) do

		if not v.map or not v.count then continue end

		if mapVotes[v.map] then
			mapVotes[v.map] += v.count
		else
			mapVotes[v.map] = v.count
		end

	end
	
	for i = 1,3 do
		local v = maps[i]
		newCount[numToColor[i]] = mapVotes[v]
	end
		
	count = newCount
	displayCount()
end




-- overlapping addId pushes to same location, no need to remove

function MapVoting:AddId(id, mapName) -- *
    
    -- here we can make changes to value (mult votes for admin/vip or smth)
	
	if not mapName then MapVoting:RemoveId(id) return end
	
    local votes = 1 -- 1 by default
    --if ownsgamepass(id, gamepass) then votes = 2 end;
    
	tally[id] = {map = mapName, count = votes}
	
	updateCount()
    
end


function MapVoting:RemoveId(id)
    
	tally[id] = {}
	
	updateCount()
    
end

function MapVoting:ResetVote() -- *
	
	activateVote(false)
	
    tally = {}
	
	updateCount()
	
end

function MapVoting:GetMap() -- *
    
    if countTally() < 1 then return maps[math.random(1,#maps)] end
    
    local totalCount = {}
    
    for _,v in pairs(tally) do
        
        if not v.map or not v.count then continue end
        
        if totalCount[v.map] then
            totalCount[v.map] += v.count
        else
            totalCount[v.map] = v.count
        end
        
    end
    
    
    local popularMap = ""
    local mostCount = 0
    
    for i,v in pairs(totalCount) do
        
        if v >= mostCount then 
            mostCount = v
            popularMap = i
        end
        
    end
		
    return popularMap -- it being "" should be an impossibility
    
end

function ownsgamepass(userid,gamepassid)
    local s,res = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,userid,gamepassid)
    if not s then
        res = false
    end
    return res
end

return MapVoting
