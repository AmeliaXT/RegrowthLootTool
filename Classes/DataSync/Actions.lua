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
        if Regrowth.User.canReceiveUpdates then
            if not Message.sender then
                Regrowth:error("Received message from unknown sender. Ignoring.");
                return;
            end

            if Regrowth:verifyMessageSender(Message.sender) then
                Regrowth:debug("Updating local data");
                Regrowth.Data:UpdateLocalProtectedDataFromSync(Message.content);
                return;
            end

            Regrowth:error("Received data from invalid user. Ignoring.");
            return;
        end

        Regrowth.Data:UpdateLocalOpenDataFromSync(Message.content);
    end,
};

---@class Actions
Regrowth.Comm.Actions = CommActions;
