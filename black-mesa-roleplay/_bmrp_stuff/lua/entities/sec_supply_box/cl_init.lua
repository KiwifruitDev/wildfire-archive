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

surface.CreateFont("BoxText", {
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


function ENT:Draw()

    self:DrawModel()

    local text = "Supply Box"
    local offset = Vector(0, 0, 25)
    local origin = self:GetPos()
    if LocalPlayer():GetPos():DistToSqr(origin) > (500*500) then return end
    local pos = origin + offset
    local ang = (LocalPlayer():EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    cam.Start3D2D(pos, ang, 0.05)
        surface.SetFont("BoxText")
        local w, h = surface.GetTextSize(text)
        draw.RoundedBox( 30, -w*.5 -30 + 6, -h*.5 + 6, w + 60, h+10, Color(0,0,0,255))
        draw.RoundedBox( 30, -w*.5 -30, -h*.5, w + 60, h+10, Color(0,93,169,150))
        draw.SimpleText(text, "BoxText", 4, 4, Color(0,0,0), 1, 1)
        draw.SimpleText(text, "BoxText", 0, 0, Color(255,255,255), 1, 1)
        
    cam.End3D2D()
end