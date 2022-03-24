// Wildfire Ranked Challenges
// File description: Script to initialize the HECU gun trigger.
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

include("ranked_challenges/ranked_challenges_config.lua")

ENT.Type = "brush"
ENT.BaseClass = "base_brush"

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    if ent:GetNWString("Challenge","") ~= "" then
        local challenge = KIWI.ChallengeList[ent:GetNWString("Challenge","")]
        if not challenge then return end
        if challenge.finishedcallback ~= nil then
            challenge.finishedcallback(ent)
        end
        local time = math.Round(ent:GetNWFloat("ChallengeTimer"),2)
        local personalbest = math.Round(ent:GetNWFloat("ChallengePreviousBest", 0),2)
        local prefix = ""
        if time < personalbest then
            personalbest = time
            prefix = "New personal best! "
        end
        ent:ChatPrint("[Ranked Challenges] "..prefix.."You have completed the challenge in "..time.." seconds! "..(personalbest > 0 and "Your personal best is "..personalbest.."!" or ""))
		hook.Run("StopChallengeForPlayer",ent)
        /*
        ent:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.5, 1 )
        timer.Simple(0.5, function()
            ent:SetPos(ent:GetNWVector("OriginalPosition"))
            ent:SetAngles(ent:GetNWAngle("OriginalAngle"))
        end)
        timer.Simple(1.5, function()
            ent:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 0 )
        end)
        */
    end
end
