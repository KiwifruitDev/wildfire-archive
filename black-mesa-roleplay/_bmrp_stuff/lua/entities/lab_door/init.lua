// Wildfire Black Mesa Roleplay
// File description: BMRP server-side door entity script
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

ENT.DoorOpen = Sound("doors/door_metal_rusty_move1.wav")
ENT.DoorClose = Sound("doors/door_metal_thin_close2.wav")

function ENT:Initialize()
	self:SetModel("models/halflifemesh/halflife_door.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMaterial("gmod_silent")
		phys:Wake()
	end
end

function ENT:Use(activator, caller)
	self:TriggerOutput("OnUse", activator)

	if IsValid(activator) && !activator.Teleporting then
		/*
		if activator:IsPlayer() then
			if self:GetPos() == Vector(-4992.9760742188, -1404.5350341797, 570.44494628906) then // this is horrible code and I should be ashamed of myself
				net.Start("StartNodraw")
				net.Send(activator)
			elseif self:GetPos() == Vector(-6244.951171875, -433.46130371094, 848.43048095703) then
				net.Start("EndNodraw")
				net.Send(activator)
			end
		end
		*/
		self:StartLoading( activator )

		local sequence = self:LookupSequence("open")

		if (self:GetSequence() != sequence ) then
			self:ResetSequence(sequence)
			self:SetPlaybackRate(2.5)

			local door = self:GetLinkedDoor()
			if IsValid( door ) then
				door:ResetSequence( sequence )
				door:SetPlaybackRate( 2.5 )
			end

			self:EmitSound( self.DoorOpen )
		end
	end
end

function ENT:GetLinkedDoor()
	if self:GetTeleportEnt() then
		local near = ents.FindInSphere( self:GetTeleportEnt(), 50 )
		for _, v in pairs( near ) do
			if IsValid( v ) && v:GetClass() == self:GetClass() then
				return v
			end
		end
	end

	return nil
end

function ENT:GetTeleportEntity()
	return self:GetTeleportEnt(), self:GetTeleportEnt2()
end

function ENT:StartLoading( ply )
	ply.Teleporting = true
	ply:Freeze( true )
	ply:ScreenFade(SCREENFADE.OUT, Color(0,0,0), self.FadeTime, self.DelayTime+1)
	timer.Simple( self.FadeTime + self.DelayTime, function()
		if IsValid( ply ) then
			//Teleport the player
			ply.Teleporting = false
			ply:Freeze( false )
			ply:EmitSound(self.DoorClose)

			local ent1, ent2 = self:GetTeleportEntity()
			if ent1 and ent2 then
				ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), self.FadeTime, 1)
				ply:SetPos( ent1 )
				ply:SetEyeAngles( ent2 )
			end
		end

	end )
	self.TeleportAt = CurTime() + self.FadeTime + self.DelayTime
	self.ShouldTeleport = true
end

function ENT:Think()
	if self.ShouldTeleport && CurTime() > self.TeleportAt then
		//shut the frickity front door
		local sequence = self:LookupSequence("idle")
		self:SetSequence(sequence)

		local door = self:GetLinkedDoor()
		if IsValid( door ) then
			door:SetSequence( sequence )
		end

		self:EmitSound( self.DoorClose )

		self.ShouldTeleport = false
		self.TeleportPly = nil
	end

	self:NextThink(CurTime())
	return true
end



function ENT:KeyValue(key, value)
	local isEmpty = !value || string.len(value) <= 0

	if key == "OnTeleport" || key == "OnUnlock" || key == "OnUse" then
		self:StoreOutput(key, value)
	end

	if !isEmpty then
		if key == "teleportpos1" then
			self:SetTeleportEnt2(value) 
		elseif key == "teleportangle" then
			self:SetTeleportEnt2(value) 
		elseif key == "opendoorsound" then
			self.DoorOpen = Sound( value )
		elseif key == "closedoorsound" then
			self.DoorClose = Sound( value )
		elseif key == "model" then
			self:SetModel(Model(value))
		end
	end
end
