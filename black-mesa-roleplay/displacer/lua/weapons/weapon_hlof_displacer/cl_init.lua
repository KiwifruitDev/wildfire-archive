include("shared.lua")

SWEP.WepSelectIcon = surface.GetTextureID( "hlof/sprites/displacer_selecticon" )
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
killicon.Add( "weapon_hlof_displacer", "hlof/sprites/displacer_killicon", Color( 255, 255, 255, 255 ) )
killicon.Add( "ent_hlof_displacer_projectile", "hlof/sprites/displacer_killicon", Color( 255, 255, 255, 255 ) )


function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end
    if not IsFirstTimePredicted() then return end
    return true
end


function SWEP:DrawHUD()
    local x, y
    if ( self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() ) then
        local tr = util.GetPlayerTrace( self.Owner )
        local trace = util.TraceLine( tr )
        local coords = trace.HitPos:ToScreen()
        x, y = coords.x, coords.y
    else
        x, y = ScrW() / 2, ScrH() / 2
    end
    surface.SetTexture( surface.GetTextureID( "hlof/sprites/displacer_crosshair" ) )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRect( x - 16, y - 16, 32, 32 )
end

function SWEP:Think()
    if self.Spin == 1 and self.SpinTimer <= CurTime() then
        if IsFirstTimePredicted() then
            self.Recoil = 1
            self.RecoilTimer = CurTime() + 0.2
            self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
        end
    end
    if self.Spin == 2 and self.SpinTimer <= CurTime() then
        local light = DynamicLight( self:EntIndex() )
        light.Pos = self:GetPos()
        light.r = 255
        light.g = 255
        light.b = 100
        light.Brightness = 2
        light.Size = 256
        light.Decay = 250
        light.DieTime = CurTime() + 0.5
    end
    if IsFirstTimePredicted() then
        if self.Recoil == 1 and self.RecoilTimer <= CurTime() then
           self.Recoil = 0
        end
        if self.Recoil == 1 then
           self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( 0.23, 0, 0 ) )
        end
    end
end