--=====================================================================================
-- BLU_Classic - data/dropdown_widget.lua
-- Custom AceGUI widget for nested sound selection dropdown
-- Uses BLU_Classic_SoundGroups to render grouped menus with submenus
-- for games that have multiple sound variants (e.g. Elden Ring, Shining Force)
--=====================================================================================

local AceGUI = LibStub("AceGUI-3.0")

local Type = "BLU_Classic_SoundSelect"
local Version = 1
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
    C_Timer.After(0, function()
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

--[[ Constructor ]]--
local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", nil, UIParent)
    local dropdown = CreateFrame("Frame", "BLU_Classic_SoundDD" .. count, frame, "UIDropDownMenuTemplate")

    local widget = {}
    widget.type = Type
    widget.frame = frame
    widget.dropdown = dropdown
    widget.count = count
    frame.obj = widget
    dropdown.obj = widget
    widget.alignoffset = 26

    frame:SetScript("OnHide", function()
        CloseDropDownMenus()
    end)

    dropdown:ClearAllPoints()
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
    dropdown:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 17, 0)
    dropdown:SetScript("OnHide", nil)

    local left = _G[dropdown:GetName() .. "Left"]
    local middle = _G[dropdown:GetName() .. "Middle"]
    local right = _G[dropdown:GetName() .. "Right"]
    middle:ClearAllPoints()
    right:ClearAllPoints()
    middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
    middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
    right:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", 0, 17)

    local button = _G[dropdown:GetName() .. "Button"]
    widget.button = button
    button.obj = widget

    local text = _G[dropdown:GetName() .. "Text"]
    widget.text = text
    text:ClearAllPoints()
    text:SetPoint("RIGHT", right, "RIGHT", -43, 2)
    text:SetPoint("LEFT", left, "LEFT", 25, 2)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetHeight(18)
    label:Hide()
    widget.label = label

    local buttonCover = CreateFrame("Button", nil, frame)
    widget.button_cover = buttonCover
    buttonCover.obj = widget
    buttonCover:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 25)
    buttonCover:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

    -- Initialize UIDropDownMenu with nested group support
    UIDropDownMenu_Initialize(dropdown, function(ddFrame, level, menuList)
        level = level or 1
        local groups = BLU_Classic_SoundGroups
        if not groups then return end
        local baseWidth = math.floor(dropdown:GetWidth())
        if baseWidth < 100 then
            baseWidth = 220
        end

        local function getMinWidthForLevel(levelToUse)
            if (levelToUse or 1) <= 1 then
                return baseWidth
            end

            return math.max(160, math.floor(baseWidth * 0.72))
        end

        local function getLeftInsetForLevel(levelToUse)
            if (levelToUse or 1) <= 1 then
                return 24
            end

            return 10
        end

        HideInlineCountLabels(level)

        if level == 1 then
            for gi, group in ipairs(groups) do
                local info = UIDropDownMenu_CreateInfo()
                if #group.indices == 1 then
                    -- Single variant group: direct selection (e.g. "[Default]", "Castlevania")
                    local idx = group.indices[1]
                    local displayText, wasTruncated = ShortenLabel(group.name, 46)
                    info.text = displayText
                    info.value = idx
                    info.checked = function() return widget.value == idx end
                    info.func = function()
                        widget.value = idx
                        widget:SetText(GetSoundDisplayName(idx))
                        widget:Fire("OnValueChanged", idx)
                        CloseDropDownMenus()
                    end
                    if wasTruncated then
                        info.tooltipTitle = group.name
                    end
                else
                    -- Multi-variant group: opens submenu (e.g. "Elden Ring", "Shining Force")
                    local displayText, wasTruncated = ShortenLabel(group.name, 46)
                    info.text = displayText
                    info.value = gi
                    info.hasArrow = true
                    info.menuList = gi
                    info.notCheckable = true
                    if wasTruncated then
                        info.tooltipTitle = group.name
                    end
                end
                UIDropDownMenu_AddButton(info, level)
                if #group.indices > 1 then
                    AttachInlineCountLabel(level, "(" .. #group.indices .. ")")
                end
            end
        elseif level == 2 and menuList then
            -- Submenu: show variant labels for the selected group
            local group = groups[menuList]
            if not group then return end
            for vi, idx in ipairs(group.indices) do
                local info = UIDropDownMenu_CreateInfo()
                local rawText = group.labels and group.labels[vi] or GetSoundDisplayName(idx)
                local trimmedText = TrimVariantLabel(rawText, group.name)
                local displayText, wasTruncated = ShortenLabel(trimmedText, 60)
                info.text = displayText
                info.value = idx
                info.checked = function() return widget.value == idx end
                info.func = function()
                    widget.value = idx
                    widget:SetText(GetSoundDisplayName(idx))
                    widget:Fire("OnValueChanged", idx)
                    CloseDropDownMenus()
                end
                if wasTruncated or trimmedText ~= rawText then
                    info.tooltipTitle = rawText
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end

        ForceListFrameWidth(level, getMinWidthForLevel(level), getLeftInsetForLevel(level))
    end)

    -- Button click toggles the dropdown menu
    local function ToggleMenu()
        ToggleDropDownMenu(1, nil, dropdown, dropdown, 0, 0)
    end

    button:SetScript("OnEnter", function(self)
        widget.button:LockHighlight()
        widget:Fire("OnEnter")
    end)
    button:SetScript("OnLeave", function(self)
        widget.button:UnlockHighlight()
        widget:Fire("OnLeave")
    end)
    button:SetScript("OnClick", ToggleMenu)
    buttonCover:SetScript("OnEnter", function(self)
        widget.button:LockHighlight()
        widget:Fire("OnEnter")
    end)
    buttonCover:SetScript("OnLeave", function(self)
        widget.button:UnlockHighlight()
        widget:Fire("OnLeave")
    end)
    buttonCover:SetScript("OnClick", ToggleMenu)

    --[[ Widget Methods ]]--

    function widget:OnAcquire()
        self:SetHeight(44)
        self:SetWidth(200)
        self:SetLabel()
        self.list = {}
    end

    function widget:OnRelease()
        CloseDropDownMenus()
        self:SetText("")
        self:SetDisabled(false)
        self.value = nil
        self.list = nil
        self.frame:ClearAllPoints()
        self.frame:Hide()
    end

    function widget:SetDisabled(disabled)
        self.disabled = disabled
        if disabled then
            self.text:SetTextColor(0.5, 0.5, 0.5)
            self.button:Disable()
            self.button_cover:Disable()
            self.label:SetTextColor(0.5, 0.5, 0.5)
        else
            self.button:Enable()
            self.button_cover:Enable()
            self.label:SetTextColor(1, 0.82, 0)
            self.text:SetTextColor(1, 1, 1)
        end
    end

    function widget:ClearFocus()
        CloseDropDownMenus()
    end

    function widget:SetText(newText)
        self.text:SetText(newText or "")
    end

    function widget:SetLabel(newLabel)
        if newLabel and newLabel ~= "" then
            self.label:SetText(newLabel)
            self.label:Show()
            self.dropdown:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -15, -14)
            self:SetHeight(40)
            self.alignoffset = 26
        else
            self.label:SetText("")
            self.label:Hide()
            self.dropdown:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -15, 0)
            self:SetHeight(26)
            self.alignoffset = 12
        end
    end

    function widget:SetValue(value)
        self.value = value
        self:SetText(GetSoundDisplayName(value))
    end

    function widget:GetValue()
        return self.value
    end

    -- SetList is called by AceConfig with the flat soundOptions table.
    -- We ignore it since we render from BLU_Classic_SoundGroups instead.
    function widget:SetList(list, order, itemType)
        self.list = list or {}
    end

    -- Stubs required by AceConfig's dropdown interface
    function widget:SetItemValue() end
    function widget:SetItemDisabled() end
    function widget:SetMultiselect() end
    function widget:GetMultiselect() return false end
    function widget:SetPulloutWidth() end
    function widget:AddItem() end

    AceGUI:RegisterAsWidget(widget)
    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
