---@type Regrowth
local _, Regrowth = ...;

---@type Regrowth.Data.Constants.Actions
local Actions = Regrowth.Data.Constants.Comm.Actions or {};

---@class Actions
local CommActions = {
    [Actions.nex] = function(Message)
        Regrowth:success("Message received: " .. Message.content);
    end,
    [Actions.handlereceiveddata] = function(Message)
        if not Message.sender then
            Regrowth:error("Received message from unknown sender. Ignoring.");
            return;
        end

        Regrowth:debug("Updating local data");
        Regrowth.Data:UpdateLocalProtectedDataFromSync(Message.content);
    end
};

---@class Actions
Regrowth.Comm.Actions = CommActions;
