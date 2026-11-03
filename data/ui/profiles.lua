--=====================================================================================
-- BLU_Classic - data/ui/profiles.lua
-- Profiles page. Layout mirrors BLU / BLU Forever profiles.lua (title bar, intro,
-- active-profile highlight, profile dropdown with inline delete, Create / Rename /
-- Reset / Copy). Backed by the RGX-Framework database owner (BLU_Classic.db).
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

local DEFAULT_PROFILE = "Default"

local function GetActiveProfileName()
    local db = BLU.db
    if db and db.GetActiveProfile then
        return db:GetActiveProfile() or DEFAULT_PROFILE
    end
    return DEFAULT_PROFILE
end

local function GetOrderedProfiles()
    local profiles = {}
    local db = BLU.db
    if db and db.ListProfiles then
        for _, name in ipairs(db:ListProfiles()) do
            profiles[#profiles + 1] = name
        end
    end

    local active = GetActiveProfileName()
    table.sort(profiles, function(a, b)
        if a == DEFAULT_PROFILE and b ~= DEFAULT_PROFILE then return true end
        if b == DEFAULT_PROFILE and a ~= DEFAULT_PROFILE then return false end
        if a == active and b ~= active then return true end
        if b == active and a ~= active then return false end
        return tostring(a):lower() < tostring(b):lower()
    end)
    return profiles
end

local function ProfileExists(name)
    for _, existing in ipairs(GetOrderedProfiles()) do
        if existing == name then return true end
    end
    return false
end

local function GetCharacterLabel()
    local name = UnitName and UnitName("player") or "?"
    local realm = GetRealmName and GetRealmName() or ""
    return realm ~= "" and (name .. " - " .. realm) or name
end

-- Rebuild every visible options page so all controls re-read the active profile.
local function RefreshAll()
    if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
    if BLU.RefreshOptions then BLU:RefreshOptions() end
end

local function GetSuggestedCopyName()
    local base = "Copy"
    if not ProfileExists(base) then return base end
    local suffix = 2
    while ProfileExists(base .. " " .. suffix) do
        suffix = suffix + 1
    end
    return base .. " " .. suffix
end

local function EditBoxOf(dialog)
    return dialog.editBox or dialog.EditBox
end

local function TrimmedText(dialog)
    local box = EditBoxOf(dialog)
    local text = box and box:GetText() or ""
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function AcceptFromEnter(editBox)
    local parent = editBox:GetParent()
    if parent and parent.button1 and parent.button1:IsEnabled() then
        parent.button1:Click()
    end
end

--=====================================================================================
-- Presets
--=====================================================================================
-- Sound ids are indexes into soundOptions (data/sounds.lua). These are the BLU Forever
-- "donniedice's Preset" selections mapped to BLU Classic's library; Forever events that
-- Classic does not have (Honor, Renown, Delves, Housing, Trading Post) are left out.
local PROFILE_PRESETS = {
    {
        name = "donniedice's Preset",
        description = "donniedice's favorite sound selections and options for BLU.",
        settings = {
            showWelcomeMessage = true,
            debugMode = false,
            LevelSoundSelect = 24,              LevelVolume = 2,            -- Kingdom Hearts 3
            QuestAcceptSoundSelect = 26,        QuestAcceptVolume = 2,      -- Kirby (2)
            QuestSoundSelect = 25,              QuestVolume = 2,            -- Kirby (1)
            RepSoundSelect = 29,                RepVolume = 2,              -- Maplestory
            AchievementSoundSelect = 15,        AchievementVolume = 2,      -- EverQuest
            BattlePetLevelSoundSelect = 37,     BattlePetLevelVolume = 2,   -- Pokemon
        },
    },
    { name = "Future Preset 1", description = "Reserved for a future profile preset.", disabled = true },
    { name = "Future Preset 2", description = "Reserved for a future profile preset.", disabled = true },
    { name = "Future Preset 3", description = "Reserved for a future profile preset.", disabled = true },
    { name = "Future Preset 4", description = "Reserved for a future profile preset.", disabled = true },
    { name = "Future Preset 5", description = "Reserved for a future profile preset.", disabled = true },
}

BLU.ProfilePresets = PROFILE_PRESETS

-- Settings that belong to the player rather than to a sound layout survive a preset.
local PRESERVED_KEYS = { "userCustomSounds", "classicMinimapIconEnabled", "classicMinimapAngle" }

local function ApplyPreset(profileName, preset)
    local db = BLU.db
    if not (db and db.ResetProfile and preset and preset.settings) then
        return false, "Presets are not available."
    end
    if profileName ~= GetActiveProfileName() then
        return false, "Switch to the profile first."
    end

    local kept = {}
    for _, key in ipairs(PRESERVED_KEYS) do
        kept[key] = db[key]
    end

    db:ResetProfile(profileName)
    for key, value in pairs(preset.settings) do
        db[key] = value
    end
    for key, value in pairs(kept) do
        db[key] = value
    end

    BLU.debugMode = db.debugMode == true
    BLU.showWelcomeMessage = db.showWelcomeMessage ~= false
    return true
end

--=====================================================================================
-- Popups
--=====================================================================================
StaticPopupDialogs["BLU_CLASSIC_PROFILE_CREATE"] = {
    text = "Create a new profile.|nEnter a name:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 40,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self)
        local box = EditBoxOf(self)
        if box then box:SetText(""); box:SetFocus() end
    end,
    OnAccept = function(self)
        local name = TrimmedText(self)
        if name == "" then return end
        if ProfileExists(name) then
            BLU:Print("A profile named '" .. name .. "' already exists.")
            return
        end
        if BLU.db:CreateProfile(name) then
            RefreshAll()
        end
    end,
    EditBoxOnEnterPressed = AcceptFromEnter,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["BLU_CLASSIC_PROFILE_RENAME"] = {
    text = "Rename profile '%s'.|nEnter a new name:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 40,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        local box = EditBoxOf(self)
        if box then box:SetText(data or ""); box:HighlightText(); box:SetFocus() end
    end,
    OnAccept = function(self, data)
        local name = TrimmedText(self)
        if name == "" or name == data then return end
        if ProfileExists(name) then
            BLU:Print("A profile named '" .. name .. "' already exists.")
            return
        end
        BLU.db:RenameProfile(data, name)
        RefreshAll()
    end,
    EditBoxOnEnterPressed = AcceptFromEnter,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

StaticPopupDialogs["BLU_CLASSIC_PROFILE_RESET"] = {
    text = "Reset profile '%s' to default settings?",
    button1 = YES,
    button2 = NO,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnAccept = function(_, data)
        BLU.db:ResetProfile(data)
        RefreshAll()
    end,
}

StaticPopupDialogs["BLU_CLASSIC_PROFILE_APPLY_PRESET"] = {
    text = "Apply preset to \"%s\"?|n|nThis resets the profile's settings, then applies the preset. Your custom sounds and minimap position are kept.",
    button1 = "Apply",
    button2 = CANCEL,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnAccept = function(_, data)
        if not (data and data.profileName and data.preset) then return end
        local ok, err = ApplyPreset(data.profileName, data.preset)
        if ok then
            BLU:Print("Applied preset '" .. tostring(data.preset.name) .. "' to profile '" .. tostring(data.profileName) .. "'.")
            RefreshAll()
        else
            BLU:Print("Preset apply failed: " .. tostring(err))
        end
    end,
}

StaticPopupDialogs["BLU_CLASSIC_PROFILE_DELETE"] = {
    text = "Delete profile '%s'? This cannot be undone.",
    button1 = YES,
    button2 = NO,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnAccept = function(_, data)
        BLU.db:DeleteProfile(data)
        RefreshAll()
    end,
}

--=====================================================================================
-- Panel
--=====================================================================================
function BLU.CreateProfilesPanel(panel)
    BLU:PrintDebug("[Options/Profiles] Creating Profiles panel")

    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

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

    local titleIcon = titleBar:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(24, 24)
    titleIcon:SetPoint("LEFT", 10, 0)
    titleIcon:SetTexture("Interface\\Icons\\Ability_Marksmanship")

    local titleLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleLabel:SetText("|cff05dffaProfiles|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(0.6, 0.66, 0.72)
    intro:SetText("Create, switch, and manage your saved sound profiles.")

    if not (BLU.db and BLU.db.ListProfiles) then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -102)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        return content
    end

    local col2X = 215
    local col3X = 492

    local mainSection = Design:CreateSection(content, "Profiles", "Interface\\Icons\\Ability_Marksmanship")
    mainSection:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -102)
    mainSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -102)
    mainSection:SetHeight(175)

    -- Highlight frame for Active Profile info
    local activeHighlight = CreateFrame("Frame", nil, mainSection.content, "BackdropTemplate")
    activeHighlight:SetPoint("TOPLEFT", 8, -8)
    activeHighlight:SetPoint("BOTTOMLEFT", 8, 8)
    activeHighlight:SetWidth(col2X - 24)
    activeHighlight:SetBackdrop(Design.Backdrops.Dark)
    activeHighlight:SetBackdropColor(0.1, 0.12, 0.16, 0.6)
    activeHighlight:SetBackdropBorderColor(0.2, 0.3, 0.4, 0.5)

    local profileDropdownLabel = mainSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileDropdownLabel:SetPoint("TOPLEFT", col2X, -16)
    profileDropdownLabel:SetText("|cff05dffaProfile|r")

    local profileDropdown = CreateFrame("Frame", "BLUClassicProfilesDropdown", mainSection.content, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", profileDropdownLabel, "BOTTOMLEFT", -15, -4)
    UIDropDownMenu_SetWidth(profileDropdown, 220)
    profileDropdown:SetAlpha(0)
    profileDropdown:SetScale(0.01)

    local profileButton = CreateFrame("Button", nil, mainSection.content, "BackdropTemplate")
    profileButton:SetPoint("TOPLEFT", profileDropdownLabel, "BOTTOMLEFT", 0, -6)
    profileButton:SetSize(220, 22)
    profileButton:SetBackdrop(Design.Backdrops.Button)
    profileButton:SetBackdropColor(0.10, 0.14, 0.19, 0.96)
    profileButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    profileButton:RegisterForClicks("LeftButtonUp")

    local profileButtonText = profileButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileButtonText:SetPoint("LEFT", 8, 0)
    profileButtonText:SetPoint("RIGHT", -18, 0)
    profileButtonText:SetJustifyH("LEFT")
    profileButtonText:SetTextColor(0.84, 0.84, 0.84, 1)

    local profileArrow = profileButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileArrow:SetPoint("RIGHT", -6, 0)
    profileArrow:SetText("v")
    profileArrow:SetTextColor(0.70, 0.78, 0.86, 1)

    profileButton:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, profileDropdown, self, 0, 0)
    end)
    profileButton:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(Design.Colors.Primary))
    end)
    profileButton:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    end)

    local profileCount = mainSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profileCount:SetPoint("TOPLEFT", profileButton, "BOTTOMLEFT", 0, -4)
    profileCount:SetPoint("RIGHT", mainSection.content, "RIGHT", -10, 0)
    profileCount:SetJustifyH("LEFT")
    profileCount:SetTextColor(0.72, 0.72, 0.72)

    local currentProfileLabel = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentProfileLabel:SetPoint("TOPLEFT", activeHighlight, "TOPLEFT", 12, -12)
    currentProfileLabel:SetText("Active")

    local currentProfileValue = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentProfileValue:SetPoint("TOPLEFT", currentProfileLabel, "BOTTOMLEFT", 0, -2)
    currentProfileValue:SetPoint("RIGHT", activeHighlight, "RIGHT", -10, 0)
    currentProfileValue:SetJustifyH("LEFT")
    currentProfileValue:SetJustifyV("TOP")
    currentProfileValue:SetWordWrap(true)

    local characterProfileLabel = activeHighlight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    characterProfileLabel:SetPoint("TOPLEFT", currentProfileValue, "BOTTOMLEFT", 0, -10)
    characterProfileLabel:SetPoint("RIGHT", activeHighlight, "RIGHT", -10, 0)
    characterProfileLabel:SetTextColor(0.76, 0.76, 0.76)
    characterProfileLabel:SetJustifyH("LEFT")

    local actionButtonWidth = 84

    local createButton = Design:CreateActionButton(mainSection.content, "Create", actionButtonWidth, 22,
        "Create Profile", "Create a new profile with a unique name and switch to it.")
    createButton:SetPoint("TOPLEFT", mainSection.content, "TOPLEFT", col3X, -8)
    createButton:SetScript("OnClick", function()
        StaticPopup_Show("BLU_CLASSIC_PROFILE_CREATE")
    end)

    local renameButton = Design:CreateActionButton(mainSection.content, "Rename", actionButtonWidth, 22,
        "Rename Profile", "Rename the active profile. The Default profile cannot be renamed.")
    renameButton:SetPoint("TOPLEFT", createButton, "BOTTOMLEFT", 0, -6)
    renameButton:SetScript("OnClick", function()
        local active = GetActiveProfileName()
        if active == DEFAULT_PROFILE then
            BLU:Print("The Default profile cannot be renamed.")
            return
        end
        StaticPopup_Show("BLU_CLASSIC_PROFILE_RENAME", active, nil, active)
    end)

    local resetButton = Design:CreateActionButton(mainSection.content, "Reset", actionButtonWidth, 22,
        "Reset Profile", "Restores the active profile to default settings.")
    resetButton:SetPoint("TOPLEFT", renameButton, "BOTTOMLEFT", 0, -6)
    resetButton:SetScript("OnClick", function()
        local active = GetActiveProfileName()
        StaticPopup_Show("BLU_CLASSIC_PROFILE_RESET", active, nil, active)
    end)

    local copyButton = Design:CreateActionButton(mainSection.content, "Copy", actionButtonWidth, 22,
        "Duplicate Active Profile", "Creates a copy named 'Copy', then 'Copy 2', 'Copy 3', and so on, and switches to it.")
    copyButton:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", 0, -6)
    copyButton:SetScript("OnClick", function()
        local source = GetActiveProfileName()
        local target = GetSuggestedCopyName()
        if BLU.db:CopyProfile(source, target) then
            RefreshAll()
        end
    end)

    -- Presets section: full width bottom section (same layout as BLU Forever)
    local presetsSection = Design:CreateSection(content, "Presets", "Interface\\Icons\\INV_Inscription_Scroll")
    presetsSection:SetPoint("TOPLEFT", mainSection, "BOTTOMLEFT", 0, -4)
    presetsSection:SetPoint("TOPRIGHT", mainSection, "BOTTOMRIGHT", 0, -4)
    presetsSection:SetHeight(112)

    local presetColWidth = 180
    for presetIndex, preset in ipairs(PROFILE_PRESETS) do
        local col = (presetIndex - 1) % 3
        local row = math.floor((presetIndex - 1) / 3)
        local presetButton = Design:CreateActionButton(
            presetsSection.content, preset.name, presetColWidth, 22,
            preset.name, preset.description)
        presetButton:SetPoint("TOPLEFT", 12 + (col * (presetColWidth + 12)), -12 - (row * 30))
        if preset.disabled then
            -- Reserved slot: visible like in BLU Forever, but it does nothing.
            presetButton:SetAlpha(0.5)
            presetButton:SetScript("OnClick", nil)
        else
            presetButton:SetScript("OnClick", function()
                local activeProfileName = GetActiveProfileName()
                StaticPopup_Show("BLU_CLASSIC_PROFILE_APPLY_PRESET", activeProfileName, nil, { profileName = activeProfileName, preset = preset })
            end)
        end
    end

    -- Dropdown contents: click to switch, inline "x" deletes non-Default profiles.
    local function HideDeleteButtons(level)
        local listFrame = _G["DropDownList" .. level]
        if not listFrame then return end
        for i = 1, (UIDROPDOWNMENU_MAXBUTTONS or 32) do
            local button = _G[listFrame:GetName() .. "Button" .. i]
            if button and button.bluDeleteButton then
                button.bluDeleteButton:Hide()
            end
        end
    end

    local function AttachDeleteButton(level, profileName)
        local listFrame = _G["DropDownList" .. level]
        if not (listFrame and listFrame.numButtons) then return end
        local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
        if not button then return end

        local deleteButton = button.bluDeleteButton
        if not deleteButton then
            deleteButton = CreateFrame("Button", nil, button, "BackdropTemplate")
            deleteButton:SetSize(18, 16)
            deleteButton:SetPoint("RIGHT", button, "RIGHT", -4, 0)
            deleteButton:SetBackdrop(Design.Backdrops.Button)
            deleteButton:SetBackdropColor(0.15, 0.05, 0.05, 0.95)
            deleteButton:SetBackdropBorderColor(0.3, 0.1, 0.1, 1)
            deleteButton:RegisterForClicks("LeftButtonUp")
            deleteButton:SetScript("OnClick", function(btn)
                if btn.profileName then
                    StaticPopup_Show("BLU_CLASSIC_PROFILE_DELETE", btn.profileName, nil, btn.profileName)
                    CloseDropDownMenus()
                end
            end)
            deleteButton:SetScript("OnEnter", function(btn)
                btn:SetBackdropColor(0.2, 0.07, 0.07, 1)
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:SetText("Delete Profile")
                GameTooltip:AddLine(btn.profileName or "", 0.82, 0.82, 0.82, true)
                GameTooltip:Show()
            end)
            deleteButton:SetScript("OnLeave", function(btn)
                btn:SetBackdropColor(0.15, 0.05, 0.05, 0.95)
                GameTooltip:Hide()
            end)
            local lbl = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lbl:SetPoint("CENTER", 0, 0)
            lbl:SetText("x")
            lbl:SetTextColor(1, 0.3, 0.3)
            button.bluDeleteButton = deleteButton
        end
        deleteButton.profileName = profileName
        deleteButton:Show()
    end

    UIDropDownMenu_Initialize(profileDropdown, function(_, level)
        level = level or 1
        if level ~= 1 then return end
        HideDeleteButtons(level)

        local active = GetActiveProfileName()
        for _, profileName in ipairs(GetOrderedProfiles()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = (profileName == active) and ("|cff05dffa" .. profileName .. "|r") or profileName
            info.value = profileName
            info.notCheckable = true
            info.func = function()
                BLU.db:LoadProfile(profileName)
                CloseDropDownMenus()
                RefreshAll()
            end
            UIDropDownMenu_AddButton(info, level)

            local openMenu = UIDROPDOWNMENU_OPEN_MENU
            if profileName ~= DEFAULT_PROFILE and openMenu and openMenu:GetName() == "BLUClassicProfilesDropdown" then
                AttachDeleteButton(level, profileName)
            end
        end
    end)

    local active = GetActiveProfileName()
    UIDropDownMenu_SetText(profileDropdown, tostring(active))
    profileButtonText:SetText(tostring(active))
    currentProfileValue:SetText("|cff05dffa" .. tostring(active) .. "|r")
    characterProfileLabel:SetText("Character: |cff95a5a6" .. GetCharacterLabel() .. "|r")
    profileCount:SetText("Saved: |cffffd700" .. tostring(#GetOrderedProfiles()) .. "|r")

    return content
end
