SWEP.PrintName = "Displacer Cannon"
SWEP.Category = "Half-Life: Opposing Force"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/hlof/v_displacer.mdl"
SWEP.WorldModel = "models/hlof/w_displacer.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 7
SWEP.Slot = 5
SWEP.SlotPos = 1

SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Spin = 0
SWEP.SpinTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.Recoil = 0
SWEP.RecoilTimer = CurTime()

SWEP.Primary.Sound = Sound( "Weapon_HLOF_Displacer_Cannon.Single" )
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.MaxAmmo = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.TakeAmmo = 20
SWEP.Primary.Delay = 2.5
SWEP.Primary.Force = 25

SWEP.Secondary.Sound = Sound( "Weapon_HLOF_Displacer_Cannon.Double" )
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.TakeAmmo = 60
SWEP.Secondary.Delay = 2