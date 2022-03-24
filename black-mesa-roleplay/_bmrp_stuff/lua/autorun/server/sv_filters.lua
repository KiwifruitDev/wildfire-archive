// Wildfire Black Mesa Roleplay
// File description: BMRP filters script
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

// This whole function disallows players from having bad names along with symbols in their name.
// BLANKED OUT FOR SECURITY REASONS
local disallowedNames = {}
// Prevent the player from setting their name to a disallowed name.
hook.Add("CanChangeRPName", "BMRP_CanChangeRPName", function(ply, RPname)
    for k, v in pairs(disallowedNames) do
        if string.find(string.lower(RPname), string.PatternSafe(string.lower(v))) then
            return false, DarkRP.getPhrase("forbidden_name")
        end
    end
    //if not string.match(RPname, "^[a-zA-ZЀ-џ0-9 ]+$") then return false, DarkRP.getPhrase("illegal_characters") end
    // WILDFIRE CHANGE: Uncomment the above line to disallow all non-alphanumeric characters.
    local len = string.len(RPname)
    if len > 32 then return false, DarkRP.getPhrase("too_long") end
    if len < 3 then return false,  DarkRP.getPhrase("too_short") end
    return true
end)
// This whole function disallows players from saying slurs and hot topics such as election related things.
// BLANKED OUT FOR SECURITY REASONS
local BlacklistedWords = {}
// If a word appears in BlacklistedWords but is apart of a word that shouldn't be, add them here.
// BLANKED OUT FOR SECURITY REASONS
local WhitelistedWords = {}
// punctuation to be cut off at the end of the word
local Punctuation = {
    "'",
    "'",
    ",",
    ".",
    "!",
    "?",
    ";",
    ":",
    "\"",
    "`",
    "~",
    "`",
    "’",
    "‘",
    "“",
    "”",
    "„",
}
// Uses BlacklistedWords
hook.Add("PlayerSay", "BMRP_ChatFilter", function(ply, str)
	local ex = string.Explode(" ", str)
	local newstring
	for k, v in pairs(ex) do
		for a, b in pairs(BlacklistedWords) do
			if string.find(v:lower(), b:lower()) then
                -- set the newstring variable to the word said (v) but lowercase and without any symbols or numbers.
                -- also let's cut off any punctuation at the end of the word.
                newstring = string.gsub(v:lower(), "[%p%d]", "")
				for c, d in pairs(Punctuation) do
                    if string.find(newstring, d) then
                        newstring = string.Split(newstring, d)[1]
                    end
                end
			end
		end
	end
	if newstring ~= nil then
        if WhitelistedWords[newstring] == nil then
            hook.Run("SystemMessage", ply, "", "Please refrain from saying slurs or attempt to discuss hot topics.")
		    return ""
        end
	end
end)