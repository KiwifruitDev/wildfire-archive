// Wildfire Black Mesa Roleplay
// File description: BMRP shared ranks script.
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
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

RANKS = {}

// Due to this being a shared file, this stuff only runs on the server.
if SERVER then
    // Function that makes a player become a subjob from a command.
    function RANKS.BecomeSubJob(ply, jobcommand)
        if not IsValid(ply) then return end
        local job, jobindex = DarkRP.getJobByCommand(jobcommand)
        if job == nil then return end
        // Set a network variable for the player because we have a custom check for this.
        ply:SetNWBool("ShouldSwitchSubJob", true)
        timer.Simple(0.1, function()
            if not ply:changeTeam(jobindex, false, true) then
                return //DarkRP.notify(ply, 1, 4, "Something went HORRIBLY wrong when becoming this job. Try again later. Check failed!")
            end
        end)
        timer.Simple(0.2, function()
            ply:SetNWBool("ShouldSwitchSubJob", false)
        end)
    end
    // Function that makes a player become a job's rank if the custom check passes.
    function RANKS.BecomeJobRank(ply, rank)
        if not IsValid(ply) then return end
        local jobtable = ply:getJobTable()
        if not jobtable then
            return DarkRP.notify(ply, 1, 4, "Something went HORRIBLY wrong when becoming this rank. Try again later. No job table!")
        end
        local ranktable = jobtable.ranks[rank]
        if not ranktable then
            return DarkRP.notify(ply, 1, 4, "Something went HORRIBLY wrong when becoming this rank. Try again later. No rank table!")
        end
        if ranktable.customCheck and not ranktable.customCheck(ply) then
            DarkRP.notify(ply, 1, 4, "You are not allowed to become this rank.")
            return
        end
        // make ply:Nick() into a table
        local nick = string.Explode(". ", ply:Nick())
        if #nick == 1 then
            nick[2] = nick[1]
        end
        ply:SetNWBool("IsBecomingRank", true)
        //ply:setRPName(ranktable.prefix .. nick[2])
        ply:SetNWString("RankPrefix", ranktable.prefix)
        ply:SetNWBool("IsBecomingRank", false)
        ply:SetNWInt("BonusCheck", ranktable.bonus)
        ply:SetNWString("Rank", rank)
        DarkRP.notify(ply, 2, 4, "You are now a " .. rank .. " " .. jobtable.name .. ".")
    end
    // This function removes leftover job rank data from the player.
    function RANKS.RemoveJobRankLeftOvers(ply)
        if not IsValid(ply) then return end
        // make ply:Nick() into a table
        local nick = string.Explode(". ", ply:Nick())
        if #nick == 1 then
            nick[2] = nick[1]
        end
        //ply:setRPName(nick[2])
        ply:SetNWString("RankPrefix", "")
        ply:SetNWInt("BonusCheck", 0)
        ply:SetNWString("Rank", "")
    end
    // Does a player meet the criteria to become a rank?
    function RANKS.MeetsCriteria(ply, jobcommand, rank)
        if not IsValid(ply) then return false end
        local job, jobindex = DarkRP.getJobByCommand(jobcommand)
        if job == nil then return false end
        if not job.ranks then return false end
        local ranktable = job.ranks[rank]
        if not ranktable then return false end
        local xp = ply:GetNWInt("XP_"..job.xptype)
        if xp < (job.xp or 0) then
            return false
        end
        if xp < (ranktable.xp or 0) then
            return false
        end
        return true
    end
    // Add a bonus to your salary depending on your rank.
    hook.Add("playerGetSalary", "bmrp_salary", function(ply, amount)
        local bonus = ply:GetNWInt("BonusCheck",0)
        print(bonus)
        if bonus > 0 then
            ply:addMoney(bonus)
            return false, "Payday! $".. amount .." + $"..bonus.." from your rank!"
        end
    end)
    // Remove your job rank when you switch teams.
    hook.Add("PlayerChangedTeam", "bmrp_team", function(ply, oldteam, newteam)
        RANKS.RemoveJobRankLeftOvers(ply)
    end)
end