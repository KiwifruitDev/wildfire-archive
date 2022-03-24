// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Serverside commands script file
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

// Developer commands
if PORTALRP.DEBUG == true then
    
    concommand.Add("entinfo", function( ply, cmd, args )
        if ply:IsStaff() then
            ply:GetEntityInfo()
        end
    end)

    concommand.Add("resetdoors", function( ply, cmd, args )
        if ply:IsDeveloper() then
            PORTALRP.WipeDoorData()
            ply:Notify("Doors have been wiped!")
        end
    end)

    concommand.Add( "pos1", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        local ent = ply:GetNWEntity("bounds")
        if !IsValid( ent ) then return end
        local handle = ent.handle_min
        handle:SetPos(ply:EyePos())
    end)

    concommand.Add( "pos2", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        local ent = ply:GetNWEntity("bounds")
        if !IsValid( ent ) then return end
        local handle = ent.handle_max
        handle:SetPos(ply:EyePos())
    end)

    concommand.Add("goto", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        local pos = Vector(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0)
        ply:SetPos(pos)
    end)

    concommand.Add("becomecore", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        //if !ply:IsDeveloper() then return end
        ply:SetNWBool("CanBecomeCore", true)
        timer.Simple(0.1, function()
            ply:ChatPrint(ply:changeTeam(4, true) and "Became a Core!" or "Failed to become a Core!")
        end)
        timer.Simple(0.5, function()
            ply:SetNWBool("CanBecomeCore", false)
        end)
    end)

    concommand.Add( "commute", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        local bounds = ply:GetNWEntity("bounds")
        if !IsValid( bounds ) then return end
        local handle_min = bounds.handle_min:GetPos()
        local handle_max = bounds.handle_max:GetPos()
        local plypos = ply:GetPos()
        local plyang = ply:GetAngles()
        for k,v in ipairs(ents.FindByName("temp_commute")) do
            v:Remove()
        end
        local ent = ents.Create("trigger_commutation")
        ent:SetPos(handle_min + (handle_max - handle_min) / 2)
        ent:Spawn()
        ent:Activate()
        ent:SetCollisionBoundsWS(handle_min, handle_max)
        ent:SetDestinationPos(plypos)
        ent:SetDestinationAngles(plyang)
        ent:SetName("temp_commute")
    end)

    concommand.Add("sciencecollaborationpoints", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        local addorremove = args[1] == "add" and true or args[1] == "remove" and false
        if addorremove == nil then return end
        local playerecieving = args[2]
        if playerecieving == nil then return end
        for k,v in ipairs(player.GetAll()) do
            if v:Nick() == playerecieving then
                if addorremove then
                    v:SetNWInt("ScienceCollaborationPoints", v:GetNWInt("ScienceCollaborationPoints") + 1)
                else
                    v:SetNWInt("ScienceCollaborationPoints", v:GetNWInt("ScienceCollaborationPoints") - 1)
                end
                break
            end
        end
    end)

    concommand.Add("enablerocketturrets", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        for k,v in ipairs(ents.FindByClass("npc_portal_rocket_turret")) do
            v:SetEnable(true)
        end
    end)

    concommand.Add("disablerocketturrets", function( ply, cmd, args )
        if !IsValid( ply ) then return end
        if !ply:IsPlayer() then return end
        if !ply:Alive() then return end
        if !ply:IsDeveloper() then return end
        for k,v in ipairs(ents.FindByClass("npc_portal_rocket_turret")) do
            v:SetEnable(false)
        end
    end)
end

//Player commands
concommand.Add("portalrp_resetsound", function( ply, cmd, args )
    ply:ResetPlayerSound()
end)


