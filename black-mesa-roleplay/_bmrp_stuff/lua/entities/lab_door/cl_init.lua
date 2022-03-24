// Wildfire Black Mesa Roleplay
// File description: BMRP client-side door entity script
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
include("shared.lua")

ENT.RenderGroup 	= RENDERGROUP_OPAQUE

local LOAD_IDLE			= 0
local LOAD_FADEDELAY	= 1
local LOAD_FADINGOUT 	= 2
local LOAD_PAUSE 		= 3
local LOAD_FADINGIN 	= 4

local loadingState = LOAD_IDLE
local loadingAlpha = 1
local loadingDelay = 0

local clr = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function ENT:Draw()
	self:DrawModel()
end


net.Receive( "LoadingDoor", function(len)

	local ent = net.ReadEntity()

	loadingDelay = RealTime() + ( ent.DelayTime or .25 ) //Give a slight pause before fading out
	loadingState = LOAD_FADEDELAY

	LocalPlayer().LoadingDoor = ent

end )

hook.Add( "RenderScreenspaceEffects", "RenderDoorLoading", function()

	if !IsValid( LocalPlayer().LoadingDoor ) || loadingState == LOAD_IDLE then return end

	local ent = LocalPlayer().LoadingDoor

	if loadingState == LOAD_FADEDELAY then

		if RealTime() > loadingDelay then
			loadingAlpha = 1
			loadingState = LOAD_FADINGOUT
		end

	elseif loadingState == LOAD_FADINGOUT then

		loadingAlpha = loadingAlpha - ( FrameTime() * 1 ) / (ent.FadeTime or 0.25)

		if loadingAlpha <= 0 then 
			loadingAlpha = 0
			loadingState = LOAD_PAUSE
			loadingDelay = RealTime() + (ent.WaitTime or 0.1)
		end

	elseif loadingState == LOAD_PAUSE then

		if RealTime() > loadingDelay then
			loadingAlpha = 0
			loadingState = LOAD_FADINGIN
		end

	elseif loadingState == LOAD_FADINGIN then
 
		loadingAlpha = loadingAlpha + ( FrameTime() * 1 ) / (ent.FadeTime or 0.25)

		if loadingAlpha >= 1 then
			loadingAlpha = 1
			loadingState = LOAD_IDLE

			LocalPlayer().LoadingDoor = nil
		end

	end

	clr["$pp_colour_brightness"] = loadingAlpha - 1
	clr["$pp_colour_colour"] = loadingAlpha
	DrawColorModify( clr )

end )