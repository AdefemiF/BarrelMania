-- Shop Master
-- TrollD3
-- March 17, 2021



local ShopClerk = {} ---handles all purchases made within the shop and equippment

--Modules/Services Uses
local PlayerMenuUI, StoreService, Framework,ShopMaster

---//UI Used
local UI              = game.Players.LocalPlayer.PlayerGui



--local plr
local plr = game.Players.LocalPlayer;

local PlayerInventory = {
	CASH = 0;
	XP = 0;
    XP_NEEDED_LVL_UP = 0;
	LEVEL = 1;
    RecentPurchaseHistory = {
        Name = "";
        didSucceed = nil;
    };
    EquippedItems = {
		Color = {"DEFAULT"};
		Skin = {};
		Accessories = {"DEFAULT"};
		Taunts_Anims = {"DEFAULT"},
		Taunts_Sound = {"DEFAULT"};
	},
	OwnedItems = {
		Color = {"DEFAULT"};
		Skin = {};
		Accessories = {"DEFAULT"};
		Taunts_Anims = {"DEFAULT"},
		Taunts_Sound = {"DEFAULT"};
	},
    Boosts = {
        isVIP = false,
        is2XP = false,
        isPremium = false;
    };
}

local DevProductIDs = {
    VIP = 16603588;
    ["2XP"] = 16603582;
    Donation = 937240666;
    ["Pocket Change"] = 937240744;
    ["Money Stacks"] = 937240808;
    ["We Ballin"] = 1163737169;
    Flexecution = 937240864;
}


function ShopClerk:CanPurchaseItem(Item, PurchaseType, Price) 
	--checks sever if they can buy and returns confirmation
	--check if they already own this
    for i,_ in pairs (PlayerInventory.OwnedItems[PurchaseType]) do
        if i==Item then return false, "Already Owned!" end;
    end
    if PlayerInventory.CASH>=Price then
        local success,msg,data = StoreService:CanPurchaseItem(Item, PurchaseType);
		if success then
			PlayerInventory.OwnedItems[PurchaseType][Item] = data;
			PlayerInventory.CASH -= Price;
		end;
        ShopClerk:UpdateCashText()
        return success , msg;
    end;
    return false, "Lacking Funds!"
end;
function ShopClerk:AddCurrency(purchasedproduct)
    if purchasedproduct== "Pocket Change" then
        PlayerInventory.CASH += 250
    elseif purchasedproduct == "Money Stacks" then
        PlayerInventory.CASH += 650
    elseif purchasedproduct == "We Ballin" then
        PlayerInventory.CASH += 1000
    elseif purchasedproduct == "Flexecution" then
        PlayerInventory.CASH += 4000
    end
    ShopClerk:UpdateCashText()
end

function ShopClerk:UpdateCashText()
    local ShopUi = UI.ShopUI
	local Market = ShopUi.MARKET
    Market.Info.Cash.TextLabel.Text = "$"..tostring(PlayerInventory.CASH);
end;

function ShopClerk:GetShopInfo()
    return StoreService:GetUpdatedShop();
end;

function ShopClerk:UpdateInventory(Item,Data)
    PlayerInventory.OwnedItems[Data.Type][Item] = Data
end;

function ShopClerk:isTwitterCodeValid(code)
    ShopClerk:AddCustomSkins(code)
    return StoreService:CheckTwitterCode(code);
end

function ShopClerk:GetInventory(Type)
    if Type == "Skins" then
        for i,v in pairs (PlayerInventory.OwnedItems[Type]) do
            if v == "LGBT" then
                table.remove(PlayerInventory.OwnedItems[Type], i)
            end
        end
    end
    return PlayerInventory.OwnedItems[Type]    
end
function ShopClerk:GetRecentTransaction()
    return PlayerInventory.RecentPurchaseHistory
end;
function ShopClerk:UpdateUserData(PersonalData, Load)
	if Load then
		PlayerInventory.CASH = PersonalData.CASH;
	else
		PlayerInventory.CASH += PersonalData.CASH_GAINED;	
	end
	local ShopUi = UI.ShopUI
	local Market = ShopUi.MARKET
    PlayerInventory.LEVEL = PersonalData.LEVEL
    PlayerInventory.XP_NEEDED_LVL_UP = PersonalData.XP_NEEDED_LVL_UP 
    PlayerInventory.XP = PersonalData.XP;
    Market.Info.Cash.TextLabel.Text = "$"..tostring(PlayerInventory.CASH);
    PlayerMenuUI.IncreasePlayerXP(PersonalData);

end;

function ShopClerk:AddCustomSkins(Type)
    local CustomSkins = {
        KNICKS = {Type = "Skin"; Price = 500; Desc = " Pretty disappointed with their season but hey the colors look cool!"; };
        NOOB = {Type = "Skin"; Price = 500; Desc = "Now you can really show your friends how much of a noob you are! :D"; };
        PEPSI = {Type = "Skin"; Price = 500; Desc = "Are you really gonna choose this over a Sprite/Coke?"; };
        REDANDBLUE = {Type = "Skin"; Price = 500; Desc = " Red Variant #1"; };
        BELLA = {Type = "Skin"; Price = 10000; Desc = "The pet of Not_Liink, our favorite youtuber!"; };
        MYSTIC = {Type = "Skin"; Price = 99999; Desc = "Thank you all for playing this game! Stay tuned for more!"; };

    }
    if Type =="VIP" then
        PlayerInventory.OwnedItems["Skin"]["NOOB"] = CustomSkins.NOOB;
    elseif Type == "2XP" then
        PlayerInventory.OwnedItems["Skin"]["PEPSI"] = CustomSkins.PEPSI;
        PlayerInventory.OwnedItems["Skin"]["REDANDBLUE"] = CustomSkins.REDANDBLUE;
        PlayerInventory.OwnedItems["Skin"]["KNICKS"] = CustomSkins.KNICKS;
    elseif Type == "WINTER_LIINK" then
        PlayerInventory.OwnedItems["Skin"]["BELLA"] = CustomSkins.BELLA;
    elseif Type == "THANKYOU" then
        PlayerInventory.OwnedItems["Skin"]["MYSTIC"] = CustomSkins.MYSTIC;
    end
end

function ShopClerk:Equip(Item, ItemType)
    local found = false;
    if Item ~= "1" then
        for i,v in pairs (PlayerInventory.OwnedItems[ItemType]) do
            if i==Item or v == "DEFAULT" then 
                found = true;
                break;
            end;
        end
    else
        found = true
        Item = "DEFAULT"
        ItemType ="Color"
    end
    if not found then return false, "You Dont Own!" end;

    PlayerInventory.EquippedItems[ItemType] = {Item}
    return StoreService:EquipItem(Item,ItemType)
end;


function ShopClerk:Start()
	StoreService = self.Services.StoreService
	PlayerMenuUI = self.Modules.PlayerMenuUI
	Framework = self.Services.Framework
    ShopMaster = self.Modules.ShopMaster
    local PlayerData = Framework:ViewPlayerData(plr)
    PlayerInventory = PlayerData;
    PlayerInventory.RecentPurchaseHistory = {}
    ShopMaster.UpdateShopItems(StoreService:GetUpdatedShop());

    StoreService["STORE_EVENT"]:Connect(function(PurchaseResult,ID)
        local purchasedproduct;
        for i,v in pairs(DevProductIDs) do
            if v==ID then
                purchasedproduct = i;
                break;
            end;
        end;
        PlayerInventory.RecentPurchaseHistory.Name = purchasedproduct;
        PlayerInventory.RecentPurchaseHistory.didSucceed = PurchaseResult;
        if purchasedproduct ~= "VIP" and purchasedproduct ~="2XP" then
            ShopClerk:AddCurrency(purchasedproduct);
        else
            ShopClerk:AddCustomSkins(purchasedproduct)
        end
        wait(.5);
        PlayerInventory.RecentPurchaseHistory.didSucceed = nil;
    end)
end

function ShopClerk:Init()
	repeat
        wait(1)
    until game.Players.LocalPlayer.PlayerGui
end









return ShopClerk