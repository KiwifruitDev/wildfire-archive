// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: GLaDoS shared script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Scrap Metal Pile"
ENT.Category = "Wildfire PortalRP"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsScavenging")
	self:NetworkVar("Bool", 1, "TimedOut")
    if SERVER then
		self:SetIsScavenging(false)
		self:SetTimedOut(false)
	end
end
