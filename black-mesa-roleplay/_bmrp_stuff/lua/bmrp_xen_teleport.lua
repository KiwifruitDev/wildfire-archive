local function NameMap(ident)
	if isnumber(ident) then return ents.GetMapCreatedEntity(ident) end
	local tab = ents.FindByName(ident)
	if #tab == 0 then return false end
	return tab[1]
end

local ENT = {}
ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.Enabled = true

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
end

function ENT:KeyValue(key, val)
	if key == "target" then
		self.Target = val
	elseif key == "targetname" then
		self:SetName(val)
	elseif key == "StartDisabled" and tobool(val) then
		self.Enabled = false
	end
end

function ENT:Teleport(ent, pos, ang)
	if ent:CreatedByMap() or ent:IsNPC() then return end
	pos, ang = pos or self.Target and self.Target[1] or Vector(0, 0, 0), ang or self.Target and self.Target[2] or Angle(0, 0, 0)
	if ent:IsPlayer() then
		if ent:HasWeapon("weapon_handcuffed") then return end
		ent:SetPos(pos)
		ent:SetEyeAngles(ang)
		ent:SetVelocity(-ent:GetVelocity())
		ent:ScreenFade(SCREENFADE.IN, Color(0, 255, 0), 1, 0)

		for _,c in pairs(ents.FindByClass("weapon_handcuffed")) do
			if IsValid(c:GetOwner()) and c.GetRopeLength and c.GetKidnapper and c:GetRopeLength() > 0 and c:GetKidnapper() == ent then
				local own = c:GetOwner()
				local npos = DarkRP.findEmptyPos(pos, {own}, 600, 30, Vector(16, 16, 64))
				own:SetPos(npos)
				own:SetEyeAngles(ang)
				own:SetVelocity(-own:GetVelocity())
				own:ScreenFade(SCREENFADE.IN, Color(0, 255, 0), 1, 0)
				break
			end
		end
	else
		local boffset = Vector(0, 0, math.abs(ent:OBBMins().z) + 20)
		local constraints = constraint.GetAllConstrainedEntities(ent)
		for k, v in pairs(constraints) do
			if ent == v then continue end
			local relpos = ent:WorldToLocal(v:GetPos())
			v:SetPos(LocalToWorld(relpos, ent:GetAngles(), pos + boffset, ent:GetAngles()))
			DropEntityIfHeld(v)
		end

		ent:SetPos(pos + boffset)
		ent:SetVelocity(Vector(0, 0, 0))
		DropEntityIfHeld(ent)
	end

	self:EmitSound("debris/beamstart7.wav", 75, 100, .1)
	EmitSound("debris/beamstart7.wav", ent:GetPos(), ent:EntIndex(), nil, .1)
end

function ENT:AcceptInput(key)
	key = key:lower()
	if key == "enable" then
		self.Enabled = true
	elseif key == "disable" then
		self.Enabled = false
	end
end

function ENT:Touch(ent)
	if ent:CreatedByMap() or ent:IsNPC() or not self.Enabled or not self.Target then return end
	if isstring(self.Target) then
		local target = NameMap(self.Target)
		if not IsValid(target) then self.Target = false return end
		self.Target = {target:GetPos(), target:GetAngles(), target}
	end
	self:Teleport(ent)
end

return ENT