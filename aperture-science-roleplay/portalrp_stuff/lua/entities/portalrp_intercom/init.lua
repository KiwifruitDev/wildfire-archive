// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Event Power Box serverside script file
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

function ENT:Initialize()
    self:SetModel("models/props_underground/intercom_panel.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion(false)
    end
end

function ENT:Use(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if self:GetIsScavenging() then return end
    if not ply:GetNWBool("IsScavenging") then
        self:SetIsScavenging(true)
        ply:SetNWBool("IsScavenging", true)
        ply:SetNWString("ScavengingText", "Announcing")
        ply:SetNWInt("ScavengeTime", CurTime())
        ply:SetNWInt("ScavengeTimeEnd", CurTime())
        timer.Create("IntercomTimer", 1, 0, function()
            self:EmitSound(table.Random(scavengingsounds), 100, 100)
            local playernearby = false
            for k,v in ipairs(ents.FindInSphere(self:GetPos(), 50)) do
                if v:IsPlayer() then
                    playernearby = true
                    break
                end
            end
            if not playernearby then
                self:SetIsScavenging(false)
                if IsValid(ply) then
                    ply:SetNWBool("IsScavenging", false)
                end
                timer.Destroy("IntercomTimer")
            end
        end)
    else
        self:SetIsScavenging(false)
        ply:SetNWBool("IsScavenging", false)
        timer.Destroy("IntercomTimer")
    end
end