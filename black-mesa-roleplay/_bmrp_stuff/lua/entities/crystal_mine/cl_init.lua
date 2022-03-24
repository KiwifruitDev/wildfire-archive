// Wildfire Black Mesa Roleplay
// File description: BMRP client-side crystal mine entity script
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

surface.CreateFont("CrystalSpawnerText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(40),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function ENT:Draw()
    self:DrawModel()
    -- change color dynamically like a rainbow if the CrystalEffect is "Rainbow"
	if self:GetCrystalType() == "Rainbow" then
		local realtime = RealTime() * 0.5
		local r, g, b = HSVToColor(realtime * 360, 1, 1).r, HSVToColor(realtime * 360, 1, 1).g, HSVToColor(realtime * 360, 1, 1).b
		self:SetColor(Color(r, g, b, 255))
	end
    local text = "Crystal Mine"
    local offset = Vector(0, 0, 50)
    local origin = self:GetPos()
    if LocalPlayer():GetPos():DistToSqr(origin) > (150*150) then return end
    local pos = origin + offset
    local ang = (LocalPlayer():EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    cam.Start3D2D(pos, ang, 0.05)
        surface.SetFont("CrystalSpawnerText")
        local w, h = surface.GetTextSize(text)
        draw.SimpleText(text, "CrystalSpawnerText", 4, 4, Color(0,0,0), 1, 1)
        draw.SimpleText(text, "CrystalSpawnerText", 0, 0, Color(255,255,255), 1, 1)
        
    cam.End3D2D()
end