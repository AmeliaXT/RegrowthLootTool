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

local function senderIsOfficer(senderGUID)
    local rankOrder = C_GuildInfo.GetGuildRankOrder(senderGUID);

    return rankOrder <= 4;
end

function Regrowth.Ace:OnCommReceived(prefix, payload, distribution, sender)
    Regrowth:debug("HELLO");

    payload = Regrowth.Comm.Message:decompress(payload);

    if (not payload) then
        return;
    end

    if (Regrowth:isSelf(payload.sender, payload.senderFqn)) then
        return;
    end

    Regrowth:debug(payload.senderGUID);

    if (not senderIsOfficer(payload.senderGUID)) then
        Regrowth:error("Received message from non-officer GUID = " ..
            payload.senderGUID .. " | Name = " .. payload.sender);
        return;
    end

    payload.channel = distribution;

    if (payload.senderFqn) then
        local ciSenderFqn = strlower(strtrim(payload.senderFqn));
        local ciPlayerName = strlower(strtrim(sender));

        if (not Regrowth:strStartsWith(ciSenderFqn, ciPlayerName)) then
            return;
        end
    end

    if (not payload.senderFqn or not type(payload.senderFqn) == "string") then
        return;
    end

    Comm:dispatch(Regrowth.Comm.Message.newFromReceived(payload));
end

function Comm:_init()
    if (self._initialized) then
        return;
    end

    self.channel = RegrowthData.Constants.Comm.channel;

    Regrowth.Ace:RegisterComm(self.channel);

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
