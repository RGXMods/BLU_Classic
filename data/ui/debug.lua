--=====================================================================================
-- BLU_Classic - data/ui/debug.lua
-- Debug page. Mirrors BLU / BLU Forever: title bar with the master ON/OFF switch,
-- intro line, then a card of diagnostics. BLU_Classic has a single debug switch, so
-- the Forever "Debug Scopes" list is replaced by client and addon details.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

local VERSION_LABELS = {
    vanilla = "Classic Era",
    tbc = "TBC Anniversary",
    wrath = "Wrath of the Lich King Classic",
    cata = "Cataclysm Classic",
    mists = "Mists of Pandaria Classic",
}

local function CreateToggleState(parent, enabled)
    local switchFrame = CreateFrame("Frame", nil, parent)
    switchFrame:SetSize(44, 20)

    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(18, 18)
    toggle:EnableMouse(true)

    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    toggleBg:SetVertexColor(1, 1, 1, 1)

    local function update(newState)
        toggle:ClearAllPoints()
        if newState then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
            switchBg:SetVertexColor(unpack(Design.Colors.Primary))
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
            switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
        end
    end

    update(enabled == true)
    return switchFrame, toggle, update
end

local function Line(parent, anchor, label, value)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
    fs:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetText("|cff9fb3c8" .. label .. "|r  " .. tostring(value))
    return fs
end

function BLU.CreateDebugPanel(panel)
    BLU:PrintDebug("[Options/Debug] Creating Debug panel")

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local pageBg = content:CreateTexture(nil, "BACKGROUND")
    pageBg:SetAllPoints()
    pageBg:SetColorTexture(0.04, 0.06, 0.08, 0.35)

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(Design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_03")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffaDebug Options|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(0.6, 0.66, 0.72)
    intro:SetText("Print diagnostic messages to chat and review client details for bug reports.")

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", titleBar, "RIGHT", -60, 0)

    if not BLU.db then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -102)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        return content
    end

    local profile = BLU.db
    local switchFrame, toggle, updateToggle = CreateToggleState(titleBar, profile.debugMode == true)
    switchFrame:SetPoint("RIGHT", -10, 0)

    local function RefreshMasterToggle()
        local enabled = profile.debugMode == true
        updateToggle(enabled)
        status:SetText(enabled and "|cff00ff00ON|r" or "|cffff0000OFF|r")
    end

    toggle:SetScript("OnClick", function()
        local enabled = not (profile.debugMode == true)
        profile.debugMode = enabled
        BLU.debugMode = enabled
        RefreshMasterToggle()
    end)
    RefreshMasterToggle()

    -- Diagnostics card
    local section = Design:CreateSection(content, "Diagnostics", "Interface\\Icons\\INV_Misc_Gear_03")
    section:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -48)
    section:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -10, -48)
    section:SetHeight(250)

    local _, buildNumber, _, interfaceVersion = GetBuildInfo()
    local gameVersion = BLU:GetGameVersion()
    local RGX = _G.RGXFramework

    local anchor = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    anchor:SetPoint("TOPLEFT", 8, -2)
    anchor:SetText("|cff9fb3c8Addon|r  BLU Classic " .. tostring(BLU.VersionNumber or "?"))
    local last = anchor
    last = Line(section.content, last, "Client", (VERSION_LABELS[gameVersion] or tostring(gameVersion)) .. "  (interface " .. tostring(interfaceVersion) .. ")")
    last = Line(section.content, last, "RGX-Framework", RGX and tostring(RGX.version or "loaded") or "|cffff6666not loaded|r")
    last = Line(section.content, last, "Active profile", profile.GetActiveProfile and profile:GetActiveProfile() or "Default")

    local errorCount = 0
    local errorNames = {}
    for tabName in pairs(BLU._panelErrors or {}) do
        errorCount = errorCount + 1
        errorNames[#errorNames + 1] = tabName
    end
    table.sort(errorNames)
    last = Line(section.content, last, "Options page errors",
        errorCount == 0 and "|cff00ff00none|r" or ("|cffff6666" .. table.concat(errorNames, ", ") .. "|r"))

    local helpButton = Design:CreateActionButton(section.content, "Show Commands", 120, 22,
        "Show Commands", "Prints the list of /blu commands to chat.")
    helpButton:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -16)
    helpButton:SetScript("OnClick", function() BLU:DisplayBLUHelp() end)

    local reloadButton = Design:CreateActionButton(section.content, "Reload UI", 120, 22,
        "Reload UI", "Reloads the interface. Useful after changing debug mode.")
    reloadButton:SetPoint("LEFT", helpButton, "RIGHT", 8, 0)
    reloadButton:SetScript("OnClick", function() ReloadUI() end)

    return content
end
