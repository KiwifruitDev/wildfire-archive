// Wildfire Black Mesa Roleplay
// File description: BMRP server-side sign in terminal entity script
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

// Every file needs this :)
include("autorun/sh_bmrp.lua")

include("bmrp_ranks.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("BMRP_SignInGUI")
util.AddNetworkString("bms_signin")
util.AddNetworkString("bms_canpress")

function ENT:Initialize()
    
    self:SetModel("models/props_blackmesa/wallcomputer.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use( activator )
    if not IsValid(activator) then return end
    local jobtable = activator:getJobTable()
    local subjobs = jobtable.subjobs
    if not subjobs then subjobs = {} end
    net.Start("BMRP_SignInGUI")
    net.WriteUInt(#subjobs+1, 8)
    net.WriteString(jobtable.command)
    SetupJobTable(jobtable, true)
    for k, v in pairs(subjobs) do
        if v == jobtable.command then continue end
        local job, jobindex = DarkRP.getJobByCommand(v)
        net.WriteString(v)
        SetupJobTable(job, true)
    end
    net.Send(activator)
end

function SetupJobTable(jobtable, isSubJob)
    net.WriteString(jobtable.name)
    net.WriteString(jobtable.model[1])
    net.WriteString(jobtable.description)
    net.WriteInt(jobtable.xp or 0, 32)
    local ranks = jobtable.ranks
    if not ranks then ranks = {} end
    // count ranks
    local count = 0
    for k, v in pairs(ranks) do
        count = count + 1
    end
    if isSubJob then
        net.WriteUInt(count, 8)
        for k, v in pairs(ranks) do
            net.WriteString(k)
            net.WriteString(v.prefix)
            net.WriteInt(v.bonus, 32)
            net.WriteInt(v.xp or 0, 32)
        end
    else
        net.WriteUInt(0, 8)
    end
end

net.Receive("bms_signin", function(len, ply)
    local subjobcommand = net.ReadString()
    local rankname = net.ReadString()
    if not RANKS.MeetsCriteria(ply, subjobcommand, rankname) then
        DarkRP.notify(ply, 1, 4, "You do not meet the requirements to sign into this job.")
        return
    end
    RANKS.BecomeSubJob(ply, subjobcommand)
    timer.Simple(0.1, function()
        RANKS.BecomeJobRank(ply, rankname)
    end)
end)

net.Receive("bms_canpress", function(len, ply)
    local subjobcommand = net.ReadString()
    local rankname = net.ReadString()
    net.WriteBool(RANKS.MeetsCriteria(ply, subjobcommand, rankname))
end)

