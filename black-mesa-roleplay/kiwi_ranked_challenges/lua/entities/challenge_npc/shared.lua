// Wildfire Ranked Challenges
// File description: Challenge NPC SHARED initialization script.
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
AddCSLuaFile()

ENT.Base			= "base_ai"
ENT.Type 			= "ai"
ENT.Spawnable		= true
ENT.PrintName		= "Challenge NPC"
ENT.Author          = "Wildfire Servers"
ENT.Category        = "Wildfire BMRP"
ENT.AdminOnly		= true
ENT.Editable = true

function ENT:Initialize()
	self:SetSequence("pose_standing_04")
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ChallengeType", {KeyName = "challengetype", Edit = {type = "Generic", order = 0, waitforenter = true}})
	self:NetworkVar("String", 1, "NPCModel", {KeyName = "npcmodel", Edit = {type = "Generic", order = 0, waitforenter = true}})
    if SERVER then
		self:SetChallengeType("XenRace")
		self:SetNPCModel("")
	end
end
