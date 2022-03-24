ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Intercom Console"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "IntercomUser")
    self:NetworkVar("Bool", 1, "IntercomUsing")
end


ENT.Sound = {
	Start = "vox/doop.wav",
	End = "vox/deeoo.wav",
}

