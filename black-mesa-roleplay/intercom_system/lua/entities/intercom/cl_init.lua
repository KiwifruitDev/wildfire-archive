include("shared.lua")

surface.CreateFont("BMRP_IntercomBox_Text", {
    font = "Roboto",
    size = 100,
    weight = 500,
    antialias = true
})

local offset = Vector(0, 0, 125)

function ENT:Draw()
    self:DrawModel()
    
    cam.Start3D2D(self:GetPos() + offset, Angle(0, Angle(0, (LocalPlayer():GetPos() - self:GetPos()):Angle().y + 90, 90).y, 90), 0.1)

	    if self:GetIntercomUsing() then
            draw.SimpleText("Intercom", "BMRP_IntercomBox_Text", 0, 75, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	        draw.SimpleText("Communications Live", "BMRP_IntercomBox_Text", 0, 150, Color(255, 0, 0), TEXT_ALIGN_CENTER)
	    else
            draw.SimpleText("Intercom", "BMRP_IntercomBox_Text", 0, 150, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end

    cam.End3D2D()
end