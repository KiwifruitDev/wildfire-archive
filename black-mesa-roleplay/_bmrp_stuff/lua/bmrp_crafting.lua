// Wildfire Black Mesa Roleplay
// File description: Crafting system shared code
// Copyright (c) 2022 KiwifruitDev
// Licensed under the MIT License.
//*********************************************************************************************
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//*********************************************************************************************
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
    "bmrp_metal",
    "xen_crystal",
}
CRAFTING.ScrapTypes = {
	"Metal", // Just a generic metal scrap
	"Silicon", // Silicon like electronic components
	"Plastic", // Plastic would be like a milk carton or something
	"Rubber", // Rubber, tires?
	"Wood", // Planks, logs, etc
	"Glass", // Whatever glass is
}
CRAFTING.ScrapModels = {
	["Metal"] = "models/props_c17/metalpot002a.mdl",
    ["Silicon"] = "models/mosi/fallout4/props/junk/components/circuitry.mdl",
    ["Plastic"] = "models/props_junk/garbage_plasticbottle003a.mdl",
    ["Rubber"] = "models/props_vehicles/tire001c_car.mdl",
    ["Wood"] = "models/gibs/wood_gib01b.mdl",
    ["Glass"] = "models/props_junk/GlassBottle01a.mdl",
}
CRAFTING.CraftItems = {
    ["Battery"] = {
        class = "bmrp_metal",
        craftClass = true,
        model = "models/items/car_battery01.mdl",
        condition = function(ply, pocketItems)
            if pocketItems["Silicon"] == nil or pocketItems["Silicon"] < 1 then
                return "You need 1 Silicon!"
            end
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 2 then
                return "You need 2 Metal!"
            end
            if pocketItems["Rubber"] == nil or pocketItems["Rubber"] < 1 then
                return "You need 1 Rubber!"
            end
            return true
        end,
        reward = function(ply, ent)
            ent:SetCraftingMaterialType("Battery")
            ent:SetModel("models/items/car_battery01.mdl")
            ent:PhysicsInit(SOLID_VPHYSICS)
            table.Empty(ply.darkRPPocket)
        end,
        description = [[A battery that can be used to power a device.


Requires: Silicon x1, Metal x2, Rubber x1]],
    },
	["Tau Cannon"] = {
        class = "weapon_hl_gauss",
        craftClass = false,
        model = "models/weapons/w_gauss_hls.mdl",
        condition = function(ply, pocketItems)
            if IsValid(ply:GetWeapon("weapon_hl_gauss")) then
                return "You already have one!"
            end
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 1 then
                return "You need 1 Metal!"
            end
            if pocketItems["Battery"] == nil or pocketItems["Battery"] < 2 then
                return "You need 2 Batteries!"
            end
            if pocketItems["Orange Crystal"] == nil or pocketItems["Orange Crystal"] < 1 then
                return "You need 1 Orange Crystal!"
            end
            local resonancecheck = false
            for k, v in pairs(pocketItems.Resonance) do
                if v.Crystal == "Orange" and v.Resonance >= 60 and v.Clean == true and v.AnalyzerScanned == true and v.Scanned == true then
                    resonancecheck = true
                end
            end
            if resonancecheck == false then
                return "Your crystal is invalid!"
            end
            return true
        end,
        reward = function(ply, ent)
            ply:Give("weapon_hl_gauss")
            table.Empty(ply.darkRPPocket)
        end,
        description = [[The Tau Cannon is a powerful particle accelerator with significant stopping power.

Requires: Metal x1, Battery x2, Orange Crystal (60% Resonance, Cleaned, Scanned, Analyzed) x1]]
    },
    ["Uranium Ammo"] = {
        class = "ent_hl_gauss_ammo",
        craftClass = true,
        model = "models/hl/w_gaussammo.mdl",
        condition = function(ply, pocketItems)
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 2 then
                return "You need 2 Metal!"
            end
            if pocketItems["Battery"] == nil or pocketItems["Battery"] < 1 then
                return "You need 1 Battery!"
            end
            if pocketItems["Silicon"] == nil or pocketItems["Silicon"] < 1 then
                return "You need 1 Silicon!"
            end
            return true
        end,
        reward = function(ply, ent)
            table.Empty(ply.darkRPPocket)
        end,
        description = [[Uranium ammo boxes contain a highly explosive projectile that can be used with the Tau Cannon.

Requires: Metal x2, Battery x1, Silicon x1]]
    },
    ["Displacer"] = {
        class = "weapon_hlof_displacer",
        craftClass = false,
        model = "models/hlof/w_displacer.mdl",
        condition = function(ply, pocketItems)
            if IsValid(ply:GetWeapon("weapon_hlof_displacer")) then
                return "You already have one!"
            end
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 1 then
                return "You need 1 Metal!"
            end
            if pocketItems["Silicon"] == nil or pocketItems["Silicon"] < 1 then
                return "You need 1 Silicon!"
            end
            if pocketItems["Battery"] == nil or pocketItems["Battery"] < 1 then
                return "You need 1 Battery!"
            end
            if pocketItems["Green Crystal"] == nil or pocketItems["Green Crystal"] < 1 then
                return "You need 1 Green Crystal!"
            end
            local resonancecheck = false
            for k, v in pairs(pocketItems.Resonance) do
                if v.Crystal == "Green" and v.Resonance >= 40 and v.Clean == true and v.AnalyzerScanned == true and v.Scanned == true then
                    resonancecheck = true
                end
            end
            if resonancecheck == false then
                return "Your crystal is invalid!"
            end
            return true
        end,
        reward = function(ply, ent)
            ply:Give("weapon_hlof_displacer")
            table.Empty(ply.darkRPPocket)
        end,
        description = [[The Displacer is an experimental handheld machine designed to connect to the border world as needed.

Requires: Metal x1, Silicon x1, Battery x1, Green Crystal (40% Resonance, Cleaned, Scanned, Analyzed) x1]]
    },
    ["Coolant Pack"] = {
        class = "bmrp_metal",
        craftClass = true,
        model = "models/props_equipment/portablebattery01.mdl",
        condition = function(ply, pocketItems)
            if pocketItems["Glass"] == nil or pocketItems["Glass"] < 1 then
                return "You need 1 Glass!"
            end
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 1 then
                return "You need 1 Metal!"
            end
				if pocketItems["Battery"] == nil or pocketItems["Battery"] < 1 then
                return "You need 1 Battery!"
            end
            if pocketItems["Dark Blue Crystal"] == nil or pocketItems["Dark Blue Crystal"] < 1 then
                return "You need 1 Dark Blue Crystal!"
            end
            local resonancecheck = false
            for k, v in pairs(pocketItems.Resonance) do
                if v.Crystal == "Dark Blue" and v.Resonance >= 10 and v.Clean == true and v.AnalyzerScanned == true and v.Scanned == true then
                    resonancecheck = true
                end
            end
            if resonancecheck == false then
                return "Your crystal is invalid!"
            end
            return true
        end,
        reward = function(ply, ent)
            ent:SetCraftingMaterialType("Coolant Pack")
            ent:SetModel("models/props_equipment/portablebattery01.mdl")
            ent:PhysicsInit(SOLID_VPHYSICS)
            table.Empty(ply.darkRPPocket)
        end,
        description = [[A contained substance that can be used to cool a device.

Requires: Glass x1, Metal x1, Battery x1, Dark Blue Crystal (10% Resonance, Cleaned, Scanned, Analyzed) x1]],
	},
	["Gluon Gun"] = {
        class = "weapon_hl_egon",
        craftClass = false,
        model = "models/hl/w_egon.mdl",
        condition = function(ply, pocketItems)
            if pocketItems["Metal"] == nil or pocketItems["Metal"] < 1 then
                return "You need 1 Metal!"
            end
			if pocketItems["Battery"] == nil or pocketItems["Battery"] < 1 then
                return "You need 1 Battery!"
            end
			if pocketItems["Coolant Pack"] == nil or pocketItems["Coolant Pack"] < 1 then
                return "You need 1 Coolant Pack!"
            end
            if pocketItems["Purple Crystal"] == nil or pocketItems["Purple Crystal"] < 1 then
                return "You need 1 Purple Crystal!"
            end
            local resonancecheck = false
            for k, v in pairs(pocketItems.Resonance) do
                if v.Crystal == "Purple" and v.Resonance >= 90 and v.Clean == true and v.AnalyzerScanned == true and v.Scanned == true then
                    resonancecheck = true
                end
            end
            if resonancecheck == false then
                return "Your crystal is invalid!"
            end
            return true
        end,
        reward = function(ply, ent)
            ply:Give("weapon_hl_egon")
            table.Empty(ply.darkRPPocket)
        end,
        description = [[The Gluon Gun is an experimental weapon capable of disintegrating the living things and particles directly in front of it.

Requires: Metal x1, Battery x1, Coolant Pack x1, Purple Crystal (90% Resonance, Cleaned, Scanned, Analyzed) x1]],
    },
    ["Flare"] = {
        class = "flare",
        craftClass = true,
        model = "models/halflife/items/flare.mdl",
        condition = function(ply, pocketItems)
            if pocketItems["Wood"] == nil or pocketItems["Wood"] < 1 then
                return "You need 1 Wood!"
            end
			if pocketItems["Silicon"] == nil or pocketItems["Silicon"] < 1 then
                return "You need 1 Silicon!"
            end
            return true
        end,
        reward = function(ply, ent)
            -- remove 1 wood and 1 silicon from pocket
            local wood = false
            local silicon = false
            for k, v in pairs(ply.darkRPPocket) do
                if v.DT then
                    if v.DT.CraftingMaterialType == "Wood" and not wood then
                        ply.darkRPPocket[k] = nil
                        wood = true
                    elseif v.DT.CraftingMaterialType == "Silicon" and not silicon then
                        ply.darkRPPocket[k] = nil
                        silicon = true
                    end
                    if silicon and wood then
                        break
                    end
                end
            end
        end,
        description = [[A flare is a small, bright light that can be used to illuminate an area.

Requires: Wood x1, Silicon x1]]
    },
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
        return "This item does not exist!"
    end
    if item.condition then -- CONDITIONAL CRAFTING --
        local cond = item.condition(ply, itemTable)
        if cond ~= true then
            if returnBoolean then return false end
            return cond or "You cannot craft this item!"
        end
    end
    print("hola")
    return true
end

// ================ //
// SERVER FUNCTIONS //
// ================ //
if SERVER then
    function CRAFTING.Craft(ply, craftItem, craftingTable)
        print("muy bien")
        if not IsValid(ply) then return false end
        if not IsValid(craftingTable) then return false end
        if not craftingTable:GetClass() == "bmrp_crafting_table" then return false end
        local itemTable = ply.darkRPPocket // DarkRP's pocket items
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
        PrintTable(newtable)
        local canCraft = CRAFTING.CanCraft(ply, newtable, craftItem, false)
        if canCraft == true then
            local item = CRAFTING.CraftItems[craftItem]
            if not item then return false end
            print(item.craftClass)
            if item.craftClass then
                local newItem = ents.Create(item.class)
                newItem:SetPos(craftingTable:GetPos() + Vector(0,0,30))
                newItem:Spawn()
                newItem:Activate()
                -- cppi owner
                newItem:CPPISetOwner(ply)
                newItem:PhysicsInit(SOLID_VPHYSICS)
                if newItem.SetCraftedBy then
                    newItem:SetCraftedBy(ply)
                end
                if item.reward then
                    item.reward(ply, newItem)
                end
            elseif item.reward then
                item.reward(ply, nil)
            end
            hook.Run("OnPlayerCraft", ply, craftItem, craftingTable)
        else
            ply:ChatPrint(canCraft)
            return false
        end
        print("como estas")
        return true
    end
end
