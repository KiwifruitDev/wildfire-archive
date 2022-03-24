// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Base Addon
*  File description: Crafting system shared code
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// ======== //
// CRAFTING //
// ======== //
CRAFTING = {}
CRAFTING.Classes = {
    "portalrp_metal",
    "portalrp_singularity_container",
}
CRAFTING.ScrapModels = {
	"models/Gibs/helicopter_brokenpiece_01.mdl",
	"models/Gibs/helicopter_brokenpiece_02.mdl",
	"models/Gibs/helicopter_brokenpiece_03.mdl",
}
CRAFTING.ScrapTypes = {
	"Metal", // Just a generic metal scrap
	"Silicon", // Silicon like electronic components
	"Plastic", // Plastic would be like a milk carton or something
	"Rubber", // Rubber, tires?
	"Wood", // Planks, logs, etc
	"Glass", // Whatever glass is
}
CRAFTING.AllTypes = {
    "Singularity", // A contained xen portal, used for teleportation (portal guns)
}

// Merge ScrapTypes and AllTypes
for k, v in ipairs(CRAFTING.ScrapTypes) do
    table.insert(CRAFTING.AllTypes, v)
end

CRAFTING.CraftItems = {
	["Personality Core"] = {
        class = "portalrp_core",
        craftClass = true,
        model = "models/npcs/personality_sphere/personality_sphere_skins.mdl",
        craftingMaterials = {
            ["Silicon"] = 2,
            ["Plastic"] = 1,
            ["Metal"] = 5,
        },
        reward = function(ply)
            ply:addMoney(1000)
        end,
    },
    ["Portal Gun"] = {
        class = "weapon_portalgun",
        craftClass = true,
        model = "models/weapons/portalgun/w_portalgun_hl2.mdl",
        craftingMaterials = {
            ["Silicon"] = 3,
            ["Plastic"] = 2,
            ["Metal"] = 5,
            ["Singularity"] = 1,
        },
        reward = function(ply)
            ply:addMoney(5000)
        end,
    },
    ["Dummy"] = {
        class = "event_power_box",
        craftClass = false,
        model = "models/props_lab/powerbox01a.mdl",
        craftingMaterials = {
            ["Silicon"] = 1,
        },
        resonance = 50,
        condition = function(ply, pocketItems)
            local syr = ply:GetWeapon("bmrp_syringe")
            if not IsValid(syr) then return false end
            if syr:GetBloodType() == "Human" then return true end
            return false
        end,
        conditionError = "You need to have a human blood syringe to craft this.",
        reward = function(ply)
            ply:addMoney(1000)
        end,
    }
}

CRAFTING.ConditionEnum = {
    // [INDEX] = errorMessage
    //[1] = "You can craft this item by consuming the required pocket materials.",
    [1] = "Your pocket does not have the required materials to craft this item.",
    [2] = "Your pocket does not have enough materials to craft this item.",
    [3] = "An unknown error has occurred.",
}

// ================= //
//  SHARED FUNCTIONS //
// ================= //
function CRAFTING.IsValid(item)
    for k,v in ipairs(CRAFTING.Classes) do
        if item.Class == v then
            return true
        end
    end
    return false
end
function CRAFTING.CanCraft(ply, itemTable, craftItem, returnBoolean)
    local item = CRAFTING.CraftItems[craftItem]
    if not item then
        if returnBoolean then return false end
        return CRAFTING.ConditionEnum[3] // Unknown error
    end
    if not itemTable then
        if returnBoolean then return false end
        return CRAFTING.ConditionEnum[3]
    end
    if item.condition then -- CONDITIONAL CRAFTING --
        if not item.condition(ply, itemTable) then
            if returnBoolean then return false end
            return item.conditionError or CRAFTING.ConditionEnum[3]
        end
    end
    local materialTotals = {}
    for k, material in ipairs(itemTable) do
        if not CRAFTING.IsValid(material) then continue end
        if not material.DT then continue end
        if not material.DT.MaterialType then continue end
        -- CRYSTAL RESONANCE --
        // Only add crystals if their resonance is greater than or equal to the item's resonance
        if item.resonance and material.DT.CrystalResonance then
            if material.DT.CrystalResonance < item.resonance then
                continue
            end
        end
        local craftType = material.DT.MaterialType
        //local craftAmount = material:GetMaterialAmount()
        if not item.craftingMaterials[craftType] then continue end
        if item.craftingMaterials[craftType] == 0 then continue end
        if not materialTotals[craftType] then materialTotals[craftType] = 0 end
        materialTotals[craftType] = materialTotals[craftType] + 1 //+ craftAmount
    end
    if table.Count(materialTotals) > 0 then
        for k, amount in ipairs(item.craftingMaterials) do
            if not materialTotals[k] then
                if returnBoolean then return false end
                return CRAFTING.ConditionEnum[1] // Pocket does not have the required materials
            end
            if materialTotals[k] < amount then
                if returnBoolean then return false end
                return CRAFTING.ConditionEnum[2] // Pocket does not have enough materials
            end
        end
        return true
    end
    if returnBoolean then return false end
    return CRAFTING.ConditionEnum[1] // Pocket does not have the required materials
end

// ================ //
// SERVER FUNCTIONS //
// ================ //
if SERVER then
    function CRAFTING.Craft(ply, craftItem, craftingTable)
        if not IsValid(ply) then return false end
        if not IsValid(craftingTable) then return false end
        if not craftingTable:GetClass() == "portalrp_crafting_table" then return false end
        local itemTable = ply.darkRPPocket // DarkRP's pocket items
        //PrintTable(itemTable)
        local canCraft = CRAFTING.CanCraft(ply, itemTable, craftItem, false)
        if canCraft == true then
            local item = CRAFTING.CraftItems[craftItem]
            if not item then return false end
            for k, material in ipairs(itemTable) do
                if not CRAFTING.IsValid(material) then continue end
                if not material.DT then continue end
                if not material.DT.MaterialType then continue end
                -- CRYSTAL RESONANCE --
                // Only add crystals if their resonance is greater than or equal to the item's resonance
                if item.resonance and material.DT.CrystalResonance then
                    if material.DT.CrystalResonance < item.resonance then
                        continue
                    end
                end
                local craftType = material.DT.MaterialType
                if not item.craftingMaterials[craftType] then continue end
                if item.craftingMaterials[craftType] <= 0 then continue end
                ply.darkRPPocket[k] = nil
            end
            if item.craftClass then
                local newItem = ents.Create(item.class)
                newItem:SetPos(craftingTable:GetPos() + Vector(0,0,20))
                newItem:Spawn()
                newItem:Activate()
                if newItem.SetCraftedBy then
                    newItem:SetCraftedBy(ply)
                    // Example of how to use this function:
                    /*                
                    function ENT:SetupDataTables()
                        self:NetworkVar("Entity", 0, "CraftedBy")
                    end

                    function ENT:Think()
                        // Make sure that the player who crafted this entity is still connected.
                        if (IsValid(self:GetNWEntity("CraftedBy"))) then
                            if (!self:GetNWEntity("CraftedBy"):IsPlayer()) then
                                self:Remove()
                            end
                        else
                            self:Remove()
                        end
                        self:SetNextThink(CurTime() + 10)
                    end
                    */
                end
            end
            if item.reward then
                item.reward(ply)
            end
        else
            ply:ChatPrint(canCraft)
            // print pocket (dev)
            local pocketMaterials = {}
            for k,v in ipairs(itemTable) do
                if pocketMaterials[v.DT.MaterialType] == nil then
                    pocketMaterials[v.DT.MaterialType] = 0
                end
                pocketMaterials[v.DT.MaterialType] = pocketMaterials[v.DT.MaterialType] + 1
            end
            ply:ChatPrint("- - - - - Your Materials: - - - - -")
            for k,v in pairs(pocketMaterials) do
                ply:ChatPrint(k.." x"..v)
            end 
            local item = CRAFTING.CraftItems[craftItem]
            if not item then return false end
            ply:ChatPrint("- - - - - Required Materials: - - - - -")
            for k,v in pairs(item.craftingMaterials) do
                ply:ChatPrint(k.." x"..v)
            end
            return false
        end
        return true
    end
end
