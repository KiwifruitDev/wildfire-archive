// Wildfire Ranked Challenges
// File description: Generic weapon for HECU training.
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
local ShootSound = Sound("Weapon_Pistol.Single")

SWEP.Base = "weapon_base"

SWEP.PrintName = "Gun"
SWEP.Author = "Wildfire Servers"
SWEP.Category = "Wildfire BMRP"

SWEP.Spawnable = false
SWEP.AdminOnly = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.Primary.Damage = 0
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 10
SWEP.Primary.Ammo = "ItsJustAGun"
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.1

SWEP.Secondary.Damage = 0
SWEP.Secondary.TakeAmmo = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = "ItsJustAGun"
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Spread = 0
SWEP.Secondary.NumberofShots = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Delay = 0

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "Pistol"

SWEP.FiresUnderwater = false

SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
    util.PrecacheSound(ShootSound)
end

function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    if not IsValid(self.Owner) then return end
    local bullet = {} 
    bullet.Num = self.Primary.NumberofShots 
    bullet.Src = self.Owner:GetShootPos() 
    bullet.Dir = self.Owner:GetAimVector() 
    bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force 
    bullet.Damage = self.Primary.Damage 
    bullet.AmmoType = self.Primary.Ammo 
     
    local rnda = self.Primary.Recoil * -1 
    local rndb = self.Primary.Recoil * math.random(-1, 1) 
     
    self:ShootEffects()
     
    self.Owner:FireBullets( bullet ) 
    self:EmitSound(ShootSound)
    //self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
    self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
     
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
end 

function SWEP:SecondaryAttack()

end
