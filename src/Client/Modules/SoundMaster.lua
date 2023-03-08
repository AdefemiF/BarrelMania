-- Sound Master
-- Username
-- November 20, 2020


--[[---------------------------------------------------------
	CutsceneMusic    = {2759720891;1841589884;1838080567;4835618264;1835662410};
	RoundMusic       = {4995916084;367339030;5439335346;5829910710;166014369;1281869149;295799686};
	ResultsMusic     = {1729141700;150272372;1837324424};
	IntroMusic       = {
        {Song= "Boss Music #1" ; ID = 5999681000;}; 
        {Song= "Roblox - Factory" ; ID = 1836349533;}; 
        {Song= "Roblox - Wiley" ; ID = 1843562622;}; 
	};
	LobbyMusic       = {
        
        {Song= "Roblox - When you coming back" ; ID = 1837871067;};
        {Song= "Roblox - Solar Flares" ; ID = 1836842889;};
        {Song= "Roblox - Crystal Clear" ; ID = 1837848642;};
        {Song= "Roblox - Robotic Dance C" ; ID = 1847853099;};
        {Song= "Roblox - Positive Rise" ; ID = 1839685658;};
        {Song= "Roblox - Love Is All Around" ; ID = 1842922252;};

		
	};
	ShopMusic        = {   
		{Song="Elevator Music";  ID = 927037476};
		{Song= "Unknown - Chill" ; ID = 3229079219;};
	}



--]]



--//All Music IDs Used
local MusicType = {
	CutsceneMusic    = {1845188109;1845571553;1845340610;1839858952;1838114124;1835649548};
	RoundMusic       = {1837788557;1846044369;1837344646;8116052630;1839285588;1840740877;1841546134;1841287751};
	ResultsMusic     = {1845242520;1846627298;1835821068};
	IntroMusic       = {
        {Song= "Roblox - Hollywood Christmas" ; ID = 1845622952;}; 
        {Song= "Roblox - Christmas Song (A)" ; ID = 1840658747;}; 
        {Song= "Roblox - Christmas Tree" ; ID = 1846045463;}; 
	};
	LobbyMusic       = {
        {Song= "Wishing you a Merry Christmas!" ; ID = 6017632918;};
        {Song= "Roblox - Christmas in the Sun" ; ID = 1837344678;};
        {Song= "Roblox - Christmas Pressies" ; ID = 1841239693;};
        {Song= "Roblox - Christmas Party" ; ID = 1837344545;};
        {Song= "Roblox - Wonderful Christmas" ; ID = 1835880891;};
        {Song= "Roblox - Christmas Groove" ; ID = 1835880933;};
        {Song= "Roblox - A Christmas Fairy" ; ID = 1846821427;};
        {Song= "Roblox - Christmas Day" ; ID = 1835968574;};
		{Song= "Roblox - Santa's World" ; ID = 1845178875;};
	};
	ShopMusic        = {   
		{Song="Roblox - Alone at Christmas";  ID = 1841664207};
		{Song= "Roblox -  Happy Christmas" ; ID = 1836008432;};
		{Song= "Roblox - Christmas Party" ; ID = 1845188014;};
        {Song= "Roblox - Christmas Morning" ; ID = 1845309089;};
		{Song= "Roblox - Playing Santa" ; ID = 1845305922;};


	}
}


--//PlayerVars
local player           = game.Players.LocalPlayer
local playerUI         = player.PlayerGui

--//Radio UI
local Radio            = playerUI.Radio.Radio

--//SpriteClip
local SpriteClip = require(script.Parent.SpriteClip)

--//Actual Sound Obj
local Master           = playerUI.SoundHolder.MASTER;
local SpriteClipObject = SpriteClip.new()


--Sound Boolean
local CanSoundPlay     = true;
local prevSoundType    = nil;

--SoundTable
local SoundMaster      = {}

SoundMaster.Setup      = function()
	local Label = Radio.BG.RadioImg
	SpriteClipObject.InheritSpriteSheet = true
	SpriteClipObject.Adornee = Label
	SpriteClipObject.SpriteSizePixel = Vector2.new(85.3,85.3)
	SpriteClipObject.SpriteCountX = 11
	SpriteClipObject.SpriteCount = 124
	SpriteClipObject.FrameRate = 60
end;

SoundMaster.ShowRadio  = function()
	spawn(function()
		SpriteClipObject:Play()
		Radio:TweenPosition(UDim2.fromScale(.422,.876), "Out", "Quad", .5)
		wait(0.5)
		Radio.Music:TweenSize(UDim2.fromScale(.645,.54), "Out", "Bounce",.7)
		wait(4)
		Radio.Music:TweenSize(UDim2.fromScale(0,.54), "Out", "Bounce",.7)
		wait(0.5)
		Radio:TweenPosition(UDim2.fromScale(.422,1.1), "Out", "Quad", .5)
		wait(0.5)
		SpriteClipObject:Stop()
	end)
end;

SoundMaster.Enabled   = function(bool)
    CanSoundPlay = bool
end;

SoundMaster.Play       = function(SoundType)
    if not CanSoundPlay then return end;
	spawn(function()
		if SoundType=="Stop" then
			spawn(function()
				repeat wait()
					Master.Volume = Master.Volume -.03
				until Master.Volume<=0
            end)
            return
        elseif SoundType =="Whistle" then
            Master.Volume = .4
            Master:Stop();
            Master.Looped = false
            Master.SoundId = "rbxassetid://1254957168"
            Master:Play();
			return
		end
        local random = Random.new(tick())
        local ChosenSound = MusicType[SoundType][random:NextInteger(1, #MusicType[SoundType])]
        Master.Volume = .4
        Master.Looped = true
		if SoundType =="RoundMusic" or SoundType=="CutsceneMusic" or SoundType=="ResultsMusic" then
			Master.SoundId = "rbxassetid://"..ChosenSound
			Master:Play();
		else
			Radio.Music.TextLabel.Text = ChosenSound.Song
			Master.SoundId = "rbxassetid://"..ChosenSound.ID
			Master:Play();
			SoundMaster.ShowRadio();
		end;
	
        prevSoundType = SoundType
	end)
	


end

SoundMaster.Setup()
return SoundMaster