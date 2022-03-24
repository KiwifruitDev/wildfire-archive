// ============================================================================================ //
/* 
 * Wildfire Servers - Script Days Addon - By KiwifruitDev
*  File description: Bounding Box Entity Server Side Script
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //

-- This entity is used to create special areas dedicated to scriptdays.
-- Admins can create these bounding boxes.
-- If a player enters the bounding box, they will be apart of the scriptday.
-- If they leave, they will no longer be marked as such.

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetTrigger(true)
    self:SetNotSolid(true)
    self:SetNoDraw(true)
    self:DrawShadow(false)
end

function ENT:Think()
    if self:GetBoundsPos1X() ~= 0 then
        self:SetCollisionBoundsWS(Vector(self:GetBoundsPos1X(), self:GetBoundsPos1Y(), self:GetBoundsPos1Z()), Vector(self:GetBoundsPos2X(), self:GetBoundsPos2Y(), self:GetBoundsPos2Z()))
        self:SetBoundsPos1X(0)
        self:SetBoundsPos1Y(0)
        self:SetBoundsPos1Z(0)
        self:SetBoundsPos2X(0)
        self:SetBoundsPos2Y(0)
        self:SetBoundsPos2Z(0)
    end
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then
        if self:GetStaff() and not ent:IsStaff() then
            ent:Kick("You entered a forbidden area restricted to staff members only")
            return
        end
        if not self:GetGeneric() then
            hook.Run("Location_PlayerEntered", ent, self)
            ent:SetNWString("location", self:GetLocation())
            ent:SetNWInt("locationpriority", self:GetPriority())
        else
            hook.Run("BoundingBox_PlayerEntered", ent, self)
        end
    elseif ent:GetModel() == "models/props_junk/tomabasarab_quaff.mdl" then
        if self:GetGeneric() then
            hook.Run("BoundingBox_HatEntered", ent, self)
        end
    end
end

function ENT:EndTouch(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then
        if not self:GetGeneric() then
            hook.Run("Location_PlayerLeft", ent, self)
            //ent:SetNWString("location", "...")
            ent:SetNWInt("locationpriority", -99)
        else
            hook.Run("BoundingBox_PlayerLeft", ent, self)
        end
    elseif ent:GetModel() == "models/props_junk/tomabasarab_quaff.mdl" then
        if self:GetGeneric() then
            hook.Run("BoundingBox_HatLeft", ent, self)
        end
    end
end
