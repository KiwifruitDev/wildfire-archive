// Wildfire Black Mesa RP
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

// Every file needs this :)
include("autorun/sh_bmrp.lua")

function ENT:Initialize()
    
    self:SetModel("models/scenery/furniture/coffeetable1/vestbl.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetRenderMode(1)
    self.VestActive = true

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use(ply)
    local ent = self
    if self.VestActive == false then return end
    if ply:CategoryCheck() == "security" then
        if ply:Armor() >= 80 then
            hook.Run("SystemMessage", ply, "", "You can't use this! Your vest is already in good condition.")
        else
            ply:SetArmor( 100 )
            print(ply:GetModel())
            if ply:GetModel() == "models/humans/pyri_pm/guard_female_pm_heavy.mdl" or ply:GetModel() == "models/humans/pyri_pm/guard_female_pm_medic.mdl" or ply:GetModel() == "models/humans/pyri_pm/guard_female_pm.mdl" then //hotfix for women
                ply:SetBodygroup(5, 2)
            else
                ply:SetBodygroup(3, 2)
            end
            timer.Simple(20, function()
                ent:EmitSound("foley/eli_sit_on_couch.wav")
                self:SetColor(Color(255, 255, 255, 255)) // transparent basically
                self:SetNotSolid(false)
                self.VestActive = true
                self:SetNoDraw(false)
            end)
            ply:EmitSound("foley/alyx_hug_eli.wav")
            self:SetColor(Color(0, 0, 0, 0)) // transparent basically
            self:SetNotSolid(true)
            self.VestActive = false
            self:SetNoDraw(true)
        end
    end
end