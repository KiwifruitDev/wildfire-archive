// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Shared functionality script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Global variable to store everything from here.
PORTALRP = {}

PORTALRP.DEBUG = true // Set to true or false for debug commands

// GROUPS //
PORTALRP.PLAYERS = {}

PORTALRP.PLAYERS.DEVELOPERS = { // Set these to the owners/developers SteamIDs.
    "STEAM_0:1:41323547", // Kiwifruit
    "STEAM_0:0:78540453", // Treycen
    "STEAM_0:1:75090064", // Flynn
    "STEAM_0:0:427407443", // Mr. Ragtime
}
PORTALRP.GROUPS = {}
PORTALRP.GROUPS.STAFF = { //Set these to your staff groups found in ULX.
    "owner",
    "coowner",
    "superadmin",
    "admin",
    "moderator",
    "trialmoderator",
}
PORTALRP.GROUPS.VIP = { // Set these to your VIP groups found in ULX. If you don't have VIP, don't worry about it.
    "vip",
}
PORTALRP.GROUPS.PLAYER = { // Set these to your user groups. In this scenario, a user is still classed as "pacaccess" so they're technically a user.
    "pacaccess",
    "user",
}

PORTALRP.TestChamberLocations = {
    ["Chamber 01"] = {Vector(-258.15936279297, -64.03125, 383.72012329102),Vector(-1877.005371, -1493.659912, 14.332928)},
}

PORTALRP.CommutationPositions = {
    ["Topside Elevator 1"] = {
        Vector(-2653.6608886719, 1281.9664306641, -1823.96875), -- Min Corner
        Vector(-2504.4523925781, 1144.3924560547, -1216.03125), -- Max Corner
        Vector(743.111145, -499.175751, 576.03125), -- Player Position
        Angle(0, 0, 0) -- Player Angles
    },
    ["Topside Elevator 2"] = {
        Vector(-2653.7258300781, 1556.3803710938, -1823.96875), -- Min Corner
        Vector(-2504.5197753906, 1414.2574462891, -1216.03125), -- Max Corner
        Vector(743.111145, -763.499451, 576.03125), -- Player Position
        Angle(0, 0, 0) -- Player Angles
    },
    ["Facility Elevator 1"] = {
        Vector(531.20349121094, -564.83081054688, 767.96875), -- Min Corner
        Vector(672.14697265625, -424.80261230469, 576.03125), -- Max Corner
        Vector(-2701.320313, 1209.094849, -1823.96875), -- Player Position
        Angle(0, 180, 0) -- Player Angles
    },
    ["Facility Elevator 2"] = {
        Vector(671.53948974609, -838.560546875, 767.96875), -- Min Corner
        Vector(531.66845703125, -699.77124023438, 576.03125), -- Max Corner
        Vector(-2701.320313, 1479.356323, -1823.96875), -- Player Position
        Angle(0, 180, 0) -- Player Angles
    },
    ["Lower Elevator"] = {
        Vector(1291.1197509766, -1752.9371337891, 699.56072998047), -- Min Corner
        Vector(1173.6251220703, -1642.0338134766, 823.45361328125),
        Vector(1170.620117, -1293.886108, 1256.03125), -- Player Position
        Angle(0, 0, 0) -- Player Angles
    },
    ["Upper Elevator"] = {
        Vector(1067.00390625, -1355.6232910156, 1275.5606689453), -- Min Corner
        Vector(946.02984619141, -1244.1096191406, 1397.8962402344), -- Max Corner
        Vector(1381.709961, -1697.758057, 680.03125), -- Player Position
        Angle(0, 0, 0) -- Player Angles
    },
    ["Test Chamber Exit"] = {
        Vector(-471.83712768555, 1103.3642578125, 657.03125), -- Min Corner
        Vector(-503.33459472656, 976.22918701172, 783.96875), -- Max Corner
        Vector(-831.43646240234, 398.59069824219, 576.03125),
        Angle(0, -90, 0) -- Player Angles
    },
    ["End of Testing Track"] = {
        Vector(-888.55639648438, 502.8564453125, 595.56072998047), -- Min Corner
        Vector(-780.75775146484, 623.0927734375, 720.00958251953), -- Max Corner
        Vector(-373.98348999023, 1040.1805419922, 657.03125),
        Angle(0, 0, 0) -- Player Angles
    },
}

PORTALRP.OrderedPortalGunColors = {
    [1] = Color(0, 0, 255), // Blue
    [2] = Color(255, 128, 0), // Orange
    [3] = Color(128,255,192), // Mint Green
    [4] = Color(255, 0, 255), // Magenta
    [5] = Color(255, 0, 0), // Red
    [6] = Color(128, 0, 255), // Purple
    [7] = Color(255, 128, 255), // Pink
    [8] = Color(139, 69, 19), // Brown
    [9] = Color(255, 255, 255), // White
    [10] = Color(0, 0, 0), // Black
    [11] = Color(0, 0, 128), // Navy Blue
    [12] = Color(255, 215, 0), // Gold
    [13] = Color(210, 180, 140), // Tan
    [14] = Color(128, 128, 128), // Grey
    [15] = Color(250, 128, 114), // Salmon
    [16] = Color(64, 224, 208), // Turquoise
    [17] = Color(255, 165, 0), // Amber
    [18] = Color(183, 228, 108), // Kiwi
    [19] = Color(127, 255, 212), // Aquamarine
    [20] = Color(109, 39, 109), // Plum
    [21] = Color(255, 255, 255), // White
    [22] = Color(255, 255, 255), // White
    [23] = Color(255, 255, 255), // White
    [24] = Color(255, 255, 255), // White
    [25] = Color(255, 255, 255), // White
    [26] = Color(255, 255, 255), // White
    [27] = Color(255, 255, 255), // White
    [28] = Color(255, 255, 255), // White
    [29] = Color(255, 255, 255), // White
    [30] = Color(255, 255, 255), // White
    [31] = Color(255, 255, 255), // White
    [32] = Color(255, 255, 255), // White
}

PORTALRP.GenericErrorMessage = "An error has occurred. Please contact an administrator."

// ================ //
// Server Functions //
// ================ //
if SERVER then
    print("----------- PortalRP Serverside Intializing... -----------")

    // ============ //
    //  PLAYER META //
    // ============ //
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
        
    //This wil be used instead of InitPostEntity or PostCleanupMap, combines two hooks into one.
    function PORTALRP.AddToMapReset(name, func)
        hook.Add("InitPostEntity", name, func)
        hook.Add("PostCleanupMap", name, func) 
    end

    //Rounding Vectors is very important
    if not vec.Round or PORTALRP.DEBUG then
        function vec:Round(dec)
            vec = self
            if not dec then dec = 0 end
            return Vector(math.Round(vec.x,dec),math.Round(vec.y,dec),math.Round(vec.z,dec))
        end
    end

    function PORTALRP.WipeDoorData()
        for k,ent in pairs(ents.GetAll()) do
            if IsValid(ent) then
                if IsValid(ent:getDoorOwner()) then
                    ent:keysUnOwn(ent:getDoorOwner())
                end
                ent:setKeysNonOwnable(true)
                ent:removeAllKeysExtraOwners()
                ent:removeAllKeysAllowedToOwn()
                ent:removeAllKeysDoorTeams()
                ent:setDoorGroup(nil)
                ent:setKeysTitle(nil)

                //Storing it for later map loads
                DarkRP.storeDoorData(ent)
                DarkRP.storeDoorGroup(ent, nil)
                DarkRP.storeTeamDoorOwnability(ent)
            end
        end
    end

    //Getting the entity info
    if not ply.GetEntityInfo or PORTALRP.DEBUG then
        function ply:GetEntityInfo()
            local ply = self
            local eyetrace = ply:GetEyeTrace()
            if IsValid(ply) then
                if eyetrace ~= nil then
                    if eyetrace.Entity ~= nil then
                        ply:ChatPrint("Name: "..eyetrace.Entity:GetName())
                        local owner = eyetrace.Entity:GetOwner()
                        if IsValid(owner) then
                            if owner:IsPlayer() then
                                local owner_name = owner:Nick()
                                ply:ChatPrint("Owner: "..owner_name)
                            end
                        end
                        ply:ChatPrint("Classname: "..eyetrace.Entity:GetClass())
                        ply:ChatPrint("Model: "..eyetrace.Entity:GetModel())
                        ply:ChatPrint("Map Creation ID: "..eyetrace.Entity:MapCreationID())
                        local pos = eyetrace.Entity:GetPos()
                        ply:ChatPrint("Position: "..pos.x..", "..pos.y..", "..pos.z)
                        local ang = eyetrace.Entity:GetAngles()
                        ply:ChatPrint("Angle: "..ang.p..", "..ang.y..", "..ang.r)
                        local hit = eyetrace.HitPos
                        ply:ChatPrint("Hit Position: "..hit.x..", "..hit.y..", "..hit.z)
                        local normal = eyetrace.HitNormal
                        ply:ChatPrint("Normal: "..normal.x..", "..normal.y..", "..normal.z)
                    end
                end
            end
        end
    end

    //Wanna notify the player of something?
    if not ply.Notify or PORTALRP.DEBUG then
        function ply:Notify(text, typeint, time)
            local ply = self
            DarkRP.notify(ply, typeint or 5, time or 5, text)
        end
    end

    //Check if the player is between point A and B -- usage: "If PORTALRP.CheckInRange(0, 0, ply:GetPos()) then"
    function PORTALRP.CheckInRange(vec1,vec2,vecent)
        if vecent:WithinAABox(vec1,vec2) then
            return true
        else
            return false
        end
        
    end

    //Reset the players sound
    if not ply.ResetSound or PORTALRP.DEBUG then
        function ply:ResetPlayerSound()
            local ply = self
            ply:SendLua("RunConsoleCommand(\"stopsound\")")
            timer.Simple(0.5, function()
                ply:SendLua("RunConsoleCommand(\"snd_restart\");print(\"[PortalRP] Your sound has been reset! You should be able to hear more things now!\")")
            end)
        end
    end

    if not ply.IsInTestChamber or PORTALRP.DEBUG then
        function ply:IsInTestChamber()
            local ply = self
            local chamber = ply:GetNWString("Location")
            if string.find(chamber, "Chamber") then
                return true
            else
                return false
            end
        end
    end

    if not ply.InitializePortalRPPlayer or PORTALRP.DEBUG then
        function ply:InitializePortalRPPlayer()
            local ply = self
            ply:SendLua("RunConsoleCommand(\"portal_dynamic_light\", \"1\");RunConsoleCommand(\"portal_arm\", \"1\");RunConsoleCommand(\"portal_borders\", \"1\");RunConsoleCommand(\"portal_crosshair\", \"1\")")
            ply:ResetPlayerSound()
        end
    end


end

// ================ //
// Client Functions //
// ================ //
if CLIENT then

    print("----------- PortalRP Cientside Intializing... -----------")

    function PORTALRP.ChangeSkybox()
        local skybox = PORTALRP.SKYBOX
        if skybox == nil then
            return
        end
        local skybox_name = skybox.name
        local skybox_texture = skybox.texture
        local skybox_material = skybox.material
        if skybox_name == nil or skybox_texture == nil or skybox_material == nil then
            return
        end
        render.SetSkyBox(skybox_name, skybox_texture, skybox_material)
    end


end

// ================ //
// Shared Functions //
// ================ //
//Checks if the player is a staff member:
function ply:IsStaff()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(PORTALRP.GROUPS.STAFF) do
        if ply:IsUserGroup(v) then
            return true
        end
    end
    return false
end

//Checks if the player is a VIP:
function ply:IsVIP()
    local ply = self
    // Loop through staff table and check if the staff groups contains the player's group.
    for k, v in pairs(PORTALRP.GROUPS.VIP) do
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
    for k, v in pairs(PORTALRP.PLAYERS.DEVELOPERS) do
        if ply:SteamID() == v then
            return true
        end
    end
    return false
end


