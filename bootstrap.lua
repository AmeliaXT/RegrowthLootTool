-- Regrowth Loot Tool - Core Logic
-- Version 1.14 (Robust Identification & TBC Fix)

---@class Regrowth
local Regrowth;

---@type string
local appName;
appName, Regrowth = ...;

-- Initialize Persistent Storage
Regrowth_Data = Regrowth_Data or {}
Regrowth_Recipes = Regrowth_Recipes or {}
Regrowth_Players = Regrowth_Players or {}

Regrowth.name = appName;
Regrowth._initialized = false;
Regrowth.EventFrame = nil;

Regrowth.Ace = LibStub("AceAddon-3.0"):NewAddon(Regrowth.name, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0");

function Regrowth:_init()
    -- self.DB:_init();
    self.Commands:_init();
    self.Frames:_init();
    self.User:_init();
    self.Comm:_init();

    self:hookItemTooltips();
    self:hookPlayerTooltips();
end

function Regrowth:bootstrap(_, _, addonName)
    if (self._initialized) then
        return;
    end

    if (addonName ~= self.name) then
        return;
    end

    self.EventFrame:UnregisterEvent("ADDON_LOADED");

    self:_init();

    Regrowth:success("Ready. Run /regrowth to start.");

    self._initialized = true;
end

local function ProcessItemTooltip(tooltip)
    local _, link = tooltip:GetItem();

    if not link then
        return;
    end

    local itemID = C_Item.GetItemInfoInstant(link);

    if not itemID then
        return;
    end

    -- 1. Check Loot Priority
    if Regrowth_Data[itemID] then
        tooltip:AddLine(" ");
        tooltip:AddLine("Regrowth Bias:", 0.1, 1, 0.6);
        tooltip:AddLine(Regrowth_Data[itemID], 1, 1, 1, true);
    end

    -- 2. Check Recipes
    if Regrowth_Recipes[itemID] then
        tooltip:AddLine(" ");
        tooltip:AddLine("Known By:", 0.1, 1, 0.6);
        tooltip:AddLine(Regrowth_Recipes[itemID], 1, 1, 1, true);
    end
end

local function ProcessUnitTooltip(tooltip)
    if not IsInRaid() then
        return;
    end

    local name = tooltip:GetUnit();

    local playerData = Regrowth_Players[name]
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

function Regrowth:hookItemTooltips()
    GameTooltip:HookScript("OnTooltipSetItem", ProcessItemTooltip);
end

function Regrowth:hookPlayerTooltips()
    GameTooltip:HookScript("OnTooltipSetUnit", ProcessUnitTooltip);
end

Regrowth.EventFrame = CreateFrame("FRAME", "Regrowth_EventFrame");
Regrowth.EventFrame:RegisterEvent("ADDON_LOADED");
Regrowth.EventFrame:SetScript("OnEvent", function (...) Regrowth:bootstrap(...); end);
