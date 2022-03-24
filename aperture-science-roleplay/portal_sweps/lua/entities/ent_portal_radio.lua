AddCSLuaFile( )
DEFINE_BASECLASS("base_anim")

ENT.PrintName		= "Радио"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction(ply, trace, className)
	if not trace.Hit then return end
	
	local ent = ents.Create(className)
	if not IsValid(ent) then return end
	ent:SetPos(trace.HitPos + trace.HitNormal * 10)
	ent:SetAngles(ply:GetAngles() + Angle(0, 180, 0))
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	
	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Enable")
end

function ENT:Initialize()
	if CLIENT then return end
	
	self:SetModel("models/aperture/radio_reference.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self.Radio_Counter = 0
	
	return true
end

-- no more client side
if CLIENT then return end

local radiosounds = {
	"music/looping_radio_mix.wav",
	"wildfire/portalrp/radios/jarrett_heather_still_alive.wav",
	"wildfire/portalrp/radios/portal_gte.wav",
	"wildfire/portalrp/radios/razor_red_noise_still_alive_remix.wav",
	"wildfire/portalrp/radios/taveric_still_alive_remix.wav"
}

local radiosoundchances = {
    [radiosounds[1]] = 4,
    [radiosounds[2]] = 2,
    [radiosounds[3]] = 1,
   	[radiosounds[4]] = 3,
}

function getRandomItem()
    local sum = 0
	for _, chance in pairs(radiosoundchances) do
		sum = sum + chance
	end

	local rand = math.random(sum)
	local winningKey
	for key, chance in pairs(radiosoundchances) do
		winningKey = key
		rand = rand - chance
		if rand <= 0 then break end
	end

	return winningKey
end

function ENT:Use(activator, caller)
	if IsValid(caller) and caller:IsPlayer() then
		if timer.Exists("TA_Radio_Block"..self:EntIndex()) then return end
		timer.Create( "TA_Radio_Block"..self:EntIndex(), 1, 1, function() end )
		self:SetEnable(not self:GetEnable())
		
		if self:GetEnable() then
			/*
			if math.random(1, 20 - self.Radio_Counter) == 1 then
				self:EmitSound( "TA:RadioStrangeNoice" )
				self.Radio_Counter = 0
			else
				self:EmitSound( "TA:RadioLoop" )
			end
			*/
			
			// random chance
			local item = getRandomItem()
			self:EmitSound( item )	
			
			self.Radio_Counter = self.Radio_Counter + 1
		else
			for k, v in pairs(radiosounds) do
				self:StopSound(v)
			end
		end
	end
end

function ENT:OnRemove()
	timer.Remove("TA_Radio_Block"..self:EntIndex())
	for k, v in pairs(radiosounds) do
		self:StopSound(v)
	end
end
