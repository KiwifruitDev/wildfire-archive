local function NameMap(ident)
	if isnumber(ident) then return ents.GetMapCreatedEntity(ident) end
	local tab = ents.FindByName(ident)
	if #tab == 0 then return false end
	return tab[1]
end

local function FNameMap(ident, func)
	local ent = NameMap(ident)
	if not ent then return false end
	func(ent)
	return ent
end

local ENT = {}
ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:Initialize()
	if CLIENT then return end
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
	self.Target = self.Target or ""
	self.Ents = {}
end

function ENT:KeyValue(key, value)
	if key == "targetname" then
		timer.Simple(0.1, function()
			self:SetName(value)
		end)
	elseif key == "target" then
		self.Target = value
	elseif key == "landmark" then
		self.Landmark = value
	elseif key == "OnEndTouch" then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(input)
	if input:lower() == "teleport" then
		self.Enabled = true
		FNameMap(self.Target or "", function(target)
			for ent, _ in pairs(self.Ents) do
				local lpos, lang = WorldToLocal(ent:GetPos(), ent:IsPlayer() and ent:EyeAngles() or ent:GetAngles(), self:WorldSpaceCenter(), (NameMap(self.Landmark) or self):GetAngles())
				local wpos, wangle = LocalToWorld(lpos, lang, target:WorldSpaceCenter(), (NameMap(target.Landmark) or target):GetAngles())
				ent:SetPos(wpos)
				if ent:IsPlayer() then
					ent:SetEyeAngles(wangle)
				else
					ent:SetAngles(wangle)
				end
			end
		end)
	end
end

function ENT:StartTouch(ent)
	if ent:CreatedByMap() then return end
	self.Ents[ent] = true
end

function ENT:EndTouch(ent)
	if ent:CreatedByMap() then return end
	self.Ents[ent] = nil
end

return ENT