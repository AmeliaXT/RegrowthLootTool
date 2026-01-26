---@type Regrowth
local _, Regrowth = ...;

---@class Frames
---@field UIFrame string
local Frames = {
    _initialized = false,
    UIFrame = "closed",
    AuthUsers = "Amy,Juice"
};

---@type Frames
Regrowth.Frames = Frames;

local function SendDataSync()
    Regrowth.Commands:call("senddatasync");
end

local function UpdateLocalAuthUsers(authUsers)
    Regrowth.Data:UpdateLocalDataAndSave(authUsers, "AuthorisedUsers");
end

local function UpdateLocalData(importData)
    Regrowth.Data:UpdateLocalDataAndSaveFromImport(importData);
end

local function CreateMainMenuTab(container)
    local desc = Regrowth.AceGUI:Create("Label");
    desc:SetText("Main Menu");
    desc:SetFullWidth(true);
    container:AddChild(desc);

    local msg = Regrowth.AceGUI:Create("Label");
    msg:SetText("Addon is currently still in development. Features may not work as expected.");
    msg:SetFullWidth(true);
    container:AddChild(msg);
end

local function CreateDataSyncTab(container)
    local desc = Regrowth.AceGUI:Create("Label");
    desc:SetText("Data Sync");
    desc:SetFullWidth(true);
    container:AddChild(desc);

    local syncDataBtn = Regrowth.AceGUI:Create("Button");
    syncDataBtn:SetText("Test sending data.");
    syncDataBtn:SetWidth(200);
    syncDataBtn:SetCallback("OnClick", function()
        SendDataSync();
    end);
    container:AddChild(syncDataBtn);
end

local function CreateImportDataTab(container)
    local importDataEb = Regrowth.AceGUI:Create("MultiLineEditBox");
    importDataEb:SetFullWidth(true);
    importDataEb:SetNumLines(20);
    importDataEb:SetLabel("Import Data");

    local importDataBtn = importDataEb.button;
    importDataBtn:SetText("Save");
    importDataBtn:SetScript("OnClick", function()
        UpdateLocalData(importDataEb:GetText());
    end);

    container:AddChild(importDataEb);
end

local function CreateAuthUsersTab(container)
    local authUsersLbl = Regrowth.AceGUI:Create("Label");
    authUsersLbl:SetText("Authorised Users - CSL");
    authUsersLbl:SetFullWidth(true);
    container:AddChild(authUsersLbl);

    local authUsersEb = Regrowth.AceGUI:Create("EditBox");
    authUsersEb:SetFullWidth(true);
    authUsersEb:SetMaxLetters(0);
    authUsersEb:SetText(Regrowth.Data.Storage.AuthorisedUsers.data);
    container:AddChild(authUsersEb);

    local authUsersBtn = Regrowth.AceGUI:Create("Button");
    authUsersBtn:SetText("Save");
    authUsersBtn:SetCallback("OnClick", function()
        UpdateLocalAuthUsers(authUsersEb:GetText());
    end);
    container:AddChild(authUsersBtn);
end

local function SelectTab(container, _, group)
    container:ReleaseChildren();

    if group == "mainMenu" then
        return CreateMainMenuTab(container);
    end
    if group == "dataSync" then
        return CreateDataSyncTab(container);
    end
    if group == "importData" then
        return CreateImportDataTab(container);
    end
    if group == "authUsers" then
        return CreateAuthUsersTab(container);
    end
end

local function CreateTabs()
    if Regrowth.User.canSendUpdates then
        return {
            { text="Main Menu", value="mainMenu" },
            { text="Data Sync", value="dataSync" },
            { text="Import data", value="importData" },
            { text="Authorised Users", value="authUsers" },
        };
    end

    if Regrowth.User.canReceiveUpdates then
        return {
            { text="Main Menu", value="mainMenu" },
            { text="Data Sync", value="dataSync" },
        };
    end

    return {
        { text="Main Menu", value="mainMenu" },
    }
end

local function CreateCommunitiesButtonFrame()
    local communitiesButtonFrame = CreateFrame( "Button" , "Regrowth_CommunitiesButton" , CommunitiesFrame.GuildInfoTab , "UIPanelButtonTemplate" );
    communitiesButtonFrame.Text = communitiesButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontWhiteTiny");
    communitiesButtonFrame.Text:SetPoint("CENTER", communitiesButtonFrame);
    communitiesButtonFrame.Text:SetText("");

    communitiesButtonFrame:SetSize(40, 40);
    communitiesButtonFrame:SetPoint("TOP", 2, -200);
    communitiesButtonFrame:SetNormalTexture("Interface\\AddOns\\RegrowthLootTool\\Icons\\rlt");

    communitiesButtonFrame:SetScript("OnClick", function (_, button)
        if button == "LeftButton" then
            if Regrowth.Frames.UIFrame == "closed" then
                Regrowth.Frames.UIFrame = Regrowth.Frames:CreateMainUI();
                Regrowth.Frames.UIFrame = "open";
            end
        end
    end);

    return communitiesButtonFrame;
end

function Frames:CreateMainUI()
    local uiFrame = Regrowth.AceGUI:Create("Frame");
    uiFrame:SetTitle("Regrowth Loot Tool");
    uiFrame:SetCallback("OnClose", function(widget)
        Regrowth.AceGUI:Release(widget);
        Regrowth.Frames.UIFrame = "closed";
    end);
    uiFrame:SetLayout("Fill");

    local tabGroup = Regrowth.AceGUI:Create("TabGroup");
    tabGroup:SetLayout("List");
    tabGroup:SetTabs(CreateTabs());
    tabGroup:SetCallback("OnGroupSelected", SelectTab);
    tabGroup:SelectTab("mainMenu");

    uiFrame:AddChild(tabGroup);

    return uiFrame;
end

function Frames:_init()
    if (self._initialized) then
        return;
    end

    self.CommunitiesUiButtonFrame = CreateCommunitiesButtonFrame();

    self._initialized = true;
end
