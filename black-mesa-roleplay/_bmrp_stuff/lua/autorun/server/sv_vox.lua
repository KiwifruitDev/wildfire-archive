// Wildfire Black Mesa Roleplay
// File description: BMRP VOX system script
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

/*
bizwarn	"Bizwarn" sound
bloop	"Bloop" sound
buzwarn	"Buzwarn" sound
dadeda	"Dadeda" sound
deeoo	"Deeoo" sound
doop	"Doop" sound
*/

local translations = {
    ["bizwarn"] = "*BIZWARN*",
    ["bloop"] = "*BLOOP*",
    ["buzwarn"] = "*BUZWARN*",
    ["dadeda"] = "*DADEDA*",
    ["deeoo"] = "*DEEOO*",
    ["doop"] = "*DOOP*",
    ["beep"] = "*BEEP*",
    ["_comma"] = ",",
    ["_period"] = ".",
}

// TODO: Add the VOX addon here
hook.Add("RunVoxTable", "TheVoxTable", function(voxtable, prefix)
    if prefix == "vox" and GetGlobalBool("hecuallowed", false) == true then
        prefix = "military_vox"
    end
    print("Running vox table: " .. prefix)
    local newtable = {}
    local displaytable = {}
    for k, v in pairs(voxtable) do
        if translations[v[2]] ~= nil then
            table.insert(displaytable, translations[v[2]])
        else
            table.insert(displaytable, v[2])
        end
        table.insert(newtable, v[2])
    end
    local tblthing = table.concat(displaytable, " ")
    for k,v in pairs(player.GetAll()) do
        if prefix == "hev_vox" and not v:HEVSuitEquipped() then
            continue
        end
        hook.Run("SystemMessage", v, "", (prefix == "vox" and "VOX: " or prefix == "military_vox" and "Military VOX: " or prefix == "hev_vox" and "HEV Suit: ")..(tblthing:sub(1,1):upper()..tblthing:sub(2)))
        if prefix == "vox" or prefix == "military_vox" then
            v:SendLua("surface.PlaySound(\""..prefix.."/bloop.wav\")")
        elseif prefix == "hev_vox" then
            v:SendLua("surface.PlaySound(\""..prefix.."/beep.wav\")")
        end
        //hook.Run("SystemMessage", v, "", table.ToString(voxtable))
    end
    timer.Simple(1, function()
        for k,v in pairs(voxtable) do
            timer.Simple(v[1], function()
                for k2,v2 in pairs( player.GetAll() ) do
                    if prefix == "hev_vox" and not v2:HEVSuitEquipped() then
                        continue
                    end
                    v2:SendLua("surface.PlaySound(\""..prefix.."/"..v[2]..".wav\")")
                end
            end)
        end
    end)
end)

local commands = {
    ["delay"] = function(time, input, entity)
        return time + tonumber(input)
    end,
}

concommand.Add("vox_new", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    if not args[1] then return end
    local voxtable = {}
    local voxdelay = 0
    local voxprefix = "vox"
    for k,v in pairs(args) do
        if v == "hev" then
            voxprefix = "hev_vox"
        elseif v == "military" then
            voxprefix = "military_vox"
        else
            table.insert(voxtable, {voxdelay, v})
            voxdelay = voxdelay + 1
        end
    end
    hook.Run("RunVoxTable", voxtable, voxprefix)
end)
