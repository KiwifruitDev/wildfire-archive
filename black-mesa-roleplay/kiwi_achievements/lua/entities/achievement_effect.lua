/*
    Wildfire Servers - Achievement System
    File Description: Achievement Particle Effect Entity
    Creation Date: 11/27/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
    All rights reserved.
*/

AddCSLuaFile()

game.AddParticles( "particles/wildfire_bmrp.pcf" )
PrecacheParticleSystem( "achievement_award" )

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Particle Effect"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
    self:DrawShadow(false)
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PlayerParent")
    self:NetworkVar("Int", 0, "RemoveTime")
    self:NetworkVar("Int", 1, "ResetTime")
    if SERVER then
        self:SetRemoveTime(CurTime() + 20)
        self:SetResetTime(CurTime() + 2)
    end
end

if SERVER then
    -- set position to player's position
    function ENT:Think()
        local parent = self:GetPlayerParent()
        if IsValid(parent) then
            local pos = parent:GetPos()
            self:SetPos(pos)
            if self:GetResetTime() < CurTime() then
                self:StopParticles()
            end
            //ParticleEffect("achievement_award", pos, Angle(0, 0, 0), self)
        end
        if self:GetRemoveTime() <= CurTime() then
            self:StopParticles()
            self:Remove()
        end
        self:NextThink(CurTime() + 0.1)
    end
end
