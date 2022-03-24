// Wildfire Black Mesa Roleplay
// File description: BMRP server-side flood valve entity script
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
    
    self:SetModel("models/props_blackmesa/bms_valvewheel.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use(activator)
    if GetGlobalBool("flood", false) == false then
        self:SetUseType(SIMPLE_USE)
        hook.Run("SystemMessage", activator, "", "You can't use this right now!")
        return
    elseif GetGlobalBool("completelyflooded", false) == false then
        self:SetUseType(SIMPLE_USE)
        hook.Run("SystemMessage", activator, "", "The water pressure has not fully stabilized. Pumps cannot activate at this time!")
        return
    else
        self:SetUseType(CONTINUOUS_USE)
    end
    if not IsValid(activator) then return end
    if not activator:IsPlayer() then return end
    local ang = self:GetAngles()
    //activator:ChatPrint(ang.p)
    ang:RotateAroundAxis( Vector(1, 0, 0), 1 )
    self:SetAngles(ang)
    self.timer = self.timer + 1
    return
end

local floodspeed = 100
local flooddistance = 1922

function flood_stop()
    local allents = ents.FindByClass("func_water_analog")
    for k,v in pairs(allents) do
        v:Fire("Close") // "Close" the flood, aka lower the water level
        v:SetKeyValue("speed", ""..floodspeed) // Fast drainage speed
    end
    for k,v in pairs( player.GetAll() ) do
        hook.Run("SystemMessage", v, "", "Black Mesa Reserve water drainage pumps activated, water drain imminent.")
        v:SendLua("surface.PlaySound(\"ambient/machines/floodgate_stop1.wav\")")
    end
    SetGlobalBool("flood", false)
    SetGlobalBool("completelyflooded", false)
    timer.Simple( 60, function() 
        local traindoors = {
            "mountain1",
            "ladderdoor",
        }
        for k1,v1 in pairs( traindoors ) do // Close some doors
            for k,v in pairs( ents.FindByName(v1) ) do
                v:Fire("Close")
            end
        end
    end )
    // Dectivate a lockdown If water is in the facility
    unredalert()

    // Delete the flood water
    timer.Simple( flooddistance/floodspeed, function() 
        for k,v in pairs(ents.FindByClass("func_water_analog")) do
            v:Remove()
        end
    end )
end

concommand.Add("noflood", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    flood_stop()
end)

function ENT:Think()
    local ang = self:GetAngles()
    if not self.down == true then 
        self:SetAngles(Angle(0, ang.y, ang.r))
        self.down = true
        return
    end
    if not self.timer then
        self.timer = 0
    end
    if self.timer >= 100 then
        if GetGlobalBool("completelyflooded", false) == true then
            flood_stop()
        end
        self.timer = 0
    elseif self.timer > 0 then
        ang:RotateAroundAxis( Vector(1, 0, 0), -1)
        self:SetAngles(ang)
    end
end