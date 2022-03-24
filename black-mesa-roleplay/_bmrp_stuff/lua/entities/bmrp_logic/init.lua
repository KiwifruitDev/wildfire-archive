// Wildfire Black Mesa Roleplay
// File description: BMRP server-side global logic entity script
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

include("shared.lua")
AddCSLuaFile("shared.lua")

// Every file needs this :)
include("autorun/sh_bmrp.lua")

local amslocations = {
    ["Upper AMS"] = true,
    ["AMS Control Room"] = true,
    ["AMS Labs"] = true,
}

local function errorout(message)
    for k,v in pairs(player.GetAll()) do
        local location = v:GetNWString("location") or "Unknown"
        if amslocations[location] then
            DarkRP.notify(v, 0, 4, message)
        end
    end
end

function SampleBad(self)
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in pairs(ents.FindByName(thismap.cascadebeam)) do
        v:Remove()
    end
    for k,v in pairs(ents.FindByName(thismap.amscart)) do
        local amscrystal = v:GetChildren()[1]
        v:SetPos(thismap.samplebadvec)
        v:SetAngles(Angle(0, 140, 0))
        
        v:SetInsideAMS(false)
        v:SetHasCrystal(false)
        v:ForcePlayerDrop()

        amscrystal:SetParent(nil)
        amscrystal:SetName("")
        amscrystal:SetPos(thismap.samplebadcrystalvec) // pop the crystal out of the cart
        amscrystal:SetAngles(Angle(0, 0, 0))
        local phys = amscrystal:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
        end

        if self:GetAfterTheFact() == true then
            self:SetAfterTheFact(false)
            amscrystal:SetAMSTested(true)
        end

    end
end

function SampleGood()
    for k,v in pairs(ents.FindByName(thismap.amscart)) do
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            v:DropToFloor()
            v:SetAngles(Angle(0, v:GetAngles().y, 0))
            v:ForcePlayerDrop()
        end
    end
end

// This disables the second stage of the AMS, we're using this after failed crystal attempts and other things.
local amsstage2 = {
    {"probe_arm_1", "Close"},
    {"probe_arm_2", "Close"},
    {"probe_arm_3", "Close"},
    {"secondbutton", "PressOut"},
}
function TurnOffSecondStage()
    for k1,v1 in ipairs( amsstage2 ) do
        for k,v in pairs( ents.FindByName(v1[1]) ) do
            v:Fire(v1[2])
        end
    end
end

// Everything below here is AMS-specific things that get disabled post-cascade. NOT cascade elements.
function TurnOffAMS()
    local thismap = BMRP.MAPS[game.GetMap()]
    for k1,v1 in ipairs( thismap.amsdisables ) do
        for k,v in pairs( ents.FindByName(v1[1]) ) do
            v:Fire(v1[2])
        end
    end
    CloseSample()
end

// This closes the sample tray and respawns the AMS cart down below. SHOULD ONLY BE CALLED IF YOU ARE SURE YOU NEED TO FULLY RESET THE AMS CART.
function CloseSample()
    local thismap = BMRP.MAPS[game.GetMap()]
    for k2, v2 in pairs(thismap.amsclose ) do
        for k,v in pairs (ents.FindByName(v2)) do
            v:Fire("Close")
        end
    end
    timer.Simple(3, function()
        for k,v in pairs (ents.FindByName(thismap.amslift)) do 
            v:Fire("Close")
        end
    end)
    timer.Simple(6, function()
        for k,v in pairs (ents.FindByName("not_sample_cart2")) do // This won't work If the sample cart is valid. Remove the crystal first and set the sample cart back to normal.
            v:SetPos(thismap.ogcartpos)
            v:SetAngles(Angle(0, 0, 0))
            local phys = v:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:Wake()
            end
        end
    end)
    for k,v in pairs (ents.FindByName(thismap.amsopen)) do
        v:Fire("Open")
    end
end

function ENT:AcceptInput(inputname, activator, caller, data)
    // AMS "Doors" //
    local thismap = BMRP.MAPS[game.GetMap()]
    if inputname == "AmsCheckOpen" then
        if GetGlobalBool("ams_shutdown", false) == false then
            for k,v in pairs(ents.FindByName("sample_cart2")) do
                local rand = math.random(1, 100)
                local amscrystal = v:GetChildren()[1]
                if not IsValid(amscrystal) then continue end
                v:SetInsideAMS(true)
                // delete beams_2 if present
                if timer.Exists("RainbowWackyBeams") then
                    timer.Remove("RainbowWackyBeams")
                end
                for k,v in pairs(ents.FindByName(thismap.cascadebeam)) do
                    v:Remove()
                end
                timer.Simple(2, function()
                    // set wacky beams (beam_2)
                    amscrystal:EmitSound("ambient/machines/teleport3.wav", 100, 100)
                    amscrystal:SetName("wack")
                    local newbeam = ents.Create("env_beam")
                    newbeam:SetName("beam_2")
                    newbeam:SetKeyValue("LightningStart", "zapper")
                    newbeam:SetKeyValue("Texture", "sprites/lgtning.spr")
                    newbeam:SetKeyValue("BoltWidth", "7.5")
                    newbeam:SetKeyValue("framerate", "200")
                    newbeam:SetKeyValue("framestart", "2")
                    newbeam:SetKeyValue("life", "0")
                    newbeam:SetKeyValue("NoiseAmplitude", "16")
                    newbeam:SetKeyValue("Radius", "256")
                    newbeam:SetKeyValue("renderamt", "200")
                    newbeam:SetKeyValue("spawnflags", "1")
                    newbeam:SetKeyValue("StrikeTime", "20")
                    newbeam:SetKeyValue("TextureScroll", "10")
                    newbeam:SetKeyValue("decalname", "Bigshot")
                    newbeam:SetKeyValue("LightningEnd", "wack")
                    newbeam:SetKeyValue("rendercolor", amscrystal:GetColor().r.." "..amscrystal:GetColor().g.." "..amscrystal:GetColor().b)
                    newbeam:Spawn()
                    newbeam:Activate()
                    newbeam:Fire("Toggle", "", 0)
                    timer.Create("RainbowWackyBeams", 0.1, 0, function()
                        if not IsValid(newbeam) then return end
                        if not IsValid(amscrystal) then return end
                        if amscrystal:GetCrystalEffect() == "Rainbow" then
                            local r = math.random(0, 255)
                            local g = math.random(0, 255)
                            local b = math.random(0, 255)
                            newbeam:SetKeyValue("rendercolor", r.." "..g.." "..b)
                        else
                            newbeam:SetKeyValue("rendercolor", amscrystal:GetColor().r.." "..amscrystal:GetColor().g.." "..amscrystal:GetColor().b)
                        end
                        newbeam:Fire("Toggle", "", 0)
                    end)
                end)
                timer.Simple(7, function()
                    if not IsValid(v) then return end
                    if not IsValid(amscrystal) then return end
                    if amscrystal:GetCrystalScanned() ~= true and amscrystal:GetAnalyzerScanned() ~= true then
                        errorout("[AMS TEST] The crystal needs to be scanned and analyzed before it can be used!")
                        SampleBad(self)
                        TurnOffSecondStage()
                    elseif amscrystal:GetCrystalScanned() ~= true and amscrystal:GetAnalyzerScanned() == true then
                        errorout("[AMS TEST] The crystal needs to be scanned first!")
                        SampleBad(self)
                        TurnOffSecondStage()
                    elseif amscrystal:GetCrystalScanned() == true and amscrystal:GetAnalyzerScanned() ~= true then
                        errorout("[AMS TEST] The crystal needs to be analyzed first!")
                        SampleBad(self)
                        TurnOffSecondStage()
                    elseif amscrystal:GetAnalyzerScanned() ~= true then
                        errorout("[AMS TEST] The crystal needs to be analyzed first before it can be used!")
                        SampleBad(self)
                        TurnOffSecondStage()
                    elseif amscrystal:GetAMSTested() ~= false then
                        errorout("[AMS TEST] This crystal has already been used in the AMS!")
                        SampleBad(self)
                        TurnOffSecondStage()
                    elseif rand <= amscrystal:GetCrystalAMSPowerLevel() then
                        if GetGlobalBool("ams_open", true) == true and GetGlobalBool("KiwiPollIsActive", false) == false and GetGlobalBool("AMSLaserPoll", false) == false then
                            print("[cckiwi_polling] Starting AMS poll...")
                            hook.Run("StartPoll", "[Server]", "A resonance cascade is attempting to start, proceed?", "Yes", "No", "", "", "", "", 60, "AMSPoll")
                            SetGlobalBool("AMSLaserPoll", true)
                        end
                        SampleGood()
                    else
                        amscrystal:SetName("")
                        SuccessfulTest(amscrystal)
                    end
                end)
                break
            end
        end
    elseif inputname == "AmsCheckClose" then
        if not caller:GetClass() == "func_door_rotating" then return end
        for k,v in pairs(ents.FindByName("sample_cart2")) do
            local amscrystal = v:GetChildren()[1]
            if not IsValid(amscrystal) then continue end
            v:SetInsideAMS(false)
            local phys = v:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:Wake()
            end
            break
        end
        SetGlobalBool("ams_open", false)
    // Attempt a disaster //
    elseif inputname == "AmsVoteForDisaster" then
        if not caller:GetClass() == "func_door_rotating" then return end
        SetGlobalBool("ams_open", true)
    elseif inputname == "LambdaFailure" then
        if not IsValid(caller) then return end
        if not IsValid(activator) then return end
        
    end
    activator.Delayed = true
    timer.Simple(0.5, function()
        activator.Delayed = false
    end)
end

// RESONANCE CASCADE CODE BELOW //
local voxcascade = { // auto vox announcer
    {0, "warning"},
    {1.25, "warning"},
    {2.5, "alien"},
    {3.25, "life"},
    {4, "forms"},
    {5, "detected"},
    {6, "evacuate"},
    {7, "immediately"},
    {8, "military"},
    {9, "command"},
    {10, "authorized"},
}

local voxcascadeend = { // auto vox announcer
    {0, "warning"},
    {1.25, "warning"},
    {2.5, "facility"},
    {3.25, "secured"},
}

hook.Add("PollResults", "WelpThereGoesTheAMS", function(voted1, voted2, id)
    if GetGlobalBool("ResonanceCascade", false) == true then return end
    local votes1 = voted1.x
    local votes2 = voted1.y
    if id == "AMSPoll" then
        print("[cckiwi_polling] Finished AMS poll! Yes: "..voted1.x.." No: "..votes2)
        if votes1 > votes2 then
            StartCascade()
        else
            print("[cckiwi_polling] AMS poll finished with a NO!")
            SetGlobalBool("ams_shutdown", false)
            for k,v in pairs(ents.FindByName("sample_cart2")) do
                local amscrystal = v:GetChildren()[1]
                if not IsValid(amscrystal) then continue end
                amscrystal:SetName("")
                SuccessfulTest(amscrystal)
                break
            end
        end
    end
end)

hook.Add("PollCancelled", "ByeByePoll", function(ply, voted1, voted2, id)
    if GetGlobalBool("ResonanceCascade", false) == true then return end
    if id == "AMSPoll" then
        print("[cckiwi_polling] AMS poll cancelled!")
        SetGlobalBool("ams_shutdown", false)
        for k,v in pairs(ents.FindByName("sample_cart2")) do
            local amscrystal = v:GetChildren()[1]
            if not IsValid(amscrystal) then continue end
            amscrystal:SetName("")
            SuccessfulTest(amscrystal)
            break
        end
    end
end)

// This is the general delay before the cascade ends. //
local endcascadedelay = 1500
local enables = {
    {"floor_spotlight_1", "TurnOff"},
    {"tldoor", "Open"},
    {"ladderdoor", "Open"}
}
// These entities are removed after a cascade finishes. //
local removes = {
    "npc_zombie",
    "npc_headcrab",
    "npc_vortigaunt",
    "monster_alien_slave",
}

local endcascadevoxtable = {
    {"", 0}
}

function StartCascade()
    local thismap = BMRP.MAPS[game.GetMap()]
    local playersinvolved = {}
    for k,v in pairs(player.GetAll()) do
        local location = v:GetNWString("location") or "Unknown"
        if amslocations[location] then
            table.insert(playersinvolved, v)
        end
    end
    hook.Run("ResonanceCascade", playersinvolved)

    SetGlobalBool("CascadeClearance", true)
    SetGlobalBool("ResonanceCascade", true)

    LightsOff()
    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "|| BLACK MESA INTERNAL POWER GRID FAILURE... ||")
    end
    for k2, v2 in ipairs(thismap.useduringcascade) do
        for k, v in pairs(ents.FindByName(v2)) do
            v:Fire("Use")
        end
    end
    for k1,v1 in ipairs( enables ) do
        for k,v in pairs( ents.FindByName(v1[1]) ) do
            v:Fire(v1[2])
        end
    end

    //rubble
    for k,v in pairs( ents.FindByClass("bmrp_rubble") ) do
        v:SetDestroyed(false)
        v:SetVisible(true)
        v:SetRubbleHealth(600)
    end

    timer.Simple(20, function()
        LightsOn()
        hook.Run("RunVoxTable", voxcascade, "vox")
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "|| BLACK MESA BACKUP GENERATORS ACTIVATED... ||")
        end
    end)

    timer.Simple(35, function()
        for k,v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "A Resonance Cascade has started. The Facility Administrator can now call in the H.E.C.U with (/hecu).")
        end
        redalert()
        closeblastdoors()
    end)

    // After a pre-set delay, the cascade ends naturally.
    timer.Simple(endcascadedelay, function()
        EndCascade()
    end)
end

function EndCascade()
    if not GetGlobalBool("ResonanceCascade", false) then return end
    local password = ""
    -- generate a password with 4 digits from 1 - 9
    for i = 1, 4 do
        password = password .. math.random(1, 9)
    end
    for k,v in pairs( ents.FindByClass("funnypad") ) do
        
        v:SetPassword(password)
    end
    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "The Facility Administrator has been granted authority to call in the Alpha Warhead. The nuclear launch code is " .. password .. ".")
        v:SendLua("surface.PlaySound('ambient/alarms/klaxon1.wav')")
    end
end

function EndCascadeReal()
    local thismap = BMRP.MAPS[game.GetMap()]
    if not GetGlobalBool("ResonanceCascade", false) then return end
    // These are just generally all the variables that get reset post-cascade.
    SetGlobalBool("AMSLaserPoll", false)
    SetGlobalBool("ResonanceCascade", false)
    SetGlobalBool("ams_open", false)
    SetGlobalBool("hecuallowed", false)
    SetGlobalBool("CascadeClearance", false)

    for k,v in pairs(ents.FindByName("beam_2")) do
        v:Remove()
    end

    // This will delete the crystal from the AMS cart pre-TurnOffAMS() because CloseSample() uses no crystals.
    for k,v in pairs(ents.FindByName("sample_cart2")) do
        if not IsValid(v) then continue end
        if not IsValid(v:GetChildren()[1]) then
            continue
        else
            local crystal = v:GetChildren()[1]
            crystal:Remove()
            v:SetHasCrystal(false)
            v:SetInsideAMS(false)
            print(v:GetHasCrystal())
        end

    end

    // This will completely deactivate the AMS, respawn the sample cart, turn off the alarms/blast doors, and end the cascade.
    unredalert()
    openblastdoors()
    TurnOffAMS()

    /*
    for k,v in pairs (player.GetAll()) do
        hook.Run("SystemMessage", v, "", "All Alien Lifeforms destroyed. All Military must leave the facility immediately. Return to normal duties. (The AMS room has been reset.)")
    end
    */
    
    hook.Run("RunVoxTable", voxcascadeend, "vox")
    for k1,v1 in ipairs( thismap.fireduringcascade ) do
        for k,v in pairs( ents.FindByName(v1[1]) ) do
            v:Fire(v1[2])
        end
    end

    for k1,v1 in pairs( removes ) do
        for k,v in pairs( ents.FindByClass(v1) ) do
            v:Remove()
        end
    end

    for k,v in pairs( ents.FindByClass("bmrp_rubble") ) do
        v:Remove()
    end

    // reset sound bc ams bugs
    timer.Simple(2, function()
        for k,v in pairs(player.GetAll()) do
            v:SendLua("RunConsoleCommand(\"snd_restart\")")
        end  
    end)
end

hook.Add("EndResonanceCascade", "EndCascade", EndCascadeReal)

// This runs a successful testing function!
function SuccessfulTest(amscrystal)
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in pairs(ents.FindByName(thismap.cascadebeam)) do
        v:Remove()
    end

    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "The machine responds positively to the crystal. The machine has automatically turned itself off to prevent any further issues. (You may now remove the crystal)")
    end

    local multiplier = 1 //flat 1 value

    for k,v in pairs(amscrystal.CrystalTypes) do 
        if v[1] == amscrystal:GetCrystalType() then
            multiplier = v[4]
        end
    end

    local money = (amscrystal:GetCrystalResonance() * 10) * multiplier // for example, if you have a 98% resonance crystal, you get $980 * the multiplier

    for k,v in pairs(player.GetAll()) do
        local location = v:GetNWString("location") or "Unknown"
        if amslocations[location] then
            v:addMoney(money)
            DarkRP.notify(v, 0, 4, "You received $" .. money .. " for participating in an AMS event.")
        end
    end

    local logic
    for k,v in pairs(ents.FindByName("bmrp_logic")) do
        logic = v
        break
    end
    if IsValid(logic) then
        logic:SetAfterTheFact(true)
        SampleBad(logic)
    end
    amscrystal:SetAMSTested(true)
    TurnOffAMS()
    SampleGood()

end

// DEVELOPER AMS COMMANDS //
concommand.Add("dev_endcascade", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    EndCascadeReal()
    DarkRP.notify(ply, 0, 4, "[DEV] Force ending a cascade...")
end)

concommand.Add("dev_endcascadefake", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    EndCascade()
    DarkRP.notify(ply, 0, 4, "[DEV] Force ending a fake cascade...")
end)

concommand.Add("dev_startcascade", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    StartCascade()
    DarkRP.notify(ply, 0, 4, "[DEV] Force starting a cascade...")
end)

concommand.Add("dev_secondstage", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    TurnOffSecondStage()
    DarkRP.notify(ply, 0, 4, "[DEV] AMS has been turned to stage 1.")
end)

concommand.Add("dev_closesample", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    CloseSample()
    DarkRP.notify(ply, 0, 4, "[DEV] Sample cart has been closed and respawned.")
end)

concommand.Add("dev_amsoff", function(ply, cmd, args)
    if ply:IsDeveloper() then
        TurnOffAMS()
        DarkRP.notify(ply, 0, 4, "AMS is now off.")
    end
end)