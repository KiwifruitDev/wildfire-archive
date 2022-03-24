// Wildfire HEV Suit HUD
// File description: Clientside HUD processing script
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

// Strings file contains the English strings from Black Mesa.
include("hevsuit/hevstrings.lua")
if HEVSTRINGS == nil then return end

// HEV suit enumerables

local HUDSTATE_NONE             = 0 // Don't show any HEV UI
local HUDSTATE_SUITED           = 1 // We've just touched the HEV suit
local HUDSTATE_STARTUP          = 2 // Standby for main systems startup
local HUDSTATE_ARMOR            = 3 // Reactive armor system
local HUDSTATE_SENSORS          = 4 // Atmospheric contaminant sensors
local HUDSTATE_HEALTH           = 5 // Automatic medical system components
local HUDSTATE_WEAPONS          = 6 // Defensive weapon selection system
local HUDSTATE_MUNITION         = 7 // Munition level monitoring
local HUDSTATE_COMMUNICATION    = 8 // Onboard communication systems
local HUDSTATE_FINISHED         = 9 // Have a very safe day
local HUDSTATE_COUNT            = 10 // Amount of hud state enumerables

// The goal is modify this value and change the UI accordingly.
local STATE = HUDSTATE_NONE
local PREVIOUSSTATE = STATE

// HEV suit global timers
// These are what will change the state overtime.

local FIRSTSTATE = {HUDSTATE_SUITED, "hev_vox/bell.wav"}

local STATETIMERS = {
	{1, HUDSTATE_STARTUP, "hev_vox/01_hev_logon.wav"},
	{11.133, HUDSTATE_ARMOR, "hev_vox/02_powerarmor_on.wav"},
	{15.35, HUDSTATE_SENSORS, "hev_vox/03_atmospherics_on.wav"},
	{19.567, HUDSTATE_SENSORS, "hev_vox/04_vitalsigns_on.wav"},
	{23, HUDSTATE_HEALTH, "hev_vox/05_automedic_on.wav"},
	{26.533, HUDSTATE_WEAPONS, "hev_vox/06_weaponselect_on.wav"},
	{30.25, HUDSTATE_MUNITION, "hev_vox/07_munitionview_on.wav"},
	{33.9, HUDSTATE_COMMUNICATION, "hev_vox/08_communications_on.wav"},
	{37.283, HUDSTATE_FINISHED, "hev_vox/09_safe_day.wav"},
	{40.6, HUDSTATE_NONE, "hev_vox/boop.wav"},
}


// These are HUD elements, specifically the text values of those that are being painted.
local ELEMENTS = {
	["Header"] = "",
	["LowerHeader"] = "",
	["Center"] = "",
	["Typewriter1"] = "",
	["Typewriter2"] = "",
	["Typewriter3"] = "",
	["Typewriter4"] = "",
	["Typewriter5"] = "",
	["SystemHeader"] = "",
	["SystemChoices1"] = "",
	["SystemChoices2"] = "",
	["SystemChoices3"] = "",
	["SystemChoices4"] = "",
	["SystemChoices5"] = "",
	["SystemReadiness1"] = "",
	["SystemReadiness2"] = "",
	["SystemReadiness3"] = "",
	["SystemReadiness4"] = "",
	["SystemReadiness5"] = "",
	["WidgetHeader"] = "",
	["WidgetFooter"] = "",
}

// To override ELEMENTS for a hud reset.
local STOCKELEMENTS = ELEMENTS

// This value is used to track typewriters and the global time.
local TRACKER = 0

// Typewriter line number, should be between 1-5 but could be higher.
local LINE = 1

// Tracker subtraction for the typewriter for multiline.
local SUBTRACTION = 0

// Random per-session user ID for the suit
local USERID = math.random(0, 9)..math.random(0, 9)..math.random(0, 9)..math.random(0, 9)

// Sound to play when activating options
local HUDSOUND = "common/wpn_hudon.wav"

// This ensures that we are in a valid place to allow the HEV UI.
local function doublecheck()
	local ply = LocalPlayer()
	if STATE == HUDSTATE_NONE then return true end
	if not IsValid(ply) then STATE = HUDSTATE_NONE;return true end
	if not ply:Alive() then STATE = HUDSTATE_NONE;return true end
	return false
end

// This timer-based function sets UI elements' values dynamically.
local function HandleState()
	if doublecheck() then return end
	if PREVIOUSSTATE ~= STATE then
		for k, v in pairs(ELEMENTS) do
			ELEMENTS[k] = ""
		end
		PREVIOUSSTATE = STATE
		TRACKER = 0
		LINE = 1
		SUBTRACTION = 0
	end
	// Messy code!
	if STATE == HUDSTATE_STARTUP then
		// Header text (H.E.V. Mark IV etc)
		ELEMENTS["Header"] = string.sub(HEVSTRINGS["TITLE"], 1, TRACKER)
		// Lower header text (OS v4.2.124 etc)
		ELEMENTS["LowerHeader"] = string.sub(HEVSTRINGS["VERSION"], 1, TRACKER)
		// Center text (Standby etc)
		ELEMENTS["Center"] = string.sub(HEVSTRINGS["STANDBY"], 1, TRACKER)
		// Typewriter stuff
		local str = string.sub(HEVSTRINGS["PATHS"][LINE], 1, (TRACKER-SUBTRACTION))
		// This old code adds multiline but sacrifices the amount of lines.
		/*
		if LINE < 5 then
			ELEMENTS["Typewriter"..LINE] = str
			if #str == #HEVSTRINGS["PATHS"][LINE] then
				LINE = LINE + 1
				SUBTRACTION = TRACKER
			end
		end
		*/
		// This new code enables more typewriter lines but sacrifices multiline.
		ELEMENTS["Typewriter5"] = str
		if #str == #HEVSTRINGS["PATHS"][LINE] then
			LINE = LINE + 1
			SUBTRACTION = TRACKER
		end
	elseif STATE == HUDSTATE_ARMOR then
		ELEMENTS["WidgetHeader"] = string.sub("USER ID# "..USERID.."- "..LocalPlayer():Nick(), 1, TRACKER)
		if TRACKER == 0 then
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASEA"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASEAA"]
			ELEMENTS["SystemChoices2"] = HEVSTRINGS["PHASEAB"]
			ELEMENTS["SystemChoices3"] = HEVSTRINGS["PHASEAC"]
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["NOTREADY"]
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["NOTREADY"]
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["NOTREADY"]
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["READY"]
		elseif TRACKER == 40 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["READY"]
		elseif TRACKER == 60 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["READY"]
		end
	elseif STATE == HUDSTATE_SENSORS then
		ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
		if TRACKER == 0 then
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASEB"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASEBA"]
			ELEMENTS["SystemChoices2"] = HEVSTRINGS["PHASEBB"]
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["DEACTIVATED"]
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["DEACTIVATED"]
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["ACTIVATED"]
		elseif TRACKER == 40 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["ACTIVATED"]
		end
	elseif STATE == HUDSTATE_HEALTH then
		if TRACKER == 0 then
			ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASEC"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASECA"]
			ELEMENTS["SystemChoices2"] = HEVSTRINGS["PHASECB"]
			ELEMENTS["SystemChoices3"] = HEVSTRINGS["PHASECC"]
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["NOTREADY"]
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["NOTREADY"]
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["NOTREADY"]
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["READY"]
		elseif TRACKER == 40 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["READY"]
		elseif TRACKER == 60 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["READY"]
		end
	elseif STATE == HUDSTATE_WEAPONS then
		if TRACKER == 0 then
			ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASED"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASEDA"]
			ELEMENTS["SystemChoices2"] = HEVSTRINGS["PHASEDB"]
			ELEMENTS["SystemChoices3"] = HEVSTRINGS["PHASEDC"]
			ELEMENTS["SystemChoices4"] = HEVSTRINGS["PHASEDD"]
			ELEMENTS["SystemChoices5"] = HEVSTRINGS["PHASEDE"]
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["OFFLINE"]
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["OFFLINE"]
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["DEACTIVATED"]
			ELEMENTS["SystemReadiness4"] = HEVSTRINGS["NOTAVAILABLE"]
			ELEMENTS["SystemReadiness5"] = HEVSTRINGS["NOTAVAILABLE"]
		// I thought it looked cool idk
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["ONLINE"]
		elseif TRACKER == 40 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["ONLINE"]
		// These don't show due to custom hud.
		/*
		elseif TRACKER == 43 then
			RunConsoleCommand("slot1")
		elseif TRACKER == 46 then
			RunConsoleCommand("slot2")
		elseif TRACKER == 49 then
			RunConsoleCommand("slot3")
		elseif TRACKER == 52 then
			RunConsoleCommand("slot4")
		elseif TRACKER == 55 then
			RunConsoleCommand("slot5")
		elseif TRACKER == 58 then
			RunConsoleCommand("slot6")
		*/
		elseif TRACKER == 60 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["ACTIVATED"]
		end
	elseif STATE == HUDSTATE_MUNITION then
		if TRACKER == 0 then
			ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASEE"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASEEA"]
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["DEACTIVATED"]
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["ACTIVATED"]
		end
	elseif STATE == HUDSTATE_COMMUNICATION then
		if TRACKER == 0 then
			ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
			ELEMENTS["SystemHeader"] = HEVSTRINGS["PHASEF"]
			ELEMENTS["SystemChoices1"] = HEVSTRINGS["PHASEFA"]
			ELEMENTS["SystemChoices2"] = HEVSTRINGS["PHASEFB"]
			ELEMENTS["SystemChoices3"] = HEVSTRINGS["PHASEFC"]
			ELEMENTS["SystemChoices4"] = HEVSTRINGS["PHASEFD"]
			ELEMENTS["SystemChoices5"] = HEVSTRINGS["PHASEFE"]

			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["OFFLINE"]
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["OFFLINE"]
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["DISABLED"]
			ELEMENTS["SystemReadiness4"] = HEVSTRINGS["OFFLINE"]
			ELEMENTS["SystemReadiness5"] = HEVSTRINGS["NOTREADY"]
		elseif TRACKER == 10 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness1"] = HEVSTRINGS["ONLINE"]
		elseif TRACKER == 20 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness2"] = HEVSTRINGS["ONLINE"]
		elseif TRACKER == 30 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness3"] = HEVSTRINGS["ENABLED"]
		elseif TRACKER == 40 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness4"] = HEVSTRINGS["ONLINE"]
		elseif TRACKER == 50 then
			surface.PlaySound(HUDSOUND)
			ELEMENTS["SystemReadiness5"] = HEVSTRINGS["READY"]
		end
	elseif STATE == HUDSTATE_FINISHED then
		if TRACKER == 0 then
			ELEMENTS["WidgetHeader"] = "USER ID# "..USERID.."- "..LocalPlayer():Nick()
		end
		ELEMENTS["WidgetFooter"] = string.sub(HEVSTRINGS["SAFEDAY"], 1, TRACKER)
	end
	if TRACKER >= 1000000000 then // 32-bit integer limit is 2,147,483,647 -- we need to avoid this.
		TRACKER = 0
	end
	TRACKER = TRACKER + 1
end

// This function handles background processing for the HEV suit (so things appear in order and such)
local function HEV(ply)
	STATE = FIRSTSTATE[1]
	surface.PlaySound(FIRSTSTATE[2])
	for k,v in ipairs(STATETIMERS) do
		// We REALLY do not want to be interrupted here.
		// This will drop everything if a problem occurs.
		if doublecheck() then return end
		// TODO: Make sure player is wearing suit!
		if v[1] == nil or v[2] == nil or v[3] == nil then STATE = HUDSTATE_NONE;return end
		if timer.Exists("HandleStateTimer") then
			timer.Remove("HandleStateTimer")
		end
		timer.Create("HandleStateTimer", 0.05, 0, HandleState)
		timer.Simple(v[1], function()
			// DOUBLE CHECK THESE HERE TOO
			if doublecheck() then return end
			STATE = v[2]
			surface.PlaySound(v[3])
		end)
	end
end

// Let's do this
net.Receive("HevSuitHud", function(len)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 128 ), 0.3, 0 )
	HEV(ply)
end)

// Let's stop doing this
net.Receive("HevSuitHudOff", function(len)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 128 ), 0.3, 0 )
	surface.PlaySound("hev_vox/fuzz.wav")
	STATE = HUDSTATE_NONE
end)

// Drawing the HEV suit UI
hook.Add( "HUDPaint", "HUDPaint_HEVSUIT", function()
	if STATE <= HUDSTATE_SUITED or STATE >= HUDSTATE_COUNT then return end
	// Header
	draw.SimpleTextOutlined( ELEMENTS["Header"], "DermaLarge", ScrW()/2, ScrH()/4, Color( 255, 127, 0, 128 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Lower Header
	draw.SimpleTextOutlined( ELEMENTS["LowerHeader"], "DermaDefault", ScrW()/2, ScrH()/3.5, Color( 255, 127, 0, 128 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Center
	draw.SimpleTextOutlined( ELEMENTS["Center"], "DermaLarge", ScrW()/2, ScrH()/2, Color( 255, 127, 0, 128 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Typewriter
	draw.SimpleTextOutlined( ELEMENTS["Typewriter1"], "DermaLarge", 25, ScrH()/2-60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["Typewriter2"], "DermaLarge", 25, ScrH()/2-30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["Typewriter3"], "DermaLarge", 25, ScrH()/2, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["Typewriter4"], "DermaLarge", 25, ScrH()/2+30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["Typewriter5"], "DermaLarge", 25, ScrH()/2+60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// System Header
	draw.SimpleTextOutlined( ELEMENTS["SystemHeader"], "DermaLarge", 25, ScrH()/2-90, Color( 255, 0, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 64, 64, 10 ) )

	draw.SimpleTextOutlined( ELEMENTS["SystemChoices1"], "DermaDefault", 25, ScrH()/2-60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemChoices2"], "DermaDefault", 25, ScrH()/2-30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemChoices3"], "DermaDefault", 25, ScrH()/2, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemChoices4"], "DermaDefault", 25, ScrH()/2+30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemChoices5"], "DermaDefault", 25, ScrH()/2+60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	
	draw.SimpleTextOutlined( ELEMENTS["SystemReadiness1"], "DermaDefault", 400, ScrH()/2-60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemReadiness2"], "DermaDefault", 400, ScrH()/2-30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemReadiness3"], "DermaDefault", 400, ScrH()/2, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemReadiness4"], "DermaDefault", 400, ScrH()/2+30, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	draw.SimpleTextOutlined( ELEMENTS["SystemReadiness5"], "DermaDefault", 400, ScrH()/2+60, Color( 255, 127, 0, 128 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Widget Header
	draw.SimpleTextOutlined( ELEMENTS["WidgetHeader"], "DermaDefault", ScrW()-256, (ScrH()/2)-256-25, Color( 255, 127, 0, 128 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Widget Footer
	draw.SimpleTextOutlined( ELEMENTS["WidgetFooter"], "DermaDefault", ScrW()-256, (ScrH()/2)+256+25, Color( 255, 127, 0, 128 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 255, 192, 64, 10 ) )
	// Widget (HEV icon on side)
	if STATE >= HUDSTATE_ARMOR then
		draw.TexturedQuad({
			texture = surface.GetTextureID("wildfire/ui/hud_widget01"),
			color   = Color( 255, 127, 0, 245 ),
			x 	=  ScrW()-384,
			y 	=  (ScrH()/2)-256,
			w 	= 256,
			h 	= 512
		})
	end
end )

// These are hud variables to enable when the hud state is greater than or equal to its set value.
local HUDTOHIDE = {
	["CHudSuitPower"] = HUDSTATE_ARMOR,
	["CHudBattery"] = HUDSTATE_ARMOR,
	["CHudGeiger"] = HUDSTATE_SENSORS,
	["CHudDamageIndicator"] = HUDSTATE_HEALTH,
	["CHudHealth"] = HUDSTATE_HEALTH,
	["CHudPoisonDamageIndicator"] = HUDSTATE_HEALTH,
	["CHUDQuickInfo"] = HUDSTATE_WEAPONS,
	["CHudCrosshair"] = HUDSTATE_WEAPONS,
	["CHudSecondaryAmmo"] = HUDSTATE_WEAPONS,
	["CHudAmmo"] = HUDSTATE_MUNITION,
	["CHudWeaponSelection"] = HUDSTATE_WEAPONS,
	["CHudZoom"] = HUDSTATE_WEAPONS,
	["CHudSquadStatus"] = HUDSTATE_COMMUNICATION,
}

// Let's make hud dynamically appear :)
// Disabled due to incompatibility with our custom hud.
/*
hook.Add( "HUDShouldDraw", "HUDShouldDraw_HEVSUIT", function( name )
	if STATE < HUDSTATE_SUITED or STATE >= HUDSTATE_COUNT then return end
	if HUDTOHIDE[name] ~= nil then
		if STATE >= HUDTOHIDE[name] then
			return true
		else
			return false
		end
	end
end)
*/
