-- Leader Board Service
-- TrollD3
-- October 19, 2021



local LeaderBoardService = {
    Client = {};
    Template = { --template 
        --Save everything in here
        HighestLevels = {};
        MostWins = {};
        MostTimePlayed = {};
    }
}

local PlayerDataService, ServerProfile,ProfileService,LeaderBoardData = nil, nil,require(script.Parent.Parent.Modules.ProfileService), nil

--stat = player's value to compare, topStats = leaderboard array
local function addPlayer(player,stat,topStats,statName) -- returns new list
    if not player or not stat or not topStats or not statName then return end
    local newTop = {}
    local inTop = false
    local i = 1
    while i < 10 and #newTop < 10 do
        if i > #topStats then 
            if not inTop then
                local t = {player = player}
                t[statName] = stat
                table.insert(newTop,t)
            end
            break
        end
        local v = topStats[i]
        if v.player and v[statName] and v.player ~= player then
            if inTop then -- if plr has been inserted, will NOT be the plr
                table.insert(newTop,v)
                i+=1
            else
                if stat > v[statName] then 

                    inTop = true
                    local t = {player = player}
                    t[statName] = stat
                    table.insert(newTop,t)
                else
                    table.insert(newTop,v)
                    i += 1
                end
            end
        else
            i +=1
        end
    end
    return newTop
end

function LeaderBoardService:Update(player,data)
    if data ==nil then return end
    local newLevels = addPlayer(player.UserId,data.LEVEL,ServerProfile.Data.HighestLevels,"level")
    local newWins = addPlayer(player.UserId,data.WINS,ServerProfile.Data.MostWins,"wins")
    local newTime = addPlayer(player.UserId,data.TIMEPLAYED,ServerProfile.Data.MostTimePlayed,"time")
    
    ServerProfile.Data.HighestLevels = newLevels
    ServerProfile.Data.MostWins = newWins
    ServerProfile.Data.MostTimePlayed = newTime
    print(ServerProfile.Data)
end

function LeaderBoardService:GetData()
    if not ServerProfile then return false end
    return ServerProfile.Data
end

function LeaderBoardService:Start()
	print("LeaderBoard Service enabled!")
    PlayerDataService = self.Services.PlayerDataService
    local LeaderBoardData = ProfileService.GetProfileStore("LeaderBoard",LeaderBoardService.Template ) --{plrid = {STATS}}

    ServerProfile = LeaderBoardData:LoadProfileAsync(string.format(4053),"ForceLoad")--.Mock for testing
    ServerProfile:Reconcile()

end


function LeaderBoardService:Init()
	
end


return LeaderBoardService