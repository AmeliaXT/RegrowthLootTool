---@type Regrowth
local _, Regrowth = ...;

---@class Regrowth.Data.Validation
local Validation = {};

---@type Regrowth.Data.Validation
Regrowth.Data.Validation = Validation;

local function isValidSystemSchema(systemData)
    local function isValidSystemUserSchema(systemUserData)
        if type(systemUserData.id) ~= "string" then
            Regrowth:debug("1.5.1");
            return false;
        end

        if type(systemUserData.name) ~= "string" then
            Regrowth:debug("1.5.2");
            return false;
        end

        return true;
    end

    if type(systemData) ~= "table" then
        Regrowth:debug("1.1");
        return false;
    end

    if not (systemData.date_generated and systemData.user) then
        Regrowth:debug("1.2");
        return false;
    end

    if type(systemData.date_generated) ~= "number" then
        Regrowth:debug("1.3");
        return false;
    end

    if type(systemData.user) ~= "table" then
        Regrowth:debug("1.4");
        return false;
    end

    if not isValidSystemUserSchema(systemData.user) then
        Regrowth:debug("1.5");
        return false;
    end

    return true;
end

local function isValidPrioritiesSchema(prioritiesData)
    local function isValidPrioritiesIndexSchema(prioritiesIndexData)
        if type(prioritiesIndexData.id) ~= "number" then
            Regrowth:debug("2.2.1");
            return false;
        end

        if type(prioritiesIndexData.name) ~= "string" then
            Regrowth:debug("2.2.2");
            return false;
        end

        if type(prioritiesIndexData.icon) ~= "string" and type(prioritiesIndexData.icon) ~= "nil" then
            Regrowth:debug("2.2.3");
            return false;
        end

        return true;
    end

    if not Regrowth:isArray(prioritiesData) then
        Regrowth:debug("2.1");
        return false;
    end

    local idx = 0;

    for _ in pairs(prioritiesData) do
        idx = idx + 1;

        if not isValidPrioritiesIndexSchema(prioritiesData[idx]) then
            Regrowth:debug("2.2");
            return false;
        end
    end

    return true;
end

local function isValidItemsSchema(itemsData)
    local function isValidItemsIndexSchema(itemsIndexData)
        local function isValidItemsIndexPrioritySchema(itemsIndexPriorityData)
            if type(itemsIndexPriorityData.priority_id) ~= "number" then
                Regrowth:debug("3.2.4.1");
                return false;
            end

            if type(itemsIndexPriorityData.weight) ~= "number" then
                Regrowth:debug("3.2.4.2");
                return false;
            end

            return true;
        end

        if type(itemsIndexData.item_id) ~= "number" then
            Regrowth:debug("3.2.1");
            return false;
        end

        if type(itemsIndexData.notes) ~= "string" and type(itemsIndexData.notes) ~= "nil" then
            Regrowth:debug("3.2.2");
            return false;
        end

        if not Regrowth:isArray(itemsIndexData.priorities) then
            Regrowth:debug("3.2.3");
            return false;
        end

        local idx = 0;

        for _ in pairs(itemsIndexData.priorities) do
            idx = idx + 1;

            if not isValidItemsIndexPrioritySchema(itemsIndexData.priorities[idx]) then
                Regrowth:debug("3.2.4");
                return false;
            end
        end

        return true;
    end

    if not Regrowth:isArray(itemsData) then
        Regrowth:debug("3.1");
        return false;
    end

    local idx = 0;

    for _ in pairs(itemsData) do
        idx = idx + 1;

        if not isValidItemsIndexSchema(itemsData[idx]) then
            Regrowth:debug("3.2");
            return false;
        end
    end

    return true;
end

local function isValidPlayersSchema(playersData)
    local function isValidPlayersIndexSchema(playerData)
        if type(playerData) ~= "table" then
            Regrowth:debug("4.2.1");
            return false;
        end

        if not (playerData.id and playerData.name and playerData.attendance) then
            Regrowth:debug("4.2.2");
            return false;
        end

        if type(playerData.id) ~= "number" then
            Regrowth:debug("4.2.3");
            return false;
        end

        if type(playerData.name) ~= "string" then
            Regrowth:debug("4.2.4");
            return false;
        end

        if type(playerData.attendance) ~= "table" then
            Regrowth:debug("4.2.5");
            return false;
        end

        if not (playerData.attendance.first_attendance and
                playerData.attendance.attended and
                playerData.attendance.total and
                playerData.attendance.percentage)
        then
            Regrowth:debug("4.2.6");
            return false;
        end

        if type(playerData.attendance.first_attendance) ~= "string" then
            Regrowth:debug("4.2.7");
            return false;
        end

        if type(playerData.attendance.attended) ~= "number" then
            Regrowth:debug("4.2.8");
            return false;
        end

        if type(playerData.attendance.total) ~= "number" then
            Regrowth:debug("4.2.9");
            return false;
        end

        if type(playerData.attendance.percentage) ~= "number" then
            Regrowth:debug("4.2.10");
            return false;
        end

        return true;
    end

    if not Regrowth:isArray(playersData) then
        Regrowth:debug("4.1");
        return false;
    end

    local idx = 0;

    for _ in pairs(playersData) do
        idx = idx + 1;

        if not isValidPlayersIndexSchema(playersData[idx]) then
            Regrowth:debug("4.2");
            return false;
        end
    end

    return true;
end

local function isValidCouncillorsSchema(councillorsData)
    local function isValidCouncillorsIndexSchema(councillorData)
        if type(councillorData) ~= "table" then
            Regrowth:debug("5.2.1");
            return false;
        end

        if not (councillorData.id and councillorData.name and councillorData.rank) then
            Regrowth:debug("5.2.2");
            return false;
        end

        if type(councillorData.id) ~= "number" then
            Regrowth:debug("5.2.3");
            return false;
        end

        if type(councillorData.name) ~= "string" then
            Regrowth:debug("5.2.4");
            return false;
        end

        if type(councillorData.rank) ~= "string" then
            Regrowth:debug("5.2.5");
            return false;
        end

        return true;
    end

    if not Regrowth:isArray(councillorsData) then
        Regrowth:debug("5.1");
        return false;
    end

    local idx = 0;

    for _ in pairs(councillorsData) do
        idx = idx + 1;

        if not isValidCouncillorsIndexSchema(councillorsData[idx]) then
            Regrowth:debug("5.2");
            return false;
        end
    end

    return true;
end

local function isValidSchema(inputData)
    if type(inputData) ~= "table" then
        Regrowth:debug("0");
        return false;
    end

    if inputData.system and not isValidSystemSchema(inputData.system) then
        Regrowth:debug("1");
        return false;
    end

    if inputData.priorities and not isValidPrioritiesSchema(inputData.priorities) then
        Regrowth:debug("2");
        return false;
    end

    if inputData.items and not isValidItemsSchema(inputData.items) then
        Regrowth:debug("3");
        return false;
    end

    if inputData.players and not isValidPlayersSchema(inputData.players) then
        Regrowth:debug("4");
        return false;
    end

    if inputData.councillors and not isValidCouncillorsSchema(inputData.councillors) then
        Regrowth:debug("5");
        return false;
    end

    return true;
end

function Validation:IsValidInput(inputData)
    return isValidSchema(inputData);
end
