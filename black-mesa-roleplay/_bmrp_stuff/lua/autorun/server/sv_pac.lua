// Wildfire Black Mesa Roleplay
// File description: PAC3 restriction script
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

// true means yes u can use pac
local ranks = {
    ["owner"] = true,
    ["coowner"] = true,
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    ["trialmoderator"] = true,
    ["donator"] = true,
    ["pacaccess"] = true,
    ["builder"] = true,
}

local restricted = {
    ["STEAM_0:0:000000"] = true,
}

hook.Add("PrePACConfigApply", "PACRestrictPrePACConfigApply", function(ply)
    if restricted[ply:SteamID()] then
        return false,"You are restricted from PAC3."
    end
	if not ranks[ply:GetUserGroup()] then
        return false,"We're sorry, this feature is for pac-access & donator players only! Apply for PAC in our Discord."
    end
end)

hook.Add("PrePACEditorOpen", "PACRestrictPrePACEditorOpen", function(ply)
    if restricted[ply:SteamID()] then
        return false,"You are restricted from PAC3."
    end
	if not ranks[ply:GetUserGroup()] then
        return false,"We're sorry, this feature is for pac-access & donator players only! Apply for PAC in our Discord."
    end
end)