// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Location trigger shared script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

ENT.Type = "brush"
ENT.BaseClass = "base_brush"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "LocationName")
    if SERVER then
		self:SetLocationName("Unknown")
	end
end
