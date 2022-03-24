// Wildfire Black Mesa Roleplay
// File description: generic player list
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

PLAYERLIST = {}

// ================ //
// SERVER FUNCTIONS //
// ================ //
if SERVER then
    // The below function is used to add or remove a steam id from a list.
    // steamid: The steamid of the player to add or remove. Use only STEAM_x:x:x format.
    // listName: The internal name of the list to add or remove the player from.
    // state: Boolean to add or remove the player from the list. If this state is already met, the function will do nothing.
    function PLAYERLIST.SetSteamIDListState(steamid, listName, state)
        // I trust that the steam id is valid.
        local data = sql.QueryRow( "SELECT * FROM playerlist WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";")
        if data ~= nil and state == false then
            sql.Query( "DELETE FROM playerlist WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";" )
            return true
        elseif state == true then
            sql.Query( "INSERT INTO playerlist (SteamID, ListName) VALUES (" .. sql.SQLStr( steamid ) .. ", " .. sql.SQLStr( listName ) .. ");" )
            return true
        end
        return false
    end
    // The below function is used to add or remove a player from a list.
    // ply: The player to add or remove.
    // listName: The internal name of the list to add or remove the player from.
    // state: Boolean to add or remove the player from the list. If this state is already met, the function will do nothing.
    // printName: A pretty name to notify the player with.
    // notify: Boolean for whether or not to notify the player with the printName.
    function PLAYERLIST.SetPlayerListState(ply, listName, state, printName, notify)
        if not IsValid(ply) then return false end
        if not ply:IsPlayer() then return false end
        local data = sql.QueryRow( "SELECT * FROM playerlist WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";")
        if state == true and notify == true then
            DarkRP.notify(ply, 0, 5, "You have been added to the " .. printName .. " list.")
        elseif notify == true then
            DarkRP.notify(ply, 0, 5, "You have been removed from the " .. printName .. " list.")
        end
        if data ~= nil and state == false then
            sql.Query( "DELETE FROM playerlist WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";" )
            return true
        elseif state == true then
            sql.Query( "INSERT INTO playerlist (SteamID, ListName) VALUES (" .. sql.SQLStr( ply:SteamID() ) .. ", " .. sql.SQLStr( listName ) .. ");" )
            return true
        end
        return false
    end
    // The below function is used to check if a steam id is in a list.
    // ply: The player to check.
    // listName: The internal name of the list to check the player in.
    function PLAYERLIST.IsSteamIDInList(steamid, listName)
        local data = sql.QueryRow( "SELECT * FROM playerlist WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";")
        if data ~= nil then
            return true
        end
        return false
    end
    // The below function is used to check if a player is in a list.
    // ply: The player to check.
    // listName: The internal name of the list to check the player in.
    function PLAYERLIST.IsPlayerInList(ply, listName)
        if not IsValid(ply) then return false end
        if not ply:IsPlayer() then return false end
        local data = sql.QueryRow( "SELECT * FROM playerlist WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND ListName = " .. sql.SQLStr( listName ) .. ";")
        if data ~= nil then
            return true
        end
        return false
    end
    hook.Add("InitPostEntity", "BMRP_CreatePlayerListDatabase", function()
        sql.Query( "CREATE TABLE IF NOT EXISTS playerlist ( SteamID TEXT, ListName TEXT )" )
    end)
end
