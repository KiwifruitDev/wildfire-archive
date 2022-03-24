// Wildfire Ranked Challenges
// File description: Challenge NPC SV initialization script.
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
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local models = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
}

local chosenmodel = models[math.random(1, #models)]
local oldchosenmodel = chosenmodel

function ENT:Initialize()
	self:SetModel(chosenmodel)
	self:SetSolid(SOLID_BBOX)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE+CAP_TURN_HEAD)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(128)
	self:SetBloodColor(DONT_BLEED)
end

function ENT:Think()
	local newmodel = self:GetNPCModel()
	if newmodel ~= oldchosenmodel then
		chosenmodel = newmodel
		oldchosenmodel = newmodel
		self:SetModel(chosenmodel)
	end
	self:SetSequence("pose_standing_04")
	--[[
	for p, ply in ipairs(player.GetAll()) do
		if(ply:EyePos():Distance(self:EyePos()) <= 256) then
			self:SetEyeTarget(ply:EyePos())
			break
		end
	end
	]]--
end

function ENT:Use(activator, caller, useType, value)
	activator:EmitSound("common/wpn_select.wav")
	net.Start("OpenRankedChallenges")
	net.WriteString(self:GetChallengeType())
	net.Send(activator)
end
