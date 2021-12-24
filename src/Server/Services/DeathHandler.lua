-- Death Handler
-- TrollD3
-- June 19, 2019


local Framework,PlayerDataService;
local DeathHandler = {Client = {}}

function DeathHandler:DeathSound(plr)
   spawn(function()
      local List = {138167455,540791978,527970724};
      local Sound = Instance.new("Sound");
      Sound.SoundId ="rbxassetid://".. List[math.random(1,#List)];
      Sound.Volume = 1;
      Sound.Parent = plr.Head;
      Sound:Play();
      wait(2);
      Sound:Destroy();
   end);
end;

function DeathHandler:Start() -------Deals with Death During the Game
    Framework = self.Services.Framework
    PlayerDataService = self.Services.PlayerDataService
    game.Players.CharacterAutoLoads = false
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Died:connect(function()
					local isPlaying = Framework:ReturnInfo("Players")
					for _, v in pairs(isPlaying) do
						if v == player.Name then
							isPlaying = true
							break
						end
					end
					if isPlaying ~= true or Framework:ReturnInfo("Mode") == nil   then
						wait(3)
						player:LoadCharacter()
					elseif isPlaying and Framework:ReturnInfo("Mode")~=nil and Framework:ReturnInfo("Status")=="MATCH" then
						local Mode = require(script.Parent.Parent.Modules.GameModes[Framework:ReturnInfo("Mode")])
                        Mode:OnDeath(player)
                    else
                        wait(1)
                        player:LoadCharacter()

					end
				end)
			end
		end)
		player:LoadCharacter()
	end)
end


function DeathHandler:Init()
end;
return DeathHandler;