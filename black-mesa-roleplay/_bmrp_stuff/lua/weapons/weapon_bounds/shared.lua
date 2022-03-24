// Wildfire Black Mesa Roleplay
// File description: BMRP bounding box weapon shared script
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

SWEP.PrintName = "Bounding Box Tool"
SWEP.Instructions = "Left click once to start drawing a bounding box. Left click again to finish drawing the box."
SWEP.Purpose = "Creates a bounding box entity."
SWEP.Category = "Wildfire BMRP"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.ViewModelFOV = 60
SWEP.UseHands = true
SWEP.HoldType = "rpg"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
-- we want to be able to "fire" this so ammo needs to be present
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
    self:NetworkVar("Entity", 0, "BoundingBox")
    self:NetworkVar("Vector", 1, "StartPos")
    self:NetworkVar("Bool", 2, "Moving")
    self:NetworkVar("Bool", 3, "Manual")
    if SERVER then
        self:SetBoundingBox(nil)
        self:SetStartPos(Vector(0, 0, 0))
        self:SetMoving(false)
        self:SetManual(false)
    end
end