---@type Regrowth
local _, Regrowth = ...;

---@class User
---@field name string
---@field realm string
---@field fqn string
---@field canSendUpdates boolean
local User = {
    _initialized = false,
    canSendUpdates = false,
};

---@type User
Regrowth.User = User;

local function CanSendUpdates()
    if Regrowth.User.name == "Khamira" or Regrowth.User.name == "Kyukon" then
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

    Regrowth:debug("User config: You " .. (self.canSendUpdates and "CAN" or "CAN NOT") .. " receive messages.")

    self._initialized = true;
end
