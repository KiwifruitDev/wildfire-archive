/*
    Wildfire Servers - Achievement System
    File Description: Achievement System Config
    Creation Date: 11/17/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
    All rights reserved.
*/

-- Create the KIWI_ACHIEVEMENTS configuration table
KIWI_ACHIEVEMENTS = KIWI_ACHIEVEMENTS or {}

-- Let's define some constants
KIWI_ACHIEVEMENTS.CONST = {}
KIWI_ACHIEVEMENTS.CONST.Version = 1 -- Updating this will force write new data via SQL
KIWI_ACHIEVEMENTS.CONST.ThinkDelay = 10 -- How many seconds between each think tick (see KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.Think)
KIWI_ACHIEVEMENTS.CONST.Prefix = "ACHIEVEMENTS"
KIWI_ACHIEVEMENTS.CONST.Icon = "atlaschat/customemoticons/bms.png"

KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM = {
    None = 0, -- Retired achievement
    Basic = 1, -- Basic achievement
    Intermediate = 2, -- Intermediate achievement
    Advanced = 3, -- Advanced achievement
    Impossible = 4, -- Impossible achievement
}

-- Define the achievement tiers with sound effects and such
KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIERS = {
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.None] = {
        Name = "Retired",
        Sound = "wildfire/achievements/success_roll_up_achieve4.mp3",
        Description = "A retired achievement.",
        Color = Color(128, 128, 128),
        Money = 1000,
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Basic] = {
        Name = "Basic",
        Sound = "wildfire/achievements/success_roll_up_achieve2.mp3",
        Description = "A simple achievement.",
        Color = Color(255, 255, 255),
        Money = 1000,
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Intermediate] = {
        Name = "Intermediate",
        Sound = "wildfire/achievements/success_roll_up_achieve3.mp3",
        Description = "A hard achievement.",
        Color = Color(255, 128, 0),
        Money = 5000,
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Advanced] = {
        Name = "Advanced",
        Sound = "wildfire/achievements/success_roll_up_achieve1.mp3",
        Description = "An extremely difficult achievement.",
        Color = Color(255, 0, 0),
        Money = 10000,
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Impossible] = {
        Name = "Impossible",
        Sound = "wildfire/achievements/success_roll_up_achieve5.mp3",
        Description = "An impossible achievement.",
        Color = Color(255, 0, 255),
        Money = 25000,
    },
}

KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM = {
    None = 0, -- Retired category
    General = 1, -- General category
    Scientific = 2, -- Scientific category
    Alien = 3, -- Xenian category
    Hazardous = 4, -- HECU category
    Secure = 5, -- Security category
}

-- Achievement Categories
KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORIES = {
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.None] = {
        Name = "Retired",
        Description = "This achievement is no longer obtainable.",
        Restricted = true,
        CategoryCheck = "",
        Color = Color(128, 128, 128),
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.General] = {
        Name = "General",
        Description = "General achievements that can be unlocked by anyone.",
        Restricted = false,
        CategoryCheck = "surface",
        Color = Color(251, 126, 20),
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific] = {
        Name = "Scientific",
        Description = "These achievements can only be unlocked by scientists.",
        Restricted = true,
        CategoryCheck = "scientist",
        Color = Color(0, 128, 0),
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Alien] = {
        Name = "Alien",
        Description = "These achievements can only be unlocked by xenian creatures.",
        Restricted = true,
        CategoryCheck = "xenian",
        Color = Color(0, 255, 128),
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Hazardous] = {
        Name = "Hazardous",
        Description = "These achievements can only be unlocked by H.E.C.U. members.",
        Restricted = true,
        CategoryCheck = "hecu",
        Color = Color(255, 128, 128),
    },
    [KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Secure] = {
        Name = "Secure",
        Description = "These achievements can only be unlocked by security guards.",
        Restricted = true,
        CategoryCheck = "security",
        Color = Color(0, 128, 255),
    },
}

KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM = {
    None = 0, -- Do not activate naturally
    Think = 1, -- Activate every think tick (see KIWI_ACHIEVEMENTS.CONST.ThinkDelay)
    PlayerSpawn = 2, -- Activate on spawn (player may be invalid here, not guaranteed to work on first join)
    PlayerInitialSpawn = 3, -- Activate on initial (first) spawn
    PlayerDeath = 4, -- Activate on death
    EntityTakeDamage = 7, -- Activate on damage
    BoundingBox_HatEntered = 9, -- Activate when the hidden hat enters a bounding box
    PlayerUse = 10, -- Activate on use
    CrystalMined = 11, -- Activate when a crystal was mined (scripted to be used with a specific crystal mine entity, not for general use)
    PlayerSay = 12, -- Activate on chat
    PlayerStartIntercom = 13, -- Activate when a player starts using their microphone 
    PlayerEndIntercom = 14, -- Activate when a player stops using their microphone
    ULibPostTranslatedCommand = 15, -- Activate when a player uses an ULX command
    PlayerDrowning = 16, -- Activate when a player drowns (custom script)
    ResonanceCascade = 17, -- Activate when a resonance cascade is triggered
    ShowID = 18, -- Activate when a player shows their ID
    OnPlayerCraft = 19, -- Activate when a player crafts something
}

-- There is no KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATIONS table, as it is not needed.
-- Achievements
KIWI_ACHIEVEMENTS.ACHIEVEMENTS = {
    ["RarestSpecimen"] = { -- Names are keys here so that players retain their achievements if the order changes.
        Name = "The Rarest Specimen",
        Description = "Teleport the hidden hat to Xen before anyone else does and earn Bugbait!",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Advanced,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1, -- How many times does the criteria need to be met to unlock this achievement? (an amount of 1 will not display a progress bar)
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.BoundingBox_HatEntered,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if not IsValid(param2) then return false end
            if param2:GetName() == "achievementhat" then
                local players = {}
                for _, ply in pairs(player.GetAll()) do
                    if ply:GetNWString("location") == "Sector A Teleport Lab" then //"Sector A Lambda Core" then
                        table.insert(players, ply)
                        ply:SendLua("surface.PlaySound(\"debris/beamstart2.wav\")")
                    end
                end
                local explosion = ents.Create("env_explosion")
                explosion:SetPos(param2:GetPos())
                explosion:SetKeyValue("spawnflags", "1")
                explosion:SetKeyValue("iMagnitude", "0")
                explosion:SetKeyValue("iRadiusOverride", "0")
                explosion:SetKeyValue("iMagnitudeOverride", "0")
                explosion:Spawn()
                explosion:Fire("Explode", 0, 0)
                param2:SetPos(Vector(-4396, -11578, 68))
                return true, players
            end
            return false
        end,
        Author = "Kiwifruit",
        AuthorSteamID = "76561198042912823",
        Icon = "wildfire/ui/achievements/rare_specimen.png",
        Callback = nil,
    },
    ["RainbowCrystal"] = {
        Name = "Rainbow Crystal Collector",
        Description = "Mine a rainbow crystal before it disappears.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Intermediate,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.CrystalMined,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if not IsValid(param2) then return false end -- player
            if not IsValid(param3) then return false end -- crystal entity
            return param3:GetCrystalEffect() == "Rainbow", param2 -- The player who mined the crystal.
        end,
        Author = "Kiwifruit",
        AuthorSteamID = "76561198042912823",
        Icon = "wildfire/ui/achievements/rainbow_crystal.png",
        Callback = nil,
    },
    ["AllIntercoms"] = {
        Name = "An Interconnected Intercom",
        Description = "Be apart of 3 different players using 3 intercoms.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Advanced,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.General,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.PlayerStartIntercom,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if not IsValid(param2) then return false end
            local count = 0
            local playertable = {}
            for k, v in pairs(player.GetAll()) do
                if IsValid(v) then
                    if v.IntercomUser == true then
                        count = count + 1
                        table.insert(playertable, v)
                    end
                end
            end
            if count >= 3 then -- DEBUG: SET TO 3 WHEN DONE
                return true, playertable
            end
            return false
        end,
        Author = "Kiwifruit",
        AuthorSteamID = "76561198042912823",
        Icon = "wildfire/ui/achievements/interconnected_intercom.png",
        Callback = nil,
    },
    ["SlapAttack"] = {
        Name = "Slap Attack",
        Description = "Get slapped by a staff member and earn Slappers!",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Impossible,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.General,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.ULibPostTranslatedCommand,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if not IsValid(param2) then return false end
            return param3 == "ulx slap", param4[2] -- The players that were slapped.
        end,
        Author = "Kiwifruit",
        AuthorSteamID = "76561198042912823",
        Icon = "wildfire/ui/achievements/slap_attack.png",
        Callback = nil,
    },
    -- PLAYER-MADE ACHIEVEMENTS --
    ["OxyMoron"] = {
        Name = "Oxy-Moron",
        Description = "You seem to be suffocating in Xen, might as well be dead.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Intermediate,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.General,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.PlayerDrowning,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if not IsValid(param2) then return false end
            if param2:GetNWString("location") == "Xen" then
                return true, param2
            end
            return false
        end,
        Author = "Steven Bills",
        AuthorSteamID = "76561198065947899",
        Icon = "wildfire/ui/achievements/oxy_moron.png",
        Callback = nil,
    },
    ["UnforseenConsequences"] = {
        Name = "Unforseen Consequences",
        Description = "Cause a resonance cascade, I think you should have shut that test down.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Basic,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.ResonanceCascade,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            return true, param2 -- The player in the AMS labs.
        end,
        Author = "AlexanderB2109",
        AuthorSteamID = "76561198347577457",
        Icon = "wildfire/ui/achievements/unforseen_consequences.png",
        Callback = nil,
    },
    ["IDPlease"] = {
        Name = "ID Please",
        Description = "Ah yes making walking harder since 1982, /showid please.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Basic,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.General,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.ShowID,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            return true, param2 -- The players involved in the ID.
        end,
        Author = "Spade",
        AuthorSteamID = "76561199005464582",
        Icon = "wildfire/ui/achievements/unknown.png",
        Callback = nil,
    },
    ["FastXenTransport"] = {
        Name = "Fast Xen Transport",
        Description = "Craft your first Displacer, I'm sure this could be put to good use...",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Intermediate,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.OnPlayerCraft,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if param3 == "Displacer" then
                return true, param2 -- The player that crafted the Displacer.
            end
        end,
        Author = "noobland3601",
        AuthorSteamID = "76561198822016447",
        Icon = "wildfire/ui/achievements/unknown.png",
        Callback = nil,
    },
    ["The Ultimate Weapon"] = {
        Name = "The Ultimate Weapon",
        Description = "Craft your first Gluon Gun.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Advanced,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.OnPlayerCraft,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if param3 == "Gluon Gun" then
                return true, param2 -- The player that crafted the Ultimate Weapon.
            end
        end,
        Author = "noobland3601",
        AuthorSteamID = "76561198822016447",
        Icon = "wildfire/ui/achievements/unknown.png",
        Callback = nil,
    },
    ["DontLetItOvercharge"] = {
        Name = "Don't let it overcharge!",
        Description = "Craft your first Tau Cannon.",
        Tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Intermediate,
        Category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORY_ENUM.Scientific,
        Amount = 1,
        Activation = KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM.OnPlayerCraft,
        ActivationCondition = function(param1, param2, param3, param4, param5)
            if param3 == "Tau Cannon" then
                return true, param2 -- The player that crafted the Ultimate Weapon.
            end
        end,
        Author = "noobland3601",
        AuthorSteamID = "76561198822016447",
        Icon = "wildfire/ui/achievements/unknown.png",
        Callback = nil,
    },
}
