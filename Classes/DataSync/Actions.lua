---@type Regrowth
local _, Regrowth = ...;

---@type Data
local Actions = Regrowth.Data.Constants.Comm.Actions or {};

---@class Actions
local CommActions = {
    [Actions.nex] = function(Message)
        Regrowth:success("Message received: " .. Message.content);
    end,
    [Actions.handlereceiveddata] = function(Message)
        if Regrowth.User.canReceiveData then
            if not Message.sender then
                Regrowth:error("Received message from unknown sender. Ignoring.");
                return;
            end

            if Regrowth:verifyMessageSender(Message.sender) then
                Regrowth:success("Received data from valid user. Feature NYI.");
                return;
            end

            Regrowth:error("Received data from invalid user. Ignoring.");
            return;
        end

        Regrowth:error("You are not authorised to receive data.");
    end,
};

---@class Actions
Regrowth.Comm.Actions = CommActions;
