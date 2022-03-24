// ============================================================================================ //
/* 
 * Wildfire Servers - Portal RP - Hud Addon
*  File description: Clientside HUD script file
 * Copyright (C) 2022 KiwifruitDev
*  Licensed under the MIT License.
 */
// ============================================================================================ //
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Every file needs this :)
include("portalrp/portalrp_shared.lua")

// We make our cool fonts and put them below this line right guys
surface.CreateFont( "PortalFontNick", {
	font = "PORTAL", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 16,
	weight = 100,
	antialias = true,
	outline = false,
} )

// Other Variables
local offset = 10
local offsetx = offset+2 // two pixels off
local offsety = offset
local shadow = 1

// Materials
local mainhud = Material("wildfire/portalrp/hud/mainhud.png")
local shieldhealth = Material("wildfire/portalrp/hud/shieldhealth.png")

local hide = {
	["CHudAmmo"] = true, 
	["CHudSecondaryAmmo"] = true,
	["CHudHealth"] = true,
    ["CHudCrosshair"] = true,
	["CHudBattery"] = true,
    -- if you DarkRP_HUD this to true, ALL of DarkRP's HUD will be disabled. That is the health bar and stuff,
    -- but also the agenda, the voice chat icons, lockdown text, player arrested text and the names above players' heads
    ["DarkRP_HUD"] = false,
    -- DarkRP_EntityDisplay is the text that is drawn above a player when you look at them.
    -- This also draws the information on doors and vehicles
    ["DarkRP_EntityDisplay"] = false,
    -- This is the one you're most likely to replace first
    -- DarkRP_LocalPlayerHUD is the default HUD you see on the bottom left of the screen
    -- It shows your health, job, salary and wallet, but NOT hunger (if you have hungermod enabled)
    ["DarkRP_LocalPlayerHUD"] = true,
    -- If you have hungermod enabled, you will see a hunger bar in the DarkRP_LocalPlayerHUD
    -- This does not get disabled with DarkRP_LocalPlayerHUD so you will need to disable DarkRP_Hungermod too
    ["DarkRP_Hungermod"] = false,
    -- Drawing the DarkRP agenda
    ["DarkRP_Agenda"] = true,
    -- Lockdown info on the HUD
    ["DarkRP_LockdownHUD"] = false,
    -- Arrested HUD
    ["DarkRP_ArrestedHUD"] = false,
    -- Chat receivers box when you open chat or speak over the microphone
    ["DarkRP_ChatReceivers"] = false,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end)

local function DrawTextShadowed(text, font, x, y, color, xalign, yalign)
    draw.SimpleText(text, font, x+shadow, y+shadow, Color(0, 0, 0, color.a), xalign, yalign)
    draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

local dots = {
    [0] = ".",
    [1] = "..",
    [2] = "...",
    [3] = ""
}

local ourdots = ""

local NextDotsTime

hook.Add("Think", "PortalRP_HUD", function()
    if not LocalPlayer():GetNWBool("IsScavenging") then return end
    if not NextDotsTime or SysTime() >= NextDotsTime then
        NextDotsTime = SysTime() + 0.5
        ourdots = ourdots or ""
        local len = string.len(ourdots)
        ourdots = dots[len]
    end
end)

hook.Add("HUDPaint", "DrawNewCrosshair", function()
    
    // crosshair variables
    local length = 1
    local height = 3
    local outline = 1
    // crosshair
    surface.SetDrawColor(0,101,255,255)
    surface.DrawOutlinedRect(ScrW()/2, ScrH()/2-height-1, length, height, outline) // top
    surface.DrawOutlinedRect(ScrW()/2, ScrH()/2+length+1, length, height, outline) // bottom
    surface.DrawOutlinedRect(ScrW()/2-height-1, ScrH()/2, height, length, outline) // left
    surface.DrawOutlinedRect(ScrW()/2+length+1, ScrH()/2, height, length, outline) // right

    // hud variables
    local health = LocalPlayer():Health()
    local armor = LocalPlayer():Armor()

    local rpname = LocalPlayer():getDarkRPVar('rpname')
    local nick = LocalPlayer():Nick()
    local job = LocalPlayer():getDarkRPVar('job')
    //local clearance = not yet
    local balanceog = LocalPlayer():getDarkRPVar('money')
	local balance = DarkRP.formatMoney(balanceog)
    local salary = LocalPlayer():getDarkRPVar('salary')
	local jbtbl = LocalPlayer():getJobTable()

    if not jbtbl then return end
    if not salary then return end

    local clearance = 0

    if jbtbl.clearance then clearance = jbtbl.clearance end

    // Draw the actual hud
    render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	surface.SetDrawColor( 255, 255, 255, 255 )
    //main hud
	surface.SetMaterial(mainhud)
    surface.DrawTexturedRect(offsetx, ScrH()-(mainhud:Height()/2)-offsety, mainhud:Width()/2, mainhud:Height()/2)
    //shield icon
    surface.SetMaterial(shieldhealth)
    surface.DrawTexturedRect(170+offsetx, ScrH()-(shieldhealth:Height()/16)-offsety-6, shieldhealth:Width()/16, shieldhealth:Height()/16)

    //health bar
    surface.SetDrawColor(0, 0, 0, 192)
    surface.DrawRect(200+offsetx, ScrH()-43, 200, 10)
    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawRect(200+offsetx, ScrH()-43, health*2, 10)

    //armor bar
    surface.SetDrawColor(0, 0, 0, 128)
    surface.DrawRect(200+offsetx, ScrH()-33, 200, 10)
    surface.SetDrawColor(0, 0, 255, 255)
    surface.DrawRect(200+offsetx, ScrH()-33, armor*2, 10)
    render.PopFilterMag()
    render.PopFilterMin()

    DrawTextShadowed(rpname, "PortalFontNick", 212+offsety, ScrH() - 189, Color(255,255,255,255)) // Name
    DrawTextShadowed(job, "PortalFontNick", 253+offsety, ScrH() - 158, Color(255,255,255,255)) // Affiliation
    DrawTextShadowed("Level: " .. clearance, "PortalFontNick", 249+offsety, ScrH() - 127, Color(255,255,255,255)) // Clearance
    DrawTextShadowed(balance, "PortalFontNick", 234+offsety, ScrH() - 96, Color(255,255,255,255)) // Balance
    DrawTextShadowed("$" .. salary, "PortalFontNick", 225+offsety, ScrH() - 65, Color(255,255,255,255)) // Salary

    // scrap metal scavenging
    if LocalPlayer():GetNWBool("IsScavenging") then
    local w = ScrW()
    local h = ScrH()
    local x, y, width, height = w / 2 - w / 10, h / 2 - 60, w / 5, h / 15
    draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120))

    local time = LocalPlayer():GetNWFloat("ScavengeTimeEnd") - LocalPlayer():GetNWFloat("ScavengeTime")
    local curtime = CurTime() - LocalPlayer():GetNWFloat("ScavengeTime")
    local status = math.Clamp(curtime / time, 0, 1)
    //LocalPlayer():ChatPrint(status)
    local BarWidth = status * (width - 16)
    local cornerRadius = math.Min(8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2)
    draw.RoundedBox(cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color(255 - (status * 255), 0 + (status * 255), 0, 255))

    draw.DrawNonParsedSimpleText(LocalPlayer():GetNWString("ScavengingText", "Scavenging") .. ourdots, "Trebuchet24", w / 2, y + height / 2, Color(255, 255, 255, 255), 1, 1)
    end
    // ammo
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep.Clip2 then
        local ammo = wep:Clip2() or 0
        if ammo > -1 then
            local maxammo = wep:GetMaxClip2() or 0
            local ammo_percent = ammo / maxammo
            local stockwidth = 200
            local ammo_bar_width = ammo_percent * stockwidth
            local ammo_bar_height = 10
            local ammo_bar_x = ScrW() - stockwidth - offsetx
            local ammo_bar_y = ScrH() - ammo_bar_height - offsety
            surface.SetDrawColor(0, 0, 0, 192)
            surface.DrawRect(ammo_bar_x, ammo_bar_y, stockwidth, ammo_bar_height)
            surface.SetDrawColor(2, 162, 255, 255)
            surface.DrawRect(ammo_bar_x, ammo_bar_y, ammo_bar_width * ammo_percent, ammo_bar_height)
            DrawTextShadowed(ammo.."/"..maxammo, "PortalFontNick", ammo_bar_x + stockwidth, ammo_bar_y+(offsety/2), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            DrawTextShadowed("Secondary", "PortalFontNick", ammo_bar_x, ammo_bar_y+(offsety/2), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    end
    if wep.Clip1 then
        local ammo = wep:Clip1() or 0
        if ammo > -1 then
            local maxammo = wep:GetMaxClip1() or 0
            local ammo_percent = ammo / maxammo
            local stockwidth = 200
            local ammo_bar_width = ammo_percent * stockwidth
            local ammo_bar_height = 10
            local ammo_bar_x = ScrW() - stockwidth - offsetx
            local ammo_bar_y = ScrH() - ammo_bar_height - offsety
            if wep.Clip2 then
                ammo_bar_y = ScrH() - ammo_bar_height * 2 - offsety*2
            end
            surface.SetDrawColor(0, 0, 0, 192)
            surface.DrawRect(ammo_bar_x, ammo_bar_y, stockwidth, ammo_bar_height)
            surface.SetDrawColor(2, 162, 255, 255)
            surface.DrawRect(ammo_bar_x, ammo_bar_y, ammo_bar_width * ammo_percent, ammo_bar_height)
            DrawTextShadowed(ammo.."/"..maxammo, "PortalFontNick", ammo_bar_x + stockwidth, ammo_bar_y+(offsety/2), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            DrawTextShadowed("Primary", "PortalFontNick", ammo_bar_x, ammo_bar_y+(offsety/2), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    end
end )
