// Wildfire Black Mesa Roleplay
// File description: XP system script
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
XP SYSTEM GROUPING:
- Global XP (given by every job) - ply:CategoryCheck() == "global" - global will return back if all the other custom checks fail

- Security XP (Given by Security Officer, Security Heavy Weapons, and Security Medic.) - ply:CategoryCheck() == "security"
- Administrative XP (Given by the Administrator) - ply:CategoryCheck() == "administrative"
- Surface XP (Given by Graffiti Aritist, and Visitor) - ply:CategoryCheck() == "surface"
- Science XP (Given by R&D Scientist, Surveyor, Hazardous Environment Researcher) - ply:CategoryCheck() == "science"
- H.E.C.U XP (Given by all members of H.E.C.U) - ply:CategoryCheck() == "hecu"
- Service XP (Given by Janitor, Facility Cook, and Maintenance Team - ply:CategoryCheck() == "service"
- Xenian XP (Given by every Alien member) - ply:CategoryCheck() == "xenian"

All of this is handled in shared.lua :)
*/

concommand.Add("security_xp", function(ply, cmd, args)
    for k,v in pairs(BMRP.GROUPS.SECURTYIDS) do
        if ply:SteamID() == v then
            if not args[1] then return end
            if not args[2] then return end
            local target = args[1]
            local amount = args[2]
            local type = "security"
            local targetply = player.GetBySteamID64(target)
            if targetply == ply then
                DarkRP.notify(ply, 1, 4, "You cannot give XP to yourself.")
                return
            end
            if not targetply then
                DarkRP.notify(ply, 1, 4, "That player does not exist.")
                return
            end
            DarkRP.notify(ply, 1, 4, "You have set " .. targetply:Nick() .. " " .. amount .. " XP.")
            targetply:SetNWInt("XP_" .. type, tonumber(amount))
            sql.Query( "UPDATE xpdata SET XP = " .. tonumber(amount) .. " WHERE SteamID = " .. sql.SQLStr( targetply:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";" )
        end
    end
end)

concommand.Add("bmrp_xp", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    if not args[1] then return end
    if not args[2] then return end
    if not args[3] then return end
    local target = args[1]
    local amount = args[2]
    local type = args[3]
    local targetply = player.GetBySteamID64(target)
    if not targetply then targetply = ply end
    //local targetply = ply
    targetply:SetNWInt("XP_" .. type, tonumber(amount))
    sql.Query( "UPDATE xpdata SET XP = " .. tonumber(amount) .. " WHERE SteamID = " .. sql.SQLStr( targetply:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";" )
end)

// DatabaseUpdate: This function re-evaulates a specific type XP of a player and updates the database if "shouldUpdateXP" is true.
// Basically, this function is called when the XP type changes or when the player is spawned, or just every minute as seen in XPTimer.
// v: Player
// type: Type of XP
// shouldUpdateXP: If true, the database will be updated and the internal counters are updated.

local function DatabaseUpdate(v, type, shouldUpdateXP)
    local data = sql.QueryRow( "SELECT * FROM xpdata WHERE SteamID = " .. sql.SQLStr( v:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";")
    if data ~= nil then
        local XP = tonumber(data.XP)
        local Counter = tonumber(data.Counter)
        if shouldUpdateXP then
            Counter = Counter + 1
        end
        if Counter >= 10 then
            if shouldUpdateXP then
                XP = XP + 5
                Counter = 0
            end
            if type ~= "global" then
                DarkRP.notify(v, 0, 3, "You've received 5 XP! Thanks for playing.")
            end
            sql.Query( "UPDATE xpdata SET XP = " .. XP .. " WHERE SteamID = " .. sql.SQLStr( v:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";" )
        end
        //"UPDATE xpdata SET Counter = " .. Counter .. " WHERE SteamID = " .. sql.SQLStr( v:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";" )
        sql.Query( "UPDATE xpdata SET Counter = " .. Counter .. " WHERE SteamID = " .. sql.SQLStr( v:SteamID() ) .. " AND Type = " .. sql.SQLStr( type ) .. ";" )
        v:SetNWInt("XP_" .. type, XP)
        v:SetNWInt("Counter_" .. type, Counter)
    else
        sql.Query( "INSERT INTO xpdata ( SteamID, XP, Counter, Type ) VALUES( " .. sql.SQLStr( v:SteamID() ) .. ", " .. 0 .. ", " .. 1 .. ", " .. sql.SQLStr( type ) .. " )" )
    end
end

hook.Add("InitPostEntity", "BMRP_XPInit", function()
    timer.Create("XPTimer", 60, 0, function()
        for k,v in pairs(player.GetAll()) do
            local type = v:CategoryCheck()
            DatabaseUpdate(v, type, true)
            DatabaseUpdate(v, "global", true)
        end
    end)
    sql.Query( "CREATE TABLE IF NOT EXISTS xpdata ( SteamID TEXT, XP INTEGER, Counter FLOAT, Type TEXT )" )
end)

hook.Add("PlayerChangedTeam", "DatabaseUpdateJobSwitch", function(ply)
    timer.Simple(0.5, function()
        local type = ply:CategoryCheck()
        DatabaseUpdate(ply, type, false)
        DatabaseUpdate(ply, "global", false)
    end)
end)

hook.Add("PlayerInitialSpawn", "BMRP_XPPlayerInit", function(ply)
    local type = "surface"
    DatabaseUpdate(ply, type, false)
    DatabaseUpdate(ply, "global", false)
end)