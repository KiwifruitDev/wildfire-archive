/*
    Wildfire Servers - BMRP F1 Menu
    File Description: Loads the F1 menu on the server
    Creation Date: 11/8/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
*/

include("bmrp_f1/bmrp_f1_config.lua")
AddCSLuaFile("bmrp_f1/bmrp_f1_config.lua")
AddCSLuaFile("kiwi_achievements/kiwi_achievements_config.lua")

local playermeta = FindMetaTable("Player")

local function SqlQuery(query)
    //print(query, sql.Query(query))
    sql.Query(query)
end

function playermeta:SetInF1Menu(bool)
    self.InF1Menu = bool
end

function playermeta:GetInF1Menu()
    return self.InF1Menu
end

function playermeta:SetInMainMenu(bool)
    self.InMainMenu = bool
end

function playermeta:GetInMainMenu()
    return self.InMainMenu
end

function playermeta:BMRP_F1_ToggleMenu()
    if self:GetInMainMenu() then return end
    if self:GetInF1Menu() then
        self:SetInF1Menu(false)
        self:Freeze(false)
        net.Start("BMRP_F1_ToggleMenu")
        net.WriteBool(false) -- show menu
        net.WriteBool(false) -- main menu
        if self.IsStaff then -- staff
            net.WriteBool(self:IsStaff())
        else
            net.WriteBool(self:IsAdmin())
        end
        net.Send(self)
    else
        self:SetInF1Menu(true)
        self:Freeze(true)
        net.Start("BMRP_F1_ToggleMenu")
        net.WriteBool(true) -- show menu
        net.WriteBool(false) -- main menu
        if self.IsStaff then -- staff
            net.WriteBool(self:IsStaff())
        else
            net.WriteBool(self:IsAdmin())
        end
        net.Send(self)
    end
end

function playermeta:BMRP_F1_ShowMainMenu()
    self:SetDSP(BMRP_F1.CONST.DSP)
    self:SetInF1Menu(true)
    self:SetInMainMenu(true)
    self:Freeze(true)
    net.Start("BMRP_F1_ToggleMenu")
    net.WriteBool(true) -- show menu
    net.WriteBool(true) -- main menu
    if self.IsStaff then -- staff
        net.WriteBool(self:IsStaff())
    else
        net.WriteBool(self:IsAdmin())
    end
    net.Send(self)
end

util.AddNetworkString("BMRP_F1_ToggleMenu")
util.AddNetworkString("BMRP_F1_ToggleMenuFromClient")
util.AddNetworkString("BMRP_F1_ViewMainMenu")
util.AddNetworkString("BMRP_F1_ExitMainMenu")
util.AddNetworkString("BMRP_F1_SetBodyGroup")
util.AddNetworkString("BMRP_F1_SetSkin")
util.AddNetworkString("BMRP_F1_CanUsePac3")
util.AddNetworkString("BMRP_F1_YouCanUsePac3")
util.AddNetworkString("BMRP_F1_SetRPName")
util.AddNetworkString("BMRP_F1_DoINeedToSetRPName")
util.AddNetworkString("BMRP_F1_YouNeedToSetRPName")
util.AddNetworkString("BMRP_F1_VoteOnWar")
util.AddNetworkString("BMRP_F1_DidIAlreadyVote")
util.AddNetworkString("BMRP_F1_YouAlreadyVoted")
util.AddNetworkString("BMRP_F1_ShowVoteMenu")

hook.Add("ShowHelp", "BMRP_F1_ShowHelp", function(ply)
    ply:BMRP_F1_ToggleMenu()
    return true
end)

net.Receive("BMRP_F1_ToggleMenuFromClient", function(len, ply)
    ply:BMRP_F1_ToggleMenu()
end)

net.Receive("BMRP_F1_ViewMainMenu", function(len, ply)
    if ply:GetInF1Menu() then return end
    ply:BMRP_F1_ShowMainMenu()
end)

net.Receive("BMRP_F1_ExitMainMenu", function(len, ply)
    if not ply:GetInF1Menu() then return end
    ply:BMRP_F1_HideMainMenu()
end)

net.Receive("BMRP_F1_SetBodyGroup", function(len, ply)
    if not ply:GetInF1Menu() then return end
    local bodygroup = net.ReadInt(8)
    local bodygroup_id = net.ReadInt(8)
    ply:SetBodygroup(bodygroup, bodygroup_id)
end)

net.Receive("BMRP_F1_SetSkin", function(len, ply)
    if not ply:GetInF1Menu() then return end
    local skin = net.ReadInt(16)
    ply:SetSkin(skin)
end)

net.Receive("BMRP_F1_CanUsePac3", function(len, ply)
    if not ply:GetInF1Menu() then return end
    net.Start("BMRP_F1_YouCanUsePac3")
    local pacaccess = false
    if ply.HasPACAccess then
        pacaccess = ply:HasPACAccess()
    else
        pacaccess = ply:IsAdmin() -- DEBUG
    end
    net.WriteBool(pacaccess)
    net.Send(ply)
end)

local cleanuphooks = {
    "PostCleanupMap",
    "InitPostEntity",
}

for k, v in pairs(cleanuphooks) do
    SqlQuery("CREATE TABLE IF NOT EXISTS MainMenu (steamid TEXT, rpnameset BOOLEAN, activewar TEXT, warvote TEXT, PRIMARY KEY(steamid));")
    print("--- CURRENT WAR STATUS ---")
    if BMRP_F1.VOTE.VoteActive or false then
        print(BMRP_F1.VOTE.VoteName .. " is currently active!")
        local activewar = BMRP_F1.VOTE.VoteInternalName or "codeblack"
        for k, v in pairs(BMRP_F1.VOTE.VoteOptions) do
            local votes = sql.QueryValue("SELECT COUNT(*) FROM MainMenu WHERE activewar = " .. sql.SQLStr(activewar) .. " AND warvote = " .. sql.SQLStr(v.Vote) .. ";") or 0
            print((v.Name or "Unknown") .. " - " .. votes .. " votes")
        end
    else
        print("No active war!")
    end
    print("--- END WAR STATUS ---")
end

function SendVoteProgress()
    if GetConVar("bmrp_betaserver"):GetBool() == false then -- beta server should not send vote progress
        if BMRP_WEBSOCKET_CONNECTED then
            local jsontable = {
                type = "voteprogress",
                server = GetConVar("bmrp_relayname"):GetString(),
            }
            jsontable.votetitle = BMRP_F1.VOTE.VoteName
            jsontable.votedescription = BMRP_F1.VOTE.VoteDescription
            if BMRP_F1.VOTE.VoteActive then
                jsontable.votestatus = "This vote is active."
            else
                jsontable.votestatus = "This vote has ended."
            end
            jsontable.voteoptionlength = #BMRP_F1.VOTE.VoteOptions
            for k, v in pairs(BMRP_F1.VOTE.VoteOptions) do
                jsontable["voteoption"..k] = v.Name
                jsontable["voteoption"..k.."description"] = v.Description
                local votes = sql.QueryValue("SELECT COUNT(*) FROM MainMenu WHERE activewar = " .. sql.SQLStr(BMRP_F1.VOTE.VoteInternalName) .. " AND warvote = " .. sql.SQLStr(v.Vote) .. ";") or 0
                jsontable["voteoption"..k.."count"] = votes
                jsontable["voteoption"..k.."users"] = sql.Query("SELECT steamid FROM MainMenu WHERE activewar = " .. sql.SQLStr(BMRP_F1.VOTE.VoteInternalName) .. " AND warvote = " .. sql.SQLStr(v.Vote) .. ";") or {}
            end
            BMRP_WEBSOCKET:write(util.TableToJSON(jsontable))
        end
    end
end

hook.Add("BMRP_WEBSOCKET_CONNECTED", "voteprogress_update", function()
    if GetConVar("bmrp_betaserver"):GetBool() == false then -- beta server should not send vote progress
        SendVoteProgress()
    end
end)

net.Receive("BMRP_F1_VoteOnWar", function(len, ply)
    if not BMRP_F1.VOTE.VoteActive then return end
    local playervotedalready = sql.QueryValue("SELECT warvote FROM MainMenu WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. " AND activewar = " .. sql.SQLStr(BMRP_F1.VOTE.VoteInternalName) .. ";") or false
    if playervotedalready then
        ply:ChatPrint("[BMRP_F1] Error: You have already voted!")
        return
    end
    local vote = net.ReadString()
    local activewar = BMRP_F1.VOTE.VoteInternalName or "codeblack"
    SqlQuery("UPDATE MainMenu SET warvote = " .. sql.SQLStr(vote) .. " WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";")
    SqlQuery("UPDATE MainMenu SET activewar = " .. sql.SQLStr(activewar) .. " WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";")
    print("[BMRP_F1] " .. ply:Nick() .. " has voted for " .. vote .. "!")
    SendVoteProgress()
end)

net.Receive("BMRP_F1_DidIAlreadyVote", function(len, ply)
    if not ply:GetInMainMenu() then return end
    if not BMRP_F1.VOTE.VoteActive then return end
    -- get what the player voted for
    local activewar = BMRP_F1.VOTE.VoteInternalName or "codeblack"
    local playervotedalready = sql.QueryValue("SELECT warvote FROM MainMenu WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. " AND activewar = " .. sql.SQLStr(activewar) .. ";") or ""
    if playervotedalready ~= "" then
        net.Start("BMRP_F1_YouAlreadyVoted")
        net.WriteString(playervotedalready)
        net.Send(ply)
    end
end)

net.Receive("BMRP_F1_SetRPName", function(len, ply)
    if not ply:GetInMainMenu() then return end
    local rpnameset = sql.QueryValue("SELECT rpnameset FROM MainMenu WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";") or false
    if rpnameset == "1" then
        ply:ChatPrint("[BMRP_F1] Error: You have already set your RP name!")
        return
    end
    local rpname = net.ReadString()
    -- check if there is two or more words in the name (first name, last name, or more)
    -- we want to only allow these names and not one worders
    if string.find(rpname, " ") then
        if ply.setRPName then
            local oldname = ply:Nick()
            DarkRP.storeRPName(ply, rpname)
            ply:setDarkRPVar("rpname", rpname)
        else
            print("[BMRP_F1] Error: ply.setRPName is not a function! Is DarkRP installed?")
        end
        ply:BMRP_F1_HideMainMenu()
        SqlQuery("UPDATE MainMenu SET rpnameset = '1' WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";")
        print("[BMRP_F1] " .. ply:Nick() .. " has set their RP name to " .. rpname .. "!")
    else
        ply:ChatPrint("[BMRP_F1] Error: You must enter a first and last name!")
    end
end)

net.Receive("BMRP_F1_DoINeedToSetRPName", function(len, ply)
    if not ply:GetInMainMenu() then return end
    local rpnameset = sql.QueryValue("SELECT rpnameset FROM MainMenu WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";") or false
    if rpnameset == false or rpnameset == "0" then
        print("[BMRP_F1] " .. ply:Nick() .. " needs to set their RP name!")
        net.Start("BMRP_F1_YouNeedToSetRPName")
        net.Send(ply)
    end
end)

-- !motd
hook.Add("PlayerSay", "BMRP_F1_PlayerSay", function(ply, text, team)
    if string.lower(text) == "!motd" then
        ply:BMRP_F1_ToggleMenu()
        return ""
    end
end)

hook.Add("PlayerInitialSpawn", "BMRP_F1_PlayerInitialSpawn", function(ply)
    local playerisindb = sql.QueryValue("SELECT steamid FROM MainMenu WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";") or false
    if playerisindb == false then
        SqlQuery("INSERT INTO MainMenu (steamid, rpnameset, activewar, warvote) VALUES (" .. sql.SQLStr(ply:SteamID()) .. ", '0', 'none', 'none');")
    end
end)

concommand.Add("bmrp_f1_resetdb", function(ply)
    if IsValid(ply) then return end -- only run this on the server
    SqlQuery("DROP TABLE MainMenu;")
    SqlQuery("CREATE TABLE IF NOT EXISTS MainMenu (steamid TEXT, rpnameset BOOLEAN, activewar TEXT, warvote TEXT, PRIMARY KEY(steamid));")
    for _, ply in pairs(player.GetAll()) do
        SqlQuery("INSERT INTO MainMenu (steamid, rpnameset, activewar, warvote) VALUES (" .. sql.SQLStr(ply:SteamID()) .. ", '0', 'none', 'none');")
    end
    print("[BMRP_F1] Database reset!")
    SendVoteProgress()
end)

function playermeta:BMRP_F1_HideMainMenu()
    self:SetDSP(1)
    self:SetInF1Menu(false)
    self:SetInMainMenu(false)
    self:Freeze(false)
    self:ConCommand("bmrp_resetsound")
    net.Start("BMRP_F1_ToggleMenu")
    net.WriteBool(false) -- show menu
    net.WriteBool(false) -- main menu
    if self.IsStaff then -- staff
        net.WriteBool(self:IsStaff())
    else
        net.WriteBool(self:IsAdmin())
    end
    net.Send(self)
    if BMRP_F1.VOTE.VoteActive then
        local playerhasvotedalready = sql.QueryValue("SELECT activewar FROM MainMenu WHERE steamid = " .. sql.SQLStr(self:SteamID()) .. ";") or ""
        if playerhasvotedalready ~= BMRP_F1.VOTE.VoteInternalName then
            net.Start("BMRP_F1_ShowVoteMenu")
            net.Send(self)
        end
    end
end
