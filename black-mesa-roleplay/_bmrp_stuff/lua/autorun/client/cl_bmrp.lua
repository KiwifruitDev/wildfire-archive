// Wildfire Black Mesa Roleplay
// File description: BMRP client-side script
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

// Every file needs this :)
include("autorun/sh_bmrp.lua")

surface.CreateFont( "BlackoutMarker", {
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

// Draw the scavenging hud dots.
local dots = {
    [0] = ".",
    [1] = "..",
    [2] = "...",
    [3] = ""
}
local ourdots = ""
local NextDotsTime
//local snowed = false
hook.Add("Think", "BMRP_ScavengeHudDots", function()
    /*
    if not snowed then
        for k, v in pairs(ents.FindByName("SNOW")) do
            v:SetRenderBounds(Vector.Zero, Vector.Zero, Vector(100000, 100000, 100000))
            snowed = true
            break
        end
    end
    */
    if not LocalPlayer():GetNWBool("IsScavenging") then return end
    if not NextDotsTime or SysTime() >= NextDotsTime then
        NextDotsTime = SysTime() + 0.5
        ourdots = ourdots or ""
        local len = string.len(ourdots)
        ourdots = dots[len]
    end
end)
// Draw the players rank above their head.
local targetply = nil
hook.Add("HUDDrawTargetID", "BMRP_DrawRank", function()
    local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then targetply = nil return end
	if (!trace.HitNonWorld) then targetply = nil return end
	
	local ent = trace.Entity
	if !ent:IsPlayer() then targetply = nil return end
	
	if !targetply then
		targetply = ent
	end
	
    local pos = targetply:EyePos()

    pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
    if pos:Distance(LocalPlayer():GetPos()) > 400 then return end
    local text = ent:GetNWString("RankPrefix") -- The text above your head.
    local offset = -70
    pos = pos:ToScreen()
    if text == "" then return end
    draw.DrawText("| " .. text .. " |", "DarkRPHUD2", pos.x + 1, pos.y + 1 + offset, Color(0, 0, 0, 255), 1)
    draw.DrawText("| " .. text .. " |", "DarkRPHUD2", pos.x, pos.y+offset, Color(251,126,20,255), 1)
end)
// This should be used to initalize anything clientside that we need.
hook.Add("InitPostEntity", "ClientsideBMRPInit", function()
    // Vortigaunt beam red "X" fix
    PrecacheParticleSystem( "vortigaunt_beam" );
	PrecacheParticleSystem( "vortigaunt_beam_charge" );
	PrecacheParticleSystem( "vortigaunt_charge_token_b" );
	PrecacheParticleSystem( "vortigaunt_charge_token_c" );
	PrecacheParticleSystem( "vortigaunt_charge_token" );
    util.PrecacheModel("models/weapons/c_vortbeamvm.mdl")
    // remove exiting pills via noclip (stupid)
    hook.Remove("CreateMove", "momo_exit_check")
    
end)
// Swimming "fade" effect. Flashes your screen blue when you swim.
hook.Add("Think", "PlayerSwimAnim", function(ply, velocity)
    if LocalPlayer():WaterLevel() > 2 then // Completely submerged
        LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 255, 32), 0.25, 0.25 ) // Instantly become blue when in water
        LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 255, 32), 1, 0.5 ) // Fade blue out when out of water
    end
end)
// Draw a custom crosshair for the player (sort-of) related to Black Mesa.
hook.Add("HUDPaint", "DrawNewCrosshair", function()
    local length = 1
    local height = 3
    local outline = 1

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

    -- crosshair
    if LocalPlayer():GetNWBool("BMRP_CrosshairToggle") ~= false then
        surface.SetDrawColor(251,163,4,255)
        surface.DrawOutlinedRect(ScrW()/2, ScrH()/2-height-1, length, height, outline) // top
        surface.DrawOutlinedRect(ScrW()/2, ScrH()/2+length+1, length, height, outline) // bottom
        surface.DrawOutlinedRect(ScrW()/2-height-1, ScrH()/2, height, length, outline) // left
        surface.DrawOutlinedRect(ScrW()/2+length+1, ScrH()/2, height, length, outline) // right
    end
end )
// Removing the default crosshair from the client
hook.Add("HUDShouldDraw", "DrawNoCrosshair", function( name )
	if name == "CHudCrosshair" then
        return false
    end
end )

local TRANSITION_TIME = 0.25 -- adjust the speed of fading crystal drugs

hook.Add("RenderScreenspaceEffects", "crystal_drugs", function()
    local ply = LocalPlayer()
    local effect = ply:GetNWString("crystal_effect")
    if ply:GetNWString("crystal_effect") == "" then return end
    if effect == "lsd" then
        local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		//tab[ "$pp_colour_brightness" ] = 0
		//tab[ "$pp_colour_contrast" ] = 1
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0
		if( ply:GetNWFloat("crystal_effect_start") && ply:GetNWFloat("crystal_effect_end") > CurTime() )then
			if( ply:GetNWFloat("crystal_effect_start") + TRANSITION_TIME > CurTime() )then
				local s = ply:GetNWFloat("crystal_effect_start");
				local e = s + TRANSITION_TIME;
				local c = CurTime();
				local pf = (c-s) / (e-s);
				tab[ "$pp_colour_colour" ] =   1 + pf*3
				tab[ "$pp_colour_brightness" ] = -pf*0.19
				tab[ "$pp_colour_contrast" ] = 1 + pf*5.31
				DrawBloom(0.65, (pf^2)*0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
			elseif( ply:GetNWFloat("crystal_effect_end") - TRANSITION_TIME < CurTime() )then
				local e = ply:GetNWFloat("crystal_effect_end");
				local s = e - TRANSITION_TIME;
				local c = CurTime();
				local pf = 1 - (c-s) / (e-s);
				tab[ "$pp_colour_colour" ] =   1 + pf*3
				tab[ "$pp_colour_brightness" ] = -pf*0.19
				tab[ "$pp_colour_contrast" ] = 1 + pf*5.31
				DrawBloom(0.65, (pf^2)*0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
			else
				tab[ "$pp_colour_colour" ] =   1 + 3
				tab[ "$pp_colour_brightness" ] = -0.19
				tab[ "$pp_colour_contrast" ] = 1 + 5.31
				DrawBloom(0.65, 0.1, 9, 9, 4, 7.7,255,255,255)
				DrawColorModify( tab ) 
			end
		end
    end
end)

local haloents = {
    ["xen_crystal"] = true,
}

hook.Add( "PreDrawHalos", "BMRP_Halos", function()
    local ply = LocalPlayer()
    // power box halos
    if GetGlobalBool("blackoutpp", false) == true then
        local halotable = {}
        for k, v in pairs(ents.FindByClass("event_power_box")) do
            if not v:GetActivated() then
                table.insert(halotable, v)
            end
        end
        halo.Add(halotable, Color(251,126,20,255), 2, 2, 1, true, true)
    end
    // crystal halos
    if ply:GetNWBool("BMRP_IsGravGunning") == true then
        local halotable = {}
        local target = ply:GetNWEntity("BMRP_GravGunTarget")
        if IsValid(target) then
            if haloents[target:GetClass()] then
                table.insert(halotable, target)
            end
            halo.Add(halotable, target:GetColor() or Color(255,255,255), 2, 2, 2, true, false)
        end
    end
end)

hook.Add("HUDPaint", "BlackoutMarkers", function()
    local ply = LocalPlayer()
    if GetGlobalBool("blackoutpp", false) == true then
        for k, v in pairs(ents.FindByClass("event_power_box")) do
            if not v:GetActivated() then
                surface.SetFont("BlackoutMarker")
                local text = "!"
                local w, h = surface.GetTextSize(text)
                local toscreen = LocalToWorld(v:OBBCenter(), Angle(0,0,0), v:GetPos(), Angle(0,0,0)):ToScreen()
                surface.SetTextPos(toscreen.x - w/2, toscreen.y - h/2)
                surface.SetTextColor(255,255,255,255)
                surface.DrawText(text)
            end
        end
    end
end)



// CRYSTAL HALOS
/*
hook.Add( "PreDrawHalos", "BMRP_Halos", function()
    local items = ents.FindByClass( "func_physbox" )
    local orange = {}
    local purple = {}
    local green = {}
    local red = {}
    local door = {}
    for k,v in pairs(items) do
        if IsValid(v) then
            if v:GetNWBool("Hidden", false) then continue end 
            if v:GetNWInt("Stage", 0) >= 1 then
                if v:GetNWBool("IsCrystal", false) == true and v then
                    local typ = v:GetNWString("Name", "")
                    if string.find(typ, "Orange") then
                        table.insert(orange,v)
                    elseif string.find(typ, "Purple") then
                        table.insert(purple,v)
                    elseif string.find(typ, "Green") then
                        table.insert(green,v)
                    elseif string.find(typ, "Red") then
                        table.insert(red,v)
                    end
                end
            end
        end
    end
    local sel = LocalPlayer():GetNWEntity("SelectedDoor") 
    if IsValid(sel) then
        if not sel:IsPlayer() then 
            table.insert(door, sel)
        end
    end
	halo.Add(orange, Color(255, 128, 0), 5, 5, 2)
    halo.Add(purple, Color(128, 0, 255), 5, 5, 2)
    halo.Add(green, Color(0, 255, 0), 5, 5, 2)
    halo.Add(red, Color(255, 0, 0), 5, 5, 2)
    halo.Add(door, Color(0, 128, 128), 5, 5, 2)
end )
*/

local laser = Material("cable/redlaser")

hook.Add("HUDPaint", "BoundingBoxText", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not wep:IsValid() then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
	for _, self in pairs(ents.FindByClass("bounding_box")) do
        if LocalToWorld(self:OBBCenter(), Angle(0,0,0), self:GetPos(), Angle(0,0,0)):Distance(ply:GetPos()) <= 1000 then
            -- display text at the origin (self:GetLocation())
            if self:GetGeneric() then return end
            local text = self:GetLocation()
            surface.SetFont("BlackoutMarker")
            local w, h = surface.GetTextSize(text)
            local toscreen = (LocalToWorld(self:OBBCenter(), Angle(0,0,0), self:GetPos(), Angle(0,0,0))):ToScreen()
            surface.SetTextPos(toscreen.x - w/2, toscreen.y - h/2)
            surface.SetTextColor(255,255,255,255)
            surface.DrawText(text)
        end
    end
end)

-- need to hook into PreDrawOpaqueRenderables to do the same for some reason
hook.Add("PostDrawTranslucentRenderables", "DrawBoundingBox", function( bDepth, isSkybox )
	if isSkybox then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not wep:IsValid() then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
	for _, self in pairs(ents.FindByClass("bounding_box")) do
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		-- start the beam
		render.SetMaterial(laser)
		render.StartBeam(10)
		render.AddBeam(LocalToWorld(Vector(mins.x, mins.y, mins.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(mins.x, maxs.y, mins.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(maxs.x, maxs.y, mins.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(maxs.x, mins.y, mins.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(mins.x, mins.y, mins.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.EndBeam()
		render.StartBeam(10)
		render.AddBeam(LocalToWorld(Vector(mins.x, mins.y, maxs.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(mins.x, maxs.y, maxs.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(maxs.x, maxs.y, maxs.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(maxs.x, mins.y, maxs.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.AddBeam(LocalToWorld(Vector(mins.x, mins.y, maxs.z), Angle(), pos, ang), 8, 0, Color(255, 0, 0))
		render.EndBeam()
		-- add beams between the floor and ceiling
		render.DrawBeam(LocalToWorld(Vector(mins.x, mins.y, mins.z), Angle(), pos, ang), LocalToWorld(Vector(mins.x, mins.y, maxs.z), Angle(), pos, ang), 8, 0, 0, Color(255, 0, 0))
		render.DrawBeam(LocalToWorld(Vector(mins.x, maxs.y, mins.z), Angle(), pos, ang), LocalToWorld(Vector(mins.x, maxs.y, maxs.z), Angle(), pos, ang), 8, 0, 0, Color(255, 0, 0))
		render.DrawBeam(LocalToWorld(Vector(maxs.x, maxs.y, maxs.z), Angle(), pos, ang), LocalToWorld(Vector(maxs.x, maxs.y, mins.z), Angle(), pos, ang), 8, 0, 0, Color(255, 0, 0))
		render.DrawBeam(LocalToWorld(Vector(maxs.x, mins.y, maxs.z), Angle(), pos, ang), LocalToWorld(Vector(maxs.x, mins.y, mins.z), Angle(), pos, ang), 8, 0, 0, Color(255, 0, 0))
	end
end)

local outsidelocations = {
    ["Topside"] = true,
    ["Pump Station Alpha"] = true,
    ["Topside Security Booth"] = true,
    ["H.E.C.U Hazard Course"] = true,
    ["Topside Maintenance"] = true,
    ["Pump Station Alpha"] = true,
}

// SNOW FOG
hook.Add("SetupWorldFog", "ClientsideFogCreator", function()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if outsidelocations[ply:GetNWString("location")] then
        render.FogMode( MATERIAL_FOG_LINEAR )
        render.FogStart( 0 )
        render.FogEnd( 2600 )
        render.FogMaxDensity( 1.00 )
        render.FogColor( 175, 175, 175 )

        return true
    else
        return false
    end
end)
hook.Add("PreDrawSkyBox", "ClientsideSkyboxDisabler", function()
    
end)