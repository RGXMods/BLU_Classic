--=====================================================================================
-- BLU | Better Level-Up! - core.lua
-- Consolidated addon core with version-aware functionality
--=====================================================================================

-- Safely create or get the BLU_Classic addon (prevents "already exists" error)
local addonName = "BLU_Classic"
BLU_Classic = LibStub("AceAddon-3.0"):GetAddon(addonName, true) or LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
BLU_L = BLU_L or {}

--=====================================================================================
-- Game Version Detection (cached for performance)
--=====================================================================================
local cachedGameVersion = nil

function BLU_Classic:GetGameVersion()
    if cachedGameVersion then return cachedGameVersion end
    
    local _, _, _, interfaceVersion = GetBuildInfo()
    
    if interfaceVersion >= 110000 then
        cachedGameVersion = "retail"
    elseif interfaceVersion >= 100000 then -- this covers between 100000 and 110000
        cachedGameVersion = "retail"
    elseif interfaceVersion >= 50000 and interfaceVersion < 60000 then
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
    Achievement = { retail = true, mists = true, cata = true, wrath = true },
    BattlePet = { retail = true, mists = true },
    Honor = { retail = true },
    Delve = { retail = true },
    Renown = { retail = true },
    Post = { retail = true },
    Level = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Quest = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    QuestAccept = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
    Reputation = { retail = true, mists = true, cata = true, wrath = true, tbc = true, vanilla = true },
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

    if version == "retail" then
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        if self:IsFeatureAvailable("BattlePet") then -- Use IsFeatureAvailable for BattlePet
            events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
            events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
        end
    elseif version == "mists" then
        if self:IsFeatureAvailable("BattlePet") then -- Use IsFeatureAvailable for BattlePet
            events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
            events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
        end
    end
    -- "cata" or "wrath" already covered by IsFeatureAvailable("Achievement")

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

function BLU_Classic:HandleHonorLevelUpdate()
    if not self:IsFeatureAvailable("Honor") then return end
    self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds and defaultSounds[5], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function BLU_Classic:HandleBattlePetLevelUp()
    if not self:IsFeatureAvailable("BattlePet") then return end
    self:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds and defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
end

function BLU_Classic:HandleRenownLevelChanged()
    if not self:IsFeatureAvailable("Renown") then return end
    self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds and defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function BLU_Classic:HandlePerksActivityCompleted()
    if not self:IsFeatureAvailable("Post") then return end
    self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", defaultSounds and defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED")
end

-- Delve Companion Level Up functions (from be75efd, adapted)
function BLU_Classic:OnDelveCompanionLevelUp(event, ...)
    if self:GetGameVersion() == "retail" then return end -- Assuming this should only trigger on non-retail
    self:PrintDebugMessage(event .. " event fired, awaiting CHAT_MSG_SYSTEM for confirmation.")

    if event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        self:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        local levelUpMatch = string.match(msg, "Brann Bronzebeard has reached Level (%d+)")
        if levelUpMatch then
            local level = tonumber(levelUpMatch)
            self:PrintDebugMessage("|cff00ff00Brann Level-Up detected: Level " .. level .. "|r")
            self:TriggerDelveLevelUpSound(level)
        else
            self:PrintDebugMessage("NO_LEVEL_FOUND")
        end
    end
end

function BLU_Classic:TriggerDelveLevelUpSound(level)
    self:HandleEvent("DELVE_LEVEL_UP", "DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds and defaultSounds[3], "DELVE_LEVEL_UP_TRIGGERED")
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

function BLU_Classic:TestDelveLevelUpSound()
    if not self:IsFeatureAvailable("Delve") then return end
    self:TestSound("DelveLevelUpSoundSelect", "DelveLevelUpVolume", defaultSounds and defaultSounds[3], "TEST_DELVE_LEVEL_UP_SOUND")
end

function BLU_Classic:TestHonorSound()
    if not self:IsFeatureAvailable("Honor") then return end
    self:TestSound("HonorSoundSelect", "HonorVolume", defaultSounds and defaultSounds[5], "TEST_HONOR_SOUND")
end

function BLU_Classic:TestLevelSound()
    self:TestSound("LevelSoundSelect", "LevelVolume", defaultSounds and defaultSounds[4], "TEST_LEVEL_SOUND")
end

function BLU_Classic:TestPostSound()
    if not self:IsFeatureAvailable("Post") then return end
    self:TestSound("PostSoundSelect", "PostVolume", defaultSounds and defaultSounds[9], "TEST_POST_SOUND")
end

function BLU_Classic:TestQuestAcceptSound()
    self:TestSound("QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds and defaultSounds[7], "TEST_QUEST_ACCEPT_SOUND")
end

function BLU_Classic:TestQuestSound()
    self:TestSound("QuestSoundSelect", "QuestVolume", defaultSounds and defaultSounds[8], "TEST_QUEST_SOUND")
end

function BLU_Classic:TestRenownSound()
    if not self:IsFeatureAvailable("Renown") then return end
    self:TestSound("RenownSoundSelect", "RenownVolume", defaultSounds and defaultSounds[6], "TEST_RENOWN_SOUND")
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

--=====================================================================================
-- Options System
--=====================================================================================
-- Map option groups to features for filtering (from HEAD, adapted)
local OPTION_GROUP_FEATURES = {
    group2 = "Achievement",
    group3 = "BattlePet",
    group4 = "Delve",
    group5 = "Honor",
    group6 = "Level",
    group7 = "QuestAccept",
    group8 = "Quest",
    group9 = "Renown",
    group10 = "Reputation",
    group11 = "Post",
}

function BLU_Classic:FilterOptionsForVersion()
    if not self.options or not self.options.args then return end
    
    for groupKey, feature in pairs(OPTION_GROUP_FEATURES) do
        if not self:IsFeatureAvailable(feature) then
            self.options.args[groupKey] = nil
        end
    end
end

-- Saved Variables Cleanup for Version Compatibility (from be75efd, adapted)
function BLU_Classic:CleanupIncompatibleSavedVariables(version)
    if version ~= "retail" then
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.HonorVolume = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.DelveLevelUpVolume = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.RenownVolume = nil
        self.db.profile.PostSoundSelect = nil
        self.db.profile.PostVolume = nil
        
        if version ~= "mists" then
            self.db.profile.BattlePetLevelSoundSelect = nil
            self.db.profile.BattlePetLevelVolume = nil
        end
    end
    
    -- Additional cleanup for non-retail from be75efd version
    local groupsToRemove = {
        vanilla = {"group2", "group3", "group4", "group5", "group9", "group11"},
        tbc = {"group2", "group3", "group4", "group5", "group9", "group11"},
        wrath = {"group3", "group4", "group5", "group9", "group11"},
        cata = {"group3", "group4", "group5", "group9", "group11"},
        mists = {"group4", "group5", "group9", "group11"},
        retail = {"group4", "group10"}, -- Removing delve and reputation for retail as per be75efd
    }
    
    local toRemove = groupsToRemove[version] or {}
    for _, groupName in ipairs(toRemove) do
        self.options.args[groupName] = nil
    end

    if version == "vanilla" or version == "tbc" then
        self.db.profile.AchievementSoundSelect = nil
    end
end


--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU_Classic:InitializeOptions()
    local AC = LibStub("AceConfig-3.0")
    local ACD = LibStub("AceConfigDialog-3.0")

    if not self.options or not self.options.args then
        if self.debugMode then
            print(BLU_Classic_PREFIX .. "|cffff0000Options table not loaded|r")
        end
        return
    end

    -- Filter options based on game version (single pass)
    self:FilterOptionsForVersion()
    
    -- Build sorted options list and apply colors
    self.sortedOptions = {}
    for _, group in pairs(self.options.args) do
        if group.order then
            table.insert(self.sortedOptions, group)
        end
    end
    
    self:AssignGroupColors()

    if not self.optionsRegistered then
        local optionsTitle = BLU_L["OPTIONS_PANEL_TITLE"] or "BLU | Better Level-Up!"
        local profilesTitle = BLU_L["PROFILES_TITLE"] or "Profiles"
        
        AC:RegisterOptionsTable("BLU_Classic_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Classic_Options", optionsTitle)

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Classic_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Classic_Profiles", profilesTitle, optionsTitle)

        self.optionsRegistered = true
    else
        self:PrintDebugMessage("OPTIONS_ALREADY_REGISTERED") -- This line was only in be75efd
    end
end

function BLU_Classic:AssignGroupColors()
    local colors = { 
        BLU_L.optionColor1 or "|cffffffff", -- Using HEAD's robust color definitions
        BLU_L.optionColor2 or "|cffcccccc" 
    }
    local patternIndex = 1

    if not self.sortedOptions or #self.sortedOptions == 0 then return end
    
    table.sort(self.sortedOptions, function(a, b) 
        return (a.order or 0) < (b.order or 0) 
    end)

    for _, group in ipairs(self.sortedOptions) do
        if group.name and group.args then
            group.name = colors[patternIndex] .. group.name .. "|r"

            for _, arg in pairs(group.args) do
                if arg.name and arg.name ~= "" then
                    arg.name = colors[patternIndex] .. arg.name .. "|r"
                end
                if arg.desc and arg.desc ~= "" then
                    arg.desc = colors[(patternIndex % 2) + 1] .. arg.desc .. "|r"
                end
            end

            patternIndex = patternIndex % 2 + 1
        end
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
    self.db = LibStub("AceDB-3.0"):New("BLUClassicDB", self.defaults, true)

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
    
    self.debugMode = self.db.profile.debugMode or false
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage
    if self.showWelcomeMessage == nil then
        self.showWelcomeMessage = true
        self.db.profile.showWelcomeMessage = true
    end

    self.functionsHalted = false
    self.sortedOptions = {}
    self.optionsRegistered = false
    
    self:RegisterChatCommand("bluc", "HandleSlashCommands")
    self:InitializeOptions()
end

function BLU_Classic:OnEnable()
    self:RegisterSharedEvents()
    self:InitializeReputationCache()
    self:MuteSounds()
    
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