// Wildfire Black Mesa Roleplay
// File description: BMRP staff handler script
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

// HOOKS //
// Large Noclip Rewrite for staff
hook.Add( "PlayerNoClip", "StaffNoclip", function( ply, desiredState )
	if ( desiredState == false ) then // EXITING NOCLIP
        ply:FAdmin_SetGlobal("FAdmin_cloaked", false)
        ply:SetNoDraw(false)
        ply:AllowFlashlight(true)
        ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		for _, v in pairs(ply:GetWeapons()) do
			v:SetNoDraw(false)
		end
		for _, v in pairs(ents.FindByClass("physgun_beam")) do
			if v:GetParent() == ply then
				v:SetNoDraw(false)
			end
		end
        ply:GodDisable()
		return true // Always allow this because a player NEEDS to exit Noclip.
	else // ENTERING NOCLIP
        if not ply:IsStaff() then return end //Staff only!
        if ply:CategoryCheck() == "xenian" then
            hook.Run("SystemMessage", ply, "", "You can't Noclip as a Xenian job. Sorry for the inconvenience.")
            return false
        end
        ply:FAdmin_SetGlobal("FAdmin_cloaked", true)
        ply:SetNoDraw(true)
        if ply:FlashlightIsOn() then
            ply:Flashlight(false)
        end
        ply:AllowFlashlight(false)
        ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		for _, v in pairs(ply:GetWeapons()) do
			v:SetNoDraw(true)
		end
		for _, v in pairs(ents.FindByClass("physgun_beam")) do
			if v:GetParent() == ply then
				v:SetNoDraw(false)
			end
		end
        ply:GodEnable()
		return true // Allow staff to enter Noclip.
	end
end )

// CON-COMMANDS //
// Staff can blow themselves up.
concommand.Add("bmrp_explode", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDonator() and not ply:IsStaff() then
        DarkRP.notify(ply, 1, 4, "Donate to the server to use this perk and more!")
        return
    end -- donator only
    if not ply:Alive() then return end
    local explosion = ents.Create("env_explosion")
    explosion:SetKeyValue("iMagnitude", "0")
    explosion:SetKeyValue("rendermode", "5")
    explosion:Fire("Explode")
    explosion:SetPos(ply:GetPos())
    ply:SetPos(ply:GetPos() + Vector(0, 0, 1))
    ply:SetVelocity(Vector(0, 0, 1000))
    timer.Simple(0.001, function()
        if not IsValid(ply) then return end
        if not ply:Alive() then return end
        ply:Kill()
    end)
end)
// This command force allows the HECU to enter/not enter the facility. Staff only.
concommand.Add("bmrp_hecutoggle", function( ply, cmd, args )
    if not ply:IsStaff() then return end
    if GetGlobalBool("hecuallowed", false) == false then
        SetGlobalBool("hecuallowed", true)
        for k,v in pairs(player.GetAll()) do
            //hook.Run("SystemMessage", v, "", "[STAFF OVERRIDE] H.E.C.U are now allowed in the facility.")
            if not v:IsStaff() then return end
            DarkRP.notify(v, 0, 4, "[STAFF] H.E.C.U are now allowed in the facility.")
        end
    else
        SetGlobalBool("hecuallowed", false)
        for k,v in pairs(player.GetAll()) do
            //hook.Run("SystemMessage", v, "", "[STAFF OVERRIDE] H.E.C.U are no longer allowed in the facility.")
            if not v:IsStaff() then return end
            DarkRP.notify(v, 0, 4, "[STAFF] H.E.C.U are no longer allowed in the facility.")
        end
    end
end)
// This command is useful for staff to announce things across the server.
concommand.Add("bmrp_announce", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    for k,v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "[STAFF] " .. table.concat(args, " "))
    end
end)
// Used to take ownership of a prop/entity
concommand.Add("bmrp_takeown", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsStaff() then return end
	local enti = ply:GetEyeTrace().Entity
    if not IsValid(enti) then return end
    enti:CPPISetOwner(ply)
    hook.Run("SystemMessage", ply, "", "[STAFF] " .. "Owned "..enti:GetClass()..".")
end)
// Disable xen check (global variable)
concommand.Add("bmrp_xencheck", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    SetGlobalBool("staff_xencheck", not GetGlobalBool("staff_xencheck", false))
    for k, v in pairs(player.GetAll()) do
        if not v:IsStaff() then return end
        DarkRP.notify(v, 0, 4, "[STAFF] " .. "Xenian check is now " .. (GetGlobalBool("staff_xencheck", false) and "disabled" or "enabled") .. ".")
    end
end)
// Disable random NPC spawning (global variable)
concommand.Add("bmrp_npcs", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    SetGlobalBool("staff_npcspawner", not GetGlobalBool("staff_npcspawner", false))
    for k, v in pairs(player.GetAll()) do
        if not v:IsStaff() then return end
        DarkRP.notify(v, 0, 4, "[STAFF] " .. "Random NPCs are now " .. (GetGlobalBool("staff_npcspawner", false) and "disabled" or "enabled") .. ".")
    end
end)

function BMRPSmite(target, fallbackvector, ignoreentities)
    local trace = {
        start = (IsValid(target) and target:IsPlayer()) and target:GetPos() or fallbackvector,
        endpos = (IsValid(target) and target:IsPlayer()) and target:GetPos() or fallbackvector + Vector(0, 0, 1000),
        filter = {},
    }
    local luckyplayer
    local playerlist = {}
    if IsValid(target) and target:IsPlayer() then
        if not luckyplayer then
            luckyplayer = target
        end
        hook.Run("SystemMessage", target, "", "Thou hast been smitten!")
        table.insert(trace.filter, target)
        --[[
        target:SetPos(target:GetPos() + Vector(0, 0, 0.1))
        target:SetVelocity(Vector(0, 0, 1000))
        -- lightning dmg
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(1000)
        dmginfo:SetDamageType(DMG_SHOCK)
        dmginfo:SetAttacker(target)
        dmginfo:SetInflictor(target)
        dmginfo:SetDamageForce(Vector(0, 0, 1))
        dmginfo:SetDamagePosition(target:GetPos())
        target:TakeDamageInfo(dmginfo)
        target:Kill()
        ]]--
        table.insert(playerlist, target:Nick())
    else
        for k, v in pairs(player.GetAll()) do
            if ignoreentities and table.HasValue(ignoreentities, v) then continue end
            if v:GetPos():Distance(fallbackvector) <= 100 then
                if not luckyplayer then
                    luckyplayer = v
                end
                table.insert(playerlist, v:Nick())
                hook.Run("SystemMessage", v, "", "Thou hast been smitten!")
                table.insert(trace.filter, v)
                --[[
                v:SetPos(v:GetPos() + Vector(0, 0, 0.1))
                v:SetVelocity(Vector(0, 0, 1000))
                -- lightning dmg
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(1000)
                dmginfo:SetDamageType(DMG_SHOCK)
                dmginfo:SetAttacker(v)
                dmginfo:SetInflictor(v)
                dmginfo:SetDamageForce(Vector(0, 0, 1))
                dmginfo:SetDamagePosition(v:GetPos())
                v:TakeDamageInfo(dmginfo)
                v:Kill()
                ]]--
            end
        end
    end
    local tr = util.TraceLine(trace)
    -- make a particle effect
    local effectdata = EffectData()
    effectdata:SetMagnitude(100)
    effectdata:SetNormal(Vector(0, 0, 1))
    if IsValid(target) and target:IsPlayer() then
        effectdata:SetEntity(target)
        effectdata:SetOrigin(target:GetPos())
    elseif IsValid(luckyplayer) then
        effectdata:SetEntity(luckyplayer)
        effectdata:SetOrigin(luckyplayer:GetPos())
    else
        effectdata:SetOrigin(fallbackvector)
    end
    effectdata:SetAttachment(1)
    effectdata:SetScale(100)
    effectdata:SetRadius(100)
    effectdata:SetStart(tr.HitPos)
    util.Effect("smite", effectdata)
    -- dust particles after the effect
    util.Effect("ThumperDust", effectdata)
    -- now make an explosion
    local explosion = ents.Create("env_explosion")
    if IsValid(target) and target:IsPlayer() then
        explosion:SetPos(target:GetPos())
    elseif IsValid(luckyplayer) then
        explosion:SetPos(luckyplayer:GetPos())
    else
        explosion:SetPos(fallbackvector)
    end
    explosion:SetKeyValue("iMagnitude", "0")
    explosion:SetKeyValue("rendermode", "5")
    explosion:Fire("Explode")
    -- and an env_shake
    local shake = ents.Create("env_shake")
    if IsValid(target) and target:IsPlayer() then
        shake:SetPos(target:GetPos())
    elseif IsValid(luckyplayer) then
        shake:SetPos(luckyplayer:GetPos())
    else
        shake:SetPos(fallbackvector)
    end
    shake:SetKeyValue("amplitude", "2000")
    shake:SetKeyValue("radius", "2000")
    shake:SetKeyValue("duration", "2")
    shake:SetKeyValue("frequency", "255")
    shake:Fire("StartShake", "", 0)
    -- make a thunder sound
    explosion:EmitSound("ambient/explosions/explode_7.wav")
    return playerlist
end

// thou hast been smitten!
concommand.Add("bmrp_smite", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    if not ply:IsDonator() and not ply:IsStaff() then
        DarkRP.notify(ply, 1, 4, "Donate to the server to use this perk and more!")
        return
    end -- donator only
    for k,v in pairs(BMRPSmite(ply, ply:GetEyeTrace().HitPos, {})) do
        DarkRP.notify(ply, 0, 4, v .. " has been smitten!")
    end
    ply:Kill()
end)

concommand.Add("bmrp_smite2", function(ply, cmd, args)
    if not IsValid(ply) then return end
    --if not ply:Alive() then return end
    if not ply:IsStaff() then return end
    for k,v in pairs(BMRPSmite(nil, ply:GetEyeTrace().HitPos, {})) do
        DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
    end
end)

-- "what the fuck"
concommand.Add("bmrp_smite3", function(ply, cmd, args)
    if not IsValid(ply) then return end
    --if not ply:Alive() then return end
    if not ply:IsStaff() then return end
    -- make a circle of BMRPSmites around the player
    local radius = tonumber(args[1]) or 200
    local density = tonumber(args[2]) or 10
    local speedmultiplier = args[3] and (tonumber(args[3]) > 0 and tonumber(args[3]) or 1) or 1
    for i = 1, density do
        timer.Simple((i / density) * speedmultiplier, function()
            local angle = math.rad(i * 360 / density)
            local pos = ply:GetPos() + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
            for k,v in pairs(BMRPSmite(nil, pos, {ply})) do
                DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
            end
        end)
    end
end)

-- basically the same as bmrp_smite3 but it does it twice with the second time being a smaller radius
concommand.Add("bmrp_smite4", function(ply, cmd, args)
    if not IsValid(ply) then return end
    --if not ply:Alive() then return end
    if not ply:IsStaff() then return end
    -- make a circle of BMRPSmites around the player
    local radius = tonumber(args[1]) or 200
    local density = tonumber(args[2]) or 10
    local speedmultiplier = args[3] and (tonumber(args[3]) > 0 and tonumber(args[3]) or 1) or 1
    for i = 1, density do
        timer.Simple((i / density) * speedmultiplier, function()
            local angle = math.rad(i * 360 / density)
            local pos = ply:GetPos() + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
            for k,v in pairs(BMRPSmite(nil, pos, {ply})) do
                DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
            end
        end)
    end
    -- after every mean has been smitten, do the same thing but with a smaller radius
    timer.Simple(density * speedmultiplier, function()
        for i = 1, density do
            timer.Simple((i / density) * speedmultiplier, function()
                local angle = math.rad(i * 360 / density)
                local pos = ply:GetPos() + Vector(math.cos(angle) * radius/2, math.sin(angle) * radius/2, 0)
                for k,v in pairs(BMRPSmite(nil, pos, {ply})) do
                    DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
                end
            end)
        end
    end)
end)

--target a player by steamid and smite them
concommand.Add("bmrp_smite5", function(ply, cmd, args)
    if not IsValid(ply) then return end
    --if not ply:Alive() then return end
    if not ply:IsStaff() then return end
    local target = args[1]
    if not target then return end
    local targetply = player.GetBySteamID(target)
    if not IsValid(targetply) then return end
    for k,v in pairs(BMRPSmite(targetply, ply:GetEyeTrace().HitPos, {})) do
        DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
    end
end)

-- smite everyone
concommand.Add("bmrp_smite6", function(ply, cmd, args)
    if not IsValid(ply) then return end
    --if not ply:Alive() then return end
    if not ply:IsStaff() then return end
    for k,v in pairs(player.GetAll()) do
        for k,v in pairs(BMRPSmite(v, ply:GetEyeTrace().HitPos, {})) do
            DarkRP.notify(ply, 0, 4, "[STAFF] " .. v .. " has been smitten!")
        end
    end
end)

-- nuke controller commands

concommand.Add("bmrp_nuketimer", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    local newdelay = tonumber(args[1])
    timer.Simple(newdelay, function()
        SetGlobalString("NukeText", "")
        SetGlobalBool("NukeEvent", false)
    end)
    timer.Create("DevNukeTimer", 1/(1 / engine.TickInterval()), newdelay*(1 / engine.TickInterval()), function()
        newdelay = newdelay - 1/(1 / engine.TickInterval())
        SetGlobalInt("NukeTimer", newdelay)
    end)
    DarkRP.notify(ply, 0, 4, "Nuke timer set to " .. newdelay .. " seconds!")
    -- minified
end)

concommand.Add("bmrp_nuketext", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    if GetGlobalBool("NukeEvent", false) then
        timer.Remove("DevNukeTimer")
        timer.Remove("RestartNukeTimer")
        timer.Remove("StupidNukeTimer")
        SetGlobalString("NukeText", "")
        SetGlobalBool("NukeEvent", false)
    else
        local text = table.concat(args, " ")
        SetGlobalString("NukeText", text)
        SetGlobalBool("NukeEvent", true)
        DarkRP.notify(ply, 0, 4, "Nuke text set to " .. text .. "!")
    end
end)
