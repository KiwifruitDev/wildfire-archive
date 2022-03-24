// Wildfire Black Mesa Roleplay
// File description: Persistent inventory system
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

// Every file needs this :)
include("autorun/sh_bmrp.lua")

function ply:SetSpawnedPersistentInventoryItem(itemnum, ent)
    self.PersistentSpawns = self.PersistentSpawns or {}
    self.PersistentSpawns[itemnum] = ent
end

function ply:GetSpawnedPersistentInventoryItem(itemnum)
    return self.PersistentSpawns and self.PersistentSpawns[itemnum]
end

local resethooks = {
    "PostCleanupMap",
    "PlayerDisconnected",
}

for _, hookname in pairs(resethooks) do
    hook.Add(hookname, "BMRP_PersistentInventory_Reset_"..hookname, function(ply)
        if IsValid(ply) then
            for k, v in pairs(ply.PersistentSpawns or {}) do
                if IsValid(v) then
                    v:Remove()
                end
            end
            ply.PersistentSpawns = nil
        else -- assume this is a map cleanup
            for _, ply in pairs(player.GetAll()) do
                for k, v in pairs(ply.PersistentSpawns or {}) do
                    if IsValid(v) then
                        v:Remove()
                    end
                end
                ply.PersistentSpawns = nil
            end
        end
    end)
end

util.AddNetworkString("GetPersistentInventoryData")
util.AddNetworkString("ReceivePersistentInventoryData")
util.AddNetworkString("SpawnPersistentInventoryItem")

net.Receive("GetPersistentInventoryData", function(len, ply)
    net.Start("ReceivePersistentInventoryData")
    net.WriteUInt(#BMRP.PersistentInventory, 8)
    for k, v in pairs(BMRP.PersistentInventory) do
        if v.Criteria then
            if not IsValid(ply) then continue end
            net.WriteBool(v:Criteria(ply) and true or false)
        else
            net.WriteBool(true) -- Always true if no criteria
        end
    end
    net.WriteUInt(#ply:GetPresents(), 8)
    for k, v in pairs(ply:GetPresents()) do
        net.WriteString(v.Name)
        net.WriteString(v.Description)
        net.WriteString(v.Model)
    end
    net.Send(ply)
end)

local WrappingPaperMaterials = {
	"christmas/candycane",
	"christmas/greencandycane",
}

local function SpawnPersistentInventoryItem(item, itemnum, ply)
    local ent = ply:GetSpawnedPersistentInventoryItem(itemnum)
    if ent then
        if item.IsWeapon then
            ply:StripWeapon(item.ClassName)
            if IsValid(ent) then
                ent:Remove()
            end
        elseif IsValid(ent) then
            ent:Remove()
        end
        ply.PersistentSpawns[itemnum] = nil
    end
    if item.IsPresent then
        if ply:HasPresent(item) then
            if #ply:GetReceivedPresents() > BMRP.MaxRecievedPresents then return end
            ply:AddReceivedPresent(item)
            ply:RemovePresent(item)
            local ent = DARKRP_Deserialize(ply, item.Entity)
            if not IsValid(ent) then return end
            local src = player.GetBySteamID(item.WrapperSteamID)
            if IsValid(src) then
                ent:SetNWEntity("wrapper", src)
            end
            ent:SetNWBool("wrapped", true)
            ent:SetNWBool("gift", true)
            ent:SetNWString("wrappedmat", table.HasValue(WrappingPaperMaterials, item.OldMat or "") and item.OldMat or "")
            ent:CPPISetOwner(ply)
            ent:SetMaterial(table.Random(WrappingPaperMaterials))
            undo.Create("Present by "..ply:Nick())
                undo.AddEntity(ent)
                undo.SetPlayer(Player)
            undo.Finish()
        end
    elseif item.ClassName then
        if item.IsWeapon then
            ply:SetSpawnedPersistentInventoryItem(itemnum, ply:Give(item.ClassName))
            ply:SelectWeapon(item.ClassName)
        else
            local ent = ents.Create(item.ClassName)
            if IsValid(ent) then
                ent:SetPos(ply:GetPos() + ply:GetForward() * 150)
                ent:Spawn()
                ent:Activate()
                ent:CPPISetOwner(ply)
                ply:SetSpawnedPersistentInventoryItem(itemnum, ent)
            end
        end
    end
end

-- https://github.com/FPtje/DarkRP/blob/92bb5e3af7b9953967963f33e568f86366f09bcd/entities/weapons/pocket/sv_init.lua#L164
if SERVER then
	function DARKRP_GetDTVars(ent)
		if not ent.GetNetworkVars then return nil end
		local name, value = debug.getupvalue(ent.GetNetworkVars, 1)
		if name ~= "datatable" then
			ErrorNoHalt("Warning: Datatable cannot be stored properly in pocket. Tell a developer!")
		end

		local res = {}

		for k,v in pairs(value) do
			res[k] = v.GetFunc(ent, v.index)
		end

		return res
	end
	function DARKRP_Serialize(ent)
		local serialized = duplicator.CopyEntTable(ent)
		serialized.DT = DARKRP_GetDTVars(ent)

		-- this function is also called in duplicator.CopyEntTable, but some
		-- entities change the DT vars of a copied entity (e.g. Lexic's moneypot)
		-- That is undone with the getDTVars function call.
		-- Re-call OnEntityCopyTableFinish assuming its implementation is pure.
		if ent.OnEntityCopyTableFinish then
			ent:OnEntityCopyTableFinish(serialized)
		end

		return serialized
	end
	function DARKRP_Deserialize(ply, item)
		local ent = ents.Create(item.Class)
		duplicator.DoGeneric(ent, item)
		ent:Spawn()
		ent:Activate()

		duplicator.DoGenericPhysics(ent, ply, item)
		table.Merge(ent:GetTable(), item)

		if ent:IsWeapon() and ent.Weapon ~= nil and not ent.Weapon:IsValid() then ent.Weapon = ent end
		if ent.Entity ~= nil and not ent.Entity:IsValid() then ent.Entity = ent end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		ent:SetPos(tr.HitPos)

		DarkRP.placeEntity(ent, tr, ply)

		local phys = ent:GetPhysicsObject()
		timer.Simple(0, function() if phys:IsValid() then phys:Wake() end end)

		if ent.OnDuplicated then
			ent:OnDuplicated(item)
		end

		if ent.PostEntityPaste then
			ent:PostEntityPaste(ply, ent, {ent})
		end

		return ent
	end
end
-- okay that's it

net.Receive("SpawnPersistentInventoryItem", function(len, ply)
    local ispresent = net.ReadBool()
    local itemnum = net.ReadUInt(8)
    local item = (ispresent and ply:GetPresents()[itemnum]) or not ispresent and BMRP.PersistentInventory[itemnum]
    if item then
        if item.Criteria then
            if item:Criteria(ply) then
                SpawnPersistentInventoryItem(item, itemnum, ply)
            end
        else
            SpawnPersistentInventoryItem(item, itemnum, ply)
        end
    end
end)

concommand.Add("bmrp_set_blockgifts", function(ply, cmd, args)
    ply:SetNWBool("blockgifts", not ply:GetNWBool("blockgifts"))
    DarkRP.notify(ply, 0, 4, ply:GetNWBool("blockgifts") and "You have blocked gifts." or "You have unblocked gifts.")
end)
