---@type Regrowth
local _, Regrowth = ...;

---@class Frames
---@field ImportFrame Frame
---@field CommunitiesUiButtonFrame Frame
local Frames = {
    _initialized = false,
};

---@type Frames
Regrowth.Frames = Frames;

function Frames:_init()
    if (self._initialized) then
        return;
    end

    self.ImportFrame = Frames:CreateImportFrame();
    self.CommunitiesUiButtonFrame = Frames:CreateCommunitiesButtonFrame();

    self._initialized = true;
end

function Frames:CreateImportFrame()
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
        tile = true, tileSize = 32, edgeSize = 32,
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
                for _ in pairs(Regrowth_Data) do count = count + 1 end
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

function Frames:CreateCommunitiesButtonFrame()
    local communitiesButtonFrame = CreateFrame( "Button" , "Regrowth_CommunitiesButton" , CommunitiesFrame , "UIPanelButtonTemplate" );
    -- communitiesButtonFrame:Hide();
    
    communitiesButtonFrame.Text = communitiesButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontWhiteTiny");
    communitiesButtonFrame.Text:SetPoint("CENTER", communitiesButtonFrame);
    communitiesButtonFrame.Text:SetText("Clicky");

    communitiesButtonFrame:SetSize(120, 120);
    communitiesButtonFrame:SetPoint("RIGHT");

    communitiesButtonFrame:SetScript("OnClick", function (_, button)
        if button == "LeftButton" then
            Regrowth.Commands:call("openimport");
        end
    end);

    return communitiesButtonFrame;
end
