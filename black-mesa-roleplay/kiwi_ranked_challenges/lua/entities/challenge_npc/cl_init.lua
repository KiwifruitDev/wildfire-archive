// Wildfire Ranked Challenges
// File description: Challenge NPC CL initialization script.
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

surface.CreateFont("vipnpc", {font = "DermaLarge", size = 192})
local offset = Vector(0, 0, 83)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
	self:DrawModel()

	local origin = self:GetPos()
	if (LocalPlayer():GetPos():Distance(origin) >= 768) then
		return end

	local pos = origin + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang.p = 0
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)

	local challenge = KIWI.ChallengeList[self:GetChallengeType()]
	local text = "Unknown"
	if challenge then
		text = challenge.name 
	end
	
    local yellow = Color(0, 255, 255, 192)
    
	cam.Start3D2D(pos, ang, 0.04)
		surface.SetFont("vipnpc")
		local width, height = surface.GetTextSize(text)
		local pad = 16
		width = width + pad * 2
		height = height + pad * 2

		draw.RoundedBox(64, -width * 0.5, -pad, width, height, Color(0, 0, 0, 128))

		draw.SimpleText(text, "vipnpc", 0, 0, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end
