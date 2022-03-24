/*
    Wildfire Servers - BMRP F1 Menu
    File Description: Loads the F1 menu on the client
    Creation Date: 11/8/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
*/

include("bmrp_f1/bmrp_f1_config.lua")
include("kiwi_achievements/kiwi_achievements_config.lua")

surface.CreateFont("BMRP_F1_Font_Main", {
    font = "Roboto",
    size = 20,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_Header", {
    font = "Roboto",
    size = 50,
    weight = 700,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_MainReallySmall", {
    font = "Roboto",
    size = 20*0.75,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_HeaderReallySmall", {
    font = "Roboto",
    size = 50*0.75,
    weight = 700,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_AchievementFooter", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_AchievementFooterReallySmall", {
    font = "Roboto",
    size = 16*0.75,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
})

surface.CreateFont("BMRP_F1_Font_AchievementFooterUnderline", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
    underline = true,
    italic = true,
})

surface.CreateFont("BMRP_F1_Font_AchievementFooterUnderlineReallySmall", {
    font = "Roboto",
    size = 16*0.75,
    weight = 400,
    antialias = true,
    additive = false,
    shadow = false,
    outline = false,
    underline = true,
    italic = true,
})

-- convars
BMRP_F1.CONVARS = {}
BMRP_F1.CONVARS.Clock24Hours = CreateClientConVar("bmrp_f1_clock_24h", "0", true, false, "Should the clock display in 24 hour format?", 0, 1)
BMRP_F1.CONVARS.BackgroundMusic = CreateClientConVar("bmrp_f1_bgm", "1", true, false, "Should the background music be enabled?", 0, 1)
BMRP_F1.CONVARS.UIScale = CreateClientConVar("bmrp_f1_ui_scale", "1", true, false, "What should the UI scale be?", 0.1, nil)
BMRP_F1.CONVARS.AutoScale = CreateClientConVar("bmrp_f1_auto_scale", "1", true, false, "Should the UI scale automatically?", 0, 1)
BMRP_F1.CONVARS.HideLinks = CreateClientConVar("bmrp_f1_hide_links", "0", true, false, "Should the fake buttons (links) be hidden?", 0, 1)
BMRP_F1.CONVARS.HideStaff = CreateClientConVar("bmrp_f1_hide_staff", "0", true, false, "Should the staff menu be hidden?", 0, 1)

BMRP_F1.DERMA = BMRP_F1.DERMA or {}
BMRP_F1.VARIABLES = BMRP_F1.VARIABLES or {}

function ScaleUI(self)
    -- I was making this at one point but I couldn't get it to work.
end

function CreateHeaderButton(parent, ButtonStart, title, key, mainmenu, staff, callback)
    local btn = vgui.Create("DButton", parent)
    Text_X, Text_Y = surface.GetTextSize(string.upper(title))
    btn:SetSize(Text_X + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    btn:SetPos(ButtonStart + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat()), 0)
    btn:SetText(string.upper(title))
    btn:SetTextColor(BMRP_F1.COLOR.Highlight)
    btn:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    btn.Key = key
    btn.Paint = function(self, w, h)
        if not self:IsVisible() then return end
        surface.SetDrawColor(BMRP_F1.COLOR.Highlight)
        local offset = 0
        if BMRP_F1.VARIABLES.CurrentMenu == self.Key or self.Key == BMRP_F1.ENUM.Menu.Achievements and BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Leaderboard then
            offset = (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
            surface.DrawRect(0, h-offset, w, h)
        end
        surface.SetDrawColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.CONST.ButtonAlpha))
        if self.ButtonHovering and self.ButtonHoveredStart then
            surface.DrawRect(0, h-offset - (math.Clamp((CurTime() - self.ButtonHoveredStart or 0)/BMRP_F1.CONST.LerpSpeed, 0, 1) * h), w, h)
        elseif self.ButtonHoveredStart then
            surface.DrawRect(0, (math.Clamp((CurTime() - self.ButtonHoveredStart or 0)/BMRP_F1.CONST.LerpSpeed, 0, 1) * h), w, h)
        end
    end
    function btn:DoClick()
        if not self:IsVisible() then return end
        surface.PlaySound("UI/buttonclick.wav")
        if not callback then
            if BMRP_F1.VARIABLES.CurrentMenu ~= self.Key then
                ChangeMenu(self.Key, true, mainmenu, staff)
                self.ButtonHovering = false
                self.ButtonHoveredStart = CurTime()
            end
        else
            callback()
        end
    end
    btn.OnCursorEntered = function(self)
        if not self:IsVisible() then return end
        surface.PlaySound("UI/buttonrollover.wav")
        if BMRP_F1.VARIABLES.CurrentMenu ~= self.Key then
            self.ButtonHovering = true
            self.ButtonHoveredStart = CurTime()
        end
    end
    btn.OnCursorExited = function(self)
        if not self:IsVisible() then return end
        if BMRP_F1.VARIABLES.CurrentMenu ~= self.Key then
            self.ButtonHovering = false
            self.ButtonHoveredStart = CurTime()
        end
    end
    btn.Think = ScaleUI
    ButtonStart = ButtonStart + Text_X + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
    return btn, ButtonStart
end

function CreateFooterButton(parent, ButtonStart, title, callback, isbackbutton, isleaderboardbutton)
    local btn = vgui.Create("DButton", parent)
    if isleaderboardbutton and not BMRP_F1.VARIABLES.LastPage then
        btn.offset = ButtonStart + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        Text_X, Text_Y = surface.GetTextSize(string.upper(BMRP_F1.TEXT.BackButton))
        ButtonStart = ButtonStart - Text_X - (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) - (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
    end
    Text_X, Text_Y = surface.GetTextSize(string.upper(title))
    btn:SetSize(Text_X + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    btn:SetPos(ButtonStart + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat()), 0)
    btn:SetText(string.upper(title))
    btn:SetTextColor(BMRP_F1.COLOR.Highlight)
    btn:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    btn.Paint = function(self, w, h)
        if isbackbutton and not BMRP_F1.VARIABLES.LastPage then
            btn:SetText("")
        elseif isbackbutton and BMRP_F1.VARIABLES.LastPage then
            btn:SetText(string.upper(title))
        end
        if isleaderboardbutton and (BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Achievements) then
            btn:SetText("")
        elseif isleaderboardbutton and (BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Leaderboard or BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Achievements) then
            btn:SetText(string.upper(BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.TEXT.AchievementsMenu or BMRP_F1.TEXT.LeaderboardButton))
        end
        if isleaderboardbutton and self.offset and BMRP_F1.VARIABLES.LastPage then
            btn:SetPos(self.offset + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat()))
            self.offset = nil
        end
        surface.SetDrawColor(BMRP_F1.COLOR.Highlight)
        local offset = 0
        surface.SetDrawColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.CONST.ButtonAlpha))
        if self.ButtonHovering and self.ButtonHoveredStart then
            surface.DrawRect(0, h-offset - (math.Clamp((CurTime() - self.ButtonHoveredStart or 0)/BMRP_F1.CONST.LerpSpeed, 0, 1) * h), w, h)
        elseif self.ButtonHoveredStart then
            surface.DrawRect(0, (math.Clamp((CurTime() - self.ButtonHoveredStart or 0)/BMRP_F1.CONST.LerpSpeed, 0, 1) * h), w, h)
        end
    end
    function btn:DoClick()
        if BMRP_F1.VARIABLES.Closing then return end
        if isbackbutton and not BMRP_F1.VARIABLES.LastPage then return end
        if isleaderboardbutton and (BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Achievements) then return end
        surface.PlaySound("UI/buttonclick.wav")
        callback(self)
    end
    btn.OnCursorEntered = function(self)
        if isbackbutton and not BMRP_F1.VARIABLES.LastPage then return end
        if isleaderboardbutton and (BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Achievements) then return end
        surface.PlaySound("UI/buttonrollover.wav")
        self.ButtonHovering = true
        self.ButtonHoveredStart = CurTime()
    end
    btn.OnCursorExited = function(self)
        if isbackbutton and not BMRP_F1.VARIABLES.LastPage then return end
        if isleaderboardbutton and (BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.VARIABLES.CurrentMenu ~= BMRP_F1.ENUM.Menu.Achievements) then return end
        self.ButtonHovering = false
        self.ButtonHoveredStart = CurTime()
    end
    btn.Think = ScaleUI
    ButtonStart = ButtonStart + Text_X + (BMRP_F1.CONST.ButtonSizeOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
    return btn, ButtonStart
end

function Clock()
    if BMRP_F1.CONVARS.Clock24Hours:GetBool() then
        return os.date("%H:%M")
    else
        return os.date("%I:%M %p")
    end
end

-- label/button helper function
function LabelButton(parent, x, y, w, h, padding, text, font, textcolor, backgroundcolor, buttoncolor, selectedcolor, checkboxorbuttontext, playsounds, callback, slidermin, slidermax)
    local label = vgui.Create("DLabel", parent)
    label:SetPos(x+padding, y)
    label:SetSize(w, h)
    --uppercase first letter in text
    label:SetText(string.sub(string.upper(text), 1, 1) .. string.sub(text, 2))
    label:SetFont(font)
    label:SetTextColor(textcolor)
    label.Think = ScaleUI
    surface.SetFont(font)
    local label_x, label_y = surface.GetTextSize(text)
    if checkboxorbuttontext == true then
        -- checkbox
        local checkbox = vgui.Create("DCheckBox", parent)
        checkbox:SetPos(x + label_x + padding*2, y)
        checkbox:SetSize(h, h)
        checkbox:SetValue(BMRP_F1.VARIABLES.Settings[text])
        checkbox.OnChange = function(self, val)
            if playsounds then
                surface.PlaySound("UI/buttonclick.wav")
            end
            BMRP_F1.VARIABLES.Settings[text] = val
            if callback then
                callback(val)
            end
        end
        if playsounds then
            checkbox.OnCursorEntered = function(self)
                surface.PlaySound("UI/buttonrollover.wav")
            end
        end
        checkbox.Think = ScaleUI
    elseif checkboxorbuttontext == "slider" then
        -- slider
        local slider = vgui.Create("DNumSlider", parent)
        slider:SetPos(x + padding*2, y)
        slider:SetSize(w - padding*4, h)
        --slider:SetText(text)
        slider:SetMin(slidermin)
        slider:SetMax(slidermax)
        slider:SetDecimals(0)
        slider:SetValue(BMRP_F1.VARIABLES.Settings[text])
        slider.OnValueChanged = function(self, val)
            self:SetValue(math.Round(val))
            if math.Round(val) ~= self.OldValue then
                if self.OldValue ~= nil then    
                    if playsounds then
                        surface.PlaySound("garrysmod/content_downloaded.wav")
                    end
                end
                self.OldValue = math.Round(val)
                BMRP_F1.VARIABLES.Settings[text] = math.Round(val)
                if callback then
                    callback(math.Round(val))
                end
            end
        end
        slider.Think = ScaleUI
        if playsounds then
            slider.OnCursorEntered = function(self)
                surface.PlaySound("UI/buttonrollover.wav")
            end
        end
    elseif checkboxorbuttontext ~= nil then
        local btn = vgui.Create("DButton", parent)
        btn:SetPos(x + label_x + padding*2, y)
        btn:SetSize(w - label_x - padding*4, h)
        btn:SetText(checkboxorbuttontext)
        btn:SetTextColor(textcolor)
        btn:SetFont(font)
        btn.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, selectedcolor)
            else
                draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, buttoncolor)
            end
        end
        btn.DoClick = function(self)
            if callback then
                callback(self)
            end
            if playsounds then
                surface.PlaySound("UI/buttonclick.wav")
            end
        end
        if playsounds then
            btn.OnCursorEntered = function(self)
                surface.PlaySound("UI/buttonrollover.wav")
            end
        end
        btn.Think = ScaleUI
    end
    y = y + h + padding
    return y
end

function ConstructAchievement(parent, x, y, w, h, achievement, key, progress, players, playersworking, leaderboard)
    /*
    if progress <= 0 and achievement.Tier == KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIER_ENUM.Impossible then
        return
    end
    */
    BMRP_F1.DERMA["AchievementPanel_"..key] = vgui.Create("DPanel", parent)
    BMRP_F1.DERMA["AchievementPanel_"..key]:SetSize(w, h)
    BMRP_F1.DERMA["AchievementPanel_"..key]:SetPos(x, y)
    BMRP_F1.DERMA["AchievementPanel_"..key].Paint = function(self, w, h)
        draw.RoundedBoxEx(BMRP_F1.CONST.CornerSize, 0, 0, w, h,  ColorAlpha(BMRP_F1.COLOR.Black, 200), false, true, false, true)
    end
    local achievementicon = vgui.Create("DImage", BMRP_F1.DERMA["AchievementPanel_"..key])
    achievementicon:SetSize(h, h)
    achievementicon:SetPos(0, 0)
    achievementicon:SetImage(achievement.Icon) -- TODO: Set icon
    local achievementprogress = vgui.Create("DProgress", BMRP_F1.DERMA["AchievementPanel_"..key])
    achievementprogress:SetPos(x+h, y)
    achievementprogress:SetSize(w-h, h)
    achievementprogress:SetFraction(progress)
    achievementprogress.Paint = function(self, w, h)
        -- lerp progress the first time it's drawn
        local progress = Lerp(BMRP_F1.CONST.LerpSpeed, self.OldProgress or 0, progress)
        self.OldProgress = progress
        draw.RoundedBoxEx(BMRP_F1.CONST.CornerSize, 0, 0, w*progress, h, BMRP_F1.COLOR.MainAccent, false, true, false, true)
    end
    achievementprogress:SetPaintBackgroundEnabled(false)
    local achievementname = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
    achievementname:SetText(achievement.Name)
    achievementname:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    achievementname:SetTextColor(BMRP_F1.COLOR.Highlight)
    achievementname:SizeToContents()
    achievementname:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, BMRP_F1.CONST.AchievementPadding)
    local achievementdesc = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
    achievementdesc:SetText(achievement.Description)
    achievementdesc:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    achievementdesc:SetTextColor(BMRP_F1.COLOR.Highlight)
    achievementdesc:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, BMRP_F1.CONST.AchievementPadding*2 + achievementname:GetTall())
    achievementdesc:SetWrap(true)
    achievementdesc:SetAutoStretchVertical(true)
    achievementdesc:SetSize(w - h - BMRP_F1.CONST.AchievementPadding/2*2, h - BMRP_F1.CONST.AchievementPadding*2)
    if not leaderboard then
        local achievementauthor = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
        achievementauthor:SetText(achievement.Author)
        achievementauthor:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooterUnderline" or "BMRP_F1_Font_AchievementFooterUnderlineReallySmall")
        achievementauthor:SetTextColor(BMRP_F1.COLOR.Highlight)
        achievementauthor:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, h - BMRP_F1.CONST.AchievementPadding*2)
        achievementauthor.DoClick = function(self)
            gui.OpenURL("http://steamcommunity.com/profiles/"..achievement.AuthorSteamID)
        end
        achievementauthor:SetMouseInputEnabled( true )
        achievementauthor:SetTooltip("View the profile of "..achievement.Author)
        achievementauthor:SizeToContents()
        local achievementtier = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
        local tier = KIWI_ACHIEVEMENTS.ACHIEVEMENT_TIERS[achievement.Tier]
        achievementtier:SetText(tier.Name)
        achievementtier:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooter" or "BMRP_F1_Font_AchievementFooterReallySmall")
        achievementtier:SetTextColor(BMRP_F1.COLOR.Highlight)
        achievementtier:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, h - BMRP_F1.CONST.AchievementPadding*4)
        achievementtier:SizeToContents()
        local achievementcategory = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
        local category = KIWI_ACHIEVEMENTS.ACHIEVEMENT_CATEGORIES[achievement.Category]
        achievementcategory:SetText(category.Name)
        achievementcategory:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooter" or "BMRP_F1_Font_AchievementFooterReallySmall")
        achievementcategory:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooter" or "BMRP_F1_Font_AchievementFooterReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(achievementcategory:GetText())
        achievementcategory:SetPos(w-TEXT_X-BMRP_F1.CONST.AchievementPadding, h - BMRP_F1.CONST.AchievementPadding*4)
        achievementcategory:SizeToContents()
    else
        local achievementplayercount = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
        achievementplayercount:SetText(players < 2 and players > 0 and players.." "..BMRP_F1.TEXT.LeaderboardPlayersEarnedNonPlural or players.." "..BMRP_F1.TEXT.LeaderboardPlayersEarned)
        achievementplayercount:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooter" or "BMRP_F1_Font_AchievementFooterReallySmall")
        achievementplayercount:SetTextColor(BMRP_F1.COLOR.Highlight)
        achievementplayercount:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, h - BMRP_F1.CONST.AchievementPadding*2)
        achievementplayercount:SizeToContents()
        --if playersworking > 0 then
            local achievementplayersworking = vgui.Create("DLabel", BMRP_F1.DERMA["AchievementPanel_"..key])
            achievementplayersworking:SetText(playersworking < 2 and playersworking > 0 and playersworking.." "..BMRP_F1.TEXT.LeaderboardPlayersWorkingNonPlural or playersworking.." "..BMRP_F1.TEXT.LeaderboardPlayersWorking)
            achievementplayersworking:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_AchievementFooter" or "BMRP_F1_Font_AchievementFooterReallySmall")
            achievementplayersworking:SetTextColor(BMRP_F1.COLOR.Highlight)
            achievementplayersworking:SetPos(h + BMRP_F1.CONST.AchievementPadding/2, h - BMRP_F1.CONST.AchievementPadding*4)
            achievementplayersworking:SizeToContents()
        --end
    end
    return 0, 0
end

function ChangeMenu(newmenu, savelast, mainmenu, staff)
    if not IsValid(BMRP_F1.VARIABLES.LocalPlayer) then return end
    if not IsValid(BMRP_F1.DERMA.Contents) then return end
    if savelast then
        BMRP_F1.VARIABLES.LastPage = BMRP_F1.VARIABLES.CurrentMenu
    end
    BMRP_F1.VARIABLES.CurrentMenu = newmenu
    for _, v in ipairs( BMRP_F1.DERMA.Contents:GetChildren() ) do
        v:Remove()
    end
    local elements = {}
    if newmenu == BMRP_F1.ENUM.Menu.Main || newmenu == BMRP_F1.ENUM.Menu.Pause then
        -- main menu (only appear when BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Main)
        BMRP_F1.DERMA.MainMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.MainMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.MainMenu:SetPos(0, 0)
        BMRP_F1.DERMA.MainMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        BMRP_F1.DERMA.MainMenu.Think = ScaleUI
        table.insert(elements, BMRP_F1.DERMA.MainMenu)
        -- so there's this update image (512x768) thing that needs to be displayed here
        BMRP_F1.DERMA.MainMenu_UpdateImage = vgui.Create("DImage", BMRP_F1.DERMA.MainMenu)
        BMRP_F1.DERMA.MainMenu_UpdateImage:SetImage(BMRP_F1.IMAGE.Update)
        -- main menu components
        BMRP_F1.DERMA.MainMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.MainMenu)
        BMRP_F1.DERMA.MainMenu_Title:SetText(BMRP_F1.TEXT.MainMenuTitle)
        BMRP_F1.DERMA.MainMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.MainMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        -- we'll setpos later
        BMRP_F1.DERMA.MainMenu_Title:SizeToContents()
        BMRP_F1.DERMA.MainMenu_Title.Think = ScaleUI
        table.insert(elements, BMRP_F1.DERMA.MainMenu_Title)
        -- player's name
        BMRP_F1.DERMA.MainMenu_PlayerName = vgui.Create("DLabel", BMRP_F1.DERMA.MainMenu)
        BMRP_F1.DERMA.MainMenu_PlayerName:SetText(string.format(player.GetCount() <= 1 and BMRP_F1.TEXT.WelcomeNonPlural or BMRP_F1.TEXT.Welcome, BMRP_F1.VARIABLES.LocalPlayer:Nick(), player.GetCount(), Clock()))
        BMRP_F1.DERMA.MainMenu_PlayerName:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.MainMenu_PlayerName:SetTextColor(BMRP_F1.COLOR.Highlight)
        -- we'll setpos later
        BMRP_F1.DERMA.MainMenu_PlayerName:SizeToContents()
        BMRP_F1.DERMA.MainMenu_PlayerName.Think = function(self)
            self:SetText(string.format(player.GetCount() <= 1 and BMRP_F1.TEXT.WelcomeNonPlural or BMRP_F1.TEXT.Welcome, BMRP_F1.VARIABLES.LocalPlayer:Nick(), player.GetCount(), Clock()))
            ScaleUI(self)
        end
        table.insert(elements, BMRP_F1.DERMA.MainMenu_PlayerName)
        -- we need to scale the 512x768 image to fit the screen height
        -- place it after the text too
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.MainMenu_Title:GetText())
        BMRP_F1.DERMA.MainMenu_UpdateImage:SetSize((BMRP_F1.CONST.UpdateImageWidth * BMRP_F1.DERMA.Contents:GetTall()/BMRP_F1.CONST.UpdateImageHeight)-(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.UpdateImageHeight * BMRP_F1.DERMA.Contents:GetTall()/BMRP_F1.CONST.UpdateImageHeight)-(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.MainMenu_UpdateImage:SetPos(BMRP_F1.DERMA.Contents:GetWide() - BMRP_F1.DERMA.MainMenu_UpdateImage:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.MainMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2) --((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.Contents:GetTall() - BMRP_F1.DERMA.MainMenu_UpdateImage:GetTall() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.MainMenu_PlayerName:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.MainMenu_Title:GetY())
        BMRP_F1.DERMA.MainMenu_UpdateImage.Think = ScaleUI
        table.insert(elements, BMRP_F1.DERMA.MainMenu_UpdateImage)
        -- update information (BMRP_F1.UPDATE)
        BMRP_F1.DERMA.MainMenu_UpdateTitle = vgui.Create("DLabel", BMRP_F1.DERMA.MainMenu)
        BMRP_F1.DERMA.MainMenu_UpdateTitle:SetText(BMRP_F1.UPDATE.Name)
        BMRP_F1.DERMA.MainMenu_UpdateTitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.MainMenu_UpdateTitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.MainMenu_UpdateTitle.Think = ScaleUI
        -- place it below the text
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X2, TEXT_Y2 = surface.GetTextSize(BMRP_F1.DERMA.MainMenu_PlayerName:GetText())
        BMRP_F1.DERMA.MainMenu_UpdateTitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y2 + TEXT_Y + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2) --BMRP_F1.DERMA.MainMenu_Title:GetY() + BMRP_F1.DERMA.MainMenu_Title:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.MainMenu_UpdateTitle:SizeToContents()
        -- update description
        BMRP_F1.DERMA.MainMenu_UpdateDescription = vgui.Create("DTextEntry", BMRP_F1.DERMA.MainMenu)
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetEditable(false)
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetMultiline(true)
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetText(BMRP_F1.UPDATE.Description)
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetPaintBackground(false)
        -- place it below the title
        TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.MainMenu_UpdateTitle:GetText())
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.MainMenu_UpdateTitle:GetY())
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.MainMenu_UpdateDescription:GetText())
        BMRP_F1.DERMA.MainMenu_UpdateDescription:SetSize(ScrW(), ScrH())
        BMRP_F1.DERMA.MainMenu_UpdateDescription.Think = ScaleUI
        table.insert(elements, BMRP_F1.DERMA.MainMenu_UpdateDescription)
        table.insert(elements, BMRP_F1.DERMA.MainMenu_UpdateTitle)
    elseif newmenu == BMRP_F1.ENUM.Menu.Rules then
        -- rules menu
        BMRP_F1.DERMA.RulesMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.RulesMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.RulesMenu:SetPos(0, 0)
        BMRP_F1.DERMA.RulesMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.RulesMenu)
        -- rules title
        BMRP_F1.DERMA.RulesMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.RulesMenu)
        BMRP_F1.DERMA.RulesMenu_Title:SetText(BMRP_F1.TEXT.RulesTitle)
        BMRP_F1.DERMA.RulesMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.RulesMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.RulesMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.RulesMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.RulesMenu_Title)
        BMRP_F1.DERMA.RulesMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.RulesMenu)
        BMRP_F1.DERMA.RulesMenu_Subtitle:SetText(BMRP_F1.TEXT.RulesSubtitle)
        BMRP_F1.DERMA.RulesMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.RulesMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.RulesMenu_Title:GetText())
        BMRP_F1.DERMA.RulesMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.RulesMenu_Title:GetY())
        BMRP_F1.DERMA.RulesMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.RulesMenu_Subtitle)
        BMRP_F1.DERMA.RulesMenu_HTML = vgui.Create("DHTML", BMRP_F1.DERMA.RulesMenu)
        BMRP_F1.DERMA.RulesMenu_HTML:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.RulesMenu_Subtitle:GetY() + BMRP_F1.DERMA.RulesMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.RulesMenu_HTML:SetSize(BMRP_F1.DERMA.RulesMenu:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.RulesMenu:GetTall() - BMRP_F1.DERMA.RulesMenu_HTML:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.RulesMenu_HTML:OpenURL(BMRP_F1.URL.Rules)
        BMRP_F1.DERMA.RulesMenu_HTML.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
    elseif newmenu == BMRP_F1.ENUM.Menu.Character then
        -- character menu
        BMRP_F1.DERMA.CharacterMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.CharacterMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.CharacterMenu:SetPos(0, 0)
        BMRP_F1.DERMA.CharacterMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu)
        -- character menu title
        BMRP_F1.DERMA.CharacterMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.CharacterMenu)
        BMRP_F1.DERMA.CharacterMenu_Title:SetText(BMRP_F1.TEXT.CharacterTitle)
        BMRP_F1.DERMA.CharacterMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.CharacterMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        -- place it in the top left corner
        BMRP_F1.DERMA.CharacterMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.CharacterMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_Title)
        BMRP_F1.DERMA.CharacterMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.CharacterMenu)
        BMRP_F1.DERMA.CharacterMenu_Subtitle:SetText(BMRP_F1.TEXT.CharacterSubtitle)
        BMRP_F1.DERMA.CharacterMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.CharacterMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.CharacterMenu_Title:GetText())
        BMRP_F1.DERMA.CharacterMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.CharacterMenu_Title:GetY())
        BMRP_F1.DERMA.CharacterMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_Subtitle)
        -- character menu player model
        BMRP_F1.DERMA.CharacterMenu_PlayerModel = vgui.Create("DModelPanel", BMRP_F1.DERMA.CharacterMenu)
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetSize((BMRP_F1.CONST.UpdateImageWidth * BMRP_F1.DERMA.Contents:GetTall()/BMRP_F1.CONST.UpdateImageHeight)-(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.UpdateImageHeight * BMRP_F1.DERMA.Contents:GetTall()/BMRP_F1.CONST.UpdateImageHeight)-(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetPos(BMRP_F1.DERMA.Contents:GetWide() - BMRP_F1.DERMA.CharacterMenu_PlayerModel:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetModel(BMRP_F1.VARIABLES.LocalPlayer:GetModel())
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetFOV(45)
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_FRONT, Color(255, 255, 255))
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_RIGHT, Color(255, 255, 255))
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_LEFT, Color(255, 255, 255))
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_BACK, Color(255, 255, 255))
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetDirectionalLight(BOX_BOTTOM, Color(255, 255, 255))
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetAmbientLight(Color(255, 255, 255))
        BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetAnimSpeed(1)
        local ModelEnt = BMRP_F1.DERMA.CharacterMenu_PlayerModel:GetEntity()
        --BMRP_F1.DERMA.CharacterMenu_PlayerModel:SetAnimated(true)
        ModelEnt:SetSequence(BMRP_F1.VARIABLES.LocalPlayer:GetSequence())
        -- attachments
        local attach = BMRP_F1.VARIABLES.LocalPlayer:GetActiveWeapon()
        if IsValid(attach) then
            local attachid = attach:GetParentAttachment()
            BMRP_F1.VARIABLES.Attachment = ClientsideModel(attach:GetModel())
            if IsValid(BMRP_F1.VARIABLES.Attachment) then
                BMRP_F1.VARIABLES.Attachment:SetPos(ModelEnt:GetPos())
                BMRP_F1.VARIABLES.Attachment:SetAngles(ModelEnt:GetAngles())
                BMRP_F1.VARIABLES.Attachment:SetParent(ModelEnt, attachid)
            end
        end
        function BMRP_F1.DERMA.CharacterMenu_PlayerModel:LayoutEntity(ent)
            -- Playback rate based on anim speed
            ent:SetPlaybackRate(self:GetAnimSpeed())
            -- Advance frame
            ent:FrameAdvance()
            ent:SetAngles(ent:GetAngles() + Angle(0, 0.25, 0))
            -- seteyetarget to the front
            ent:SetEyeTarget((ent:GetPos() + ent:GetForward() * 100) + Vector(0, 0, 50))
            for k,v in pairs(ent:GetBodyGroups()) do
                ent:SetBodygroup(v.id, BMRP_F1.VARIABLES.Settings[ent:GetBodygroupName(v.id)] or 0)
            end
            ent:SetSkin(BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButtonCharacter])
        end
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_PlayerModel)
        -- dtree for character
        BMRP_F1.DERMA.CharacterMenu_Display = vgui.Create("DScrollPanel", BMRP_F1.DERMA.CharacterMenu)
        BMRP_F1.DERMA.CharacterMenu_Display:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.CharacterMenu_Subtitle:GetY() + BMRP_F1.DERMA.CharacterMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.CharacterMenu_Display:SetSize(BMRP_F1.DERMA.CharacterMenu:GetWide() - BMRP_F1.DERMA.CharacterMenu_PlayerModel:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.CharacterMenu:GetTall() - BMRP_F1.DERMA.CharacterMenu_Display:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.CharacterMenu_Display:SetBackgroundColor(ColorAlpha(BMRP_F1.COLOR.Black, 200))
        BMRP_F1.DERMA.CharacterMenu_Display.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_Display)
        -- collapsable categories
        local CategoryStart = 24
        local ButtonStart = 24
        -- this one is skins
        BMRP_F1.DERMA.CharacterMenu_Display_Categories = vgui.Create("DCollapsibleCategory", BMRP_F1.DERMA.CharacterMenu_Display)
        BMRP_F1.DERMA.CharacterMenu_Display_Categories:SetSize(BMRP_F1.DERMA.CharacterMenu_Display:GetWide(), BMRP_F1.DERMA.CharacterMenu_Display:GetTall())
        BMRP_F1.DERMA.CharacterMenu_Display_Categories:SetExpanded(true)
        BMRP_F1.DERMA.CharacterMenu_Display_Categories:SetLabel(BMRP_F1.TEXT.CategoryCharacter)
        BMRP_F1.DERMA.CharacterMenu_Display_Categories:SetExpanded(true)
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_Display_Categories)
        BMRP_F1.VARIABLES.Skins = BMRP_F1.VARIABLES.LocalPlayer:SkinCount() - 1
        if BMRP_F1.VARIABLES.Skins > 0 then
            BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButtonCharacter] = BMRP_F1.VARIABLES.LocalPlayer:GetSkin()
            -- label buttons
            ButtonStart = LabelButton(BMRP_F1.DERMA.CharacterMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.CharacterMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonCharacter, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, "slider", true, function(value)
                net.Start("BMRP_F1_SetSkin")
                net.WriteInt(value, 16)
                net.SendToServer()
            end, 0, BMRP_F1.VARIABLES.Skins)
        end
        if not mainmenu then
            ButtonStart = LabelButton(BMRP_F1.DERMA.CharacterMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.CharacterMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonPac3, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, BMRP_F1.VARIABLES.CanUsePac3 == true and BMRP_F1.TEXT.ButtonPac3 or BMRP_F1.TEXT.ButtonCantUsePac3, true, function(value)
                if BMRP_F1.VARIABLES.CanUsePac3 == true then
                    RunConsoleCommand("pac_editor")
                    net.Start("BMRP_F1_ToggleMenuFromClient")
                    net.SendToServer()
                else
                    surface.PlaySound("buttons/button10.wav")
                end
            end, 0, BMRP_F1.VARIABLES.Skins)
        end
        CategoryStart = CategoryStart + ButtonStart
        ButtonStart = 24
        -- get all bodygroups of the player model and display them
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups = vgui.Create("DCollapsibleCategory", BMRP_F1.DERMA.CharacterMenu_Display)
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:SetSize(BMRP_F1.DERMA.CharacterMenu_Display:GetWide(), BMRP_F1.DERMA.CharacterMenu_Display:GetTall())
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:SetPos(0, CategoryStart + BMRP_F1.CONST.CategoryOffset)
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:SetExpanded(true)
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:SetLabel(BMRP_F1.TEXT.CategoryBodygroups)
        BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:SetExpanded(true)
        table.insert(elements, BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups)
        function BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups:Think()
            -- if the above category is collapsed, move this category up
            self:SetPos(0, BMRP_F1.DERMA.CharacterMenu_Display_Categories:GetTall() + BMRP_F1.CONST.CategoryOffset)
        end
        -- get all bodygroups of the player model and display them
        BMRP_F1.VARIABLES.Bodygroups = {}
        for k, v in pairs(BMRP_F1.VARIABLES.LocalPlayer:GetBodyGroups()) do
            BMRP_F1.VARIABLES.Bodygroups[k] = {}
            for k2, v2 in pairs(v.submodels) do
                BMRP_F1.VARIABLES.Bodygroups[k][k2] = v2
            end
        end
        for k, v in pairs(BMRP_F1.VARIABLES.Bodygroups) do
            local bodygroupname = BMRP_F1.VARIABLES.LocalPlayer:GetBodygroupName(k)
            local max = BMRP_F1.VARIABLES.LocalPlayer:GetBodygroupCount(k)
            if max-1 <= 0 then continue end
            if bodygroupname == "" then continue end
            BMRP_F1.VARIABLES.Settings[bodygroupname] = BMRP_F1.VARIABLES.LocalPlayer:GetBodygroup(k)
            ButtonStart = LabelButton(BMRP_F1.DERMA.CharacterMenu_Display_Bodygroups, 0, ButtonStart, BMRP_F1.DERMA.CharacterMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, bodygroupname, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, "slider", true, function(value)
                net.Start("BMRP_F1_SetBodyGroup")
                net.WriteInt(k, 8)
                net.WriteInt(value, 8)
                net.SendToServer()
            end, 0, max-1)
        end
    elseif newmenu == BMRP_F1.ENUM.Menu.Achievements then
        -- Achievements menu
        BMRP_F1.DERMA.AchievementsMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.AchievementsMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.AchievementsMenu:SetPos(0, 0)
        BMRP_F1.DERMA.AchievementsMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.AchievementsMenu)
        -- Achievements title
        BMRP_F1.DERMA.AchievementsMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.AchievementsMenu)
        BMRP_F1.DERMA.AchievementsMenu_Title:SetText(BMRP_F1.TEXT.AchievementsTitle)
        BMRP_F1.DERMA.AchievementsMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.AchievementsMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.AchievementsMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.AchievementsMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.AchievementsMenu_Title)
        BMRP_F1.DERMA.AchievementsMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.AchievementsMenu)
        BMRP_F1.DERMA.AchievementsMenu_Subtitle:SetText(BMRP_F1.TEXT.AchievementsSubtitle)
        BMRP_F1.DERMA.AchievementsMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.AchievementsMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.AchievementsMenu_Title:GetText())
        BMRP_F1.DERMA.AchievementsMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.AchievementsMenu_Title:GetY())
        BMRP_F1.DERMA.AchievementsMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.AchievementsMenu_Subtitle)
        BMRP_F1.DERMA.AchievementsMenu_Display = vgui.Create("DScrollPanel", BMRP_F1.DERMA.AchievementsMenu)
        BMRP_F1.DERMA.AchievementsMenu_Display:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.AchievementsMenu_Subtitle:GetY() + BMRP_F1.DERMA.AchievementsMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.AchievementsMenu_Display:SetSize(BMRP_F1.DERMA.AchievementsMenu:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.AchievementsMenu:GetTall() - BMRP_F1.DERMA.AchievementsMenu_Display:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.AchievementsMenu_Display.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
        table.insert(elements, BMRP_F1.DERMA.AchievementsMenu_Display)
        BMRP_F1.DERMA.AchievementsMenu_Display_List = vgui.Create("DIconLayout", BMRP_F1.DERMA.AchievementsMenu_Display)
        BMRP_F1.DERMA.AchievementsMenu_Display_List:SetSize(BMRP_F1.DERMA.AchievementsMenu_Display:GetWide(), BMRP_F1.DERMA.AchievementsMenu_Display:GetTall())
        BMRP_F1.DERMA.AchievementsMenu_Display_List:SetPos(0, 0)
        BMRP_F1.DERMA.AchievementsMenu_Display_List:SetSpaceY(BMRP_F1.CONST.HeaderBarHeight/2 * BMRP_F1.CONVARS.UIScale:GetFloat())
        BMRP_F1.DERMA.AchievementsMenu_Display_List:SetSpaceX(BMRP_F1.CONST.HeaderBarHeight/2 * BMRP_F1.CONVARS.UIScale:GetFloat())
        table.insert(elements, BMRP_F1.DERMA.AchievementsMenu_Display_List)
        if KIWI_ACHIEVEMENTS then
            net.Start("KIWI_ACHIEVEMENTS_GetAchievementProgress")
            net.SendToServer()
        else
            print("[BMRP_F1] No achievements found!")
        end
    elseif newmenu == BMRP_F1.ENUM.Menu.Leaderboard then
        -- Achievements menu
        BMRP_F1.DERMA.LeaderboardMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.LeaderboardMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.LeaderboardMenu:SetPos(0, 0)
        BMRP_F1.DERMA.LeaderboardMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.LeaderboardMenu)
        -- Achievements title
        BMRP_F1.DERMA.LeaderboardMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.LeaderboardMenu)
        BMRP_F1.DERMA.LeaderboardMenu_Title:SetText(BMRP_F1.TEXT.LeaderboardButton)
        BMRP_F1.DERMA.LeaderboardMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.LeaderboardMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.LeaderboardMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.LeaderboardMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.LeaderboardMenu_Title)
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.LeaderboardMenu)
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle:SetText(BMRP_F1.TEXT.LeaderboardSubtitle)
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.LeaderboardMenu_Title:GetText())
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.LeaderboardMenu_Title:GetY())
        BMRP_F1.DERMA.LeaderboardMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.LeaderboardMenu_Subtitle)
        BMRP_F1.DERMA.LeaderboardMenu_Display = vgui.Create("DScrollPanel", BMRP_F1.DERMA.LeaderboardMenu)
        BMRP_F1.DERMA.LeaderboardMenu_Display:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.LeaderboardMenu_Subtitle:GetY() + BMRP_F1.DERMA.LeaderboardMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.LeaderboardMenu_Display:SetSize(BMRP_F1.DERMA.LeaderboardMenu:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.LeaderboardMenu:GetTall() - BMRP_F1.DERMA.LeaderboardMenu_Display:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.LeaderboardMenu_Display.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
        table.insert(elements, BMRP_F1.DERMA.LeaderboardMenu_Display)
        BMRP_F1.DERMA.LeaderboardMenu_Display_List = vgui.Create("DIconLayout", BMRP_F1.DERMA.LeaderboardMenu_Display)
        BMRP_F1.DERMA.LeaderboardMenu_Display_List:SetSize(BMRP_F1.DERMA.LeaderboardMenu_Display:GetWide(), BMRP_F1.DERMA.LeaderboardMenu_Display:GetTall())
        BMRP_F1.DERMA.LeaderboardMenu_Display_List:SetPos(0, 0)
        BMRP_F1.DERMA.LeaderboardMenu_Display_List:SetSpaceY(BMRP_F1.CONST.HeaderBarHeight/2 * BMRP_F1.CONVARS.UIScale:GetFloat())
        BMRP_F1.DERMA.LeaderboardMenu_Display_List:SetSpaceX(BMRP_F1.CONST.HeaderBarHeight/2 * BMRP_F1.CONVARS.UIScale:GetFloat())
        table.insert(elements, BMRP_F1.DERMA.LeaderboardMenu_Display_List)
        if KIWI_ACHIEVEMENTS then
            net.Start("KIWI_ACHIEVEMENTS_GetAchievementProgress")
            net.SendToServer()
        else
            print("[BMRP_F1] No achievements found!")
        end
    elseif newmenu == BMRP_F1.ENUM.Menu.Settings then
        -- Settings menu
        BMRP_F1.DERMA.SettingsMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.SettingsMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.SettingsMenu:SetPos(0, 0)
        BMRP_F1.DERMA.SettingsMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.SettingsMenu)
        -- Settings title
        BMRP_F1.DERMA.SettingsMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.SettingsMenu)
        BMRP_F1.DERMA.SettingsMenu_Title:SetText(BMRP_F1.TEXT.SettingsTitle)
        BMRP_F1.DERMA.SettingsMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.SettingsMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.SettingsMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.SettingsMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.SettingsMenu_Title)
        BMRP_F1.DERMA.SettingsMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.SettingsMenu)
        BMRP_F1.DERMA.SettingsMenu_Subtitle:SetText(BMRP_F1.TEXT.SettingsSubtitle)
        BMRP_F1.DERMA.SettingsMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.SettingsMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.SettingsMenu_Title:GetText())
        BMRP_F1.DERMA.SettingsMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.SettingsMenu_Title:GetY())
        BMRP_F1.DERMA.SettingsMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.SettingsMenu_Subtitle)
        BMRP_F1.DERMA.SettingsMenu_Display = vgui.Create("DScrollPanel", BMRP_F1.DERMA.SettingsMenu)
        BMRP_F1.DERMA.SettingsMenu_Display:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.SettingsMenu_Subtitle:GetY() + BMRP_F1.DERMA.SettingsMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.SettingsMenu_Display:SetSize(BMRP_F1.DERMA.SettingsMenu:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.SettingsMenu:GetTall() - BMRP_F1.DERMA.SettingsMenu_Display:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.SettingsMenu_Display.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
        table.insert(elements, BMRP_F1.DERMA.SettingsMenu_Display)
        -- collapsable categories
        local CategoryStart = 24
        local ButtonStart = 24
        BMRP_F1.DERMA.SettingsMenu_Display_Categories = vgui.Create("DCollapsibleCategory", BMRP_F1.DERMA.SettingsMenu_Display)
        BMRP_F1.DERMA.SettingsMenu_Display_Categories:SetSize(BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.DERMA.SettingsMenu_Display:GetTall())
        BMRP_F1.DERMA.SettingsMenu_Display_Categories:SetExpanded(true)
        BMRP_F1.DERMA.SettingsMenu_Display_Categories:SetLabel(BMRP_F1.TEXT.CategoryMenuSettings)
        BMRP_F1.DERMA.SettingsMenu_Display_Categories:SetExpanded(true)
        table.insert(elements, BMRP_F1.DERMA.SettingsMenu_Display_Categories)
        -- BMRP_F1.CONVARS.Clock24Hours
        BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButton24HourClock] = BMRP_F1.CONVARS.Clock24Hours:GetBool()
        ButtonStart = LabelButton(BMRP_F1.DERMA.SettingsMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButton24HourClock, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, true, true, function(value)
            BMRP_F1.CONVARS.Clock24Hours:SetBool(value)
        end)
        -- BMRP_F1.CONVARS.BackgroundMusic
        BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButtonBackgroundMusic] = BMRP_F1.CONVARS.BackgroundMusic:GetBool()
        ButtonStart = LabelButton(BMRP_F1.DERMA.SettingsMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonBackgroundMusic, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, true, true, function(value)
            BMRP_F1.CONVARS.BackgroundMusic:SetBool(value)
            if BMRP_F1.VARIABLES.BackgroundMusic ~= nil then
                if value then
                    BMRP_F1.VARIABLES.BackgroundMusic:Play()
                else
                    BMRP_F1.VARIABLES.BackgroundMusic:Stop()
                end
            end
        end)
        BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButtonHideLinks] = BMRP_F1.CONVARS.HideLinks:GetBool()
        ButtonStart = LabelButton(BMRP_F1.DERMA.SettingsMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonHideLinks, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, true, true, function(value)
            BMRP_F1.CONVARS.HideLinks:SetBool(value)
            CreateHeader(mainmenu, staff)
        end)
        if staff then
            BMRP_F1.VARIABLES.Settings[BMRP_F1.TEXT.LabelButtonHideStaff] = BMRP_F1.CONVARS.HideStaff:GetBool()
            ButtonStart = LabelButton(BMRP_F1.DERMA.SettingsMenu_Display_Categories, 0, ButtonStart, BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonHideStaff, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, true, true, function(value)
                BMRP_F1.CONVARS.HideStaff:SetBool(value)
                CreateHeader(mainmenu, staff)
            end)
        end
        CategoryStart = CategoryStart + ButtonStart
        ButtonStart = 24
        BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral = vgui.Create("DCollapsibleCategory", BMRP_F1.DERMA.SettingsMenu_Display)
        BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral:SetSize(BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.DERMA.SettingsMenu_Display:GetTall())
        BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral:SetExpanded(true)
        BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral:SetLabel(BMRP_F1.TEXT.CategoryGeneralSettings)
        BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral:SetExpanded(true)
        function BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral:Think()
            -- if the above category is collapsed, move this category up
            self:SetPos(0, BMRP_F1.DERMA.SettingsMenu_Display_Categories:GetTall() + BMRP_F1.CONST.CategoryOffset)
        end
        ButtonStart = LabelButton(BMRP_F1.DERMA.SettingsMenu_Display_CategoryGeneral, 0, ButtonStart, BMRP_F1.DERMA.SettingsMenu_Display:GetWide(), BMRP_F1.CONST.ButtonSize, BMRP_F1.CONST.ButtonPadding, BMRP_F1.TEXT.LabelButtonEngineMenu, BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", BMRP_F1.COLOR.Highlight, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.Black, BMRP_F1.COLOR.MainAccent, BMRP_F1.TEXT.ButtonEngineMenu, true, function(value)
            RunConsoleCommand("gameui_activate")
            RunConsoleCommand("gamemenucommand", "openoptionsdialog")
        end)
    elseif newmenu == BMRP_F1.ENUM.Menu.Staff then
        -- Staff menu
        BMRP_F1.DERMA.StaffMenu = vgui.Create("DPanel", BMRP_F1.DERMA.Contents)
        BMRP_F1.DERMA.StaffMenu:SetSize(BMRP_F1.DERMA.Contents:GetWide(), BMRP_F1.DERMA.Contents:GetTall())
        BMRP_F1.DERMA.StaffMenu:SetPos(0, 0)
        BMRP_F1.DERMA.StaffMenu:SetBackgroundColor(BMRP_F1.COLOR.Clear)
        table.insert(elements, BMRP_F1.DERMA.StaffMenu)
        -- Staff title
        BMRP_F1.DERMA.StaffMenu_Title = vgui.Create("DLabel", BMRP_F1.DERMA.StaffMenu)
        BMRP_F1.DERMA.StaffMenu_Title:SetText(BMRP_F1.TEXT.StaffTitle)
        BMRP_F1.DERMA.StaffMenu_Title:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        BMRP_F1.DERMA.StaffMenu_Title:SetTextColor(BMRP_F1.COLOR.Highlight)
        BMRP_F1.DERMA.StaffMenu_Title:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.StaffMenu_Title:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.StaffMenu_Title)
        BMRP_F1.DERMA.StaffMenu_Subtitle = vgui.Create("DLabel", BMRP_F1.DERMA.StaffMenu)
        BMRP_F1.DERMA.StaffMenu_Subtitle:SetText(BMRP_F1.TEXT.StaffSubtitle)
        BMRP_F1.DERMA.StaffMenu_Subtitle:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        BMRP_F1.DERMA.StaffMenu_Subtitle:SetTextColor(BMRP_F1.COLOR.Highlight)
        surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Header" or "BMRP_F1_Font_HeaderReallySmall")
        local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.DERMA.StaffMenu_Title:GetText())
        BMRP_F1.DERMA.StaffMenu_Subtitle:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, TEXT_Y + BMRP_F1.DERMA.StaffMenu_Title:GetY())
        BMRP_F1.DERMA.StaffMenu_Subtitle:SizeToContents()
        table.insert(elements, BMRP_F1.DERMA.StaffMenu_Subtitle)
        BMRP_F1.DERMA.StaffMenu_Display = vgui.Create("DScrollPanel", BMRP_F1.DERMA.StaffMenu)
        BMRP_F1.DERMA.StaffMenu_Display:SetPos((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2, BMRP_F1.DERMA.StaffMenu_Subtitle:GetY() + BMRP_F1.DERMA.StaffMenu_Subtitle:GetTall() + (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())/2)
        BMRP_F1.DERMA.StaffMenu_Display:SetSize(BMRP_F1.DERMA.StaffMenu:GetWide() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.StaffMenu:GetTall() - BMRP_F1.DERMA.StaffMenu_Display:GetY() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.StaffMenu_Display.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
        end
        table.insert(elements, BMRP_F1.DERMA.StaffMenu_Display)
    end
    -- fade in all elements
    for k, v in pairs(elements) do
        if IsValid(v) then
            v:SetAlpha(0)
            v:AlphaTo(255, BMRP_F1.CONST.FadeInTime)
        end
    end
end

function CreateHeader(mainmenu, staff)
    -- header bar
    if IsValid(BMRP_F1.DERMA.HeaderBar) then BMRP_F1.DERMA.HeaderBar:Remove() end
    BMRP_F1.DERMA.HeaderBar = vgui.Create("DPanel")
    BMRP_F1.DERMA.HeaderBar:SetPos(0, 0)
    BMRP_F1.DERMA.HeaderBar.Paint = function(self, w, h)
        local w, h = self:GetSize()
        surface.SetDrawColor(ColorAlpha(BMRP_F1.COLOR.MainAccent, 200))
        -- draw a bar with a triangle on the right side of the header bar (poly)
        /*
        surface.DrawPoly({
            {x = (ScrW()/2)+50, y = 0},
            {x = 0, y = 0},
            {x = 0, y = (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())},
            {x = (ScrW()/2)-50, y = (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat())},
        })
        */
        draw.NoTexture()
        surface.DrawRect(0, 0, w-(BMRP_F1.CONST.TrianglePiece * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        surface.SetMaterial(BMRP_F1.MATERIAL.Triangle)
        surface.DrawTexturedRect(w-(BMRP_F1.CONST.TrianglePiece * BMRP_F1.CONVARS.UIScale:GetFloat()), 0, (BMRP_F1.CONST.TrianglePiece * BMRP_F1.CONVARS.UIScale:GetFloat()), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    end
    -- header bar children (icon)
    if IsValid(BMRP_F1.DERMA.HeaderIcon) then BMRP_F1.DERMA.HeaderIcon:Remove() end
    BMRP_F1.DERMA.HeaderIcon = vgui.Create("DImage", BMRP_F1.DERMA.HeaderBar)
    BMRP_F1.DERMA.HeaderIcon:SetSize(40, 40)
    BMRP_F1.DERMA.HeaderIcon:SetPos(12, 12)
    BMRP_F1.DERMA.HeaderIcon:SetImage(BMRP_F1.IMAGE.Icon)
    BMRP_F1.DERMA.HeaderIcon.Paint = function(self, w, h)
        render.PushFilterMin( TEXFILTER.ANISOTROPIC )

        surface.SetMaterial( BMRP_F1.MATERIAL.Icon )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRect( 0, 0, w, h )

        render.PopFilterMin()
    end
    BMRP_F1.DERMA.HeaderIcon.Think = function(self)
        -- if the scale is too small (<1), drop the text
        if (BMRP_F1.CONVARS.UIScale:GetFloat() < 1) then
            self:SetVisible(false)
        else
            self:SetVisible(true)
        end
    end
    -- header text
    if IsValid(BMRP_F1.DERMA.HeaderText) then BMRP_F1.DERMA.HeaderText:Remove() end
    BMRP_F1.DERMA.HeaderText = vgui.Create("DLabel", BMRP_F1.DERMA.HeaderBar)
    BMRP_F1.DERMA.HeaderText:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    BMRP_F1.DERMA.HeaderText:SetText(string.upper(BMRP_F1.TEXT.Title))
    BMRP_F1.DERMA.HeaderText:SetTextColor(BMRP_F1.COLOR.Highlight)
    surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    local Text_X, Text_Y = surface.GetTextSize(string.upper(BMRP_F1.TEXT.Title))
    BMRP_F1.DERMA.HeaderText:SetPos(64, ((BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()) - Text_Y) / 2)
    BMRP_F1.DERMA.HeaderText:SetSize(Text_X, Text_Y)
    BMRP_F1.DERMA.HeaderText:SetContentAlignment(5)
    BMRP_F1.DERMA.HeaderText.Think = function(self)
        -- if the scale is too small (<1), drop the text
        if (BMRP_F1.CONVARS.UIScale:GetFloat() < 1) then
            self:SetVisible(false)
        else
            self:SetVisible(true)
        end
    end
    -- header buttons (info, settings, exit)
    local ButtonStart = (BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and Text_X + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) or 0)
    if mainmenu then
        if IsValid(BMRP_F1.DERMA.HeaderButtonMainMenu) then BMRP_F1.DERMA.HeaderButtonMainMenu:Remove() end
        BMRP_F1.DERMA.HeaderButtonMainMenu, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.MainMenu, BMRP_F1.ENUM.Menu.Main, mainmenu, staff)
        BMRP_F1.VARIABLES.CurrentMenu = BMRP_F1.ENUM.Menu.Main
    else
        if IsValid(BMRP_F1.DERMA.HeaderButtonPause) then BMRP_F1.DERMA.HeaderButtonPause:Remove() end
        BMRP_F1.DERMA.HeaderButtonPause, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.PauseMenu, BMRP_F1.ENUM.Menu.Pause, mainmenu, staff)
        BMRP_F1.VARIABLES.CurrentMenu = BMRP_F1.VARIABLES.CurrentMenu or BMRP_F1.ENUM.Menu.Pause
    end 
    if IsValid(BMRP_F1.DERMA.HeaderButtonRules) then BMRP_F1.DERMA.HeaderButtonRules:Remove() end
    BMRP_F1.DERMA.HeaderButtonRules, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.RulesMenu, BMRP_F1.ENUM.Menu.Rules, mainmenu, staff)
    if IsValid(BMRP_F1.DERMA.HeaderButtonCharacter) then BMRP_F1.DERMA.HeaderButtonCharacter:Remove() end
    BMRP_F1.DERMA.HeaderButtonCharacter, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.CharacterMenu, BMRP_F1.ENUM.Menu.Character, mainmenu, staff)
    if IsValid(BMRP_F1.DERMA.HeaderButtonAchievements) then BMRP_F1.DERMA.HeaderButtonAchievements:Remove() end
    BMRP_F1.DERMA.HeaderButtonAchievements, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.AchievementsMenu, BMRP_F1.ENUM.Menu.Achievements, mainmenu, staff)
    BMRP_F1.DERMA.HeaderButtonSettings, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.SettingsMenu, BMRP_F1.ENUM.Menu.Settings, mainmenu, staff)
    if staff then
        if IsValid(BMRP_F1.DERMA.HeaderButtonStaff) then BMRP_F1.DERMA.HeaderButtonStaff:Remove() end
        if not BMRP_F1.CONVARS.HideStaff:GetBool() then
            -- STAFF MENU IS DISABLED!
            --BMRP_F1.DERMA.HeaderButtonStaff, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.StaffMenu, BMRP_F1.ENUM.Menu.Staff, mainmenu, staff)
        end
    elseif BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Staff then
        BMRP_F1.VARIABLES.CurrentMenu = BMRP_F1.ENUM.Menu.Achievements
    end
    -- links
    if IsValid(BMRP_F1.DERMA.HeaderButtonDiscord) then BMRP_F1.DERMA.HeaderButtonDiscord:Remove() end
    if IsValid(BMRP_F1.DERMA.HeaderButtonDonate) then BMRP_F1.DERMA.HeaderButtonDonate:Remove() end
    if not BMRP_F1.CONVARS.HideLinks:GetBool() then
        BMRP_F1.DERMA.HeaderButtonDiscord, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.DiscordMenu, BMRP_F1.ENUM.Menu.None, mainmenu, staff, function()
            gui.OpenURL(BMRP_F1.URL.Discord)
        end)
        BMRP_F1.DERMA.HeaderButtonDonate, ButtonStart = CreateHeaderButton(BMRP_F1.DERMA.HeaderBar, ButtonStart, BMRP_F1.TEXT.DonateMenu, BMRP_F1.ENUM.Menu.None, mainmenu, staff, function()
            gui.OpenURL(BMRP_F1.URL.Donate)
        end)
    end
    BMRP_F1.DERMA.HeaderBar:SetSize(ButtonStart + (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat()) + (BMRP_F1.CONST.TrianglePiece * BMRP_F1.CONVARS.UIScale:GetFloat())*2, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
end

function BMRP_F1_ShowMenu(mainmenu, staff)
    if BMRP_F1.VARIABLES.MenuOpen then return end
    if BMRP_F1.VARIABLES.BlurOpen then return end
    if BMRP_F1.VARIABLES.Closing then return end
    BMRP_F1.VARIABLES.NeedToSetRPName = false
    BMRP_F1.VARIABLES.LocalPlayer = LocalPlayer()
    if not IsValid(BMRP_F1.VARIABLES.LocalPlayer) then return end
    net.Start("BMRP_F1_DoINeedToSetRPName")
    net.SendToServer()
    net.Start("BMRP_F1_DidIAlreadyVote")
    net.SendToServer()
    net.Start("BMRP_F1_CanUsePac3")
    net.SendToServer()
    if not BMRP_F1.VARIABLES.Settings then
        BMRP_F1.VARIABLES.Settings = {}
    end
    gui.EnableScreenClicker(true)

    timer.Remove("BMRP_F1_Delete")
    input.SetCursorPos(BMRP_F1.VARIABLES.MouseX or ScrW()/2, BMRP_F1.VARIABLES.MouseY or ScrH()/2)
    for k, v in pairs(BMRP_F1.DERMA) do
        if type(v) == "Panel" and IsValid(v) then
            v:Remove()
        end
    end
    if BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Main and not mainmenu then
        BMRP_F1.VARIABLES.CurrentMenu = BMRP_F1.ENUM.Menu.Pause
    elseif BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Pause and mainmenu then
        BMRP_F1.VARIABLES.CurrentMenu = BMRP_F1.ENUM.Menu.Main
    end
    -- automatically adjust scale if screen resolution is too small
    if BMRP_F1.CONVARS.AutoScale:GetBool() then
        if ScrH() < BMRP_F1.CONST.MinScreenHeight then
            BMRP_F1.CONVARS.UIScale:SetFloat(ScrH()/BMRP_F1.CONST.MinScreenHeight)
        else
            BMRP_F1.CONVARS.UIScale:SetFloat(1)
        end
    end
    BMRP_F1.VARIABLES.Closing = false
    BMRP_F1.VARIABLES.LastPage = nil
    BMRP_F1.VARIABLES.MenuOpen = true
    BMRP_F1.VARIABLES.BlurStart = CurTime()
    BMRP_F1.VARIABLES.BlurOpen = true
    -- background
    BMRP_F1.DERMA.BackgroundPanel = vgui.Create("DPanel")
    BMRP_F1.DERMA.BackgroundPanel:SetSize(ScrW(), ScrH())
    BMRP_F1.DERMA.BackgroundPanel:SetPos(0, 0)
    BMRP_F1.DERMA.BackgroundPanel.Paint = function(self, w, h)
        -- blur and unblur, whichever bluropen is set to
        -- disabled because it breaks poly drawing
        if not BMRP_F1.VARIABLES.BlurOpen then
            BMRP_F1.VARIABLES.Fraction = BMRP_F1.VARIABLES.Fraction - BMRP_F1.CONST.BlurTime*FrameTime()
            if BMRP_F1.VARIABLES.Fraction <= 0 then
                BMRP_F1.VARIABLES.Fraction = 0
            end
        else
            BMRP_F1.VARIABLES.Fraction = math.Clamp((CurTime() - BMRP_F1.VARIABLES.BlurStart) / BMRP_F1.CONST.BlurTime, 0, 1)
        end

        -- instead we're going to just draw a rect
        --surface.SetDrawColor( 10, 10, 10, 200 * BMRP_F1.VARIABLES.Fraction )
        --surface.DrawRect(0, 0, w, h)
        
        local x, y = self:LocalToScreen( 0, 0 )
        local wasEnabled = DisableClipping( true )
        surface.SetMaterial( BMRP_F1.MATERIAL.Blur )
        surface.SetDrawColor( 255, 255, 255, 255 )
        for i=0.33, 1, 0.33 do
            BMRP_F1.MATERIAL.Blur:SetFloat( "$blur", BMRP_F1.VARIABLES.Fraction * 5 * i )
            BMRP_F1.MATERIAL.Blur:SetInt( "$flags", bit.bor( BMRP_F1.MATERIAL.Blur:GetInt( "$flags" ), 32768 ) )
            BMRP_F1.MATERIAL.Blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
        end
        surface.SetDrawColor( 10, 10, 10, 200 * BMRP_F1.VARIABLES.Fraction )
        surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )
        DisableClipping( wasEnabled )
    end
    CreateHeader(mainmenu, staff)
    if IsValid(BMRP_F1.DERMA.HeaderBar) then
        BMRP_F1.DERMA.HeaderBar:SetPos(0, -(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
        BMRP_F1.DERMA.HeaderBar:MoveTo(0, 0, BMRP_F1.CONST.LerpSpeed, 0, 1)
    else
        print("[BMRP_F1] Error: HeaderBar is not valid! How did we get here?")
    end
    -- well first of all let's see if we have the HL1 music present as otherwise we'll drop to the HL1 music installed into HL2 (already present in the table)
    BMRP_F1.VARIABLES.MusicExtension = table.Copy(BMRP_F1.MUSIC)
    if BMRP_F1.CONST.HL1MusicAllowed then
        local HL1Music = file.Find("sound/music/half-life*.mp3", "GAME")
        if #HL1Music > 0 then
            table.Empty(BMRP_F1.VARIABLES.MusicExtension)
            for k, v in pairs(HL1Music) do
                table.insert(BMRP_F1.VARIABLES.MusicExtension, "music/"..v)
            end
        end
    end
    -- play background music (to be removed later when the menu is closed)
    BMRP_F1.VARIABLES.BackgroundMusic = CreateSound(BMRP_F1.VARIABLES.LocalPlayer, table.Random(BMRP_F1.VARIABLES.MusicExtension))
    BMRP_F1.VARIABLES.BackgroundMusic:SetDSP(BMRP_F1.CONST.DSP)
    if BMRP_F1.CONVARS.BackgroundMusic:GetBool() then
        BMRP_F1.VARIABLES.BackgroundMusic:Play()
    end
    -- footer bar
    BMRP_F1.DERMA.FooterBar = vgui.Create("DPanel")
    BMRP_F1.DERMA.FooterBar:SetSize(ScrW(), (BMRP_F1.CONST.FooterBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    BMRP_F1.DERMA.FooterBar:SetPos(0, ScrH())
    BMRP_F1.DERMA.FooterBar:MoveTo(0, ScrH() - (BMRP_F1.CONST.FooterBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.CONST.LerpSpeed, 0, 1)
    BMRP_F1.DERMA.FooterBar:SetBackgroundColor(ColorAlpha(BMRP_F1.COLOR.Black, 128))
    -- footer buttons (back, exit)
    local FooterButtonStart = (BMRP_F1.CONST.SelectedButtonOffset * BMRP_F1.CONVARS.UIScale:GetFloat())
    BMRP_F1.DERMA.FooterButtonExit, FooterButtonStart = CreateFooterButton(BMRP_F1.DERMA.FooterBar, FooterButtonStart, BMRP_F1.TEXT.ExitButton, function()
        -- modal pop-up
        if IsValid(BMRP_F1.DERMA.Modal) then
            BMRP_F1.DERMA.Modal:Remove()
        end
        BMRP_F1.DERMA.Modal = vgui.Create("DFrame")
        BMRP_F1.DERMA.Modal:SetSize(BMRP_F1.CONST.ModalWidth, BMRP_F1.CONST.ModalHeight)
        BMRP_F1.DERMA.Modal:SetPos((ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, (ScrH() - BMRP_F1.DERMA.Modal:GetTall()) / 2) --(ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, -BMRP_F1.DERMA.Modal:GetTall())
        BMRP_F1.DERMA.Modal:SetTitle("")
        BMRP_F1.DERMA.Modal:SetDraggable(true)
        BMRP_F1.DERMA.Modal:ShowCloseButton(false)
        BMRP_F1.DERMA.Modal:SetBackgroundBlur(true)
        BMRP_F1.DERMA.Modal:MakePopup()
        --BMRP_F1.DERMA.Modal:MoveTo((ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, (ScrH() - BMRP_F1.DERMA.Modal:GetTall()) / 2, BMRP_F1.CONST.LerpSpeed, 0, 1)
        BMRP_F1.DERMA.Modal.StartTime = SysTime()
        BMRP_F1.DERMA.Modal.Alpha = 0
        BMRP_F1.DERMA.Modal.FadeOut = false
        BMRP_F1.DERMA.Modal.Paint = function(self, w, h)
            -- title bar
            draw.RoundedBoxEx(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, BMRP_F1.CONST.ModalTitleHeight, ColorAlpha(BMRP_F1.COLOR.Black, self.Alpha), true, true, false, false)
            -- title text
            draw.SimpleText(string.upper(BMRP_F1.TEXT.ExitModalTitle), BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", w/2, BMRP_F1.CONST.ModalTitleHeight/2, ColorAlpha(BMRP_F1.COLOR.Highlight, self.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- body
            draw.RoundedBoxEx(BMRP_F1.CONST.ModalCornerSize, 0, BMRP_F1.CONST.ModalTitleHeight, w, h - BMRP_F1.CONST.ModalTitleHeight, ColorAlpha(BMRP_F1.COLOR.MainAccent, self.Alpha), false, false, true, true)
        end
        BMRP_F1.DERMA.Modal.Think = function(self)
            -- fade in with BMRP_F1.CONST.ModalFadeTime
            if self.FadeOut == false then
                if self.StartTime + BMRP_F1.CONST.ModalFadeTime > SysTime() then
                    self.Alpha = math.Clamp((SysTime() - self.StartTime) / BMRP_F1.CONST.ModalFadeTime, 0, 1) * 255
                end
            elseif self.FadeOut == true then
                if self.StartTime + BMRP_F1.CONST.ModalFadeTime > SysTime() then
                    self.Alpha = math.Clamp(1 - (SysTime() - self.StartTime) / BMRP_F1.CONST.ModalFadeTime, 0, 1) * 255
                else
                    self:Remove()
                end
            end
        end
        local description = vgui.Create("DLabel", BMRP_F1.DERMA.Modal)
        description:SetText(BMRP_F1.TEXT.ExitModalDescription)
        description:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        description:SetTextColor(BMRP_F1.COLOR.Highlight)
        description:SetPos(BMRP_F1.CONST.ModalWidth/2, BMRP_F1.CONST.ModalHeight/3)
        description:SizeToContents()
        description:CenterHorizontal()
        description.Think = function(self)
            self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha))
        end
        local yes = vgui.Create("DButton", BMRP_F1.DERMA.Modal)
        yes:SetText(BMRP_F1.TEXT.ExitModalYes)
        yes:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        yes:SetTextColor(BMRP_F1.COLOR.Highlight)
        yes:SetSize(BMRP_F1.CONST.ModalWidth/4, BMRP_F1.CONST.ModalHeight/6)
        yes:SetPos((BMRP_F1.CONST.ModalWidth/4)-(BMRP_F1.CONST.ModalButtonSpacing/2), BMRP_F1.CONST.ModalHeight/2)
        yes.DoClick = function()
            surface.PlaySound("ui/buttonclickrelease.wav")
            BMRP_F1.DERMA.Modal:Close()
            RunConsoleCommand("disconnect")
        end
        yes.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, BMRP_F1.DERMA.Modal.Alpha), 200)
        end
        yes.Think = function(self)
            self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha))
        end
        local no = vgui.Create("DButton", BMRP_F1.DERMA.Modal)
        no:SetText(BMRP_F1.TEXT.ExitModalNo)
        no:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
        no:SetTextColor(BMRP_F1.COLOR.Highlight)
        no:SetSize(BMRP_F1.CONST.ModalWidth/4, BMRP_F1.CONST.ModalHeight/6)
        no:SetPos((BMRP_F1.CONST.ModalWidth/4)*2+(BMRP_F1.CONST.ModalButtonSpacing/2), BMRP_F1.CONST.ModalHeight/2)
        no.DoClick = function()
            surface.PlaySound("ui/buttonclickrelease.wav")
            --BMRP_F1.DERMA.Modal:MoveTo((ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, ScrH(), BMRP_F1.CONST.LerpSpeed, 0, 1)
            -- fade out with BMRP_F1.CONST.ModalFadeTime
            BMRP_F1.DERMA.Modal.StartTime = SysTime()
            BMRP_F1.DERMA.Modal.FadeOut = true
        end
        no.Paint = function(self, w, h)
            draw.RoundedBox(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, BMRP_F1.DERMA.Modal.Alpha), 200)
        end
        no.Think = function(self)
            self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha))
        end
    end, false)
    BMRP_F1.DERMA.FooterButtonResume, FooterButtonStart = CreateFooterButton(BMRP_F1.DERMA.FooterBar, FooterButtonStart, mainmenu and BMRP_F1.TEXT.StartButton or BMRP_F1.TEXT.ResumeButton, function(self)
        if mainmenu and BMRP_F1.VARIABLES.NeedToSetRPName == true then
            -- modal pop-up
            if IsValid(BMRP_F1.DERMA.Modal) then
                BMRP_F1.DERMA.Modal:Remove()
            end
            BMRP_F1.DERMA.Modal = vgui.Create("DFrame")
            BMRP_F1.DERMA.Modal:SetSize(BMRP_F1.CONST.ModalWidth, BMRP_F1.CONST.ModalHeight)
            BMRP_F1.DERMA.Modal:SetPos((ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, (ScrH() - BMRP_F1.DERMA.Modal:GetTall()) / 2) --(ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, -BMRP_F1.DERMA.Modal:GetTall())
            BMRP_F1.DERMA.Modal:SetTitle("")
            BMRP_F1.DERMA.Modal:SetDraggable(true)
            BMRP_F1.DERMA.Modal:ShowCloseButton(false)
            BMRP_F1.DERMA.Modal:SetBackgroundBlur(true)
            BMRP_F1.DERMA.Modal:MakePopup()
            --BMRP_F1.DERMA.Modal:MoveTo((ScrW() - BMRP_F1.DERMA.Modal:GetWide()) / 2, (ScrH() - BMRP_F1.DERMA.Modal:GetTall()) / 2, BMRP_F1.CONST.LerpSpeed, 0, 1)
            BMRP_F1.DERMA.Modal.StartTime = SysTime()
            BMRP_F1.DERMA.Modal.Alpha = 0
            BMRP_F1.DERMA.Modal.FadeOut = false
            BMRP_F1.DERMA.Modal.Paint = function(self, w, h)
                -- title bar
                draw.RoundedBoxEx(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, BMRP_F1.CONST.ModalTitleHeight, ColorAlpha(BMRP_F1.COLOR.Black, self.Alpha), true, true, false, false)
                -- title text
                draw.SimpleText(string.upper(BMRP_F1.TEXT.RPNameModalTitle), BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall", w/2, BMRP_F1.CONST.ModalTitleHeight/2, ColorAlpha(BMRP_F1.COLOR.Highlight, self.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                -- body
                draw.RoundedBoxEx(BMRP_F1.CONST.ModalCornerSize, 0, BMRP_F1.CONST.ModalTitleHeight, w, h - BMRP_F1.CONST.ModalTitleHeight, ColorAlpha(BMRP_F1.COLOR.MainAccent, self.Alpha), false, false, true, true)
            end
            BMRP_F1.DERMA.Modal.Think = function(self)
                -- fade in with BMRP_F1.CONST.ModalFadeTime
                if self.FadeOut == false then
                    if self.StartTime + BMRP_F1.CONST.ModalFadeTime > SysTime() then
                        self.Alpha = math.Clamp((SysTime() - self.StartTime) / BMRP_F1.CONST.ModalFadeTime, 0, 1) * 255
                    end
                elseif self.FadeOut == true then
                    if self.StartTime + BMRP_F1.CONST.ModalFadeTime > SysTime() then
                        self.Alpha = math.Clamp(1 - (SysTime() - self.StartTime) / BMRP_F1.CONST.ModalFadeTime, 0, 1) * 255
                    else
                        self:Remove()
                    end
                end
            end
            local description = vgui.Create("DLabel", BMRP_F1.DERMA.Modal)
            description:SetText(BMRP_F1.TEXT.RPNameModalDescription)
            description:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
            description:SetTextColor(BMRP_F1.COLOR.Highlight)
            description:SetPos(BMRP_F1.CONST.ModalWidth/2, BMRP_F1.CONST.ModalHeight/4)
            description:SizeToContents()
            description:CenterHorizontal()
            description.Think = function(self)
                self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha))
            end
            local yes = vgui.Create("DButton", BMRP_F1.DERMA.Modal)
            yes:SetText(BMRP_F1.TEXT.RPNameModalButton)
            yes:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
            yes:SetTextColor(BMRP_F1.COLOR.Highlight)
            yes:SetSize(BMRP_F1.CONST.ModalWidth/4, BMRP_F1.CONST.ModalHeight/6)
            yes:SetPos(BMRP_F1.CONST.ModalWidth/2 - yes:GetWide()/2, BMRP_F1.CONST.ModalHeight/2 + BMRP_F1.CONST.ModalWidth/8)
            yes.Paint = function(self, w, h)
                draw.RoundedBox(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, BMRP_F1.DERMA.Modal.Alpha), 200)
            end
            yes.Think = function(self)
                self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha))
            end
            -- text entry
            local textEntry = vgui.Create("DTextEntry", BMRP_F1.DERMA.Modal)
            textEntry:SetSize(BMRP_F1.CONST.ModalWidth-BMRP_F1.CONST.ModalWidth/8, BMRP_F1.CONST.ModalHeight/6)
            textEntry:SetPos(BMRP_F1.CONST.ModalWidth/2 - textEntry:GetWide()/2, (BMRP_F1.CONST.ModalHeight/2 - textEntry:GetTall()/4))
            textEntry:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
            textEntry:SetTextColor(BMRP_F1.COLOR.Highlight)
            textEntry:SetText(BMRP_F1.VARIABLES.LocalPlayer:Nick())
            textEntry.OnEnter = function(self)
                if string.find(self:GetText(), " ") then
                    net.Start("BMRP_F1_SetRPName")
                    net.WriteString(self:GetText())
                    net.SendToServer()
                    BMRP_F1.DERMA.Modal.StartTime = SysTime()
                    BMRP_F1.DERMA.Modal.FadeOut = true
                else
                    -- must enter a first name and last name
                    yes:SetText(BMRP_F1.TEXT.RPNameModalButtonFail)
                    surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
                    local TEXT_X, TEXT_Y = surface.GetTextSize(BMRP_F1.TEXT.RPNameModalButtonFail)
                    yes:SetSize((BMRP_F1.CONST.ModalWidth/4) + TEXT_X/2, BMRP_F1.CONST.ModalHeight/6)
                    yes:SetPos(BMRP_F1.CONST.ModalWidth/2 - yes:GetWide()/2, BMRP_F1.CONST.ModalHeight/2 + BMRP_F1.CONST.ModalWidth/8)
                end
            end
            yes.DoClick = function()
                -- ditto
                textEntry:OnEnter()
            end
            textEntry:SetContentAlignment(5)
            textEntry.Paint = function(self, w, h)
                draw.RoundedBox(BMRP_F1.CONST.ModalCornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, BMRP_F1.DERMA.Modal.Alpha), 200)
                -- text
                draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2, ColorAlpha(BMRP_F1.COLOR.Highlight, BMRP_F1.DERMA.Modal.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            textEntry.Think = function(self)
                self:SetTextColor(ColorAlpha(BMRP_F1.COLOR.Black, BMRP_F1.DERMA.Modal.Alpha))
            end
        elseif mainmenu then
            net.Start("BMRP_F1_ExitMainMenu")
            net.SendToServer()
        else
            net.Start("BMRP_F1_ToggleMenuFromClient")
            net.SendToServer()
        end
    end, false)
    local oldfooterbuttonstart = FooterButtonStart
    BMRP_F1.DERMA.FooterButtonBack, FooterButtonStart = CreateFooterButton(BMRP_F1.DERMA.FooterBar, FooterButtonStart, BMRP_F1.TEXT.BackButton, function(self)
        local thismenu = BMRP_F1.VARIABLES.CurrentMenu
        ChangeMenu(BMRP_F1.VARIABLES.LastPage, false, mainmenu, staff)
        BMRP_F1.VARIABLES.LastPage = thismenu
    end, true)
    BMRP_F1.DERMA.FooterButtonLeaderboard, FooterButtonStart = CreateFooterButton(BMRP_F1.DERMA.FooterBar, FooterButtonStart, BMRP_F1.TEXT.LeaderboardButton, function(self)
        ChangeMenu(BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Leaderboard and BMRP_F1.ENUM.Menu.Achievements or BMRP_F1.ENUM.Menu.Leaderboard, false, mainmenu, staff)
    end, false, true)
    -- footer righthand text
    BMRP_F1.DERMA.FooterText = vgui.Create("DLabel", BMRP_F1.DERMA.FooterBar)
    BMRP_F1.DERMA.FooterText:SetText(string.upper(BMRP_F1.TEXT.FooterText))
    BMRP_F1.DERMA.FooterText:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    BMRP_F1.DERMA.FooterText:SetTextColor(BMRP_F1.COLOR.Highlight)
    surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    TEXT_X, TEXT_Y = surface.GetTextSize(string.upper(BMRP_F1.TEXT.FooterText))
    BMRP_F1.DERMA.FooterText:SetPos(BMRP_F1.DERMA.FooterBar:GetWide()-TEXT_X-(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.DERMA.FooterBar:GetTall()/2-TEXT_Y/2)
    BMRP_F1.DERMA.FooterText:SizeToContents()
    -- footer center text (access with f1)
    BMRP_F1.DERMA.FooterCenterText = vgui.Create("DLabel", BMRP_F1.DERMA.FooterBar)
    BMRP_F1.DERMA.FooterCenterText:SetText(string.upper(string.format(BMRP_F1.TEXT.FooterCenterText, mainmenu and "Main" or input.LookupBinding("gm_showhelp") or "F1", BMRP_F1.VARIABLES.CompletionProgress or 0)))
    BMRP_F1.DERMA.FooterCenterText:SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    BMRP_F1.DERMA.FooterCenterText:SetTextColor(BMRP_F1.COLOR.Highlight)
    surface.SetFont(BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall")
    TEXT_X, TEXT_Y = surface.GetTextSize(string.upper(string.format(BMRP_F1.TEXT.FooterCenterText, mainmenu and "Main" or input.LookupBinding("gm_showhelp") or "F1", BMRP_F1.VARIABLES.CompletionProgress or 0)))
    BMRP_F1.DERMA.FooterCenterText:SetPos(BMRP_F1.DERMA.FooterBar:GetWide()/2-TEXT_X/2, BMRP_F1.DERMA.FooterBar:GetTall()/2-TEXT_Y/2)
    BMRP_F1.DERMA.FooterCenterText:SizeToContents()
    BMRP_F1.DERMA.FooterCenterText.Think = function(self)
        TEXT_X = surface.GetTextSize(string.upper(string.format(BMRP_F1.TEXT.FooterCenterText, mainmenu and "Main" or input.LookupBinding("gm_showhelp") or "F1", BMRP_F1.VARIABLES.CompletionProgress or 0)))
        self:SetText(string.upper(string.format(BMRP_F1.TEXT.FooterCenterText, mainmenu and "Main" or input.LookupBinding("gm_showhelp") or "F1", BMRP_F1.VARIABLES.CompletionProgress or 0)))
        self:SetPos(BMRP_F1.DERMA.FooterBar:GetWide()/2-TEXT_X/2, BMRP_F1.DERMA.FooterBar:GetTall()/2-TEXT_Y/2)
        self:SizeToContents()
    end
    -- contents (center, changes depending on BMRP_F1.VARIABLES.CurrentMenu)
    BMRP_F1.DERMA.Contents = vgui.Create("DPanel")
    BMRP_F1.DERMA.Contents:SetKeyboardInputEnabled(true)
    BMRP_F1.DERMA.Contents:SetMouseInputEnabled(true)
    BMRP_F1.DERMA.Contents:SetSize(ScrW(), ScrH() - (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()) - (BMRP_F1.CONST.FooterBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    BMRP_F1.DERMA.Contents:SetPos(-ScrW(), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()))
    BMRP_F1.DERMA.Contents:MoveTo(0, (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.CONST.LerpSpeed, 0, 1)
    BMRP_F1.DERMA.Contents:SetBackgroundColor(BMRP_F1.COLOR.Clear)
    ChangeMenu(BMRP_F1.VARIABLES.CurrentMenu, false, mainmenu, staff)
end

function BMRP_F1_HideMenu()
    if not BMRP_F1.VARIABLES.MenuOpen then return end
    if not BMRP_F1.VARIABLES.BlurOpen then return end
    if BMRP_F1.VARIABLES.BackgroundMusic then
        if BMRP_F1.VARIABLES.BackgroundMusic:IsPlaying() and BMRP_F1.CONVARS.BackgroundMusic:GetBool() then
            BMRP_F1.VARIABLES.BackgroundMusic:FadeOut(BMRP_F1.CONST.FadeTime)
        else
            BMRP_F1.VARIABLES.BackgroundMusic:Stop()
        end
    end
    if IsValid(BMRP_F1.VARIABLES.Attachment) then
        BMRP_F1.VARIABLES.Attachment:Remove()
    end
    BMRP_F1.VARIABLES.Closing = true
    BMRP_F1.VARIABLES.MenuOpen = false
    timer.Remove("BMRP_F1_Delete")
    gui.EnableScreenClicker(false)
    BMRP_F1.VARIABLES.MouseX, BMRP_F1.VARIABLES.MouseY = input.GetCursorPos()
    BMRP_F1.VARIABLES.BlurOpen = false
    BMRP_F1.VARIABLES.BlurStart = CurTime()
    if IsValid(BMRP_F1.DERMA.HeaderBar) then
        BMRP_F1.DERMA.HeaderBar:Stop()
        BMRP_F1.DERMA.HeaderBar:MoveTo(0, -(BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.CONST.LerpSpeed, 0, 1)
    end
    if IsValid(BMRP_F1.DERMA.FooterBar) then
        BMRP_F1.DERMA.FooterBar:Stop()
        BMRP_F1.DERMA.FooterBar:MoveTo(0, ScrH(), BMRP_F1.CONST.LerpSpeed, 0, 1)
    end
    if IsValid(BMRP_F1.DERMA.Contents) then
        BMRP_F1.DERMA.Contents:Stop()
        BMRP_F1.DERMA.Contents:MoveTo(ScrW(), (BMRP_F1.CONST.HeaderBarHeight * BMRP_F1.CONVARS.UIScale:GetFloat()), BMRP_F1.CONST.LerpSpeed, 0, 1)
    end
    -- remove all panels
    timer.Create("BMRP_F1_Delete", BMRP_F1.VARIABLES.Fraction, 1, function()
        for k, v in pairs(BMRP_F1.DERMA) do
            if type(v) == "Panel" and IsValid(v) then
                v:Remove()
            end
        end
        BMRP_F1.VARIABLES.BackgroundMusic:Stop()
        BMRP_F1.VARIABLES.BackgroundMusic = nil
        BMRP_F1.VARIABLES.Closing = false
    end)
end

function BMRP_F1_ToggleMenu(mainmenu, staff)
    if BMRP_F1.VARIABLES.MenuOpen then
        BMRP_F1_HideMenu()
    else
        BMRP_F1_ShowMenu(mainmenu, staff)
    end
end

net.Receive("BMRP_F1_ToggleMenu", function()
    local networkedbool = net.ReadBool() or nil
    local mainmenu = net.ReadBool() or false
    local staff = net.ReadBool() or false
    if networkedbool == true then
        BMRP_F1_ShowMenu(mainmenu, staff)
    elseif networkedbool == false then
        BMRP_F1_HideMenu()
    else
        BMRP_F1_ToggleMenu(mainmenu, staff)
    end
end)

net.Receive("BMRP_F1_YouCanUsePac3", function()
    BMRP_F1.VARIABLES.CanUsePac3 = net.ReadBool()
end)

net.Receive("BMRP_F1_YouNeedToSetRPName", function()
    BMRP_F1.VARIABLES.NeedToSetRPName = true
end)

net.Receive("BMRP_F1_YouAlreadyVoted", function()
    BMRP_F1.VARIABLES.AlreadyVoted = true
end)

hook.Add("InitPostEntity", "BMRP_F1_Init", function()
    net.Start("BMRP_F1_ViewMainMenu")
    net.SendToServer()
end)

concommand.Add("bmrp_f1_mainmenu", function()
    net.Start("BMRP_F1_ViewMainMenu")
    net.SendToServer()
end)

-- achievements
net.Receive("KIWI_ACHIEVEMENTS_GetAchievementProgress_Response", function()
    if not BMRP_F1.VARIABLES.MenuOpen then return end
    local count = net.ReadUInt(32)
    local completedachievements = 0
    for i = 1, count do
        local key = net.ReadString()
        local achievement = KIWI_ACHIEVEMENTS.ACHIEVEMENTS[key]
        -- make progress from 0 to 1 depending on achievement.Amount
        local progress = net.ReadUInt(32) / (achievement or {Amount = 1}).Amount
        if progress >= 1 then
            completedachievements = completedachievements + 1
        end
        local players = net.ReadUInt(32)
        local playersworking = net.ReadUInt(32)
        if not achievement then continue end
        local x = 0 --BMRP_F1.CONST.AchievementPadding
        local y = 0 --BMRP_F1.CONST.AchievementPadding
        local w = BMRP_F1.CONST.AchievementWidth
        local h = BMRP_F1.CONST.AchievementHeight
        if BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Achievements then
            x, y = ConstructAchievement(BMRP_F1.DERMA.AchievementsMenu_Display_List, x, y, w, h, achievement, key, progress, players, playersworking, false)
        elseif BMRP_F1.VARIABLES.CurrentMenu == BMRP_F1.ENUM.Menu.Leaderboard then
            x, y = ConstructAchievement(BMRP_F1.DERMA.LeaderboardMenu_Display_List, x, y, w, h, achievement, key, progress, players, playersworking, true)
        end
    end
    -- out of 100 (percentage)
    BMRP_F1.VARIABLES.CompletionProgress = (completedachievements / count) * 100
end)

net.Receive("BMRP_F1_ShowVoteMenu", function()
    -- seperate namespace
    local background = vgui.Create("DPanel")
    background:SetSize(ScrW(), ScrH())
    background:SetPos(0, 0)
    background.Paint = function(self, w, h)
        surface.SetDrawColor(ColorAlpha(BMRP_F1.COLOR.Black, 200))
        surface.DrawRect(0, 0, w, h)
    end
    gui.EnableScreenClicker(true)
    -- add seperate vote buttons for each vote option in BMRP_F1.VOTE.VoteOptions
    local x = ScrW() / 2 - (384)
    local y = ScrH() / 2 - (256)
    local w = 384
    local h = 512
    local subpanel = vgui.Create("DPanel", background)
    subpanel:SetSize(w*2+16, h+16)
    subpanel:SetPos(x-8, y-8)
    subpanel.Paint = function(self, w, h)
        draw.RoundedBox(BMRP_F1.CONST.CornerSize, 0, 0, w, h, ColorAlpha(BMRP_F1.COLOR.Black, 200))
    end
    local rollovertextdef = {
        "Select a vote option to vote for.",
        "Voting will conclude by the end of this week.",
        "You can only vote once.",
    }
    local rollovertext1 = table.Copy(rollovertextdef)
    local selecting = 0
    for k, v in pairs(BMRP_F1.VOTE.VoteOptions) do
        local button = vgui.Create("DButton", background)
        button:SetSize(w, h)
        button:SetPos(x, y)
        button:SetText("")
        button.DoClick = function()
            net.Start("BMRP_F1_VoteOnWar")
            net.WriteString(v.Vote)
            net.SendToServer()
            background:Remove()
            gui.EnableScreenClicker(false)
            surface.PlaySound("ui/buttonclick.wav")
        end
        button.Paint = function(self, w, h)
            //draw.RoundedBoxEx(BMRP_F1.CONST.CornerSize, 0, 0, w, h, v.Color, (k == 1 and true or k == 2 and false), (k == 1 and false or k == 2 and true), (k == 1 and true or k == 2 and false),  (k == 1 and false or k == 2 and true))
            //draw.SimpleText(v.Name, (BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"), w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local img = v.Image
            surface.SetDrawColor(ColorAlpha(BMRP_F1.COLOR.Highlight, selecting == k and 128 or 255))
            surface.SetMaterial(img)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        // button rollover
        button.OnCursorEntered = function()
            surface.PlaySound("ui/buttonrollover.wav")
            rollovertext1[1] = v.Description
            rollovertext1[2] = v.UpdateDescription
            rollovertext1[3] = v.Desc3
            selecting = k
        end
        button.OnCursorExited = function()
            rollovertext1 = table.Copy(rollovertextdef)
            selecting = 0
        end
        x = x + w
    end
    local description = vgui.Create("DLabel", background)
    description:SetText(BMRP_F1.VOTE.VoteDescription)
    description:SetFont((BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"))
    description:SizeToContents()
    description:SetTextColor(BMRP_F1.COLOR.Highlight)
    description:SetPos(ScrW() / 2 - (description:GetWide() / 2), y - BMRP_F1.CONST.AchievementPadding - description:GetTall())
    local title = vgui.Create("DLabel", background)
    title:SetText(BMRP_F1.VOTE.VoteName)
    title:SetFont((BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"))
    title:SetTextColor(BMRP_F1.COLOR.Highlight)
    title:SizeToContents()
    title:SetPos(ScrW() / 2 - (title:GetWide() / 2), y - title:GetTall() - BMRP_F1.CONST.AchievementPadding - description:GetTall() - BMRP_F1.CONST.AchievementPadding)
    local rollovertext = vgui.Create("DLabel", background)
    rollovertext:SetText(rollovertext1[1])
    rollovertext:SetFont((BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"))
    rollovertext:SetTextColor(BMRP_F1.COLOR.Highlight)
    rollovertext.Think = function(self)
        self:SetText(rollovertext1[1])
        self:SizeToContents()
        self:SetPos(ScrW() / 2 - (self:GetWide() / 2), y + h + BMRP_F1.CONST.AchievementPadding)
    end
    local rollovertext2 = vgui.Create("DLabel", background)
    rollovertext2:SetText(rollovertext1[2])
    rollovertext2:SetFont((BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"))
    rollovertext2:SetTextColor(BMRP_F1.COLOR.Highlight)
    rollovertext2.Think = function(self)
        self:SetText(rollovertext1[2])
        self:SizeToContents()
        self:SetPos(ScrW() / 2 - (self:GetWide() / 2), y + h + BMRP_F1.CONST.AchievementPadding + self:GetTall() + BMRP_F1.CONST.AchievementPadding)
    end
    local rollovertext3 = vgui.Create("DLabel", background)
    rollovertext3:SetText(rollovertext1[3])
    rollovertext3:SetFont((BMRP_F1.CONVARS.UIScale:GetFloat() >= 1 and "BMRP_F1_Font_Main" or "BMRP_F1_Font_MainReallySmall"))
    rollovertext3:SetTextColor(BMRP_F1.COLOR.Highlight)
    rollovertext3.Think = function(self)
        self:SetText(rollovertext1[3])
        self:SizeToContents()
        self:SetPos(ScrW() / 2 - (self:GetWide() / 2), y + h + BMRP_F1.CONST.AchievementPadding + self:GetTall() + BMRP_F1.CONST.AchievementPadding + self:GetTall() + BMRP_F1.CONST.AchievementPadding)
    end
end)
