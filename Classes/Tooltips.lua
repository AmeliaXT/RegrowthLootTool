---@type Regrowth
local _, Regrowth = ...;

---@class Tooltips
local Tooltips = {
    _initialized = false,
};

---@type Tooltips
Regrowth.Tooltips = Tooltips;

local function GetItemId(tooltip)
    local _, link = tooltip:GetItem();
    if not link then
        return;
    end

    local itemID = C_Item.GetItemInfoInstant(link);
    if not itemID then
        return;
    end

    return itemID;
end

local function AddWishlistDataToTooltip(tooltip)
    if not Regrowth_Config.TooltipToggles["wishlist"] and not IsInRaid() then
        return;
    end

    local itemID = GetItemId(tooltip);

    if not itemID then
        return
    end

    local wanted = Regrowth:findByKeyInArray(Regrowth_Data.Wishlists.data, "itemId", itemID);

    if wanted then
        tooltip:AddLine(" ");
        tooltip:AddLine("Wanted by:", 0.1, 1, 0.6);

        local wantedBy = wanted.wantedBy;

        for _, wantedData in ipairs(wantedBy) do
            tooltip:AddLine(wantedData.name, 1, 1, 1);
        end
    end
end

local function AddRegrowthItemDataToTooltip(tooltip)
    if not Regrowth_Config.TooltipToggles["bias"] and not IsInRaid() then
        return;
    end

    local itemID = GetItemId(tooltip);

    if not itemID then
        return
    end

    local itemDataById = Regrowth:findByKeyInArray(Regrowth_Data.Items.data, "item_id", itemID);

    
    if itemDataById then
        tooltip:AddLine(" ");
        tooltip:AddLine("Regrowth Bias:", 0.1, 1, 0.6);
        tooltip:AddLine(itemDataById.text, 1, 1, 1, true);
    end
end

local function AddLootReceivedPlayerDataToTooltip(tooltip, name)
    local receivedDataByName = Regrowth:findByKey(Regrowth_Data.LootReceived.data, name);

    if not receivedDataByName then
        return;
    end

    local lootCount = table.getn(receivedDataByName) or 0;
    tooltip:AddDoubleLine("Total Loot:", lootCount, 0.1, 1, 0.6, 1, 1, 1);

    if lootCount > 0 then
        local lastWin = Regrowth:findByKey(receivedDataByName[1].when, "date");
        tooltip:AddDoubleLine("Last Win:", lastWin, 0.1, 1, 0.6, 1, 1, 1);
    end

end

local function AddRegrowthPlayerDataToTooltip(tooltip)
    if not Regrowth_Config.TooltipToggles["players"] and not IsInRaid() then
        return;
    end

    local name = tooltip:GetUnit();

    local playerDataByName = Regrowth:findByKeyInArray(Regrowth_Data.Players.data, "name", name);

    if not playerDataByName then
        return;
    end

    local attendance = playerDataByName.attendance.percentage and playerDataByName.attendance.percentage .. "%" or "N/A";

    tooltip:AddLine(" ");
    tooltip:AddLine("Guild Raid Stats:", 0.1, 1, 0.6);
    tooltip:AddDoubleLine("Attendance:", attendance, 1, 1, 1, 1, 1, 1);

    AddLootReceivedPlayerDataToTooltip(tooltip, name);
end

function Tooltips:_init()
    if self._initialized then
        return;
    end

    GameTooltip:HookScript("OnTooltipSetItem", AddRegrowthItemDataToTooltip);
    GameTooltip:HookScript("OnTooltipSetItem", AddWishlistDataToTooltip);
    GameTooltip:HookScript("OnTooltipSetUnit", AddRegrowthPlayerDataToTooltip);

    self._initialized = true;
end
