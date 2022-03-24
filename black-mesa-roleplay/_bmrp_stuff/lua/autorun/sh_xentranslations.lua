// Wildfire Black Mesa Roleplay
// File description: BMRP xenian script
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

// Serverside because It's voice stuff
if SERVER then
    hook.Add("PlayerCanHearPlayersVoice", "AlienVoiceDisable", function(listener, talker)
        if talker:CategoryCheck() == "xenian" and not listener:IsStaff() then
            return false
        end
    end)
else //clientside chat stuff
	local function cipher(str, num)
		local newstr = ""
		for k, v in pairs(string.Explode("", str)) do
			v = string.byte(v)
			if string.char(v) == " " then
				newstr = newstr .. " "
				continue
			end

			if v + num > 122 then
				newstr = newstr .. string.char(v + num - 57)
			else
				newstr = newstr .. string.char(v + num)
			end
		end
		return newstr
	end

	hook.Add("OnPlayerChat", "TranslateXenianChat", function(ply, text, isTeam, isDead, begin)

		if begin and isstring(begin) and (string.find(begin, "(OOC)") or string.find(begin, "(LOOC)")) then return end

		if IsValid(ply) and ply:IsPlayer() and ply:CategoryCheck() == "xenian" and LocalPlayer():CategoryCheck() ~= "xenian" and not team.GetName(ply:Team()) ~= "Vortigaunt" then
			if LocalPlayer():GetActiveWeapon():GetClass() == "weapon_translator" then
				timer.Simple(0.5, function()
					net.Start("SystemMessage")
					// split string into table (ply:GetName())
					local name = ply:getDarkRPVar("rpname")
					net.WriteString("TRANSLATED - ("..name.."): "..text)
					net.SendToServer()
					//chat.AddText("TRANSLATED " .. ply:GetName() .. ": " .. text)
				end)
			end

			local newtext = cipher(text, math.random(5, 30))

			if LocalPlayer():IsStaff() then
				newtext = newtext:sub(1, 5) .. " (STAFF OVERRIDE: " .. text .. ")"
			end

			chat.AddText(team.GetColor(ply:Team()), ply:GetName(), Color(255, 255, 255), ": ", newtext)
			return true
		end
	end)
end
