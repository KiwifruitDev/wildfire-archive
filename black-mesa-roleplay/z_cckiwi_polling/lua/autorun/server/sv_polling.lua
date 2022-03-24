--[[
	-| cckiwi_polling |-

	Copyright (c) 2021 KiwifruitDev
	https://github.com/TeamPopplio/
	https://steamcommunity.com/id/KiwifruitDev/

	Licensed under the MIT License.

	File description: Server polling loader sv_polling.lua
]]--

util.AddNetworkString("pollstarted")
util.AddNetworkString("pollinfo")
util.AddNetworkString("pollnetwork")
util.AddNetworkString("pollupdate")
util.AddNetworkString("pollended")

print("[cckiwi_polling] Loading autorun/server/sv_polling.lua")

local pollname
local option1
local option2
local option3
local option4
local option5
local option6
local timera
local votes
local voted1
local voted2
local adminname
local id

local playerswhovoted = {}

SetGlobalBool("KiwiPollIsActive", false)
SetGlobalBool("KiwiPollIsFinished", false)

local function makepoll(adminname1, pollname1, option11, option21, option31, option41, option51, option61, timera1, id1)
	table.Empty(playerswhovoted)

	adminname = adminname1
	pollname = pollname1
	option1 = option11
	option2 = option21
	option3 = option31
	option4 = option41
	option5 = option51
	option6 = option61
	timera = timera1
	votes = 0
	voted1 = Vector(0, 0, 0)
	voted2 = Vector(0, 0, 0)
	id = id1
	hook.Run("PollStarted", adminname, pollname, option1, option2, option3, option4, option5, option6, timera, id)

	net.Start("pollnetwork")
	net.WriteString(adminname)
	net.WriteString(pollname)
	net.WriteString(option1)
	net.WriteString(option2)
	net.WriteString(option3)
	net.WriteString(option4)
	net.WriteString(option5)
	net.WriteString(option6)
	net.WriteInt(timera, 8)
	net.WriteInt(votes, 8)
	net.WriteVector(voted1)
	net.WriteVector(voted2)
	net.Broadcast()

	--set poll as active
	SetGlobalInt("KiwiPollStartTime", timera)
	SetGlobalBool("KiwiPollIsActive", true)
	SetGlobalBool("KiwiPollIsFinished", false)
	timer.Create("polltimer", 1, 0, function()
		SetGlobalInt("KiwiPollStartTime", GetGlobalInt("KiwiPollStartTime", 0) - 1)
		if GetGlobalInt("KiwiPollStartTime", 0) > 0 then
			SetGlobalBool("KiwiPollIsActive", true)
		elseif GetGlobalInt("KiwiPollStartTime", 0) > -10 then
			hook.Run("PollResults", voted1, voted2, id)
			SetGlobalBool("KiwiPollIsFinished", true)
		else
			SetGlobalBool("KiwiPollIsActive", false)
			SetGlobalBool("KiwiPollIsFinished", false)
			hook.Run("PollFinished", voted1, voted2, id)
			timer.Remove("polltimer")
		end
	end)
end

hook.Add("StartPoll", "CCKIWI_STARTPOLL", makepoll)

net.Receive("pollstarted", function(len, ply)
	if IsValid(ply) and ply:IsStaff() then
		if GetGlobalBool("KiwiPollIsActive", false) == false then
			local apollname = net.ReadString()
			local aoption1 = net.ReadString()
			local aoption2 = net.ReadString()
			local aoption3 = net.ReadString()
			local aoption4 = net.ReadString()
			local aoption5 = net.ReadString()
			local aoption6 = net.ReadString()
			local atimera = net.ReadInt(8)
			local aadminname = ply:Name()
			if apollname ~= "" and apollname ~= nil and atimera >= 10 then
				ply:ChatPrint("[cckiwi_polling] Starting poll...")
				makepoll(aadminname,apollname,aoption1,aoption2,aoption3,aoption4,aoption5,aoption6,atimera,"PlayerPoll")
			end
		else
			hook.Run("PollCancelled", ply, voted1 or 0, voted2 or 0, id or "PlayerPoll")
			timer.Remove("polltimer")
			ply:ChatPrint("[cckiwi_polling] Cancelled poll.")
			SetGlobalInt("KiwiPollStartTime", 0)
			SetGlobalBool("KiwiPollIsActive", false)
			SetGlobalBool("KiwiPollIsFinished", false)
		end
	end
end)

hook.Add( "PlayerSay", "cckiwi_polling_playersay", function( ply, text )
	if ( string.StartWith(string.lower( text ), "!vote ") ) then
		local vote = tonumber(string.sub( text, 7 ))
		PrintTable(playerswhovoted)
		if playerswhovoted[ply:UserID()] then
			ply:ChatPrint("[Polling] You have already voted in this poll!")
		elseif vote == nil or vote == "" then
			ply:ChatPrint("[Polling] You must specify a vote option!")
		elseif vote > 6 or vote < 1 then
			ply:ChatPrint("[Polling] The vote option must be in the range of 1-6.")
		elseif GetGlobalBool("KiwiPollIsActive", false) == true and GetGlobalBool("KiwiPollIsFinished", false) == false then
			local listofoptions = {
				option1,
				option2,
				option3,
				option4,
				option5,
				option6,
			}
			if listofoptions[vote] ~= nil and listofoptions[vote] ~= "" then
				ply:ChatPrint("[Polling] Your vote has been cast for option "..vote.."!")
				playerswhovoted[ply:UserID()] = vote
				if vote <= 3 then
					voted1[vote] = voted1[vote] + 1
				else
					voted2[vote-3] = voted2[vote-3] + 1
				end
				votes = votes + 1
				net.Start("pollnetwork")
				net.WriteString(adminname)
				net.WriteString(pollname)
				net.WriteString(option1)
				net.WriteString(option2)
				net.WriteString(option3)
				net.WriteString(option4)
				net.WriteString(option5)
				net.WriteString(option6)
				net.WriteInt(timera, 8)
				net.WriteInt(votes, 8)
				net.WriteVector(voted1)
				net.WriteVector(voted2)
				net.Broadcast()
				--remind players that have just joined
				SetGlobalInt("KiwiPollStartTime", GetGlobalInt("KiwiPollStartTime", 0))
				SetGlobalBool("KiwiPollIsActive", GetGlobalBool("KiwiPollIsActive", false))
				SetGlobalBool("KiwiPollIsFinished", GetGlobalBool("KiwiPollIsFinished", false))
				hook.Run("PollVote", ply, vote, id)
			else
				ply:ChatPrint("[Polling] This vote option is not present on the poll.")
			end
		else
			ply:ChatPrint("[Polling] There is no poll active at this time.")
		end
		return ""
	end
end )
