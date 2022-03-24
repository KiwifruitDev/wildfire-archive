// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Hook serverside script file
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

// Basic hooks //

hook.Add("SystemMessage", "HookSystemMessage", function(ply, prefix, msg)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if prefix == "" then prefix = "Aperture" end
    ply:ChatPrint("<icon 32,32>atlaschat/customemoticons/aperture.png</icon> <c=0,100,255>["..prefix.."] |</c> <c=0,126,255>"..msg.."</c>")
end)

hook.Add( "PlayerInitialSpawn", "PortalRPInit", function( ply )
	timer.Simple(5, function()
        ply:InitializePortalRPPlayer()
    end)
end)

hook.Add("PlayerSpawn", "PortalRP_PlayerSpawn", function(ply)
    local jbtbl = ply:getJobTable()
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        if not ply:Alive() then return end
        ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        if jbtbl.isCore then
            // Make player invisible
            ply:SetColor(Color(0, 0, 0, 0))
            ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
            ply:SetNoDraw(true)
            ply:SetNotSolid(true)
            ply:StripWeapons()
            ply:SetMoveType(MOVETYPE_NONE)
            ply:SetNoTarget(true)
            // RUN CONSOLE COMMAND TO PLAYER
            ply:ConCommand("simple_thirdperson_enabled 1")
        else
            ply:ConCommand("simple_thirdperson_enabled 0")
        end
    end)
    if jbtbl.isCore then
        local coreent = ents.Create("portalrp_core")
        coreent:SetPos(ply:EyePos())
        coreent:SetAngles(ply:EyeAngles())
        coreent:Spawn()
        coreent:Activate()
        coreent:SetPlayerOwner(ply)
        ply:SetNWEntity("PersonalityCore", coreent)
    end
end)

hook.Add("Think", "PortalRP_Think", function()
    for k, v in pairs(player.GetAll()) do
        if not IsValid(v) then continue end
        if not v:Alive() then continue end
        local jbtbl = v:getJobTable()
        if jbtbl.isCore == true then
            if not v:GetNWEntity("PersonalityCore") then
                v:changeTeam(1, true)
            elseif not v:Alive() then
                v:changeTeam(1, true)
            else
                local coreent = v:GetNWEntity("PersonalityCore")
                if not IsValid(coreent) then
                    v:changeTeam(1, true)
                end
                coreent:SetSkin(1)
                coreent:SetAnimationID(6)
                v:SetPos(coreent:GetPos())
                v:SetAngles(coreent:GetAngles())
            end
        end
    end
end)

// Other hooks // 

//First map initialization stuff (used for turning things off, removing things, adding core functionality, etc)
PORTALRP.AddToMapReset("PortalRP_MapInit", function()
    //remove dumb map death triggers
    for k,v in pairs(ents.FindByName("deathtrigger")) do
        v:Remove()
    end

    //These lights aren't on by default
    for k,v in pairs(ents.FindByName("glados_lights")) do
        v:Fire("TurnOn")
    end
    for k,v in pairs(ents.FindByName("gladoschamber_lights")) do
        v:Fire("TurnOff")
    end
    for k,v in pairs(ents.FindByName("glados_spotlights")) do
        v:Fire("LightOn")
    end
    for k,v in pairs(ents.FindByName("portalrp_light")) do
        v:Fire("TurnOn")
    end

    //create funny radios
    local vec = Vector( 136.14031982422, -21.269031524658, 612.32452392578)
    local ang = Angle(0, -43, 0)
    local radio = ents.Create("ent_portal_radio")
    radio:Spawn()
    radio:Activate()
    radio:SetPos(vec)
    radio:SetAngles(ang)

    //creating test chambers
    print("Creating test chamber locations...")
    for k,v in pairs(PORTALRP.TestChamberLocations) do
        local chamber = ents.Create("trigger_location")
        chamber:Spawn()
        chamber:Activate()
        chamber:SetCollisionBoundsWS(v[1], v[2])
        chamber:SetLocationName(k)
        chamber:SetName("TestChamber_" .. k:gsub("%s", ""))
        print("Created test chamber \"" .. k .. "\" between " .. v[1].x .. ", " .. v[1].y .. ", " .. v[1].z .. " and " .. v[2].x .. ", " .. v[2].y .. ", " .. v[2].z)
    end
    print("Creating commutation entities...")
    for k,v in pairs(PORTALRP.CommutationPositions) do
        local chamber = ents.Create("trigger_commutation")
        chamber:Spawn()
        chamber:Activate()
        chamber:SetCollisionBoundsWS(v[1], v[2])
        chamber:SetDestinationPos(v[3])
        chamber:SetDestinationAngles(v[4])
        chamber:SetName("Commutation_" .. k:gsub("%s", ""))
        print("Created commutation entity \"" .. k .. "\" between " .. v[1].x .. ", " .. v[1].y .. ", " .. v[1].z .. " and " .. v[2].x .. ", " .. v[2].y .. ", " .. v[2].z)
    end

    //adding glados (this will be changed and removed later)
    print("Attempting to spawn GLaDos")

    //escape_02 coordinates
    local coords = Vector( 4360, -670, 1746 )
    for k,v in pairs(ents.FindByName("temp_glados")) do
        coords = v:GetPos()
        v:Remove()
        break
    end
    local glados = ents.Create("portalrp_glados")
    glados:SetPos(coords)
    glados:SetAngles(Angle(0, 0, 0))
    glados:Spawn()
    glados:Activate()
    SetGlobalBool("GladosActivated", false)
end)
