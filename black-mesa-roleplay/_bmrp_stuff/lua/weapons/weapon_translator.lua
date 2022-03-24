// Wildfire Black Mesa Roleplay
// File description: BMRP Translator swep
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

AddCSLuaFile()

if SERVER then
	SWEP.Weight                     = 5
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if CLIENT then
	SWEP.PrintName          = "Translator"
	SWEP.Author             = "Wildfire BMRP"
	SWEP.Purpose            = "Used to translate garbled text from Xenian creatures."
end

SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Wildfire BMRP"
SWEP.UseHands           = false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/props_clutter/radiophone.mdl"
SWEP.WorldModel 		= "models/props_clutter/radiophone.mdl"

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


function SWEP:PrimaryAttack()
	return false
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
		vm:SetPos( ply:EyePos() - Vector( 0, 0, 4 ) + ply:GetForward() * 12 + ply:GetRight() * 7)
		// make it face you
		vm:SetAngles( ply:GetAngles() + Angle( 90, 0, 180 ) )
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
			self.CSWorldModel:SetAngles(newAng + Angle(90, 0, 180))

			self.CSWorldModel:SetupBones()
			self.CSWorldModel:DrawModel()
		end
	end
end