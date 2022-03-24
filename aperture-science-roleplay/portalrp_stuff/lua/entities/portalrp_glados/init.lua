// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: GLaDoS serverside script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

//Light flash function
local function GLaDOS_LightStartup()
    timer.Simple(2, function()
        portalrp_gladosbootofflights()
    end)
    timer.Simple(2.3, function()
        portalrp_gladosbootuplights()
    end)
    timer.Simple(2.6, function()
        portalrp_gladosbootofflights()
    end)
    timer.Simple(2.9, function()
        portalrp_gladosbootuplights()
    end)
    timer.Simple(3.2, function()
        portalrp_gladosbootofflights()
    end)
    timer.Simple(3.5, function()
        portalrp_gladosbootuplights()
    end)
    timer.Simple(3.8, function()
        portalrp_gladosbootofflights()
    end)
    timer.Simple(4.1, function()
        portalrp_gladosbootuplights()
    end)
end

local discs = {
    //"spin_disk_1",
    "spin_disk_2",
    //"spin_disk_3",
    "spin_disk_4",
}

function ENT:Initialize()
    
    self:SetModel("models/npcs/glados/glados_animation.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self:SetUseType(SIMPLE_USE)

    self:SetAutomaticFrameAdvance(true)

    //power off state sequence
    self:ResetSequence(1)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:Activate()
    end 

end


function ENT:Use( ply )
    if GetGlobalBool("GladosActivated", false) == true then

        ply:ChatPrint("You cant do that again!")

    else
        ply:ChatPrint("power up initiated")
        SetGlobalBool("GladosActivated", true)

        for k,v in pairs(ents.FindByName("portalrp_global_shake")) do
            v:SetKeyValue("duration", "7")
            v:SetKeyValue("amplitude", "16")
            v:SetKeyValue("frequency", "512")
            v:Fire("StartShake")
        end

        self:EmitSound("wildfire/portalrp/glados_powerup.wav", 511, 100, 10)

        GLaDOS_LightStartup()

        timer.Simple(3, function()
            self:EmitSound("wildfire/portalrp/level_08_glados_firstspeak-1.wav", 511, 100, 10)
        end)

        timer.Simple(3.5, function()
            self:SetAnimationID(7)
        end)
        /*
        timer.Simple(4.8, function()
            for k,v in pairs(ents.FindByName("GlaDOS_slideshow")) do
                v:Fire("Enable")
            end
            for k,v in pairs(discs) do
                for k2,v2 in pairs(ents.FindByName(v)) do
                    v2:Fire("StartForward")
                end
            end
        end)
        */
    end
end