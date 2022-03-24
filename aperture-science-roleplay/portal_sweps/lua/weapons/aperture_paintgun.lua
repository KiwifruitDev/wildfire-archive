AddCSLuaFile( )

if ( SERVER ) then
	SWEP.Weight                     = 4
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if ( CLIENT ) then
	SWEP.WepSelectIcon 		= surface.GetTextureID("weapons/paintgun_inventory")
	SWEP.PrintName          = "Paint Gun"
	SWEP.Author             = "CrishNate (modified by Wildfire)"
	SWEP.Purpose            = "Shoots gels"
	SWEP.ViewModelFOV       = 45
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.CSMuzzleFlashes    = false

end

SWEP.HoldType			= "crossbow"
SWEP.EnableIdle			= false	
SWEP.BobScale 			= 0
SWEP.SwayScale 			= 0

SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Aperture Science"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/v_aperture_paintgun.mdl" 
SWEP.WorldModel 		= "models/weapons/w_aperture_paintgun.mdl"

SWEP.ViewModelFlip 		= false

SWEP.Delay              = .5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo				= "none"

SWEP.RunBob = 0.5
SWEP.RunSway = 2.0

SWEP.PaintGunHoldEntity	= NULL
SWEP.NextAllowedPickup	= 0
SWEP.PickupSound		= nil
SWEP.IsShooting			= false
SWEP.HUDAnimation		= 0
SWEP.HUDSmoothCursor	= 0

function SWEP:Initialize()
end

function SWEP:ViewModelDrawn(viewModel) 
end

function SWEP:Holster(wep)
	return true
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Reload()
	return
end

function SWEP:Deploy()
	return true
end

function SWEP:OnRemove()
	return true
end
