--[[
	-| cckiwi_polling |-

	Copyright (c) 2021 KiwifruitDev
	https://github.com/TeamPopplio/
	https://steamcommunity.com/id/KiwifruitDev/

	Licensed under the MIT License.

	File description: Client polling loader cl_polling.lua
]]--

print("[cckiwi_polling] Loading autorun/client/cl_polling.lua")

-- convars
local pollname_cmd = CreateClientConVar("cckiwi_pollname", "", false, false, "Set the poll name to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option1_cmd = CreateClientConVar("cckiwi_polloption1", "", false, false, "Set the first option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option2_cmd = CreateClientConVar("cckiwi_polloption2", "", false, false, "Set the second option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option3_cmd = CreateClientConVar("cckiwi_polloption3", "", false, false, "Set the third option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option4_cmd = CreateClientConVar("cckiwi_polloption4", "", false, false, "Set the fourth option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option5_cmd = CreateClientConVar("cckiwi_polloption5", "", false, false, "Set the fifth option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local option6_cmd = CreateClientConVar("cckiwi_polloption6", "", false, false, "Set the sixth option to be sent with cckiwi_startpoll. Can be set to \"\" to remove.")
local timer_cmd = CreateClientConVar("cckiwi_polltimer", 10, false, false, "Set the time limit to be sent with cckiwi_startpoll.", 10, 600)

-- start poll
concommand.Add("cckiwi_startpoll", function(ply, cmd, args)
	net.Start("pollstarted")
	net.WriteString(pollname_cmd:GetString())
	net.WriteString(option1_cmd:GetString())
	net.WriteString(option2_cmd:GetString())
	net.WriteString(option3_cmd:GetString())
	net.WriteString(option4_cmd:GetString())
	net.WriteString(option5_cmd:GetString())
	net.WriteString(option6_cmd:GetString())
	net.WriteInt(timer_cmd:GetInt(), 8)
	net.SendToServer()
end)

hook.Add("InitPostEntity", "cckiwi_polling", function()
	vgui.Create("PollingUI")
end)

-- CLIENTSIDE FUNCTIONALITY --

local PANEL = {}

local offset = 48
local w = 512
local h = 512
local border = 8
local round = 8
local optionwidth = 32
local spacer = 8

local options = {
	0,
	0,
	0,
	0,
	0,
	0,
}

local adminname
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

local function GetTimer()
	if GetGlobalInt("KiwiPollStartTime", 0) > 0 then
		return GetGlobalInt("KiwiPollStartTime", 0)
	else
		return "Results"
	end
end

net.Receive("pollnetwork", function()
	adminname = net.ReadString()
	pollname = net.ReadString()
	option1 = net.ReadString()
	option2 = net.ReadString()
	option3 = net.ReadString()
	option4 = net.ReadString()
	option5 = net.ReadString()
	option6 = net.ReadString()
	timera = net.ReadInt(8)
	votes = net.ReadInt(8)
	voted1 = net.ReadVector()
	voted2 = net.ReadVector()
end)

function PANEL:StartShow()
	local x, y = self:GetPos()
	self.transitioning = true
	self.transitionuse = 0
	self:SetPos(0-w, y)
end

function PANEL:StartHide()
	local x, y = self:GetPos()
	self.transitioning = false
	self.transitionuse = 0
	self:SetPos(offset, y)
end

function PANEL:IsShown()
	local x, y = self:GetPos()
	return x >= offset
end

function PANEL:IsHidden()
	local x, y = self:GetPos()
	return x <= 0-w
end

function PANEL:PerformLayout()
	self:SizeToChildren(true, true)
	self:Show()
	self:SetPos(0-w, offset)
end

function PANEL:Init()
	local DPanel = vgui.Create( "DPanel", self )
	DPanel:SetSize( w, h )
	local playercount = player.GetCount()
	function DPanel:Paint( w, h )
		local x, y = self:GetPos()
		draw.DrawText((adminname or "Someone").." started a poll:", "TargetID", (x+w)/2, y+(border*2)-16, Color(255,255,255), TEXT_ALIGN_CENTER)
		surface.SetDrawColor(251, 126, 20, 128)
		-- status bar
		surface.DrawRect( x+(border*2), y+(border*2), w-(border*4), optionwidth )
		draw.DrawText(pollname or "Something went wrong when getting poll data!", "TargetID", x+(border*2)+4, y+(border*2)+8, Color(255,255,255), TEXT_ALIGN_LEFT)
		draw.DrawText(GetTimer(), "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8, Color(255,255,255), TEXT_ALIGN_RIGHT)
		local optionspace = spacer+optionwidth
		local amount = 0

		--options
		surface.SetDrawColor(127, 62, 10, 128)
		if option1 ~= nil and option1 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("1: "..(option1 or "!!!"), "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted1[1] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end
		surface.SetDrawColor(127, 62, 10, 128)
		if option2 ~= nil and option2 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("2: "..(option2 or "!!!"), "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted1[2] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end
		surface.SetDrawColor(127, 62, 10, 128)
		if option3 ~= nil and option3 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("3: "..(option3 or "!!!") or "!!!", "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted1[3] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end
		surface.SetDrawColor(127, 62, 10, 128)
		if option4 ~= nil and option4 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("4: "..(option4 or "!!!"), "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted2[1] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end
		surface.SetDrawColor(127, 62, 10, 128)
		if option5 ~= nil and option5 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("5: "..(option5 or "!!!") or "!!!", "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted1[2] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end
		surface.SetDrawColor(127, 62, 10, 128)
		if option6 ~= nil and option6 ~= "" then
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, w-(border*4), optionwidth )
			amount = amount+1
			surface.SetDrawColor(251, 126, 20, 128)
			local am = (options[amount]/playercount) * w-(border*4)
			if am > w-(border*4) then
				am = w-(border*4)
			end
			surface.DrawRect( x+(border*2), y+(border*2) + optionspace, am, optionwidth )
			draw.DrawText("6: "..(option6 or "!!!") or "!!!", "TargetID", x+(border*2)+4, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_LEFT)
			draw.DrawText(voted1[3] or "0", "TargetID", (x+(border*2)+4 + (w-(border*4))) - 8, y+(border*2)+8+optionspace, Color(255,255,255), TEXT_ALIGN_RIGHT)
			optionspace = optionspace + spacer+optionwidth
		end

		draw.DrawText("Use '!vote 1-"..amount.."' to vote on this poll.", "TargetID", (x+w)/2, y+(border*2)+optionspace-8, Color(255,255,255), TEXT_ALIGN_CENTER)
	end
	local buffer = 1
	local x, y = self:GetPos()
	hook.Add("Think", self, function(self)
		playercount = player.GetCount()
		local x, y = self:GetPos()
		if self.transitioning == nil then -- not transitioning
			if GetGlobalBool("KiwiPollIsActive", false) == false then
				if self:IsShown() then
					self:StartHide()
					options = {
						0,
						0,
						0,
						0,
						0,
						0,
					}
				end
			elseif GetGlobalBool("KiwiPollIsActive", false) == true then
				if self:IsHidden() then
					self:StartShow()
					options = {
						0,
						0,
						0,
						0,
						0,
						0,
					}
				end
			end
		elseif self.transitioning == true then -- transitioning up (showing)
			if x < offset then
				self.transitionuse = self.transitionuse + 1
				self:SetPos(x + self.transitionuse, y)
			else
				self.transitioning = nil
				self.transitionuse = 0
			end
		elseif self.transitioning == false then -- transitioning down (hiding)
			if x > 0-w then
				self.transitionuse = self.transitionuse + 1
				self:SetPos(x - self.transitionuse, y)
			else
				self.transitioning = nil
				self.transitionuse = 0
			end
		end
		if voted1 ~= nil and voted2 ~= nil then
			for k,v in ipairs(options) do
				local var = voted1
				local key = k
				if k > 3 then
					var = voted2
					key = k - 3
				end
				if var[key] > v then
					options[k] = options[k]+0.05
				end
			end
		end
	end)
end

function PANEL:HidePanel()
	self:SetPos(0, offset)
end

vgui.Register("PollingUI", PANEL, "Panel")
