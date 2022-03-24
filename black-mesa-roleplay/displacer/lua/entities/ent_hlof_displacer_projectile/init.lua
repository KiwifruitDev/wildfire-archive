include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
    self.Entity:SetModel( "models/hunter/misc/sphere1x1.mdl" )
    self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
    self.Entity:SetSolid( SOLID_VPHYSICS )
    self.Entity:PhysicsInit( SOLID_VPHYSICS )
    self.Entity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
    self.Entity:DrawShadow( false )
end

function ENT:Think()
    if self.Entity:WaterLevel() > 0 then
        self.Entity:Remove()
    end
end

function ENT:PhysicsCollide( data )
    if data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() then
        self.TeleportedEntity = data.HitEntity
    end
   self.Entity:Remove()
end

function ENT:OnRemove()
    if IsValid( self.TeleportedEntity ) then
        self.TeleportedEntity:EmitSound( "Weapon_HLOF_Displacer_Cannon.Teleport" )
        if self.TeleportedEntity:IsPlayer() then
            if math.random( 1, 100 ) <= HLOF_DISPLACER_TRAM_CHANCE then
                local tramz = 0
                local tram = table.Random(HLOF_DISPLACER_TRAMS[game.GetMap()])
                for k, v in pairs(ents.FindByName(tram[1])) do
                    local trampos = v:GetPos()
                    for k2, v2 in pairs(tram[2]) do
                        if trampos.z >= v2[1] then
                            tramz = v2[2]
                        end
                    end
                    self.TeleportedEntity:SetPos( Vector( trampos.x, trampos.y, tramz ) )
                    break
                end
            else
                local location = "Xen"
                if self.TeleportedEntity:GetNWString("location") == "Xen" then
                    location = "Facility"
                elseif self.TeleportedEntity:GetNWString("location") == "???" then
                    return
                end
                self.TeleportedEntity:SetPos( table.Random(HLOF_DISPLACER_TELEPORT_LOCATIONS[location]) )
            end
        else
            self.TeleportedEntity:Remove()
        end
    end
    //util.BlastDamage( self, self.Owner, self:GetPos(), 256, 250 )
    self.Entity:EmitSound( "Weapon_HLOF_Displacer_Cannon.Impact" )
end