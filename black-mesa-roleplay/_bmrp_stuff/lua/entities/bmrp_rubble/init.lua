// Wildfire Black Mesa Roleplay
// File description: BMRP server-side rubble entity script
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

local RubbleWalls = {
    "models/props_debris/barricade_short01a.mdl",
    "models/props_debris/barricade_short02a.mdl",
    "models/props_debris/barricade_short03a.mdl",
    "models/props_debris/barricade_short04a.mdl",
    "models/props_debris/barricade_tall01a.mdl",
    "models/props_debris/barricade_tall02a.mdl",
    "models/props_debris/barricade_tall03a.mdl",
    "models/props_debris/barricade_tall04a.mdl",
}

local RubblePiles = {
    "models/props_debris/concrete_debris128pile001a.mdl", 
    "models/props_debris/plaster_ceilingpile002a.mdl",
    "models/props_debris/concrete_debris128pile001b.mdl",
}

function ENT:Initialize()
    self:SetModel(self:GetRubbleModel() or table.Random(RubbleWalls))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        // freeze
        phys:EnableMotion(false)
    end
    // invisible
    self:SetRenderMode(RENDERMODE_NONE)
    self:SetNoDraw(true)
    self:SetColor(Color(255, 255, 255, 0))
    self:DrawShadow(false)
    // unsolid
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetVisible(false)
    self:SetDestroyed(false)
    self:SetRubbleHealth(600)
end

function ENT:Think()
    if self:GetRubbleModel() then
        self:SetModel(self:GetRubbleModel())
    end
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:OnTakeDamage( dmginfo )
    if self:GetVisible() == false or self:GetDestroyed() == true then
        return
    end
    local ply = dmginfo:GetAttacker()
    local weapon = ply:GetActiveWeapon()
    local damage = dmginfo:GetDamage()
    if weapon:GetClass() == "tfa_nmrih_sledge" or weapon:GetClass() == "tfa_nmrih_pickaxe" then
        self:SetRubbleHealth(self:GetRubbleHealth() - damage) 
        if self:GetRubbleHealth() <= 0 then
            self:EmitSound("physics/concrete/concrete_break" .. math.random(2,3) .. ".wav")
            self:SetDestroyed(true)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self:SetModel(table.Random(RubblePiles))
            self:DropToFloor()
            //timer.Simple(0.01, function() 
                //self:Remove()
            //end)
        end
        self:EmitSound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav")
    end
end

function ENT:AcceptInput(name, activator, caller, data)
    // use these first
    if name == "Visualize" then
        self:SetRenderMode(RENDERMODE_NORMAL)
        self:SetColor(Color(255, 255, 255, 255))
        self:SetNoDraw(false)
        self:DrawShadow(true)
        self:SetVisible(true)
    elseif name == "Invisualize" then
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetColor(Color(255, 255, 255, 0))
        self:SetNoDraw(true)
        self:DrawShadow(false)
        self:SetVisible(false)
    // then these
    /*
    elseif name == "Destroy" then
        self:SetDestroyed(true)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetModel(table.Random(RubblePiles))
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            // freeze
            phys:EnableMotion(false)
        end
        self:DropToFloor()
    */
    elseif name == "Reset" then
        self:SetDestroyed(false)
        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
        self:SetModel(table.Random(RubbleWalls))
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            // freeze
            phys:EnableMotion(false)
        end
        self:DropToFloor()
    end
end
