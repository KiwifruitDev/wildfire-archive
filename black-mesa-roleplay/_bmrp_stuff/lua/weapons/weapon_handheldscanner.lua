// Wildfire Black Mesa Roleplay
// File description: BMRP Handheld Scanner swep
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

AddCSLuaFile()

if SERVER then
	SWEP.Weight                     = 4
	SWEP.AutoSwitchTo               = false
	SWEP.AutoSwitchFrom             = false
end

if CLIENT then
	SWEP.PrintName          = "Handheld Scanner"
	SWEP.Author             = "Wildfire BMRP"
	SWEP.Purpose            = "Left-click to scan an item."
end

SWEP.HoldType			= "pistol"
SWEP.DrawAmmo 			= false
SWEP.DrawCrosshair 		= true
SWEP.Category 			= "Wildfire BMRP"
SWEP.UseHands           = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/wildfire/weapons/v_scanner.mdl"
SWEP.WorldModel 		= "models/wildfire/weapons/w_scanner.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo				= "none"
SWEP.AlwaysRaised = true

function SWEP:PrimaryAttack()
    return
end

function SWEP:SecondaryAttack()
    return
end