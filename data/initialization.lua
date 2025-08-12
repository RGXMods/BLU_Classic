--=====================================================================================
-- BLU | Better Level-Up! - initialization.lua
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
-- Version detection with proper API compatibility
if C_AddOns and C_AddOns.GetAddOnMetadata then
    BLU.VersionNumber = C_AddOns.GetAddOnMetadata("BLU_Classic", "Version")
else
    BLU.VersionNumber = GetAddOnMetadata("BLU_Classic", "Version")
end

--=====================================================================================
-- Libraries and Variables
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

BLU.functionsHalted = false
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.sortedOptions = {}
BLU.optionsRegistered = false


BLU_L = BLU_L or {}

--=====================================================================================
-- Game Version Handling
--=====================================================================================
function BLU:GetGameVersion()
    local _, _, _, interfaceVersion = GetBuildInfo()

    if interfaceVersion >= 110000 then
        return "retail"  -- Retail (The War Within)
    elseif interfaceVersion >= 100000 and interfaceVersion < 110000 then
        return "retail"  -- Retail (Dragonflight)
    elseif interfaceVersion >= 50000 and interfaceVersion < 60000 then
        return "mists"  -- Mists of Pandaria Classic (50500)
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        return "cata"  -- Cataclysm Classic (40400)
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        return "wrath"  -- Wrath Classic (30405)
    elseif interfaceVersion >= 20000 and interfaceVersion < 30000 then
        return "tbc"  -- Burning Crusade Classic (20504)
    elseif interfaceVersion >= 10000 and interfaceVersion < 20000 then
        return "vanilla"  -- Classic Era (11507)
    else
        self:PrintDebugMessage("ERROR_UNKNOWN_GAME_VERSION: " .. tostring(interfaceVersion))
        return "unknown"
    end
end

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    local version = self:GetGameVersion()

    local events = {
        PLAYER_ENTERING_WORLD = "HandlePlayerEnteringWorld",
        PLAYER_LEVEL_UP = "HandlePlayerLevelUp",
        QUEST_ACCEPTED = "HandleQuestAccepted",
        QUEST_TURNED_IN = "HandleQuestTurnedIn",
        CHAT_MSG_SYSTEM = "ReputationChatFrameHook",
    }

    -- Add version-specific events
    if version == "retail" then
        -- All modern features (retail only)
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.HONOR_LEVEL_UPDATE = "HandleHonorLevelUpdate"
        events.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = "HandleRenownLevelChanged"
        events.PERKS_ACTIVITY_COMPLETED = "HandlePerksActivityCompleted"
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    elseif version == "mists" then
        -- MoP Classic features (achievements and battle pets only)
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
        events.PET_BATTLE_LEVEL_CHANGED = "HandleBattlePetLevelUp"
        events.PET_JOURNAL_LIST_UPDATE = "HandleBattlePetLevelUp"
    elseif version == "cata" or version == "wrath" then
        -- Cata and Wrath have achievements only
        events.ACHIEVEMENT_EARNED = "HandleAchievementEarned"
    end
    -- Vanilla and TBC have no additional events beyond base ones

    for event, handler in pairs(events) do
        if type(self[handler]) == "function" then
            self:RegisterEvent(event, handler)
            self:PrintDebugMessage("EVENT_REGISTERED", event, handler)
        else
            self:PrintDebugMessage("EVENT_HANDLER_NOT_FOUND", event, handler)
        end
    end
end


--=====================================================================================
-- Initialization, Mute Sounds, and Welcome Message
--=====================================================================================
function BLU:OnInitialize()
    -- Get game version early for version-specific initialization
    local version = self:GetGameVersion()
    self:PrintDebugMessage("INITIALIZING_FOR_VERSION", version)
    
    -- Initialize the database with defaults
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Apply default values if they are not set
    for key, value in pairs(self.defaults.profile) do
        if self.db.profile[key] == nil then
            self.db.profile[key] = value
        end
    end
    
    -- Clean up version-incompatible saved variables immediately after initialization
    self:CleanupIncompatibleSavedVariables(version)

    self.debugMode = self.db.profile.debugMode
    self.showWelcomeMessage = self.db.profile.showWelcomeMessage

    -- Register slash commands
    self:RegisterChatCommand("blu", "HandleSlashCommands")

    -- Initialize options
    self:InitializeOptions()
    
    -- Mute sounds based on game version
    local soundsToMute = muteSoundIDs[self:GetGameVersion()]
    if soundsToMute and #soundsToMute > 0 then
        for _, soundID in ipairs(soundsToMute) do
            MuteSoundFile(soundID)
        end
    end
end

--=====================================================================================
-- OnEnable Function - Called after OnInitialize when addon is fully loaded
--=====================================================================================
function BLU:OnEnable()
    -- Register events after addon is fully enabled
    self:RegisterSharedEvents()
    
    -- Display the welcome message if enabled
    if self.showWelcomeMessage then
        print(BLU_PREFIX .. BLU_L["WELCOME_MESSAGE"])
        print(BLU_PREFIX .. BLU_L["VERSION"], "|cff8080ff", BLU.VersionNumber)
    end
end

--=====================================================================================
-- Saved Variables Cleanup for Version Compatibility
--=====================================================================================
function BLU:CleanupIncompatibleSavedVariables(version)
    -- Clean up profile settings for features that don't exist in this version
    if version ~= "retail" then
        -- Honor, Delves, Renown, and Trading Post are retail-only
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.HonorVolume = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.DelveLevelUpVolume = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.RenownVolume = nil
        self.db.profile.PostSoundSelect = nil
        self.db.profile.PostVolume = nil
        
        -- Battle pets only available in Mists and Retail
        if version ~= "mists" then
            self.db.profile.BattlePetLevelSoundSelect = nil
            self.db.profile.BattlePetLevelVolume = nil
        end
    end
    
    -- Achievements only available in Wrath, Cata, Mists, and Retail
    if version == "vanilla" or version == "tbc" then
        self.db.profile.AchievementSoundSelect = nil
        self.db.profile.AchievementVolume = nil
    end
end

--=====================================================================================
-- Options Initialization
--=====================================================================================
function BLU:InitializeOptions()
    local version = self:GetGameVersion()

    if not self.options or not self.options.args then
        self:PrintDebugMessage("ERROR_OPTIONS_NOT_INITIALIZED")
        return
    end

    self.sortedOptions = {}

    -- Remove options based on game version
    if version ~= "retail" then
        self:RemoveOptionsForVersion(version)
    end

    -- Filter out incompatible groups and assign colors
    for _, group in pairs(self.options.args) do
        if self:IsGroupCompatibleWithVersion(group, version) then
            table.insert(self.sortedOptions, group)
        else
            self:PrintDebugMessage("SKIPPING_GROUP_NOT_COMPATIBLE") 
        end
    end

    self:AssignGroupColors()

    if not self.optionsRegistered then
        AC:RegisterOptionsTable("BLU_Options", self.options)
        self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", BLU_L["OPTIONS_LIST_MENU_TITLE"]) 

        local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        AC:RegisterOptionsTable("BLU_Profiles", profiles)
        ACD:AddToBlizOptions("BLU_Profiles", BLU_L["PROFILES_TITLE"], BLU_L["OPTIONS_LIST_MENU_TITLE"])

        self.optionsRegistered = true
    else
        self:PrintDebugMessage("OPTIONS_ALREADY_REGISTERED")
    end
end

function BLU:IsGroupCompatibleWithVersion(group, version)
    if not group or not group.name then return true end
    
    -- Features incompatible with each version
    -- Honor Ranks, Delves, Renown, and Trading Post are retail-only
    local incompatible = {
        retail = {},  -- Retail has everything
        mists = {"Honor", "Delve", "Renown", "Post"},
        cata = {"Battle Pet", "Honor", "Delve", "Renown", "Post"},
        wrath = {"Battle Pet", "Honor", "Delve", "Renown", "Post"},
        tbc = {"Achievement", "Battle Pet", "Honor", "Delve", "Renown", "Post"},
        vanilla = {"Achievement", "Battle Pet", "Honor", "Delve", "Renown", "Post"},
    }
    
    local patterns = incompatible[version] or {}
    for _, pattern in ipairs(patterns) do
        if group.name:match(pattern) then
            return false
        end
    end
    
    return true
end

function BLU:RemoveOptionsForVersion(version)
    local args = self.options.args
    
    -- Define which groups to remove for each version based on corrected feature availability
    -- Honor Ranks, Delves, Renown, and Trading Post are retail-only
    local groupsToRemove = {
        vanilla = {"group2", "group3", "group4", "group5", "group9", "group11"},  -- Remove achievements, battle pets, honor, delves, renown, trading post
        tbc = {"group2", "group3", "group4", "group5", "group9", "group11"},     -- Remove achievements, battle pets, honor, delves, renown, trading post  
        wrath = {"group3", "group4", "group5", "group9", "group11"},             -- Remove battle pets, honor, delves, renown, trading post
        cata = {"group3", "group4", "group5", "group9", "group11"},              -- Remove battle pets, honor, delves, renown, trading post
        mists = {"group4", "group5", "group9", "group11"},                       -- Remove honor, delves, renown, trading post (keep achievements and battle pets)
        retail = {},  -- Keep all groups for retail
    }
    
    -- Remove incompatible groups
    local toRemove = groupsToRemove[version] or {}
    for _, groupName in ipairs(toRemove) do
        args[groupName] = nil
    end
    
    -- Clean up profile settings for removed features
    if version ~= "retail" then
        -- Honor, Delves, Renown, and Trading Post are retail-only
        self.db.profile.HonorSoundSelect = nil
        self.db.profile.DelveLevelUpSoundSelect = nil
        self.db.profile.RenownSoundSelect = nil
        self.db.profile.PostSoundSelect = nil
        
        -- Battle pets only available in Mists and Retail
        if version ~= "mists" then
            self.db.profile.BattlePetLevelSoundSelect = nil
        end
    end
    
    -- Achievements only available in Wrath, Cata, Mists, and Retail
    if version == "vanilla" or version == "tbc" then
        self.db.profile.AchievementSoundSelect = nil
    end
end

--=====================================================================================
-- Assign Group Colors
--=====================================================================================
function BLU:AssignGroupColors()
    local colors = { BLU_L.optionColor1, BLU_L.optionColor2 } 
    local patternIndex = 1

    if self.sortedOptions and #self.sortedOptions > 0 then
        table.sort(self.sortedOptions, function(a, b) return a.order < b.order end)

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
end
