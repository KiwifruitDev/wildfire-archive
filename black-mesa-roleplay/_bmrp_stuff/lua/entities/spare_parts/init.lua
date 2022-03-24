// Wildfire Black Mesa Roleplay
// File description: BMRP server-side repair box script
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
    
    self:SetModel("models/props_junk/cardboard_box001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetTrigger(true)
    //self:SetSolidFlags(FSOLID_CUSTOMRAYTEST) 
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if not IsValid(self) then return end
    if ent:IsPlayer() then return end
    if ent.SetBroken then
        -- get cppi owner
        local ply = self:CPPIGetOwner()
        if ent:GetBroken() then
            if WireLib then
                WireLib.TriggerOutput(ent, "Broken", 0)
            end
            ent:SetBroken(false)
            ent:Extinguish()
            ent:EmitSound("physics/cardboard/cardboard_box_impact_soft" .. math.random(1, 3) .. ".wav")
            -- add darkrp money
            if ply:IsValid() then
                ply:addMoney(600)
                DarkRP.notify(ply, 0, 4, "You have received $600 for fixing broken lab equipment.")
            end
            self:Remove()
        end
    end
end
