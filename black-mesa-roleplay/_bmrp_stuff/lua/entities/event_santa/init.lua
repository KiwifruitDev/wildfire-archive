// Wildfire Black Mesa Roleplay
// File description: BMRP server-side Santa Clause entity script
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
    self:SetModel("models/player/christmas/santa_npc.mdl") // Change this!
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:DropToFloor()
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    local ply = activator
    if ply:IsPlayer() then
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", ply:GetName() .. " has found Santa Claus and has been awarded a gift!")
        end
    end
end

function ENT:Think()
    self:SetSequence("stall_idle04")

    self:NextThink(CurTime() + 1)
    return true
end
