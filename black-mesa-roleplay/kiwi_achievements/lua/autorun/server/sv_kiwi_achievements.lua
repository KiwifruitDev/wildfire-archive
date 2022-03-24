/*
    Wildfire Servers - Achievement System
    File Description: Loads the Achievement System on the server
    Creation Date: 11/17/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
    All rights reserved.
*/

include("kiwi_achievements/kiwi_achievements_config.lua")
AddCSLuaFile("kiwi_achievements/kiwi_achievements_config.lua")

local playermeta = FindMetaTable("Player")

local cleanuphooks = {
    "PostCleanupMap",
    "InitPostEntity",
}

local nextthinks = {}

local databasecache = {}

for k, v in pairs(cleanuphooks) do
    sql.Query("CREATE TABLE IF NOT EXISTS kiwi_achievements (steamid TEXT, achievement TEXT, progress INTEGER, PRIMARY KEY(steamid, achievement))")
    hook.Remove(v, "KIWI_ACHIEVEMENTS_"..v)
    hook.Add(v, "KIWI_ACHIEVEMENTS_"..v, function()
        -- Check if the KIWI_ACHIEVEMENTS table exists
        if not KIWI_ACHIEVEMENTS then
            KIWI_ACHIEVEMENTS = {}
        end
        KIWI_ACHIEVEMENTS.ACHIEVEMENTS = KIWI_ACHIEVEMENTS.ACHIEVEMENTS or {}
        for k, v in pairs(KIWI_ACHIEVEMENTS.ACHIEVEMENTS) do
            -- get activation enum's key from the value
            for activationKey, activationValue in pairs(KIWI_ACHIEVEMENTS.ACHIEVEMENT_ACTIVATION_ENUM) do
                if v.Activation == activationValue then
                    hook.Remove(activationKey, "KIWI_ACHIEVEMENTS_"..k.."_"..activationKey)
                    hook.Add(activationKey, "KIWI_ACHIEVEMENTS_"..k.."_"..activationKey, function(param1, param2, param3, param4, param5) -- there is probably an easier way to do this, but idk it
                        if nextthinks[k] ~= nil and CurTime() >= nextthinks[k] or nextthinks[k] == nil then
                            if activationKey == "Think" then
                                nextthinks[k] = CurTime() + KIWI_ACHIEVEMENTS.CONST.ThinkDelay
                            end
                            local activated, play = v:ActivationCondition(param1, param2, param3, param4, param5)
                            if activated then
                                if IsValid(play) then
                                    if play:IsPlayer() then
                                        play:AddAchievementProgress(k, 1)
                                    end
                                elseif type(play) == "table" then
                                    if #play ~= 0 then
                                        for k2, v2 in pairs(play) do
                                            if not IsValid(v2) then continue end
                                            if v2:IsPlayer() then
                                                print(k2, v2)
                                                v2:AddAchievementProgress(k, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    break
                end
            end
        end
    end)
end

function KIWI_ACHIEVEMENTS.SaveCachedDatabase()
    for k, v in pairs(databasecache) do
        for k2, v2 in pairs(v) do
            sql.Query("REPLACE INTO kiwi_achievements (steamid, achievement, progress) VALUES (" .. sql.SQLStr(k) .. ", " .. sql.SQLStr(k2) .. ", " .. sql.SQLStr(v2) .. ");")
        end
    end
end

hook.Add("ShutDown", "KIWI_ACHIEVEMENTS_ShutDown", function()
    KIWI_ACHIEVEMENTS.SaveCachedDatabase()
end)

function playermeta:AddAchievementProgress(achievementName, increment)
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[achievementName]
    if not achievement then
        return
    end
    if increment <= 0 then
        increment = 1
    end
    local progress = self:GetAchievementProgress(achievementName)
    self:SetAchievementProgress(achievementName, progress + increment, true)
end

function playermeta:GetAchievementProgress(achievementName)
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[achievementName]
    if not achievement then
        return
    end
    -- use SQL to cache the data
    if databasecache[self:SteamID()] == nil then
        local result = sql.Query("SELECT * FROM kiwi_achievements WHERE steamid = " .. sql.SQLStr(self:SteamID()) .. ";")
        if result then
            databasecache[self:SteamID()] = {}
            for k, v in pairs(result) do
                databasecache[self:SteamID()][v.achievement] = tonumber(v.progress)
            end
        end
    end
    -- check if the achievement is cached
    if databasecache[self:SteamID()] and databasecache[self:SteamID()][achievementName] then
        return databasecache[self:SteamID()][achievementName]
    else
        return 0
    end
end

function playermeta:SetAchievementProgress(achievementName, progress, award)
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[achievementName]
    if not achievement then
        return
    end
    local category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORIES[achievement.Category]
    if not category then
        return
    end
    if progress < 0 then
        progress = 0
    end
    //if category.CategoryCheck == "surface" or self:CategoryCheck() == category.CategoryCheck then
        if progress >= achievement.Amount and award then
            self:AwardAchievement(achievementName)
            progress = achievement.Amount
        end
        if databasecache[self:SteamID()] == nil then
            databasecache[self:SteamID()] = {}
        end
        databasecache[self:SteamID()][achievementName] = progress
        sql.Query("REPLACE INTO kiwi_achievements (steamid, achievement, progress) VALUES (" .. sql.SQLStr(self:SteamID()) .. ", " .. sql.SQLStr(achievementName) .. ", " .. sql.SQLStr(progress) .. ");")
    //else
        //print("[KIWI_ACHIEVEMENTS] Player " .. self:Nick() .. " is not in the correct category for achievement " .. achievementName .. "!")
    //end
end

function AltasChatColor(color)
    return "<c="..color.r..","..color.g..","..color.b..">"
end

function playermeta:AwardAchievement(achievementName)
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[achievementName]
    if not achievement then
        return
    end
    if self:GetAchievementProgress(achievementName) < achievement.Amount then
        self:SetAchievementProgress(achievementName, achievement.Amount, false)
    else
        return -- already achieved
    end
    local tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIERS[achievement.Tier]
    if not tier then
        return
    end
    local category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORIES[achievement.Category]
    if not category then
        return
    end
    //if category.CategoryCheck == "surface" or self:CategoryCheck() == category.CategoryCheck then
        print("Awarding achievement "..achievementName.." to "..self:Nick())
        self:EmitSound(tier.Sound)
        local target = ents.Create("achievement_effect")
        target:SetPlayerParent(self)
        target:Spawn()
        PrintMessage(HUD_PRINTTALK, "<icon 32,32>" .. KIWI_ACHIEVEMENTS.CONST.Icon .. "</icon> <c=91,91,91>[" .. KIWI_ACHIEVEMENTS.CONST.Prefix .. "] |</c> <hsv>" .. self:Nick() .. " has earned the</hsv> " .. AltasChatColor(tier.Color) .. tier.Name .. "</c> " .. AltasChatColor(category.Color) .. category.Name .. "</c> <hsv>achievement " .. achievement.Name .. "!</hsv>")
        timer.Simple(5, function()
            if IsValid(target) then
                target:StopParticles()
                target:Remove()
            end
        end)
    //else
        //print("Awarding achievement "..achievementName.." to "..self:Nick().." but category check failed")
    //end
end

util.AddNetworkString("KIWI_ACHIEVEMENTS_GetAchievementProgress")
util.AddNetworkString("KIWI_ACHIEVEMENTS_GetAchievementProgress_Response")

net.Receive("KIWI_ACHIEVEMENTS_GetAchievementProgress", function(len, ply)
    net.Start("KIWI_ACHIEVEMENTS_GetAchievementProgress_Response")
    net.WriteUInt(table.Count(KIWI_ACHIEVEMENTS.ACHIEVEMENTS), 32)
    for k, v in pairs(KIWI_ACHIEVEMENTS.ACHIEVEMENTS) do
        net.WriteString(k)
        net.WriteUInt(ply:GetAchievementProgress(k), 32)
        -- request from SQL the amount of players who have an achievement amount of v.Amount
        local result = sql.Query("SELECT COUNT(*) AS amount FROM kiwi_achievements WHERE achievement = " .. sql.SQLStr(k) .. " AND progress = " .. sql.SQLStr(v.Amount) .. ";")
        if result then
            net.WriteUInt(result[1].amount, 32)
        else
            net.WriteUInt(0, 32)
        end
        -- request from SQL the amount of players who have an achievement amount lower than v.Amount ("working on it")
        local result = sql.Query("SELECT COUNT(*) AS amount FROM kiwi_achievements WHERE achievement = " .. sql.SQLStr(k) .. " AND progress < " .. sql.SQLStr(v.Amount) .. ";")
        if result then
            net.WriteUInt(result[1].amount, 32)
        else
            net.WriteUInt(0, 32)
        end
    end
    net.Send(ply)
end)

-- DEVELOPER COMMANDS FOR DEBUGGING

concommand.Add("kiwi_achievements_give", function(ply, cmd, args)
    if not ply:IsStaff() then
        return
    end
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[args[1]]
    if not achievement then
        return
    end
    ply:AwardAchievement(args[1])
end)

concommand.Add("kiwi_achievements_revoke", function(ply, cmd, args)
    if not ply:IsStaff() then
        return
    end
    local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[args[1]]
    if not achievement then
        return
    end
    ply:SetAchievementProgress(args[1], 0, false)
end)

concommand.Add("kiwi_achievements_revokeall", function(ply, cmd, args)
    if not ply:IsStaff() then
        return
    end
    -- delete the entire sql table for yourself
    sql.Query("DELETE FROM kiwi_achievements WHERE steamid = " .. sql.SQLStr(ply:SteamID()) .. ";")
    -- clear the cache for yourself
    if databasecache[ply:SteamID()] then
        databasecache[ply:SteamID()] = nil
    end
end)

concommand.Add("kiwi_achievements_revoke_for_everyone_yes_i_am_sure", function(ply, cmd, args)
    if not ply:IsStaff() then
        return
    end
    -- delete the entire sql table for everyone
    sql.Query("DELETE FROM kiwi_achievements;")
    -- clear the cache for everyone
    databasecache = {}
end)
