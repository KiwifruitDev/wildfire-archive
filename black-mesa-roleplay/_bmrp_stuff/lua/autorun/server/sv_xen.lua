// Wildfire Black Mesa Roleplay
// File description: BMRP Xen script
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

// Add our really cool HEV suits to the map so people can suit-up with them. //
BMRP.AddToMapReset("BMRP_AddSuitsToMap", function()
    // HEV SUITS //
    print("[BMRP] Replacing suits...")
    for k,v in pairs(ents.FindByClass("item_suit")) do
        local newsuit = ents.Create("bms_hev_suit")
        newsuit:SetPos(v:GetPos())
        newsuit:SetAngles(v:GetAngles())
        v:Remove()
        newsuit.persistant = true
        newsuit:Spawn()
        newsuit.persistant = true // double sure
        print("[BMRP] Replacing HEV Suit #"..k)
    end
    print("[BMRP] Done replacing suits!")
end)

// This table of models is allowed to "breathe" or not die in Xen.
local models = {
    "models/motorhead/hevscientist.mdl",
    "models/cs/playermodels/vortigaunt.mdl",
    "models/vj_hlr/hl1/headcrab.mdl",
    "models/houndeye.mdl",
    "models/bullsquid.mdl",
}

hook.Add("MDAreaEnter", "BMRP_XenGravityEnter", function(ent, trigger, settings) // Happens when you enter the MapDefine trigger for Xen
	if settings.name == "Xen" then
        if IsValid(ent) then
            if ent:IsPlayer() and ( not ent:GetNWBool("MDSpawning", false) ) then
                if not GetGlobalBool("staff_xencheck", false) then
                    ent:SetGravity(0.4) // very low moon gravity
                    for k,v in pairs(models) do
                        if ent:GetModel() == v then
                            return
                        end 
                    end
                    // put stuff here if you enter without an hev suit
                    local index = ent:EntIndex()
                    local lastplayerhealth = ent:Health()
                    timer.Create("XenDeath_"..index, 1.5, 0, function() // we want a unique index so we can delete it when you exit
                        if GetGlobalBool("staff_xencheck", false) then
                            timer.Remove("XenDeath_"..index)
                            return
                        end
                        if lastplayerhealth <= 15 then
                            ent:Kill()
                            timer.Remove("XenDeath_"..index) // no need
                            return
                        end
                        local dmg = DamageInfo() //drowning damage
                        dmg:SetDamage(15)
                        dmg:SetDamageType(DMG_DROWN)
                        ent:TakeDamageInfo(dmg)
                        ent:ScreenFade( SCREENFADE.IN, Color( 0, 0, 255, 10 ), 0.3, 0 )
                        lastplayerhealth = ent:Health()
                        hook.Run("PlayerDrowning", ent)
                    end)
                end
            end 
        end
    elseif settings.name == "HECUKILLER" then
        if IsValid(ent) then
            if ent:IsPlayer() and ( not ent:GetNWBool("MDSpawning", false) ) then
                if GetGlobalBool("hecuallowed", false) == false then
                    if ent:CategoryCheck() ~= "hecu" then return end
                    if ent:IsStaff() then return end
                    ent:KillSilent()
                    hook.Run("SystemMessage", ent, "", "H.E.C.U are not allowed in the facility at this time. You have been respawned.")
                end
            end
        end
    elseif settings.name == "xentp" then
        if IsValid(ent) then
            if ent:GetClass() ~= "xen_crystal" then return end
            if not ent:IsPlayer() and ( not ent:GetNWBool("MDSpawning", false) ) then
                ent:SetPos(Vector(-13457.995117, 525.824951, -303.379181))
            end
        end
    end
end)

hook.Add("MDAreaExit", "BMRP_XenGravityExit", function(ent, trigger, settings) // Happens when you leave the MapDefine trigger for Xen
	if settings.name == "Xen" then
        if IsValid(ent) then
            if ent:IsPlayer() and ( not ent:GetNWBool("MDSpawning", false) ) then
                ent:SetGravity(1) // go back to default gravity
                if timer.Exists("XenDeath_"..ent:EntIndex()) then
                    timer.Remove("XenDeath_"..ent:EntIndex()) // deleting unique index
                end
            end
        end
    end
end)


// This spawns random NPC's around the map If there are actually enough players to kill them. //

// How many players before random NPCs start to spawn? 
local playercount = 10
// How many seconds before a random NPC spawns?
local spawndelay = 2200

local SpawnPositions = {
    Vector(-10274.734375, -973.662415, 634.031250), // Right inside topside entrance.
    Vector(-10278.618164, -1043.493408, -188.968750), // Sector F after elevator
}

local RandomNPCs = {
    "npc_vj_hlr1_headcrab",
    "npc_vj_hlr1_headcrab_baby",
    "npc_vj_hlr1_zombie",
    "npc_vj_hlr1_houndeye",
    "npc_vj_hlr1_bullsquid",
}

timer.Create("RandomNPCSpawner", spawndelay, 0, function()
    if player.GetCount() >= playercount then
        if GetGlobalBool("staff_npcspawner", false) == true then
            local spawnpos = table.Random(SpawnPositions)
            local npc = ents.Create(table.Random(RandomNPCs))
            npc:SetPos(spawnpos)
            npc:Spawn()
            npc:DropToFloor()
            npc:Activate()
            local sprite = ents.Create("env_sprite")
            sprite:SetPos(spawnpos + Vector(0, 0, -64))
            sprite:SetKeyValue("rendercolor", "77 210 130")
            sprite:SetKeyValue("renderfx", "14")
            sprite:SetKeyValue("rendermode", "3")
            sprite:SetKeyValue("model", "sprites/Fexplo1.spr")
            sprite:SetKeyValue("scale", "1")
            sprite:SetKeyValue("spawnflags", "3")
            sprite:SetKeyValue("framerate", "10")
            sprite:Spawn()
            sprite:EmitSound("debris/beamstart2.wav")
            sprite:Activate()
            timer.Simple(5, function()
                if IsValid(sprite) then
                    sprite:Remove()
                end
            end)
        end
    end 
end)