--=====================================================================================
-- BLU_Classic - data/dropdown_widget.lua
-- Custom AceGUI widget for nested sound selection dropdown
-- Uses BLU_Classic_SoundGroups to render grouped menus with submenus
-- for games that have multiple sound variants (e.g. Elden Ring, Shining Force)
--=====================================================================================

local AceGUI = LibStub("AceGUI-3.0")

local Type = "BLU_Classic_SoundSelect"
local Version = 1

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

        if level == 1 then
            for gi, group in ipairs(groups) do
                local info = UIDropDownMenu_CreateInfo()
                if #group.indices == 1 then
                    -- Single variant group: direct selection (e.g. "[Default]", "Castlevania")
                    local idx = group.indices[1]
                    info.text = group.name
                    info.value = idx
                    info.checked = function() return widget.value == idx end
                    info.func = function()
                        widget.value = idx
                        widget:SetText(GetSoundDisplayName(idx))
                        widget:Fire("OnValueChanged", idx)
                        CloseDropDownMenus()
                    end
                else
                    -- Multi-variant group: opens submenu (e.g. "Elden Ring", "Shining Force")
                    info.text = group.name
                    info.value = gi
                    info.hasArrow = true
                    info.menuList = gi
                    info.notCheckable = true
                end
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 and menuList then
            -- Submenu: show variant labels for the selected group
            local group = groups[menuList]
            if not group then return end
            for vi, idx in ipairs(group.indices) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = group.labels and group.labels[vi] or tostring(vi)
                info.value = idx
                info.checked = function() return widget.value == idx end
                info.func = function()
                    widget.value = idx
                    widget:SetText(GetSoundDisplayName(idx))
                    widget:Fire("OnValueChanged", idx)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
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
