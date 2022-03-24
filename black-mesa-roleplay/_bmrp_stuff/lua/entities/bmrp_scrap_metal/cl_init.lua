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

function ENT:Draw()
    if not self:GetTimedOut() then
        self:DrawModel()

        local text = "Rubbish Pile"
        local offset = Vector(0, 0, 15)
        local origin = self:GetPos()
        if LocalPlayer():GetPos():DistToSqr(origin) > (500*500) then return end
        local pos = origin + offset
        local ang = (LocalPlayer():EyePos() - pos):Angle()
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 180)

        cam.Start3D2D(pos, ang, 0.05)
            surface.SetFont("CraftingTableText")
            local w, h = surface.GetTextSize(text)
            surface.SetTextPos(-(w / 2), -(h / 2))
            surface.SetTextColor(255, 255, 255, 255)
            surface.DrawText(text)
        cam.End3D2D()
    end
end

