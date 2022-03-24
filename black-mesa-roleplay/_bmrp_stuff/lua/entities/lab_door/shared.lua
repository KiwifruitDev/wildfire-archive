// Wildfire Black Mesa Roleplay
// File description: BMRP shared door entity script
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

-----------------------------------------------------
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true

ENT.DelayTime = 0.75 //how long until the screen begins to fade
ENT.FadeTime = 0.75 //how long it takes to fade completely
ENT.WaitTime = 0.25 //period for it to stay completely black

ENT.OpenSound = Sound("doors/door_metal_rusty_move1.wav")
ENT.CloseSound = Sound("doors/door_metal_thin_close2.wav")

ENT.PrintName = "Lab Door (!!!)"
ENT.Category = "Wildfire BMRP"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:CanUse( ply )
	return true, "ENTER"
end

function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "TeleportEnt" )
	self:NetworkVar( "Angle", 1, "TeleportEnt2" )

	if SERVER then
		self:SetTeleportEnt( Vector( 0, 0, 0 ) )
		self:SetTeleportEnt2( Angle( 0, 0, 0 ) )
	end

end
