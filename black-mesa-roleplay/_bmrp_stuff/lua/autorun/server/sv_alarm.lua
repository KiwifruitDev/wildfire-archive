// Wildfire Black Mesa Roleplay
// File description: BMRP alarm system script
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

// CON-COMMANDS //
// A concommand that activates/de-activates the alarm. (This does NOT close the blast doors.)
concommand.Add("bmrp_redalert", function(ply, cmd, args)
    if not ply:IsStaff() then return end
    if not GetGlobalBool("RedAlert", false) then
        redalert()
    else
        unredalert()
    end
end)

// FUNCTIONS //
// This activates the alarms, sprites, and sounds. It also sets the global boolean to tell the server that a lockdown is active.
function redalert()
    local thismap = BMRP.MAPS[game.GetMap()]
    local lights = ents.FindByName(thismap.redalertlights)
    local sirens = ents.FindByName(thismap.redalertsound)
    local sprites = ents.FindByName(thismap.redalertsprite)
    for k,v in pairs(lights) do
        v:Fire("TurnOn")
        v:Fire("SetPattern", "abcdefghijklmnopqrrqponmlkjihgfedcba")
    end
    for k,v in pairs(sirens) do
        v:Fire("PlaySound")
    end
    for k,v in pairs(sprites) do
        v:Fire("ShowSprite")
    end
    SetGlobalBool("RedAlert", true)
end
// This is the same exact thing as above, just changed in the way that the alarms don't activate.
function blackoutredalert()
    local thismap = BMRP.MAPS[game.GetMap()]
    local lights = ents.FindByName(thismap.redalertlights)
    local sirens = ents.FindByName(thismap.redalertsound)
    local sprites = ents.FindByName(thismap.redalertsprite)
    for k,v in pairs(lights) do
        v:Fire("TurnOn")
        v:Fire("SetPattern", "abcdefghijklmnopqrrqponmlkjihgfedcba")
    end
    for k,v in pairs(sirens) do
        v:Fire("PlaySound")
    end
    for k,v in pairs(sprites) do
        v:Fire("ShowSprite")
    end
    SetGlobalBool("RedAlert", true)
end
// This disables any alarms, lights, or sprites that have to do with the lockdown.
function unredalert()
    local thismap = BMRP.MAPS[game.GetMap()]
    local lights = ents.FindByName(thismap.redalertlights)
    local sirens = ents.FindByName(thismap.redalertsound)
    local sprites = ents.FindByName(thismap.redalertsprite)
    for k,v in pairs(lights) do
        v:Fire("TurnOff")
        v:Fire("SetPattern", "a")
    end
    for k,v in pairs(sirens) do
        v:Fire("StopSound")
    end
    for k,v in pairs(sprites) do
        v:Fire("HideSprite")
    end
    SetGlobalBool("RedAlert", false)
end
// A concommand that closes the blast doors in the facility.
concommand.Add("bmrp_closeblastdoors", function(ply, cmd, args)
    if not ply:IsStaff() then return end
    closeblastdoors()
end)
// A concommand that opens the blast doors in the facility.
concommand.Add("bmrp_openblastdoors", function(ply, cmd, args)
    if not ply:IsStaff() then return end
    openblastdoors()
end)
// loud sound
concommand.Add("bmrp_loudsound", function(ply, cmd, args)
    if not ply:IsStaff() then return end
    local thismap = BMRP.MAPS[game.GetMap()]
    for k,v in pairs(ents.FindByName(thismap.alertsound)) do
        v:Fire("StopSound")
    end
end)

// This closes the blast doors in the facility.
function closeblastdoors()
    local thismap = BMRP.MAPS[game.GetMap()]
    local doors = ents.FindByName(thismap.lockdowndoor)
    for k,v in pairs(doors) do
        v:Fire("Close")
    end
end
// This opens the blast doors in the facility.
function openblastdoors()
    local thismap = BMRP.MAPS[game.GetMap()]
    local doors = ents.FindByName(thismap.lockdowndoor)
    for k,v in pairs(doors) do
        v:Fire("Open")
    end
end

// DarkRP Hooks //
local voxtable = {
    {0, "security"},
    {1, "lock"},
    {2, "down"},
    {3, "activated"},
}
local voxtabletwo = {
    {0, "facility"},
    {1, "secured"},
}

// When a lockdown is engaged, activate redalert along with the vox table.
hook.Add("lockdownStarted", "BMRP_Lockdown", function(ply)
    redalert()
    hook.Run("RunVoxTable", voxtable, "vox")
end)
// When a lockdown is dis-engaged, decativate the redalert along with the vox table.
hook.Add("lockdownEnded", "BMRP_Lockdown", function(ply)
    unredalert()
    hook.Run("RunVoxTable", voxtabletwo, "vox")
end)

// ARCHIVED STUFF //