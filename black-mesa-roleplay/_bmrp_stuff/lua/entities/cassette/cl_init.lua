// Wildfire Black Mesa Roleplay
// File description: BMRP client-side code for the Cassette entity
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

function ENT:Draw()
    self:DrawModel()

    local cassette = BMRP_ARG.CASSETTES[self:GetCassetteID()]
    if not cassette then return end

    local progress = 0
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)

    -- make a progress bar on the front of the entity
    cam.Start3D2D(self:GetPos() + self:GetForward() * 44.5 + self:GetUp() * 61.25, ang, 0.05)
        -- DO NOT MESS WITH THESE draw.RoundedBox SETTINGS!
        surface.SetDrawColor(Color(255, 255, 0, 255))
        surface.DrawRect(-100, -100, 200, 200)
        surface.SetDrawColor(Color(0, 0, 0, 255))   
        surface.DrawRect(-95, -95, 190, 190)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        -- draw text
        draw.SimpleText(cassette.text, "BMRP_CrystalWasher_Text", 0, -20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
