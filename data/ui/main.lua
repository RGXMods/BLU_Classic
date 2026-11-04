--=====================================================================================
-- BLU_Classic - data/ui/main.lua
-- Main options panel: header, tab strip, content pages, Settings registration.
-- Mirrors BLU / BLU Forever core/interface/options/main.lua.
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]
local Tabs = BLU.Modules and BLU.Modules["tabs"]

-- Layout Constants
local TAB_BUTTON_WIDTH_CORE = 94

-- Create options module
local Options = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["options"] = Options

local function GetAddOnMetadataSafe(addonName, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, value = pcall(C_AddOns.GetAddOnMetadata, addonName, key)
        return ok and value or nil
    elseif GetAddOnMetadata then
        local ok, value = pcall(GetAddOnMetadata, addonName, key)
        return ok and value or nil
    end
    return nil
end

local OPTIONS_PANEL_NAME = "Better Level-Up! (Classic)"
local OPTIONS_LIST_STYLED_NAME = "|T" .. ADDON_PATH .. "media\\icon:0|t |cff05dffaB|r|cffffffffetter |cff05dffaL|r|cffffffffevel-|cff05dffaU|r|cffffffffp|cff05dffa!|r |cffFFD700(Classic)|r"

function Options:ResolveOptionsCategoryID()
    BLU:PrintDebug("[Options] ResolveOptionsCategoryID called")
    if type(BLU.OptionsCategoryID) == "number" then
        return BLU.OptionsCategoryID
    end

    local category = BLU.OptionsCategory
    if Settings and Settings.GetCategory and BLU.OptionsPanel then
        local settingsCategory = Settings.GetCategory(BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name)
        if not settingsCategory then
            settingsCategory = Settings.GetCategory(BLU.OptionsPanel.name)
        end
        if settingsCategory then
            category = settingsCategory
        end
    end
    if not category then
        return nil
    end

    local categoryID = nil
    if type(category.GetID) == "function" then
        categoryID = category:GetID()
    else
        categoryID = category.ID
    end

    if type(categoryID) ~= "number" and type(category.GetOrder) == "function" then
        local repairedID = category:GetOrder()
        if type(repairedID) == "number" then
            categoryID = repairedID
        end
    end

    if type(categoryID) == "number" then
        BLU.OptionsCategoryID = categoryID
        return categoryID
    end

    return nil
end

-- Create main options panel
function Options:CreateOptionsPanel()
    BLU:PrintDebug("Creating new options panel...")

    if not BLU.db then
        BLU:PrintError("Cannot create options panel: Database not available")
        return nil
    end

    local panel = CreateFrame("Frame", "BLUClassicOptionsPanel", UIParent, "BackdropTemplate")
    panel.name = OPTIONS_PANEL_NAME
    panel.settingsCategoryName = OPTIONS_LIST_STYLED_NAME
    BLU.OptionsPanel = panel

    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    container:SetBackdropColor(Design.Rgba("background", 0.95))
    container:SetBackdropBorderColor(Design.Rgba("border", 1))

    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(52)
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    header:SetBackdropColor(Design.Rgba("surface", 0.95))
    header:SetBackdropBorderColor(Design.Rgba("border", 1))

    local headerAccent = header:CreateTexture(nil, "ARTWORK")
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", 8, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", -8, 0)
    headerAccent:SetColorTexture(unpack(BLU.Modules.design.Colors.Primary))

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(28, 28)
    logo:SetPoint("LEFT", 10, 0)
    logo:SetTexture(ADDON_PATH .. "media\\icon.tga")

    local leftX = 50
    local rightX = -15
    local rowOneY = -14
    local rowTwoY = -26
    local rowThreeY = -38

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", header, "TOPLEFT", leftX, rowOneY)
    title:SetText("|cff05dffaB|r|cffffffffetter |cff05dffaL|r|cffffffffevel-|cff05dffaU|r|cffffffffp|cff05dffa!|r |cffFFD700(Classic)|r")
    title:SetJustifyV("MIDDLE")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("LEFT", header, "TOPLEFT", leftX, rowTwoY)
    subtitle:SetText("Iconic game sounds for WoW Classic")
    subtitle:SetTextColor(Design.Rgb("subtext"))
    subtitle:SetJustifyV("MIDDLE")

    local discord = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    discord:SetPoint("LEFT", header, "TOPLEFT", leftX, rowThreeY)
    discord:SetText("|cff7289daDiscord:|r |cffffd700discord.gg/N7kdKAHVVF|r")
    discord:SetTextColor(Design.Rgb("text"))
    discord:SetJustifyV("MIDDLE")

    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowOneY)
    local metadataVersion = GetAddOnMetadataSafe(addonName, "Version") or BLU.VersionNumber or "v1.3.8"
    version:SetText(metadataVersion)
    version:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
    version:SetJustifyH("RIGHT")
    version:SetJustifyV("MIDDLE")

    local author = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowTwoY)
    author:SetText("by donniedice")
    author:SetTextColor(Design.Rgb("subtext"))
    author:SetJustifyH("RIGHT")
    author:SetJustifyV("MIDDLE")

    local branding = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    branding:SetPoint("RIGHT", header, "TOPRIGHT", rightX, rowThreeY)
    branding:SetText("|cff8b4b5cRGX|r |cffffd700Mods|r")
    branding:SetJustifyH("RIGHT")
    branding:SetJustifyV("MIDDLE")

    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
    tabContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -12)
    if Tabs and Tabs.SetContainer then
        Tabs:SetContainer(tabContainer)
    end
    local tabContainerHeight = (Tabs and Tabs.GetContainerHeight and Tabs:GetContainerHeight()) or 62
    tabContainer:SetHeight(tabContainerHeight)

    local tabBg = tabContainer:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(Design.Rgba("background", 0.6))

    -- No settings box (operator rev 3): tabs render directly on the strip.
    -- The frame remains only as a layout helper for height tracking.
    -- Settings box: General, Profiles, Debug and Sounds sit inside a bordered frame, like
    -- BLU Retail's settings column. It spans both tab columns (x 8..208 of the strip).
    local SETTINGS_BOX_WIDTH = 208
    -- Rows 1 and 2 (the four settings tabs): top -6 to bottom -61, so each button has 4 px of margin (buttons span y -10 to -57).
    local SETTINGS_BOX_HEIGHT = 55
    local leftTabGroup = CreateFrame("Frame", nil, tabContainer, "BackdropTemplate")
    leftTabGroup:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 4, -6)
    leftTabGroup:SetSize(SETTINGS_BOX_WIDTH, SETTINGS_BOX_HEIGHT)
    leftTabGroup:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
    leftTabGroup:SetBackdropColor(Design.Rgba("surface", 0.95))
    leftTabGroup:SetBackdropBorderColor(Design.Rgba("border", 1))

    local leftSeparator = tabContainer:CreateTexture(nil, "OVERLAY")
    leftSeparator:SetSize(1, tabContainerHeight - 12)
    -- Divider after column 2 (col 2 right edge = 208): separates the
    -- settings columns from the event columns.
    leftSeparator:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 214, -8)
    leftSeparator:SetColorTexture(Design.Rgba("border", 0.9))

    -- Dynamic reflow: whenever the tab strip's width changes (UI scale,
    -- panel resize), re-wrap the buttons and resize the container and its
    -- fixed-height decorations so leftTabGroup/leftSeparator track the
    -- wrapped row count.
    local function RefreshTabStripLayout()
        if not (Tabs and Tabs.RefreshLayout) then return end
        local rows = Tabs:RefreshLayout()
        if rows and Tabs.GetContainerHeight then
            local newHeight = Tabs:GetContainerHeight()
            if newHeight ~= tabContainerHeight then
                tabContainerHeight = newHeight
                tabContainer:SetHeight(newHeight)
                leftSeparator:SetSize(1, newHeight - 12)
            end
        end
    end
    tabContainer:HookScript("OnSizeChanged", function()
        RefreshTabStripLayout()
    end)

    panel.tabs = {}
    panel.contents = {}

    local tabs = BLU.OptionsTabs
    if not tabs then
        BLU:PrintError("BLU.OptionsTabs not defined")
        return nil
    end

    -- Re-apply flavor gating so greyed flags are always present at build
    -- time, regardless of module init order
    if BLU.Modules.flavors and BLU.Modules.flavors.ApplyToTabSpec then
        BLU.Modules.flavors:ApplyToTabSpec(tabs)
    end

    for i, tabInfo in ipairs(tabs) do
        BLU:PrintDebug("[Options] Creating tab content for '" .. tostring(tabInfo.text) .. "'")
        local tab = BLU.CreateTabButton(tabContainer, tabInfo.text, i, tabInfo.row, tabInfo.col, panel, tabInfo.icon)
        if Tabs then
            Tabs.buttons = Tabs.buttons or {}
            Tabs.buttons[i] = tab
        end
        if tabInfo.placeholder then
            tab:SetPlaceholder(true)
        end
        -- Greyed-out flavor tabs are visible but not clickable
        if tabInfo.greyed then
            tab.greyed = true
            tab:Disable()
        end
        panel.tabs[i] = tab

        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        -- Leave room between the tab strip and each page's heading/subtext.
        content:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 1, -12)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -7, 8)
        content:SetBackdrop(BLU.Modules.design.Backdrops.Dark)
        content:SetBackdropColor(Design.Rgba("background", 0.95))
        content:SetBackdropBorderColor(Design.Rgba("border", 1))
        content:Hide()

        if tabInfo.greyed and tabInfo.greyedMessage then
            local greyedTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            greyedTitle:SetPoint("TOPLEFT", 18, -40)
            greyedTitle:SetText("|cff05dffa" .. tabInfo.text .. "|r")

            local greyedMessage = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            greyedMessage:SetPoint("TOPLEFT", 18, -76)
            greyedMessage:SetPoint("RIGHT", -18, 0)
            greyedMessage:SetText(tabInfo.greyedMessage)
            greyedMessage:SetJustifyH("LEFT")
        elseif tabInfo.create then
            local success, err = pcall(tabInfo.create, content)
            if not success then
                BLU:PrintError("Error creating content for " .. tabInfo.text .. ": " .. tostring(err))
                BLU._panelErrors = BLU._panelErrors or {}
                BLU._panelErrors[tabInfo.text] = tostring(err)
            end
        elseif tabInfo.eventType then
            local success, err = pcall(BLU.CreateEventSoundPanel, content, tabInfo.eventType, tabInfo.text)
            if not success then
                BLU:PrintError("Error creating event panel for " .. tabInfo.text .. ": " .. tostring(err))
                BLU._panelErrors = BLU._panelErrors or {}
                BLU._panelErrors[tabInfo.text] = tostring(err)
            end
        elseif tabInfo.placeholder then
            local placeholderMessage = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            placeholderMessage:SetPoint("TOPLEFT", 18, -18)
            placeholderMessage:SetText(tabInfo.greyedMessage or "|cff778899Reserved for a future options panel.|r")
            placeholderMessage:SetJustifyH("LEFT")
        end
        panel.contents[i] = content
    end

    -- All buttons exist now: run the initial dynamic wrap pass so the strip
    -- reflects the live spec at the container's actual width (this also
    -- corrects the container height before the panel is first shown).
    RefreshTabStripLayout()

    -- Destroy all child frames/regions on a content panel so a clean rebuild won't stack widgets.
    local function ClearTabContent(content)
        for _, child in ipairs({content:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
        -- Also clear any textures/fontstrings created directly on the frame
        for _, region in ipairs({content:GetRegions()}) do
            region:Hide()
        end
        -- Reset Refresh so a stale closure from the previous build doesn't fire
        content.Refresh = nil
    end

    local function RebuildTab(content, tabInfo)
        ClearTabContent(content)
        content._bluDirty = nil
        if tabInfo.greyed and tabInfo.greyedMessage then
            -- Greyed-out tabs never rebuild; their message is static
        elseif tabInfo.create then
            local ok, err = pcall(tabInfo.create, content)
            if not ok then
                BLU:PrintError("Tab rebuild error: " .. tostring(err))
                BLU._panelErrors = BLU._panelErrors or {}
                BLU._panelErrors[tabInfo.text] = tostring(err)
            end
        elseif tabInfo.eventType then
            local ok, err = pcall(BLU.CreateEventSoundPanel, content, tabInfo.eventType, tabInfo.text)
            if not ok then
                BLU:PrintError("Tab rebuild error: " .. tostring(err))
                BLU._panelErrors = BLU._panelErrors or {}
                BLU._panelErrors[tabInfo.text] = tostring(err)
            end
        end
    end

    function panel:SelectTab(index)
        BLU:PrintDebug("[Options] Selecting tab index " .. tostring(index))
        for i, tab in ipairs(self.tabs) do
            if self.tabs[i] and self.contents[i] then
                self.tabs[i]:SetActive(i == index)
                self.contents[i]:SetShown(i == index)
                if i == index then
                    local content = self.contents[i]
                    local tabInfo = BLU.OptionsTabs and BLU.OptionsTabs[i]
                    if content._bluDirty and tabInfo then
                        RebuildTab(content, tabInfo)
                    elseif type(content.Refresh) == "function" then
                        local ok, err = pcall(content.Refresh, content)
                        if not ok then BLU:PrintError("Tab refresh error: " .. tostring(err)) end
                    end
                end
            end
        end
    end

    if #panel.tabs > 0 then
        panel:SelectTab(1)
    end

    -- Mark all tab content frames dirty so each will do a full rebuild on next view.
    function BLU:InvalidateAllTabs()
        if not panel or not panel.contents then return end
        for _, content in ipairs(panel.contents) do
            content._bluDirty = true
        end
    end

    -- Rebuild every visible dirty tab; call Refresh on visible non-dirty tabs.
    function BLU:RefreshOptions()
        if not panel or not panel.contents then return end
        for i, content in ipairs(panel.contents) do
            if content:IsShown() then
                local tabInfo = BLU.OptionsTabs and BLU.OptionsTabs[i]
                if content._bluDirty and tabInfo then
                    RebuildTab(content, tabInfo)
                elseif type(content.Refresh) == "function" then
                    local ok, err = pcall(content.Refresh, content)
                    if not ok then
                        BLU:PrintDebug("RefreshOptions error: " .. tostring(err))
                    end
                end
            end
        end
    end

    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.settingsCategoryName or panel.name)
        Settings.RegisterAddOnCategory(category)
        BLU.OptionsCategory = category
        self:ResolveOptionsCategoryID()
    else
        panel.name = panel.settingsCategoryName or panel.name
        InterfaceOptions_AddCategory(panel)
        BLU.OptionsCategory = panel
    end

    return panel
end

-- Open options
function Options:OpenOptions()
    BLU:PrintDebug("[Options] OpenOptions called")
    if not BLU.db then
        BLU:Print("Database not ready. Please wait a moment and try again.")
        return
    end

    if InCombatLockdown and InCombatLockdown() then
        BLU:PrintDebug("[Options] OpenOptions blocked by combat lockdown")
        if not BLU._queuedOpenOptions then
            BLU._queuedOpenOptions = true
            BLU:Print("|cff00ccffBLU:|r Options cannot be opened in combat. Queued to open after combat.")
            local RGX = _G.RGXFramework
            if RGX and RGX.QueueForCombat then
                RGX:QueueForCombat(function()
                    BLU._queuedOpenOptions = nil
                    if BLU.OpenOptions then
                        BLU:OpenOptions()
                    end
                    return true
                end)
            else
                BLU._queuedOpenOptions = nil
            end
        else
            BLU:PrintDebug("[Options] OpenOptions already queued for after combat")
        end
        return
    end

    if not BLU.OptionsPanel then
        BLU:PrintDebug("[Options] Options panel missing, creating now")
        self:CreateOptionsPanel()
    end

    if not BLU.OptionsCategory then
        BLU:Print("Options panel not properly registered.")
        return
    end

    local opened = false
    local categoryID = self:ResolveOptionsCategoryID()

    if Settings and Settings.OpenToCategory and categoryID then
        local ok, result = pcall(function()
            if securecall then
                -- Use string name as fallback if ID is not a number
                local target = type(categoryID) == "number" and categoryID or (BLU.OptionsPanel and (BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name))
                if target then
                    return securecall(Settings.OpenToCategory, target)
                end
            end
            return Settings.OpenToCategory(categoryID)
        end)
        opened = ok and result ~= nil
    end

    -- Avoid calling C_SettingsUtil.OpenSettingsPanel directly because it can be blocked for addons.
    if not opened and SettingsPanel and SettingsPanel.OpenToCategory and type(categoryID) == "number" then
        local ok, result = pcall(function()
            if securecall then
                return securecall(SettingsPanel.OpenToCategory, SettingsPanel, categoryID)
            end
            return SettingsPanel.OpenToCategory(SettingsPanel, categoryID)
        end)
        opened = ok and result ~= nil
    end

    if not opened and Settings and Settings.OpenToCategory and BLU.OptionsPanel then
        local categoryName = BLU.OptionsPanel.settingsCategoryName or BLU.OptionsPanel.name
        if categoryName then
            local ok, result = pcall(function()
                if securecall then
                    return securecall(Settings.OpenToCategory, categoryName)
                end
                return Settings.OpenToCategory(categoryName)
            end)
            opened = ok and result ~= nil
        end
    end

    if not opened and InterfaceOptionsFrame_OpenToCategory and BLU.OptionsPanel then
        local okFirst = pcall(InterfaceOptionsFrame_OpenToCategory, BLU.OptionsPanel)
        local okSecond = pcall(InterfaceOptionsFrame_OpenToCategory, BLU.OptionsPanel)
        opened = okFirst or okSecond
    end

    if not opened then
        if SettingsPanel then
            SettingsPanel:Show()
            opened = true
        elseif InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            opened = true
        end
    end

    if not opened then
        BLU:Print("Unable to open options panel")
    else
        BLU:PrintDebug("[Options] Options panel opened successfully")
    end
end

function Options:Init()
    BLU:PrintDebug("Options:Init() called, registering OpenOptions.")
    BLU.CreateOptionsPanel = function()
        return self:CreateOptionsPanel()
    end
    BLU.OpenOptions = function()
        return self:OpenOptions()
    end
end

function Options:Cleanup()
    BLU:PrintDebug("[Options] Cleanup called")
end

Options:Init()
