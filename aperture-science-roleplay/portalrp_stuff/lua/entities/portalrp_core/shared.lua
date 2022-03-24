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

ENT.PrintName = "Personality Core"
ENT.Category = "Wildfire PortalRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
  self:NetworkVar("Int", 0, "AnimationID")
  self:NetworkVar("Entity", 1, "PlayerOwner")
  if SERVER then
    self:SetAnimationID(self:LookupSequence("core03_idle"))
  end
end

function ENT:Think()
  local anim = self:GetAnimationID()
  if anim <= 1 then return end
  if self:GetSequence() ~= anim or self:IsSequenceFinished() then
    self:ResetSequence(anim)
  end
  if SERVER then
    local owner = self:GetPlayerOwner()
    if not IsValid(owner) then
      self:Remove()
      return
    elseif not owner:Alive() then
      self:Remove()
      return
    elseif owner:GetNWEntity("PersonalityCore") ~= self then
      self:Remove()
      return
    end
    self:NextThink( CurTime() )
    return true
  end
end