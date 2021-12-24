-- AddToProfile
-- TrollD3
-- March 3, 2021
--This script is the handling system for Leveling up with XP and for handling adding Currency and dev products in game!


local PDS = require(script.Parent.Parent.Services.PlayerDataService);


local Data = {
    CURRENT_RATE = 2; --can make 2x or 3x if I want
    VIP_XP_RATE = 1.2;
    PREMIUM_RATE = 1.10;
    DOUBLE_RATE = 2;
    XPCAP = 150;
    COINCAP = 70;


}


function Data:ReturnNeededXP(LVL)
    return (math.floor(((LVL*(LVL - 1))/15) * 100) + 100);
end;

function Data:Add_XP_CASH(player, points,winner)
    local SaveableData = PDS:GetSaveableData(game.Players[player]);
    if SaveableData == nil then warn("Data Non Existent for "..player) return end;
    if winner then SaveableData.WINS +=1 end; 
    local didLevelUp = false;
    local prevCash = SaveableData.CASH;
    local Return_XP = math.ceil(Data:CalculateXP(math.ceil(points)));
    local Return_Coin = math.ceil(Return_XP*.65)
    if Return_XP<=10 then
        Return_XP = 10;
    elseif Return_XP >=Data.XPCAP then
        Return_XP = Data.XPCAP
    end
    if Return_Coin <=5 then
        Return_Coin = 5;
    elseif Return_Coin >=Data.COINCAP then
        Return_Coin = Data.COINCAP;
    end
    SaveableData.XP_NEEDED_LVL_UP = Data:ReturnNeededXP(SaveableData.LEVEL) -- used to see if level up 
    
    if Data.CURRENT_RATE == 1 then
        if SaveableData.Boosts.is2XP then
            Return_XP *=Data.DOUBLE_RATE;
            Return_Coin *=Data.DOUBLE_RATE;
        elseif SaveableData.Boosts.isVIP then
            Return_XP *=Data.VIP_XP_RATE;
            Return_Coin *=Data.VIP_XP_RATE;
        elseif SaveableData.Boosts.isPremium then
            Return_XP *=Data.PREMIUM_RATE;
            Return_Coin *=Data.PREMIUM_RATE;
        end 
    else
        Return_XP *=Data.CURRENT_RATE;
        Return_Coin *=Data.CURRENT_RATE;
    end
    SaveableData.XP = SaveableData.XP + Return_XP
    SaveableData.CASH = SaveableData.CASH + Return_Coin;
    if SaveableData.XP>= SaveableData.XP_NEEDED_LVL_UP then
        didLevelUp = true;
        SaveableData.LEVEL +=1;
        SaveableData.XP = 0;
        SaveableData.XP_NEEDED_LVL_UP = Data:ReturnNeededXP(SaveableData.LEVEL)
    end;

    local PersonalData = {
        XP = SaveableData.XP;
        XP_GAINED = Return_XP; 
        ["prevCash"] = prevCash;
        CASH_GAINED = Return_Coin; 
        XP_NEEDED_LVL_UP = SaveableData.XP_NEEDED_LVL_UP;
        LEVEL = SaveableData.LEVEL;
        ["didLevelUp"] = didLevelUp;
        
    }
    return PersonalData;
end


function Data:CalculateXP(Points) --give the points won in a match determine SaveableData.XP
    local XP_EARNED = 0;
    XP_EARNED = Points/2;
    return XP_EARNED;
end;















return Data