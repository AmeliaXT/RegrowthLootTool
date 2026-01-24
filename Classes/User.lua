---@type Regrowth
local _, Regrowth = ...;

---@class User
---@field name string
---@field realm string
---@field fqn string
---@field isOfficer boolean
local User = {
    _initialized = false,
    isOfficer = false,
};

---@type User
Regrowth.User = User;

function User:_init()
    if (self._initialized) then
        return;
    end

    self.name = UnitName("player");
    self.realm = GetRealmName():gsub("-", "");
    self.fqn = Regrowth:getFullyQualifiedName(self.name, self.realm);
    self.isOfficer = C_GuildInfo.IsGuildOfficer();

    self._initialized = true;
end

function User:CanSendUpdates()
    local canUpdate = false;
    local authorisedUsers = Regrowth.Data.Storage.AuthorisedUsers.data;

    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't share Regrowth_Data - Version out of date.");
        return false;
    end

    for userName in string.gmatch(authorisedUsers, '([^,]+)') do
        if (Regrowth:iEquals(userName, self.name)) then
            canUpdate = true;
            break;
        end
    end

    return canUpdate;
end
