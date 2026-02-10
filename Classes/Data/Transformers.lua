---@type Regrowth
local _, Regrowth = ...;

---@class Regrowth.Data.Transformers
local Transformers = {};

---@type Regrowth.Data.Transformers
Regrowth.Data.Transformers = Transformers;

local function GetPriorityForId(priorityData)
    local pID = priorityData.priority_id;
    local weight = priorityData.weight;

    if Regrowth:empty(Regrowth_Data.Priorities.data) then
        return {
            priority_id = pID,
            weight = weight,
            name = "MS > OS",
        };
    end

    local priority = Regrowth:findByKeyInArray(Regrowth_Data.Priorities.data, "id", pID);

    return {
        priority_id = pID,
        weight = weight,
        name = priority.name,
        icon = priority.icon,
    };
end

local function CreatePriorityTextFromWeightings(priorityData)
    local text = "";
    local prevWeight = -1;

    for idx in ipairs(priorityData) do
        if text == "" then
            text = priorityData[idx].name;
        else
            if prevWeight == priorityData[idx].weight then
                text = text .. " = " .. priorityData[idx].name;
            else
                text = text .. " > " .. priorityData[idx].name;
            end
        end

        prevWeight = priorityData[idx].weight;
    end

    return text;
end

local function TransformItemsDataWithPriorities(itemsData)
    for iIdx, itemData in ipairs(itemsData) do
        for pIdx, priorityData in ipairs(itemData.priorities) do
            local mappedPriority = GetPriorityForId(priorityData);

            itemsData[iIdx].priorities[pIdx] = mappedPriority
        end

        table.sort(itemsData[iIdx].priorities, function(k1, k2)
            return k1.weight < k2.weight;
        end);

        itemsData[iIdx].text = CreatePriorityTextFromWeightings(itemsData[iIdx].priorities);
        itemsData[iIdx].priorities = nil;
    end

    return itemsData;
end

local function TransformLootCouncilToCSL(lootCouncilData)
    local csl = nil;

    for _, lootCouncilData in ipairs(lootCouncilData) do
        if not csl then
            csl = lootCouncilData.name;
        else
            csl = csl .. ", " .. lootCouncilData.name;
        end
    end

    return csl;
end

function Transformers:TransformItemsData(itemsData)
    return TransformItemsDataWithPriorities(itemsData);
end

function Transformers:TransformLootCouncillors(lootCouncilData)
    return TransformLootCouncilToCSL(lootCouncilData);
end
