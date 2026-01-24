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

local function UpdateAuthUsers(authUsers)
    Regrowth.Data:UpdateLocalDataAndSave(authUsers, "AuthorisedUsers");
end

local function UpdateAllData(importData)
    Regrowth.Data:UpdateLocalDataAndSaveFromImport(importData);
end

local function CreateMainMenuTab(container)
    local desc = Regrowth.AceGUI:Create("Label");
    desc:SetText("Main Menu");
    desc:SetFullWidth(true);
    container:AddChild(desc);

    local button = Regrowth.AceGUI:Create("Button");
    button:SetText("Main Menu button");
    button:SetWidth(200);
    container:AddChild(button);
end

local function CreateDataSyncTab(container)
    local desc = Regrowth.AceGUI:Create("Label");
    desc:SetText("Data Sync");
    desc:SetFullWidth(true);
    container:AddChild(desc);

    local button = Regrowth.AceGUI:Create("Button");
    button:SetText("Data Sync button");
    button:SetWidth(200);
    container:AddChild(button);
end

local function CreateImportDataTab(container)
    local importDataEb = Regrowth.AceGUI:Create("MultiLineEditBox");
    importDataEb:SetFullWidth(true);
    importDataEb:SetNumLines(20);
    importDataEb:SetLabel("Import Data");

    local importDataBtn = importDataEb.button;
    importDataBtn:SetText("Save");
    importDataBtn:SetScript("OnClick", function()
        UpdateAllData(importDataEb:GetText());
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
        UpdateAuthUsers(authUsersEb:GetText());
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

local function CreateMainUI()
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

local function CreateCommunitiesButtonFrame()
    local communitiesButtonFrame = CreateFrame( "Button" , "Regrowth_CommunitiesButton" , CommunitiesFrame.GuildInfoTab , "UIPanelButtonTemplate" );
    -- communitiesButtonFrame:Hide();

    communitiesButtonFrame.Text = communitiesButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontWhiteTiny");
    communitiesButtonFrame.Text:SetPoint("CENTER", communitiesButtonFrame);
    communitiesButtonFrame.Text:SetText("");

    communitiesButtonFrame:SetSize(40, 40);
    communitiesButtonFrame:SetPoint("TOP", 2, -200);
    communitiesButtonFrame:SetNormalTexture("Interface\\AddOns\\RegrowthLootTool\\Icons\\rlt");

    communitiesButtonFrame:SetScript("OnClick", function (_, button)
        if button == "LeftButton" then
            if Regrowth.Frames.UIFrame == "closed" then
                Regrowth.Frames.UIFrame = CreateMainUI();
                Regrowth.Frames.UIFrame = "open";
            end
        end
    end);

    return communitiesButtonFrame;
end

function Frames:_init()
    if (self._initialized) then
        return;
    end

    -- self.UIFrame = CreateMainUI();
    self.CommunitiesUiButtonFrame = CreateCommunitiesButtonFrame();

    self._initialized = true;
end

function CreateImportFrame()
    --- Main UI
    local importFrame = CreateFrame("Frame", "Regrowth_ImportFrame", UIParent, "BackdropTemplate");
    importFrame:Hide();
    importFrame:SetSize(600, 500);
    importFrame:SetPoint("CENTER");
    importFrame:SetFrameStrata("DIALOG");
    importFrame:SetMovable(true);
    importFrame:EnableMouse(true);
    importFrame:RegisterForDrag("LeftButton");
    importFrame:SetScript("OnDragStart", importFrame.StartMoving);
    importFrame:SetScript("OnDragStop", importFrame.StopMovingOrSizing);
    importFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    });
    importFrame:SetBackdropColor(0, 0, 0, 0.95);

    importFrame.Header = importFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    importFrame.Header:SetPoint("TOP", 0, -20);
    importFrame.Header:SetText("Regrowth Data Sync");

    importFrame.Scroll = CreateFrame("ScrollFrame", "Regrowth_ImportFrame_Scroll", importFrame, "UIPanelScrollFrameTemplate")
    importFrame.Scroll:SetSize(540, 350)
    importFrame.Scroll:SetPoint("TOP", 0, -85)

    importFrame.EditBox = CreateFrame("EditBox", "Regrowth_ImportFrame_Edit", importFrame.Scroll)
    importFrame.EditBox:SetMultiLine(true)
    importFrame.EditBox:SetMaxLetters(0)
    importFrame.EditBox:SetFontObject("ChatFontNormal")
    importFrame.EditBox:SetWidth(530)
    importFrame.EditBox:SetScript("OnEscapePressed", function() importFrame:Hide() end)
    importFrame.Scroll:SetScrollChild(importFrame.EditBox)

    --- Buttons
    importFrame.SyncButton = CreateFrame("Button", "Regrowth_ImportFrame_SyncButton", importFrame, "GameMenuButtonTemplate")
    importFrame.SyncButton:SetSize(120, 35)
    importFrame.SyncButton:SetPoint("BOTTOMLEFT", 100, 20)
    importFrame.SyncButton:SetText("Import Data")
    importFrame.SyncButton:SetScript("OnClick", function()
        local data = importFrame.EditBox:GetText();

        if not data or data == "" then
            return;
        end

        local dataCb, loadErr = loadstring(data);

        if dataCb then
            local ok, execErr = pcall(dataCb);
            if ok then
                local count = 0
                for _ in pairs(Regrowth_Item_Data) do count = count + 1 end
                Regrowth:success("Sync complete - " .. count .. " items loaded.");
                importFrame:Hide();
            else
                Regrowth:error(tostring(execErr));
            end
        else
            Regrowth:error(tostring(loadErr));
        end
    end)

    importFrame.ShareButton = CreateFrame("Button", "Regrowth_ImportFrame_ShareButton", importFrame, "GameMenuButtonTemplate")
    importFrame.ShareButton:SetSize(120, 35);
    importFrame.ShareButton:SetPoint("BOTTOM", 0, 20);
    importFrame.ShareButton:SetText("Share Data");
    importFrame.ShareButton:SetScript("OnClick", function()
        Regrowth.Commands:call("senddataupdate");
        Regrowth.Commands:call("sendplayerupdate");
        Regrowth.Commands:call("sendrecipeupdate");
    end);

    importFrame.ClearButton = CreateFrame("Button", "Regrowth_ImportFrame_ClearButton", importFrame, "GameMenuButtonTemplate")
    importFrame.ClearButton:SetSize(120, 35);
    importFrame.ClearButton:SetPoint("BOTTOMRIGHT", -100, 20);
    importFrame.ClearButton:SetText("Clear All");
    importFrame.ClearButton:SetScript("OnClick", function()
        importFrame.EditBox:SetText("");
        importFrame.EditBox:SetFocus();
        Regrowth:success("Import box cleared.");
    end);

    importFrame.CloseButton = CreateFrame("Button", nil, importFrame, "UIPanelCloseButton");
    importFrame.CloseButton:SetPoint("TOPRIGHT", -5, -5);

    return importFrame;
end


