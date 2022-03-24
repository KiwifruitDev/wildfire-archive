// Wildfire Black Mesa Roleplay
// File description: BMRP Wrapping Paper swep
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

if SERVER then
	include("autorun/server/sv_persistentinventory.lua")
end

// Every file needs this :)
include("autorun/sh_bmrp.lua")

AddCSLuaFile()

if SERVER then
	SWEP.Weight                     = 5
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if CLIENT then
	SWEP.PrintName          = "Wrapping Paper"
	SWEP.Author             = "Wildfire BMRP"
	SWEP.Purpose            = "Wrap up anything to be given out as a gift to a random player on the server!"
end

SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Wildfire BMRP"
SWEP.UseHands           = false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/c_models/c_xms_giftwrap/c_xms_giftwrap.mdl"
SWEP.WorldModel 		= "models/weapons/c_models/c_xms_giftwrap/c_xms_giftwrap.mdl"

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "";

SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Damage = 1;
SWEP.Secondary.Delay = 1;
SWEP.Secondary.Ammo = "";

SWEP.Slot = 4

SWEP.WrapBlacklist = {
	["player"] = true,
	["gmt_instrument_base_reborn"] = true,
	["prop_ragdoll"] = true,
	["sent_streamradio"] = true,
	["mediaplayer_tv"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true,
	["func_button"] = true,
	["func_physbox"] = true,
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
	["func_movelinear"] = true,
}

function SWEP:PrimaryAttack()
	if SERVER then
		if not IsValid(self.Owner) then return end
		-- get the entity
		local ent = self.Owner:GetEyeTrace().Entity
		-- check if it's a valid entity
		if IsValid(ent) then
			if ent:GetNWBool("wrapped") then
				DarkRP.notify(self.Owner, 1, 4, "This entity is already wrapped!")
				return
			end
			if ent:CPPIGetOwner() ~= self.Owner then
				DarkRP.notify(self.Owner, 1, 4, "You can only wrap up entities you own!")
				return
			end
			-- make sure it's not too far away
			if ent:GetPos():Distance(self.Owner:GetPos()) > 128 then return end
			-- make sure it isn't in the blacklist
			if self.WrapBlacklist[ent:GetClass()] then
				DarkRP.notify(self.Owner, 1, 4, "You can't wrap up that entity!")
				return
			end
			-- make sure you haven't sent too many presents
			if #self.Owner:GetSentPresents() >= BMRP.MaxSentPresents then
				DarkRP.notify(self.Owner, 1, 4, "You have sent too many presents!")
				return
			end
			-- wrap up the entity
			local oldmat = ent:GetMaterial()
			local plycount = player.GetCount()
			//local ply = self.Owner
			//if plycount > 1 then
			local plys = player.GetAll()
			-- remove yourself from the list
			table.RemoveByValue(plys, self.Owner)
			-- select a random player
			local shuffled = ShuffleTable(plys)
			for k, v in pairs(shuffled) do
				if v:GetNWBool("blockgifts") then continue end // skip blocked players
				if #v:GetPresents() < BMRP.MaxPresents and #v:GetReceivedPresents() < BMRP.MaxRecievedPresents then
					-- this player is good to go
					ply = v
					break
				end
			end
			if not IsValid(ply) then
				DarkRP.notify(self.Owner, 1, 4, "No one can receive your present!")
				return
			end
			//end
			-- give the entity to the random player (or yourself)
			local serialized = DARKRP_Serialize(ent)
			local template = {
				Name = "Present",
				ClassName = ent:GetClass(),
				Description = "A present wrapped by " .. self.Owner:Nick().. ". ("..ent:GetClass()..") This item will not persist.",
				IsWeapon = false,
				IsPresent = true,
				Model = "models/gift/christmas_gift.mdl",
				Entity = serialized,
				Wrapper = self.Owner:Nick(),
				WrapperSteamID = self.Owner:SteamID(),
				OldMat = oldmat,
			},
			ply:EmitSound("garrysmod/save_load" .. math.random(1, 4) .. ".wav")
			hook.Run("SystemMessage", ply, "GIFTS", "You have received a present from " .. self.Owner:Nick() .. "! ("..ent:GetClass()..")")
			hook.Run("SystemMessage", self.Owner, "GIFTS", "You have given a present to " .. ply:Nick() .. "! ("..ent:GetClass()..")")
			ply:AddPresent(template)
			self.Owner:AddSentPresent(template)
			ent:Remove()
			print("[BMRP] " .. self.Owner:Nick() .. " has wrapped up " .. ent:GetClass() .. " and gave it to " .. ply:Nick() .. "!")
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end


function SWEP:Holster()
	if IsValid(self.CSWorldModel) then
		self.CSWorldModel:Remove()
	end
	return true
end

if CLIENT then
	function SWEP:Think()
		if not IsValid(self:GetOwner()) then
			if IsValid(self.CSWorldModel) then
				self.CSWorldModel:Remove()
			end
		end
	end
	function SWEP:PreDrawViewModel( vm, wep, ply )
		// make viewmodel appear in front of player
		vm:SetPos( ply:EyePos() - Vector( 0, 0, 10 ) + ply:GetForward() * 15 + ply:GetRight() * 7)
		// make it face you
		vm:SetAngles( ply:GetAngles() )
	end
	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()
		if (IsValid(_Owner)) then
			if not IsValid(self.CSWorldModel) then 
				self.CSWorldModel = ClientsideModel(self.WorldModel)
			end
			-- Specify a good position
			local offsetVec = Vector(5.75, -2.4, -1)
			local offsetAng = Angle(180, 240, 0)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = _Owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			self.CSWorldModel:SetPos(newPos)
			self.CSWorldModel:SetAngles(newAng)

			self.CSWorldModel:SetupBones()
			self.CSWorldModel:DrawModel()
		end
	end
end