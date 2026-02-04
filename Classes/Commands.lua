local _, Regrowth = ...;

---@type RegrowthData
local RegrowthData = Regrowth.Data;

---@class Commands
local Commands = {
    nex = function() 
        Regrowth.Comm.Message.new(
            RegrowthData.Constants.Comm.Actions.nex,
            "Nex says hi (>^.^<)",
            "GUILD"
        ):send();
    end,
    togglemainui = function()
        Regrowth.Frames:ToggleMainUIFrame();
    end,
    senddatasync = function()
        if Regrowth.User.canSendUpdates then
            local receivers = RegrowthData.Storage.LootCouncil.data;
            Regrowth:debug("Sending data to 'OFFFICER' chat.");

            local officerMessage = Regrowth.Comm.Message.new(
                RegrowthData.Constants.Comm.Actions.handlereceiveddata,
                Regrowth_Data,
                "OFFICER"
            );

            officerMessage:send();

            for receiver in string.gmatch(receivers, '([^,]+)') do
                Regrowth:debug("Sending data to '" .. receiver .. "'.");

                local message = Regrowth.Comm.Message.new(
                    RegrowthData.Constants.Comm.Actions.handlereceiveddata,
                    Regrowth_Data,
                    "WHISPER",
                    receiver
                );

                message:send();
            end

            return;
        end

        Regrowth:error("You are not authorised to send data.");
    end,
};

local function _dispatch(str)
    local command = str:match("^(%S+)");
    local argumentStr = "";

    if (command) then
        argumentStr = strsub(str, strlen(command) + 2);
    end

    if (not str or #str < 1) then
        command = "togglemainui";
    end

    command = string.lower(command);

    local args = {};

    args = { strsplit(" ", argumentStr, 1) };

    if (command and Regrowth.Commands[command]and type(Regrowth.Commands[command]) == "function") then
        return Regrowth.Commands[command](unpack(args))
    end
end;

---@type Commands
Regrowth.Commands = Commands;

function Commands:_init()
    Regrowth.Ace:RegisterChatCommand("rg", function (...)
        return _dispatch(...);
    end);

    Regrowth.Ace:RegisterChatCommand("regrowth", function (...)
        return _dispatch(...)
    end)
end

function Commands:call(str)
    return _dispatch(str);
end
