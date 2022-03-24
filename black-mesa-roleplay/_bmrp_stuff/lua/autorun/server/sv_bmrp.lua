// Wildfire Black Mesa Roleplay
// File description: BMRP core script
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
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Every file needs this :)
include("autorun/sh_bmrp.lua")

AddCSLuaFile("bmrp_crafting.lua")

include("bmrp_ranks.lua")

// Variables

local BMRP_BETASERVER_CONVAR = CreateConVar("bmrp_betaserver", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable/Disable BMRP Beta Server")

// custom spawnflags pulled from https://developer.valvesoftware.com/wiki/Trigger_hurt#Flags
local SF_TRIGGER_CLIENTS = 1
local SF_TRIGGER_PHYSICS_OBJECTS = 8

// Basic hooks //
// This completely replaces the default ChatPrint system. With this, we can use SystemMessage instead and It's cool and orange.
// usage: hook.Run("SystemMessage", ply, "", "string")
hook.Add("SystemMessage", "HookSystemMessage", function(ply, prefix, msg)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if ply:GetNWBool("BMRP_SystemMessagesToggle", false) == true then return end
    local hsv = false
    if prefix == "HSV" then
        prefix = "BMRP"
        hsv = true
    elseif prefix == "" then
        prefix = "BMRP"
    end
    ply:ChatPrint("<icon 32,32>atlaschat/customemoticons/bms.png</icon> <c=91,91,91>["..prefix.."] |</c> "..(hsv and "<hsv>" or "<c=251,126,20>")..msg..(hsv and "</hsv>" or "</c>"))
    return true
    //<hsv>A RAINBOW crystal has appeared in Xen!</hsv>
end)

// Network over system messages
util.AddNetworkString("SystemMessage")
net.Receive("SystemMessage", function(len, ply)
    local message = net.ReadString()
    hook.Run("SystemMessage", ply, "", message)
end)

// ULX has a stupid announcements system, this allows us to make our own with system messages and AtlasChat.
local announcements = {
    "Make sure to join our Discord!: https://discord.gg/5gX3rdymxx",
    "We're looking for staff! Apply in our Discord!: https://discord.gg/5gX3rdymxx",
    "Wanna donate to get access to special content? Refer to our Discord for donations!",
    "If you notice any bugs please report them in our Discord!",
    "Someone breaking the rules with no staff online? Report them in our Discord!",
    "Have suggestions for the server? Share them in our Discord server!",
    "Have you previously donated but not received your perks? Refer to #donations in our Discord for more information!",
    "Seeing everything weird and glowy? Type mat_specular 0 in console!",
    "Need to report a player? Type @ followed by your message!",
}
timer.Create("AnnouncementLoop", 600, 0, function()
    for k,v in pairs(player.GetAll()) do
        v:ChatPrint("<icon 32,32>atlaschat/customemoticons/bms.png</icon> <c=91,91,91>[BMRP] |</c> <c=251,126,20>"..table.Random(announcements).."</c>")
    end
end)

// Allow the player to reset their sound using bmrp_resetsound
concommand.Add("bmrp_resetsound", function( ply, cmd, args )
    ply:SendLua("RunConsoleCommand(\"snd_restart\");print(\"[BMRP] Your sound has been reset! You should be able to hear more things now!\")")
end)

// GLOBAL TAKING DAMAGE HOOK //
local nodamageweps = {
    ["tfa_nmrih_sledge"] = true,
    ["tfa_nmrih_pickaxe"] = true,
}

local centeroflambda = Vector(-14131.059570313, 557.43719482422, -250) -- yeah just change this inside of sv_events.lua too
hook.Add("EntityTakeDamage", "BMRP_GlobalTakeDamage", function(target, dmg)
    if not IsValid(target) then return end
    if not target:IsPlayer() then return end
    if GetGlobalBool("SuckEveryoneIntoLambdaCore", false) == true then
        -- wait a minute, this could be inside of the lambda chamber during a meltdown!
        local dist = target:GetPos():Distance(centeroflambda) 
        if dist < 1000 and (dmg:IsFallDamage() or dmg:IsDamageType(DMG_SHOCK) or dmg:IsDamageType(DMG_ENERGYBEAM)) then
            return true
        end
    end
    // if the targets location is "Xen" then return no damage
    if target:GetNWString("location") == "Xen" then
        if dmg:IsFallDamage() then
            return true 
        end
    end
    local ply = dmg:GetAttacker()
    if not ply:IsPlayer() then return end
    local weapon = ply:GetActiveWeapon()
    local damage = dmg:GetDamage()
    if not IsValid(weapon) then return end
    // disable attacking for weapon classes inside of nodamageweps
    if nodamageweps[weapon:GetClass()] then return true end
    
end)
// GLOBAL HOOK FOR PLAYERSPAWN //
hook.Add("PlayerSpawn", "BMRP_PlayerSpawn", function(ply)
    local index = ply:EntIndex()
    local lastplayerhealth = ply:Health()
    ply:SetColor(Color(255,255,255,255)) // reset players color on spawn
    ply:SetMaterial("") // reset players material on spawn
    //enable crosshair and hud
    ply:SetNWBool("BMRP_CrosshairToggle", true)
    ply:SetNWBool("BMRP_HudToggle", true)
    ply:SetNWBool("BMRP_SystemMessages", true)
    timer.Create("Drown_"..index, 5, 0, function() // we want a unique index so we can delete it when you exit
        if not IsValid(ply) then return end
        if lastplayerhealth <= 1 then
            timer.Remove("Drown_"..index)
            ply:Kill()
        end
        if ply:WaterLevel() > 2 then
            if ply:CategoryCheck() ~= "xenian" and not ply:HEVSuitEquipped() then
                local dmg = DamageInfo() //drowning damage
                dmg:SetDamage(1)
                dmg:SetDamageType(DMG_DROWN)
                ply:TakeDamageInfo(dmg)
                ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 255, 10 ), 0.3, 0 )
                lastplayerhealth = ply:Health()
                hook.Run("PlayerDrowning", ply)
            end
        end
    end)
    // Everything down here tracks your HEV suit and model.
    if not ply:HEVSuitEquipped() then return end
    local lgm = ply:GetNWString("LastGoodModel")
    ply:RemoveSuit()
    if lgm == "" or lgm == nil then
        local jobtable = ply:getJobTable()
        lgm = jobtable.model
    end
    ply:SetModel(lgm)
    ply:SetNWString("LastGoodModel","")
end)
// GLOBAL PLAYER INITAL SPAWN HOOK //
hook.Add("PlayerInitialSpawn", "SoundReset", function(ply)
    timer.Simple( 15, function()
        //ply:ConCommand("bmrp_resetsound") 
        if not ply:HasPACAccess() then
            pace.ClearOutfit(ply)
            local steamid = ply:SteamID64()
            timer.Create("BMRP_NagNonPacAccess_"..steamid, 60, 0, function()
                if IsValid(ply) then
                    pace.ClearOutfit(ply)
                else
                    timer.Remove("BMRP_NagNonPacAccess_"..steamid)
                end
            end)
        end
    end)
end)
// GLOBAL PLAYER DEATH HOOK //
hook.Add("PlayerDeath", "BMRP_RemoveDrown1", function(ply)
    local index = ply:EntIndex()
    timer.Remove("Drown_"..index)
end)
// GLOBAL PLAYER DISCONNECTED HOOK //
hook.Add("PlayerDisconnected", "BMRP_RemoveDrown2", function(ply)
    local index = ply:EntIndex()
    timer.Remove("Drown_"..index)
end)

local elevatordelete = {
    "trainingsectorelev",
    "elebutton65",
    "eledoorstop",
    "elebutton64",
    "eledoorsbottom",
}

local clearlagcleanup = {
    ["xen_crystal"] = true,
    ["squidspit"] = true,
    ["bmrp_metal"] = true,
}

// GLOBAL ADD TO MAP RESET HOOK //
BMRP.AddToMapReset("BMRP_GlobalAddToMapReset", function()
    local thismap = BMRP.MAPS[game.GetMap()]
    // GROUND CRYSTAL REMOVER ANTI-LAG //
    timer.Remove("BMRP_GroundCrystalRemover")
    timer.Create("BMRP_GroundCrystalRemover", 1800, 0, function()
        if player.GetCount() <= 2 then return end
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "[WARNING!] All materials/crystals/gifts will be removed in 1 minute! Please pocket your crystals.")
        end
        timer.Simple(50, function()
            for k,v in pairs(player.GetAll()) do
                hook.Run("SystemMessage", v, "", "[WARNING!] All materials/crystals/gifts will be removed in 10 seconds! Please pocket your crystals.")
            end
            timer.Simple(10, function()
                for k,v in pairs(player.GetAll()) do
                    hook.Run("SystemMessage", v, "", "[WARNING!] All materials/crystals/gifts have been cleared!")
                end
                for k,v in pairs(ents.GetAll()) do
                    if clearlagcleanup[v:GetClass()] == true or v:GetNWBool("gift", false) == true then
                        v:Remove()
                    end
                end
            end)
        end)
    end)
    // SET ACHIEVEMENT HAT NAME //
    for k, v in pairs(ents.FindByModel("models/props_junk/tomabasarab_quaff.mdl")) do
        v:SetName("achievementhat")
    end
    // RAINBOW CRYSTAL SPAWNER // 
    timer.Remove("RandomRainbowCrystalTimer")
    local RAINBOW_CRYSTAL_TIMER = math.random(3600, 7200)
    timer.Create("RandomRainbowCrystalTimer", RAINBOW_CRYSTAL_TIMER, 0, function()
        local randomcrystals = ents.FindByClass("crystal_mine")
        local luckycrystal = table.Random(randomcrystals)
        if not IsValid(luckycrystal) then return end
        local type = luckycrystal.CrystalTypes[luckycrystal.RainbowCrystal]
        local fallbacktype = luckycrystal.CrystalTypes[math.random(1, luckycrystal.CrystalTypeLimit)]
        if not type then return end
        if not fallbacktype then return end
        luckycrystal:SetCrystalType(type[1])
        luckycrystal:SetColor(type[2])
        for k,v in pairs(player.GetAll()) do
            //DarkRP.notify(v, 3, 4, "A rainbow crystal has appeared! Find it in Xen and collect it for a bonus!")
            hook.Run("SystemMessage", v, "HSV", "A rainbow crystal has appeared! Find it in Xen and test it for a bonus!")
            v:SendLua("surface.PlaySound(\"friends/friend_online.wav\")")
        end
        local function fail()
            for k,v in pairs(player.GetAll()) do
                //DarkRP.notify(v, 3, 4, "The rainbow crystal has disappeared! Better luck next time!")
                hook.Run("SystemMessage", v, "HSV", "The rainbow crystal has disappeared! Better luck next time!")
                v:SendLua("surface.PlaySound(\"friends/friend_join.wav\")")
            end
        end
        -- 10 minutes
        timer.Simple(600, function()
            if not IsValid(luckycrystal) then return fail() end
            luckycrystal:SetCrystalType(fallbacktype[1])
            luckycrystal:SetColor(fallbacktype[2])
            fail()
        end)
    end)
    // Remove every flood water entity //
    for k,v in pairs(ents.FindByClass("func_water_analog")) do
        SetGlobalString("floodwater", v:GetModel())
        v:Remove()
    end
    // remove smoke
    for k,v in pairs(ents.FindByClass("func_smokevolume")) do
        v:Remove()
    end
    // Replace AMS cart with with ours
    for k,v in pairs(ents.FindByName(thismap.amscart)) do
        local amscart = ents.Create("ams_cart")
        amscart:SetPos(v:GetPos())
        amscart:SetAngles(v:GetAngles())
        amscart:Spawn()
        amscart:Activate()
        v:Remove()
    end
    for k, v in pairs(ents.FindByClass("env_lightglow")) do
        v:SetColor(Color(0,0,0))
    end
    //SNOW!!
    
    /*
    local info_target = ents.Create("info_target")
    info_target:SetPos(Vector(-6869.580566, -1420.507080, 700.961975))
    info_target:SetName("snow_start")
    info_target:Spawn()
    info_target:Activate()
    
    local snow = ents.Create("prop_dynamic")
    snow:SetModel("models/propper/displacement_overlay.mdl")
    snow:SetPos(Vector(-4595, -4828, -1076))
    snow:SetAngles(Angle(0,-90,0))
    snow:SetKeyValue("disableshadows", "1")
    snow:SetLightingOriginEntity(info_target)
    snow:SetName("SNOW")
    snow:Spawn()
    snow:SetColor(Color(155,155,155,155))
    */

    local skypaint = ents.Create("env_skypaint")
    skypaint:SetKeyValue("topcolor", "0.68 0.68 0.68")
    skypaint:SetKeyValue("bottomcolor", "0.68 0.68 0.68")
    skypaint:Spawn()
    skypaint:Activate()
    
    // Remove every elevator entity (TEMPORARY BY KIWI) //
    /*
    for k,v in pairs(elevatordelete) do
        for k2,v2 in pairs(ents.FindByName(v)) do
            v2:Remove()
        end
    end
    */
    // Disable death triggers permanently.
    for k,v in pairs ( ents.FindByName(thismap.deathtriggers) ) do
        v:Fire("Disable")
    end
    // slight bug: after every map reset sound breaks. This is a workaround.
    for k,v in pairs(player.GetAll()) do
        v:ConCommand("bmrp_resetsound") 
    end
    // Just a general global logic to be used on anything //
    local global = ents.Create("bmrp_logic")
    global:SetName("global_bmrp_logic")
    // Add outputs to global logic //
    local door = ents.FindByName(thismap.amsarm) // One of the AMS arms
    for k,v in pairs(door) do
        v:Input("AddOutput", nil, nil, "OnFullyOpen global_bmrp_logic:AmsCheckOpen::0:-1")
        v:Input("AddOutput", nil, nil, "OnClose global_bmrp_logic:AmsCheckClose::0:-1")
    end
    local trigger = ents.FindByName(thismap.amstrigger) // AMS cart trigger
    for k,v in pairs(trigger) do
        v:Input("AddOutput", nil, nil, "OnStartTouch global_bmrp_logic:AmsVoteForDisaster::0:-1")
    end
    local teletrigger1 = ents.FindByName(thismap.teletele) // Teleporter room trigger
    for k,v in pairs(teletrigger1) do
        v:Input("AddOutput", nil, nil, "OnStartTouch global_bmrp_logic:CrystalTeleport::0:-1")
    end
    // this is some door in the lambda chamber (4321)
    //ents.GetMapCreatedEntity(4321):Input("AddOutput", nil, nil, "OnFullyOpen global_bmrp_logic:LambdaFailure::0:-1")
    // THESE ARE THE DUMB MAINTENANCE DOORS // 
    for k,v in pairs(ents.FindByName(thismap.maintenancedoors)) do
        v:Fire("Unlock")
    end
    // hecu door
    for k,v in pairs(ents.FindByName(thismap.hecudoor)) do
        v:Fire("Unlock")
    end
end)
// DISABLE CROSSHAIR COMMAND //
concommand.Add("bmrp_crosshair", function(ply)
    if ply:GetNWBool("BMRP_CrosshairToggle") == true then
        ply:SetNWBool("BMRP_CrosshairToggle", false)
        hook.Run("SystemMessage", ply, "", "Crosshair disabled.")
    else
        ply:SetNWBool("BMRP_CrosshairToggle", true)
        hook.Run("SystemMessage", ply, "", "Crosshair enabled.")
    end
end)
// DISABLE HUD COMMAND //
concommand.Add("bmrp_hud", function(ply)
    if ply:GetNWBool("BMRP_HudToggle") == true then
        ply:SetNWBool("BMRP_HudToggle", false)
        hook.Run("SystemMessage", ply, "", "Hud disabled.")
    else
        ply:SetNWBool("BMRP_HudToggle", true)
        hook.Run("SystemMessage", ply, "", "Hud enabled.")
    end
end)
// DISABLE SYSTEM MESSAGES COMMAND //
concommand.Add("bmrp_messages", function(ply)
    if ply:GetNWBool("BMRP_SystemMessagesToggle") == true then
        ply:SetNWBool("BMRP_SystemMessagesToggle", false)
        DarkRP.notify(ply, 0, 4, "System messages disabled.")
    else
        ply:SetNWBool("BMRP_SystemMessagesToggle", true)
        DarkRP.notify(ply, 0, 4, "System messages enabled.")
    end
end)
hook.Add("PlayerLoadout", "BMRP_Loadout", function(ply)
    //ply:Give("weapon_wrappingpaper")
end)
// SUIT RECHARGERS //
hook.Add("PlayerUse", "BMRP_SuitRechargers", function(ply, ent)
    if not IsValid(ent) or not IsValid(ply) then return end
    if ent:GetNWBool("wrapped", false) == true then
        ent:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1,3)..".wav")
        ent:SetMaterial(ent:GetNWString("wrappeddefaultmat", ""))
        ent:SetNWBool("wrapped", false)
        local src = ent:GetNWEntity("wrapper")
        if IsValid(src) then
            hook.Run("SystemMessage", ply, "GIFTS", "You have unwrapped a present from "..src:Nick().."! ("..ent:GetClass()..")")
            hook.Run("SystemMessage", src, "GIFTS", ply:Nick().." has unwrapped your present! ("..ent:GetClass()..")")
        end
        return false
    end
    if ent:GetClass() == "func_recharge" then // func_recharges are suit rechargers scattered throughout the map.
        if ply:CategoryCheck() == "xenian" then return end
        if not ply:HEVSuitEquipped() and ply.debounce == false then
            ply.debounce = true
            timer.Simple(3, function()
                ply.debounce = false
            end)
            hook.Run("SystemMessage", ply, "", "**H.E.V GENERAL FAILURE: PLEASE REVIEW H.E.V MANUAL TO CONTINUE.**")
            ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")
            ply:SendLua("surface.PlaySound(\"hl1/fvox/hev_general_fail.wav\")")
        end
        return false
    end
end)

// Gravgun stuff for halos
hook.Add("GravGunOnPickedUp", "BMRP_StartGravGunning", function(ply, ent)
    if not IsValid(ply) then return end
    if not IsValid(ent) then return end
    ply:SetNWBool("BMRP_IsGravGunning", true)
    ply:SetNWEntity("BMRP_GravGunTarget", ent)
    if ent:GetClass() == "spare_parts" then
        -- check if their darkrp job is maintenance
        if team.GetName(ply:Team()) ~= "Facility Maintenance" then
            ply:SetNWBool("BMRP_IsGravGunning", false)
            ply:SetNWEntity("BMRP_GravGunTarget", nil)
            ent:ForcePlayerDrop()
            DarkRP.notify(ply, 1, 4, "You can only pick up repair boxes as Facility Maintenance.")
            return false
        end
    end
end)
hook.Add("GravGunOnDropped", "BMRP_EndGravGunning", function(ply, ent)
    if not IsValid(ply) then return end
    if not IsValid(ent) then return end
    ply:SetNWBool("BMRP_IsGravGunning", false)
    ply:SetNWEntity("BMRP_GravGunTarget", nil)
end)
hook.Add("canPocket", "BMRP_PocketHook", function(ply, ent)
    if not IsValid(ply) then return end
    if ply.darkRPPocket ~= nil then
        if #ply.darkRPPocket >= 4 then
            DarkRP.notify(ply, 1, 4, "You can't fit any more items in your pocket!")
            return false
        end
    end
    if not IsValid(ent) then return end
    -- materials
    if ent:GetClass() == "xen_crystal" and ent.GetCrystalType ~= nil then
        if ent:CPPIGetOwner() ~= ply then
            if IsValid(ent:CPPIGetOwner()) then
                if ent:CPPIGetOwner():IsPlayer() then
                    DarkRP.notify(ent:CPPIGetOwner(), 1, 4, ply:Nick() .. " has pocketed your "..ent:GetCrystalType() .. " Crystal.")
                end
            end
        end
        return true
    elseif ent.GetCraftingMaterialType ~= nil then
        if ent:CPPIGetOwner() ~= ply then
            if IsValid(ent:CPPIGetOwner()) then
                if ent:CPPIGetOwner():IsPlayer() then
                    DarkRP.notify(ent:CPPIGetOwner(), 1, 4, ply:Nick() .. " has pocketed your "..ent:GetCraftingMaterialType() .. " Scrap.")
                end
            end
        end
        return true
    end
    -- cppi check for everything that isn't a material
    if ent:CPPIGetOwner() ~= ply then return false, "You can only pocket your own stuff." end
    if ent:GetClass() == "spare_parts" then
        if team.GetName(ply:Team()) ~= "Facility Maintenance" then
            return false, "You can only pocket repair boxes as Facility Maintenance."
        else
            return true
        end
    end
end)
hook.Add("playerBoughtCustomEntity", "BMRP_cppiownership", function(ply, enttable, ent, price)
    if not IsValid(ply) then return end
    if not IsValid(ent) then return end
    ent:CPPISetOwner(ply)
end)
hook.Add("onPocketItemDropped", "BMRP_cppiownership_pocket", function(ply, ent, num, id)
    if not IsValid(ply) then return end
    if not IsValid(ent) then return end
    ent:CPPISetOwner(ply)
end)

-- location check
local nextprocessdelay = 2 // Making this a variable just in-case it causes weird lag.
local nextprocess = os.time() + nextprocessdelay
local zero = Angle(0,0,0)
hook.Add("Think", "LocationUpdate", function()
	if nextprocess < os.time() then
        for k,v in pairs(player.GetAll()) do
            local notinany = true
            local pos = v:GetPos()
            for k2, v2 in pairs(ents.FindByClass("bounding_box")) do
                if v2:GetGeneric() then continue end
                local pos2 = v2:GetPos()
                local mins, maxs = v2:WorldSpaceAABB()
                local priority = v2:GetPriority()
                local location = v2:GetLocation()
                if pos:WithinAABox(mins, maxs) then
                    notinany = false
                    if v:GetNWInt("locationpriority") < priority then
                        v:SetNWString("location", location)
                        v:SetNWInt("locationpriority", priority)
                    end
                elseif LocalToWorld(v2:OBBCenter(), zero, pos2, zero):Distance(pos) > 1000 then
                    notinany = false
                end
            end
            if notinany then
                for k,v in pairs(player.GetAll()) do
                    v:SetNWString("location", "???")
                    v:SetNWInt("locationpriority", -99)
                end
            end
        end
		nextprocess = os.time() + nextprocessdelay
	end
end)

local droppableweapons = {
    ["weapon_hlof_displacer"] = true,
    ["weapon_hl_gauss"] = true,
    ["weapon_hl_egon"] = true,
}

hook.Add("DoPlayerDeath", "DisplacerDrop", function(ply, attacker, dmginfo)
    if not IsValid(ply) then return end
    for _, wep in pairs(ply:GetWeapons()) do
        if droppableweapons[wep:GetClass()] then
            ply:DropWeapon(wep)
            wep:CPPISetOwner(ply) -- fix wrapping weapons
        end
    end
end)

// enforce banned ip addresses
hook.Add( "PlayerInitialSpawn", "banip", function( ply )
    local ipaddress = ply:IPAddress()
	for _, bannedip in pairs(BMRP.PLAYERS.BANNEDIPS) do
        if ipaddress == bannedip then
            print("[BMRP] " .. name .. " attempted to join but is banned by IP.")
            ply:Kick("You are not welcome here.")
            return
        end
    end
    local name = ply:Nick()
    local steamname = ply:SteamName()
    for _, forbiddenname in pairs(BMRP.FORBIDDEN_NAMES) do
        if string.find(string.lower(name), string.lower(forbiddenname)) then
            print("[BMRP] " .. name .. " attempted to join but their name is banned.")
            ply:Kick("You are not welcome here.")
            return
        elseif string.find(string.lower(steamname), string.lower(forbiddenname)) then
            print("[BMRP] " .. name .. " attempted to join but their steam name is banned.")
            ply:Kick("You are not welcome here.")
            return
        end
    end
end )
