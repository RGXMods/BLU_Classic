--=====================================================================================
-- BLU_Classic - data/ui/general.lua
-- General page. Layout mirrors BLU / BLU Forever general.lua: title bar, intro,
-- left column (Core) and right column (About). Only options that
-- exist in BLU_Classic are shown.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

local function CreateCheckbox(parent, text, x, y, checked, onClick, tooltip)
    local checkbox = Design:CreateCheckbox(parent, text, tooltip)
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.check:SetChecked(checked)
    checkbox.check:SetScript("OnClick", onClick)
    return checkbox
end

function BLU.CreateGeneralPanel(panel)
    BLU:PrintDebug("[Options/General] Creating General panel")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(Design.Rgba("background", 0.35))

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(Design.Backdrops.Solid)
    titleBar:SetBackdropColor(Design.Rgba("surface", 0.95))
    titleBar:SetBackdropBorderColor(Design.Rgba("border", 1))

    local titleIcon = titleBar:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(24, 24)
    titleIcon:SetPoint("LEFT", 10, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_08")

    local titleLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleLabel:SetText("|cff05dffaGeneral|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(Design.Rgb("subtext"))
    intro:SetText("Configure BLU Classic's core behavior.")

    if not BLU.db then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -102)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        return
    end

    local profile = BLU.db

    -- Left column: Core
    local coreSection = Design:CreateSection(content, "Core", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -102)
    coreSection:SetPoint("TOPRIGHT", content, "TOP", -12, -102)
    coreSection:SetHeight(112)

    CreateCheckbox(coreSection.content, "Show welcome message", 4, -6, profile.showWelcomeMessage ~= false, function(self)
        local checked = self:GetChecked() and true or false
        profile.showWelcomeMessage = checked
        BLU.showWelcomeMessage = checked
    end, "Shows BLU's startup message after login or reload.")

    CreateCheckbox(coreSection.content, "Show minimap icon", 4, -32, profile.classicMinimapIconEnabled ~= false, function(self)
        BLU:ToggleMinimapIcon(self:GetChecked() and true or false)
    end, "Shows a BLU button on the minimap. Left-click opens the options panel; drag to reposition; Ctrl+Right-click hides it (/blu icon on restores it).")

    -- Right column: About
    local aboutSection = Design:CreateSection(content, "About", "Interface\\Icons\\INV_Misc_Book_09")
    aboutSection:SetPoint("TOPLEFT", content, "TOP", 12, -102)
    aboutSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -102)
    aboutSection:SetHeight(204)

    local aboutVersion = aboutSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aboutVersion:SetPoint("TOPLEFT", 8, -8)
    aboutVersion:SetText("Version |cff05dffa" .. tostring(BLU.VersionNumber or "?") .. "|r")

    local aboutCommands = aboutSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    aboutCommands:SetPoint("TOPLEFT", aboutVersion, "BOTTOMLEFT", 0, -10)
    aboutCommands:SetPoint("RIGHT", aboutSection.content, "RIGHT", -8, 0)
    aboutCommands:SetJustifyH("LEFT")
    aboutCommands:SetWordWrap(true)
    aboutCommands:SetTextColor(Design.Rgb("subtext"))
    aboutCommands:SetText(
        "|cff05dffa/blu|r  Open these options|n" ..
        "|cff05dffa/blu icon on|off|r  Show or hide the minimap icon|n" ..
        "|cff05dffa/blu debug|r  Toggle debug mode|n" ..
        "|cff05dffa/blu welcome|r  Toggle the welcome message|n" ..
        "|cff05dffa/blu help|r  List commands"
    )

    return content
end
