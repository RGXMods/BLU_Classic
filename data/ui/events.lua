--=====================================================================================
 -- BLU_Classic - data/ui/events.lua
-- Event sound pages (Level Up, Quest, Reputation, Achievement, Battle Pet).
-- Row layout, colors, and controls mirror BLU / BLU Forever sound_panel.lua:
-- titled card, intro line, then one 68px row per sound with label, current
-- sound, dropdown button, volume track, and Test button.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

-- Nested menu helpers (carried over from the previous AceGUI sound-select widget).
local BORDER_THICKNESS = UIDROPDOWNMENU_BORDER_THICKNESS or 15
local BORDER_PAD = BORDER_THICKNESS * 2

local function GetListFrame(level)
    return _G["DropDownList" .. level] or _G["LibDropDownMenu_List" .. level]
end

local function ShortenLabel(text, maxChars)
    if type(text) ~= "string" then
        return "", false
    end

    if #text <= maxChars then
        return text, false
    end

    return string.sub(text, 1, maxChars - 3) .. "...", true
end

local function TrimVariantLabel(soundName, parentLabel)
    if type(soundName) ~= "string" then
        return ""
    end

    if type(parentLabel) ~= "string" or parentLabel == "" then
        return soundName
    end

    local escapedParent = string.gsub(parentLabel, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    local withoutDashPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*%-%s*", "")
    if withoutDashPrefix ~= soundName then
        return withoutDashPrefix
    end

    local withoutColonPrefix = string.gsub(soundName, "^" .. escapedParent .. "%s*:%s*", "")
    if withoutColonPrefix ~= soundName then
        return withoutColonPrefix
    end

    return soundName
end

local function HideInlineCountLabels(level)
    local listFrame = GetListFrame(level)
    if not listFrame then
        return
    end

    local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
    for i = 1, maxButtons do
        local button = _G[listFrame:GetName() .. "Button" .. i]
        if button and button.bluClassicCountLabel then
            button.bluClassicCountLabel:Hide()
        end
    end
end

local function AttachInlineCountLabel(level, text)
    local listFrame = GetListFrame(level)
    if not listFrame or not listFrame.numButtons then
        return
    end

    local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
    if not button then
        return
    end

    local countLabel = button.bluClassicCountLabel
    if not countLabel then
        countLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        countLabel:SetJustifyH("RIGHT")
        countLabel:SetTextColor(0.72, 0.72, 0.72)
        button.bluClassicCountLabel = countLabel
    end

    countLabel:SetText(text or "")
    countLabel:Show()
end

local function ForceListFrameWidth(level, minWidth, leftInset)
    BLU:UIAfter(0, function()
        local listFrame = GetListFrame(level)
        if not listFrame or not listFrame:IsShown() then
            return
        end

        local neededContentWidth = math.max((minWidth or 200) - BORDER_PAD, 140)
        local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
        local visibleButtons = 0

        for i = 1, maxButtons do
            local button = _G[listFrame:GetName() .. "Button" .. i]
            if button and button:IsShown() then
                visibleButtons = visibleButtons + 1
                local normalText = _G[button:GetName() .. "NormalText"]
                local expandArrow = _G[button:GetName() .. "ExpandArrow"]
                local countLabel = button.bluClassicCountLabel
                local hasArrow = expandArrow and expandArrow:IsShown()
                local hasCount = countLabel and countLabel:IsShown()
                local textWidth = normalText and math.ceil(normalText:GetStringWidth() or 0) or 0
                local countWidth = hasCount and math.ceil(countLabel:GetStringWidth() or 0) or 0
                local rightReservation = (hasArrow and 14 or 6) + (hasCount and (countWidth + 6) or 0)
                neededContentWidth = math.max(neededContentWidth, (leftInset or 10) + textWidth + rightReservation)
            end
        end

        if visibleButtons == 0 then
            return
        end

        local buttonWidth = neededContentWidth
        local frameWidth = math.min(neededContentWidth + BORDER_PAD, 460)
        listFrame:SetWidth(frameWidth)

        for i = 1, maxButtons do
            local button = _G[listFrame:GetName() .. "Button" .. i]
            if button and button:IsShown() then
                local normalText = _G[button:GetName() .. "NormalText"]
                local expandArrow = _G[button:GetName() .. "ExpandArrow"]
                local countLabel = button.bluClassicCountLabel
                local hasArrow = expandArrow and expandArrow:IsShown()
                local hasCount = countLabel and countLabel:IsShown()

                button:SetWidth(buttonWidth)

                if expandArrow then
                    expandArrow:ClearAllPoints()
                    expandArrow:SetPoint("RIGHT", button, "RIGHT", -3, 0)
                end

                if countLabel and hasCount then
                    countLabel:ClearAllPoints()
                    if hasArrow and expandArrow then
                        countLabel:SetPoint("RIGHT", expandArrow, "LEFT", -4, 0)
                    else
                        countLabel:SetPoint("RIGHT", button, "RIGHT", -6, 0)
                    end
                end

                if normalText then
                    normalText:ClearAllPoints()
                    normalText:SetPoint("LEFT", button, "LEFT", leftInset or 10, 0)
                    if hasCount and countLabel then
                        normalText:SetPoint("RIGHT", countLabel, "LEFT", -6, 0)
                    else
                        normalText:SetPoint("RIGHT", button, "RIGHT", hasArrow and -16 or -6, 0)
                    end
                    normalText:SetJustifyH("LEFT")
                end
            end
        end
    end)
end

-- Resolve a numeric sound index to a display name using the group data
local function GetSoundDisplayName(value)
    if not value then return "" end
    if not BLU_Classic_SoundGroups or not BLU_Classic_IndexToGroup then
        return soundOptions and soundOptions[value] or tostring(value)
    end

    local gi = BLU_Classic_IndexToGroup[value]
    if not gi then
        return soundOptions and soundOptions[value] or tostring(value)
    end

    local group = BLU_Classic_SoundGroups[gi]
    if not group then return tostring(value) end

    if #group.indices == 1 then
        return group.name
    end

    local vi = BLU_Classic_IndexToVariant and BLU_Classic_IndexToVariant[value]
    local label = group.labels and group.labels[vi] or tostring(vi)
    return group.name .. " - " .. label
end


-- Rows per event page: saved-variable keys are unchanged from earlier releases.
local EVENT_ROWS = {
    levelup = {
        { labelKey = "LEVEL_UP", label = "Level Up", sound = "LevelSoundSelect", volume = "LevelVolume", test = "TestLevelSound" },
    },
    quest = {
        { labelKey = "QUEST_ACCEPTED", label = "Quest Accepted", sound = "QuestAcceptSoundSelect", volume = "QuestAcceptVolume", test = "TestQuestAcceptSound" },
        { labelKey = "QUEST_COMPLETE", label = "Quest Complete", sound = "QuestSoundSelect", volume = "QuestVolume", test = "TestQuestSound" },
    },
    reputation = {
        { labelKey = "REPUTATION_RANK_UP", label = "Reputation Rank Up", sound = "RepSoundSelect", volume = "RepVolume", test = "TestRepSound" },
    },
    achievement = {
        { labelKey = "ACHIEVEMENT_EARNED", label = "Achievement Earned", sound = "AchievementSoundSelect", volume = "AchievementVolume", test = "TestAchievementSound" },
    },
    battlepet = {
        { labelKey = "BATTLE_PET_LEVEL_UP", label = "Battle Pet Level Up", sound = "BattlePetLevelSoundSelect", volume = "BattlePetLevelVolume", test = "TestBattlePetLevelSound" },
    },
}

-- Combat and Loot pages: one row per trigger (see data/triggers.lua)
for pageKey, triggers in pairs(BLU.TriggerPages or {}) do
    EVENT_ROWS[pageKey] = {}
    for _, trigger in ipairs(triggers) do
        EVENT_ROWS[pageKey][#EVENT_ROWS[pageKey] + 1] = {
            label = trigger.label, sound = trigger.sound, volume = trigger.volume,
            trigger = trigger.id, description = trigger.description, none = true,
        }
    end
end

local EVENT_ICONS = {
    hardcore = "Interface\\Icons\\Spell_Shadow_AnimateDead",
    combat = "Interface\\Icons\\Ability_Warrior_Charge",
    loot = "Interface\\Icons\\INV_Misc_Coin_02",
    levelup = "Interface\\Icons\\Achievement_Level_100",
    quest = "Interface\\Icons\\INV_Misc_Note_01",
    reputation = "Interface\\Icons\\Achievement_Reputation_01",
    achievement = "Interface\\Icons\\Achievement_Quests_Completed_08",
    battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
}

local EVENT_DESCRIPTIONS = {
    hardcore = "Pick a sound for each death trigger. Made for hardcore and self-found runs, where every death is a story.",
    combat = "Pick a sound for each combat moment. Triggers start off; choose [None] to silence one.",
    loot = "Pick a sound for items and coin you loot, by item quality. Triggers start off.",
    levelup = "Pick a sound for each level-up.",
    quest = "Pick sounds for accepting and completing quests.",
    reputation = "Pick a sound for reputation rank-ups.",
    achievement = "Pick a sound for earned achievements.",
    battlepet = "Pick a sound for battle pet level-ups.",
}

-- Volume is stored as 0-3 (0 = off). The track snaps to four detents.
local VOLUME_LABELS = { [0] = "Off", [1] = "Low", [2] = "Medium", [3] = "High" }

local function NormalizeVolume(value)
    value = tonumber(value) or 2
    value = math.floor(value + 0.5)
    if value < 0 then value = 0 end
    if value > 3 then value = 3 end
    return value
end

-- compact = true builds the narrow two-column variant used on long pages (Combat, Loot):
-- label, then the dropdown and Test button on one line, then the volume track below.
local function CreateSoundRow(parent, rowInfo, yOffset, compact)
    local soundKey, volumeKey = rowInfo.sound, rowInfo.volume

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    container:SetHeight(compact and 76 or 68)
    container:SetBackdrop(Design.Backdrops.Solid)
    container:SetBackdropColor(0.08, 0.11, 0.15, 0.92)
    container:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

    if rowInfo.description then
        container:EnableMouse(true)
        container:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(rowInfo.label, 1, 1, 1)
            GameTooltip:AddLine(rowInfo.description, 0.82, 0.82, 0.82, true)
            GameTooltip:Show()
        end)
        container:SetScript("OnLeave", GameTooltip_Hide)
    end

    local rowLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowLabel:SetPoint("TOPLEFT", 10, -6)
    rowLabel:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -6)
    rowLabel:SetJustifyH("LEFT")
    rowLabel:SetTextColor(1.0, 0.82, 0.18)
    rowLabel:SetText(BLU:GetText(rowInfo.labelKey, rowInfo.label))

    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    currentSound:SetPoint("TOPLEFT", rowLabel, "BOTTOMLEFT", 0, -2)
    currentSound:SetPoint("TOPRIGHT", rowLabel, "BOTTOMRIGHT", 0, -2)
    currentSound:SetJustifyH("LEFT")
    currentSound:SetTextColor(0.02, 0.87, 0.98)
    currentSound:SetWordWrap(false)
    if currentSound.SetMaxLines then
        currentSound:SetMaxLines(1)
    end

    -- Volume track -----------------------------------------------------------------
    local volumeControl = CreateFrame("Frame", nil, container)
    volumeControl:SetHeight(compact and 14 or 18)

    local volButton = CreateFrame("Button", nil, volumeControl)
    volButton:SetAllPoints(volumeControl)
    volButton:SetHeight(18)

    local volLabel = volumeControl:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    volLabel:SetTextColor(0.70, 0.78, 0.86)
    volLabel:SetPoint("TOP", volButton, "BOTTOM", 0, 2)
    volLabel:Hide()

    volButton:SetScript("OnEnter", function() volLabel:Show() end)
    volButton:SetScript("OnLeave", function() volLabel:Hide() end)

    local volTrack = volumeControl:CreateTexture(nil, "ARTWORK")
    volTrack:SetHeight(4)
    volTrack:SetPoint("LEFT", volButton, "LEFT", 0, 0)
    volTrack:SetPoint("RIGHT", volButton, "RIGHT", 0, 0)
    volTrack:SetPoint("CENTER", volButton, "CENTER", 0, 0)
    volTrack:SetColorTexture(0.14, 0.20, 0.28, 1)

    local volFill = volumeControl:CreateTexture(nil, "ARTWORK")
    volFill:SetHeight(4)
    volFill:SetPoint("LEFT", volTrack, "LEFT", 0, 0)
    volFill:SetColorTexture(unpack(Design.Colors.Primary))

    local volThumb = volumeControl:CreateTexture(nil, "ARTWORK")
    volThumb:SetSize(8, 8)
    volThumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    volThumb:SetVertexColor(1, 1, 1, 1)

    local function getVolume()
        return NormalizeVolume(BLU.db and BLU.db[volumeKey])
    end

    -- Draw the track from the SAVED value. The track has no width until the page has
    -- been laid out, so this also runs whenever the control is shown or resized.
    local function renderVolume()
        local level = getVolume()
        local trackWidth = volTrack:GetWidth()
        if not trackWidth or trackWidth < 1 then return end
        local fillW = math.max(4, trackWidth * (level / 3))
        volFill:SetWidth(fillW)
        volThumb:ClearAllPoints()
        volThumb:SetPoint("CENTER", volTrack, "LEFT", fillW, 0)
        volLabel:SetText(VOLUME_LABELS[level])
    end

    local function applyVolume(level)
        if BLU.db then
            BLU.db[volumeKey] = NormalizeVolume(level)
        end
        renderVolume()
    end

    volumeControl:SetScript("OnShow", renderVolume)
    volumeControl:SetScript("OnSizeChanged", renderVolume)

    volButton:SetScript("OnMouseDown", function(self)
        local cursorX = GetCursorPosition()
        local scale = self:GetEffectiveScale()
        local left = self:GetLeft() and (self:GetLeft() * scale) or 0
        local width = math.max(1, (self:GetWidth() or 1) * scale)
        local percent = math.max(0, math.min(1, (cursorX - left) / width))
        applyVolume(math.floor(percent * 3 + 0.5))
    end)

    volButton:EnableMouseWheel(true)
    volButton:SetScript("OnMouseWheel", function()
        applyVolume((getVolume() + 1) % 4)
    end)

    -- Test button ---------------------------------------------------------------------
    local testBtn = Design:CreateButton(container, BLU:GetText("TEST_BUTTON", "Test"), 60, 22)
    testBtn:SetScript("OnClick", function()
        if rowInfo.trigger then
            BLU:TestTrigger(rowInfo.trigger)
            return
        end
        local testFn = BLU[rowInfo.test]
        if type(testFn) == "function" then
            testFn(BLU)
        end
    end)

    -- Sound dropdown (native menu owns selection; the visible trigger matches BLU) ------
    local dropdown = CreateFrame("Frame", "BLUClassicDropdown_" .. soundKey, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", currentSound, "BOTTOMLEFT", -16, -5)
    UIDropDownMenu_SetWidth(dropdown, 220)
    dropdown:SetAlpha(0)
    dropdown:SetScale(0.01)

    local dropdownButton = CreateFrame("Button", nil, container, "BackdropTemplate")
    dropdownButton:SetHeight(22)
    if not compact then
        dropdownButton:SetWidth(220)
    end
    dropdownButton:SetBackdrop(Design.Backdrops.Button)
    dropdownButton:SetBackdropColor(0.10, 0.14, 0.19, 0.96)
    dropdownButton:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    dropdownButton:RegisterForClicks("LeftButtonUp")

    local dropdownButtonLabel = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dropdownButtonLabel:SetPoint("LEFT", 8, 0)
    dropdownButtonLabel:SetPoint("RIGHT", -18, 0)
    dropdownButtonLabel:SetJustifyH("LEFT")
    dropdownButtonLabel:SetTextColor(0.84, 0.84, 0.84, 1)

    local dropdownArrow = dropdownButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dropdownArrow:SetPoint("RIGHT", -6, 0)
    dropdownArrow:SetText("v")
    dropdownArrow:SetTextColor(0.70, 0.78, 0.86, 1)

    dropdownButton:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
    end)
    dropdownButton:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(Design.Colors.Primary))
    end)
    dropdownButton:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    end)

    if compact then
        -- The current sound is already the dropdown text, so the extra line is dropped.
        currentSound:Hide()
        testBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -24)
        dropdownButton:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -24)
        dropdownButton:SetPoint("TOPRIGHT", testBtn, "TOPLEFT", -8, 0)
        volumeControl:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -54)
        volumeControl:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -54)
    else
        dropdownButton:SetPoint("LEFT", container, "LEFT", 10, 0)
        dropdownButton:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)
        testBtn:SetPoint("RIGHT", container, "RIGHT", -10, 0)
        testBtn:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)
        volumeControl:SetPoint("CENTER", dropdownButton, "CENTER", 0, 0)
        volumeControl:SetPoint("LEFT", dropdownButton, "RIGHT", 12, 0)
        volumeControl:SetPoint("RIGHT", testBtn, "LEFT", -12, 0)
    end

    local function isCustomSelection(value)
        return BLU.UserSounds and BLU.UserSounds:IsCustomId(value)
    end

    -- Numeric index into the shipped library, or the "custom:<path>" id of a user sound.
    local function selectedIndex()
        local value = BLU.db and BLU.db[soundKey]
        if isCustomSelection(value) then
            return value
        end
        return tonumber(value) or (rowInfo.none and 0 or 1)
    end

    local function refreshLabels()
        local value = selectedIndex()
        local name
        if isCustomSelection(value) then
            name = BLU.UserSounds:GetName(value)
        elseif value == 0 then
            name = "[None]"
        else
            name = GetSoundDisplayName(value)
        end
        currentSound:SetText(name)
        dropdownButtonLabel:SetText(name)
        -- Custom sounds have one file, so the low/medium/high track does not apply
        volumeControl:SetShown(not isCustomSelection(value) and value ~= 0)
        if compact then currentSound:Hide() end
    end

    local function chooseSound(index)
        if BLU.db then
            BLU.db[soundKey] = index
        end
        refreshLabels()
        CloseDropDownMenus()
    end

    UIDropDownMenu_Initialize(dropdown, function(_, level, menuList)
        level = level or 1
        local groups = BLU_Classic_SoundGroups
        if not groups then return end
        local baseWidth = 220
        local function minWidthFor(levelToUse)
            if (levelToUse or 1) <= 1 then return baseWidth end
            return math.max(160, math.floor(baseWidth * 0.72))
        end
        local function leftInsetFor(levelToUse)
            if (levelToUse or 1) <= 1 then return 24 end
            return 10
        end

        HideInlineCountLabels(level)

        if level == 1 then
            if rowInfo.none then
                local noneInfo = UIDropDownMenu_CreateInfo()
                noneInfo.text = "[None]"
                noneInfo.value = 0
                noneInfo.checked = function() return selectedIndex() == 0 end
                noneInfo.func = function() chooseSound(0) end
                UIDropDownMenu_AddButton(noneInfo, level)
            end
            for groupIndex, group in ipairs(groups) do
              -- Triggers have no shipped default file, so [Default] is not offered there
              if not (rowInfo.none and #group.indices == 1 and group.indices[1] == 1) then
                local info = UIDropDownMenu_CreateInfo()
                local displayText, truncated = ShortenLabel(group.name, 46)
                info.text = displayText
                if #group.indices == 1 then
                    local index = group.indices[1]
                    info.value = index
                    info.checked = function() return selectedIndex() == index end
                    info.func = function() chooseSound(index) end
                else
                    info.value = groupIndex
                    info.hasArrow = true
                    info.menuList = groupIndex
                    info.notCheckable = true
                end
                if truncated then
                    info.tooltipTitle = group.name
                end
                UIDropDownMenu_AddButton(info, level)
                if #group.indices > 1 then
                    AttachInlineCountLabel(level, "(" .. #group.indices .. ")")
                end
              end
            end

            local customEntries = BLU.UserSounds and BLU.UserSounds:GetEntries() or {}
            if #customEntries > 0 then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "User Custom Sounds"
                info.value = "custom"
                info.hasArrow = true
                info.menuList = "custom"
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
                AttachInlineCountLabel(level, "(" .. #customEntries .. ")")
            end
        elseif level == 2 and menuList == "custom" then
            for _, entry in ipairs(BLU.UserSounds and BLU.UserSounds:GetEntries() or {}) do
                local info = UIDropDownMenu_CreateInfo()
                local displayText, truncated = ShortenLabel(entry.name, 60)
                info.text = displayText
                info.value = entry.id
                info.checked = function() return selectedIndex() == entry.id end
                info.func = function() chooseSound(entry.id) end
                if truncated then
                    info.tooltipTitle = entry.name
                end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 and menuList then
            local group = groups[menuList]
            if not group then return end
            for variantIndex, index in ipairs(group.indices) do
                local info = UIDropDownMenu_CreateInfo()
                local rawText = group.labels and group.labels[variantIndex] or GetSoundDisplayName(index)
                local trimmed = TrimVariantLabel(rawText, group.name)
                local displayText, truncated = ShortenLabel(trimmed, 60)
                info.text = displayText
                info.value = index
                info.checked = function() return selectedIndex() == index end
                info.func = function() chooseSound(index) end
                if truncated or trimmed ~= rawText then
                    info.tooltipTitle = rawText
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        ForceListFrameWidth(level, minWidthFor(level), leftInsetFor(level))
    end)

    renderVolume()
    refreshLabels()

    return container
end

function BLU.CreateEventSoundPanel(panel, eventType, eventName)
    BLU:PrintDebug("[Options/Events] Creating event sound panel for '" .. tostring(eventType) .. "'")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(0.04, 0.06, 0.08, 0.35)

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
    icon:SetTexture(EVENT_ICONS[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(0.6, 0.66, 0.72)
    intro:SetText(EVENT_DESCRIPTIONS[eventType] or ("Pick a sound for " .. eventName .. "."))

    local dropY = -102
    local rows = EVENT_ROWS[eventType] or {}
    local RGX = _G.RGXFramework
    local UI = RGX and RGX.GetUI and RGX:GetUI() or _G.RGXUI
    local usePager = #rows > 4 and UI and UI.CreatePager and UI.CreateColumns

    if usePager then
        -- Long pages (Combat, Loot): the framework pager with two columns per page.
        -- Rows fill the left column first, then the right.
        local ROWS_PER_PAGE, ROW_STEP = 6, 80
        local pageCount = math.ceil(#rows / ROWS_PER_PAGE)
        local body = CreateFrame("Frame", nil, content)
        body:SetPoint("TOPLEFT", content, "TOPLEFT", 0, dropY)
        body:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 4)

        local pager = UI:CreatePager(body, { pages = pageCount })
        for pageIndex = 1, pageCount do
            local left, right = UI:CreateColumns(pager.frames[pageIndex], 2, { gap = 10 })
            local columns = { left, right }
            local first = (pageIndex - 1) * ROWS_PER_PAGE + 1
            local perColumn = math.ceil(ROWS_PER_PAGE / 2)
            for offset = 0, ROWS_PER_PAGE - 1 do
                local rowInfo = rows[first + offset]
                if rowInfo then
                    local column = columns[math.floor(offset / perColumn) + 1]
                    CreateSoundRow(column, rowInfo, -((offset % perColumn) * ROW_STEP), true)
                end
            end
        end
        content.pager = pager
    else
        for rowIndex, rowInfo in ipairs(rows) do
            CreateSoundRow(content, rowInfo, dropY - (rowIndex - 1) * 80)
        end
    end

    return content
end
