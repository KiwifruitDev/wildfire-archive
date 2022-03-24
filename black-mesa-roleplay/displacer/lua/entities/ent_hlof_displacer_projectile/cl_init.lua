include("shared.lua")

function ENT:Draw()
    render.SetMaterial( Material( "hlof/sprites/exit1" ) )
    render.DrawSprite( self:GetPos(), 64, 64, Color( 255, 255, 255 ) )
end

function ENT:Think()
    local light = DynamicLight( self:EntIndex() )
    light.Pos = self:GetPos()
    light.r = 255
    light.g = 255
    light.b = 100
    light.Brightness = 1
    light.Size = 256
    light.Decay = 250
    light.DieTime = CurTime() + 0.2
end

function ENT:OnRemove()
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
