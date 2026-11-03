--=====================================================================================
-- BLU | Better Level-Up! - core.lua
-- Consolidated addon core with version-aware functionality
--=====================================================================================

-- Safely create or get the BLU_Classic addon (prevents "already exists" error)
local addonName = "BLU_Classic"
BLU_Classic = LibStub("AceAddon-3.0"):GetAddon(addonName, true) or LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0")
BLU_L = BLU_L or {}

-- Register PLAYER_LOGOUT at file-load time so unmute fires even if init/enable failed.
-- Must not be guarded by profile.enabled or any DB check.
do
    local logoutFrame = CreateFrame("Frame")
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", function()
        BLU_Classic:UnmuteSounds()
    end)
end

--=====================================================================================
-- Game Version Detection (cached for performance)
--=====================================================================================
local cachedGameVersion = nil

function BLU_Classic:GetGameVersion()
    if cachedGameVersion then return cachedGameVersion end
    
    local _, _, _, interfaceVersion = GetBuildInfo()
    
    if interfaceVersion >= 50000 and interfaceVersion < 60000 then
        cachedGameVersion = "mists"
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        cachedGameVersion = "cata"
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        cachedGameVersion = "wrath"
    elseif interfaceVersion >= 20000 and interfaceVersion < 30000 then
        cachedGameVersion = "tbc"
    elseif interfaceVersion >= 10000 and interfaceVersion < 20000 then
        cachedGameVersion = "vanilla"
    else
        cachedGameVersion = "unknown"
        self:PrintDebugMessage("ERROR_UNKNOWN_GAME_VERSION: " .. tostring(interfaceVersion)) -- Add debug message
    end
    
    return cachedGameVersion
end

--=====================================================================================
-- Feature Compatibility Tables (single source of truth)
--=====================================================================================
local FEATURE_AVAILABILITY = {
    Achievement = { mists = true, cata = true, wrath = true },
    BattlePet = { mists = true },
    Level = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Quest = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    QuestAccept = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Reputation = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Combat = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Loot = { mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
}

function BLU_Classic:IsFeatureAvailable(feature)
    local version = self:GetGameVersion()
    return FEATURE_AVAILABILITY[feature] and FEATURE_AVAILABILITY[feature][version] or false
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU_Classic:RegisterSharedEvents()
    local version = self:GetGameVersion()

    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedInAndScanReputation",
        UPDATE_FACTION = "ScheduleReputationScan",
    }

    if self:IsFeatureAvailable("Achievement") then
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end

    if self:IsFeatureAvailable("BattlePet") then
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    end

    for event, handler in pairs(events) do
        if type(self[handler]) == "function" then
            self:RegisterEvent(event, handler)
        end
    end
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU_Classic:HandleQuestTurnedInAndScanReputation()
    self:HandleQuestTurnedIn()
    self:ScheduleReputationScan()
end

function BLU_Classic:HandlePlayerLevelUp()
    self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds and defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
end

function BLU_Classic:HandleQuestAccepted()
    self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds and defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
end

function BLU_Classic:HandleQuestTurnedIn()
    self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds and defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function BLU_Classic:HandleAchievementEarned()
    if not self:IsFeatureAvailable("Achievement") then return end
    self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds and defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function BLU_Classic:HandleBattlePetLevelUp()
    if not self:IsFeatureAvailable("BattlePet") then return end
    self:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds and defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
end

--=====================================================================================
-- Test Sound Functions
--=====================================================================================
function BLU_Classic:TestAchievementSound()
    if not self:IsFeatureAvailable("Achievement") then return end
    self:TestSound("AchievementSoundSelect", "AchievementVolume", defaultSounds and defaultSounds[1], "TEST_ACHIEVEMENT_SOUND")
end

function BLU_Classic:TestBattlePetLevelSound()
    if not self:IsFeatureAvailable("BattlePet") then return end
    self:TestSound("BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds and defaultSounds[2], "TEST_BATTLE_PET_LEVEL_SOUND")
end

function BLU_Classic:TestLevelSound()
    self:TestSound("LevelSoundSelect", "LevelVolume", defaultSounds and defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU_Classic:TestQuestAcceptSound()
    self:TestSound("QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds and defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU_Classic:TestQuestSound()
    self:TestSound("QuestSoundSelect", "QuestVolume", defaultSounds and defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU_Classic:TestRepSound()
    -- This function was present in both, with the same body, but using defaultSounds[6] twice.
    -- Assuming defaultSounds[6] is correct for Rep.
    self:TestSound("RepSoundSelect", "RepVolume", defaultSounds and defaultSounds[6], "TEST_REP_SOUND")
end

--=====================================================================================
-- Reputation System
--=====================================================================================
local function GetReputationFunctions()
    local GetNumFactions = _G.GetNumFactions or (C_Reputation and C_Reputation.GetNumFactions)
    local GetFactionInfo = _G.GetFactionInfo or (C_Reputation and function(factionIndex)
        if not factionIndex then return nil end
        local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
        if not factionData then return nil end
        return factionData.name, factionData.description, factionData.reaction, 
               factionData.currentReactionThreshold, factionData.nextReactionThreshold, 
               factionData.currentStanding, factionData.atWarWith, factionData.canToggleAtWar, 
               factionData.isHeader, factionData.isCollapsed, factionData.isHeaderWithRep, 
               factionData.isWatched, factionData.isChild, factionData.factionID, 
               factionData.hasBonusRepGain, factionData.canSetInactive
    end)
    return GetNumFactions, GetFactionInfo
end

function BLU_Classic:InitializeReputationCache()
    local GetNumFactions, GetFactionInfo = GetReputationFunctions()
    if not GetNumFactions then return end

    self.db.char.reputationCache = self.db.char.reputationCache or {}
    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
        if factionID and not self.db.char.reputationCache[factionID] then
            self.db.char.reputationCache[factionID] = {
                name = name,
                standingId = standingId
            }
        end
    end
end

function BLU_Classic:ScanForReputationChanges()
    local GetNumFactions, GetFactionInfo = GetReputationFunctions()
    if not GetNumFactions then return end

    if not self.db.char.reputationCache then
        self:InitializeReputationCache()
        return
    end

    for i = 1, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
        if factionID and self.db.char.reputationCache[factionID] then
            local oldStandingId = self.db.char.reputationCache[factionID].standingId
            if standingId and oldStandingId and standingId > oldStandingId then
                self:PrintDebugMessage("Reputation rank-up detected for " .. (name or "Unknown"))
                self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", defaultSounds and defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
            end
            self.db.char.reputationCache[factionID].standingId = standingId
        elseif factionID then
            self.db.char.reputationCache[factionID] = {
                name = name,
                standingId = standingId
            }
        end
    end
end

function BLU_Classic:ScheduleReputationScan()
    if self.reputationScanTimer then
        self:CancelTimer(self.reputationScanTimer)
    end
    self.reputationScanTimer = self:ScheduleTimer("ScanForReputationChanges", 1)
end

-- Saved Variables Cleanup for Version Compatibility (from be75efd, adapted)
function BLU_Classic:CleanupIncompatibleSavedVariables(version)
    -- Clean up any leftover retail-only saved variables
    self.db.HonorSoundSelect = nil
    self.db.HonorVolume = nil
    self.db.DelveLevelUpSoundSelect = nil
    self.db.DelveLevelUpVolume = nil
    self.db.RenownSoundSelect = nil
    self.db.RenownVolume = nil
    self.db.PostSoundSelect = nil
    self.db.PostVolume = nil

    if version ~= "mists" then
        self.db.BattlePetLevelSoundSelect = nil
        self.db.BattlePetLevelVolume = nil
    end

    if version == "vanilla" or version == "tbc" then
        self.db.AchievementSoundSelect = nil
        self.db.AchievementVolume = nil
    end
end


--=====================================================================================
-- Options Initialization (BLU-style options panel, see data/ui/)
--=====================================================================================
function BLU_Classic:InitializeOptions()
    if self.optionsRegistered then
        self:PrintDebugMessage("OPTIONS_ALREADY_REGISTERED")
        return
    end

    if type(self.CreateOptionsPanel) ~= "function" then
        print(BLU_Classic_PREFIX .. "|cffff0000Options panel module not loaded|r")
        return
    end

    if self:CreateOptionsPanel() then
        self.optionsRegistered = true
    end
end

--=====================================================================================
-- Sound Muting System
--=====================================================================================
function BLU_Classic:MuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs and muteSoundIDs[version] -- Keep robust check
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            MuteSoundFile(soundID)
        end
    end
end

function BLU_Classic:UnmuteSounds()
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs and muteSoundIDs[version] -- Keep robust check
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            UnmuteSoundFile(soundID)
        end
    end
end

--=====================================================================================
-- Addon Lifecycle
--=====================================================================================
function BLU_Classic:OnInitialize()
    -- RGX-Framework database (issue #5): replaces the AceDB-3.0 layer.
    -- Flat proxy: self.db.<key> reads/writes the active profile; self.db.char
    -- is per-character storage. SavedVariables name stays BLUClassicDB.
    local RGXDB = _G.RGXFramework
    if not RGXDB or not RGXDB.NewDatabase then
        print("|cff05dffaBLU_Classic:|r RGX-Framework is required for settings storage.")
        return
    end
    self.db = RGXDB:NewDatabase("BLUClassicDB", self.defaults and self.defaults.profile or {}, {
        onSwitch = function()
            if self.UpdateMinimapButtonPosition then self:UpdateMinimapButtonPosition() end
            if self.minimapButton and self.minimapButton.SetVisible then
                self.minimapButton:SetVisible(self.db.classicMinimapIconEnabled ~= false)
            end
            self.debugMode = self.db.debugMode == true
            self.showWelcomeMessage = self.db.showWelcomeMessage ~= false
            if self.InvalidateAllTabs then self:InvalidateAllTabs() end
            if self.RefreshOptions then self:RefreshOptions() end
        end,
    })

    -- Explicitly embed AceTimer-3.0 to ensure ScheduleTimer is available
    LibStub("AceTimer-3.0"):Embed(self)

    -- Get version number (API differs between versions)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        self.VersionNumber = C_AddOns.GetAddOnMetadata("BLU_Classic", "Version")
    else
        self.VersionNumber = GetAddOnMetadata("BLU_Classic", "Version")
    end
    
    local version = self:GetGameVersion()
    self:CleanupIncompatibleSavedVariables(version) -- Call cleanup here

    self.db.char.reputationCache = self.db.char.reputationCache or {}
    
    self.debugMode = self.db.debugMode or false
    self.showWelcomeMessage = self.db.showWelcomeMessage
    if self.showWelcomeMessage == nil then
        self.showWelcomeMessage = true
        self.db.showWelcomeMessage = true
    end

    self.functionsHalted = false
    self.optionsRegistered = false

    self.db.classicMinimapIconEnabled = self.db.classicMinimapIconEnabled ~= false
    self.db.classicMinimapAngle = self.db.classicMinimapAngle or 220

    local RGX = _G.RGXFramework
    if RGX then
        RGX:RegisterSlashCommand({"blu", "bluc"}, function(msg) self:HandleSlashCommands(msg) end, "BLU_Classic")
    end
    self:InitializeOptions()
end

function BLU_Classic:OnEnable()
    self:RegisterSharedEvents()
    self:InitializeTriggers()
    self:InitializeReputationCache()
    self:MuteSounds()

    self:CreateMinimapButton()
    if self.minimapButton and self.db.classicMinimapIconEnabled == false then
        -- Silent restore on login: hide the frame directly instead of
        -- SetVisible(false), which fires onVisibilityChanged and would print
        -- toggle feedback on every UI load.
        self.minimapButton.frame:Hide()
    elseif self.minimapButton then
        -- Restore the saved angle placement without visibility side effects.
        self:UpdateMinimapButtonPosition()
    end
    
    if self.showWelcomeMessage then
        local welcomeMsg = BLU_L["WELCOME_MESSAGE"] or "Loaded successfully!" -- From HEAD
        local versionText = BLU_L["VERSION"] or "Version:" -- From HEAD
        print(BLU_Classic_PREFIX .. welcomeMsg)
        print(BLU_Classic_PREFIX .. versionText .. " |cff8080ff" .. (self.VersionNumber or "Unknown") .. "|r") -- From HEAD
    end
end

function BLU_Classic:OnDisable()
    self:UnmuteSounds()
end
