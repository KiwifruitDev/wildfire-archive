// Modified version of https://steamcommunity.com/sharedfiles/filedetails/?id=1656360089
// Originally created by https://steamcommunity.com/id/mewtek32

include('half_hud/halfhud_settings.lua')


// Fonts go here

surface.CreateFont( "HealthFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 60,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "InvFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 30,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "InvFontSub", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "AmmoPrimary", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 60,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "AmmoSecondary", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 60,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "MoneyFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 30,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )


surface.CreateFont( "NukeFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 100,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "NukeFont2", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 30,
	weight = 200,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "WantedFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = true,
	size = 30,
	weight = 800,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = true,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )


// Materials

local name_tag = Material('half_name.png')
local job_tag = Material('half_job.png')
local money_current = Material('half_money.png')
local salary_icon = Material('half_salary.png')
local health_icon = Material('half_health.png')
local armor_icon = Material('half_armor.png')
local ammo_icon = Material('half_ammo.png')
local energy_icon = Material('half_energy.png')
local wanted_icon = Material('half_wanted.png')
local lockdown_icon = Material('half_lockdown.png')
local gunlicense_icon = Material('half_gunlicense.png')
local xp_icon = Material('wildfire/ui/star.png')


// Custom hud color override
local hudcolor = Color(234, 156, 0)


// Disable default Garry's Mod & DarkRP HUD elements

local hideHUDElements = {
	["DarkRP_HUD"] = true,
	["DarkRP_EntityDisplay"] = false,
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Hungermod"] = true,
	["DarkRP_Agenda"] = false,
   	["DarkRP_LockdownHUD"] = false,
   	["DarkRP_ArrestedHUD"] = false,
	["CHudAmmo"] = true, 
	["CHudSecondaryAmmo"] = true
}
// This is the code that actually stops the game from drawing the elements above
hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name)
	if hideHUDElements[name] then return false end
end)

local brokentext = "DarkRP has been Lua refreshed, expect A LOT OF ERRORS!"
local brokentextsub = "Please wait until next server restart for this to go away."

local centeroflambda = Vector(-14131.059570313, 557.43719482422, -250)

local intercomactive = 0

net.Receive("IntercomActive", function()
	intercomactive = 100
end)

// Actual UI
hook.Add("HUDPaint", "DrawHHud", function()
	if LocalPlayer():GetNWBool("BMRP_HudToggle") ~= false then
		local brokenoffset = ScrH()
		local health = LocalPlayer():Health()
		local suitpower = LocalPlayer():Armor()
		local money = LocalPlayer():getDarkRPVar('money')
		local salary = LocalPlayer():getDarkRPVar('salary')
		local job = LocalPlayer():getDarkRPVar('job')
		local rpname = LocalPlayer():getDarkRPVar('rpname')
		local energy = LocalPlayer():getDarkRPVar('Energy')
		local jbtbl = LocalPlayer():getJobTable()

		local errors = money == nil and "Money" or salary == nil and "Salary" or job == nil and "Job" or rpname == nil and "RP Name" or jbtbl == nil and "Job Table" or "Unknown"

		if errors ~= "Unknown" then
			draw.SimpleText("Error code: "..errors, "InvFont", ScrW()/2, brokenoffset-65, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(brokentext, "InvFont", ScrW()/2, brokenoffset-40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(brokentextsub, "InvFont", ScrW()/2, brokenoffset-15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			return
		end

		local money = DarkRP.formatMoney(money)

		local rankprefix = LocalPlayer():GetNWString("RankPrefix", "")
		if #rankprefix > 0 then
			rankprefix = rankprefix .. " "
		end
		
		// Ammo Variables
		local weapon = LocalPlayer():GetActiveWeapon()
		if not IsValid (weapon) then return end 
		local weaponclass = weapon:GetClass()
		local ammo = weapon:Clip1()
		local reserve = LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType())
		local disabled = ammo <= 0 and reserve <= 0 and true or false

		// Variables from the config

		local HMEnabled = Half_Hud.hungermod

		// Draw Materials

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(name_tag) -- If you use Material, cache it!
		surface.DrawTexturedRect( 0, ScrH() - 146, 34, 34 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(job_tag) -- If you use Material, cache it!
		surface.DrawTexturedRect(-3, ScrH() - 176, 40, 40 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(money_current) -- If you use Material, cache it!
		surface.DrawTexturedRect( -7 , ScrH() - 101, 50, 50 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(salary_icon) -- If you use Material, cache it!
		surface.DrawTexturedRect( -1, ScrH() - 120, 35, 35 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(health_icon) -- If you use Material, cache it!
		surface.DrawTexturedRect( -10, ScrH() - 68, 60, 60 )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(armor_icon) -- If you use Material, cache it!
		surface.DrawTexturedRect( 144, ScrH() - 70, 60, 60 )
		///////////////////////////////////////////

		
		draw.SimpleText(health.."", "HealthFont", 45, ScrH() - 70, hudcolor, 0, 0)
		draw.SimpleText(suitpower.."", "HealthFont", 200, ScrH() - 70, hudcolor, 0, 0)


		if LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
			if LocalPlayer():IsStaff() then
				draw.SimpleText("You are currently noclipping!", "InvFont", ScrW()/2, ScrH() - 40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("(You are invisible, silent, and invincible.)", "InvFontSub", ScrW()/2, ScrH() - 15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		elseif LocalPlayer():HEVSuitEquipped() then
			if GetGlobalBool("LambdaFailureClearance", false) == true then
				local dist = LocalPlayer():GetPos():Distance(centeroflambda)
				if dist <= 1000 then
					draw.SimpleText("Magnetic Boots Engaged.", "InvFont", ScrW()/2, ScrH() - 40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText("(You feel heavier!)", "InvFontSub", ScrW()/2, ScrH() - 15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		elseif weaponclass == "weapon_syringe" then 
			draw.SimpleText("Blood Type: "..weapon:GetSyringeBloodType(), "InvFont", ScrW()/2, ScrH() - 40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("(Right-click clears your blood!)", "InvFontSub", ScrW()/2, ScrH() - 15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif weaponclass == "pocket" then
			draw.SimpleText("Press 'R' to open your inventory.", "InvFont", ScrW()/2, ScrH() - 40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("(Doesn't work If you have nothing.)", "InvFontSub", ScrW()/2, ScrH() - 15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif weaponclass == "weapon_handheldscanner" then
			draw.SimpleText("Press 'E' to scan items!", "InvFont", ScrW()/2, ScrH() - 40, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("(Works on crystals!)", "InvFontSub", ScrW()/2, ScrH() - 15, hudcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText(""..money.."", "MoneyFont", 45, ScrH() - 90, hudcolor)
		draw.SimpleText("$"..salary.."", "MoneyFont", 45, ScrH() - 117, hudcolor)
		draw.SimpleText(job.."", "MoneyFont", 45, ScrH() - 170, hudcolor)
		draw.SimpleText(rankprefix..rpname.."", "MoneyFont", 45, ScrH() - 144, hudcolor)


		local function DisplayNotify(msg)
			local txt = msg:ReadString()
			GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
			surface.PlaySound("buttons/lightswitch2.wav")

		-- Log to client console
			MsgC(Color(255, 20, 20, 255), "[BMRP] ", Color(200, 200, 200, 255), txt, "\n")
		end
		usermessage.Hook("_Notify", DisplayNotify)


		if HMEnabled == true then


			draw.SimpleText(energy.."%", "HealthFont", 420, ScrH() - 70, hudcolor, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(energy_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect(295, ScrH() - 70, 60, 60 )
			
		end

		// Wanted event
		if LocalPlayer():getDarkRPVar("wanted") then
			draw.SimpleText(Half_Hud.wantedmsg, "WantedFont", 50, ScrH() - 720, Color(137, 0, 6 ))
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(wanted_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect(-5, ScrH() - 740, 64, 64 )
		end
		// Lockdown event
		if GetGlobalBool("DarkRP_LockDown") then
			draw.SimpleText(Half_Hud.lockdownmsg, "WantedFont", 60, ScrH() - 779, Color(137, 0, 6 ))
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(lockdown_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect(-5, ScrH() - 800, 64, 64 )
		end

		// XP
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(xp_icon) -- If you use Material, cache it!
		surface.DrawTexturedRect( 2, ScrH() - 227, 34, 34 )
		//draw.SimpleText("Global XP: "..LocalPlayer():GetNWInt("XP_global"), "MoneyFont", 45, ScrH() - 224, hudcolor)
		// Uppercase the first letter of LocalPlayer():CategoryCheck() gsub("^%l", string.upper)
		local InternalName = LocalPlayer():CategoryCheck()
		local localizedName = string.gsub(InternalName, "^%l", string.upper)
		local HECUTEXT = "H.E.C.U"
		//draw.SimpleText("Debug Counter: "..LocalPlayer():GetNWInt("Counter_"..InternalName), "MoneyFont", 45, ScrH() - 250, hudcolor)
		if InternalName == "hecu" then
			draw.SimpleText(HECUTEXT.." XP: "..LocalPlayer():GetNWInt("XP_"..InternalName), "MoneyFont", 45, ScrH() - 224, hudcolor)
		else
			draw.SimpleText(localizedName.." XP: "..LocalPlayer():GetNWInt("XP_"..InternalName), "MoneyFont", 45, ScrH() - 224, hudcolor)
		end

		if jbtbl.clearance and not jbtbl.hecu then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(gunlicense_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect( 2, ScrH() - 200, 34, 34 )
			draw.SimpleText("Clearance Level "..jbtbl.clearance, "MoneyFont", 45, ScrH() - 197, hudcolor)
		elseif jbtbl.hecu then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(gunlicense_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect( 2, ScrH() - 200, 34, 34 )
			draw.SimpleText("Military Clearance", "MoneyFont", 45, ScrH() - 197, hudcolor)
		else
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(gunlicense_icon) -- If you use Material, cache it!
			surface.DrawTexturedRect( 2, ScrH() - 200, 34, 34 )
			draw.SimpleText("Clearance Level 0", "MoneyFont", 45, ScrH() - 197, hudcolor)
		end

		// draw location on opposite side

		local location = LocalPlayer():GetNWString("location")
		if location == "" then
			location = "Unknown"
		end
		-- fake ammo count
		surface.SetFont("AmmoSecondary")
		local TEXT_X, TEXT_Y = surface.GetTextSize(reserve)
		draw.SimpleText(location, "MoneyFont", ScrW() - (TEXT_X > 0 and 120 or 45)+TEXT_X, ScrH() - 85, hudcolor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		if intercomactive > 0 and GetGlobalBool("NukeEvent", false) == true then
			draw.SimpleText("INTERCOM ACTIVE", "NukeFont2", ScrW()/2, 125, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			intercomactive = intercomactive - 1
		elseif intercomactive > 0 then
			draw.SimpleText("INTERCOM ACTIVE", "NukeFont2", ScrW()/2, 25, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			intercomactive = intercomactive - 1
		end

		if GetGlobalBool("NukeEvent", false) == true then
			-- draw nukecountdown like a digital clock (00:00:00)
			local nukecountdown = GetGlobalInt("NukeTimer", 0)
			local minutes = math.floor(nukecountdown/60)
			local seconds = nukecountdown - (minutes * 60)
			local miliseconds = math.floor((nukecountdown - math.floor(nukecountdown)) * 100)
			local formattednuke = string.format("%02d:%02d:%02d", minutes, seconds, miliseconds)
			// draw in center
			draw.SimpleText(formattednuke, "NukeFont", ScrW()/2, 75, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(GetGlobalString("NukeText", "Alpha Warhead Detonation:") ~= "" and GetGlobalString("NukeText", "Alpha Warhead Detonation:") or "Alpha Warhead Detonation:", "NukeFont2", ScrW()/2, 15, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		// Does the player have a gun license?
		/*
		if Half_Hud.gunlicense == true then
			if LocalPlayer():getDarkRPVar("HasGunlicense") then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial(gunlicense_icon) -- If you use Material, cache it!
				surface.DrawTexturedRect( 2, ScrH() - 200, 34, 34 )
				draw.SimpleText("You have a gun license", "MoneyFont", 45, ScrH() - 197, hudcolor)
			else
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial(gunlicense_icon) -- If you use Material, cache it!
				surface.DrawTexturedRect( 2, ScrH() - 200, 34, 34 )
				draw.SimpleText("You don't have a gun license", "MoneyFont", 45, ScrH() - 197, hudcolor)
			end
		end
		*/


		// NOTE: If you're adding in your own custom values into the HUD, DON'T PUT ANYTHING BENEATH THIS LINE
		// It makes sure that the ammo counter doesn't display -2 | 0 on things like the physgun
		// Anything below it will only be visible when the ammo counter's visible, and vice versa
		if Half_Hud.ammocount == true then

			if disabled then return end

			draw.SimpleText(ammo.."", "AmmoPrimary", ScrW() - 200, ScrH() - 75, hudcolor, 0, 0)
			draw.SimpleText(reserve.."", "AmmoSecondary", ScrW() - 120, ScrH() - 75, hudcolor, 0,0)
			draw.RoundedBox(0, ScrW() - 130, ScrH() - 69, 3, 50, hudcolor)
		end

	end

end)