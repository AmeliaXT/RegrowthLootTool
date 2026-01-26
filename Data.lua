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
                handlereceiveddata = 2,
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

local function UpdateAuthorisedData(newData, table)
    local mappedData = {
        data = newData,
        timestamp = GetServerTime(),
    }

    if table == "AuthorisedUsers" then
        return UpdateAuthorisedUsers(mappedData);
    end

    if table == "Items" then
        return UpdateItems(mappedData);
    end

    if table == "Players" then
        return UpdatePlayers(mappedData);
    end
end

function RegrowthData:UpdateLocalData(newData, table)
    if type(table) ~= "string" then
        Regrowth:error("Unable to update data. Invalid data type for table" .. type(table) .. "'.");
        return;
    end

    if (table ~= "AuthorisedUsers" and
        table ~= "Items" and
        table ~= "Players" and
        table ~= "Recipes")
    then
        Regrowth:error("Unable to update data. Invalid table '" .. table .. "'.");
        return;
    end

    if (table == "AuthorisedUsers" or
        table == "Players" or
        table == "Items")
    then
        if Regrowth.User.canReceiveUpdates then
            return UpdateAuthorisedData(newData, table);
        else
            Regrowth:error("Unable to update data. User not authorised.");
            return;
        end
    end

    return UpdateRecipes(newData);
end

function RegrowthData:UpdateLocalSavedData()
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    Regrowth_Data = self.Storage;
end

function RegrowthData:UpdateLocalDataAndSave(newData, table)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    self:UpdateLocalData(newData, table);
    self:UpdateLocalSavedData();
end

function RegrowthData:UpdateLocalDataAndSaveFromImport(import)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    local table = Regrowth.json.decode(import);

    if table["items"] then
        self:UpdateLocalDataAndSave(table["items"], "Items");
    end

    if table["players"] then
        self:UpdateLocalDataAndSave(table["players"], "Players");
    end

    if table["recipes"] then
        self:UpdateLocalDataAndSave(table["recipes"], "Recipes");
    end
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
