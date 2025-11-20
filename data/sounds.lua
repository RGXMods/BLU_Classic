--=====================================================================================
-- Sound IDs
--=====================================================================================

muteSoundIDs = {
    retail = {
        569143,  -- Achievement
        1489546, -- Honor
        569593,  -- Level Up
        642841,  -- Battle Pet Level
        4745441, -- Renown
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439,  -- Quest Turned In
        2066672  -- Trade Post
    },
    mists = {
        569143,  -- Achievement
        569593,  -- Level Up
        642841,  -- Battle Pet Level
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439   -- Quest Turned In
    },
    cata = {
        569143,  -- Achievement
        569593,  -- Level Up
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439   -- Quest Turned In
    },
    wrath = {
        569143,  -- Achievement
        569593,  -- Level Up
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439   -- Quest Turned In
    },
    tbc = {
        569593,  -- Level Up
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439   -- Quest Turned In
    },
    vanilla = {
        569593,  -- Level Up
        568016,  -- Reputation
        567400,  -- Quest Accepted
        567439   -- Quest Turned In
    }
}

--=====================================================================================
-- Sound Options
--=====================================================================================

soundOptions = {
    default = "[Default]",
    random = "[Random]",
    altered_beast = "Altered Beast",
    assassins_creed = "Assassin's Creed",
    castlevania = "Castlevania",
    diablo_2 = "Diablo 2",
    dragon_quest = "Dragon Quest",
    dota_2 = "DotA 2",
    elden_ring = {
        elden_ring_1 = "Elden Ring (1)",
        elden_ring_2 = "Elden Ring (2)",
        elden_ring_3 = "Elden Ring (3)",
        elden_ring_4 = "Elden Ring (4)",
        elden_ring_5 = "Elden Ring (5)",
        elden_ring_6 = "Elden Ring (6)",
    },
    everquest = "EverQuest",
    fallout = {
        fallout_new_vegas = "Fallout - New Vegas",
        fallout_3 = "Fallout 3",
    },
    final_fantasy = "Final Fantasy",
    fire_emblem = {
        fire_emblem = "Fire Emblem",
        fire_emblem_awakening = "Fire Emblem - Awakening",
    },
    fly_for_fun = "Fly For Fun",
    fortnite = "Fortnite",
    gta_san_andreas = "GTA - San Andreas",
    kingdom_hearts_3 = "Kingdom Hearts 3",
    kirby = {
        kirby_1 = "Kirby (1)",
        kirby_2 = "Kirby (2)",
    },
    league_of_legends = "League of Legends",
    legend_of_zelda = "Legend of Zelda",
    maplestory = "Maplestory",
    metal_gear_solid = "Metal Gear Solid",
    minecraft = "Minecraft",
    modern_warfare_2 = "Modern Warfare 2",
    morrowind = "Morrowind",
    old_school_runescape = "Old School Runescape",
    palworld = "Palworld",
    path_of_exile = "Path of Exile",
    pokemon = "Pokemon",
    ragnarok_online = "Ragnarok Online",
    shining_force = {
        shining_force_2 = "Shining Force II",
        shining_force_3_1 = "Shining Force III (1)",
        shining_force_3_2 = "Shining Force III (2)",
        shining_force_3_3 = "Shining Force III (3)",
        shining_force_3_4 = "Shining Force III (4)",
        shining_force_3_5 = "Shining Force III (5)",
        shining_force_3_6 = "Shining Force III (6)",
        shining_force_3_7 = "Shining Force III (7)",
        shining_force_3_8 = "Shining Force III (8)",
        shining_force_3_9 = "Shining Force III (9)",
        shining_force_3_10 = "Shining Force III (10)",
        shining_force_3_11 = "Shining Force III (11)",
    },
    skyrim = "Skyrim",
    sonic_the_hedgehog = "Sonic The Hedgehog",
    spyro_the_dragon = "Spyro The Dragon",
    super_mario_bros_3 = "Super Mario Bros 3",
    warcraft_3 = {
        warcraft_3_1 = "Warcraft 3 (1)",
        warcraft_3_2 = "Warcraft 3 (2)",
        warcraft_3_3 = "Warcraft 3 (3)",
    },
    witcher_3 = {
        witcher_3_1 = "Witcher 3 (1)",
        witcher_3_2 = "Witcher 3 (2)",
    }
}

--=====================================================================================
-- Default Sounds
--=====================================================================================
defaultSounds = {
    [1] = { -- Achievement
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\achievement_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\achievement_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\achievement_default_high.ogg"
    },
    [2] = { -- Battle Pet Level
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\battle_pet_level_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\battle_pet_level_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\battle_pet_level_default_high.ogg"
    },
    [3] = { -- Honor
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\honor_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\honor_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\honor_default_high.ogg"
    },
    [4] = { -- Level Up
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\level_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\level_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\level_default_high.ogg"
    },
    [5] = { -- Renown
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\renown_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\renown_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\renown_default_high.ogg"
    },
    [6] = { -- Rep
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\rep_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\rep_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\rep_default_high.ogg"
    },
    [7] = { -- Quest Accept
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_accept_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_accept_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_accept_default_high.ogg"
    },
    [8] = { -- Quest Turn In
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\quest_default_high.ogg"
    },
    [9] = { -- Post
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\post_default_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\post_default_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\post_default_high.ogg"
    }
}

--=====================================================================================
-- Custom Sounds
--=====================================================================================
sounds = {
    ["altered_beast"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\altered_beast_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\altered_beast_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\altered_beast_high.ogg"
    },
    ["assassins_creed"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\assassins_creed_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\assassins_creed_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\assassins_creed_high.ogg"
    },
    ["castlevania"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\castlevania_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\castlevania_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\castlevania_high.ogg"
    },
    ["diablo_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\diablo_2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\diablo_2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\diablo_2_high.ogg"
    },
    ["dragon_quest"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\dragon_quest_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\dragon_quest_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\dragon_quest_high.ogg"
    },
    ["dota_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\dota_2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\dota_2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\dota_2_high.ogg"
    },
    ["elden_ring_1"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-1_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-1_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-1_high.ogg"
    },
    ["elden_ring_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-2_high.ogg"
    },
    ["elden_ring_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-3_high.ogg"
    },
    ["elden_ring_4"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-4_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-4_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-4_high.ogg"
    },
    ["elden_ring_5"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-5_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-5_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-5_high.ogg"
    },
    ["elden_ring_6"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-6_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-6_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\elden_ring-6_high.ogg"
    },
    ["everquest"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\everquest_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\everquest_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\everquest_high.ogg"
    },
    ["fallout_new_vegas"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_new_vegas_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_new_vegas_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_new_vegas_high.ogg"
    },
    ["fallout_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fallout_3_high.ogg"
    },
    ["final_fantasy"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\final_fantasy_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\final_fantasy_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\final_fantasy_high.ogg"
    },
    ["fire_emblem"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_high.ogg"
    },
    ["fire_emblem_awakening"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_awakening_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_awakening_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fire_emblem_awakening_high.ogg"
    },
    ["fly_for_fun"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fly_for_fun_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fly_for_fun_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fly_for_fun_high.ogg"
    },
    ["fortnite"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\fortnite_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\fortnite_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\fortnite_high.ogg"
    },
    ["gta_san_andreas"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\gta_san_andreas_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\gta_san_andreas_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\gta_san_andreas_high.ogg"
    },
    ["kingdom_hearts_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\kingdom_hearts_3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\kingdom_hearts_3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\kingdom_hearts_3_high.ogg"
    },
    ["kirby_1"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-1_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-1_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-1_high.ogg"
    },
    ["kirby_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\kirby-2_high.ogg"
    },
    ["league_of_legends"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\league_of_legends_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\league_of_legends_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\league_of_legends_high.ogg"
    },
    ["legend_of_zelda"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\legend_of_zelda_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\legend_of_zelda_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\legend_of_zelda_high.ogg"
    },
    ["maplestory"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\maplestory_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\maplestory_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\maplestory_high.ogg"
    },
    ["metal_gear_solid"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\metalgear_solid_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\metalgear_solid_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\metalgear_solid_high.ogg"
    },
    ["minecraft"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\minecraft_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\minecraft_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\minecraft_high.ogg"
    },
    ["modern_warfare_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\modern_warfare_2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\modern_warfare_2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\modern_warfare_2_high.ogg"
    },
    ["morrowind"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\morrowind_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\morrowind_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\morrowind_high.ogg"
    },
    ["old_school_runescape"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\old_school_runescape_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\old_school_runescape_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\old_school_runescape_high.ogg"
    },
    ["palworld"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\palworld_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\palworld_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\palworld_high.ogg"
    },
    ["path_of_exile"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\path_of_exile_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\path_of_exile_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\path_of_exile_high.ogg"
    },
    ["pokemon"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\pokemon_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\pokemon_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\pokemon_high.ogg"
    },
    ["ragnarok_online"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\ragnarok_online_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\ragnarok_online_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\ragnarok_online_high.ogg"
    },
    ["shining_force_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_2_high.ogg"
    },
    ["shining_force_3_1"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-1_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-1_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-1_high.ogg"
    },
    ["shining_force_3_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-2_high.ogg"
    },
    ["shining_force_3_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-3_high.ogg"
    },
    ["shining_force_3_4"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-4_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-4_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-4_high.ogg"
    },
    ["shining_force_3_5"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-5_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shing_force_3-5_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-5_high.ogg"
    },
    ["shining_force_3_6"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-6_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-6_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-6_high.ogg"
    },
    ["shining_force_3_7"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-7_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-7_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-7_high.ogg"
    },
    ["shining_force_3_8"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-8_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-8_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-8_high.ogg"
    },
    ["shining_force_3_9"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-9_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-9_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-9_high.ogg"
    },
    ["shining_force_3_10"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-10_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-10_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-10_high.ogg"
    },
    ["shining_force_3_11"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-11_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-11_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\shining_force_3-11_high.ogg"
    },
    ["skyrim"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\skyrim_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\skyrim_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\skyrim_high.ogg"
    },
    ["sonic_the_hedgehog"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\sonic_the_hedgehog_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\sonic_the_hedgehog_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\sonic_the_hedgehog_high.ogg"
    },
    ["spyro_the_dragon"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\spyro_the_dragon_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\spyro_the_dragon_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\spyro_the_dragon_high.ogg"
    },
    ["super_mario_bros_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\super_mario_bros_3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\super_mario_bros_3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\super_mario_bros_3_high.ogg"
    },
    ["warcraft_3_1"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3_high.ogg"
    },
    ["warcraft_3_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-2_high.ogg"
    },
    ["warcraft_3_3"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-3_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-3_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\warcraft_3-3_high.ogg"
    },
    ["witcher_3_1"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-1_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-1_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-1_high.ogg"
    },
    ["witcher_3_2"] = {
        [1] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-2_low.ogg",
        [2] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-2_med.ogg",
        [3] = "Interface\\Addons\\BLU_Classic\\sounds\\witcher_3-2_high.ogg"
    }
}
--=====================================================================================
-- 
--=====================================================================================
