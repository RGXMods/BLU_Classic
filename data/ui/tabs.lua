--=====================================================================================
-- BLU_Classic - data/ui/tabs.lua
-- Tab strip layout, tab buttons, and the Classic tab spec. Layout and button code
-- mirror BLU / BLU Forever core/interface/options/tabs.lua.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]
local Tabs = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["tabs"] = Tabs

local TAB_BUTTON_WIDTH_CORE = 94
local TAB_BUTTON_WIDTH_WIDE = 100
local TAB_BUTTON_HEIGHT = 22
local TAB_SPACING = 6
local TAB_ROW_PADDING = 8
local TAB_ROW_SPACING = 3
local TAB_COLUMNS_PER_ROW = 6
-- Section gap: event columns (col >= 3) shift right so the 1px divider
-- has symmetric breathing room on both sides (settings | pipe | events).
local TAB_SECTION_GAP = 6

local function GetTabRowWidth()
    -- 1 core column + 5 wide columns + spacing + 16px gutter
    return TAB_BUTTON_WIDTH_CORE + (5 * TAB_BUTTON_WIDTH_WIDE) + (5 * TAB_SPACING) + 16
end

-- Dynamic tab strip layout ---------------------------------------------------
-- The strip derives its geometry from the live spec table and the container's
-- actual width instead of the legacy fixed col-based xOffset math. Buttons are
-- laid out left-to-right at fixed widths/spacing and wrap onto a new row
-- (aligned to the same left edge) when the next button would not fit at the
-- container's current width. The legacy per-tab `row`/`col` spec fields are
-- kept for compatibility but are hints only; positions come from this
-- layout pass.
--
-- Layout model (matches the legacy single-row rendering when everything fits
-- on one row):
--   * first button of the strip: x = TAB_ROW_PADDING, width = CORE (94)
--   * every other button:        x = prev right edge + TAB_SPACING (6),
--                                width = WIDE (100)
--   * every button:             y = -6 - (row-1) * (22 + 3)
--
-- The legacy per-button math in UpdatePosition was:
--   col 1: x = 8,  width 94
--   col>1: x = 8 + 94 + 6 + (col-2)*(100+6) = 108 + (col-2)*106, width 100
-- so buttons sit at x = 8, 118, 224, 330, ... The gap after the CORE button
-- is a 16px gutter; every later WIDE button is 6px after the previous one.
-- The dynamic pass reproduces exactly this sequence and wraps to the next
-- row (same left edge and spacing) when the next button would not fit at
-- the container's current width.

-- Compute the layout for the live spec. The spec's row/col fields are the
-- authoritative fixed-grid geometry (operator review 2026-09-28 rev 3: BLU's
-- original column/row alignment, with rows subtracted to two and tabs
-- shifted — no custom flow, no adaptive widths):
--   col 1: x = 8,    width = CORE (94)
--   col>1: x = 118 + (col-2) * 106, width = WIDE (100)
--   row r: y = -6 - (r-1) * 25
-- Buttons hidden by the flavors hook (hidden = true) are skipped.
local function ComputeTabLayout(containerWidth)
    local layout = { buttons = {}, rows = 1 }
    if not BLU.OptionsTabs then
        return layout
    end
    local maxRow = 1
    for index, tabInfo in ipairs(BLU.OptionsTabs) do
        if not tabInfo.hidden then
            local col = tonumber(tabInfo.col) or 1
            local row = tonumber(tabInfo.row) or 1
            local x, width
            if col <= 1 then
                x = TAB_ROW_PADDING
                width = TAB_BUTTON_WIDTH_CORE
            else
                x = TAB_ROW_PADDING + TAB_BUTTON_WIDTH_CORE + TAB_SPACING + (col - 2) * (TAB_BUTTON_WIDTH_WIDE + TAB_SPACING)
                if col >= 3 then
                    x = x + TAB_SECTION_GAP
                end
                width = TAB_BUTTON_WIDTH_WIDE
            end
            local y = -6 - (row - 1) * (TAB_BUTTON_HEIGHT + TAB_ROW_SPACING)
            layout.buttons[#layout.buttons + 1] = {
                index = index,
                x = x,
                y = y,
                width = width,
                row = row,
            }
            if row > maxRow then
                maxRow = row
            end
        end
    end
    layout.rows = maxRow
    return layout
end

-- Generic "coming soon" placeholder panel — used by Combat, Collectibles, Loot, and Prey

function Tabs:GetRowCount()
    -- Dynamic layout: row count comes from the wrapped layout for the live
    -- spec at the tab container's current width. Falls back to the legacy
    -- spec `row` hints when no container has been wired yet (so callers that
    -- run before CreateOptionsPanel still get a sane height).
    if self.container and self.container.GetWidth then
        local ok, width = pcall(self.container.GetWidth, self.container)
        if ok and type(width) == "number" and width > 0 then
            return ComputeTabLayout(width).rows
        end
    end
    local maxRow = 1
    if BLU.OptionsTabs then
        for _, tabInfo in ipairs(BLU.OptionsTabs) do
            if tabInfo.row and tabInfo.row > maxRow and not tabInfo.hidden then
                maxRow = tabInfo.row
            end
        end
    end
    return maxRow
end

function Tabs:GetContainerHeight()
    return 10 + (self:GetRowCount() * TAB_BUTTON_HEIGHT) + ((self:GetRowCount() - 1) * TAB_ROW_SPACING) + 6
end

-- Wire the strip's container frame. Called by CreateOptionsPanel after the
-- tabContainer exists; GetRowCount then reflects the wrapped layout at the
-- container's live width.
function Tabs:SetContainer(container)
    self.container = container
end

-- Recompute the dynamic layout for the live spec at the container's current
-- width and apply it to every tab button. Idempotent; safe to call on every
-- OnSizeChanged and after any spec change (tab add/remove). Buttons whose
-- spec entry is hidden are hidden; all others are shown and repositioned.
-- Returns the computed row count.
function Tabs:RefreshLayout()
    if not self.container then return nil end
    local width = self.container:GetWidth()
    if not width or width <= 0 then return nil end

    local layout = ComputeTabLayout(width)
    local applied = {}
    for _, entry in ipairs(layout.buttons) do
        local button = self.buttons and self.buttons[entry.index]
        if button then
            button.tabX = entry.x
            button.tabLayoutRow = entry.row
            button.tabWidth = entry.width
            button:UpdatePosition()
            button:Show()
            applied[entry.index] = true
        end
    end
    -- Buttons whose spec entry is hidden (flavor-gated out) stay hidden.
    if self.buttons then
        for index, button in ipairs(self.buttons) do
            if not applied[index] then
                button:Hide()
            end
        end
    end
    self.layoutRows = layout.rows
    return layout.rows
end


-- Create a tab button (alpha.3 style)
function BLU.CreateTabButton(parent, text, index, row, col, panel, icon)
    local buttonName = "BLUTab" .. tostring(index) .. text:gsub("%W", "")
    local button = CreateFrame("Button", buttonName, parent)
    button:SetSize(TAB_BUTTON_WIDTH_CORE, TAB_BUTTON_HEIGHT)
    -- Legacy spec hints, kept for compatibility; the dynamic layout pass
    -- (Tabs:RefreshLayout) owns the actual geometry.
    button.tabRow = row
    button.tabCol = col
    button.isPlaceholder = false

    -- Dynamic position/width for this button, computed from the live spec
    -- and the container's actual width by ComputeTabLayout. Until the first
    -- strip-level layout pass runs (Tabs:RefreshLayout), fall back to the
    -- legacy fixed row/col math so the button renders exactly where the old
    -- code put it; once the dynamic pass has run, tabX/tabLayoutRow/tabWidth
    -- own the geometry.
    local function legacyPosition(self)
        if self.tabCol == 1 then
            return TAB_ROW_PADDING, TAB_BUTTON_WIDTH_CORE
        end
        local x = TAB_ROW_PADDING + TAB_BUTTON_WIDTH_CORE + TAB_SPACING + (self.tabCol - 2) * (TAB_BUTTON_WIDTH_WIDE + TAB_SPACING)
        if self.tabCol >= 3 then
            x = x + TAB_SECTION_GAP
        end
        return x, TAB_BUTTON_WIDTH_WIDE
    end

    function button:UpdatePosition()
        local xOffset, width
        if self.tabX ~= nil then
            xOffset, width = self.tabX, (self.tabWidth or TAB_BUTTON_WIDTH_CORE)
        else
            xOffset, width = legacyPosition(self)
        end
        local layoutRow = self.tabLayoutRow or self.tabRow or 1
        local yOffset = -10 - (layoutRow - 1) * (TAB_BUTTON_HEIGHT + TAB_ROW_SPACING)
        self:SetWidth(width)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    end

    button:UpdatePosition()
    button:HookScript("OnShow", function(self)
        self:UpdatePosition()
    end)
    -- Container width changes re-wrap the whole strip; the strip-level
    -- RefreshLayout hook below triggers this button's reposition too.

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(Design.Rgba("surface", 0.90))
    button.bg = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(Design.Rgba("border", 1))
    button.border = border

    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if icon then
        local iconTexture = button:CreateTexture(nil, "ARTWORK")
        iconTexture:SetSize(14, 14)
        iconTexture:SetPoint("LEFT", 6, 0)
        iconTexture:SetTexture(icon)
        button.icon = iconTexture

        buttonText:SetPoint("LEFT", iconTexture, "RIGHT", 4, 0)
        buttonText:SetPoint("RIGHT", -4, 0)
        buttonText:SetJustifyH("LEFT")
    else
        buttonText:SetPoint("CENTER", 0, 0)
    end
    buttonText:SetText(text)
    buttonText:SetTextColor(Design.Rgba("text", 1))
    button.text = buttonText

    button:SetScript("OnClick", function(self)
        BLU:PrintDebug("[Tabs] Clicked tab '" .. tostring(text) .. "' (" .. tostring(self.tabIndex) .. ")")
        panel:SelectTab(self.tabIndex)
    end)

    button:SetScript("OnEnter", function(self)
        BLU:PrintDebug("[Tabs] Hover enter on tab '" .. tostring(text) .. "'")
        if self.greyed or self.isPlaceholder then return end
        if not self.isActive then
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
        end
    end)

    button:SetScript("OnLeave", function(self)
        BLU:PrintDebug("[Tabs] Hover leave on tab '" .. tostring(text) .. "'")
        if self.greyed or self.isPlaceholder then return end
        if not self.isActive then
            self.border:SetBackdropBorderColor(Design.Rgba("track", 1))
            self.text:SetTextColor(Design.Rgba("subtext", 1))
        end
    end)

    button.tabIndex = index

    function button:SetActive(active)
        self.isActive = active
        if self.isPlaceholder then
            if active then
                self.bg:SetColorTexture(Design.Rgba("surface", 0.90))
                self.text:SetTextColor(Design.Rgba("subtext", 1))
                self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            else
                self.bg:SetColorTexture(Design.Rgba("background", 0.55))
                self.text:SetTextColor(Design.Rgba("subtext", 1))
                self.border:SetBackdropBorderColor(Design.Rgba("border", 1))
            end
            if self.icon then
                self.icon:SetDesaturated(true)
                self.icon:SetAlpha(active and 0.75 or 0.45)
            end
            return
        end
        if active then
            self.bg:SetColorTexture(Design.Rgba("hover", 1))
            self.text:SetTextColor(unpack(BLU.Modules.design.Colors.Primary))
            self.border:SetBackdropBorderColor(unpack(BLU.Modules.design.Colors.Primary))
            if self.icon then
                self.icon:SetDesaturated(false)
                self.icon:SetAlpha(1)
            end
        else
            self.bg:SetColorTexture(Design.Rgba("surface", 0.90))
            self.text:SetTextColor(Design.Rgba("subtext", 1))
            self.border:SetBackdropBorderColor(Design.Rgba("border", 1))
            if self.icon then
                self.icon:SetDesaturated(false)
                self.icon:SetAlpha(0.95)
            end
        end
    end

    function button:SetPlaceholder(placeholder)
        self.isPlaceholder = placeholder == true
        self:SetEnabled(true)
        self:SetActive(false)
    end

    return button
end

--=====================================================================================
-- Classic tab spec
--=====================================================================================
-- Same geometry as BLU / BLU Forever: a fixed two-row grid with General, Profiles,
-- Debug, and Sounds in columns 1-2, the pipe divider, then the event tabs from
-- column 3. Event tabs for features the running client does not have are left out,
-- so the number of tab buttons matches the client.

function Tabs:Init()
    -- Panel builders are resolved lazily: they load after this file.
    local function general(p) return BLU.CreateGeneralPanel(p) end
    local function profiles(p) return BLU.CreateProfilesPanel(p) end
    local function debugPanel(p) return BLU.CreateDebugPanel(p) end
    local function sounds(p) return BLU.CreateSoundsPanel(p) end

    local spec = {
        -- Row 1
        {text = "General",     create = general,  row = 1, col = 1, icon = "Interface\\Icons\\INV_Misc_Gear_08"},
        {text = "Profiles",    create = profiles, row = 1, col = 2, icon = "Interface\\Icons\\Ability_Marksmanship"},
        {text = "Level Up",    eventType = "levelup",     row = 1, col = 3, feature = "Level",       icon = "Interface\\Icons\\Achievement_Level_100"},
        {text = "Quest",       eventType = "quest",       row = 1, col = 4, feature = "Quest",       icon = "Interface\\Icons\\INV_Misc_Note_01"},
        {text = "Combat",      eventType = "combat",      row = 1, col = 5, feature = "Combat",      icon = "Interface\\Icons\\Ability_Warrior_Charge"},
        -- Row 2
        {text = "Debug",       create = debugPanel, row = 2, col = 1, icon = "Interface\\Icons\\INV_Misc_Gear_03"},
        {text = "Sounds",      create = sounds,     row = 2, col = 2, icon = "Interface\\Icons\\INV_Misc_Bell_01"},
        {text = "Reputation",  eventType = "reputation",  row = 2, col = 3, feature = "Reputation",  icon = "Interface\\Icons\\Achievement_Reputation_01"},
        {text = "Loot",        eventType = "loot",        row = 2, col = 4, feature = "Loot",        icon = "Interface\\Icons\\INV_Misc_Coin_02"},
        {text = "Hardcore",    eventType = "hardcore",    row = 2, col = 5, feature = "Hardcore",    icon = "Interface\\Icons\\Spell_Shadow_AnimateDead"},
        -- Column 6 of rows 1 and 2, one per row. The strip stays two rows.
        {text = "Honor",       eventType = "honor",       row = 1, col = 6, feature = "Honor",       icon = "Interface\\Icons\\Achievement_PVP_A_A"},
        {text = "Collectibles", eventType = "collectibles", row = 2, col = 6, feature = "Collectibles", icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"},
    }

    BLU.OptionsTabs = {}
    local occupied = {}
    for _, tabInfo in ipairs(spec) do
        local featureOk = not tabInfo.feature or BLU:IsFeatureAvailable(tabInfo.feature)
        local pageOk = not tabInfo.eventType or not BLU.TriggerPages[tabInfo.eventType]
            or BLU:PageHasUsableTriggers(tabInfo.eventType)
        local slot = tabInfo.row .. ":" .. tabInfo.col
        if featureOk and pageOk and not occupied[slot] then
            occupied[slot] = true
            BLU.OptionsTabs[#BLU.OptionsTabs + 1] = tabInfo
        end
    end

    BLU:PrintDebug("[Tabs] Registered " .. #BLU.OptionsTabs .. " tabs")
end

Tabs:Init()
