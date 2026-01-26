---@type Regrowth
local _, Regrowth = ...;

---@class User
---@field name string
---@field realm string
---@field fqn string
---@field canSendUpdates boolean
---@field canReceiveUpdates boolean
local User = {
    _initialized = false,
    canSendUpdates = false,
    canReceiveUpdates = false,
};

---@type User
Regrowth.User = User;

local function CanReceiveUpdates()
    if Regrowth.User.name == "Khamira" then
        return true;
    end

    local canUpdate = false;
    local lootCouncil = Regrowth.Data.Storage.LootCouncil.data;

    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't receive Regrowth_Data - Version out of date.");
        return false;
    end

    if C_GuildInfo.IsGuildOfficer() then
        return true;
    end

    for userName in string.gmatch(lootCouncil, '([^,]+)') do
        if (Regrowth:iEquals(userName, Regrowth.User.name)) then
            canUpdate = true;
        end
    end

    return canUpdate;
end

local function CanSendUpdates()
    if Regrowth.User.name == "Khamira" then
        return true;
    end

    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't send Regrowth_Data - Version out of date.");
        return false;
    end

    return C_GuildInfo.IsGuildOfficer();
end

function User:_init()
    if (self._initialized) then
        return;
    end

    self.name = UnitName("player");
    self.realm = GetRealmName():gsub("-", "");
    self.fqn = Regrowth:getFullyQualifiedName(self.name, self.realm);
    self.canSendUpdates = CanSendUpdates();
    self.canReceiveUpdates = CanReceiveUpdates();

    Regrowth:debug("User config: You " .. (self.canReceiveUpdates and "CAN" or "CAN NOT") .. " send messages.")
    Regrowth:debug("User config: You " .. (self.canSendUpdates and "CAN" or "CAN NOT") .. " receieve messages.")

    self._initialized = true;
end
