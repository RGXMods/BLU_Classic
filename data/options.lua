--=====================================================================================
-- Default Profile Settings (the options UI lives in data/ui/)
--=====================================================================================
BLU_Classic.defaults = {
    profile = {
        debugMode = false,
        showWelcomeMessage = true,
        classicMinimapIconEnabled = true,
        classicMinimapAngle = 220,
        AchievementSoundSelect = 35,
        AchievementVolume = 2.0,
        BattlePetLevelSoundSelect = 37,
        BattlePetLevelVolume = 2.0,
        LevelSoundSelect = 24,
        LevelVolume = 2.0,
        QuestAcceptSoundSelect = 26,
        QuestAcceptVolume = 2.0,
        QuestSoundSelect = 25,
        QuestVolume = 2.0,
        RepSoundSelect = 15,
        RepVolume = 2.0,
    },
}

-- Combat and Loot triggers (data/triggers.lua): sound 0 = none, volume 2 = medium.
for _, trigger in ipairs(BLU_Classic.TriggerList or {}) do
    BLU_Classic.defaults.profile[trigger.sound] = 0
    BLU_Classic.defaults.profile[trigger.volume] = 2
end
