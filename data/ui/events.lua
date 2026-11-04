--=====================================================================================
 -- BLU_Classic - data/ui/events.lua
-- Event sound pages (Level Up, Quest, Reputation, Achievement, Battle Pet).
-- Row layout, colors, and controls mirror BLU / BLU Forever sound_panel.lua:
-- titled card, intro line, then one 68px row per sound with label, current
-- sound, dropdown button, volume track, and Test button.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

-- Menu helpers. The RGX-Framework dropdown module builds, sizes and adds Play buttons to the sound menus.

local function GetDrops()
    local RGX = _G.RGXFramework
    if RGX and type(RGX.GetDropdowns) == "function" then
        return RGX:GetDropdowns()
    end
    return nil
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
        { labelKey = "LEVEL_UP", label = "Level Up", sound = "LevelSoundSelect", volume = "LevelVolume", test = "TestLevelSound", defaultIndex = 4 },
    },
    quest = {
        { labelKey = "QUEST_ACCEPTED", label = "Quest Accepted", sound = "QuestAcceptSoundSelect", volume = "QuestAcceptVolume", test = "TestQuestAcceptSound", defaultIndex = 7 },
        { labelKey = "QUEST_COMPLETE", label = "Quest Complete", sound = "QuestSoundSelect", volume = "QuestVolume", test = "TestQuestSound", defaultIndex = 8 },
    },
    reputation = {
        { labelKey = "REPUTATION_RANK_UP", label = "Reputation Rank Up", sound = "RepSoundSelect", volume = "RepVolume", test = "TestRepSound", defaultIndex = 6 },
    },
    achievement = {
        { labelKey = "ACHIEVEMENT_EARNED", label = "Achievement Earned", sound = "AchievementSoundSelect", volume = "AchievementVolume", test = "TestAchievementSound", defaultIndex = 1 },
    },
    battlepet = {
        { labelKey = "BATTLE_PET_LEVEL_UP", label = "Battle Pet Level Up", sound = "BattlePetLevelSoundSelect", volume = "BattlePetLevelVolume", test = "TestBattlePetLevelSound", defaultIndex = 2 },
    },
}

-- Trigger pages (Combat, Loot, Hardcore, Honor, Collectibles): one row per trigger from
-- data/triggers.lua, built when the page opens so triggers this client cannot fire are left out.
local function RowsFor(eventType)
    local pageTriggers = BLU.TriggerPages and BLU.TriggerPages[eventType]
    if not pageTriggers then
        return EVENT_ROWS[eventType] or {}
    end
    local rows = {}
    for _, trigger in ipairs(pageTriggers) do
        if trigger.available ~= false then
            rows[#rows + 1] = {
                label = trigger.label, sound = trigger.sound, volume = trigger.volume,
                trigger = trigger.id, description = trigger.description, none = true,
            }
        end
    end
    return rows
end

local EVENT_ICONS = {
    hardcore = "Interface\\Icons\\Spell_Shadow_AnimateDead",
    combat = "Interface\\Icons\\Ability_Warrior_Charge",
    loot = "Interface\\Icons\\INV_Misc_Coin_02",
    levelup = "Interface\\Icons\\XP_Icon",
    quest = "Interface\\Icons\\INV_Misc_Note_01",
    reputation = "Interface\\Icons\\Achievement_Reputation_01",
    achievement = "Interface\\Icons\\Achievement_Quests_Completed_08",
    battlepet = "Interface\\Icons\\INV_Pet_BattlePetTraining",
    honor = "Interface\\Icons\\Achievement_PVP_A_A",
    collectibles = "Interface\\Icons\\Ability_Mount_RidingHorse",
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
    honor = "Pick a sound for each PvP rank you reach. Triggers start off.",
    collectibles = "Pick a sound for each new mount, pet, or toy. Triggers start off; events this client does not have are not listed.",
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
    container:SetBackdropColor(Design.Rgba("surface", 0.92))
    container:SetBackdropBorderColor(Design.Rgba("border", 1))

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
    rowLabel:SetTextColor(Design.Rgb("warning"))
    rowLabel:SetText(BLU:GetText(rowInfo.labelKey, rowInfo.label))

    local currentSound = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    currentSound:SetPoint("TOPLEFT", rowLabel, "BOTTOMLEFT", 0, -2)
    currentSound:SetPoint("TOPRIGHT", rowLabel, "BOTTOMRIGHT", 0, -2)
    currentSound:SetJustifyH("LEFT")
    currentSound:SetTextColor(Design.Rgb("brand"))
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
    volLabel:SetTextColor(Design.Rgb("subtext"))
    volLabel:SetPoint("TOP", volButton, "BOTTOM", 0, 2)
    volLabel:Hide()

    volButton:SetScript("OnEnter", function() volLabel:Show() end)
    volButton:SetScript("OnLeave", function() volLabel:Hide() end)

    local volTrack = volumeControl:CreateTexture(nil, "ARTWORK")
    volTrack:SetHeight(4)
    volTrack:SetPoint("LEFT", volButton, "LEFT", 0, 0)
    volTrack:SetPoint("RIGHT", volButton, "RIGHT", 0, 0)
    volTrack:SetPoint("CENTER", volButton, "CENTER", 0, 0)
    volTrack:SetColorTexture(Design.Rgba("border", 1))

    local volFill = volumeControl:CreateTexture(nil, "ARTWORK")
    volFill:SetHeight(4)
    volFill:SetPoint("LEFT", volTrack, "LEFT", 0, 0)
    volFill:SetColorTexture(unpack(Design.Colors.Primary))

    local volThumb = volumeControl:CreateTexture(nil, "ARTWORK")
    volThumb:SetSize(8, 8)
    volThumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    volThumb:SetVertexColor(Design.Rgba("text", 1))

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

    -- Sound menu: the RGX-Framework nested dropdown (2.12.0+) builds the menu, sizes it, and adds
    -- a Play button to each sound. BLU keeps its own trigger look (triggerStyle = "retail").
    local Drops = GetDrops()
    assert(Drops and type(Drops.CreateNestedDropdown) == "function", "RGX-Framework 2.12.0 or newer is required")

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

    local function nameFor(value)
        if isCustomSelection(value) then
            return BLU.UserSounds:GetName(value) or "[Missing sound]"
        elseif value == 0 then
            return "[None]"
        end
        return GetSoundDisplayName(value)
    end

    local soundMenu -- the framework dropdown holder, created below

    local function refreshLabels()
        local value = selectedIndex()
        currentSound:SetText(nameFor(value))
        if soundMenu then
            soundMenu:SetValue(value)
        end
        -- Custom sounds have one file, so the low/medium/high track does not apply
        volumeControl:SetShown(not isCustomSelection(value) and value ~= 0)
        if compact then currentSound:Hide() end
    end

    local function chooseSound(index)
        if BLU.db then
            BLU.db[soundKey] = index
        end
        refreshLabels()
    end

    -- Play one sound at this row's volume. This is the menu's Play button.
    local function previewSound(value)
        if value == nil or value == 0 then return end
        local sample = BLU:SelectSound(value)
        if not sample then return end
        local volumeLevel = BLU.db and BLU.db[rowInfo.volume]
        if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then volumeLevel = 2 end
        local defaultTable = rowInfo.defaultIndex and defaultSounds and defaultSounds[rowInfo.defaultIndex] or nil
        BLU:PlaySelectedSound(sample, volumeLevel, defaultTable)
    end

    -- Menu items: [None] (event rows only offer it on triggers), one row per shipped sound
    -- group, a submenu per multi-variant group, and a submenu of the user's own sounds.
    local function menuItems()
        local items = {}
        local groups = BLU_Classic_SoundGroups or {}
        if rowInfo.none then
            items[#items + 1] = { text = "[None]", value = 0, preview = false }
        end
        for _, group in ipairs(groups) do
            -- Triggers have no shipped default file, so [Default] is not offered there
            if not (rowInfo.none and #group.indices == 1 and group.indices[1] == 1) then
                local displayText, truncated = ShortenLabel(group.name, 46)
                if #group.indices == 1 then
                    items[#items + 1] = {
                        text = displayText,
                        value = group.indices[1],
                        tooltipTitle = truncated and group.name or nil,
                    }
                else
                    local children = {}
                    for variantIndex, index in ipairs(group.indices) do
                        local rawText = group.labels and group.labels[variantIndex] or GetSoundDisplayName(index)
                        local trimmed = TrimVariantLabel(rawText, group.name)
                        local childText, childTruncated = ShortenLabel(trimmed, 60)
                        children[#children + 1] = {
                            text = childText,
                            value = index,
                            tooltipTitle = (childTruncated or trimmed ~= rawText) and rawText or nil,
                        }
                    end
                    items[#items + 1] = {
                        text = displayText .. " (" .. #group.indices .. ")",
                        children = children,
                        notCheckable = true,
                        tooltipTitle = truncated and group.name or nil,
                    }
                end
            end
        end
        local customEntries = BLU.UserSounds and BLU.UserSounds:GetEntries() or {}
        if #customEntries > 0 then
            local children = {}
            for _, entry in ipairs(customEntries) do
                local displayText, truncated = ShortenLabel(entry.name, 60)
                children[#children + 1] = {
                    text = displayText,
                    value = entry.id,
                    tooltipTitle = truncated and entry.name or nil,
                }
            end
            items[#items + 1] = {
                text = "User Custom Sounds (" .. #customEntries .. ")",
                children = children,
                notCheckable = true,
            }
        end
        return items
    end

    soundMenu = Drops:CreateNestedDropdown(container, {
        label = "",
        width = 220,
        buttonWidth = 220,
        value = selectedIndex(),
        items = menuItems,
        triggerStyle = "retail",
        justifyH = "LEFT",
        getValueText = function(value) return nameFor(value) end,
        onChange = function(value) chooseSound(value) end,
        onPreview = function(value) previewSound(value) end,
        previewLabel = "Play",
    })
    assert(soundMenu, "the sound menu could not be created")
    local trigger = soundMenu.retailTrigger

    if compact then
        -- The current sound is already the dropdown text, so the extra line is dropped.
        currentSound:Hide()
        testBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -24)
        soundMenu:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -22)
        soundMenu:SetPoint("TOPRIGHT", testBtn, "TOPLEFT", -8, -2)
        volumeControl:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -54)
        volumeControl:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -54)
    else
        soundMenu:SetPoint("LEFT", container, "LEFT", 10, 0)
        soundMenu:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)
        testBtn:SetPoint("RIGHT", container, "RIGHT", -10, 0)
        testBtn:SetPoint("TOP", currentSound, "BOTTOM", 0, -5)
        volumeControl:SetPoint("CENTER", trigger, "CENTER", 0, 0)
        volumeControl:SetPoint("LEFT", trigger, "RIGHT", 12, 0)
        volumeControl:SetPoint("RIGHT", testBtn, "LEFT", -12, 0)
    end

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
    contentBg:SetColorTexture(Design.Rgba("background", 0.35))

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(Design.Backdrops.Solid)
    titleBar:SetBackdropColor(Design.Rgba("surface", 0.95))
    titleBar:SetBackdropBorderColor(Design.Rgba("border", 1))

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(EVENT_ICONS[eventType] or "Interface\\Icons\\INV_Misc_QuestionMark")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffa" .. eventName .. " Sounds|r")

    -- ON/OFF switch: turns this page's sounds off without clearing the choices.
    local moduleKey = eventType
    local switchFrame = CreateFrame("Frame", nil, titleBar)
    switchFrame:SetSize(44, 20)
    switchFrame:SetPoint("RIGHT", -10, 0)

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

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

    local function RenderSwitch(enabled)
        toggle:ClearAllPoints()
        if enabled then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
            switchBg:SetVertexColor(Design.Rgb("brand"))
            status:SetText("|cff00ff00ON|r")
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
            switchBg:SetVertexColor(Design.Rgb("track"))
            status:SetText("|cffff0000OFF|r")
        end
    end

    toggle:SetScript("OnClick", function()
        local enabled = not BLU:IsModuleEnabled(moduleKey)
        BLU:SetModuleEnabled(moduleKey, enabled)
        RenderSwitch(enabled)
    end)
    RenderSwitch(BLU:IsModuleEnabled(moduleKey))

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(Design.Rgb("subtext"))
    intro:SetText(EVENT_DESCRIPTIONS[eventType] or ("Pick a sound for " .. eventName .. "."))

    local dropY = -102
    local rows = RowsFor(eventType)
    if #rows == 0 then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -102)
        unavailable:SetText("|cff9fb3c8None of these events are available on this game client.|r")
        return content
    end
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
