// Wildfire Black Mesa Roleplay
// File description: BMRP Syringe swep
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

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "SyringeBloodType")
    if SERVER then
        self:SetSyringeBloodType("None")
    end
end

if SERVER then
	SWEP.Weight                     = 4
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if CLIENT then
	SWEP.PrintName          = "Syringe"
	SWEP.Author             = "Wildfire BMRP"
	SWEP.Purpose            = "Left-click to take some blood. (MWUAHAHAHA)"
end

SWEP.HoldType			= "knife"
SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Wildfire BMRP"
SWEP.UseHands           = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/wildfire/weapons/c_syringe.mdl"
SWEP.WorldModel 		= "models/wildfire/weapons/w_syringe.mdl"

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

local XenBloodType = {
	["models/cs/playermodels/vortigaunt.mdl"] = "Vortigaunt",
}

local painmale = {
    "vo/npc/male01/pain01.wav",
    "vo/npc/male01/pain02.wav",
    "vo/npc/male01/pain03.wav",
    "vo/npc/male01/pain04.wav",
    "vo/npc/male01/pain05.wav",
    "vo/npc/male01/pain06.wav",
    "vo/npc/male01/pain07.wav",
    "vo/npc/male01/pain08.wav",
    "vo/npc/male01/pain09.wav",
}
local painfemale = {
    "vo/npc/female01/pain01.wav",
    "vo/npc/female01/pain02.wav",
    "vo/npc/female01/pain03.wav",
    "vo/npc/female01/pain04.wav",
    "vo/npc/female01/pain05.wav",
    "vo/npc/female01/pain06.wav",
    "vo/npc/female01/pain07.wav",
    "vo/npc/female01/pain08.wav",
    "vo/npc/female01/pain09.wav",
}

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local ply = self:GetOwner()

    self.Weapon:EmitSound("weapons/knife/knife_slash1.wav")
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
    
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true)
		end
		
		local trace = self.Owner:GetEyeTraceNoCursor()
		
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if (IsValid(trace.Entity)) then
				if trace.Entity:IsPlayer() then

					local dmg = DamageInfo()
					dmg:SetDamage(1)
					dmg:SetDamageType(DMG_SLASH)
					dmg:SetAttacker(ply)
					dmg:SetInflictor(self)
					self:SendWeaponAnim( ACT_VM_HITCENTER )

					if XenBloodType[trace.Entity:GetModel()] ~= nil then
						self:SetSyringeBloodType(XenBloodType[trace.Entity:GetModel()])
						hook.Run("SystemMessage", ply, "", "You pricked the creature with the syringe. You now have a small vial of Its blood.")
						trace.Entity:TakeDamageInfo(dmg)
						trace.Entity:EmitSound("weapons/knife/knife_hit1.wav")
					else
						if self:GetSyringeBloodType() ~= "Human" then
							self:SetSyringeBloodType("Human")

							local snd = painmale
							if string.find(trace.Entity:GetModel(), "female") then
								snd = painfemale
							end
							trace.Entity:EmitSound(snd[math.random(1, #snd)])

							trace.Entity:TakeDamageInfo(dmg)
							trace.Entity:EmitSound("weapons/knife/knife_hit1.wav")

							hook.Run("SystemMessage", ply, "", "You pricked them with the syringe. You now have a small vial of their blood.")
						else
							hook.Run("SystemMessage", ply, "", "There's no need to prick them again!")
						end
					end
				end
			end
		end

		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false)
		end
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local ply = self:GetOwner()

	if self:GetSyringeBloodType() ~= "None" then
		self:SetSyringeBloodType("None")
		hook.Run("SystemMessage", ply, "", "You have cleared the blood from your syringe.")
	end

end


function SWEP:Holster()
	return true
end