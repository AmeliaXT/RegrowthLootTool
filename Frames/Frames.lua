---@type Regrowth
local _, Regrowth = ...;

---@class Frames
local Frames = {};

---@type Frames
Regrowth.Frames = Frames;

function Frames:CreateImportFrame()
    if RegrowthImportFrame then return RegrowthImportFrame end

    local f = CreateFrame("Frame", "RegrowthImportFrame", UIParent, "BackdropTemplate")
    f:SetSize(600, 500)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetBackdropColor(0, 0, 0, 0.95)

    f.Header = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.Header:SetPoint("TOP", 0, -20)
    f.Header:SetText("Regrowth Data Sync")

    local sf = CreateFrame("ScrollFrame", "RegrowthScrollFrame", f, "UIPanelScrollFrameTemplate")
    sf:SetSize(540, 350)
    sf:SetPoint("TOP", 0, -85)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetFontObject("ChatFontNormal")
    eb:SetWidth(530)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    sf:SetScrollChild(eb)
    f.EditBox = eb

    local syncBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    syncBtn:SetSize(120, 35)
    syncBtn:SetPoint("BOTTOMLEFT", 100, 20)
    syncBtn:SetText("Import Data")
    syncBtn:SetScript("OnClick", function()
        local code = eb:GetText()
        if not code or code == "" then return end
        
        local func, err = loadstring(code)
        
        if func then
            local ok, execErr = pcall(func)
            if ok then
                local count = 0
                for _ in pairs(Regrowth_Data) do count = count + 1 end
                print(Regrowth.colour .. ": Sync complete. " .. count .. " items loaded.")
                f:Hide()
            else
                print(Regrowth.colour .. ": |cffef4444Exec Error:|r " .. tostring(execErr))
            end
        else
            print(Regrowth.colour .. ": |cffef4444Import Error:|r " .. tostring(err))
        end
    end)

    local syncBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    syncBtn:SetSize(120, 35)
    syncBtn:SetPoint("BOTTOM", 0, 20)
    syncBtn:SetText("Share Data")
    syncBtn:SetScript("OnClick", function()
        Regrowth.Commands:call("senddataupdate");
        Regrowth.Commands:call("sendplayerupdate");
        Regrowth.Commands:call("sendrecipeupdate");
    end)

    local clearBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    clearBtn:SetSize(120, 35)
    clearBtn:SetPoint("BOTTOMRIGHT", -100, 20)
    clearBtn:SetText("Clear All")
    clearBtn:SetScript("OnClick", function()
        eb:SetText("")
        eb:SetFocus()
        print(Regrowth.colour .. ": Import box cleared.")
    end)

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    return f
end
