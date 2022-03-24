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

// Every file needs this :)
include("bmrp_crafting.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Scrap Metal"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CraftingMaterialType", { KeyName = "materialtype", Edit = { type = "Generic", category = "Material Type" } })
	//self:NetworkVar("Int", 1, "MaterialAmount")
    if SERVER then
		if CRAFTING then
			local randommat = table.Random(CRAFTING.ScrapTypes)
			self:SetCraftingMaterialType(randommat)
			self:SetModel(CRAFTING.ScrapModels[randommat])
			//self:SetMaterialAmount(math.random(1, 10))
		end
	end
end
