// Wildfire Black Mesa Roleplay
// File description: BMRP bounding box weapon serverside script
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

-- This weapon is used to create a scriptday_bounding_box entity.

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    if not IsFirstTimePredicted() then return end
    local shootpos = self.Owner:GetEyeTrace().HitPos
    if not IsValid(self:GetBoundingBox()) and self:GetMoving() then
        self:SetMoving(false)
        self:SetBoundingBox(nil)
    end
    if self:GetMoving() then
        -- success sound
        self.Owner:EmitSound("weapons/physcannon/superphys_launch" .. math.random(1, 2) .. ".wav")
        self:SetMoving(false)
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Finished a bounding box.")
        hook.Run("SystemMessage", self.Owner, "", "Bounding box finished. Use bounds_setlocation \"LocationName\" to set a location and/or use bounds_save when finished.")
    else
        self.Owner:EmitSound("weapons/physcannon/energy_bounce" .. math.random(1, 2) .. ".wav")
        -- create the entity and then resize it's OBB bounds to the player's view
        local ent = ents.Create("bounding_box")
        ent:SetPos(shootpos)
        ent:SetAngles(Angle(0,0,0))
        ent:Spawn()
        ent:Activate()
        self:SetBoundingBox(ent)
        self:SetStartPos(shootpos)
        self:SetMoving(true)
        -- add to undo
        undo.Create("bounding_box")
        undo.AddEntity(ent)
        undo.SetPlayer(self.Owner)
        undo.Finish()
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Created a bounding box.")
        hook.Run("SystemMessage", self.Owner, "", "Bounding box created. Click again to finish.")
    end
    self:SetManual(false)
    -- make a particle effect
    local effectdata = EffectData()
    effectdata:SetOrigin(shootpos)
    effectdata:SetMagnitude(5)
    effectdata:SetNormal(self.Owner:GetAimVector())
    effectdata:SetEntity(self)
    effectdata:SetAttachment(1)
    util.Effect("ToolTracer", effectdata)
    util.Effect("ElectricSpark", effectdata)
    return false
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    return false
end

function SWEP:Think()
    if not self:GetMoving() then return end
    if self:GetManual() then return end
    local ent = self:GetBoundingBox()
    if not IsValid(ent) then return end
    -- resize the OBB bounds to the player's view
    local shootpos = self.Owner:GetEyeTrace().HitPos
    local startpos = self:GetStartPos()
    -- trace the ceiling so that the bounds hit it
    local tr = util.TraceLine({
        start = shootpos,
        endpos = shootpos + Vector(0,0,1000),
        filter = function( ent ) if ( ent:GetClass() == "bounding_box" ) then return true end end,
        mask = MASK_SOLID_BRUSHONLY
    })
    local ceiling = tr.HitPos
    -- trace the floor so the startpos is on the floor
    tr = util.TraceLine({
        start = startpos,
        endpos = startpos + Vector(0,0,-1000),
        filter = function( ent ) if ( ent:GetClass() == "bounding_box" ) then return true end end,
        mask = MASK_SOLID_BRUSHONLY
    })
    local floor = tr.HitPos
    ent:SetCollisionBoundsWS(floor, ceiling)
end
