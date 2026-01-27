---@type Regrowth
local _, Regrowth = ...;

---@class RegrowthData
---@field Constants table
---@field Version string
---@field LootCouncil string
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
        latest = "0.4",
    },
    Storage = {
        LootCouncil = {
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

local function isValidInput(input, dataType)
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

local function isValidItemsData(items)
    for _, itemData in ipairs(items) do
        if not itemData or type(itemData) ~= "table" then
            return false;
        end

        for itemId, text in pairs(itemData) do
            if not tonumber(itemId) then
                return false;
            end

            if type(text) ~= "string" then
                return false;
            end
        end
    end

    return true;
end

local function TransformItemsData(items)
    local transformed = {};

    for _, itemData in ipairs(items) do
        for itemId, itemBias in pairs(itemData) do
            local itemIndex = tonumber(itemId);
    
            transformed[itemIndex] = itemBias;
        end
    end

    return transformed;
end

local function isValidPlayersData(players)
    for _, playerData in ipairs(players) do
        if not playerData or type(playerData) ~= "table" then
            return false;
        end

        for playerName, playerHistory in pairs(playerData) do
            if type(playerName) ~= "string" then
                return false;
            end

            for k, v in pairs(playerHistory) do
                if k ~= "attendance" and k ~= "loot" and k ~= "last" then
                    return false;
                end

                if k == "loot" and not tonumber(v) then
                    return false;
                end

                if k ~= "loot" and type(v) ~= "string" then
                    return false;
                end
            end
        end
    end

    return true;
end

local function TransformPlayersData(players)
    local transformed = {};

    for _, playerData in ipairs(players) do
        for playerName, playerHistory in pairs(playerData) do
            transformed[playerName] = {};

            for k, v in pairs(playerHistory) do
                transformed[playerName][k] = v;
            end
        end
    end

    return transformed;
end

local function UpdateLootCouncil(users)
    if not isValidInput(users, "string") then
        return false;
    end

    if isOlderData(users.timestamp, RegrowthData.Storage.LootCouncil.timestamp) then
        Regrowth:warning("Update for LootCouncil skipped - Current data is newer.");
        return false;
    end

    RegrowthData.Storage.LootCouncil = users;
    return true;
end

local function UpdateItems(items)
    if not isValidInput(items, "table") then
        return false;
    end

    if not isValidItemsData(items.data) then
        Regrowth:error("Invalid 'Items' format. Expected: { \"items\": [ { \"123\": \"Warrior\" } ] }");
        return false;
    end

    if isOlderData(items.timestamp, RegrowthData.Storage.Items.timestamp) then
        Regrowth:warning("Update for 'Items' skipped - Current data is newer.");
        return false;
    end

    Regrowth:success("'Items' data valid. Updating...");

    local transformedData = TransformItemsData(items.data);

    RegrowthData.Storage.Items = {
        data = transformedData,
        timestamp = items.timestamp
    };

    return true;
end

local function UpdatePlayers(players)
    if not isValidInput(players, "table") then
        return false;
    end

    if not isValidPlayersData(players.data) then
        Regrowth:error("Invalid 'Players' format. Expected: { \"players\": [ { \"Name\": { \"attendance\": \"50%\", \"loot\": 1, \"last\": \"01/01/2025\" } } ] }");
        return false;
    end

    if isOlderData(players.timestamp, RegrowthData.Storage.Players.timestamp) then
        Regrowth:warning("Update for 'Players' skipped - Current data is newer.");
        return false;
    end

    Regrowth:success("'Players' data valid. Updating...");

    local transformedData = TransformPlayersData(players.data);

    RegrowthData.Storage.Players = {
        data = transformedData,
        timestamp = players.timestamp
    };

    return true;
end

local function UpdateRecipes(recipes)
    if not isValidInput(recipes, "table") then
        return false;
    end

    if not isValidItemsData(recipes.data) then
        Regrowth:error("Invalid 'Recipes' format. Expected: { \"recipes\": [ { \"123\": \"Known By: Nex, Billy, etc.\" } ] }");
        return false;
    end

    if isOlderData(recipes.timestamp, RegrowthData.Storage.Recipes.timestamp) then
        Regrowth:warning("Update for 'Recipes' skipped - Current data is newer.");
        return false;
    end

    Regrowth:success("'Recipes' data valid. Updating...");

    local transformedData = TransformItemsData(recipes.data);

    RegrowthData.Storage.Recipes = {
        data = transformedData,
        timestamp = recipes.timestamp
    };

    return true;
end

local function UpdateProtectedData(newData, table)
    if table == "LootCouncil" then
        return UpdateLootCouncil(newData);
    end

    if table == "Items" then
        return UpdateItems(newData);
    end

    if table == "Players" then
        return UpdatePlayers(newData);
    end

    return true;
end

local function UpdateLocalFromSync(data, table)
    RegrowthData.Storage[table] = data;

    return RegrowthData:UpdateLocalSavedData();
end

function RegrowthData:UpdateLocalData(newData, table)
    if type(table) ~= "string" then
        Regrowth:error("Unable to update data. Invalid data type for table" .. type(table) .. "'.");
        return false;
    end

    if (table ~= "LootCouncil" and
        table ~= "Items" and
        table ~= "Players" and
        table ~= "Recipes")
    then
        Regrowth:error("Unable to update data. Invalid table '" .. table .. "'.");
        return false;
    end

    local mappedData = {
        data = newData,
        timestamp = GetServerTime(),
    };

    if (table == "LootCouncil" or
        table == "Players" or
        table == "Items")
    then
        if Regrowth.User.canReceiveUpdates then
            return UpdateProtectedData(mappedData, table);
        else
            Regrowth:error("Unable to update data. User not authorised.");
            return false;
        end
    end

    return UpdateRecipes(mappedData);
end

function RegrowthData:UpdateLocalSavedData()
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return false;
    end

    Regrowth_Data = self.Storage;
    return true;
end

function RegrowthData:UpdateLocalDataAndSave(newData, table)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    local hasUpdated = self:UpdateLocalData(newData, table);

    if hasUpdated then
        return self:UpdateLocalSavedData();
    end
end

function RegrowthData:UpdateLocalDataFromSync(newData)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    if newData["Items"] then
        Regrowth:debug("New 'items' data received. Updating...")
        UpdateLocalFromSync(newData["Items"], "Items");
    end

    if newData["Players"] then
        Regrowth:debug("New 'players' data received. Updating...")
        UpdateLocalFromSync(newData["Players"], "Players");
    end

    if newData["Recipes"] then
        Regrowth:debug("New 'recipes' data received. Updating...")
        UpdateLocalFromSync(newData["Recipes"], "Recipes");
    end

    if newData["LootCouncil"] then
        Regrowth:debug("New 'lootCouncil' data received. Updating...")
        UpdateLocalFromSync(newData["LootCouncil"], "LootCouncil");
    end
end

function RegrowthData:UpdateLocalRecipeDataFromSync(newData)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    if newData["Recipes"] then
        Regrowth:debug("New 'recipes' data received. Updating...")
        UpdateLocalFromSync(newData["Recipes"], "Recipes");
    end
end

function RegrowthData:UpdateLocalDataAndSaveFromImport(import)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    local table = Regrowth.json.decode(import);

    if table["items"] then
        Regrowth:debug("New 'items' data imported. Updating...")
        self:UpdateLocalDataAndSave(table["items"], "Items");
    end

    if table["players"] then
        Regrowth:debug("New 'players' data imported. Updating...")
        self:UpdateLocalDataAndSave(table["players"], "Players");
    end

    if table["recipes"] then
        Regrowth:debug("New 'recipes' data imported. Updating...")
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
        Regrowth_Data = self.Storage;
    end

    self._initialized = true;
end
