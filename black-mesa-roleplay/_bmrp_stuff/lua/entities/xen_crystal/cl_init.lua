// Wildfire Black Mesa Roleplay
// File description: BMRP client-side AMS cart entity script
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

surface.CreateFont("XenCrystalText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(30),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("RadioactiveText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(30),
	weight = 500,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
})

function ENT:Draw()
	self:DrawModel()
	-- change color dynamically like a rainbow if the CrystalEffect is "Rainbow"
	if self:GetCrystalEffect() == "Rainbow" then
		local realtime = RealTime() * 0.5
		local r, g, b = HSVToColor(realtime * 360, 1, 1).r, HSVToColor(realtime * 360, 1, 1).g, HSVToColor(realtime * 360, 1, 1).b
		self:SetColor(Color(r, g, b, 255))
	end

	local text = self:GetCrystalType() .. " Crystal"
	local text3 = self:GetCrystalType() .. " Crystal (dirty!)"
	local text2 = "Resonance: " .. (self:GetCrystalScanned() and self:GetCrystalResonance() or "??") .. "%"
	local offset = Vector(0, 0, 17)
	local origin = self:GetPos()
	if LocalPlayer():GetPos():DistToSqr(origin) > (150*150) then return end
	local pos = origin + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)

	cam.Start3D2D(pos, ang, 0.05)
		surface.SetFont("XenCrystalText")
		local w, h = surface.GetTextSize(text2)
		if self:GetClean() ~= false then
			draw.SimpleText(text, "XenCrystalText", 4, 4, Color(0,0,0), 1, 1)
			draw.SimpleText(text, "XenCrystalText", 0, 0, Color(255,255,255), 1, 1)
		else
			draw.SimpleText(text3, "RadioactiveText", 4, 4, Color(0,0,0), 1, 1)
			draw.SimpleText(text3, "RadioactiveText", 0, 0, Color(255,255,255), 1, 1)
		end
		draw.SimpleText(text2, "XenCrystalText", 4, 79, Color(0,0,0), 1, 1)
		draw.SimpleText(text2, "XenCrystalText", 0, 75, Color(255,255,255), 1, 1)
		
	cam.End3D2D()

end

