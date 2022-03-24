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
    
    self:SetModel("models/props_clutter/shopping_cart.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetTrigger(true)
    self:SetSolidFlags(FSOLID_CUSTOMRAYTEST)

    // Tell hammer that this is a valid AMS cart. (not_ is just used to say that the AMS cart isn't ready yet. To be set later.)
    self:SetKeyValue("targetname", "not_sample_cart2")
    self:SetKeyValue("classname", "not_func_pushable")

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use(activator)
    local ply = activator
    if self:GetInsideAMS() == true then
        DarkRP.notify(ply, 1, 4, "The AMS must be off to remove a crystal.")
        return
    end
    if self:GetHasCrystal() == true then
        self:SetHasCrystal(false)

        local ent = self:GetChildren()[1] // we can assume the ams cart will only have 1 child at a time.
        ent:SetParent(nil)
        ent:SetPos(ent:GetPos() + Vector(0, 0, 40)) // pop the crystal out of the cart
        hook.Run("SystemMessage", ply, "", "You removed the crystal from the cart.")

    end
end

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if not IsValid(self) then return end
    if self:GetDebounce() then return end
    if ent:IsPlayer() then return end
    if ent:GetClass() == "xen_crystal" then
        if ent:GetClean() ~= true then return end
        if ent:GetAMSTested() ~= false then return end
        if self:GetHasCrystal() == false then
            self:SetHasCrystal(true)
            -- print to all players in a range of 100
            for _, ply in pairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) <= 100 then
                    hook.Run("SystemMessage", ply, "", "You have attached a " .. ent:GetCrystalType() .. " crystal to the cart.")
                end
            end
            -- we'll parent this so let's set local vectors and angles as an offset and convert them to world.
            ent:SetParent(self)
            ent:SetLocalPos(Vector(42.488761901855, -1.3483346700668, 26.466205596924))
            ent:SetLocalAngles(Angle(45, -90, 0))

            self:SetDebounce(true)
            timer.Simple(5, function()
                if not IsValid(self) then return end
                self:SetDebounce(false)
            end)

        end
    end 
end

function ENT:Think()
    // Rather than constantly setting these values, we can just check If it has a crystal and set the values accordingly.
    if self:GetHasCrystal() ~= false then
        self:SetKeyValue("targetname", "sample_cart2")
        self:SetKeyValue("classname", "func_pushable")
    else
        self:SetKeyValue("targetname", "not_sample_cart2")
        self:SetKeyValue("classname", "not_func_pushable")
    end
end
