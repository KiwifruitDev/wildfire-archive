// Wildfire Black Mesa Roleplay
// File description: BMRP client-side trashcan entity script
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

surface.CreateFont("CraftingTableText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(30),
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

local offset = Vector(0, 0, 30)

function ENT:Draw()
    self:DrawModel()
    
    local text = "Trashcan"
    local text2 = "" //"Resonance: " .. (self:GetCrystalScanned() and self:GetCrystalResonance() or "??") .. "%"
    local origin = self:GetPos()
    if LocalPlayer():GetPos():DistToSqr(origin) > (110*110) then return end
    local pos = origin + offset
    local ang = (LocalPlayer():EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    cam.Start3D2D(pos, ang, 0.05)
        surface.SetFont("CraftingTableText")
        local w, h = surface.GetTextSize(text2)
        local w2, h2 = surface.GetTextSize(text)
        if w < w2 then w = w2 end
        draw.SimpleText(text, "CraftingTableText", 4, h/4+4-10, Color(0,0,0), 1, 1)
        draw.SimpleText(text2, "CraftingTableText", 4, 89, Color(0,0,0), 1, 1)
        draw.SimpleText(text, "CraftingTableText", 0, h/4+4-10, Color(255,255,255), 1, 1)
        draw.SimpleText(text2, "CraftingTableText", 0, 85, Color(255,255,255), 1, 1)
    cam.End3D2D()
end