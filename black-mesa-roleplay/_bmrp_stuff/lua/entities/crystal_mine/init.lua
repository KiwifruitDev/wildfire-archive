// Wildfire Black Mesa Roleplay
// File description: BMRP server-side AMS cart entity script
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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

    self:SetModel("models/props_xen/crystals/xen_crystals_orange_3_micro.mdl")

    -- get random out of self.crystaltypes that isn't beyond self.CrystalTypeLimit
    local type = self.CrystalTypes[math.random(1, self.CrystalTypeLimit)]
    self:SetCrystalType(type[1]) // first value is the name, second is the color
    self:SetColor(type[2])

    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

end

function ENT:Think()
    if self:GetCrystalEffect() == "Rainbow" then
        return true -- basically, we're going to make this become a rainbow crystal outside of here
    end
    // every 300 seconds reset the resonance and crystal type
    local type = self.CrystalTypes[math.random(1, self.CrystalTypeLimit)]

    self:SetCrystalType(type[1])
    self:SetColor(type[2])
    
    self:SetCrystalRemaining(4) // Reset crystal mine back to 4.

    self:NextThink( CurTime() + 300 )
    return true 
end



function ENT:Use(ply)
    local weapon = ply:GetActiveWeapon()
    if not weapon:IsValid() then return end
    if weapon:GetClass() == "weapon_handheldscanner" then
        hook.Run("SystemMessage", ply, "", "The scanner fails to scan the crystal. The crystal must be broken up into smaller pieces.")
        ply:EmitSound("npc/scanner/combat_scan5.wav")
    end
end


function ENT:OnTakeDamage( dmginfo )
    local ply = dmginfo:GetAttacker()
    local weapon = ply:GetActiveWeapon()
    local damage = dmginfo:GetDamage()

    if weapon:GetClass() == "tfa_nmrih_pickaxe" then
        if self:GetCrystalRemaining() <= 0 then
            hook.Run("SystemMessage", ply, "", "This crystal cannot be mined anymore!")
        else
            self:SetCrystalMineHealth(self:GetCrystalMineHealth() - damage) 
            if self:GetCrystalMineHealth() <= 0 then
                self:SetCrystalRemaining(self:GetCrystalRemaining() - 1)
                self:SetCrystalMineHealth(325)

                local vec = self:GetPos() + Vector(0, 0, 60)
                local crystal = ents.Create("xen_crystal")
                crystal:Spawn()
                crystal:Activate()
                -- get type table from first value of the crystal type table (self:GetCrystalType())
                for k,v in pairs(self.CrystalTypes) do
                    if v[1] == self:GetCrystalType() then
                        crystal:SetCrystalType(v[1])
                        crystal:SetColor(v[2])
                        crystal:SetCrystalEffect(v[3])
                        crystal:SetCrystalResonance(math.random(1, 100))
                        crystal:SetCrystalAMSPowerLevel(math.random(1, 100)) //USEFUL FOR LATER!!!
                        crystal:CPPISetOwner(ply)
                        crystal:SetPos(vec)
                        if v[3] == "Rainbow" then
                            crystal:SetCrystalResonance(math.Clamp(crystal:GetCrystalResonance() + 99, 1, 100))
                            crystal:SetCrystalAMSPowerLevel(math.Clamp(crystal:GetCrystalAMSPowerLevel() - 99, 1, 100))
                            for k,v in pairs(player.GetAll()) do
                                //DarkRP.notify(v, 3, 4, "The rainbow crystal has been mined!")
                                v:SendLua("surface.PlaySound('friends/message.wav')")
                                hook.Run("SystemMessage", v, "HSV", "The rainbow crystal has been mined!")
                            end
                            local fallback = self.CrystalTypes[math.random(1, self.CrystalTypeLimit)]
                            self:SetCrystalType(fallback[1])
                            self:SetColor(fallback[2])
                        end
                        hook.Run("CrystalMined", ply, crystal)
                    end
                end
            end
        end
    end
end


