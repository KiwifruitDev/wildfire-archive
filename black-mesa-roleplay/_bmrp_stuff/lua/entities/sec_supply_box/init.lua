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

// Every file needs this :)
include("autorun/sh_bmrp.lua")

function ENT:Initialize()
    
    self:SetModel("models/props/CS_militia/footlocker01_closed.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

local weapons = {
    "door_ram",
    "weapon_cuff_elastic",
    "arrest_stick",
    "unarrest_stick",
    "weaponchecker",
    "swep_radiodevice",
    "weapon_bmrpstunstick",
    "riot_shield"
}

function ENT:Use(activator)
    local ply = activator
    if ply:CategoryCheck() ~= "security" then return end
    if ply:GetNWBool("SecAlreadyUsed") == true then return end
    ply:SetNWBool("SecAlreadyUsed", true)
    hook.Run("SystemMessage", ply, "", "Here, take your supplies. Security may retrieve their firearms from the Security Locker.")
    self:EmitSound("items/ammo_pickup.wav")
    for k,v in pairs(weapons) do
        ply:Give(v)
    end
    if team.GetName(ply:Team()) == "Security Medic" then
        ply:Give("rust_syringe")
        ply:Give("fas2_ifak")
    end
end

hook.Add( "PlayerDeath", "ResetSecurityCrate", function(ply)
	ply:SetNWBool("SecAlreadyUsed", false)
end )

hook.Add( "OnPlayerChangedTeam", "ResetSecurityCrate2", function(ply)
	ply:SetNWBool("SecAlreadyUsed", false)
end )