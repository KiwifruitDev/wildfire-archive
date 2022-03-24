// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Events Addon
*  File description: Serverside events initialization script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Every file needs this :)
include("portalrp/portalrp_shared.lua")
AddCSLuaFile("portalrp/portalrp_shared.lua")

// Power Outage Event //

//Light names that turn on after a power outage:
local blackoutlights = {
    "glados_lights",
    "portalrp_light",
}

local blackoutemergencylights = {
    "glados_emergencylight",
    "portalrp_emergencylight",
}

function poweroutage() // Lights go off D:
    SetGlobalBool("BlackoutEvent", true)

    for k,v in pairs( player.GetAll() ) do
        if GetGlobalBool("GladosActivated", false) == true then
            hook.Run("SystemMessage", v, "", "Aperture Research Facility total power outage. GLaDOS mainframe failure. Restart the auxiliary generators immediately.")
        else
            hook.Run("SystemMessage", v, "", "Aperture Research Facility total power outage. Restart the auxiliary generators.")
        end
        v:SendLua("surface.PlaySound(\"wildfire/poweroutage.wav\")")
    end

    portalrp_lightsoff()


end

function endpoweroutage() // Lights come back on
    SetGlobalBool("BlackoutEvent", false)

    for k,v in pairs( player.GetAll() ) do
        hook.Run("SystemMessage", v, "", "Facility auxiliary generators engaged, power restored. Please return to normal duties.")
        v:SendLua("surface.PlaySound(\"ambient/machines/spinup.wav\")")
    end

    portalrp_lightson()

end

function portalrp_lightsoff()
    for k,v in pairs(blackoutlights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOff")
        end
    end
    for k,v in pairs(blackoutemergencylights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOn")
        end
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOff")
    end
    for k,v in pairs(ents.FindByName("portalrp_spotlight")) do
        v:Fire("LightOff")
    end
    for k,v in pairs(ents.FindByName("portalrp_lightglow")) do
        v:Fire("Color 0 0 0")
    end
end

function portalrp_lightson()
    for k,v in pairs(blackoutlights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOn")
        end
    end
    for k,v in pairs(blackoutemergencylights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOff")
        end
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOn")
    end
    for k,v in pairs(ents.FindByName("portalrp_spotlight")) do
        v:Fire("LightOn")
    end
    for k,v in pairs(ents.FindByName("portalrp_lightglow")) do
        v:Fire("Color 255 255 255")
    end
end

function portalrp_gladosbootuplights()
    for k,v in pairs(blackoutlights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOn")
        end
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOn")
    end
    for k,v in pairs(ents.FindByName("portalrp_spotlight")) do
        v:Fire("LightOn")
    end
    for k,v in pairs(ents.FindByName("portalrp_lightglow")) do
        v:Fire("Color 255 255 255")
    end
end

function portalrp_gladosbootofflights()
    for k,v in pairs(blackoutlights) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Fire("TurnOff")
        end
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOff")
    end
    for k,v in pairs(ents.FindByName("portalrp_spotlight")) do
        v:Fire("LightOff")
    end
    for k,v in pairs(ents.FindByName("portalrp_lightglow")) do
        v:Fire("Color 0 0 0")
    end
end


concommand.Add("portalrp_poweroutage", function(ply, args)
    if ply:IsSuperAdmin() then 
        poweroutage()
    end  
end)

concommand.Add("portalrp_endpoweroutage", function(ply, args)
    if ply:IsSuperAdmin() then 
        endpoweroutage()
    end  
end)

//glados lights are dumb
concommand.Add("gladosbitchon", function(ply)
    for k,v in pairs(ents.FindByName("glados_lights")) do
        v:Fire("TurnOn")
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOn")
    end
end)

concommand.Add("gladosbitchoff", function(ply)
    for k,v in pairs(ents.FindByName("glados_lights")) do
        v:Fire("TurnOff")
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOff")
    end
end)

concommand.Add("testertester123", function(ply)
    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "Aperture Research Facility total power outage. Restart the auxiliary generators.")
    end
end)