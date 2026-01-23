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

    print("Running user stuff")

    self._initialized = true;
end
