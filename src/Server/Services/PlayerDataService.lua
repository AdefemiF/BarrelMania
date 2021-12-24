-- Player Data Service
-- TrollD3
-- June 25, 2019

local GameSessionService = {Client = {}; 
    Template = { --template 
        --Save everything in here
        LEVEL = 1,
        XP = 0,
        XP_NEEDED_LVL_UP = 100,
        CASH = 100,
        WINS = 0,
        TIMEPLAYED = 0,
        EquippedItems = {
            Color = {"DEFAULT"};
            Skin = {"DEFAULT"};
            Accessories = {"DEFAULT"};
            Animations = {"DEFAULT"},
            Sounds = {"DEFAULT"};
        },
        OwnedItems = {
            Color = {"DEFAULT"};
            Skin = {};
            Accessories = {"DEFAULT"};
            Animations = {"DEFAULT"},
            Sounds = {"DEFAULT"};
        },
        GamePasses = {}, --only one can be bought so just insert the ID
        Receipts = {}; --Productid, PriceinRobux, TimeofPurchase = os.time, 
        ReedemedTwitterCodes = {};
        Boosts = {
            isPremium = false,
            isVIP = false,
            is2XP = false,
        }
    }
}
local SessionData = {} --Holds the data currently in the games
local MarketService = game:GetService("MarketplaceService")
local Framework,StoreService,LeaderBoardService,ProfileService,MapVoting = nil, nil, nil,require(script.Parent.Parent.Modules.ProfileService),nil;
local GameDataStore = ProfileService.GetProfileStore("LivePlayerData",GameSessionService.Template ) --{plrid = {STATS}}
local ADMINS = {"TrollD3", "MeltedPast", "yoshirifter"}

game.Players.PlayerAdded:Connect(
    --use data stores to find if playerprofile exists, and if not then create a new one and then save it
    function(player) --creates data profile for every player that enters the game
        local PlayerProfile = GameDataStore:LoadProfileAsync(string.format(player.UserId),"ForceLoad")--.Mock for testing
        if PlayerProfile then
            PlayerProfile:Reconcile()
            GameSessionService:AddSessionProfile(player,PlayerProfile);
            LeaderBoardService:Update(player, GameSessionService:GetSaveableData(player))

            PlayerProfile:ListenToRelease(function()
                SessionData[player.Name].isAFK = true
                SessionData[player.Name] = nil
                Framework:UpdatePlayerList(player)
                -- The profile could've been loaded on another Roblox server:
                player:Kick()
            end)
        else
            PlayerProfile:Release()
            player:Kick("Data Failure. Kicking to Prevent Overwrite Issues.");
        end;
        --print(player.Name.." PROFILE DATA: ", PlayerProfile.Data)
        Framework:UpdateUIForPlayer(player, "UPDATE"); --GameSessionService:ViewPlayerData(player)

    end
)

game.Players.PlayerRemoving:Connect(
    function(player) 
        GameSessionService:RemoveSessionProfile(player);
    end
)

function GameSessionService:AddSessionProfile(player,Data)
    if SessionData[player.Name]~= nil then return end; --Makes sure of No Duplicates
    SessionData[player.Name] = { --//Create Data Profile
        JoinTime = os.time(),
        isAFK = true,
        CanProcessAction = true, --for any ingame action that may be needed in rounds besides taunt
        PlayerType = nil, --human/barrel
        ActionTimer = 0, --have server timer
        WantsSound = true, --whether or not server sounds will play for this person
        WantsTips = true,
        STATS = Data; --access using STATS = {all my shit}
    }

    if player.MembershipType == Enum.MembershipType.Premium then
        SessionData[player.Name].STATS.Data.Boosts.isPremium = true;
    end
    if MarketService:UserOwnsGamePassAsync(player.UserId,16603582 ) then
        SessionData[player.Name].STATS.Data.Boosts.is2XP = true;
        if SessionData[player.Name].STATS.Data.OwnedItems["Skin"]["PEPSI"]== nil then
            StoreService:AddCustomSkins(player,"2XP")
        end
    end;
    if MarketService:UserOwnsGamePassAsync(player.UserId,16603588 ) then
        SessionData[player.Name].STATS.Data.Boosts.isVIP = true;
        if SessionData[player.Name].STATS.Data.OwnedItems["Skin"]["NOOB"]== nil then
            StoreService:AddCustomSkins(player,"VIP")
        end
    end;

    for _,v in pairs(ADMINS) do
        if player.Name == v then
            SessionData[player.Name].STATS.Data.CASH = 50000
            SessionData[player.Name].STATS.Data.Boosts.isVIP=true
            SessionData[player.Name].STATS.Data.Boosts.is2XP=true
        end;
    end
end;

function GameSessionService:RemoveSessionProfile(player)
    local SaveData = SessionData[player.Name].STATS;
    local PlayedFor = os.time() - SessionData[player.Name].JoinTime;
    SaveData.Data.TIMEPLAYED +=PlayedFor
    --GameDataStore:WipeProfileAsync(string.format(player.UserId))
    LeaderBoardService:Update(player, GameSessionService:GetSaveableData(player))
    SaveData:Release();
    SessionData[player.Name] = nil;
    player:Kick();
end

function GameSessionService:WipePlayerData(player)
    GameDataStore:WipeProfileAsync(string.format(player.UserId))
end;

function GameSessionService:ViewPlayerData(player)
    if type(player)=="string" then
        player = game.Players[player];
    end;
    if SessionData[player.Name] and SessionData[player.Name].STATS ~= nil then
        local UserID = string.format(player.UserId);
        local localdata = SessionData[player.Name].STATS.Data;
        return localdata
    end
end

function GameSessionService:GetSaveableData(player)
    if type(player)=="string" then
        player = game.Players[player];
    end;
    if player and SessionData[player.Name] then
        return SessionData[player.Name].STATS.Data;
    end;
end

function GameSessionService:isAFK(player, bool)
    if not SessionData[player] then return end;
    if bool == nil then
        return SessionData[player].isAFK
    else
        SessionData[player].isAFK = bool
        if bool then
            if game.Players[player] then
                MapVoting:RemoveId(game.Players[player].UserId)
            end
        end
    end
end

function GameSessionService:WantsSound(player, bool)
    if not SessionData[player] then return end;
    if bool == nil then
        return SessionData[player].WantsSound
    else
        SessionData[player].WantsSound = bool
    end
end

function GameSessionService:WantsTips(player, bool)
    if not SessionData[player] then return end;
    if bool == nil then
        return SessionData[player].WantsTips
    else
        SessionData[player].WantsTips = bool
    end
end

function GameSessionService:ProcessAction(player, bool)
    if not player or not SessionData[player] then return end;

    if bool == nil then
        return SessionData[player].CanProcessAction
    else
        SessionData[player].CanProcessAction = bool
    end
end

function GameSessionService:SetPlayerType(player, Type)
    if game.Players[player]  and SessionData[player] then
        SessionData[player].PlayerType = Type
    end;
end

function GameSessionService:GetPlayerType(player)
    if game.Players[player]  and SessionData[player] then
        return SessionData[player].PlayerType
    end
end

function GameSessionService:Start()
    print("PlayerDataService Ready")
    Framework = self.Services.Framework
    StoreService = self.Services.StoreService
    LeaderBoardService = self.Services.LeaderBoardService
    MapVoting = self.Modules.MapVotingServer
end
function GameSessionService:Init()
end
return GameSessionService
