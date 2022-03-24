// ============================================================================================ //
/* 
 * Wildfire Servers - Script Days Addon - By KiwifruitDev
*  File description: Bounding Box Entity Shared Script
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Bounding Box"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Wildfire BMRP"

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Location")
    self:NetworkVar("Bool", 1, "Generic")
    self:NetworkVar("Bool", 2, "Staff")
    self:NetworkVar("Int", 3, "Priority")
    self:NetworkVar("Int", 4, "BoundsPos1X")
    self:NetworkVar("Int", 5, "BoundsPos1Y")
    self:NetworkVar("Int", 6, "BoundsPos1Z")
    self:NetworkVar("Int", 7, "BoundsPos2X")
    self:NetworkVar("Int", 8, "BoundsPos2Y")
    self:NetworkVar("Int", 9, "BoundsPos2Z")
    if SERVER then
        self:SetLocation("")
        self:SetGeneric(true)
        self:SetStaff(false)
        self:SetPriority(0)
        self:SetBoundsPos1X(0)
        self:SetBoundsPos1Y(0)
        self:SetBoundsPos1Z(0)
        self:SetBoundsPos2X(0)
        self:SetBoundsPos2Y(0)
        self:SetBoundsPos2Z(0)
    end
end