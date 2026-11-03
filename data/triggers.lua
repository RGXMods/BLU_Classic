--=====================================================================================
-- BLU_Classic - data/triggers.lua
-- Combat and Loot sound triggers. One definition list drives both the runtime below
-- and the options pages (data/ui/events.lua), so they cannot drift apart.
--
--   * Combat triggers use the RGX-Framework Combat module callbacks.
--   * Loot triggers read CHAT_MSG_LOOT / CHAT_MSG_MONEY through RGX:RegisterEvent. The
--     item quality comes from the item link colour, which is locale independent and
--     does not need the item to be cached. (The framework's OnRareLoot relies on
--     BAG_NEW_ITEMS_UPDATED, a Retail-only event.)
--   * Every trigger saves "<Id>SoundSelect" (0 = none) and "<Id>Volume" (0-3), like the
--     existing event pages. All triggers default to none.
--=====================================================================================

local BLU = _G.BLU_Classic

local PER_TRIGGER_COOLDOWN = 1.0

-- Pages in tab order; each trigger: id, label, description (tooltip/intro text).
BLU.TriggerPages = {
    combat = {
        { id = "CombatStart",      label = "Combat Start",        description = "Entering combat." },
        { id = "CombatEnd",        label = "Combat End",          description = "Leaving combat." },
        { id = "LowHealth",        label = "Low Health",          description = "Your health drops below 35%." },
        { id = "ExecuteWindow",    label = "Execute Window",      description = "Your target drops below 20% health." },
        { id = "CritHit",          label = "Critical Hit",        description = "You land a critical hit." },
        { id = "CritHeal",         label = "Critical Heal",       description = "You land a critical heal." },
        { id = "ResourceCapped",   label = "Resource Capped",     description = "Your power reaches 100%." },
        { id = "ResourceLow",      label = "Resource Low",        description = "Your power drops below 20%." },
        { id = "TargetLost",       label = "Target Lost",         description = "You clear or lose your target." },
        { id = "EncounterEnd",     label = "Encounter End",       description = "A boss encounter ends (win or wipe), on clients that report encounters." },
        { id = "EncounterVictory", label = "Encounter Victory",   description = "A boss encounter ends in victory, on clients that report encounters." },
    },
    loot = {
        { id = "LootUncommon", label = "Uncommon Item Looted", description = "You receive a green item." },
        { id = "LootRare",     label = "Rare Item Looted",     description = "You receive a blue item." },
        { id = "LootEpic",     label = "Epic Item Looted",     description = "You receive a purple item." },
        { id = "LootLegendary", label = "Legendary Item Looted", description = "You receive an orange item." },
        { id = "LootCoin",     label = "Coin Looted",          description = "You loot coin." },
    },
    hardcore = {
        { id = "DeathSelf",  label = "Your death",         description = "Your character dies." },
        { id = "DeathParty", label = "Party member death", description = "A member of your party dies." },
        { id = "DeathRaid",  label = "Raid member death",  description = "A member of your raid dies." },
        { id = "DeathOther", label = "Other player death", description = "Any other player dies nearby." },
    },
    -- Classic's counterpart to Retail's honor level is the PvP rank. Event triggers name the
    -- WoW event; a trigger whose event the client does not know is hidden (see InitializeTriggers).
    honor = {
        { id = "PvPRankUp", label = "PvP Rank Up", description = "Your PvP rank increases.", event = "PLAYER_PVP_RANK_CHANGED" },
    },
    collectibles = {
        { id = "MountLearned", label = "Mount Learned", description = "You learn a new mount.", event = "NEW_MOUNT_ADDED" },
        { id = "PetCollected", label = "Pet Collected", description = "You add a new pet to your collection.", event = "NEW_PET_ADDED" },
        { id = "ToyLearned",   label = "Toy Learned",   description = "You add a new toy to your collection.", event = "NEW_TOY_ADDED" },
    },
}

-- Does this client know the event? Blizzard's own UI uses C_EventUtils.IsEventValid, which is
-- present on Classic Era. Without it, registration is attempted and failure is absorbed.
local function KnownEvent(event)
    local EventUtils = _G.C_EventUtils
    if EventUtils and type(EventUtils.IsEventValid) == "function" then
        local ok, valid = pcall(EventUtils.IsEventValid, event)
        return ok and valid == true
    end
    return true
end

-- Decide at load which event triggers this client can use, so the tab strip can hide
-- pages that have nothing to fire.
for _, page in pairs(BLU.TriggerPages) do
    for _, trigger in ipairs(page) do
        if trigger.event then
            trigger.available = KnownEvent(trigger.event)
        end
    end
end

-- A page is shown only when at least one of its triggers is usable on this client.
function BLU:PageHasUsableTriggers(pageKey)
    for _, trigger in ipairs(self.TriggerPages[pageKey] or {}) do
        if trigger.event == nil or trigger.available ~= false then
            return true
        end
    end
    return false
end

-- Flat list for defaults and lookups
BLU.TriggerList = {}
BLU.TriggersById = {}
for _, page in pairs(BLU.TriggerPages) do
    for _, trigger in ipairs(page) do
        trigger.sound = trigger.id .. "SoundSelect"
        trigger.volume = trigger.id .. "Volume"
        BLU.TriggerList[#BLU.TriggerList + 1] = trigger
        BLU.TriggersById[trigger.id] = trigger
    end
end

local COMBATLOG_OBJECT_TYPE_PLAYER = 0x400

-- Item link colour -> quality id (Poor 0 ... Legendary 5)
local QUALITY_BY_COLOR = {
    ff9d9d9d = 0, ffffffff = 1, ff1eff00 = 2, ff0070dd = 3, ffa335ee = 4, ffff8000 = 5,
}
local LOOT_TRIGGER_BY_QUALITY = {
    [2] = "LootUncommon", [3] = "LootRare", [4] = "LootEpic", [5] = "LootLegendary",
}

local lastPlayed = {}

--- Play the sound saved for a trigger. Silent when none is selected.
function BLU:PlayTrigger(id)
    local trigger = self.TriggersById[id]
    if not trigger or not self.db or self.functionsHalted then return end

    local selected = self.db[trigger.sound]
    if selected == nil or selected == 0 then return end

    local now = GetTime and GetTime() or 0
    if lastPlayed[id] and (now - lastPlayed[id]) < PER_TRIGGER_COOLDOWN then return end
    lastPlayed[id] = now

    local sound = self:SelectSound(selected)
    if not sound then return end

    local volume = tonumber(self.db[trigger.volume])
    if not volume or volume < 0 or volume > 3 then volume = 2 end
    self:PlaySelectedSound(sound, math.floor(volume + 0.5), nil)
end

--- Options-page Test button.
function BLU:TestTrigger(id)
    local lastSaved = lastPlayed[id]
    lastPlayed[id] = nil
    self:PlayTrigger(id)
    if lastPlayed[id] == nil then lastPlayed[id] = lastSaved end
end

local function IsOwnLoot(guid, playerName)
    if guid and UnitGUID then
        return guid == UnitGUID("player")
    end
    if playerName and UnitName then
        local name = UnitName("player")
        return playerName == name or (playerName:match("^([^%-]+)") == name)
    end
    return false
end

function BLU:InitializeTriggers()
    if self.triggersInitialized then return end
    local RGX = _G.RGXFramework
    if not RGX then return end
    self.triggersInitialized = true

    local function bind(id)
        return function() BLU:PlayTrigger(id) end
    end

    local Combat = RGX.GetCombat and RGX:GetCombat()
    if Combat then
        local map = {
            OnEnter = "CombatStart", OnLeave = "CombatEnd", OnLowHealth = "LowHealth",
            OnExecuteWindow = "ExecuteWindow", OnCrit = "CritHit", OnCritHeal = "CritHeal",
            OnResourceCapped = "ResourceCapped", OnResourceLow = "ResourceLow",
            OnTargetLost = "TargetLost", OnEncounterEnd = "EncounterEnd",
            OnEncounterVictory = "EncounterVictory",
        }
        for method, id in pairs(map) do
            if type(Combat[method]) == "function" then
                Combat[method](Combat, bind(id))
            end
        end
    end

    -- Item loot: arg order is (event, text, playerName, ..., lineID, guid)
    RGX:RegisterEvent("CHAT_MSG_LOOT", function(_, text, playerName, _, _, _, _, _, _, _, _, _, guid)
        if type(text) ~= "string" or not IsOwnLoot(guid, playerName) then return end
        local link = text:match("|c%x%x%x%x%x%x%x%x|Hitem:.-|h%[.-%]|h|r")
        local color = link and link:match("^|c(%x%x%x%x%x%x%x%x)")
        local quality = color and QUALITY_BY_COLOR[color:lower()]
        local id = quality and LOOT_TRIGGER_BY_QUALITY[quality]
        if id then BLU:PlayTrigger(id) end
    end, "BLU_Classic:loot")

    -- Hardcore deaths: your own death, then everyone else from the combat log
    RGX:RegisterEvent("PLAYER_DEAD", function()
        BLU:PlayTrigger("DeathSelf")
    end, "BLU_Classic:death")

    local combatLogAllowed = true
    if RGX.HasCapability and RGX:HasCapability("combatLogEvent") ~= nil then
        combatLogAllowed = RGX:HasCapability("combatLogEvent")
    end
    if combatLogAllowed and CombatLogGetCurrentEventInfo then
        RGX:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
            local _, subevent, _, _, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
            if subevent ~= "UNIT_DIED" or not destName or destName == "" then return end
            if destGUID == UnitGUID("player") then return end   -- PLAYER_DEAD handles you
            if bit.band(destFlags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then return end

            if UnitInRaid and UnitInRaid(destName) then
                BLU:PlayTrigger("DeathRaid")
            elseif UnitInParty and UnitInParty(destName) then
                BLU:PlayTrigger("DeathParty")
            else
                BLU:PlayTrigger("DeathOther")
            end
        end, "BLU_Classic:combatlog")
    end

    -- Coin loot (own share only: the event is not sent for other players' money)
    RGX:RegisterEvent("CHAT_MSG_MONEY", function()
        BLU:PlayTrigger("LootCoin")
    end, "BLU_Classic:money")

    -- Honor and collection triggers
    RGX:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        BLU.enteredWorldAt = GetTime and GetTime() or 0
    end, "BLU_Classic:enterworld")

    for _, page in pairs(BLU.TriggerPages) do
        for _, trigger in ipairs(page) do
            if trigger.event and trigger.available ~= false then
                local id = trigger.id
                local ok = pcall(function()
                    RGX:RegisterEvent(trigger.event, function()
                        -- PvP rank events can arrive while the character loads; ignore them then.
                        local now = GetTime and GetTime() or 0
                        if id == "PvPRankUp" and BLU.enteredWorldAt and (now - BLU.enteredWorldAt) < 5 then
                            return
                        end
                        BLU:PlayTrigger(id)
                    end, "BLU_Classic:" .. id)
                end)
                trigger.available = ok == true
            end
        end
    end
end
