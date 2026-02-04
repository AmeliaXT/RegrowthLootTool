---@type Regrowth
local _, Regrowth = ...;

---@class Comm
local Comm = {
    _initialized = false,
};

---@type Comm
Regrowth.Comm = Comm;

---@type Regrowth.Data
local RegrowthData = Regrowth.Data;

function Comm:_init()
    if (self._initialized) then
        return;
    end

    self.channel = RegrowthData.Constants.Comm.channel;

    Regrowth.Ace:RegisterComm(self.channel, Comm.listen);

    self._initialized = true;
end

function Comm:send(Message, broadcastFinishedCallback, packageSentCallback)
    local compressed = Regrowth.Comm.Message:compress(Message);

    Regrowth.Ace:SendCommMessage(
        self.channel,
        compressed,
        Message.channel,
        Message.recipient
    );
end

function Comm:listen(payload, distribution, playerName)
    payload = Regrowth.Comm.Message:decompress(payload);

    if (not payload) then
        return false;
    end

    if (Regrowth:isSelf(payload.sender, payload.senderFqn)) then
        return false;
    end

    payload.channel = distribution;

    if (payload.senderFqn) then
        local ciSenderFqn = strlower(strtrim(payload.senderFqn));
        local ciPlayerName = strlower(strtrim(playerName));

        if (not Regrowth:strStartsWith(ciSenderFqn, ciPlayerName)) then
            return false;
        end
    end

    if (not payload.senderFqn or not type(payload.senderFqn) == "string") then
        return false;
    end

    Comm:dispatch(Regrowth.Comm.Message.newFromReceived(payload));
end

function Comm:dispatch(Message)
    local action = Message.action;

    if (not action) then
        return;
    end

    if (not Regrowth.Comm.Actions[action]) then
        return;
    end

    return Regrowth.Comm.Actions[action](Message);
end
