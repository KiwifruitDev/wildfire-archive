// Wildfire Black Mesa Roleplay
// File description: BMRP server-side crystal washer entity script
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
    
    self:SetModel("models/props_watertreatment/watertreatment_tank_003.mdl") 
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
    self.Outputs = WireLib.CreateSpecialOutputs(self, {"Washing", "Broken"}, {"NORMAL", "NORMAL"})
end

local washingtime = 15
local brokenchance = 5

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if not IsValid(self) then return end
    if ent:IsPlayer() then return end
    if self:GetBroken() ~= false then return end
    if ent:GetClass() == "xen_crystal" then
        if self:GetDebounce() == false then
            self:SetDebounce(true)
            timer.Simple(2, function()
                if not IsValid(self) then return end
                self:SetDebounce(false)
            end)
        end
        if self:GetHasCrystal() == true then return end // If it has a crystal inside of it, do nothing.
        if ent:GetClean() ~= false then return end // If the crystal is clean, do nothing.
        if self:GetBroken() == true then return end // If the machihne is broken, do nothing.
        if ent:GetCrystalScanned() ~= false then return end // If the crystal is scanned, do nothing.
        if self:GetHasCrystal() ~= true then
            ent:ForcePlayerDrop()
            self:SetHasCrystal(true)
            self:SetIsWashing(true)
            if WireLib then
                WireLib.TriggerOutput(self, "Washing", 1)
            end
            for _, ply in pairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) <= 100 then
                    hook.Run("SystemMessage", ply, "", "You placed the crystal into the washer and fired it up, please wait...")
                end
            end
            local oldpos = ent:GetPos()
            local oldang = ent:GetAngles()
            ent:SetPos(Vector(0,0,0))
            ent:SetAngles(Angle(0,0,0))
            self:SetProgress(0)
            -- linear progress bar (self:setprogress) using washingtime
            timer.Create("CleaningCrystal_"..self:EntIndex(), washingtime/100, 100, function()
                if not IsValid(self) then return end
                if not IsValid(ent) then return end
                if self:GetProgress() >= 1 then
                    self:SetProgress(1)
                else
                    -- add progress (enough to be 1 by the end of the timer)
                    self:SetProgress(self:GetProgress() + 1/100)
                end
            end)
            timer.Simple(washingtime, function()
                if not IsValid(self) then return end
                self:StopSound("ambient/water/water_splash1.wav")
                self:StopSound("ambient/water/water_splash2.wav")
                self:StopSound("ambient/water/water_splash3.wav")
                if math.random(1, 100) <= brokenchance then
                    self:SetBroken(true)
                    self:SetIsWashing(false)
                    self:SetHasCrystal(false)
                    if WireLib then
                        WireLib.TriggerOutput(self, "Washing", 0)
                        WireLib.TriggerOutput(self, "Broken", 1)
                    end
                    self:SetProgress(0)
                    for _, ply in pairs(player.GetAll()) do
                        if ply:GetPos():Distance(self:GetPos()) <= 100 then
                            hook.Run("SystemMessage", ply, "", "The washer has broken :)")
                        end
                    end
                    self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
                    self:Ignite(30)
                    self:SetSkin(1)
                    ent:Remove()
                    
                    local explosion = ents.Create("env_explosion")
                    explosion:SetKeyValue("iMagnitude", "3")
                    explosion:SetKeyValue("rendermode", "5")
                    explosion:Fire("Explode")
                    explosion:SetPos(self:GetPos())
                    return
                end
                -- done washing
                if WireLib then
                    WireLib.TriggerOutput(self, "Washing", 0)
                end
                self:EmitSound("buttons/button1.wav")
                self:SetHasCrystal(false)
                self:SetIsWashing(false)
                ent:SetPos(oldpos)
                ent:SetAngles(oldang)
                ent:Clean()
                self:SetProgress(0)
                timer.Destroy("CleaningCrystal_"..self:EntIndex())
            end)
        end
    end 
end 

function ENT:Think()
    if self:GetIsWashing() == true then
        self:EmitSound("ambient/water/water_splash"..math.random(1,3)..".wav")
        local phys = self:GetPhysicsObject()
        phys:Wake()
        -- unfreeze
        phys:EnableMotion(true)
        phys:SetVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
    end
    if self:GetBroken() == true then
        self:SetSkin(1)
    else
        self:SetSkin(0)
    end
    self:NextThink(CurTime() + 1)
    return true
end