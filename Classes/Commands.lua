local _, Regrowth = ...;

---@type RegrowthData
local RegrowthData = Regrowth.Data;

---@class Commands
local Commands = {
    CommandDescriptions = {
        test = "yup",
    },

    Dictionary = {
        nex = function() 
            Regrowth.Comm.Message.new(
                RegrowthData.Constants.Comm.Actions.nex,
                "Nex says hi (>^.^<)",
                "GUILD"
            ):send();
        end,
        senddataupdate = function()
            Regrowth.Comm.Message.new(
                RegrowthData.Constants.Comm.Actions.updateData,
                Regrowth_Item_Data,
                "GUILD"
            ):send();
        end,
        sendplayerupdate = function()
            Regrowth.Comm.Message.new(
                RegrowthData.Constants.Comm.Actions.updatePlayers,
                Regrowth_Players,
                "GUILD"
            ):send();
        end,
        sendrecipeupdate = function()
            Regrowth.Comm.Message.new(
                RegrowthData.Constants.Comm.Actions.updateRecipes,
                Regrowth_Recipes,
                "GUILD"
            ):send();
        end,
    },
};

---@type Commands
Regrowth.Commands = Commands;

function Commands:_init()
    Regrowth.Ace:RegisterChatCommand("rg", function (...)
        Regrowth.Commands:_dispatch(...);
    end);

    Regrowth.Ace:RegisterChatCommand("regrowth", function ()
        Regrowth.Commands:_dispatch("openimport")
    end)
end

function Commands:call(str)
    return Commands:_dispatch(str);
end

function Commands:_dispatch(str)
    local command = str:match("^(%S+)");
    local argumentStr = "";

    if (command) then
        argumentStr = strsub(str, strlen(command) + 2);
    end

    if (not str or #str < 1) then
        command = Regrowth:warning("Run a command you dummy :). Try /rg nex")
        return;
    end

    command = string.lower(command);

    local args = {};

    args = { strsplit(" ", argumentStr, 1) };

    if (command and self.Dictionary[command]and type(self.Dictionary[command]) == "function") then
        return self.Dictionary[command](unpack(args))
    end

    return self.Dictionary["nex"]();
end;
