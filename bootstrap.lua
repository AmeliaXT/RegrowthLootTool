-- Regrowth Loot Tool - Core Logic
-- Version 1.14 (Robust Identification & TBC Fix)

---@class Regrowth
local Regrowth;

---@type string
local appName;
appName, Regrowth = ...;

-- Initialize Persistent Storage
Regrowth_Data = Regrowth_Data or {};

Regrowth.name = appName;
Regrowth._initialized = false;
Regrowth.EventFrame = nil;

Regrowth.Ace = LibStub("AceAddon-3.0"):NewAddon(Regrowth.name, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0");

---@type AceGUI-3.0
Regrowth.AceGUI = LibStub("AceGUI-3.0");

Regrowth.Settings = {
    DebugMode = "on"
};

function Regrowth:_init()
    self.Data:_init();
    self.Commands:_init();
    self.Frames:_init();
    self.Tooltips:_init();
    self.User:_init();
    self.Comm:_init();
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

Regrowth.EventFrame = CreateFrame("FRAME", "Regrowth_EventFrame");
Regrowth.EventFrame:RegisterEvent("ADDON_LOADED");
Regrowth.EventFrame:SetScript("OnEvent", function (...) Regrowth:bootstrap(...); end);
