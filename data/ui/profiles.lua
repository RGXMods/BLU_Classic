--=====================================================================================
-- BLU_Classic - data/ui/profiles.lua
-- Profiles page, built on RGX-Framework's shared profile editor (UI:CreateProfilesPanel).
-- The framework supplies the themed header, the active-profile box, the profile
-- dropdown with inline delete, Create / Rename / Copy (themed name dialogs), and the
-- Presets card. BLU adds its preset data and a confirmation before anything destructive:
-- Reset and applying a preset.
--=====================================================================================

local BLU = _G.BLU_Classic
local DEFAULT_PROFILE = "Default"

-- The framework's profile editor follows the framework theme, but BLU's highlights are brand
-- cyan. BuildBrandedProfileCard builds the card inside a brand-primary theme scope, which covers
-- colours the framework reads while it builds the card (such as the Active value). Its button
-- hover reads the framework primary when the mouse enters, so BrandProfileButtonHover runs after
-- it and re-tints each button. Dropdown hover and the name dialogs still follow the framework
-- theme; that is a framework follow-up.
local function BrandProfileButtonHover(card)
    local Design = BLU.Modules and BLU.Modules["design"]
    if not (Design and card) then return end
    local function brandButton(btn)
        if not (btn and btn.HookScript) then return end
        btn:HookScript("OnEnter", function(self)
            local enabled = self:IsEnabled()
            if self.border and self.border.SetBackdropBorderColor then
                self.border:SetBackdropBorderColor(Design.Rgb(enabled and "brand" or "border"))
            end
            if self.label and self.label.SetTextColor then
                self.label:SetTextColor(Design.Rgb(enabled and "brand" or "subtext"))
            end
        end)
    end
    for _, btn in pairs(card.buttons or {}) do brandButton(btn) end
    for _, btn in ipairs(card.presetButtons or {}) do brandButton(btn) end
end
BLU.BrandProfileButtonHover = BrandProfileButtonHover

local function BuildBrandedProfileCard(build)
    local Design = BLU.Modules and BLU.Modules["design"]
    local RGX = _G.RGXFramework
    local D = RGX and RGX.GetDesign and RGX:GetDesign()
    local card
    if Design and D and type(D.WithTheme) == "function" then
        D:WithTheme({ primary = { Design.Rgb("brand") } }, function() card = build() end)
    else
        card = build()
    end
    BrandProfileButtonHover(card)
    return card
end

local function GetActiveProfileName()
    local db = BLU.db
    if db and db.GetActiveProfile then
        return db:GetActiveProfile() or DEFAULT_PROFILE
    end
    return DEFAULT_PROFILE
end

local function RefreshAll()
    if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
    if BLU.RefreshOptions then BLU:RefreshOptions() end
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
-- Panel
--=====================================================================================
function BLU.CreateProfilesPanel(panel)
    BLU:PrintDebug("[Options/Profiles] Creating Profiles panel")

    for _, child in ipairs({panel:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local UI = BLU:GetFrameworkUI()
    if not (UI and UI.CreateProfilesPanel and UI.Confirm) then
        local missing = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        missing:SetPoint("TOPLEFT", 18, -18)
        missing:SetText("|cffff6666RGX-Framework 2.12.0 or newer is required for profile management.|r")
        return panel
    end

    if not (BLU.db and BLU.db.ListProfiles) then
        local unavailable = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 18, -18)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        return panel
    end

    local card = BuildBrandedProfileCard(function() return UI:CreateProfilesPanel(panel, {
        db = BLU.db,
        title = "Profiles",
        icon = "Interface\\Icons\\Ability_Marksmanship",
        description = "Create, switch, and manage your saved sound profiles.",
        onChange = function() RefreshAll() end,
        presets = BLU.ProfilePresets,
        onPreset = function(preset)
            local active = GetActiveProfileName()
            UI:Confirm({
                title = "Apply preset",
                message = "Apply \"" .. tostring(preset.name) .. "\" to \"" .. tostring(active) .. "\"?\n\n"
                    .. "This resets the profile's settings, then applies the preset. Custom sounds and the minimap position are kept.",
                confirm = "Apply",
                cancel = "Cancel",
                onConfirm = function()
                    local ok, err = ApplyPreset(active, preset)
                    if ok then
                        BLU:Print("Applied preset '" .. tostring(preset.name) .. "' to profile '" .. tostring(active) .. "'.")
                    else
                        BLU:Print("Preset apply failed: " .. tostring(err))
                    end
                    RefreshAll()
                end,
            })
        end,
    }) end)

    -- Reset replaces every setting in the profile, so it asks first. The framework's
    -- button handler is kept (it is pcall-isolated) and called from the confirmation.
    local reset = card and card.buttons and card.buttons.reset
    if reset then
        local performReset = reset:GetScript("OnClick")
        reset:SetScript("OnClick", function(self, mouse)
            local active = GetActiveProfileName()
            UI:Confirm({
                title = "Reset profile",
                message = "Reset \"" .. tostring(active) .. "\" to default settings?\n\n"
                    .. "This clears every setting in the profile, including its custom sound list.",
                confirm = "Reset",
                cancel = "Cancel",
                onConfirm = function() performReset(self, mouse) end,
            })
        end)
    end

    return panel
end
