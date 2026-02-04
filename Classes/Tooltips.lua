---@type Regrowth
local _, Regrowth = ...;

---@class Tooltips
local Tooltips = {
    _initialized = false,
};

---@type Tooltips
Regrowth.Tooltips = Tooltips;

local function AddRegrowthItemDataToTooltip(tooltip)
    local _, link = tooltip:GetItem();
    if not link then
        return;
    end

    local itemID = C_Item.GetItemInfoInstant(link);
    if not itemID then
        return;
    end

    local itemDataById = Regrowth:findByKeyInArray(Regrowth_Data.Items.data, "item_id", itemID);

    if not itemDataById then
        return;
    end

    tooltip:AddLine(" ");
    tooltip:AddLine("Regrowth Bias:", 0.1, 1, 0.6);
    tooltip:AddLine(itemDataById.text, 1, 1, 1, true);
end

local function AddRegrowthPlayerDataToTooltip(tooltip)
    if not IsInRaid() then
        return;
    end

    local name = tooltip:GetUnit();

    local pData = Regrowth_Data.Players.data;

    local playerData = pData[name];
    if playerData then
        tooltip:AddLine(" ");
        tooltip:AddLine("Guild Raid Stats:", 0.1, 1, 0.6);
        tooltip:AddDoubleLine("Attendance:", playerData.att or "N/A", 1, 1, 1, 1, 1, 1);
        local lootCount = playerData.loot or 0;
        local lastWin = playerData.last or "N/A";
        local lootText = string.format("%d Won (%s)", lootCount, lastWin);
        tooltip:AddDoubleLine("MS Loot:", lootText, 1, 1, 1, 1, 1, 1);
    end
end

function Tooltips:_init()
    if self._initialized then
        return;
    end

    GameTooltip:HookScript("OnTooltipSetItem", AddRegrowthItemDataToTooltip);
    -- GameTooltip:HookScript("OnTooltipSetUnit", AddRegrowthPlayerDataToTooltip);

    self._initialized = true;
end
