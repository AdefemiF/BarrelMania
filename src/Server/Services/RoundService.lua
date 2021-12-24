-- Round Service
-- TrollD3
-- April 18, 2019


local RoundService = {Client = {}}
function RoundService:Start()
  local Framework = self.Services.Framework;
  local chosenRound,chosenmap;
    while wait() do
        if Framework.CanRoundStart() then
            chosenRound = require(script.Parent.Parent.Modules.GameModes[Framework:ChooseRound("Mode")]);
            Framework.Intermission();
            if Framework.CanRoundStart() then
                chosenmap = Framework:ChooseRound("Map");

                chosenRound.Init(); --will deal with all code in the back
                --Framework.DisplayAwards()
                wait(23)--Wait For Results
                Framework.Reset();--wont start until chosen round is finished
            end
        end;
        wait(5)

    end;
end;

function RoundService:Init()
    print("Initializing...... \n V2 BETA \n Barrel Mania Starting...");
end;

return RoundService;