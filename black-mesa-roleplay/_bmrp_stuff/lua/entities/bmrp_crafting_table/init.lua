// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Event Power Box serverside script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Include crafting
include("bmrp_crafting.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/cs_italy/it_mkt_table3.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end


util.AddNetworkString("BMRP_CraftingGUI")
util.AddNetworkString("DarkRP_PocketMenu")
util.AddNetworkString("bms_craft")
util.AddNetworkString("bms_cancraft")
util.AddNetworkString("bms_canpresscraft")

function ENT:Use(activator)
    if not IsValid(activator) then return end
    //local jobtable = activator:getJobTable()
    //local subjobs = jobtable.subjobs
    //if not subjobs then subjobs = {} end
    net.Start("BMRP_CraftingGUI")
    local pocketitems = activator.darkRPPocket
    local pocketstring = ""
    local pocketMaterials = {}
    local newtable = {}
    if pocketitems then 
        for k, v in pairs(pocketitems) do
            if v.DT then
                if v.DT.CraftingMaterialType then
                    newtable[v.DT.CraftingMaterialType] = (newtable[v.DT.CraftingMaterialType] or 0) + 1
                elseif v.DT.CrystalType then
                    newtable[v.DT.CrystalType.." Crystal"] = (newtable[v.DT.CrystalType.." Crystal"] or 0) + 1
                    newtable["Crystal"] = (newtable["Crystal"] or 0) + 1
                    if not newtable.Resonance then
                        newtable.Resonance = {}
                    end
                    table.insert(newtable.Resonance, {
                        ["Crystal"] = v.DT.CrystalType,
                        ["Effect"] = v.DT.CrystalEffect,
                        ["Resonance"] = v.DT.CrystalResonance,
                        ["AMSPowerLevel"] = v.DT.CrystalAMSPowerLevel,
                        ["Scanned"] = v.DT.CrystalScanned,
                        ["AnalyzerScanned"] = v.DT.AnalyzerScanned,
                        ["Clean"] = v.DT.Clean,
                        ["AMSTested"] = v.DT.AMSTested,
                    })
                end
            end
        end
        for k, v in pairs(newtable) do
            if tonumber(v) then
                pocketstring = pocketstring..k.." x"..v.."\n"
            end
        end
    end
    net.WriteString(pocketstring or "")
    net.WriteEntity(self)
    net.Send(activator)
end


net.Receive("bms_craft", function(len, ply)
    local craftitem = net.ReadString()
    local craftingtable = net.ReadEntity()
    if not IsValid(craftingtable) then return end
    if craftingtable:GetClass() ~= "bmrp_crafting_table" then return end
    print("y tu?")
    print(CRAFTING.Craft(ply, craftitem, craftingtable))
end)

net.Receive("bms_cancraft", function(len, ply)
    local craftitem = net.ReadString()
    net.Start("bms_canpresscraft")
    local itemTable = ply.darkRPPocket // DarkRP's pocket items
    if not itemTable then itemTable = {} end
    local newtable = {}
    for k, v in pairs(itemTable) do
        if v.DT then
            if v.DT.CraftingMaterialType then
                newtable[v.DT.CraftingMaterialType] = (newtable[v.DT.CraftingMaterialType] or 0) + 1
            elseif v.DT.CrystalType then
                newtable[v.DT.CrystalType.." Crystal"] = (newtable[v.DT.CrystalType.." Crystal"] or 0) + 1
                newtable["Crystal"] = (newtable["Crystal"] or 0) + 1
                if not newtable.Resonance then
                    newtable.Resonance = {}
                end
                table.insert(newtable.Resonance, {
                    ["Crystal"] = v.DT.CrystalType,
                    ["Effect"] = v.DT.CrystalEffect,
                    ["Resonance"] = v.DT.CrystalResonance,
                    ["AMSPowerLevel"] = v.DT.CrystalAMSPowerLevel,
                    ["Scanned"] = v.DT.CrystalScanned,
                    ["AnalyzerScanned"] = v.DT.AnalyzerScanned,
                    ["Clean"] = v.DT.Clean,
                    ["AMSTested"] = v.DT.AMSTested,
                })
            end
        end
    end
    local str = CRAFTING.CanCraft(ply, newtable, craftitem, false)
    net.WriteBool(str == true)
    net.WriteString(str == true and "" or str)
    net.Send(ply)
end)