local function RandomName(ident)
	local tab = ents.FindByName(ident)
	if #tab == 0 then return false end
	return table.Random(tab)
end

local ENT = {}
ENT.Type = "brush"
ENT.Base = "bmrp_xen_teleport"

function ENT:KeyValue(key, val)
	if key == "type" then
		self.PortalType = tonumber(val) or 1
	end
end

function ENT:AcceptInput(key)
end

function ENT:Touch(ent)
end

function ENT:StartTouch(ent)
	if ent:CreatedByMap() then return end

	if (self.PortalType == 2 or self.PortalType == 3) then

		local sdest
		if self.PortalType == 2 then
			sdest = "bmrf_randomxen"
		else
			sdest = "bmrf_randomlab"
		end
		if IsValid(self.RandDest) and self.RandDestTime > CurTime() then
			self:Teleport(ent, self.RandDest:GetPos(), self.RandDest:GetAngles())
			return
		end

		self.RandDest = RandomName(sdest)
		self.RandDestTime = CurTime() + 3
		if not IsValid(self.RandDest) then return end

		local pos = self.RandDest:GetPos()
		self:Teleport(ent, pos, self.RandDest:GetAngles())

		if ent:IsPlayer() then
			ent:SetGravity(1)
		end
	elseif self.PortalType == 1 then
		if ent:IsPlayer() then ent:SetGravity(1) end

		local dest = RandomName("bmrf_onearth")
		if not dest then return end

		self:Teleport(ent, dest:GetPos(), dest:GetAngles())
		return
	else
		return
	end
end

return ENT