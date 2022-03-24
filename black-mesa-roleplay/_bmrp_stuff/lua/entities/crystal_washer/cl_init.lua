// Wildfire Black Mesa Roleplay
// File description: BMRP client-side crystal washer entity script
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
surface.CreateFont("BMRP_CrystalWasher_Text", {
    font = "Roboto",
    size = 15,
    weight = 500,
    antialias = true
})

surface.CreateFont("AnalyzerText", {
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
    bold = true,
})

function ENT:Draw()

    self:DrawModel()

    local text = "(BROKEN)"
	local offset = Vector(0, 0, 105)
	local origin = self:GetPos()
	if LocalPlayer():GetPos():DistToSqr(origin) > (300*300) then return end
	local pos = origin + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)

	cam.Start3D2D(pos, ang, 0.1)
		surface.SetFont("AnalyzerText")
		local w, h = surface.GetTextSize(text)
		if self:GetBroken() then
			draw.SimpleText(text, "AnalyzerText", 4, -145, Color(0,0,0), 1, 1)
			draw.SimpleText(text, "AnalyzerText", 0, -149, Color(255, 0, 0), 1, 1)
        end
	cam.End3D2D()

    local progress = self:GetProgress()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)

    -- make a progress bar on the front of the entity
    cam.Start3D2D(self:GetPos() + self:GetForward() * 44.5 + self:GetUp() * 61.25, ang, 0.05)
        -- DO NOT MESS WITH THESE draw.RoundedBox SETTINGS!
        surface.SetDrawColor(Color(self:GetBroken() and 255 or 0, self:GetBroken() and 0 or 255, 0, 255))
        surface.DrawRect(-100, -100, 200, 200)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        surface.DrawRect(-95, -95, 190, 190)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        -- draw text
        draw.SimpleText("[ SUBSTANCE CLEANER ]", "BMRP_CrystalWasher_Text", 0, -20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- draw progress bar (0 - 1)
        surface.SetDrawColor(Color(self:GetBroken() and 255 or 0, self:GetBroken() and 0 or 255, 0, 255))
        surface.DrawRect(-90, -10, progress * 180, 20)
        -- draw information text
		if self:GetBroken() == false then
        	draw.SimpleText("[ PROGRESS: " .. math.Round(progress * 100) .. "% ]", "BMRP_CrystalWasher_Text", 0, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("[ PROGRESS: ERROR% ]", "BMRP_CrystalWasher_Text", 0, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()

end