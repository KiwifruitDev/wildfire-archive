include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function SWEP:Initialize()
   self:SetWeaponHoldType( self.HoldType )
   self.Idle = 0
   self.IdleTimer = CurTime() + 1
end
 
function SWEP:Deploy()
   self:SetWeaponHoldType( self.HoldType )
   self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
   self:SetNextPrimaryFire( CurTime() + 0.5 )
   self:SetNextSecondaryFire( CurTime() + 0.5 )
   self.Spin = 0
   self.SpinTimer = CurTime()
   self.Idle = 0
   self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
   self.Recoil = 0
   self.RecoilTimer = CurTime()
   return true
end
 
function SWEP:Holster()
   self.Spin = 0
   self.SpinTimer = CurTime()
   self.Idle = 0
   self.IdleTimer = CurTime()
   self.Recoil = 0
   self.RecoilTimer = CurTime()
   return true
end
 
function SWEP:PrimaryAttack()
   /*
   if self.Weapon:Ammo1() < 20 then
      self.Owner:EmitSound( "common/wpn_denyselect.wav" )
      self:SetNextPrimaryFire( CurTime() + 0.2 )
      self:SetNextSecondaryFire( CurTime() + 0.2 )
   end
   */
   if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
      self.Owner:EmitSound( "common/wpn_denyselect.wav" )
      self:SetNextPrimaryFire( CurTime() + 0.2 )
      self:SetNextSecondaryFire( CurTime() + 0.2 )
   end
   //if self.Weapon:Ammo1() < 20 then return end
   if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
   self.Owner:EmitSound( "Weapon_HLOF_Displacer_Cannon.Spin" )
   self.Weapon:SendWeaponAnim( ACT_GAUSS_SPINUP )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self.Spin = 1
   self.SpinTimer = CurTime() + 1
   self.Idle = 1
end
 
function SWEP:SecondaryAttack()
   /*
   if self.Weapon:Ammo1() < 60 then
      self.Owner:EmitSound( "common/wpn_denyselect.wav" )
      self:SetNextPrimaryFire( CurTime() + 0.2 )
      self:SetNextSecondaryFire( CurTime() + 0.2 )
   end
   */
   if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then
      self.Owner:EmitSound( "common/wpn_denyselect.wav" )
      self:SetNextPrimaryFire( CurTime() + 0.2 )
      self:SetNextSecondaryFire( CurTime() + 0.2 )
   end
   //if self.Weapon:Ammo1() < 60 then return end
   if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
   if SERVER then
      self.Owner:EmitSound( "Weapon_HLOF_Displacer_Cannon.Spin2" )
   end
   self.Weapon:SendWeaponAnim( ACT_GAUSS_SPINUP )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self.Spin = 2
   self.SpinTimer = CurTime() + 1
   self.Idle = 1
end
 
function SWEP:Reload()
end
 
function SWEP:Think()
   if self.Spin == 1 and self.SpinTimer <= CurTime() then
      local entity = ents.Create( "ent_hlof_displacer_projectile" )
      entity:SetOwner( self.Owner )
      if IsValid( entity ) then
         local Forward = self.Owner:EyeAngles():Forward()
         entity:SetPos( self.Owner:GetShootPos() + Forward * 8 )
         entity:SetAngles( self.Owner:EyeAngles() )
         entity:Spawn()
         local phys = entity:GetPhysicsObject()
         phys:SetMass( 1 )
         phys:EnableGravity( false )
         timer.Create( "Flight"..entity:EntIndex(), 0, 0, function()
         if !IsValid( phys ) then
            timer.Stop( "Flight" )
         end
         if IsValid( entity ) and IsValid( phys ) then
            phys:ApplyForceCenter( entity:GetForward() * 25 )
         end
         end )
      end
      self.Owner:EmitSound( self.Primary.Sound )
      self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
      self.Owner:SetAnimation( PLAYER_ATTACK1 )
      self.Owner:MuzzleFlash()
      self:TakePrimaryAmmo( self.Primary.TakeAmmo )
      self.Spin = 0
      self.Idle = 0
      self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
      if game.SinglePlayer() and IsFirstTimePredicted() then
         self.Recoil = 1
         self.RecoilTimer = CurTime() + 0.2
         self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
      end
   end
   if self.Spin == 2 and self.SpinTimer <= CurTime() then
      self.Owner:EmitSound( self.Secondary.Sound )
      self.Owner:MuzzleFlash()
      self:TakePrimaryAmmo( self.Secondary.TakeAmmo )
      self.Spin = 0
      self.Idle = 0
      -- this is where the displacer magic happens
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
            self.Owner:SetPos( Vector( trampos.x, trampos.y, tramz ) )
            break
         end
     else
         local location = "Xen"
         if self.Owner:GetNWString("location") == "Xen" then
            location = "Facility"
         elseif self.Owner:GetNWString("location") == "???" then
            return
         end
         self.Owner:SetPos( table.Random(HLOF_DISPLACER_TELEPORT_LOCATIONS[location]) )
     end
   end
   if game.SinglePlayer() and IsFirstTimePredicted() then
      if self.Recoil == 1 and self.RecoilTimer <= CurTime() then
         self.Recoil = 0
      end
      if self.Recoil == 1 then
         self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( 0.23, 0, 0 ) )
      end
   end
   if self.Idle == 0 and self.IdleTimer <= CurTime() then
      if SERVER then
         self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
      end
      self.Idle = 1
   end
   if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
      self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
   end
end