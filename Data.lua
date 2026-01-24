---@type Regrowth
local _, Regrowth = ...;

---@class RegrowthData
---@field Constants table
---@field Version string
---@field AuthorisedUsers string
---@field Items table
---@field Players table
---@field Recipes table
local RegrowthData = {
    _initialized = false,
    Constants = {
        Comm = {
            channel = "RGLT_Channel",

            Actions = {
                nex = 1,
                updateData = 2,
                updatePlayers = 3,
                updateRecipes = 4,
            },
        },
    },
    Version = {
        current = "0.0",
        latest = "0.3",
    },
    Storage = {
        AuthorisedUsers = {
            data = "Amy,Billy",
            timestamp = 0,
        },
        Items = {
            data = {},
            timestamp = 0,
        },
        Players = {
            data = {},
            timestamp = 0,
        },
        Recipes = {
            data = {},
            timestamp = 0,
        },
    }
};

---@type RegrowthData
Regrowth.Data = RegrowthData;

local function isOlderData(input, current)
    if input > current then
        return false;
    end

    return true;
end

local function isValidData(input, dataType)
    if not input then
        Regrowth:error("Input data invalid - Missing input data.")
        return false;
    end

    if type(input) ~= "table" then
        Regrowth:error("Input data invalid - Invalid data type '" .. type(input) .. "'.");
        return false;
    end

    if not input.timestamp then
        Regrowth:error("Input data invalid - Missing required field 'timestamp'.");
        return false;
    end

    if not input.data then
        Regrowth:error("Input data invalid - Missing required field 'data'.");
        return false;
    end

    if type(input.timestamp) ~= "number" then
        Regrowth:error("Input data invalid - Invalid 'timestamp' data type '" .. type(input.timestamp) .. "'.");
        return false;
    end

    if type(input.data) ~= dataType then
        Regrowth:error("Input data invalid - Invalid 'data' data type '" .. type(input.data) .. "'.");
        return false;
    end

    return true;
end

local function UpdateAuthorisedUsers(users)
    if not isValidData(users, "string") then
        return;
    end

    if isOlderData(users.timestamp, RegrowthData.Storage.AuthorisedUsers.timestamp) then
        Regrowth:warning("Update for AuthorisedUsers skipped - Current data is newer.");
        return;
    end

    RegrowthData.Storage.AuthorisedUsers = users;
end

local function UpdateItems(items)
    if not isValidData(items, "table") then
        return;
    end

    if isOlderData(items.timestamp, RegrowthData.Storage.Items.timestamp) then
        Regrowth:warning("Update for Items skipped - Current data is newer.");
        return;
    end

    RegrowthData.Storage.Items = items;
end

local function UpdatePlayers(players)
    if not isValidData(players, "table") then
        return;
    end

    if isOlderData(players.timestamp, RegrowthData.Storage.Players.timestamp) then
        Regrowth:warning("Update for Players skipped - Current data is newer.");
        return;
    end

    RegrowthData.Storage.Players = players;
end

local function UpdateRecipes(recipes)
    if not isValidData(recipes, "table") then
        return;
    end

    if isOlderData(recipes.timestamp, Regrowth.Storage.Recipes.timestamp) then
        Regrowth:warning("Update for Recipes skipped - Current data is newer.");
        return;
    end

    RegrowthData.Storage.Recipes = recipes;
end

function RegrowthData:UpdateData(newData, table)
    if type(table) ~= "string" then
        Regrowth:error("Unable to update data. Invalid data type for table" .. type(table) .. "'.");
    end

    Regrowth:debug(table);

    if table ~= "AuthorisedUsers" and
        table ~= "Items" and
        table ~= "Players" and
        table ~= "Recipes"
    then
        Regrowth:error("Unable to update data. Invalid table '" .. table .. "'.");
        return;
    end

    local mappedData = {
        timestamp = GetServerTime(),
    }

    if table == "AuthorisedUsers" then
        Regrowth:debug(tostring(newData));
        mappedData.data = newData;
        return UpdateAuthorisedUsers(mappedData);
    end

    if table == "Items" then
        mappedData.data = newData;
        return UpdateItems(mappedData);
    end

    if table == "Players" then
        mappedData.data = newData;
        return UpdatePlayers(mappedData);
    end

    if table == "Recipes" then
        mappedData.data = newData;
        return UpdateRecipes(mappedData);
    end
end

function RegrowthData:UpdateSavedData()
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    Regrowth_Data = self.Storage;
end

function RegrowthData:UpdateDataAndSave(newData, table)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    self:UpdateData(newData, table);
    self:UpdateSavedData();
end

function RegrowthData:_init()
    if (self._initialized) then
        return;
    end

    self.Version.current = C_AddOns.GetAddOnMetadata(Regrowth.name, "Version") or self.Version.current;

    if not Regrowth:empty(Regrowth_Data) then
        self.Storage = Regrowth_Data
    else
        Regrowth_Data = tostring(self.Storage);
    end

    self._initialized = true;
end
