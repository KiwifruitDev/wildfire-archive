// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Location trigger serverside script file
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
	self:SetSolid(SOLID_BBOX)
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    if ent == self then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    local location = self:GetLocationName()
    if ent:GetNWString("Location","") == location then return end
    ent:SetNWString("Location",location)
end

function ENT:EndTouch(ent)
    if not IsValid(ent) then return end
    if ent == self then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    local location =  self:GetLocationName()
    if ent:GetNWString("Location","") ~= location then return end
    ent:SetNWString("Location","Unknown")
end
