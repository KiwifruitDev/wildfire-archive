// Wildfire Black Mesa Roleplay
// File description: BMRP client-side repair box script
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

-- font for the text
surface.CreateFont("BMRP_RepairBox_Text", {
    font = "Roboto",
    size = 750,
    weight = 500,
    antialias = true
})

function ENT:Draw()

    self:DrawModel()
	local text = "Spare Parts"
	local offset = Vector(0, 0, 20)
	local origin = self:GetPos()
	if LocalPlayer():GetPos():DistToSqr(origin) > (150*150) then return end
	local pos = origin + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)

	cam.Start3D2D(pos, ang, 0.05)
		surface.SetFont("XenCrystalText")
		local w, h = surface.GetTextSize(text)
        draw.SimpleText(text, "XenCrystalText", 4, 4, Color(0,0,0), 1, 1)
        draw.SimpleText(text, "XenCrystalText", 0, 0, Color(255,255,255), 1, 1)
	cam.End3D2D()
end