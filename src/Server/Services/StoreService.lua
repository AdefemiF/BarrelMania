-- Store Service
-- TrollD3
-- March 16, 2021

--// Services used by the StoreService;
local StoreService = {Client = {}}
local PlayerDataService, ProfileService;
local MarketService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

--//Name for RemoteEvent used by the STORE;
local STORE_EVENT = "STORE_EVENT"

--//Storage Locations for Game Objects used by the Game
local serverstore = game.ServerStorage
local repstore = game.ReplicatedStorage

local FeaturedDate, DailyDate;
local ClientShopCopy = nil;

StoreService.StoreTemplate = { 
    FeaturedTimer = 0000;
    DailyTimer = 0000;
    Sale = 1;
    CurrentDaily = {};
    CurrentFeatured = {};
}
local Items = {

    Featured = {        
        GALAXY = {Type = "Skin"; Price = 1900; Desc = "Galaxy Skin! See the cosmos!"; };
        STARS = {Type = "Skin"; Price = 2200; Desc = " 'Shoot for the stars. Aim for the moon.'"; };
        SUPREME = {Type = "Skin"; Price = 9000; Desc = "Money Machine go Brrrrrrrrr"; };
        WSB = {Type = "Skin"; Price = 1700; Desc = "WSB is taking $RBLX and $GME to the Moon! ";};
        GME = {Type = "Skin"; Price = 1700; Desc = "GME TO THE MOON! DIAMOND HANDS ONLY!"; };
        SPIDEY = {Type = "Skin"; Price = 8000; Desc = " 'With Great Power, Comes Great Responsibility' - Uncle Ben"; };
        ["HI-C"] = {Type = "Skin"; Price = 4900; Desc = "The best drink from McDonalds!"; };
        MUSHROOM = {Type = "Skin"; Price = 3900; Desc = "How does their princess keep getting taken?"; };
        SPOOKY = {Type = "Skin"; Price = 1200; Desc = "Happy Halloween!"; };
        SANTA = {Type = "Skin"; Price = 1000; Desc = "We still believe in Santa <3"; };


    };
    Daily = {
        BLUE = {Type = "Color"; Price = 700; Desc = "Color your barrel Blue!"; };
        PURPLE = {Type = "Color"; Price = 700; Desc = "Color your barrel Purple!";};
        ORANGE = {Type = "Color"; Price = 700; Desc = "Color your barrel Orange!";};
        YELLOW = {Type = "Color"; Price = 500; Desc = "Color your barrel Yellow!";};
        GREEN = {Type = "Color"; Price = 700; Desc = "Color your barrel Green!"; };
        PINK = {Type = "Color"; Price = 700; Desc = "Color your barrel Pink!"; };
        COW = {Type = "Skin"; Price = 800; Desc = "MOOO"; };
        APE = {Type = "Skin"; Price = 800; Desc = "Ah. Yes. Monkey. Good Ape."; };
        BARREL = {Type = "Skin"; Price = 800; Desc = "Seriously? Barrel skin on top of a barrel?? Yes we did."; };
        CAMO1 = {Type = "Skin"; Price = 900; Desc = "You can't see me.. right??"; };
        WOOD = {Type = "Skin"; Price = 800; Desc = "Its not made of wood so the WoodReviewer cant hurt us! ;)"; };
        BROWN = {Type = "Color"; Price = 300; Desc = "Color your barrel Brown! (LOL)"; };
        RAINBOW = {Type = "Skin"; Price = 800; Desc = "WE STAN INCLUSIVITY! LOVE YOU ALL!!"; };
        CAKE = {Type = "Skin"; Price = 900; Desc = "Let them eat.."; };
        KITTY = {Type = "Skin"; Price = 900; Desc = "MEOW"; };
        DOMO = {Type = "Skin"; Price = 800; Desc = "Domo-Kun!"; };
        STRAWHAT = {Type = "Skin"; Price = 900; Desc = "Buy this and you'll become the next king of pirates... ;)"; };
        RENGOKU = {Type = "Skin"; Price = 900; Desc = "Flame Breathing.. Esoteric Art! 9th Form... RENGOKUUUU!"; };
        BRICK = {Type = "Skin"; Price = 700; Desc = "Brick by Brick"; };
        CANDYCANE = {Type = "Skin"; Price = 600; Desc = "Our favorite Christmas treat!"; };
        SKULLS2 = {Type = "Skin"; Price = 700; Desc = "Variation of SKULLS"; };
        SKULLS = {Type = "Skin"; Price = 700; Desc = "We forgot to add it during Halloween!"; };
        TREE = {Type = "Skin"; Price = 600; Desc = "Hoping your tree is lit this year!"; };
        REINDEER = {Type = "Skin"; Price = 400; Desc = "Rudolph with your nose so bright..."; };
        PRESENTS = {Type = "Skin"; Price = 800; Desc = "Hoping you've been nice instead of bad this year!"; };
        PUMPKIN = {Type = "Skin"; Price = 300; Desc = "Pumpkin Pie is delicious, go try it!"; };



    };
    GamePasses = {
        VIP = {Type = "GamePass"; Price = 300; 
            Desc = "Access to VIP room! \n Exclusive VIP barrel skin! \n Increase EXP and CASH by 20%!"
        };
        ["2XP"] = {Type = "GamePass"; Price = 400; 
            Desc = [[2XP Permanently! 2x Coins as well! Comes with a Pack of 3 Exclusive Skins!]]
        };

        Donation = {Type = "Donation"; Price =20; 
                Desc = [[Support our team and help us cover our college tuitions! We appreciate every little bit of help! :D (Not a GamePass)]]}

    };
    Refills = {
        ["Pocket Change"] = {Price =50; Desc = "Adds cash by $250";};
        ["Money Stacks"] = {Price = 110;Desc = "Adds cash by $650";};
        ["We Ballin"] = {Price = 250;Desc = "Adds cash by $1000";};
        Flexecution = {Price = 720;Desc = "Adds cash by $4000";};
    }
    -- DEFAULT = {Type = "Color"; Price = 0; Desc = "Default Color!"; };
    -- DEFAULT = {Type = "Skin"; Price = 0; Desc = "Default Skin!"; };
    --[[
    Animations = {
        DEFAULT = {Type = "Animation"; Price = 0; Desc = "Default Animation!"; AnimationID = "ANIMATIONID"};
        SHOOT = {Type = "Animation"; Price = 700; Desc = "Wha.. a FORTNITE ANIMATION?!??!"; AnimationID = "ANIMATIONID"};
        ORANGEJUSTICE = {Type = "Animation"; Price = 750; Desc = "I will set the beat on flow, woah!"; AnimationID = "ANIMATIONID"};
    --]]
};

local DevProductIDs = {
    VIP = 16603588;
    ["2XP"] = 16603582;
    Donation = 937240666;
    ["Pocket Change"] = 937240744;
    ["Money Stacks"] = 937240808;
    ["We Ballin"] = 1163737169;
    Flexecution = 937240864;
}

local CurrentCodes = {"NOT_LIINK", "WINTER_LIINK", "THANKYOU"}
function StoreService:TwitterCode(plr,SentCode)
    
    for i = 1, #CurrentCodes do
        if SentCode== CurrentCodes[i] then
            local localPlayerData = PlayerDataService:GetSaveableData(plr)
            if localPlayerData.ReedemedTwitterCodes ==nil then 
                localPlayerData.ReedemedTwitterCodes = {} 
            else
                for _,v in pairs(localPlayerData.ReedemedTwitterCodes) do
                    if v == SentCode then
                        return false, "Already Redeemed!"
                    end
                end
            end;
            table.insert(localPlayerData.ReedemedTwitterCodes, CurrentCodes[i])
            if  CurrentCodes[i] =="NOT_LIINK" then
                localPlayerData.CASH += 250
                return true, "Awarded $250! Subscribe to Not_Liink on Youtube!",localPlayerData.CASH
            elseif CurrentCodes[i] == "WINTER_LIINK" then
                localPlayerData.CASH += 500
                StoreService:AddCustomSkins(plr, "WINTER_LIINK")
                return true, "Awarded $500 w/ Custom Skin! Go Subscribe to Not_Liink!",localPlayerData.CASH
            elseif CurrentCodes[i] == "THANKYOU" then
                localPlayerData.CASH += 700
                StoreService:AddCustomSkins(plr, "THANKYOU")
                return true, "TYSM for the support! +700 w/ skin!",localPlayerData.CASH
            end
        end
    end
    return false, "Code is invalid/expired!"
end


function StoreService:AddCustomSkins(plr, Type)
    local CustomSkins = {
        KNICKS = {Type = "Skin"; Price = 500; Desc = "Their season was wack, but hey the colors look cool!"; };
        NOOB = {Type = "Skin"; Price = 500; Desc = "Now you can really show your friends how much of a noob you are! :D"; };
        PEPSI = {Type = "Skin"; Price = 500; Desc = "Are you really gonna choose this over a Sprite/Coke?"; };
        REDANDBLUE = {Type = "Skin"; Price = 500; Desc = "Red Variant #1"; };
        BELLA = {Type = "Skin"; Price = 10000; Desc = "The pet of Not_Liink, our favorite youtuber!"; };
        MYSTIC = {Type = "Skin"; Price = 99999; Desc = "Thank you all for playing this game! Stay tuned for more!"; };

    }
    local localPlayerData = PlayerDataService:GetSaveableData(plr)
    if Type =="VIP" then
        localPlayerData.OwnedItems["Skin"]["NOOB"] = CustomSkins.NOOB;
    elseif Type == "2XP" then
        localPlayerData.OwnedItems["Skin"]["PEPSI"] = CustomSkins.PEPSI;
        localPlayerData.OwnedItems["Skin"]["REDANDBLUE"] = CustomSkins.REDANDBLUE;
        localPlayerData.OwnedItems["Skin"]["KNICKS"] = CustomSkins.KNICKS;
    elseif Type == "WINTER_LIINK" then
        localPlayerData.OwnedItems["Skin"]["BELLA"] = CustomSkins.BELLA;
    elseif Type == "THANKYOU" then
        localPlayerData.OwnedItems["Skin"]["MYSTIC"] = CustomSkins.MYSTIC;
    end
end;


function StoreService.Client:CanPurchaseItem(plr,Item,PurchaseType)
    local ItemName = Item;
    local localPlayerData = PlayerDataService:GetSaveableData(plr)

    if localPlayerData.OwnedItems[PurchaseType][ItemName] then --checking if they own
        return false, "Already Owned!!"; 
    end;

    if Items.Featured[Item] then
        Item = Items.Featured[Item]
    elseif Items.Daily[Item] then
        Item = Items.Daily[Item]
    end;
    if localPlayerData.CASH>= Item.Price then
        localPlayerData.CASH -= Item.Price;
        localPlayerData.OwnedItems[PurchaseType][ItemName] = Item;
        return true, "success", Item
    else
        return false, "Not Enough Money!"
    end
end;

function StoreService.Client:GetUpdatedShop()
    return ClientShopCopy;
end;

function StoreService.Client:GetRotationDate()
    return FeaturedDate,DailyDate;
end

function StoreService.Client:CheckTwitterCode(plr,SentCode)
    return StoreService:TwitterCode(plr,SentCode)
end

function StoreService.Client:EquipItem(plr, Item, ItemType)
    local localPlayerData = PlayerDataService:GetSaveableData(plr)
    if localPlayerData.OwnedItems[ItemType][Item] or Item == "DEFAULT" and localPlayerData.OwnedItems[ItemType][1] then --checking if they own
        if ItemType == "Color" and Item == "DEFAULT" then
            localPlayerData.EquippedItems["Skin"] = {"DEFAULT"}
        elseif ItemType=="Color" then
            localPlayerData.EquippedItems["Skin"] = {""}
        elseif ItemType=="Skin" then
            localPlayerData.EquippedItems["Color"] = {""}            
        end;
        localPlayerData.EquippedItems[ItemType] = {Item}
        return true, "success"
    else 
        return false, "You do not own this item!" --consider punishing
    end;
end;

function StoreService:ProcessGamePass(plr, passid, bool)
    if bool == false then return end;
    local localPlayerData = PlayerDataService:GetSaveableData(plr)
    for i,v in pairs(DevProductIDs) do
        if v==passid then
            purchasedproduct = i;
            break;
        end;
    end;
    if purchasedproduct == "VIP" then
        localPlayerData.Boosts.isVIP = true;
        StoreService:AddCustomSkins(plr,"VIP")
    elseif purchasedproduct == "2XP" then
        localPlayerData.Boosts.is2XP = true;
        StoreService:AddCustomSkins(plr,"2XP")
    end;
end

function StoreService:ProcessMarketPurchase(ReceiptInfo)
    local player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)
    if not player then --user left the game
        return Enum.ProductPurchaseDecision.NotProcessedYet;
    else
        local purchasedproduct;
        local localPlayerData = PlayerDataService:GetSaveableData(player)
        for i,v in pairs(DevProductIDs) do
            if v==ReceiptInfo.ProductId then
                purchasedproduct = i;
                break;
            end;
        end;
        if purchasedproduct== "Pocket Change" then
            localPlayerData.CASH += 250
        elseif purchasedproduct == "Money Stacks" then
            localPlayerData.CASH += 650
        elseif purchasedproduct == "We Ballin" then
            localPlayerData.CASH += 1000
        elseif purchasedproduct == "Flexecution" then
            localPlayerData.CASH += 4000
        end
        local Receipt  = {
            Name = purchasedproduct;
            ProductID = ReceiptInfo.ProductId;
            PriceInRobux = ReceiptInfo.CurrencySpent;
            TimeofPurchase = os.time();
        }
        table.insert(localPlayerData.Receipts, Receipt);
        return Enum.ProductPurchaseDecision.PurchaseGranted;
    end;
end;


function StoreService:CheckDailyandFeatured(Data)
    local weekly_unix = 400000/2; --about 4-5 days cut in half
    local daily_unix = 43200; --about 12 hours

    if Data.DailyTimer <= os.time() then --our set period has been reached. reset!
        Data.DailyTimer = os.time() + daily_unix;
        Data.CurrentDaily = StoreService:RotateDaily(Data);
    end;
    if Data.FeaturedTimer  <=os.time() then ----our set period has been reached. reset!
        Data.FeaturedTimer = os.time() + weekly_unix;
        Data.CurrentFeatured = StoreService:RotateFeatured(Data);
    end;

    FeaturedDate = Data.FeaturedTimer
    DailyDate = Data.DailyTimer

    ClientShopCopy = Data;
    ClientShopCopy.Items = Items
end;    

function checkDuplicates(array,value)
    for i,_ in pairs (array) do --checking for no duplicates
        if i==value then
            return true;
        end;
    end
    return false;
end

function StoreService:RotateDaily(Data)
    local Holder = Items.Daily;
    local temp = {};
    local newDaily = {};
    local random = Random.new(Data.DailyTimer);
    local counter = 0;
    for i,_ in pairs (Holder) do
        table.insert(temp, i);
    end;
    repeat 
        local chosen = temp[random:NextInteger(1, #temp)]
        if not checkDuplicates(newDaily, chosen) then
            newDaily[""..chosen] = Holder[chosen];
            counter +=1; 
        end;
        wait()
    until counter>=5 
    return newDaily;
end;

function StoreService:RotateFeatured(Data)
    local Holder = Items.Featured;
    local temp = {};
    local newFeatured = {};
    local random = Random.new(Data.FeaturedTimer);
    local counter = 0;
    for i,_ in pairs (Holder) do
        table.insert(temp, i);
    end;
    repeat 
        local chosen = temp[random:NextInteger(1, #temp)]
        if not checkDuplicates(newFeatured, chosen) then
            newFeatured[""..chosen] = Holder[chosen];
            counter +=1;
        end;
        wait()
    until counter>=3   
    return newFeatured;
end;

function StoreService:ShopUpdate()

    local ShopProfile = ProfileService.GetProfileStore("ShopData", StoreService.StoreTemplate)
    local ShopData = ShopProfile:LoadProfileAsync(string.format(tonumber("4053")),"ForceLoad")
    ShopData:Reconcile(); --Updates with current shop items
    StoreService:CheckDailyandFeatured(ShopData.Data);
    spawn(function()
        while wait(60) do
            StoreService:CheckDailyandFeatured(ShopData.Data);
        end
    end)
end;


function StoreService:Start()
	print("StoreService Loaded!")
    ProfileService = self.Modules.ProfileService;
    PlayerDataService = self.Services.PlayerDataService
    StoreService:ShopUpdate()
    local function processReceipt(RecieptInfo)
        return StoreService:ProcessMarketPurchase(RecieptInfo)
    end;
    local function processgamepass(...)
        local tbl = {...}
        local plr = tbl[1]
        if tbl[3] == true then
            self:FireClientEvent(STORE_EVENT, plr,tbl[3], tbl[2]);
        end
        return StoreService:ProcessGamePass(plr, tbl[2], tbl[3])
    end;
    MarketService.PromptGamePassPurchaseFinished:Connect(processgamepass)
    MarketService.ProcessReceipt = processReceipt
    MarketService.PromptProductPurchaseFinished:Connect(function(...)
        local tuple = {...}
        local plr = Players:GetPlayerByUserId(tuple[1])
        if tuple[3] == true then
            self:FireClientEvent(STORE_EVENT, plr,true, tuple[2]);
        else
            self:FireClientEvent(STORE_EVENT, plr,false, tuple[2]);

        end;
        
    end)
end
  

function StoreService:Init()
    self:RegisterClientEvent(STORE_EVENT)
end


return StoreService