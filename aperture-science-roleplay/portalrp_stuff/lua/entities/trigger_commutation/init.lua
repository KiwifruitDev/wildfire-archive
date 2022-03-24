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
    if not ent:IsPlayer() then
		if ent:GetClass() == "portalrp_core" then
			timer.Simple(1, function()
				if IsValid(ent) then
					ent:SetPos(self:GetDestinationPos())
					ent:SetAngles(self:GetDestinationAngles())
				end
			end)
		end
		return
	end
	if ent:GetMoveType() ~= MOVETYPE_WALK then return end
    if not ent:Alive() then return end
	ent:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, 0)
	timer.Simple(1, function()
		if IsValid(ent) then
			ent:SetPos(self:GetDestinationPos())
			ent:SetEyeAngles(self:GetDestinationAngles())
			ent:ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 1, 0)
		end
	end)
end
