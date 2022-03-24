// Wildfire Black Mesa Roleplay
// File description: BMRP shared function script
// Copyright (c) 2022 KiwifruitDev
// Licensed under the MIT License.
//*********************************************************************************************
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//*********************************************************************************************
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Global variable to store everything from here.
BMRP = {}

// Presents or something
BMRP.MaxPresents = 5
BMRP.MaxRecievedPresents = 5
BMRP.MaxSentPresents = 5

// PLAYER STUFF //
BMRP.PLAYERS = {}

BMRP.PLAYERS.DEVELOPERS = { // Set these to the owners/developers SteamIDs.
    "STEAM_0:0:78540453", // Treycen
    "STEAM_0:1:41323547", // Kiwifruit
    "STEAM_0:1:75090064", // Flynn
}

// BANNED IP ADDRESSES
// BLANKED OUT FOR SECURITY REASONS
BMRP.PLAYERS.BANNEDIPS = {}

// FORBIDDEN NAMES
// if player's username contains any of these, they will not be allowed to join.
// BLANKED OUT FOR SECURITY REASONS.
BMRP.FORBIDDEN_NAMES = {}

// MAPS //
BMRP.MAPS = {
    ["rp_sectorc_beta_wf"] = {
        clearance = {
            { // level 1
                "controlroom scanner 1699", // Front entrance to BMRF.
                "controlroom scanner 169", // Exit from BMRF.
            },
            { // level 2
                "retinal 5", // Entrance to lab area.
                "controlroom scanner 135", // Entrance to main transit area from elevator.

                "biodoorset0button", // Biohazard lab entrance button.
                //2248, // Biohazard lab exit button.
                4015, // Biohazard lab window button. (FIXME: Make this not an MCID.)
                2239, // Biohazard lab extermination button. (FIXME: Make this not an MCID.)
                "button_crab1", // Biohazard lab Jail cell 1
                "button_crab2", // Biohazard lab Jail cell 2

                2233, // Sector C main entrance scanner. (FIXME: Make this not an MCID.)
                2247, // Sector C main exit scanner. (FIXME: Make this not an MCID.)
                "sector c access scanner", // Sector C AMS back entrance entrance.
                "controlroom scanner 2", // Sector C AMS back entrance exit.
                "controlroom scanner 1", // Sector C AMS main entrance door.
                "motor_button", // Sector C AMS Rotors Stage 1.
                "chamber scanner", // Sector C AMS blast doors.

                //1265, // Sector D main entrance scanner. (FIXME: What is this?)

                "lambdalab scanner", // Lambda main entrance scanner.
                // OBSOLETE:
                //4351, // Lambda keypad entrance.
                //4301, // Lambda keypad exit.
                //1241, // Lambda decon entrance.
                //1247, // Lambda big blast door.
                //4315, // Lambda big blast door exit button.
                //4313, // Lambda decon exit
            },
            { // level 3
                "keypad1", // Sector C AMS Rotors Stage 2/First Beam.
                "cartbutton", // Sector C AMS Sample lift.

                "retinal 3", // Security Sector main entrance scanner. (BUG: "retinal 3" shares the same name from the office sector.)
                //1259, // Security Sector back exit/entrance. (FIXME: What is this?)

                "lambdalab mainbutton 1", // Lambda startup button 1.
                "lambdalab mainbutton 2", // Lambda startup button 2.
                "lambdalab poweroff", // Lambda turn-off button.

                "carenterlocker", // Outside gate
            },
            { // level 4
                "secondbutton", // Sector C AMS Rotors Stage 3/Secondary Beams.
            },
            { // level 5
                "secdoor scanner", // Security Sector globe room entrance scanner.
            },
            { // Admin Only Level 6+
                "adminbutton9", // (As shown in-game) - "Announcements Off" (FIXME: Make this not an MCID.)
                "adminbutton7", // (As shown in-game) - "Announcements Bad ON" (FIXME: Make this not an MCID.)
                "adminbutton8", // (As shown in-game) - "Announcements Good Enable" (FIXME: Make this not an MCID.)
                "adminbutton5", // (As shown in-game) - "Shake + Explode" (FIXME: Make this not an MCID.)
                "adminbutton2", // (As shown in-game) - "Play Event Noise" (FIXME: Make this not an MCID.)
                "adminbutton6", // (As shown in-game) - "Event 1 Shake" (FIXME: Make this not an MCID.)
                "adminbutton4", // (As shown in-game) - "Event Noise 2" (FIXME: Make this not an MCID.)
                "eventmanual", // (As shown in-game) - "Trigger Disaster"
                "adminbutton1", // (As shown in-game) - "STOP MACHINE" (FIXME: Make this not an MCID.)
                "earthfire", // (As shown in-game) - "Earthquake + Fire"
                "invasionspawn", // (As shown in-game) - "Invasion Spawner"
                "adminbutton3", // (As shown in-game) - "Invasion Noise" (FIXME: Make this not an MCID.)
                "adminbutton10", // ADMIN ROOM - ??? (FIXME: Make this not an MCID.)
            },
            { // Military (level 7+)
                "controlroom scanner 1352", // HECU Base Entrance
            },
        },
        blackoutdisabled = {  // This table is disabled during a blackout. Remember, Map Creation IDs.
            "exterminatebutton", // Biohazard lab extermination button. (FIXME: Make this not an MCID.)
            "motor_button", // Sector C AMS Rotors Stage 1.
            "keypad1", // Sector C AMS Rotors Stage 2/First Beam.
            "secondbutton", // Sector C AMS Rotors Stage 3/Secondary Beams.
            "cartbutton", // Sector C AMS Sample lift.
            "lambdalab mainbutton 1", // Lambda startup button 1.
            "lambdalab mainbutton 2", // Lambda startup button 2.
            "lambdalab poweroff", // Lambda turn-off button.
        },
        amsdisabled = { // AMS DISABLED
            "motor_button", // Sector C AMS Rotors Stage 1.
            "keypad1", // Sector C AMS Rotors Stage 2/First Beam.
            "secondbutton", // Sector C AMS Rotors Stage 3/Secondary Beams.
            "cartbutton", // Sector C AMS Sample lift.
            //2631, // Sector C AMS main entrance door. (This could cause issues, so it's disabled.)
        },
        lambdadisabled = { // LAMBDA DISABLED
            "lambdalab mainbutton 1", // Lambda startup button 1.
            "lambdalab mainbutton 2", // Lambda startup button 2.
            "lambdalab poweroff", // Lambda turn-off button.
            // OBSOLETE:
            //1247, // Lambda big blast door.
            //4315, // Lambda big blast door exit button.
        },
        blackoutlights = {
            "facilitypower_light",
            "facilitypower_tramlight",
            "floor_spotlight_1",
            "c3a2d_light02",
            "c3a2d_light03",
        },
        turnonduringblackout = {
            "c3a2d_light01",
            "crabglass_lights",
        },
        lambdalightson = {
            "c3a2d_light02",
            "c3a2d_light03",
        },
        lambdalightsoff = {
            "c3a2d_light01",
        },
        lambdadoor = "c3a2d_door3",
        redalertlights = "red_lite",
        redalertsound = "red_snd",
        redalertsprite = "",
        alertsound = "bmrp_alert_sound",
        lockdowndoor = "lockdowndoor",
        amscart = "sample_cart2",
        deathtriggers = "emergencyhurt",
        amsarm = "probe_arm_2",
        amstrigger = "disastermaker",
        teletele = "teletele",
        maintenancedoors = "noice",
        hecudoor = "controlroom scanner 1352",
        lambdabutton = "lambda button off",
        cascadebeam = "beam_2",
        useduringcascade = {
            "adminbutton3",
            "invasionspawn",
            "earthfire",
            "adminbutton5",
            "eventmanual",
        },
        fireduringcascade = {
            {"se", "TurnOff"},
            {"se_l", "TurnOff"},
            {"stage_two_beams", "TurnOff"},
            {"stage_two_beams", "TurnOff"},
            {"start_disaster_red_lights", "TurnOff"},
            {"start_disaster_shake", "StopShake"},
            {"disaster_big_shake", "StopShake"},
            {"disaster_big_shake_2", "StopShake"},
            {"tramstation fire", "Extinguish"},
            {"tramstation fire lgt", "TurnOff"},
            {"tramstation fire snd", "StopSound"},
            {"eventgas", "TurnOff"},
            {"emersparks", "StopSpark"},
            {"sparks2", "StopSpark"},
            {"spark_1", "StopSpark"},
            {"spark_2", "StopSpark"},
            {"spark_3", "StopSpark"},
            {"spark_4", "StopSpark"},
            {"spawner_sprite1", "HideSprite"},
            {"spawner_sprite2", "HideSprite"},
            {"spawner_sprite3", "HideSprite"},
            {"spawnheadcrabssprite", "HideSprite"},
            {"earthquake_timer_01", "Disable"},
            {"eventshake1", "StopShake"},
            {"disastermaker", "Enable"},
            {"eventgas", "TurnOff"},
            {"tldoor", "Close"},
            {"ladderdoor", "Close"},
        },
        amsdisables = {
            {"motor_button", "PressOut"},
            {"motor_button", "Unlock"},
            {"keypad1", "PressOut"},
            {"keypad1", "Lock"},
            {"secondbutton", "PressOut"},
            {"secondbutton", "Lock"},
            {"cartbutton", "PressOut"},
            {"cartbutton", "Unlock"},
            {"tldoor", "Close"}, 
            {"cascadereset", "Use"},
        },
        amsclose = {
            "sample_cart2_lift",
            "sample_fence",
        },
        amsopen = {
            "de_cart_door",
        },
        amslift = "sample_delivery_door1",
        samplebadvec = Vector(-3074.0104980469, -3781.7504882813, -1372.5435791016),
        samplebadcrystalvec = Vector(-3122.7954101563, -3836.9279785156, -1359.1303710938),
        ogcartpos = Vector(-3770.7985839844, -3501.130859375, -1573.0346679688),
    },
    ["project_sigma_v2_alpha3"] = {
        clearance = {
            { // level 1
            },
            { // level 2
            },
            { // level 3
            },
            { // level 4
            },
            { // level 5
            },
            { // Admin Only Level 6+
                "red_alert1", // STUPID ALARM BUTTON
            },
            { // Military (level 7+)
            },
        },
        blackoutdisabled = {  // This table is disabled during a blackout. Remember, Map Creation IDs.
        },
        amsdisabled = { // AMS DISABLED
        },
        lambdadisabled = { // LAMBDA DISABLED
        },
        blackoutlights = {},
        turnonduringblackout = {},
        redalertlights = "",
        redalertsound = "",
        alertsound = "",
        lockdowndoor = "",
        amscart = "",
        deathtriggers = "",
        amsarm = "",
        amstrigger = "",
        teletele = "",
        maintenancedoors = "",
        hecudoor = "",
        lambdabutton = "",
        cascadebeam = "",
        useduringcascade = {},
        fireduringcascade = {},
        amsdisables = {},
        amsclose = {},
        amsopen = {},
        amslift = "",
        samplebadvec = Vector(0,0,0),
        samplebadcrystalvec = Vector(0,0,0),
        ogcartpos = Vector(0,0,0),
    },
    ["rp_bmrf_wf"] = {
        clearance = {
            { // level 1
            },
            { // level 2
                "bmrf_ams_buttonstart", // Rotors button.
            },
            { // level 3
                "bmrf_ams_buttonstage1", // Stage 1 AMS button
                "bmrf_lambdacorereactor_start_btn", // Lambda Core Reactor button.
                "bmrf_lambdacorereactor_stop_btn", // Lambda Core Reactor button.
                "bmrf_lambdacorereactor_exit_btn", // Lambda Core Reactor button.
            },
            { // level 4
                "bmrf_ams_buttonstage2", // Stage 2 AMS button
            },
            { // level 5
            },
            { // Admin Only Level 6+
            },
            { // Military (level 7+)
            },
        },
        blackoutdisabled = {  // This table is disabled during a blackout. Remember, Map Creation IDs.
        },
        amsdisabled = { // AMS DISABLED
        },
        lambdadisabled = { // LAMBDA DISABLED
        },
        blackoutlights = {
            "bmrf_facilitylights"
        },
        turnonduringblackout = {},
        redalertlights = "bmrf_alert_light",
        redalertsound = "bmrf_alert_sound",
        redalertsprite = "bmrf_alert_sprite",
        alertsound = "bmrf_alert_sound",
        lockdowndoor = "",
        amscart = "",
        deathtriggers = "",
        amsarm = "",
        amstrigger = "",
        teletele = "",
        maintenancedoors = "",
        hecudoor = "",
        lambdabutton = "bmrf_lambdacorereactor_stop_btn",
        cascadebeam = "",
        useduringcascade = {},
        fireduringcascade = {},
        amsdisables = {},
        amsclose = {},
        amsopen = {},
        amslift = "",
        samplebadvec = Vector(0,0,0),
        samplebadcrystalvec = Vector(0,0,0),
        ogcartpos = Vector(0,0,0),
    },
}

// GROUPS //
BMRP.GROUPS = {}
BMRP.GROUPS.STAFF = { //Set these to your staff groups found in ULX.
    "owner",
    "coowner",
    "superadmin",
    "admin",
    "moderator",
    "trialmoderator",
}
BMRP.GROUPS.DONATOR = { // Set these to your donator groups found in ULX. If you don't have donator, don't worry about it.
    "donator",
}
BMRP.GROUPS.PACACCESS = { // Set these to your pac access groups. If you don't have pac, don't bother!
    "owner",
    "coowner",
    "superadmin",
    "admin",
    "moderator",
    "trialmoderator",
    "pacaccess",
    "builder",
    "donator",
}
BMRP.GROUPS.PLAYER = { // Set these to your user groups. In this scenario, a user is still classed as "pacaccess" so they're technically a user.
    "donator",
    "pacaccess",
    "builder",
    "user",
}
BMRP.GROUPS.SECURTYIDS = { // Set these to your entrusted SteamIDS. These are the managers of all security XP and have access to commander.
    "STEAM_0:0:78540453", // Treycen
    "STEAM_0:1:41323547", // Kiwifruit
    "STEAM_0:0:120902152", // Lena
    "STEAM_0:1:22079064", // Lightning
    "STEAM_0:0:165635013" // Adam
}

// TEAMS //
BMRP.Teams = {}

BMRP.Teams.Security = {
    InternalName = "security",
    TeamNames = {
        "Security Guard",
        "Security Medic",
        "Security Heavy Weapons",
    }
}

BMRP.Teams.Administrative = {
    InternalName = "administrative",
    TeamNames = {
        "Facility Administrator",
    }
}

BMRP.Teams.Surface = {
    InternalName = "surface",
    TeamNames = {
        "Visitor",
    }
}

BMRP.Teams.Scientist = {
    InternalName = "scientist",
    TeamNames = {
        "R&D Scientist",
        "Surveyor",
        "Bioworker",
        "Medical Personnel",
    }
}

BMRP.Teams.HECU = {
    InternalName = "hecu",
    TeamNames = {
        "H.E.C.U Marine",
        "H.E.C.U Medic",
        "H.E.C.U Brute",
    }
}

BMRP.Teams.Service = {
    InternalName = "service",
    TeamNames = {
        "Janitor",
        "Facility Maintenance",
        "Facility Cook",
    }
}

BMRP.Teams.Xenian = {
    InternalName = "xenian",
    TeamNames = {
        "Vortigaunt",
        "Headcrab",
        "Houndeye",
        "Bullsquid",
    }
}

BMRP.PersistentInventory = {
    {
        Name = "Slappers",
        ClassName = "slappers",
        Description = "Slappers! Slap your friends, or your enemies. You earned this from the achievement \"Slap Attack\"!",
        IsWeapon = true,
        Model = "models/props_combine/breenbust.mdl",
        Criteria = function(self, ply)
            return SERVER and ply:GetAchievementProgress("SlapAttack") >= 1 and ply:Alive()
        end,
    },
    {
        Name = "Bugbait",
        ClassName = "weapon_bugbait",
        Description = "Bugbait! This stuff stinks... You earned this from the achievement \"The Rarest Specimen\"!",
        IsWeapon = true,
        Model = "models/weapons/w_bugbait.mdl",
        Criteria = function(self, ply)
            return SERVER and ply:GetAchievementProgress("RarestSpecimen") >= 1 and ply:Alive()
        end,
    },
    {
        Name = "Wowozela",
        ClassName = "wowozela",
        Description = "The Wowozela! Quite the musical experience. Thank you for contributing to Wildfire Servers and its future!",
        IsWeapon = true,
        Model = "models/props_junk/tomabasarab_quaff.mdl",
        Criteria = function(self, ply)
            return SERVER and (ply:GetDiscordPremium() or ply:IsDonator() or ply:IsStaff() or ply:GetDiscordContributor() or ply:GetDiscordAmbassador() or ply:GetDiscordDonator()) and ply:Alive()
        end,
    },
    {
        Name = "Playable Piano",
        ClassName = "gmt_instrument_piano_reborn",
        Description = "A piano! Thank you for contributing to Wildfire Servers and its future!",
        IsWeapon = false,
        Model = "models/fishy/furniture/piano.mdl",
        Criteria = function(self, ply)
            return SERVER and (ply:GetDiscordPremium() or ply:IsDonator() or ply:IsStaff() or ply:GetDiscordContributor() or ply:GetDiscordAmbassador() or ply:GetDiscordDonator()) and ply:Alive()
        end,
    },
    {
        Name = "Wrapping Paper",
        ClassName = "weapon_wrappingpaper",
        Description = "Wrapping Paper! Wrap up items to give away. Thank you for contributing to Wildfire Servers and its future!",
        IsWeapon = true,
        Model = "models/weapons/c_models/c_xms_giftwrap/c_xms_giftwrap.mdl",
        Criteria = function(self, ply)
            return SERVER and (ply:GetDiscordPremium() or ply:IsDonator() or ply:IsStaff() or ply:GetDiscordContributor() or ply:GetDiscordAmbassador() or ply:GetDiscordDonator()) and ply:Alive()
        end,
    },
}

// ================= //
//  Anti-Lag System  //
// Provided by sirro //
// ================= //
local function antilagOn()
	RunConsoleCommand("gmod_mcore_test", "1")
	RunConsoleCommand("mat_queue_mode", "-1")
    if CLIENT then
        RunConsoleCommand("cl_threaded_bone_setup", "1")
        RunConsoleCommand("cl_threaded_client_leaf_system", "1")
        RunConsoleCommand("r_threaded_client_shadow_manager", "1")
        RunConsoleCommand("r_threaded_particles", "1")
        RunConsoleCommand("r_threaded_renderables", "1")
        RunConsoleCommand("r_queued_ropes", "1")
        RunConsoleCommand("studio_queue_mode", "1")
        RunConsoleCommand("mat_bloomscale", "0")
        hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
        hook.Remove("RenderScreenspaceEffects", "RenderBloom")
        hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
        hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
        hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
        hook.Remove("RenderScreenspaceEffects", "RenderSobel")
        hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
        hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
        hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
        hook.Remove("RenderScene", "RenderStereoscopy")
        hook.Remove("RenderScene", "RenderSuperDoF")
        hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
        hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
        hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
        hook.Remove("PostRender", "RenderFrameBlend")
        hook.Remove("PreRender", "PreRenderFrameBlend")
        hook.Remove("Think", "DOFThink")
        hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
        hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
        hook.Remove("PostDrawEffects", "RenderWidgets")
        //hook.Remove("PostDrawEffects", "RenderHalos")
    end
end
hook.Add("InitPostEntity", "BMRP_AntiLag", antilagOn)

// ================ //
// Server Functions //
// ================ //
if SERVER then
    print("----------- BMRP Serverside Intializing... -----------")

    //This wil be used instead of InitPostEntity or PostCleanupMap, combines two hooks into one.
    function BMRP.AddToMapReset(name, func)
        hook.Add("InitPostEntity", name.."_initpostentity", func)
        hook.Add("PostCleanupMap", name.."_postcleanupmap", func) 
    end
end


// ================ //
// Client Functions //
// ================ //
if CLIENT then

    print("----------- BMRP Cientside Intializing... -----------")

end

// Caching
util.PrecacheSound("ambient/explosions/citadel_end_explosion1.wav")

// ================ //
// Shared Functions //
// ================ //

function GetPlayerByName(name)
    for k, v in pairs(player.GetAll()) do
        if not IsValid(v) then continue end
        if not v:IsPlayer() then continue end
        if v:Nick() == name then
            return v
        end
    end
end

-- https://gist.github.com/Uradamus/10323382#gistcomment-3149506
function ShuffleTable(t)
    local tbl = {}
    for i = 1, #t do
      tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function ply:MutePlayer(target)
    ply.mutedplayers = ply.mutedplayers or {}
    ply.mutedplayers[target:SteamID()] = true
end

function ply:UnMutePlayer(target)
    ply.mutedplayers = ply.mutedplayers or {}
    ply.mutedplayers[target:SteamID()] = nil
end

function ply:IsMuted(target)
    ply.mutedplayers = ply.mutedplayers or {}
    return ply.mutedplayers[target:SteamID()]
end

// Checks if the player is in a specific, predefined category
// See also: BMRP.Teams
// Quick reference:
// BMRP.Teams.Security
// BMRP.Teams.Administrative
// BMRP.Teams.Surface
// BMRP.Teams.Scientist
// BMRP.Teams.HECU
// BMRP.Teams.Service
// BMRP.Teams.Xenian
function ply:CategoryCheck(category)
    local ply = self
    local plyteam = team.GetName(ply:Team())
    for _,team in pairs(BMRP.Teams) do
        for k,teamname in pairs(team.TeamNames) do
            if plyteam == teamname then
                return team.InternalName 
            end
        end
    end
    return "global"
end

function ply:HEVSuitEquipped()
    if not self:IsValid() then return false end
    //local job = self:getDarkRPVar("job")
    // doing the above made it so that if you change your job title, you won't be considered wearing a HEV suit
    // therefore, this has been replaced with jobtable check
    local jobtable = self:getJobTable()
    if jobtable and jobtable.playerCanWearSuit then
        return self:GetModel() == "models/motorhead/hevscientist.mdl"
    else
        return false
    end
end

//Checks if the player is a staff member:
function ply:IsStaff()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(BMRP.GROUPS.STAFF) do
        if ply:IsUserGroup(v) then
            return true
        end
    end
    return false
end
//Checks if the player has access to PAC:
function ply:HasPACAccess()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(BMRP.GROUPS.PACACCESS) do
        if ply:IsUserGroup(v) then
            return true
        end
    end
    return false
end
//Checks if the player is a Donator:
function ply:IsDonator()
    local ply = self
    if ply:GetDiscordDonator() then
        return true
    end
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(BMRP.GROUPS.DONATOR) do
        if ply:IsUserGroup(v) then
            return true
        end
    end
    return false
end

//Checks if the player is a developer:
function ply:IsDeveloper()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(BMRP.PLAYERS.DEVELOPERS) do
        if ply:SteamID() == v then
            return true
        end
    end
    return false
end
//Checks if the player is a Security manager
function ply:IsSecurityManager()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(BMRP.GROUPS.SECURTYIDS) do
        if ply:SteamID() == v then
            return true
        end
    end
    return false
end
// Anti-spam universal function
function ply:AntiSpam()
    local ply = self
    if ply.antispam_use == nil or ply.antispam_use == 0 then
        ply.antispam_use = 1
        timer.Destroy(ply:SteamID().."_antispam_use")
        timer.Create(ply:SteamID().."_antispam_use", 0.25, 1, function()
            ply.antispam_use = 0
        end)
        return true
    else
        return false
    end
end

// Presents!
function ply:AddPresent(present)
    self.presents = self.presents or {}
    table.insert(self.presents, present)
end
function ply:GetPresents()
    return self.presents or {}
end
function ply:SetPresents(presents)
    self.presents = presents
end
function ply:ClearPresents()
    self.presents = {}
end
function ply:HasPresent(present)
    return table.HasValue(self:GetPresents(), present)
end
function ply:RemovePresent(present)
    for k, v in pairs(self:GetPresents()) do
        if v == present then
            table.remove(self:GetPresents(), k)
        end
    end
end
-- presents you've sent
function ply:AddSentPresent(present)
    self.sentPresents = self.sentPresents or {}
    table.insert(self.sentPresents, present)
end
function ply:GetSentPresents()
    return self.sentPresents or {}
end
function ply:SetSentPresents(presents)
    self.sentPresents = presents
end
function ply:ClearSentPresents()
    self.sentPresents = {}
end
function ply:HasSentPresent(present)
    return table.HasValue(self:GetSentPresents(), present)
end
function ply:RemoveSentPresent(present)
    for k, v in pairs(self:GetSentPresents()) do
        if v == present then
            table.remove(self:GetSentPresents(), k)
        end
    end
end
-- recieved (opened) presents
function ply:AddReceivedPresent(present)
    self.receivedPresents = self.receivedPresents or {}
    table.insert(self.receivedPresents, present)
end
function ply:GetReceivedPresents()
    return self.receivedPresents or {}
end
function ply:SetReceivedPresents(presents)
    self.receivedPresents = presents
end
function ply:ClearReceivedPresents()
    self.receivedPresents = {}
end
function ply:HasReceivedPresent(present)
    return table.HasValue(self:GetReceivedPresents(), present)
end
function ply:RemoveReceivedPresent(present)
    for k, v in pairs(self:GetReceivedPresents()) do
        if v == present then
            table.remove(self:GetReceivedPresents(), k)
        end
    end
end
