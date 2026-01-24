---@type Regrowth
local _, Regrowth = ...;

---@type Data
local Actions = Regrowth.Data.Constants.Comm.Actions or {};

---@class Actions
local CommActions = {
    [Actions.nex] = function(Message)
        Regrowth:success("Message received: " .. Message.content);
    end,
    [Actions.updateData] = function(Message)
        Regrowth:success("Updating your loot data");

        Regrowth_Item_Data = Message.content
    end,
    [Actions.updatePlayers] = function(Message)
        Regrowth:success("Updating your player data");

        Regrowth_Players = Message.content
    end,
    [Actions.updateRecipes] = function(Message)
        Regrowth:success("Updating your recipe data");
        
        Regrowth_Recipes = Message.content
    end,
};

---@class Actions
Regrowth.Comm.Actions = CommActions;
