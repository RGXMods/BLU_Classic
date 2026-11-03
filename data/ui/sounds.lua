--=====================================================================================
-- BLU_Classic - data/ui/sounds.lua
-- Sounds page. Mirrors BLU / BLU Forever: title bar, intro, a scrolling list of the
-- installed sounds on the left, details on the right. BLU_Classic ships one fixed
-- library (no sound-pack manager), so the list previews the bundled sounds.
--=====================================================================================

local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

local ROW_HEIGHT = 28

local function SoundDisplayName(index)
    local groupIndex = BLU_Classic_IndexToGroup and BLU_Classic_IndexToGroup[index]
    local group = groupIndex and BLU_Classic_SoundGroups and BLU_Classic_SoundGroups[groupIndex]
    if not group then
        return soundOptions and soundOptions[index] or tostring(index)
    end
    if #group.indices == 1 then
        return group.name
    end
    local variant = BLU_Classic_IndexToVariant and BLU_Classic_IndexToVariant[index]
    local label = group.labels and group.labels[variant] or tostring(variant)
    return group.name .. " - " .. label
end

-- Every previewable sound index (1 = [Default], 2 = [Random] are selection modes).
local function CollectSoundIndices()
    local indices = {}
    for index = 3, #(soundOptions or {}) do
        if sounds and sounds[index] then
            indices[#indices + 1] = index
        end
    end
    return indices
end

function BLU.CreateSoundsPanel(panel)
    BLU:PrintDebug("[Options/Sounds] Creating Sounds panel")

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
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Bell_01")

    local titleLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleLabel:SetText("|cff05dffaSounds|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(0.6, 0.66, 0.72)
    intro:SetText("Browse and preview the sounds bundled with BLU Classic.")

    local indices = CollectSoundIndices()

    -- Left: scrolling list
    local listPanel = CreateFrame("Frame", nil, content, "BackdropTemplate")
    listPanel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -102)
    listPanel:SetPoint("TOPRIGHT", content, "TOP", -12, -102)
    listPanel:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 5)
    listPanel:SetBackdrop(Design.Backdrops.Dark)
    listPanel:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
    listPanel:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    scrollFrame:EnableMouseWheel(true)

    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:Hide()
        scrollFrame.ScrollBar.Show = function() end
    end

    local list = CreateFrame("Frame", nil, scrollFrame)
    list:SetWidth(284)
    scrollFrame:SetScrollChild(list)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local maxScroll = math.max(0, (list:GetHeight() or 0) - self:GetHeight())
        local nextValue = current - (delta * ROW_HEIGHT)
        if nextValue < 0 then nextValue = 0 elseif nextValue > maxScroll then nextValue = maxScroll end
        self:SetVerticalScroll(nextValue)
    end)

    local header = Design:CreateHeader(list, "Bundled Sounds", "Interface\\Icons\\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)

    local rowTop = -40
    for position, index in ipairs(indices) do
        local row = CreateFrame("Frame", nil, list)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 0, rowTop - (position - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", 0, rowTop - (position - 1) * ROW_HEIGHT)

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", 8, 0)
        name:SetPoint("RIGHT", -64, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        name:SetText(SoundDisplayName(index))

        local play = Design:CreateActionButton(row, "Play", 52, 20)
        play:SetPoint("RIGHT", -4, 0)
        play:SetScript("OnClick", function()
            local files = sounds and sounds[index]
            local file = files and (files[2] or files[1] or files[3])
            if file then
                PlaySoundFile(file, "MASTER")
            end
        end)
    end
    list:SetHeight(math.abs(rowTop) + #indices * ROW_HEIGHT + 8)

    -- Right: details
    local aboutSection = Design:CreateSection(content, "About Sounds", "Interface\\Icons\\INV_Misc_Book_09")
    aboutSection:SetPoint("TOPLEFT", content, "TOP", 12, -102)
    aboutSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -102)
    aboutSection:SetHeight(190)

    local count = aboutSection.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    count:SetPoint("TOPLEFT", 8, -8)
    count:SetText("|cff05dffa" .. tostring(#indices) .. "|r bundled sounds from more than 50 games")

    local note = aboutSection.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", count, "BOTTOMLEFT", 0, -10)
    note:SetPoint("RIGHT", aboutSection.content, "RIGHT", -8, 0)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetTextColor(0.72, 0.78, 0.86)
    note:SetText("Use Play to hear a sound at medium volume. Choose the sound and volume for each event on the Level Up, Quest, and Reputation pages.")

    return content
end
