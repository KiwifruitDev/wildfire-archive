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

include("bmrp_crafting.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Crafting Table"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CraftItem", { KeyName = "craftitem", Edit = { type = "Generic", category = "Crafting" } })
    if SERVER then
		self:SetCraftItem(CRAFTING.DefaultItem or "")
	end
end
