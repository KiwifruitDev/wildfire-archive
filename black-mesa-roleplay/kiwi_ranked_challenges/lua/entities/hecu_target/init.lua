// Wildfire Ranked Challenges
// File description: Script that takes damage so you're verified to shoot the target range.
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

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate05x1.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    // invisible
    self:DrawShadow(false)
    self:SetNoDraw(true)
    //self:SetNotSolid(true)
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetColor(Color(255, 255, 255, 0))
end

// take damage
function ENT:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() then
        local wep = attacker:GetActiveWeapon()
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "weapon_hecu" then return end
        if self:GetNWEntity("player") == attacker then
            attacker:SetNWInt("targets", attacker:GetNWInt("targets") + 1)
            if attacker:GetNWInt("targets") == 3 then
                attacker:SetNWInt("targets", 0)
                local challenge = KIWI.ChallengeList["HecuCourse"]
                if challenge.finishedcallback ~= nil then
                    challenge.finishedcallback(attacker)
                end
                local time = math.Round(attacker:GetNWFloat("ChallengeTimer"),2)
                local personalbest = math.Round(attacker:GetNWFloat("ChallengePreviousBest", 0),2)
                local prefix = ""
                if time < personalbest then
                    personalbest = time
                    prefix = "New personal best! "
                end
                attacker:ChatPrint("[Ranked Challenges] "..prefix.."You have completed the challenge in "..time.." seconds! "..(personalbest > 0 and "Your personal best is "..personalbest.."!" or ""))
                hook.Run("StopChallengeForPlayer", attacker)
                attacker:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.5, 1 )
                timer.Simple(0.5, function()
                    attacker:SetPos(attacker:GetNWVector("OriginalPosition"))
                    attacker:SetAngles(attacker:GetNWAngle("OriginalAngle"))
                    attacker:StripWeapon("weapon_hecu")
                end)
                timer.Simple(1.5, function()
                    attacker:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 0 )
                end)
            end
            self:Remove()
        end
    end
end
