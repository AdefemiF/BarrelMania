--April,22,2019
--EVENT_HANDLER
--TrollD3

local EVENT_HANDLER = {}
local Framework, GameUI, PlayerUI, Replicate, Fade, SoundMaster , Indicator,Results,ShopClerk, ShopMaster,StoreService, MapVoting
local plr = game.Players.LocalPlayer

function EVENT_HANDLER:Start()
    Framework = self.Services.Framework
    SoundMaster = self.Modules.SoundMaster
    GameUI = self.Modules.GameUIFunctions
    PlayerUI = self.Modules.PlayerMenuUI
    Indicator = self.Modules.IndicatorModule
    Replicate = self.Controllers.Replication
    Fade = self.Controllers.Fade
    Results = self.Modules.ResultsModule
    ShopClerk = self.Controllers.ShopClerk
    ShopMaster = self.Modules.ShopMaster
    StoreService = self.Services.StoreService
    MapVoting = self.Modules.MapVotingClient


    Framework["GAME_EVENT"]:Connect(
        function(Type, action, ...)
        --[[ UI -> CUTSCENE, STATUS, PLAYERTYPE,UPDATESPECTATE,COUNTDOWN,FINISH/ROUNDEND
            ACTION -> ActionEnabled
        --]]
            --print("CLIENT RECIEVED: " .. Type, action)
            if Type == "UI" then
                -- if UIStatus=="INTERMISSION" and UIStatus=="CUTSCENE" and UIStatus=="MATCH" then
                --EVENT_HANDLER:SOUNDMASTER(action); --Add spawn function for the handler
                -- end;
                EVENT_HANDLER:UIMASTER(action, ...)
            elseif Type == "ACTION" then
                Replicate:ActionEnabled(action)
                --print("ACTION FIRED ON CLIENT: Var"..tostring(action))
            end

        end
    )
end

function EVENT_HANDLER:UIMASTER(action, ...)
    -- print("DEBUG    "..Framework.GetInfo("Intermission"));
    if action == "INTERMISSION" then
        SoundMaster.Play("LobbyMusic")
        GameUI.Intermission(Framework:GetInfo("Intermission")) --done
        PlayerUI.SendTip()
    elseif action =="MAPVOTING" then
        local tuple = {...}
        if tuple[1] ~= "Disable" then
            MapVoting:DisableVoting(false)
            MapVoting:DisplayChoices(tuple[1])
        else
            MapVoting:DisableVoting(true)
        end
    elseif action == "RESET" then
        if not Framework:isAFK(plr) then

            wait(2)
            local tuple = {...};
            ShopMaster.DisableShop(false);
            ShopMaster.ExitShop(true);
            GameUI.ClearRoundUI()
            GameUI.ShowPlayerUI()
            GameUI.ShowStatusbar()
            PlayerUI.UpdateSpectate({})

        end

    elseif action == "UPDATESPECTATE" then
        PlayerUI.UpdateSpectate(...)
    elseif action =="UPDATESCORE"then
        GameUI.UpdateTeamScore(...)
        if not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            GameUI.ShowActions(Framework:GetPlayerType(),false)
        end
    elseif action == "STATUS" then
        GameUI.UpdateStatus(...)
    elseif action == "CUTSCENE" then
        if not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            local Map = Framework:GetInfo("Map")
            local Round = Framework:GetInfo("Mode")
            local MapAnim= Map:FindFirstChild("Animation")
            ShopMaster.DisableShop(true);
            ShopMaster.ExitShop(true, false, true);
            GameUI.HidePlayerUI()

            Fade:Out(3)
            Fade:In(4, true)
            GameUI.CutSceneUI(Map.Name, Map.Creator.Value, Round)
            if MapAnim then
                MapAnim.Disabled = false
            end
            SoundMaster.Play("CutsceneMusic")

            GameUI.MapPan(Map.Name)
            GameUI.CutSceneUI(nil)
        end
    elseif action == "ROUNDINTRO" then
        if not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            local Mode = Framework:GetInfo("Mode")
            SoundMaster.Play("Stop")
            Fade:In(3, true)
            GameUI.GameObjective(Mode, Framework:GetPlayerType()) --play souond
            GameUI.HealthBar(Framework:GetPlayerType())
            SoundMaster.Play("RoundMusic")
            GameUI.MatchSignal("GO")
            if Mode ~="Falling Barrels" then
                GameUI.ShowScore()
            end
            GameUI.ShowActions(Framework:GetPlayerType(),true)
        end
    elseif action == "RESULTS" then
        local tuple = {...};
        GameUI.UpdateStatus(tuple[1].." Win!")
        if not Framework:isPlaying(plr) then
            wait(3)
            GameUI.UpdateStatus("Showing Results CutScene...")    
        elseif not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            wait(.1)
            ShopMaster.DisableShop(true);
            ShopMaster.ExitShop(true, false, true);
            GameUI.HidePlayerUI()
            SoundMaster.Play("Whistle")
            GameUI.MatchSignal("STOP")
            GameUI.HideStatusbar()
            Fade:Out(1)
            
            GameUI.ClearRoundUI()
            GameUI.HidePlayerUI()

            Fade:In(2, true)
            SoundMaster.Play("ResultsMusic")
            Results.Activate(tuple[2])
            SoundMaster.Play("Stop")
            Fade:Out(3)
            wait(2)
            Fade:In(4,true)
            PlayerUI.UpdateSpectate({})

        end;
    elseif action == "INDICATOR" then
        if not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            local tuple = {...}; -- DOT: (Type,humans,barrel) / SKULL:(Type,Location,Team)
            if tuple[1]=="DOT" then
                Indicator.ShowTeamMembers(Framework:GetPlayerType(), tuple[2], tuple[3])
            elseif tuple[1]=="SKULL" then
                Indicator.SpawnSkull(tuple[2],tuple[3])
            end;
        end
    elseif action =="KILLFEED" then
        if not Framework:isAFK(plr) and Framework:isPlaying(plr) then
            GameUI.KillFeed(...)
        --[[
            local plr1 = {Name = "TrollD3"; Team = "Human"};
            local plr2 = {Name = "Shadow"; Team = "Barrel"};
            GameUIFuncs.KillFeed(plr1,plr2);
        --]]
        end;
    elseif action =="NICE" then
        print("NICE FIRED", ...)
        GameUI.NicePhrase(...)
    elseif action == "RESPAWNUI" then
       -- GameUI.RespawnUI()
    elseif action =="ShowAction" then
        GameUI.ShowActions(Framework:GetPlayerType(),false)
    elseif action=="UPDATE" then
        local PlayerData = Framework:ViewPlayerData(plr)
        local ShopData = Framework:GetInfo("")
        ShopClerk:UpdateUserData(PlayerData, true)
        if not Framework:isPlaying(plr) then
            local Status = Framework:GetInfo("Status");
            if Status == "INTERMISSION" then
                GameUI.UpdateStatus("INTERMISSION")
            elseif Status=="MATCH" then
                local GameMode = Framework:GetInfo("Mode");
                local RemainingTime = Framework:GetInfo("Time");
                wait(1)
                GameUI.UpdateStatus(GameMode,RemainingTime);
            end
            SoundMaster.Play("LobbyMusic")
        end;
    end
end

function EVENT_HANDLER:SendMapVote(mapName)
    Framework:SendMapVote(mapName)
end


function EVENT_HANDLER:Init()
    repeat
        wait(1)
    until game.Players.LocalPlayer.PlayerGui
end


return EVENT_HANDLER
