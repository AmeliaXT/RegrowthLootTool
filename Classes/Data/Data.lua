---@type Regrowth
local _, Regrowth = ...;

local defaultData = {
    data = {},
    timestamp = 0,
}

---@class Regrowth.Data
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
        latest = "0.5",
    },
    Storage = {
        LootCouncil = {
            data = "",
            timestamp = 0,
        },
        System = defaultData,
        Priorities = defaultData,
        Items = defaultData,
        Players = defaultData,
    }
};

---@type Regrowth.Data
Regrowth.Data = RegrowthData;

local function isOlderData(input, current)
    if input > current then
        return false;
    end

    return true;
end

local function UpdateSystem(systemData)
    if isOlderData(systemData.timestamp, RegrowthData.Storage.System.timestamp) then
        Regrowth:warning("Update for 'System' skipped - Current data is newer.");
        return;
    end

    Regrowth:debug("Updating 'System'...");

    RegrowthData.Storage.System = systemData;
end

local function UpdatePriorities(prioritiesData)
    if isOlderData(prioritiesData.timestamp, RegrowthData.Storage.Priorities.timestamp) then
        Regrowth:warning("Update for 'Priorities' skipped - Current data is newer.");
        return;
    end

    Regrowth:debug("Updating 'Priorities'...");

    RegrowthData.Storage.Priorities = prioritiesData;
end

local function UpdateItems(itemsData)
    if isOlderData(itemsData.timestamp, RegrowthData.Storage.Items.timestamp) then
        Regrowth:warning("Update for 'Items' skipped - Current data is newer.");
        return;
    end

    Regrowth:debug("Updating 'Items'...");

    local transformedItemsData = RegrowthData.Transformers:TransformItemsData(itemsData.data);

    RegrowthData.Storage.Items = {
        data = transformedItemsData,
        timestamp = itemsData.timestamp,
    };
end

local function UpdatePlayers(playersData)
    if isOlderData(playersData.timestamp, RegrowthData.Storage.Players.timestamp) then
        Regrowth:warning("Update for 'Players' skipped - Current data is newer.");
        return;
    end

    Regrowth:debug("Updating 'Players'...");

    RegrowthData.Storage.Players = playersData;
end

local function UpdateLootCouncil(lootCouncilData)
    if isOlderData(lootCouncilData.timestamp, RegrowthData.Storage.LootCouncil.timestamp) then
        Regrowth:warning("Update for 'LootCouncil' skipped - Current data is newer.");
        return;
    end

    Regrowth:debug("Updating 'LootCouncil'...");

    RegrowthData.Storage.LootCouncil = lootCouncilData;
end

local function UpdateProtectedData(newData, table)
    if (table == "Priorities") then
        return UpdatePriorities(newData);
    end

    if (table == "Items") then
        return UpdateItems(newData);
    end

    if (table == "Players") then
        return UpdatePlayers(newData);
    end

    if (table == "LootCouncil") then
        return UpdateLootCouncil(newData);
    end
end

local function UpdateOpenData(newData, table)
    if (table == "System") then
        return UpdateSystem(newData);
    end
end

local function UpdateLocalDataFromSync(data, table)
    RegrowthData.Storage[table] = data;

    return RegrowthData:UpdateLocalSavedData();
end

function RegrowthData:UpdateLocalData(newData, table, timestamp)
    if (table ~= "System" and
        table ~= "Priorities" and
        table ~= "Items" and
        table ~= "Players" and
        table ~= "LootCouncil")
    then
        Regrowth:error("Invalid table '" .. table .. "'.");
        return;
    end

    local mappedData = {
        data = newData,
        timestamp = timestamp or GetServerTime(),
    };

    if (table == "Priorities" or
        table == "Items" or
        table == "Players" or
        table == "LootCouncil")
    then
        if Regrowth.User.canReceiveUpdates then
            return UpdateProtectedData(mappedData, table);
        else
            Regrowth:error("Unable to update data. User not authorised.");
            return;
        end
    end

    return UpdateOpenData(mappedData, table);
end

function RegrowthData:UpdateLocalSavedData()
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    Regrowth_Data = self.Storage;
end

function RegrowthData:UpdateLocalDataAndSave(newData, table, timestamp)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    self:UpdateLocalData(newData, table, timestamp);
    self:UpdateLocalSavedData();
end

function RegrowthData:UpdateLocalProtectedDataFromSync(newData)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    if newData["System"] then
        Regrowth:debug("New 'System' data received. Updating...");
        UpdateLocalDataFromSync(newData["System"], "System");
    end

    if newData["Priorities"] then
        Regrowth:debug("New 'Priorities' data received. Updating...");
        UpdateLocalDataFromSync(newData["Priorities"], "Priorities");
    end

    if newData["Items"] then
        Regrowth:debug("New 'Items' data received. Updating...");
        UpdateLocalDataFromSync(newData["Items"], "Items");
    end

    if newData["Players"] then
        Regrowth:debug("New 'Players' data received. Updating...");
        UpdateLocalDataFromSync(newData["Players"], "Players");
    end

    if newData["LootCouncil"] then
        Regrowth:debug("New 'LootCouncil' data received. Updating...");
        UpdateLocalDataFromSync(newData["LootCouncil"], "LootCouncil");
    end
end

function RegrowthData:UpdateLocalOpenDataFromSync(newData)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    if newData["System"] then
        Regrowth:debug("New 'System' data received. Updating...");
        UpdateLocalDataFromSync(newData["System"], "System");
    end
end

function RegrowthData:UpdateLocalDataAndSaveFromImport(importData)
    if not Regrowth:isCurrentVersion() then
        Regrowth:warning("Can't update local Regrowth_Data - Version out of date.");
        return;
    end

    local timestamp = importData.system and importData.system.date_generated or nil;

    if importData.system then
        self:UpdateLocalDataAndSave(importData.system, "System", timestamp);
    end

    if importData.priorities then
        self:UpdateLocalDataAndSave(importData.priorities, "Priorities", timestamp);
    end

    if importData.items then
        self:UpdateLocalDataAndSave(importData.items, "Items", timestamp);
    end

    if importData.players then
        self:UpdateLocalDataAndSave(importData.players, "Players", timestamp);
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

    self.Storage.LootCouncil = self.Storage.LootCouncil or {
        data = "",
        timestamp = 0,
    };
    self.Storage.System = self.Storage.System or defaultData;
    self.Storage.Priorities = self.Storage.Priorities or defaultData;
    self.Storage.Items = self.Storage.Items or defaultData;
    self.Storage.Players = self.Storage.Players or defaultData;

    self._initialized = true;
end
