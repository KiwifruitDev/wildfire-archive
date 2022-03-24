// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Clearance Addon
*  File description: Serverside clearance script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

local clearance = {
    { // level 1
        0,
    },
    { // level 2
        0,
    },
    { // level 3
        0,
    },
    { // level 4
        0,
    },
    { // level 5
        0,
    }
}

hook.Add("PlayerUse", "PortalRP_ButtonClearance", function(ply, ent)
    local jobtable = {} //ply:getJobTable()
    local clearancenum = 0
    if jobtable.clearance then clearancenum = jobtable.clearance end
    for k,v in pairs(clearance) do
        for k2,v2 in pairs(v) do
            if ent:MapCreationID() == v2 then
                if ply.debounce == true then return false end
                // debounce so you don't +use 1000x times in a row
                ply.debounce = true
                timer.Simple(0.5, function()
                    ply.debounce = false
                end)
                if clearancenum >= k then
                    // access granted
                    ply:SendLua("surface.PlaySound(\"common/wpn_select.wav\")")

                    hook.Run("SystemMessage", ply, "", "Level "..k.." clearance, access granted.")

                    return true
                end
                /// access denied
                ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")

                hook.Run("SystemMessage", ply, "", "Level "..k.." clearance is required, access denied.")

                return false
            end
        end
    end
end)

hook.Add( "PlayerSay", "ShowID", function( ply, text )
    local jobtable = ply:getJobTable()
    if string.StartWith(string.lower( text ), "/showid") then
        if not jobtable.clearance then jobtable.clearance = 0 end
        local str = "shows their identification. It reads: "..ply:Nick()..", Affiliation: "..ply:getDarkRPVar("job")..", Clearance Level: "..jobtable.clearance, GAMEMODE.Config.meDistance
        DarkRP.talkToRange(ply, ply:Nick().." "..str, "", GAMEMODE.Config.talkDistance)
        return ""
    end
end)
