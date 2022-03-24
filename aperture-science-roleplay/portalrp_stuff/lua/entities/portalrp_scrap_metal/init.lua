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
    self:SetModel("models/props_junk/garbage128_composite001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion(false)
    end
end

local scavengingsounds = {
    "physics/metal/metal_solid_strain1.wav",
    "physics/metal/metal_solid_strain2.wav",
    "physics/metal/metal_solid_strain3.wav",
    "physics/metal/metal_solid_strain4.wav",
    "physics/metal/metal_solid_strain5.wav",
}

function ENT:Use(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if self:GetTimedOut() then return end
    if self:GetIsScavenging() then return end
    if not ply:GetNWBool("IsScavenging") then
        self:SetIsScavenging(true)
        ply:SetNWBool("IsScavenging", true)
        ply:SetNWString("ScavengingText", "Scavenging")
        ply:SetNWInt("ScavengeTime", CurTime())
        ply:SetNWInt("ScavengeTimeEnd", CurTime() + 10)
        self:EmitSound(table.Random(scavengingsounds), 100, 100)
        local steamid = ply:SteamID64()
        timer.Create("ScavengeTimer" .. steamid, 1, 0, function()
            self:EmitSound(table.Random(scavengingsounds), 100, 100)
            local playernearby = false
            for k,v in ipairs(ents.FindInSphere(self:GetPos(), 50)) do
                if v:IsPlayer() then
                    if v:SteamID64() == steamid then
                        playernearby = true
                        break
                    end
                end
            end
            if not playernearby then
                self:SetIsScavenging(false)
                if IsValid(ply) then
                    ply:SetNWBool("IsScavenging", false)
                end
                timer.Destroy("ScavengeTimer" .. steamid)
            end
        end)
        timer.Simple(10, function()
            if not self:GetIsScavenging() then return end
            if IsValid(ply) then
                ply:SetNWBool("IsScavenging", false)
            end
            self:SetIsScavenging(false)
            timer.Remove("ScavengeTimer" .. steamid)
            local scrap = ents.Create("portalrp_metal")
            scrap:SetPos(self:GetPos()+Vector(0,0,10))
            scrap:Spawn()
            scrap:Activate()
            self:SetTimedOut(true)
            self:PhysicsInit(SOLID_NONE)
            self:SetMoveType(MOVETYPE_NONE)
            self:SetSolid(SOLID_NONE)
            local phys = self:GetPhysicsObject()
            if phys:IsValid() then
                phys:EnableMotion(false)
            end
        end)
        timer.Simple(20, function()
            self:SetTimedOut(false)
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            local phys = self:GetPhysicsObject()
            if phys:IsValid() then
                phys:EnableMotion(false)
            end
        end)
    end
end