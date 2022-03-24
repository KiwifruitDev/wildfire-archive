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

ENT.Pos1 = Vector(-3894.03125, -17.529624938965, 696.68255615234)
ENT.Pos2 = Vector(-3999.4113769531, -341.56307983398, 576.03125)

function ENT:Initialize()
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(self.Pos1, self.Pos2)
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    if ent == self then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    // If the entity is our assigned player, give them an HECU gun.
    if ent == self:GetNWEntity("player") then
        local weapon = ent:Give("weapon_hecu")
        ent:SetActiveWeapon(weapon)
        ent:ChatPrint("[Ranked Challenges] You have been given a weapon, shoot the targets!")
        self:Remove()
    end
end
