// Wildfire HEV Suit HUD
// File description: Suit hands weapon script
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

// This SWEP is just here to display the hands, nothing special.
// It should not be given to the player outside of these scripts.

AddCSLuaFile()

local HANDS = "models/weapons/v_hev_hands.mdl"

util.PrecacheModel(HANDS)

SWEP.PrintName = "HEV Suit"
SWEP.Author = "Wildfire Servers"
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Spawnable = false
SWEP.ViewModel = Model( "models/weapons/v_hev_hands.mdl" )
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.DrawAmmo = false
SWEP.UseHands = false
SWEP.DisableDuplicator = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SetPlaybackRate(0.75)
	return true
end

function SWEP:OnDrop()
	return false
end

function SWEP:Holster()
	-- randy reported a bug here where the hands were not removed properly
	-- so I'm returning true here instead of the original false value
	return true
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
    return false
end
