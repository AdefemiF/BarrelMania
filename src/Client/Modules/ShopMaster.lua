-- Shop Master
-- TrollD3
-- July 16, 2020


--Arrays
local ShopFunctions   = {CamSpeed = .4}--holds all shop functions, predetermined camspeed is how fast the cam tween will go.
local VP_Connects     = {}; --store all viewport connections in here and destroy after

--//CheckerForSetup
local IsShopSetup     = false;

--Services
local ShopClerk       = require(script.Parent.Parent.Controllers.ShopClerk)
local TweenService    = game:GetService("TweenService");
local MarketplaceService = game:GetService("MarketplaceService")

local ShopData        = {} --Data will Need to be updated 
ShopData.ShopInfo     = {--simulate server items. Items: skins=textures,colors, taunt sounds/animations, accessories
	  --Name = {Type = (anim,skin,pet), Price, Desc, Rarity = (common,uncommon,rare,bruh)}?
	Sale = 1;--Change This Scale to change the Sale!
	Featured = {};  
	Daily = {};
	GamePasses = {};
    Refills = {};
    CurrentItem = nil;
    CurrentItemData = nil;
    FeaturedTimer = 0000;
    DailyTimer = 0000;

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

--//hold all the data on the local side unless a purchase is gonna be made/changes to equipped is made


--Models/Objects
local ShopModel       = game.ReplicatedStorage.Shop.ShopBG;
local ShopItems       = game.ReplicatedStorage.Shop.ShopItems;
local player          = game.Players.LocalPlayer;
local cam             = workspace.CurrentCamera;
local newshop;
local PurpleCam,
		RedCam,
		BlueCam,
		CashCam,
		DownCam,
		UpCam;

--User Interface
local UI              = game.Players.LocalPlayer.PlayerGui
local ShopUI          = UI.ShopUI;
local PlayerUI        = UI.PlayerUI;
local StatusUI        = UI.GameUI.Status
local LastFrame       = ShopUI.MARKET;

local Inventory,
		Market,
		Store,
		Twitter,
		ShopButtons     = ShopUI.INVENTORY, ShopUI.MARKET, ShopUI.STORE, ShopUI.TWITTER, ShopUI.ShopButtons;

        local twitterFrame    = Twitter.TwitterFrame
        local twitterTextBox  = twitterFrame.TextBox

local TransitioninProgress = false;
ShopFunctions.plrInShop = false
ShopFunctions.DoNotOpen = false
--SoundController
local SoundController = require(script.Parent.SoundMaster)

--Button Pressed Sound
local Press          = UI.SoundHolder.Press


local SelectedInventoryItem, SelectedType; --Inventory Vara

ShopFunctions.DisableShop = function(bool)
    ShopFunctions.DoNotOpen = bool
end

ShopFunctions.UpdateShopItems =  function(Data)
    print("ShopItems Updated: ", Data)
	ShopData.ShopInfo = Data;
end
ShopFunctions.DisplayTime = function()
    spawn(function()
        while wait() do
            local currenttime = os.time()
            local remainingweek = ShopData.ShopInfo.FeaturedTimer - currenttime
            local remaininghrs = ShopData.ShopInfo.DailyTimer - currenttime
            if currenttime >= ShopData.ShopInfo.FeaturedTimer or currenttime >= ShopData.ShopInfo.DailyTimer then
                ShopFunctions.UpdateShopItems(ShopClerk:GetShopInfo())
                ShopFunctions.updatemarket(ShopData.ShopInfo.CurrentFeatured,"Featured");
                ShopFunctions.updatemarket(ShopData.ShopInfo.CurrentDaily, "Retail");
            end;
            local daysremain = tonumber(os.date("%j", ShopData.ShopInfo.FeaturedTimer)) - tonumber(os.date("%j", currenttime)) 
            Market.Shop.Featured.Timer.TextLabel.Text =
           (tostring(tonumber(os.date("%H",remainingweek)) + daysremain*24)..":"..os.date("%M", remainingweek) ..":".. os.date("%S", remainingweek)) or "error"
            Market.Shop.Retail.Timer.TextLabel.Text = 
            (os.date("%H",remaininghrs)..":"..os.date("%M", remaininghrs) ..":".. os.date("%S", remaininghrs)) or "error"
            wait(1)
        end;
    end)
end;
ShopFunctions.Setup   = function()--set up the main shop by fading UI, and setting up shop and camera view.
    if ShopFunctions.DoNotOpen then return end
    if ShopFunctions.plrInShop then return end
    
    ShopFunctions.plrInShop = true
    newshop = ShopModel:Clone();
    newshop.Parent = cam;
    
    
    
    PlayerUI.WhiteFade.BackgroundTransparency = 0;
    --Fade regular Music Out

    cam.CameraType = Enum.CameraType.Scriptable;
    cam.CFrame = newshop.Cams.RedCam.CFrame;
    PurpleCam = {CFrame = newshop.Cams.PurpleCam.CFrame}
    RedCam = {CFrame = newshop.Cams.RedCam.CFrame}
    BlueCam = {CFrame = newshop.Cams.BlueCam.CFrame}
    CashCam = {CFrame = newshop.Cams.CashCam.CFrame}
    DownCam = {CFrame = newshop.Cams.DownCam.CFrame}
    UpCam = {CFrame = newshop.Cams.UpCam.CFrame}
    ShopUI.Enabled = true;
    PlayerUI.Enabled = false;
    PlayerUI.WhiteFade.Transparency = 0;
    --Shop Music Starts Playing
    if not IsShopSetup then
        ShopFunctions.SetupFrames();
        ShopFunctions.DisplayTime()
        IsShopSetup = true;

    end;
    ShopUI.WhiteFade.BackgroundTransparency = 1;
    ShopButtons:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad", .5);
    Market.Info:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad", .5);
    Market.Shop:TweenPosition(UDim2.fromScale(.5,.5), "Out", "Quad", .5);
    StatusUI.Visible = false;

end;

ShopFunctions.ChangeCamPos   = function(CamPos)--Changes camera positions by 
	local transitionCam = UpCam;
	if math.random(0,50)%2==0 then transitionCam = DownCam; end;
	TweenService:Create(cam, TweenInfo.new(ShopFunctions.CamSpeed), transitionCam):Play();
	wait(.5)
	TweenService:Create(cam, TweenInfo.new(ShopFunctions.CamSpeed), CamPos):Play();
end

ShopFunctions.ChangeFrames   = function(FrameName)
	local ColorButton = {
		MARKET = {In = Color3.fromRGB(197, 66, 66); Out = Color3.fromRGB(255, 87, 87)} ,
		INVENTORY ={Out = Color3.fromRGB(205, 196, 255), In = Color3.fromRGB(137, 131, 170)} ,
		STORE = {Out = Color3.fromRGB(128, 238, 114), In = Color3.fromRGB(89, 192, 86)}, 
		TWITTER ={Out = Color3.fromRGB(120, 228, 255) ; In = Color3.fromRGB(85, 160, 179)}}
   spawn(function()
	  if not TransitioninProgress then
		 TransitioninProgress = true;
		 if LastFrame ~=FrameName then
            if LastFrame.Name ~= "TWITTER" then
                LastFrame.Info:TweenPosition(UDim2.fromScale(1,.5),"Out", "Quad",.8);
                LastFrame.Shop:TweenPosition(UDim2.fromScale(-.2,.5),"Out", "Quad",.8);
            else
                twitterFrame:TweenPosition(UDim2.fromScale(.355, -.5), "Out", "Bounce",.5)
            end;
            ShopButtons[LastFrame.Name].ImageColor3 = ColorButton[LastFrame.Name].Out;
		 end;
         if FrameName.Name ~= "TWITTER" then
            FrameName.Info:TweenPosition(UDim2.fromScale(.5,.5),"Out", "Quad",.8);
            FrameName.Shop:TweenPosition(UDim2.fromScale(.5,.5),"Out", "Quad",.8);
         else
            twitterFrame:TweenPosition(UDim2.fromScale(.355, .3), "Out", "Bounce",1)
         end
         ShopButtons[FrameName.Name].ImageColor3 = ColorButton[FrameName.Name].In;

		 LastFrame = FrameName;
		 wait(0.8)
		 TransitioninProgress = false;
	  end;
	end)
end

ShopFunctions.SetViewPort    = function(viewport,model)
	local function setRotationEvent(viewportCamera,model)
		local currentAngle = 0
		local modelCF, modelSize = model:GetBoundingBox()
		local rotInv = (modelCF - modelCF.p):inverse()
		modelCF = modelCF * rotInv
		modelSize = rotInv * modelSize
		modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))
		local diagonal = 0
		local maxExtent = math.max(modelSize.x, modelSize.y, modelSize.z)
		local tan = math.tan(math.rad(viewportCamera.FieldOfView/2))
		
		if (maxExtent == modelSize.x) then
			diagonal = math.sqrt(modelSize.y*modelSize.y + modelSize.z*modelSize.z)/2
		elseif (maxExtent == modelSize.y) then
			diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.z*modelSize.z)/2
		else
			diagonal = math.sqrt(modelSize.x*modelSize.x + modelSize.y*modelSize.y)/2
		end
		local minDist = (maxExtent/2)/tan + diagonal;
		
		local VF_Funcs = game:GetService("RunService").RenderStepped:Connect(function(dt)
			currentAngle = currentAngle + 2*dt*60
			viewportCamera.CFrame = modelCF * CFrame.fromEulerAnglesYXZ(0, math.rad(currentAngle), 0) * CFrame.new(0, 0, minDist + 3) * CFrame.new(0,0,-3)
		end);
		table.insert(VP_Connects,VF_Funcs);
		return VF_Funcs;
	end
	local newcam = Instance.new("Camera")
	newcam.Parent = viewport;
	viewport.CurrentCamera = newcam;
	setRotationEvent(newcam,model);
end

local SelectedCard = nil
ShopFunctions.reloadcards = function(Type,location,reset)
    if reset then
        location:ClearAllChildren();
        local layout = Inventory.Shop.Folder.UIGridLayout:Clone();
        layout.Parent = location;
    end;
    for i,x in pairs (ShopClerk:GetInventory(Type)) do
        local Card = Inventory.Shop.Card;
        local Carditem = Card:Clone();
        Carditem.Name = i
        local VF = Carditem.Frame.ViewportFrame;
        local CardModel;
        if x== "DEFAULT" then
            Carditem.Frame.TextLabel.Text = "DEFAULT";
            CardModel = ShopItems.Market[Type]["DEFAULT"]:Clone()
        else
            CardModel = ShopItems.Market[Type][i]:Clone()
            Carditem.Frame.TextLabel.Text = i;
        end;
        CardModel.Parent = VF;
        ShopFunctions.SetViewPort(VF,CardModel);
        Carditem.Parent = location
        Carditem.Visible = true;
        Carditem.Frame.MouseButton1Click:connect(function()
            local VF = Inventory.Info.ViewportFrame;
            VF.WorldModel:ClearAllChildren()
            local CardModel;
            if x~="DEFAULT" then
                CardModel = ShopItems.Market[Type][i]:Clone();
            else
                CardModel = ShopItems.Market[Type]["DEFAULT"]:Clone();
            end;
            SelectedInventoryItem = Carditem
            SelectedType = Type
            CardModel.Parent = VF.WorldModel;
            ShopFunctions.SetViewPort(VF,CardModel);
            if x~= "DEFAULT" then
                Inventory.Info.Title.TextLabel.Text = i;
                Inventory.Info.Desc.TextLabel.Text = x.Desc;
            else
                Inventory.Info.Title.TextLabel.Text = "DEFAULT";
                Inventory.Info.Desc.TextLabel.Text = "Resets to Default"
            end
            if SelectedCard and SelectedCard.Name == Carditem.Name then
                Inventory.Info.Desc.Equip.TextLabel.Text = "EQUIPPED"
            else
                Inventory.Info.Desc.Equip.TextLabel.Text = "EQUIP"
            end
        end)
    end

end;

ShopFunctions.updatemarket = function(Table,Frame)
    Market.Shop[Frame].Holder.Frame:ClearAllChildren()
    local Desc      = Market.Info.Desc;
    local Title     = Market.Info.Title;
    local Viewport  = Market.Info.Viewport;
    local UIGRID     = Market.Shop[Frame].Holder.Folder.UIGridLayout:Clone()
    UIGRID.Parent = Market.Shop[Frame].Holder.Frame

    local priceOrder = {};
    for i,v in pairs (Table) do
        table.insert(priceOrder,{i,v})
    end
    table.sort(priceOrder,function(a,b) return a[2].Price < b[2].Price end)
    for _,p in pairs (priceOrder) do --Setup Featured Section in Market
        local i = p[1]
        local v = p[2]
        local Card      = Market.Shop[Frame].Holder.Card:Clone();
        local CardModel = ShopItems.Market[v.Type][i]:Clone()
        local VF        = Card.Frame.ViewportFrame;
        Card.Name = i;
        Card.Frame.Price.Label.Text = "$"..v.Price;
        Card.Frame.Title.Text = i;
        CardModel.Parent = VF; 
        ShopFunctions.SetViewPort(VF,CardModel);
        Card.Parent = Market.Shop[Frame].Holder.Frame;
        Card.Visible = true;
        Card.Frame.MouseButton1Down:connect(function()
            Viewport.WorldModel:ClearAllChildren();
            CardModel = ShopItems.Market[v.Type][i]:Clone();
            CardModel.Parent = Viewport.WorldModel;
            ShopFunctions.SetViewPort(Viewport,CardModel);
            Desc.Label.Text = v.Desc;
            Title.Label.Text = i;
            Desc.Equip.Label.Text = "Buy: $"..v.Price;
            ShopData.ShopInfo.CurrentItem = i;
            ShopData.ShopInfo.CurrentItemData = v;
        end)
    end
end;

ShopFunctions.SetupFrames    = function()
	local ShopInfo  = ShopData.ShopInfo;
    local Desc = Market.Info.Desc;
    Desc.Equip.MouseLeave:connect(function()
        Desc.Equip.Label.Text = "Buy: $"..ShopData.ShopInfo.CurrentItemData.Price;
    end)
    Desc.Equip.MouseEnter:connect(function()
        Desc.Equip.Label.Text = "Are you sure?"
    end)
    Desc.Equip.MouseButton1Down:connect(function()
        local success,msg = ShopClerk:CanPurchaseItem(ShopData.ShopInfo.CurrentItem, ShopData.ShopInfo.CurrentItemData.Type, ShopData.ShopInfo.CurrentItemData.Price)
        if success and msg == "success" then
            ShopClerk:UpdateInventory(ShopData.ShopInfo.CurrentItem,ShopData.ShopInfo.CurrentItemData)
            Desc.Equip.Label.Text = "Purchase Successful!"
            local data = ShopData.ShopInfo.CurrentItemData;
            local Section = Inventory.Shop.Frame;
            if data.Type == "Skin" or data.Type == "Color" then
                ShopFunctions.reloadcards("Color",Section["Skins"].holder,true)
                ShopFunctions.reloadcards("Skin",Section["Skins"].holder)
            end;
            wait(1)
            Desc.Equip.Label.Text = "Owned"
        else
            Desc.Equip.Label.Text = msg;
            wait(1)
            Desc.Equip.Label.Text = "Buy: $"..ShopData.ShopInfo.CurrentItemData.Price;
        end;
    end)
	ShopFunctions.updatemarket(ShopInfo.CurrentFeatured,"Featured");
	ShopFunctions.updatemarket(ShopInfo.CurrentDaily, "Retail");
	local Section = Inventory.Shop.Frame.Anim;

	for _,v in pairs (Inventory.Shop:GetChildren()) do
        local Debounce = false;
		if v.ClassName ~="ImageButton" then continue end;
		v.Click.MouseButton1Down:connect(function()
            if v.Name ~= "Skins" then return end;
            if not Debounce then Debounce = true; else return end;
			if Section.Name ~=v.Name then
				Section:TweenPosition(UDim2.fromScale(.424,-.5),"Out", "Quad",.6);
			end;
            Section = Section.Parent[v.Name];
			Section:TweenPosition(UDim2.fromScale(.424,.548),"Out", "Quad",.6);
            if v.Name == "Skins" then
                ShopFunctions.reloadcards("Color", Section.holder,true)
                ShopFunctions.reloadcards("Skin", Section.holder)                
            end;
            wait(.7);
			Debounce = false;
		end)
	end
    Inventory.Info.Desc.Equip.MouseButton1Down:connect(function()
        if SelectedInventoryItem ~= nil then
            local result = ShopClerk:Equip(SelectedInventoryItem.Name,SelectedType)
            if result then
                if SelectedCard ==nil then 
                    SelectedCard = SelectedInventoryItem;
                    SelectedCard.Frame.ImageColor3 = Color3.fromRGB(71, 175, 255)
                else
                    SelectedCard.Frame.ImageColor3 = Color3.fromRGB(129, 107, 255)
                    SelectedCard = SelectedInventoryItem;
                    SelectedCard.Frame.ImageColor3 = Color3.fromRGB(71, 175, 255)
                end
                Inventory.Info.Desc.Equip.TextLabel.Text = "Equipped!"
                wait(1);
                Inventory.Info.Desc.Equip.TextLabel.Text = "EQUIP"
            else
                Inventory.Info.Desc.Equip.TextLabel.Text = "You dont own!"
                wait(1)
                Inventory.Info.Desc.Equip.TextLabel.Text = "EQUIP"
            end;
        end;
    
    end)
	local ChosenDevProduct;
	local Store_CardSetup = function(Table,Frame)
        local priceOrder = {};
        for _,v in pairs (Table) do
            table.insert(priceOrder,v.Price)
        end
        table.sort(priceOrder,function(a,b) return a < b end)
		for _,price in pairs (priceOrder) do 
            for i,v in pairs (Table) do
                if price ~= v.Price then continue end;
                local CardModel = ShopItems.Store[i]:Clone();
                local Card		= Store.Shop.Shop.Card:Clone();
                local Desc      = Store.Info.Desc;
                local Title     = Store.Info.Title;
                local Viewport  = Store.Info.Viewport;
                local VF        = Card.Frame.ViewportFrame;
                CardModel.Parent = VF; 
                ShopFunctions.SetViewPort(VF,CardModel);
                Card.Name = i;
                Card.Frame.Price.Label.Text = "$"..v.Price;
                Card.Frame.Title.Text = i;
                Card.Parent = Store.Shop.Shop[Frame];
                Card.Visible = true;
                Card.Frame.MouseButton1Down:connect(function()
                    Viewport.WorldModel:ClearAllChildren();
                    CardModel = ShopItems.Store[i]:Clone();
                    CardModel.Parent = Viewport.WorldModel;
                    ShopFunctions.SetViewPort(Viewport,CardModel);
                    Desc.Label.Text = v.Desc;
                    Title.Label.Text = i;
                    Desc.Buy.Label.Text = "Buy: $"..v.Price;
                    ChosenDevProduct = i;
                end)
            end
		end

	end
    Store.Info.Desc.Buy.MouseButton1Down:connect(function()
        if not ChosenDevProduct then return end;
        for i,v in pairs(DevProductIDs) do
            if i==ChosenDevProduct then
                ChosenDevProduct = v;
                if i ~= "VIP" and i ~= "2XP" then
                    MarketplaceService:PromptProductPurchase(player,ChosenDevProduct)
                else
                    MarketplaceService:PromptGamePassPurchase(player,ChosenDevProduct)
                end;
                break;
            end;
        end;
        repeat wait() until ShopClerk:GetRecentTransaction().didSucceed ~= nil 
        if ShopClerk:GetRecentTransaction().didSucceed then
            local org = Store.Info.Desc.Buy.Label.Text
            if ShopClerk:GetRecentTransaction().Name~="Donation" then
                Store.Info.Desc.Buy.Label.Text = "Purchased!"
            else
                Store.Info.Desc.Buy.Label.Text = "Thank You!"
            end;
            wait(1.5)
            Store.Info.Desc.Buy.Label.Text = org;            
        end
    end)

	Store_CardSetup(ShopInfo.Items.Refills, "Robux");
	Store_CardSetup(ShopInfo.Items.GamePasses, "Deals");
 
end

ShopFunctions.ExitShop  = function(IsMatch,showui, disableShop) --Doesnt add the fade if ismatch is true
    SoundController.Play("Stop")
    if newshop ==nil then return end;
    if IsMatch ~= true then
        ShopUI.WhiteFade.BackgroundTransparency = 0;
    end
    if LastFrame.Name ~= "TWITTER" then
        LastFrame.Info:TweenPosition(UDim2.fromScale(1,.5),"Out", "Quad",.8);
        LastFrame.Shop:TweenPosition(UDim2.fromScale(-.2,.5),"Out", "Quad",.8);
    else
        twitterFrame:TweenPosition(UDim2.fromScale(.355, -.5), "Out", "Bounce",.5) 
    end
    ShopButtons:TweenPosition(UDim2.fromScale(.5,.3), "Out", "Quad", .5);
    newshop:Destroy();
   LastFrame = ShopUI.MARKET;
   if showui == false then
        PlayerUI.Enabled = false 
   else
        PlayerUI.Enabled = true;
   end
   StatusUI.Visible = true;
    ShopUI.Enabled = false;
    wait(.1)
    cam.CameraType = Enum.CameraType.Custom;
    --if IsMatch ~= true then
        PlayerUI.WhiteFade.BackgroundTransparency = 1;
    --end;
    if not disableShop then
        spawn(function()
            wait(2)
            ShopFunctions.plrInShop = false
        end)
    end
end

local shopButtonDebounce = false

for _,v in pairs (ShopButtons:GetChildren()) do
    if v.ClassName ~=  "ImageButton" then continue end;
    if v.Name ~="EXIT" then
        v.MouseButton1Click:connect(function()
            if not shopButtonDebounce then
                shopButtonDebounce = true
                
                spawn(function()
                    wait(ShopFunctions.CamSpeed +.55)
                    shopButtonDebounce = false
                end)
                                
                Press:Play()
                ShopFunctions.ChangeFrames(ShopUI[v.Name]);
                if v.Name=="INVENTORY" then
                    ShopFunctions.ChangeCamPos(PurpleCam);
                elseif v.Name=="MARKET" then
                    ShopFunctions.ChangeCamPos(RedCam);
                elseif v.Name =="STORE" then
                    ShopFunctions.ChangeCamPos(CashCam);
                elseif v.Name =="TWITTER" then
                    ShopFunctions.ChangeCamPos(BlueCam);
                end;
            end
        end)
    else
        v.MouseButton1Click:connect(function()
            if not shopButtonDebounce then
                shopButtonDebounce = true

                spawn(function()
                    wait(ShopFunctions.CamSpeed +.55)
                    shopButtonDebounce = false
                end)
                
                Press:Play()
                ShopFunctions.ExitShop()
               -- ShopFunctions.ChangeFrames(ShopUI[v.Name]);

                wait(1)
                SoundController.Play("LobbyMusic")
            end
        end)
    end;
    
end

twitterTextBox.FocusLost:connect(function()
    local bool,msg,cash = ShopClerk:isTwitterCodeValid(twitterTextBox.Text)
	if bool then
        Market.Info.Cash.TextLabel.Text = "$"..tostring(cash)
		twitterTextBox.TextColor3 = Color3.fromRGB(0,255,0)
		twitterTextBox.Text = "REDEEMED!"
        twitterTextBox.Parent.Follow.Text = msg

		wait(3)
		twitterTextBox.TextColor3 = Color3.fromRGB(0,0,0)
		twitterTextBox.Text = ""
        twitterTextBox.Parent.Follow.Text = "Follow our Twitter! @MysticStudios2"

	else
		twitterTextBox.TextColor3 = Color3.fromRGB(255,0,0)
		twitterTextBox.Text = msg
		wait(1)
		twitterTextBox.TextColor3 = Color3.fromRGB(0,0,0)
		twitterTextBox.Text = ""
	end
end)


return ShopFunctions;

