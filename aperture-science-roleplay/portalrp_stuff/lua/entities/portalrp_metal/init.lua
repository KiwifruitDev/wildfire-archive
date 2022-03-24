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

// Every file needs this :)
include("portalrp/portalrp_shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(table.Random(CRAFTING.ScrapModels))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if self:GetIsScavenging() then return end
    if not ply:GetNWBool("IsScavenging") then
        self:SetIsScavenging(true)
        ply:SetNWBool("IsScavenging", true)
        ply:SetNWInt("ScavengeTime", CurTime())
        ply:SetNWInt("ScavengeTimeEnd", CurTime() + 10)
        self:EmitSound(table.Random(scavengingsounds), 100, 100)
        local steamid = ply:SteamID64()
        timer.Create("ScavengeTimer" .. steamid, 1, 0, function()
            if not self:GetIsScavenging() then return end
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
            if IsValid(ply) then
                ply:SetNWBool("IsScavenging", false)
            end
            self:SetIsScavenging(false)
            timer.Remove("ScavengeTimer" .. steamid)
        end)
    end
end