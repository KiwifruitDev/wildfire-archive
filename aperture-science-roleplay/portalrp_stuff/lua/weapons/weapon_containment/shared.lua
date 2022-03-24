AddCSLuaFile( )

if ( SERVER ) then
	SWEP.Weight                     = 4
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if ( CLIENT ) then
	SWEP.PrintName          = "Bounds Tool"
	SWEP.Author             = "Wildfire Servers"
	SWEP.Purpose            = "Left click to create a boundary."
end

SWEP.HoldType			= "crossbow"
SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Wildfire PortalRP"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel 		= "models/weapons/w_rpg.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo				= "none"
SWEP.AlwaysRaised = true

function SWEP:Initialize()
end

function SWEP:ViewModelDrawn(viewModel) 
end

function SWEP:Holster(wep)
    local ply = self.Owner
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return false end
    if SERVER then
        local ent = ply:GetNWEntity("bounds")
        if IsValid(ent) then
            ply:ChatPrint(ent.handle_min:GetPos().x..", "..ent.handle_min:GetPos().y..", "..ent.handle_min:GetPos().z.." <-> "..ent.handle_max:GetPos().x..", "..ent.handle_max:GetPos().y..", "..ent.handle_max:GetPos().z)
            ent:Remove()
        end
    end
	return true
end

function SWEP:PrimaryAttack()
    local ply = self.Owner
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return false end
    if SERVER then
        if self:GetNextPrimaryFire() > CurTime() then return end
        self:SetNextPrimaryFire(CurTime() + 0.5)
        local ent = ply:GetNWEntity("bounds")
        if not IsValid(ent) then
            if self:GetNextSecondaryFire() > CurTime() then return end
            self:SetNextSecondaryFire(CurTime() + 0.5)
            local ent = ply:GetNWEntity("bounds")
            if IsValid(ent) then
                ent:Remove()
            end
            ent = ents.Create("trigger_bounds")
            ent:Spawn()

            local ps=ply:GetEyeTrace().HitPos
            ent.handle_min:SetPos(ps+Vector(0,0,0))
            ent.handle_max:SetPos(ps+Vector(0,0,0))
            ent:Think()
            ply:SetNWEntity("bounds",ent)
            undo.Create("boundary")
                undo.AddFunction(function(tab)
                    local ply = tab.Owner
                    if not IsValid(ply) then return end
                    if not ply:IsSuperAdmin() then return false end
                    if SERVER then
                        local ent = ply:GetNWEntity("bounds")
                        if IsValid(ent) then
                            ply:ChatPrint(ent.handle_min:GetPos().x..", "..ent.handle_min:GetPos().y..", "..ent.handle_min:GetPos().z.." <-> "..ent.handle_max:GetPos().x..", "..ent.handle_max:GetPos().y..", "..ent.handle_max:GetPos().z)
                        end
                    end
                end)
                undo.AddEntity(ply:GetNWEntity("bounds"))
                undo.SetPlayer(ply)
            undo.Finish()
        else
            local ps = ply:GetEyeTrace().HitPos
            ent.handle_min:SetPos(ps)
        end
    end
	return
end

function SWEP:SecondaryAttack()
    local ply = self.Owner
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return false end
    if SERVER then
        if self:GetNextSecondaryFire() > CurTime() then return end
        self:SetNextSecondaryFire(CurTime() + 0.5)
        local ent = ply:GetNWEntity("bounds")
        if not IsValid(ent) then return end
        local ps = ply:GetEyeTrace().HitPos
        ent.handle_max:SetPos(ps)
    end
	return
end

function SWEP:Reload()
    local ply = self.Owner
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return false end
    if SERVER then
        local ent = ply:GetNWEntity("bounds")
        if IsValid(ent) then
            ply:ChatPrint(ent.handle_min:GetPos().x..", "..ent.handle_min:GetPos().y..", "..ent.handle_min:GetPos().z.." <-> "..ent.handle_max:GetPos().x..", "..ent.handle_max:GetPos().y..", "..ent.handle_max:GetPos().z)
        end
    end
	return
end

function SWEP:Deploy()
	return true
end

function SWEP:OnRemove()
	return true
end
