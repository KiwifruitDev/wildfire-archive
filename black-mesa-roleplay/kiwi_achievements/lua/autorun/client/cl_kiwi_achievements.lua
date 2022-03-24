/*
    Wildfire Servers - Achievement System
    File Description: Loads the Achievement System on the client
    Creation Date: 11/17/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
    All rights reserved.
*/

include("kiwi_achievements/kiwi_achievements_config.lua")

--[[

local ACHIEVEMENTS_DERMA = {}

concommand.Add("kiwi_achievementmenu", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:IsAdmin() then return end
    if not KIWI_ACHIEVEMENTS then return end
    for k, v in pairs(ACHIEVEMENTS_DERMA) do
        if IsValid(v) then
            v:Remove()
        end
    end
    net.Start("KIWI_ACHIEVEMENTS_GetAchievementProgress")
    net.SendToServer()
    -- derma
    ACHIEVEMENTS_DERMA.DermaPanel = vgui.Create("DFrame")
    ACHIEVEMENTS_DERMA.DermaPanel:SetSize(ScrW() * 0.5, ScrH() * 0.5)
    ACHIEVEMENTS_DERMA.DermaPanel:Center()
    ACHIEVEMENTS_DERMA.DermaPanel:SetTitle("Achievements")
    ACHIEVEMENTS_DERMA.DermaPanel:SetVisible(true)
    ACHIEVEMENTS_DERMA.DermaPanel:SetDraggable(true)
    ACHIEVEMENTS_DERMA.DermaPanel:ShowCloseButton(true)
    ACHIEVEMENTS_DERMA.DermaPanel:MakePopup()
    ACHIEVEMENTS_DERMA.DermaPanel:SetKeyboardInputEnabled(false)
    ACHIEVEMENTS_DERMA.DermaPanel:SetMouseInputEnabled(true)
    ACHIEVEMENTS_DERMA.DermaPanel:SetDeleteOnClose(true)
    ACHIEVEMENTS_DERMA.DermaPanel:SetSizable(true)
    ACHIEVEMENTS_DERMA.DermaPanel:SetScreenLock(true)
    ACHIEVEMENTS_DERMA.DermaPanel:SetBackgroundBlur(true)
    -- populate the list
    ACHIEVEMENTS_DERMA.DermaList = vgui.Create("DListView", ACHIEVEMENTS_DERMA.DermaPanel)
    ACHIEVEMENTS_DERMA.DermaList:SetPos(5, 30)
    ACHIEVEMENTS_DERMA.DermaList:SetSize(ACHIEVEMENTS_DERMA.DermaPanel:GetWide() - 10, ACHIEVEMENTS_DERMA.DermaPanel:GetTall() - 35)
    ACHIEVEMENTS_DERMA.DermaList:SetMultiSelect(false)
    ACHIEVEMENTS_DERMA.DermaList:AddColumn("Achievement")
    ACHIEVEMENTS_DERMA.DermaList:AddColumn("Tier")
    ACHIEVEMENTS_DERMA.DermaList:AddColumn("Category")
    ACHIEVEMENTS_DERMA.DermaList:AddColumn("Progress")
end)

net.Receive("KIWI_ACHIEVEMENTS_GetAchievementProgress_Response", function(len, ply)
    local achievementCount = net.ReadInt(32)
    for i = 1, achievementCount do
        local achievementName = net.ReadString()
        local achievementProgress = net.ReadInt(32)
        local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[achievementName]
        if not achievement then continue end
        local achievementTier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIERS[achievement.Tier]
        if not achievementTier then continue end
        local achievementCategory = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORIES[achievement.Category]
        if not achievementCategory then continue end
        if not ACHIEVEMENTS_DERMA then continue end
        if not IsValid(ACHIEVEMENTS_DERMA.DermaList) then continue end
        ACHIEVEMENTS_DERMA.DermaList:AddLine(achievement.Name, achievementTier.Name, achievementCategory.Name, achievementProgress)
    end
end)

]]--