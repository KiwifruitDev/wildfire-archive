// Wildfire Black Mesa Roleplay
// File description: BMRP server-side power box entity script
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
    
    self:SetModel("models/props_equipment/powergenerator01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetSkin(1) // Power Box On
    self:SetUseType(SIMPLE_USE)
    //self:SetSkin(0) // Power Box Off

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Think()
    if self:GetActivated() then
        self:SetSkin(1)
    else
        self:SetSkin(0)
    end
end

function ENT:Use(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if GetGlobalBool("blackoutpp", false) == true then
        if self:GetActivated() then
            hook.Run("SystemMessage", ply, "", "This auxiliary generator is already activated.")
            return
        end
        if math.random(1, 100) <= 10 then
            if not IsValid(ply) then return end
            if not ply:Alive() then return end
            hook.Run("SystemMessage", ply, "", "You plugged the wire into the wrong place and are now suffering the consequences.")
            local explosion = ents.Create("env_explosion")
            explosion:SetKeyValue("iMagnitude", "0")
            explosion:SetKeyValue("rendermode", "5")
            explosion:Fire("Explode")
            explosion:SetPos(ply:GetPos())
            ply:SetPos(ply:GetPos() + Vector(0, 0, 1))
            ply:SetVelocity(Vector(0, 0, 1000))
            timer.Simple(0.001, function()
                if not IsValid(ply) then return end
                if not ply:Alive() then return end
                ply:Kill()
            end)
            return
        end
        self:SetActivated(true)
        SetGlobalInt("bmrppower", GetGlobalInt("bmrppower", 0) + 1)
        if GetGlobalInt("bmrppower", 0) >= self:GetMaxNeeded() then
            SetGlobalInt("bmrppower", 0)
            SetGlobalBool("blackoutpp", false)
            for k,v in pairs( player.GetAll() ) do
                hook.Run("SystemMessage", v, "", "Black Mesa facility auxiliary generators engaged. Power restored in sectors A-G.")
                v:SendLua("surface.PlaySound(\"ambient/machines/spinup.wav\")")
            end
            LightsOn()
            unredalert()
        else
            for k,v in pairs( player.GetAll() ) do
                hook.Run("SystemMessage", v, "", "A facility auxiliary generator has been activated. Power boxes remaining: " .. GetGlobalInt("bmrppower", 0) .. "/" .. self:GetMaxNeeded())
                v:SendLua("surface.PlaySound(\"ambient/machines/spinup.wav\")")
            end
        end
    end
end