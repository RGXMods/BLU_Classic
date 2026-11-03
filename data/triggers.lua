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
}

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

    -- Coin loot (own share only: the event is not sent for other players' money)
    RGX:RegisterEvent("CHAT_MSG_MONEY", function()
        BLU:PlayTrigger("LootCoin")
    end, "BLU_Classic:money")
end
