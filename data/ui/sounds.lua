--=====================================================================================
-- BLU_Classic - data/ui/sounds.lua
-- Sounds page. Ported from BLU / BLU Forever core/interface/options/sounds.lua:
-- title bar, intro, "Installed Sound Packs" list on the left, and the "User Custom
-- Sounds" manager on the right (Add Custom Sound, loaded count, Remove per sound).
-- BLU Classic has no SharedMedia pack discovery, so that row is not shown.
--=====================================================================================

local addonName = ...
local ADDON_PATH = "Interface\\AddOns\\" .. (addonName or "BLU_Classic") .. "\\"
local BLU = _G.BLU_Classic
local Design = BLU.Modules["design"]

-- Rebuild every visible page so lists and event dropdowns pick up custom sound changes.
function BLU.RefreshSoundPackUI()
    if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
    if BLU.RefreshOptions then BLU:RefreshOptions() end
end

local function EditBoxOf(dialog)
    return dialog.editBox or dialog.EditBox
end

local function CountBundledSounds()
    local count = 0
    for index = 3, #(soundOptions or {}) do
        if sounds and sounds[index] then
            count = count + 1
        end
    end
    return count
end

local function CountDefaultSets()
    local count = 0
    for _ in pairs(defaultSounds or {}) do
        count = count + 1
    end
    return count
end

-- Add Custom Sound: a framework-styled dialog (same construction as the framework's own
-- name dialogs): themed frame, input box with focus, Enter to add, Escape to close.
local addDialog, addInput, addFeedback

local function SubmitCustomSound()
    local text = (addInput:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        addFeedback:SetText("Enter a file name like myfile or myfile.ogg.")
        return
    end
    local userSounds = BLU.UserSounds
    if not userSounds then
        addFeedback:SetText("User custom sounds are not available yet.")
        return
    end
    local ok, result, resolvedPath = userSounds:Add(text)
    if ok then
        if resolvedPath and text:find("[/\\]") then
            BLU:Print("Added custom sound: " .. tostring(result) .. " (" .. tostring(resolvedPath) .. ")")
        else
            BLU:Print("Added custom sound: " .. tostring(result))
        end
        addDialog:Hide()
        BLU.RefreshSoundPackUI()
    else
        addFeedback:SetText(tostring(result))
    end
end

local function OpenAddCustomSoundDialog()
    local UI = BLU:GetFrameworkUI()
    if not (UI and UI.CreateConfigDialog and UI.CreateButton and UI.CreateLabel) then
        BLU:Print("RGX-Framework 2.12.0 or newer is required to add custom sounds.")
        return
    end

    if not addDialog then
        addDialog = UI:CreateConfigDialog(UIParent, { title = "Add Custom Sound", width = 340, height = 150 })
        addDialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

        addInput = CreateFrame("EditBox", nil, addDialog, "InputBoxTemplate")
        addInput:SetSize(296, 26)
        addInput:SetPoint("TOPLEFT", addDialog, "TOPLEFT", 16, -44)
        addInput:SetAutoFocus(true)
        addInput:SetMaxLetters(255)
        addInput:SetScript("OnEscapePressed", function() addDialog:Hide() end)

        addFeedback = UI:CreateLabel(addDialog, { text = "", width = 308, color = "muted" })
        addFeedback:SetPoint("TOPLEFT", addInput, "BOTTOMLEFT", 0, -4)

        local addButton = UI:CreateButton(addDialog, { text = "Add", width = 80, height = 22,
            onClick = SubmitCustomSound })
        addButton:SetPoint("BOTTOMLEFT", addDialog, "BOTTOMLEFT", 16, 14)
        local cancelButton = UI:CreateButton(addDialog, { text = "Cancel", width = 80, height = 22,
            onClick = function() addDialog:Hide() end })
        cancelButton:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
        addInput:SetScript("OnEnterPressed", function() addButton:Click() end)
        addDialog.addButton = addButton
    end

    addInput:SetText("")
    addFeedback:SetText("Type a short file name like myfile or myfile.ogg, or paste a full Interface\\AddOns path.")
    addDialog:Show()
    addInput:SetFocus()
end

-- Exposed so the options tests can open the same dialog the Add Custom Sound button opens.
BLU.OpenAddCustomSoundDialog = OpenAddCustomSoundDialog

function BLU.CreateSoundsPanel(panel)
    BLU:PrintDebug("[Options/Sounds] Creating Sounds panel")
    -- Wipe existing content
    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local pageBg = content:CreateTexture(nil, "BACKGROUND")
    pageBg:SetAllPoints()
    pageBg:SetColorTexture(Design.Rgba("background", 0.35))

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
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Bell_01")

    local titleLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleLabel:SetText("|cff05dffaSounds|r")

    local intro = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, -64)
    intro:SetPoint("TOPRIGHT", 0, -64)
    intro:SetJustifyH("LEFT")
    intro:SetWordWrap(true)
    intro:SetTextColor(Design.Rgb("subtext"))
    intro:SetText("Browse installed sound packs and manage sounds for the active profile.")

    local pageContent = content

    local installedPanel = CreateFrame("Frame", nil, content, "BackdropTemplate")
    installedPanel:SetPoint("TOPLEFT", pageContent, "TOPLEFT", 0, -102)
    installedPanel:SetPoint("TOPRIGHT", pageContent, "TOP", -12, -102)
    installedPanel:SetPoint("BOTTOMLEFT", pageContent, "BOTTOMLEFT", 0, 5)
    installedPanel:SetBackdrop(Design.Backdrops.Dark)
    installedPanel:SetBackdropColor(Design.Rgba("background", 0.95))
    installedPanel:SetBackdropBorderColor(Design.Rgba("border", 1))

    local scrollFrame = CreateFrame("ScrollFrame", nil, installedPanel, "UIPanelScrollFrameTemplate")
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
        local step = 28
        local maxScroll = math.max(0, (list:GetHeight() or 0) - self:GetHeight())
        local nextValue = current - (delta * step)
        if nextValue < 0 then
            nextValue = 0
        elseif nextValue > maxScroll then
            nextValue = maxScroll
        end
        self:SetVerticalScroll(nextValue)
    end)

    local header = Design:CreateHeader(list, "Installed Sound Packs", "Interface\\Icons\\INV_Misc_Bag_33")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)

    local headerNote = list:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerNote:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -6)
    headerNote:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -12, -6)
    headerNote:SetJustifyH("LEFT")
    headerNote:SetWordWrap(true)
    headerNote:SetTextColor(Design.Rgb("subtext"))
    headerNote:SetText("BLU lists its built-in libraries and your manually added custom sounds.")

    local startY = -72
    local columnXStart = 10
    local columnWidth = 244
    local rowStep = 45

    local function createPackEntry(parent, pack, x, y)
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(columnWidth, 40)
        frame:SetPoint("TOPLEFT", x, y)

        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(pack.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

        local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.name = name
        name:SetPoint("LEFT", icon, "RIGHT", 10, 5)
        name:SetText(pack.name or "Unknown Pack")

        local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        status:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
        status:SetText(pack.status or "|cff00ff00Loaded|r")

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(pack.name or "Unknown Pack", 1, 1, 1)
            GameTooltip:AddLine((pack.status or "Status unavailable"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""), 0.02, 0.87, 0.98, true)
            GameTooltip:AddLine("Registered sounds: " .. tostring(pack.soundCount or 0), 0.82, 0.82, 0.82, true)
            if pack.id == "wow_default_blu" then
                GameTooltip:AddLine("BLU's built-in Warcraft-style defaults.", 0.82, 0.82, 0.82, true)
            elseif pack.id == "other_games_blu" then
                GameTooltip:AddLine("BLU's built-in game sound library with low, medium, and high variants.", 0.82, 0.82, 0.82, true)
            elseif pack.id == "user_custom_sounds" then
                GameTooltip:AddLine("Sounds you added manually from the Sounds tab.", 0.82, 0.82, 0.82, true)
            end
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", GameTooltip_Hide)

        return frame
    end

    local customEntries = {}
    if BLU.UserSounds then
        customEntries = BLU.UserSounds:GetEntries()
    end
    local customSoundCount = #customEntries

    local packRows = {
        {
            id = "wow_default_blu",
            name = "wow default-blu",
            icon = ADDON_PATH .. "media\\icon.tga",
            status = "|cff05dffaBLU defaults|r",
            soundCount = CountDefaultSets(),
        },
        {
            id = "other_games_blu",
            name = "other games-blu",
            icon = ADDON_PATH .. "media\\icon.tga",
            status = "|cff05dffaBLU game library|r",
            soundCount = CountBundledSounds(),
        },
        {
            id = "user_custom_sounds",
            name = "user custom sounds",
            icon = "Interface\\Icons\\INV_Misc_Coin_18",
            status = customSoundCount > 0 and "|cff00ff00Loaded|r" or "|cffffaa00No user custom sounds loaded|r",
            soundCount = customSoundCount,
        },
    }

    for index, pack in ipairs(packRows) do
        local frame = createPackEntry(list, pack, columnXStart, startY - ((index - 1) * rowStep))
        frame.name:SetText(pack.name .. " (" .. pack.soundCount .. ")")
    end

    list:SetHeight(math.abs(startY) + (#packRows * rowStep) + 50)
    BLU:PrintDebug("[Options/Sounds] Rendered " .. tostring(#packRows) .. " sound pack entries")

    local managerPanel = CreateFrame("Frame", nil, content, "BackdropTemplate")
    managerPanel:SetPoint("TOPLEFT", pageContent, "TOP", 12, -102)
    managerPanel:SetPoint("TOPRIGHT", pageContent, "TOPRIGHT", -10, -102)
    managerPanel:SetPoint("BOTTOMRIGHT", pageContent, "BOTTOMRIGHT", -10, 5)
    managerPanel:SetBackdrop(Design.Backdrops.Dark)
    managerPanel:SetBackdropColor(Design.Rgba("background", 0.95))
    managerPanel:SetBackdropBorderColor(Design.Rgba("border", 1))

    local managerHeader = Design:CreateHeader(managerPanel, "User Custom Sounds", "Interface\\Icons\\INV_Misc_Coin_18")
    managerHeader:SetPoint("TOPLEFT", 8, -8)
    managerHeader:SetPoint("TOPRIGHT", -8, -8)

    local managerNote = managerPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    managerNote:SetPoint("TOPLEFT", managerHeader, "BOTTOMLEFT", 4, -8)
    managerNote:SetPoint("TOPRIGHT", managerHeader, "BOTTOMRIGHT", -4, -8)
    managerNote:SetJustifyH("LEFT")
    managerNote:SetWordWrap(true)
    managerNote:SetTextColor(Design.Rgb("subtext"))
    managerNote:SetText("Add .ogg, .mp3, or .wav files from an AddOns sound folder. Enter a filename such as victory.ogg, or paste its full Interface\\AddOns path. These sounds belong to the active profile; select them on an event page after adding them here.")

    local addButton = Design:CreateActionButton(
        managerPanel,
        "Add Custom Sound",
        140,
        24,
        "Add Custom Sound",
        "Type a short file name like myfile or myfile.ogg.\nOr paste a full Interface\\\\AddOns path.\nBLU will search common custom-sound folders automatically."
    )
    addButton:SetPoint("TOPLEFT", managerNote, "BOTTOMLEFT", 0, -10)
    addButton:SetScript("OnClick", function()
        BLU:PrintDebug("[Options/Sounds] Add Custom Sound button clicked")
        OpenAddCustomSoundDialog()
    end)

    local countLabel = managerPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countLabel:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
    countLabel:SetTextColor(Design.Rgb("subtext"))
    countLabel:SetText("Loaded: " .. tostring(customSoundCount))

    local listFrame = CreateFrame("ScrollFrame", nil, managerPanel, "UIPanelScrollFrameTemplate")
    listFrame:SetPoint("TOPLEFT", addButton, "BOTTOMLEFT", 0, -12)
    listFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    listFrame:EnableMouseWheel(true)

    if listFrame.ScrollBar then
        listFrame.ScrollBar:Hide()
        listFrame.ScrollBar.Show = function() end
    end

    local listContent = CreateFrame("Frame", nil, listFrame)
    listContent:SetWidth(294)
    listFrame:SetScrollChild(listContent)
    listFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 28
        local maxScroll = math.max(0, (listContent:GetHeight() or 0) - self:GetHeight())
        local nextValue = current - (delta * step)
        if nextValue < 0 then
            nextValue = 0
        elseif nextValue > maxScroll then
            nextValue = maxScroll
        end
        self:SetVerticalScroll(nextValue)
    end)

    if #customEntries == 0 then
        local emptyText = listContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        emptyText:SetPoint("TOPLEFT", 4, -4)
        emptyText:SetPoint("RIGHT", -4, 0)
        emptyText:SetJustifyH("LEFT")
        emptyText:SetTextColor(Design.Rgb("subtext"))
        emptyText:SetText("No user custom sounds are loaded.")
        listContent:SetHeight(40)
    else
        local rowHeight = 48
        for index, entry in ipairs(customEntries) do
            local row = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
            row:SetPoint("TOPLEFT", 0, -((index - 1) * (rowHeight + 6)))
            row:SetWidth(294)
            row:SetHeight(rowHeight)
            row:SetBackdrop(Design.Backdrops.Solid)
            row:SetBackdropColor(Design.Rgba("surface", 0.90))
            row:SetBackdropBorderColor(Design.Rgba("border", 1))

            local soundName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            soundName:SetPoint("TOPLEFT", 8, -6)
            soundName:SetPoint("RIGHT", -88, 0)
            soundName:SetJustifyH("LEFT")
            soundName:SetText(entry.name or "Custom Sound")

            local soundPath = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            soundPath:SetPoint("TOPLEFT", soundName, "BOTTOMLEFT", 0, -2)
            soundPath:SetPoint("RIGHT", -88, 0)
            soundPath:SetJustifyH("LEFT")
            soundPath:SetTextColor(Design.Rgb("subtext"))
            soundPath:SetText(entry.file or "")

            local removeButton = Design:CreateButton(row, "Remove", 68, 22)
            removeButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, -11)
            removeButton:SetFrameStrata("HIGH")
            removeButton:Show()
            if removeButton.label then
                removeButton.label:SetTextColor(Design.Rgb("error"))
            end
            removeButton:SetScript("OnClick", function()
                local ok, err = BLU.UserSounds:Remove(entry.file)
                if ok then
                    BLU:Print("Removed custom sound: " .. tostring(entry.name))
                    BLU.RefreshSoundPackUI()
                else
                    BLU:Print("Failed to remove custom sound: " .. tostring(err))
                end
            end)
        end

        listContent:SetHeight((#customEntries * (rowHeight + 6)) + 4)
    end

    return content
end
