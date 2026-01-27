---@type Regrowth
local _, Regrowth = ...;

---@class Frames
---@field UIFrame string
local Frames = {
    _initialized = false,
    UIFrame = "closed",
    AuthUsers = "Khamira,Kyukon"
};

---@type Frames
Regrowth.Frames = Frames;

local function SendDataSync()
    Regrowth.Commands:call("senddatasync");
end

local function UpdateLocalLootCouncil(lootCouncil)
    Regrowth.Data:UpdateLocalDataAndSave(lootCouncil, "LootCouncil");
end

local function UpdateLocalData(importData)
    Regrowth.Data:UpdateLocalDataAndSaveFromImport(importData);
end

local function CreateMainMenuTab(container)
    local mainMenuHeading = Regrowth.AceGUI:Create("Heading");
    mainMenuHeading:SetText("Regrowth Loot Tool");
    mainMenuHeading:SetFullWidth(true);
    container:AddChild(mainMenuHeading);

    local mainMenuIntro = Regrowth.AceGUI:Create("Label");
    mainMenuIntro:SetText("Addon is currently still in development. Features may not work as expected.");
    mainMenuIntro:SetFullWidth(true);
    container:AddChild(mainMenuIntro);

    local mainMenuCredit = Regrowth.AceGUI:Create("Label");
    mainMenuCredit:SetText("Addon implementation by Amy. Addon protoype and design by SoulJuice. <3");
    mainMenuCredit:SetFullWidth(true);
    container:AddChild(mainMenuCredit);
end

local function CreateDataSyncTab(container)
    local dataSyncHeading = Regrowth.AceGUI:Create("Heading");
    dataSyncHeading:SetText("Data Sync");
    dataSyncHeading:SetFullWidth(true);
    container:AddChild(dataSyncHeading);

    local desc = Regrowth.AceGUI:Create("Label");
    desc:SetText("Send local data to all valid receivers.");
    desc:SetFullWidth(true);
    container:AddChild(desc);

    local syncDataBtn = Regrowth.AceGUI:Create("Button");
    syncDataBtn:SetText("Send.");
    syncDataBtn:SetWidth(200);
    syncDataBtn:SetCallback("OnClick", function()
        SendDataSync();
    end);
    container:AddChild(syncDataBtn);
end

local function CreateImportDataTab(container)
    local importDataHeading = Regrowth.AceGUI:Create("Heading");
    importDataHeading:SetText("Import Data");
    importDataHeading:SetFullWidth(true);
    container:AddChild(importDataHeading);

    local importDataEb = Regrowth.AceGUI:Create("MultiLineEditBox");
    importDataEb:SetFullWidth(true);
    importDataEb:SetNumLines(20);
    importDataEb:SetLabel("");

    local importDataBtn = importDataEb.button;
    importDataBtn:SetText("Save");
    importDataBtn:SetScript("OnClick", function()
        UpdateLocalData(importDataEb:GetText());
    end);

    container:AddChild(importDataEb);
end

local function CreateLootCouncilTab(container)
    local lootCouncilHeading = Regrowth.AceGUI:Create("Heading");
    lootCouncilHeading:SetText("Loot Council");
    lootCouncilHeading:SetFullWidth(true);
    container:AddChild(lootCouncilHeading);

    local lootCouncilLbl = Regrowth.AceGUI:Create("Label");
    lootCouncilLbl:SetText("By default, all officers in the guild will be considered part of the loot council.\n\nOthers can be added to receive data, but will NOT be able to send data. \n\n");
    lootCouncilLbl:SetFullWidth(true);
    container:AddChild(lootCouncilLbl);

    local lootCouncilAdditionalHeading = Regrowth.AceGUI:Create("Heading");
    lootCouncilAdditionalHeading:SetText("Additional Members");
    lootCouncilAdditionalHeading:SetFullWidth(true);
    container:AddChild(lootCouncilAdditionalHeading);

    local lootCouncilAdditionalLbl = Regrowth.AceGUI:Create("Label");
    lootCouncilAdditionalLbl:SetText("Additional character names. Comma separated e.g. \"Nex, Juice\"");
    lootCouncilAdditionalLbl:SetFullWidth(true);
    container:AddChild(lootCouncilAdditionalLbl);

    local lootCouncilAdditionalList = Regrowth.AceGUI:Create("EditBox");
    lootCouncilAdditionalList:SetFullWidth(true);
    lootCouncilAdditionalList:SetMaxLetters(0);
    lootCouncilAdditionalList:SetText(Regrowth.Data.Storage.LootCouncil.data);
    container:AddChild(lootCouncilAdditionalList);

    local lootCouncilSaveBtn = Regrowth.AceGUI:Create("Button");
    lootCouncilSaveBtn:SetText("Save");
    lootCouncilSaveBtn:SetCallback("OnClick", function()
        UpdateLocalLootCouncil(lootCouncilAdditionalList:GetText());
    end);
    container:AddChild(lootCouncilSaveBtn);
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
    if group == "lootCouncil" then
        return CreateLootCouncilTab(container);
    end
end

local function CreateTabs()
    if Regrowth.User.canSendUpdates then
        return {
            { text="Main Menu", value="mainMenu" },
            { text="Data Sync", value="dataSync" },
            { text="Import data", value="importData" },
            { text="Loot Council", value="lootCouncil" },
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
