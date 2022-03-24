/*
    Wildfire Servers - BMRP F1 Menu
    File Description: F1 Menu Config
    Creation Date: 11/8/2021
    Copyright (C) 2022 KiwifruitDev
    Licensed under the MIT License.
    Created by: KiwifruitDev
*/

-- Create the BMRP_F1 configuration table
BMRP_F1 = BMRP_F1 or {}

print("BMRP_F1: Loading F1 Menu Config")

-- Let's define some constants
BMRP_F1.CONST = {}
BMRP_F1.CONST.Version = 1 -- Updating this will force the client to write new data via SQL
BMRP_F1.CONST.BlurTime = 1 -- The time it takes to blur the screen
BMRP_F1.CONST.LerpSpeed = 0.1 -- The speed at which the menu will lerp to the new position
BMRP_F1.CONST.HeaderBarHeight = 64 -- The height of the header bar
BMRP_F1.CONST.FooterBarHeight = 64 -- The height of the footer bar
BMRP_F1.CONST.ButtonSizeOffset = 64 -- How much extra space to add to the button size
BMRP_F1.CONST.SelectedButtonOffset = 8 -- How much of an indicator to show for the selected button
BMRP_F1.CONST.ButtonAlpha = 64 -- Alpha of selected button
BMRP_F1.CONST.FadeTime = 0.8 -- How long it takes to fade out music
BMRP_F1.CONST.TrianglePiece = 128 -- The size of the triangle piece
BMRP_F1.CONST.ModalWidth = 384 -- The width of a modal
BMRP_F1.CONST.ModalHeight = 192 -- The height of a modal
BMRP_F1.CONST.ModalTitleHeight = 24 -- The height of the title bar
BMRP_F1.CONST.ModalButtonSpacing = 8 -- The spacing between buttons
BMRP_F1.CONST.ModalCornerSize = 8 -- The size of the corner
BMRP_F1.CONST.FadeInTime = 0.1 -- How long it takes to fade in elements when switching menus
BMRP_F1.CONST.DSP = 1 -- The DSP to use for the background music and the player's environment
BMRP_F1.CONST.UpdateImageSpacing = 64 -- The spacing between the update image and the header/footer
BMRP_F1.CONST.UpdateImageWidth = 512 -- The width of the update image
BMRP_F1.CONST.UpdateImageHeight = 768 -- The height of the update image
BMRP_F1.CONST.CornerSize = 8 -- The size of the corner
BMRP_F1.CONST.ButtonPadding = 8 -- The padding between the button and the text
BMRP_F1.CONST.ButtonSize = 24 -- The size of the button
BMRP_F1.CONST.CategoryOffset = 4 -- The offset between the category
BMRP_F1.CONST.ModalFadeTime = 0.15 -- How long it takes to fade in modals
BMRP_F1.CONST.MinScreenHeight = 1080 -- The minimum height of the screen
BMRP_F1.CONST.AchievementWidth = 384 -- The width of the achievement
BMRP_F1.CONST.AchievementHeight = 128 -- The height of the achievement
BMRP_F1.CONST.AchievementPadding = 8 -- The padding between the achievement and the text
BMRP_F1.CONST.HL1MusicAllowed = false -- Whether or not HL1 music is allowed

BMRP_F1.VOTE = {}
BMRP_F1.VOTE.VoteActive = false -- Whether or not a war vote is taking place
BMRP_F1.VOTE.VoteName = "Code Black"
BMRP_F1.VOTE.VoteDescription = "Vote for who gets the next major update in-game!"
BMRP_F1.VOTE.VoteInternalName = "codeblack"
BMRP_F1.VOTE.VoteOptions = {
    {
        Name = "The Brains",
        Description = "Vote for the scientists to recieve a major update in their research first.",
        UpdateDescription = "Scientists will recieve a DNA sequencing system and a disease system alongside a total revamp of the resonance cascade event.",
        Desc3 = "Utilize blood to create a cure for a Xen-rampant disease!",
        Vote = "brains",
        Color = Color(255, 128, 0),
        Image = Material("wildfire/ui/vote/brains.png"),
    },
    {
        Name = "The Brawn",
        Description = "Vote for the H.E.C.U. to recieve a major update in their arsenal first.",
        UpdateDescription = "The H.E.C.U. will recieve a weaponized upgrade system and the ability to bruteforce your way through the facility with enough power.",
        Desc3 = "Level up by living as long as possible per-life!",
        Vote = "brawn",
        Color = Color(0, 128, 0),
        Image = Material("wildfire/ui/vote/brawn.png"),
    },
}

BMRP_F1.MATERIAL = {}
BMRP_F1.MATERIAL.Blur = Material( "pp/blurscreen" )
BMRP_F1.MATERIAL.Icon = Material( "atlaschat/customemoticons/bms_white.png" )
BMRP_F1.MATERIAL.Triangle = Material( "wildfire/ui/triangle.png" )

-- Enumerables
BMRP_F1.ENUM = {}
BMRP_F1.ENUM.Menu = {}
BMRP_F1.ENUM.Menu.None = 0 -- No menu
BMRP_F1.ENUM.Menu.Main = 1 -- The main menu
BMRP_F1.ENUM.Menu.Character = 2 -- The character menu
BMRP_F1.ENUM.Menu.Settings = 3 -- The achievements menu
BMRP_F1.ENUM.Menu.Achievements = 4 -- The achievements menu
BMRP_F1.ENUM.Menu.Staff = 5 -- The staff menu
BMRP_F1.ENUM.Menu.Pause = 6 -- The pause menu
BMRP_F1.ENUM.Menu.Rules = 7 -- The pause menu
BMRP_F1.ENUM.Menu.Leaderboard = 8 -- The leaderboard menu

BMRP_F1.TEXT = {}
BMRP_F1.TEXT.Title = "Wildfire Black Mesa RP"
BMRP_F1.TEXT.Subtitle = "Comments? Suggestions? Bugs? Contact us on Discord!"
BMRP_F1.TEXT.FooterText = "Icons by clankeroni#3572 — Copyright (C) 2022 KiwifruitDev "
BMRP_F1.TEXT.FooterCenterText = "— %s Menu (%u%% Completion) —"
BMRP_F1.TEXT.MainMenu = "Welcome"
BMRP_F1.TEXT.CharacterMenu = "Character"
BMRP_F1.TEXT.SettingsMenu = "Settings"
BMRP_F1.TEXT.AchievementsMenu = "Achievements"
BMRP_F1.TEXT.RulesMenu = "Rules"
BMRP_F1.TEXT.StaffMenu = "Staff"
BMRP_F1.TEXT.DiscordMenu = "Discord"
BMRP_F1.TEXT.DonateMenu = "Donate"
BMRP_F1.TEXT.PauseMenu = "Welcome"
BMRP_F1.TEXT.BackButton = "Back"
BMRP_F1.TEXT.ExitButton = "Disconnect"
BMRP_F1.TEXT.ResumeButton = "Resume"
BMRP_F1.TEXT.StartButton = "Play"
BMRP_F1.TEXT.RulesButton = "Rules"
BMRP_F1.TEXT.ExitModalTitle = "Disconnect"
BMRP_F1.TEXT.ExitModalDescription = "Are you sure you want to disconnect?"
BMRP_F1.TEXT.ExitModalYes = "Yes"
BMRP_F1.TEXT.ExitModalNo = "No"
BMRP_F1.TEXT.RPNameModalTitle = "RP Name"
BMRP_F1.TEXT.RPNameModalDescription = "Enter your RP name:"
BMRP_F1.TEXT.RPNameModalButton = "Play"
BMRP_F1.TEXT.MainMenuTitle = "Welcome to Wildfire Black Mesa RP!"
BMRP_F1.TEXT.Welcome = "Welcome to the server and happy holidays, %s! There are %u players online and it is currently %s."
BMRP_F1.TEXT.WelcomeNonPlural = "Welcome to the server and happy holidays, %s! There is %u player online and it is currently %s."
BMRP_F1.TEXT.CharacterTitle = "Character Customization"
BMRP_F1.TEXT.CategoryCharacter = "Model"
BMRP_F1.TEXT.LabelButtonCharacter = "Skins"
BMRP_F1.TEXT.LabelButtonPac3 = "PAC3"
BMRP_F1.TEXT.ButtonPac3 = "Open PAC3 Menu"
BMRP_F1.TEXT.ButtonCantUsePac3 = "Apply in our Discord!"
BMRP_F1.TEXT.CategoryBodygroups = "Bodygroups"
BMRP_F1.TEXT.CharacterSubtitle = "Customize your character's appearance by changing their skin and bodygroups."
BMRP_F1.TEXT.RulesTitle = "Server Rules"
BMRP_F1.TEXT.RulesSubtitle = "Please read the rules before playing."
BMRP_F1.TEXT.AchievementsTitle = "Achievements"
BMRP_F1.TEXT.AchievementsSubtitle = "Achievements are earned by completing tasks on the server."
BMRP_F1.TEXT.SettingsTitle = "Settings"
BMRP_F1.TEXT.SettingsSubtitle = "Configure different aspects of the server and your game."
BMRP_F1.TEXT.StaffTitle = "Staff Menu"
BMRP_F1.TEXT.StaffSubtitle = "Quick actions for staff are available here."
BMRP_F1.TEXT.CategoryGeneralSettings = "General"
BMRP_F1.TEXT.LabelButtonEngineMenu = "Garry's Mod Settings"
BMRP_F1.TEXT.ButtonEngineMenu = "Open settings window"
BMRP_F1.TEXT.CategoryMenuSettings = "Menu"
BMRP_F1.TEXT.LabelButton24HourClock = "24 Hour Clock"
BMRP_F1.TEXT.LabelButtonBackgroundMusic = "Background Music"
BMRP_F1.TEXT.RPNameModalButtonFail = "Enter a last name please!"
BMRP_F1.TEXT.LabelButtonHideLinks = "Hide Link Buttons"
BMRP_F1.TEXT.LabelButtonHideStaff = "Hide Staff Menu (Disabled)"
BMRP_F1.TEXT.LeaderboardButton = "Leaderboard"
BMRP_F1.TEXT.LeaderboardSubtitle = "View the player-based leaderboard."
BMRP_F1.TEXT.LeaderboardPlayersEarned = "players have earned."
BMRP_F1.TEXT.LeaderboardPlayersEarnedNonPlural = "player has earned."
BMRP_F1.TEXT.LeaderboardPlayersWorking = "players are progressing."
BMRP_F1.TEXT.LeaderboardPlayersWorkingNonPlural = "player is progressing."

BMRP_F1.UPDATE = {}
BMRP_F1.UPDATE.Name = "The War Effort Update"
BMRP_F1.UPDATE.Description = [[The Brains have won the war with an 85:54 vote ratio. This means that the scientists will be receiving their very own dedicated update.
The Questionable Ethics update is soon to come as part of the vote that had taken place prior.

Background music is Things Done Changed (Anomalous Based Materials Vol IV) by Radiation Hazard.
Vote banners created by Skywrooth#4328.

Our current changelog is as follows:
- The player vote from the previous update is no longer active.
- The achievement progress in the F1 / Main Menu now updates in real time.
- Development has begun on the Questionable Ethics update.
- The F1 / Main Menu music has changed from Memories to Things Done Changed. (Both were composed by Radiation Hazard and are a part of Anomalous Based Materials Vol IV.)
Patch notes as of 12/11/2021:
- There is now a /authorize command for the facility administrator, it is currently for roleplay only.
- There are now /mute and /unmute commands that locally mutes or unmutes a player during your session.
- Anyone can now speak in Xen without being automatically muted. Intercom users can not be heard here, however.
- Spawn points should now be fixed on behalf of Lightning#2387.
- Vortigaunts have a new swep.
This completes this changelog, for more information please visit our Discord server.
]]


-- Colors
BMRP_F1.COLOR = {}
BMRP_F1.COLOR.MainAccent = Color(0, 127, 0, 255) --Color(228, 113, 37, 255) -- The main accent color
BMRP_F1.COLOR.MainAccentDark = Color(180, 92, 35, 255) -- The main accent dark color
BMRP_F1.COLOR.Highlight = Color(255, 255, 255, 255) -- The highlight color
BMRP_F1.COLOR.Black = Color(0, 0, 0, 255) -- The black color
BMRP_F1.COLOR.Clear = Color(0, 0, 0, 0) -- The clear color

BMRP_F1.IMAGE = {}
BMRP_F1.IMAGE.Update = "wildfire/ui/update_512x768.png"
BMRP_F1.IMAGE.Icon = "atlaschat/customemoticons/bms_white.png"

BMRP_F1.MUSIC = {
    "wildfire/f1menu/things_done_changed.mp3",
    /*
    "music/hl1_song3.mp3",
    "music/hl1_song5.mp3",
    "music/hl1_song6.mp3",
    "music/hl1_song9.mp3",
    "music/hl1_song10.mp3",
    "music/hl1_song11.mp3",
    "music/hl1_song14.mp3",
    "music/hl1_song15.mp3",
    "music/hl1_song17.mp3",
    "music/hl1_song19.mp3",
    "music/hl1_song20.mp3",
    //"music/hl1_song21.mp3",
    "music/hl1_song24.mp3",
    "music/hl1_song26.mp3",
    */
}

BMRP_F1.URL = {}
BMRP_F1.URL.Rules = "https://wildfireservers.github.io/#/articles/rules"
BMRP_F1.URL.Discord = "https://discord.gg/5gX3rdymxx"
BMRP_F1.URL.Donate = "https://wildfireservers.github.io/#/articles/donate"
