// Wildfire Black Mesa Roleplay
// File description: BMRP event handler script
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

// RANDOM EVENTS //
local eventcommands = {
    "poweroutage",
    "flood",
    //"lambdafailure",
}

// 8,971 means 8,929 -- as in "8929 University Center Ln San Diego, CA 92122"
// plus 42, the answer to the ultimate question of life, the universe, and everything
// aka 8971
// this is also known as dumb
local dumb = 8971
timer.Create("EventLoop", dumb, 0, function()
    if GetGlobalBool("blackoutpp", false) == true then return end
    if GetGlobalBool("flood", false) == true then return end
    
    local event = eventcommands[math.random(1, #eventcommands)]
    if #player.GetAll() >= 1 then
        print("[BMRP] Starting "..event.." event...")
        hook.Run(event)
    else
        print("[BMRP] Event "..event.." failed. Not enough players...")
    end
end)

// POWER OUTAGE EVENT //
local voxpower = { // auto vox announcer
    {0, "warning"},
    {1.25, "warning"},
    {2.5, "power"},
    {3.25, "failure"},
}

local lightglowtable = {}

function poweroutage()
    for k,v in ipairs( player.GetAll() ) do
        hook.Run("SystemMessage", v, "", "Black Mesa sectors A-G total power failure. Restart the auxiliary generators throughout the facility. (Sector A, Sector C, Administration, & Topside.)")
    end
    timer.Simple(3.6, function()
        hook.Run("RunVoxTable", voxpower, "vox")
    end)
    LightsOff()
    blackoutredalert()
    SetGlobalBool("blackoutpp", true)
    for k,v in pairs(ents.FindByClass("event_power_box")) do
        v:SetActivated(false)
    end
end

function LightsOff()
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in ipairs( player.GetAll() ) do
        v:SendLua("surface.PlaySound(\"wildfire/poweroutage.wav\")")
    end
    local names = {}
    timer.Simple(0.05, function()
        for k2,v2 in ipairs(thismap.blackoutlights) do 
            for k,v in ipairs(ents.FindByName(v2)) do
                v:Fire("TurnOff")
                v:Fire("SetPattern", "a")
            end
        end
        for k2,v2 in ipairs(thismap.turnonduringblackout) do 
            for k,v in pairs(ents.FindByName(v2)) do
                v:Fire("TurnOn")
            end
        end
        for k,v in ipairs(ents.FindByName(thismap.lambdabutton)) do
            v:Fire("Use")
        end
        for k, v in pairs(ents.FindByClass("env_lightglow")) do
            lightglowtable[v:EntIndex()] = v:GetColor()
            v:SetColor(Color(0,0,0))
        end
    end)
end
function LightsOn()
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in ipairs( player.GetAll() ) do
        v:SendLua("surface.PlaySound(\"wildfire/powerstartup.wav\")")
    end
    timer.Remove("FancyBlackout")
    local lightsbrightness = 0
    for k2,v2 in ipairs(thismap.blackoutlights) do 
        for k,v in ipairs(ents.FindByName(v2)) do
            v:Fire("Enable")
            v:Fire("TurnOn")
            //v:Fire("FadeToPattern", "b")
            timer.Simple(2, function()
                v:Fire("FadeToPattern", "z")
            end)
        end
    end
    for k2,v2 in ipairs(thismap.turnonduringblackout) do 
        for k,v in pairs(ents.FindByName(v2)) do
            v:Fire("TurnOff")
        end
    end
    for k, v in pairs(ents.FindByClass("env_lightglow")) do
        v:SetColor(lightglowtable[v:EntIndex()] or Color(255,255,255))
    end
end
// Staff command that will force start a blackout.
concommand.Add("bmrp_blackout", function(ply, args)
    if ply:IsStaff() then 
        poweroutage()
    end  
end)
// Staff command that will let players end the blackout manually.
concommand.Add("bmrp_endblackout", function(ply, args)
    if not ply:IsStaff() then return end
    if GetGlobalBool("blackoutpp", false) == true then
        SetGlobalBool("blackoutpp", false)
        for k,v in pairs( player.GetAll() ) do
            hook.Run("SystemMessage", v, "", "Black Mesa facility auxiliary generators engaged. Power restored in sectors A-G.")
            v:SendLua("surface.PlaySound(\"ambient/machines/spinup.wav\")")
        end
        LightsOn()
        unredalert()
        for k,v in pairs(ents.FindByClass("event_power_box")) do
            v:SetActivated(true)
        end
    else
        hook.Run("SystemMessage", ply, "", "Command failed. Event is NOT active.")
    end
end)
// Just a simple hook that will start the function for the power outage. LUA is dumb so If we don't do It like this the server crashes.
hook.Add("poweroutage", "PowerOutageStarter", function()
	poweroutage()
end)

// FLOOD EVENT //
local voxwater = { // auto vox announcer
    {0, "warning"},
    {1.25, "warning"},
    {2.5, "rapid"},
    {3.25, "water"},
    {4, "disposal"},
    {5, "evacuate"},
    {6, "immediately"},
}

local floodpos = Vector(-17368, 824, -2193)
local floodoffset = 4342
local floodyoffset = -664
local floodspeed = 4
local flooddistance = 1922

function flood()
    hook.Run("RunVoxTable", voxwater, "vox")
    timer.Simple( 7, function() 
        for k,v in pairs( player.GetAll() ) do
            hook.Run("SystemMessage", v, "", "Rapid flood water detected in the facility. Evacuate immediately.")
            v:SendLua("surface.PlaySound(\"ambient/machines/floodgate_stop1.wav\")")
        end
        SetGlobalBool("flood", true)
        // Activate a lockdown If water is in the facility
        redalert()
    end )
    // Let's start the flood event
    local allents = ents.FindByClass("func_water_analog")
    for k,v in pairs(allents) do
        v:Remove() // Remove every flood water entity before we create new ones
    end
    for i = 1, 30 do
        local ent = ents.Create("func_water_analog") //ents.Create("flood_water")
        ent:SetModel(GetGlobalString("floodwater"))
        local offset = Vector(floodoffset * i, 0, 0)
        // This is messy, but it works
        // We're trying to make a grid pattern and then rise up a level each 10 entities
        if i > 5 and i <= 10 then
            offset = Vector(floodoffset * (i - 5), -floodoffset, 0)
        elseif i > 10 and i <= 15 then
            offset = Vector(floodoffset * (i - 10), 0, floodyoffset)
        elseif i > 15 and i <= 20 then
            offset = Vector(floodoffset * (i - 15), -floodoffset, floodyoffset)
        elseif i > 20 and i <= 25 then
            offset = Vector(floodoffset * (i - 20), 0, floodyoffset*2)
        elseif i > 25 and i <= 30 then
            offset = Vector(floodoffset * (i - 25), -floodoffset, floodyoffset*2)
        end
        ent:SetPos(floodpos + offset)
        ent:SetKeyValue("movedir", "-90") // Up
        ent:SetKeyValue("movedistance", ""..flooddistance) // This will raise up to the at least the top of the lambda chamber
        ent:SetKeyValue("speed", ""..floodspeed) // Should be fine for the water level
        ent:Spawn()
        ent:Activate()
        if i > 10 then
            ent:SetNoDraw(true) // Make all entities below the surface layer invisible
        end
        ent:Fire("Open") // Start the water flood
    end
    // Wait for the facility to be completely flooded
    // inches (hammer units) / inches per second
    timer.Simple( flooddistance/floodspeed, function() 
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "The water pressure has fully stabilized. The pumps can now be initiated at Pump Station Alpha!")
        end
        SetGlobalBool("completelyflooded", true)
    end )
end
// Just a simple hook that will start the function for the flood. LUA is dumb so If we don't do It like this the server crashes.
hook.Add("flood", "FloodStarter", function()
	flood()
end)

// DEBUG COMMANDS
concommand.Add("thereissomuchwaterohmygodpleasewhy", function(ply, args)
    if ply:IsStaff() then
        floodspeed = 4
        flood() // Start the flood event
    end
end)

concommand.Add("quickflood", function(ply, args)
    if ply:IsStaff() then
        floodspeed = 100
        flood() // Start the flood event
    end
end)


// LAMBDA CORE FAILURE EVENT //
local voxlambda = { // auto vox announcer
    {0, "bizwarn"},
    {1, "bizwarn"},
    {2.5, "warning"},
    {3.50, "warning"},
    {5, "lambda"},
    {6, "failure"},
    {7, "evacuate"},
    {8, "chamber"},
    {9, "immediately"},
    {10, "bizwarn"},
    {11, "bizwarn"},
}

local voxlambda2 = { // auto vox announcer
    {0, "lambda"},
    {1, "chamber"},
    {2, "secured"},
}

// Just a simple hook that will start the function for the flood. LUA is dumb so If we don't do It like this the server crashes.
hook.Add("lambdafailure", "LambdaFailureStarter", function()
    LambdaFailure()
end)
local centeroflambda = Vector(-14131.059570313, 557.43719482422, -250) -- yeah just change this inside of sv_bmrp.lua too
function LambdaFailure()
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in pairs(player.GetAll()) do
        v:SendLua("surface.PlaySound(\"ambient/explosions/citadel_end_explosion1.wav\")")
    end
    timer.Simple(4, function()
        SetGlobalBool("LambdaFailureClearance", true)
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "WARNING, BLACK MESA LAMBDA REACTOR FAILURE. GRAVITY CONTROL SYSTEMS DISENGAGED.")
        end
        hook.Run("RunVoxTable", voxlambda, "vox")
        for k2, v2 in ipairs(thismap.lambdalightson) do
            for k,v in pairs(ents.FindByName(v2)) do
                v:Fire("TurnOff")
            end
        end
        for k2, v2 in ipairs(thismap.lambdalightsoff) do
            for k,v in pairs(ents.FindByName(v2)) do
                v:Fire("TurnOn")
                v:Fire("SetPattern", "abcdefghijklmnopqrrqponmlkjihgfedcba")
            end
        end
        for k,v in pairs(ents.FindByName(thismap.lambdadoor)) do
            v:SetKeyValue("wait", "-1")
            v:Fire("Open")
            v:Fire("Lock")
        end
    end)
    timer.Simple(15, function()
        redalert()
        SetGlobalBool("SuckEveryoneIntoLambdaCore", true)
        local explosion = ents.Create("env_explosion")
        explosion:SetKeyValue("iMagnitude", "0")
        explosion:SetKeyValue("rendermode", "5")
        explosion:SetPos(centeroflambda)
        explosion:Spawn()
        explosion:Fire("Explode")
        local shake = ents.Create("env_shake")
        shake:SetKeyValue("amplitude", "2000")
        shake:SetKeyValue("radius", "2000")
        shake:SetKeyValue("duration", "5")
        shake:SetKeyValue("frequency", "255")
        shake:SetPos(centeroflambda)
        shake:Spawn()
        shake:Fire("StartShake")
        timer.Simple(5, function()
            if not IsValid(shake) then return end
            shake:Fire("StopShake")
            shake:Remove()
        end)
        // set wacky beams (again)
        local beam = ents.Create("env_beam")
        beam:SetName("lambda_wacky_beam")
        beam:SetKeyValue("BoltWidth", "7.5")
        beam:SetKeyValue("framerate", "200")
        beam:SetKeyValue("framestart", "2")
        beam:SetKeyValue("life", ".25")
        beam:SetKeyValue("NoiseAmplitude", "10.4")
        beam:SetKeyValue("Radius", "500")
        beam:SetKeyValue("TextureScroll", "35")
        beam:SetKeyValue("renderamt", "200")
        beam:SetKeyValue("rendercolor", "247 199 9")
        beam:SetKeyValue("LightningStart", "bigtele_zap01c")
        beam:SetKeyValue("StrikeTime", "-.5")
        beam:SetKeyValue("Texture", "sprites/lgtning.spr")
        beam:SetKeyValue("TextureScroll", "10")
        beam:SetKeyValue("damage", "2")
        beam:SetKeyValue("spawnflags", "1")
        beam:Spawn()
        beam:Activate()
    end)
end

function ResetLambda()
    local thismap = BMRP.MAPS[game.GetMap()]
    unredalert()
    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "Black Mesa Lambda Reactor gravity control systems engaged. Please return to normal duties.")
    end
    hook.Run("RunVoxTable", voxlambda2, "vox")
    for k2, v2 in ipairs(thismap.lambdalightson) do
        for k,v in pairs(ents.FindByName(v2)) do
            v:Fire("TurnOn")
        end
    end
    for k2, v2 in ipairs(thismap.lambdalightsoff) do
        for k,v in pairs(ents.FindByName(v2)) do
            v:Fire("TurnOff")
            v:Fire("SetPattern", "a")
        end
    end
    for k,v in pairs(ents.FindByName(thismap.lambdadoor)) do
        v:SetKeyValue("wait", "5")
        v:Fire("Close")
        v:Fire("Unlock")
    end
    for k,v in pairs(ents.FindByName(thismap.lambdabutton)) do
        v:Fire("Use")
    end
    -- remove wacky beams
    for k,v in pairs(ents.FindByName("lambda_wacky_beam")) do
        v:Remove()
    end
    SetGlobalBool("SuckEveryoneIntoLambdaCore", false)
    SetGlobalBool("LambdaFailureClearance", false)
end

hook.Add("Think", "BMRP_UniversalThink", function()
    for k,v in pairs(player.GetAll()) do
        if GetGlobalBool("SuckEveryoneIntoLambdaCore", false) == true then
            // suck them into it over time
            local dist = v:GetPos():Distance(centeroflambda)
            local force = (centeroflambda - v:GetPos()) * 0.1
            if dist > 1000 then
                // If you have an H.E.V suit, reset your jumping power.
                if v:HEVSuitEquipped() then
                    v:SetJumpPower(200) // Prevent jumping
                    v:SetRunSpeed(240) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
                    v:SetWalkSpeed(160) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
                end
                continue
            end
            // If you have an H.E.V suit, Lambda core has no effect and you can't jump.
            if v:HEVSuitEquipped() then
                v:SetJumpPower(0) // Prevent jumping
                v:SetRunSpeed(70) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
                v:SetWalkSpeed(70) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
                continue
            end
            if dist < 100 then
                v:SetVelocity(force * -1 + (Vector(math.random(-100,100),math.random(-100,100),math.random(-100,150))))
            else -- 200 to 1000
                v:SetVelocity(force * 1 + (Vector(math.random(-100,100),math.random(-100,100),math.random(-100,150))))
            end
            if v:OnGround() then
                v:SetPos(v:GetPos()+Vector(0,0,1))
            end
        elseif v:HEVSuitEquipped() then
            v:SetJumpPower(200) // Prevent jumping
            v:SetRunSpeed(240) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
            v:SetWalkSpeed(160) // Set your walk, sprint, and alt+walk speeds to something really slow. "Magnetic" effect.
        end
    end
end)

concommand.Add("bmrp_lambdafailure", function(ply, args)
    if ply:IsStaff() then 
        LambdaFailure()
    end  
end)
concommand.Add("bmrp_resetlambda", function(ply, args)
    if ply:IsStaff() then 
        ResetLambda()
    end  
end)

// NUKE EVENT >:)
// buzwarn buzwarn Attention code black atomic alpha armory authorized buzwarn buzwarn military
local voxnuke = { // auto vox announcer
    {0, "buzwarn"},
    {0.7, "buzwarn"},
    {1.7, "attention"},
    {2.6, "code"},
    {3.3, "black"},
    {3.9, "atomic"},
    {4.7, "alpha"},
    {5.4, "armory"},
    {6.1, "authorized"},
    {7.1, "buzwarn"},
    {7.8, "buzwarn"},
}


local delay = 90

function NukeEvent()
    if not GetGlobalBool("ResonanceCascade", false) then return end
    if GetGlobalBool("NukeEvent", false) == true then return end
    hook.Run("RunVoxTable", voxnuke, "vox")
    SetGlobalBool("NukeEvent", true)
    local newdelay = delay+10
    -- remove one millisecond from newdelay every millisecond
    timer.Create("StupidNukeTimer", 1/(1 / engine.TickInterval()), (delay+10)*(1 / engine.TickInterval()), function()
        newdelay = newdelay - 1/(1 / engine.TickInterval())
        SetGlobalInt("NukeTimer", newdelay)
    end)
    for k,v in pairs(player.GetAll()) do
        v:SendLua("surface.PlaySound(\"bm_alarms/fo_alarm.wav\")")
    end
    timer.Simple(10, function()
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "The Facility Administrator has authorized the Alpha Warhead for detonation in T-Minus 90 seconds.")
        end
        redalert()
        closeblastdoors()
        local shakeitup = ents.Create("env_shake")
        shakeitup:SetKeyValue("amplitude", "2000")
        shakeitup:SetKeyValue("spawnflags", "4")
        shakeitup:SetKeyValue("radius", "2000")
        shakeitup:SetKeyValue("duration", "1000")
        shakeitup:SetKeyValue("frequency", "255")
        shakeitup:SetName("NUKE")
        shakeitup:SetPos(Vector(0,0,0))
        shakeitup:Spawn()
        shakeitup:Activate()
        shakeitup:Fire("StartShake")
        if IsValid(shakeitup) then
            shakeitup:Fire("StopShake")
            shakeitup:Remove()
        end
        timer.Simple(60, function()
            for k,v in pairs(player.GetAll()) do
                v:SendLua("surface.PlaySound(\"wildfire/sadsong.wav\")")
            end
        end)
        timer.Simple(delay, function()
            if GetGlobalBool("NukeEvent", false) == false then return end
            timer.Remove("StupidNukeTimer")
            SetGlobalInt("NukeTimer", 0)
            for k,v in pairs(player.GetAll()) do
                v:SendLua("surface.PlaySound(\"ambient/explosions/citadel_end_explosion1.wav\")")
                v:ScreenFade( SCREENFADE.OUT, Color( 251, 126, 20 ), 2, 3.1 )
            end
            timer.Simple(3, function()
                for k, v in pairs(player.GetAll()) do
                    local explosion = ents.Create("env_explosion")
                    explosion:SetKeyValue("iMagnitude", "0")
                    explosion:SetKeyValue("rendermode", "5")
                    explosion:SetPos(v:GetPos())
                    explosion:Spawn()
                    explosion:Fire("Explode")
                    timer.Simple(1, function()
                        v:ScreenFade( SCREENFADE.IN, Color( 251, 126, 20 ), 2, 0 )
                    end)
                    v:SetPos(v:GetPos()+Vector(0,0,1))
                    v:SetVelocity(Vector(0,0,1000))
                    v:Kill()
                    v:Spawn()
                    v:SendLua("RunConsoleCommand(\"snd_restart\")")
                    v:SendLua("surface.PlaySound(\"ambient/explosions/explode_8.wav\")")
                end
                unredalert()
                openblastdoors()
                hook.Run("EndResonanceCascade")
                SetGlobalBool("NukeEvent", false)
            end)
        end)
        timer.Simple(delay+2, function()
            if GetGlobalBool("NukeEvent", false) == false then return end
            /*
            local newfloodpos = Vector(floodpos.x, floodpos.y, 700)
            local allents = ents.FindByClass("func_smokevolume")
            for k,v in pairs(allents) do
                v:Remove() // Remove every flood water entity before we create new ones
            end
            for i = 1, 30 do
                local ent = ents.Create("func_smokevolume") //ents.Create("flood_water")
                ent:SetModel(GetGlobalString("floodwater"))
                local offset = Vector(floodoffset * i, 0, 0)
                // This is messy, but it works
                // We're trying to make a grid pattern and then rise up a level each 10 entities
                if i > 5 and i <= 10 then
                    offset = Vector(floodoffset * (i - 5), -floodoffset, 0) 
                elseif i > 10 and i <= 15 then
                    offset = Vector(floodoffset * (i - 10), 0, floodyoffset)
                elseif i > 15 and i <= 20 then
                    offset = Vector(floodoffset * (i - 15), -floodoffset, floodyoffset)
                elseif i > 20 and i <= 25 then
                    offset = Vector(floodoffset * (i - 20), 0, floodyoffset*2)
                elseif i > 25 and i <= 30 then
                    offset = Vector(floodoffset * (i - 25), -floodoffset, floodyoffset*2)
                end
                ent:SetPos(newfloodpos + offset)
                ent:SetKeyValue("Color1", "0 0 0")
                ent:SetKeyValue("Color2", "0 0 0")
                ent:SetKeyValue("Density", "1")
                ent:SetKeyValue("DensityRampSpeed", "1")
                ent:SetKeyValue("material", "particle/smokesprites_0012")
                ent:SetKeyValue("MovementSpeed", "10")
                ent:SetKeyValue("ParticleDrawWidth", "120")
                ent:SetKeyValue("ParticleSpacingDistance", "80")
                ent:SetKeyValue("RotationSpeed", "10")
                ent:SetKeyValue("spawnflags", "0")
                ent:Spawn()
                ent:Activate()
            end
            */
        end)
    end)
end

hook.Add("FunnyPadGranted", "NukeEventHook", NukeEvent)

function ResetNukeEvent()
    SetGlobalBool("NukeEvent", false)
    for k,v in ipairs(ents.FindByName("NUKE")) do
        v:Fire("StopShake")
        v:Remove()
    end
    for k,ply in ipairs(player.GetAll()) do
        ply:SendLua("RunConsoleCommand(\"snd_restart\")")
    end
    timer.Destroy("StupidNukeTimer")
    hook.Run("EndResonanceCascade")
end

concommand.Add("bmrp_nuke", function(ply, args)
    if not ply:IsStaff() then return end
    if GetGlobalBool("NukeEvent", false) == true then
        ResetNukeEvent()
        DarkRP.notify(ply, 1, 4, "Nuke event has been reset.")
    else
        NukeEvent()
        DarkRP.notify(ply, 1, 4, "Nuke event has started.")
    end
end)