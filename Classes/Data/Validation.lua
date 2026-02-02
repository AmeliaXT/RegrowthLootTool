---@type Regrowth
local _, Regrowth = ...;

---@class RegrowthDataValidation
local Validation = {};

---@type RegrowthDataValidation
Regrowth.Data.Validation = Validation;

local function isValidSystemSchema(systemData)
    local function isValidSystemUserSchema(systemUserData)
        if type(systemUserData.id) ~= "number" then
            return false;
        end

        if type(systemUserData.name) ~= "string" then
            return false;
        end
    end

    if type(systemData) ~= "table" then
        return false;
    end

    if not (systemData.data_generated and systemData.user) then
        return false;
    end

    if type(systemData.data_generated) ~= "string" then
        return false;
    end

    if type(systemData.user) ~= "table" then
        return false;
    end

    if not isValidSystemUserSchema(systemData.user) then
        return false;
    end

    return true;
end

local function isValidPrioritiesSchema(prioritiesData)
    local function isValidPrioritiesIndexSchema(prioritiesIndexData)
        if type(prioritiesIndexData.id) ~= "number" then
            return false;
        end

        if type(prioritiesIndexData.name) ~= "string" then
            return false;
        end

        if type(prioritiesIndexData.icon) ~= "string" or type(prioritiesIndexData.icon) ~= "nil" then
            return false;
        end
    end

    if not Regrowth:isArray(prioritiesData) then
        return false;
    end

    local idx = 0;

    for _ in pairs(prioritiesData) do
        idx = idx + 1;

        if not isValidPrioritiesIndexSchema(prioritiesData[idx]) then
            return false;
        end
    end

    return true;
end

local function isValidItemsSchema(itemsData)
    local function isValidItemsIndexSchema(itemsIndexData)
        local function isValidItemsIndexPrioritySchema(itemsIndexPriorityData)
            if type(itemsIndexPriorityData.priority_id) ~= "number" then
                return false;
            end

            if type(itemsIndexPriorityData.weight) ~= "number" then
                return false;
            end
        end

        if type(itemsIndexData.item_id) ~= "number" then
            return false;
        end

        if type(itemsIndexData.notes) ~= "string" then
            return false;
        end

        if not Regrowth:isArray(itemsIndexData.priorities) then
            return false;
        end

        local idx = 0;

        for _ in pairs(itemsIndexData.priorities) do
            idx = idx + 1;

            if not isValidItemsIndexPrioritySchema(itemsIndexData.priorities[idx]) then
                return false;
            end
        end
    end

    if not Regrowth:isArray(itemsData) then
        return false;
    end

    local idx = 0;

    for _ in pairs(itemsData) do
        idx = idx + 1;

        if not isValidItemsIndexSchema(itemsData[idx]) then
            return false;
        end
    end

    return true;
end

local function isValidSchema(inputData)
    if type(inputData) ~= "table" then
        return false;
    end

    if not (inputData.system and inputData.priorities and inputData.items) then
        return false;
    end

    if not isValidSystemSchema(inputData.system) then
        return false;
    end

    if not isValidPrioritiesSchema(inputData.priorities) then
        return false;
    end

    if not isValidItemsSchema(inputData.items) then
        return false;
    end

    return true;
end

function Validation:IsValidInput(inputData)
    return isValidSchema(inputData);
end
