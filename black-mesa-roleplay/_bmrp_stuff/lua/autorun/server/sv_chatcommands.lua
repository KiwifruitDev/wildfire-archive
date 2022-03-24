// Wildfire Black Mesa Roleplay
// File description: BMRP chat commands script
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

// This is a giant timer which activates after DarkRP is loaded. I suggest you constnatly keep it 5 seconds.
local secondsTill = 5
timer.Simple( secondsTill, function()
    DarkRP.addPhrase('en', 'announce', '[Announcement]')
    DarkRP.removeChatCommand("advert")
    // Remove from DarkRP
     local function PlayerAdvertise(ply, args)
        if args == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        local DoSay = function(text)
            if text == "" then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
                return
            end
            for k,v in pairs(player.GetAll()) do
                local col = team.GetColor(ply:Team())
                DarkRP.talkToPerson(v, col, DarkRP.getPhrase("announce") .. " " .. ply:Nick(), Color(255, 255, 0, 255), text, ply)
            end
        end
        return args, DoSay
    end
    // LOOC BELOW THIS LINE
    local function LOOC(ply, args)
        if args == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end

        local DoSay = function(text)
            if text == "" then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
                return ""
            end
                DarkRP.talkToRange(ply, "(LOOC) " .. ply:Nick(), text, 250)
        end
        return args, DoSay
    end
    // WHO & IT
    local function it(ply, args)
        if args == "" or args:find("rolls a") then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        local DoSay = function(text)
            if text == "" then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
                return ""
            end
            DarkRP.talkToRange(ply, text, "", 250)
        end
        return args, DoSay
    end
    // ROLL
    local function Roll(ply, args)
        DarkRP.talkToRange(ply, ply:GetName() .. "'s dice lands on " .. math.random(100) .. ".", "", 250)
        return args, DoSay
    end
    // EXTRA ME & WHISPER COMMANDS BELOW
    local function MeWhisper(ply, args)
        if args == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
            return ""
        end
    
        local DoSay = function(text)
            if text == "" then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
                return ""
            end
            DarkRP.talkToRange(ply, "(quietly) " .. ply:Nick() .. " " .. text, "", 90)
        end
        return args, DoSay
    end
    // ME BUT YELL DISTANCE
    local function MeYell(ply, args)
        if args == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
            return ""
        end
    
        local DoSay = function(text)
            if text == "" then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
                return ""
            end
            DarkRP.talkToRange(ply, "(loudly) " .. ply:Nick() .. " " .. text, "", 90)
        end
        return args, DoSay
    end
    // HECU COMMAND
    local function HECUCall(ply, args)
        if not IsValid(ply) then return end
        if not ply:isMayor() then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "hecu"))
            return
        end
        if GetGlobalBool("ResonanceCascade", false) == false then
            DarkRP.notify(ply, 1, 4, "The H.E.C.U can only be called in during a resonance cascade!")
            return
        end
        if GetGlobalBool("hecuallowed", false) then
            DarkRP.notify(ply, 1, 4, "The H.E.C.U is already approved for entry.")
            return
        end
        for k,v in pairs( player.GetAll() ) do
            hook.Run("SystemMessage", v, "", "The Hazardous Environment Combat Unit (H.E.C.U) has been approved for facility entry.")
        end
        for k2,v2 in pairs( player.GetAll() ) do
            v2:SendLua("surface.PlaySound(\"voxswitch.wav\")")
        end
        SetGlobalBool("hecuallowed", true)
        return ""
    end
    local authvoxtable = {
        {0, "facility"},
        {0.88, "administration"},
        {2.12, "has"},
        {2.71, "authorized"},
        {3.75, "this"},
        {4.21, "exchange"},
        {5.15, "_comma"},
        {5.4, "please"},
        {6.05, "acknowledge"},
        {6.97, "dadeda"},
    }
    local authvoxtable_military = {
        {0, "facility"},
        {1.25, "announcement"},
        {2.5, "this"},
        {2.25, "activity"},
        {4.5, "is"},
        {5.25, "authorized"},
        {6.5, "dadeda"},
    }
    // AUTHORIZE COMMAND
    local function Authorize(ply, args)
        if not IsValid(ply) then return end
        if not ply:isMayor() then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "authorize"))
            return
        end
        for k,v in pairs( player.GetAll() ) do
            hook.Run("SystemMessage", v, "", "The facility administrator has authorized any previous action.")
        end
        hook.Run("RunVoxTable", GetGlobalBool("hecuallowed", false) and authvoxtable_military or authvoxtable, "vox")
        return ""
    end
    // CLOSE & OPEN BLASTDOORS
    local function AdministratorCloseBlastdoors(ply, args)
        if ply:isMayor() then
            DarkRP.notify(ply, 0, 4, "We're attemping to close the blast doors.")
            closeblastdoors()
        else
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "closeblastdoors"))
        end
        return ""
    end
    local function AdministratorOpenBlastdoors(ply, args)
        if ply:isMayor() then
            DarkRP.notify(ply, 0, 4, "We're attemping to open the blast doors.")
            openblastdoors()
        else
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "openblastdoors"))
        end
        return ""
    end
    // SHOWID COMMAND
    local function ShowID(ply, args)
        local jobtable = ply:getJobTable()
        if not jobtable.clearance then jobtable.clearance = 0 end
        local str = "shows their identification. It reads: "..ply:Nick()..", Affiliation: "..ply:getDarkRPVar("job")..", Clearance Level: "..jobtable.clearance, GAMEMODE.Config.meDistance
        DarkRP.talkToRange(ply, ply:Nick().." "..str, "", GAMEMODE.Config.talkDistance)
        local idhook = {}
        for k, v in pairs(ents.FindInSphere(ply:GetPos(), GAMEMODE.Config.talkDistance)) do
            if not IsValid(v) then continue end
            if v:IsPlayer() then
                table.insert(idhook, v)
            end
        end
        if #idhook > 1 then
            print("horks")
            hook.Run("ShowID", idhook)
        end
        return ""
    end
    // MUTE COMMAND
    local function Mute(ply, args)
        local muteplayer = DarkRP.findPlayer(args)
        if not muteplayer then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args))
            return ""
        end
        ply:MutePlayer(muteplayer)
        DarkRP.notify(ply, 0, 4, "You have muted "..muteplayer:Nick().." locally.")
        return ""
    end
    // UNMUTE COMMAND
    local function UnMute(ply, args)
        local unmuteplayer = DarkRP.findPlayer(args)
        if not unmuteplayer then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args))
            return ""
        end
        ply:UnMutePlayer(unmuteplayer)
        DarkRP.notify(ply, 0, 4, "You have unmuted "..unmuteplayer:Nick().." locally.")
        return ""
    end
    // Declare the chat commands...
    DarkRP.declareChatCommand{
        command = "announce",
        description = "Announce something to everyone in the server.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "a",
        description = "Announce something to everyone in the server.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "looc",
        description = "Similar to OOC (out-of-character) but locally to your peers.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "/.",
        description = "Similar to OOC (out-of-character) but locally to your peers.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "it",
        description = "Chat roleplay to say you're doing things that you can't show otherwise.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "who",
        description = "Chat roleplay to say you're doing things that you can't show otherwise.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "roll",
        description = "Rolls a number between 1 and 100.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "rtd",
        description = "Rolls a number between 1 and 100.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "mec",
        description = "Chat roleplay to say you're doing things that you can't show otherwise.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "mel",
        description = "Chat roleplay to say you're doing things that you can't show otherwise.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "hecu",
        description = "Facility Administrator uses this to call in the H.E.C.U.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "authorize",
        description = "Facility Administrator uses this to authorize any previous action.",
        delay = 30
    }
    DarkRP.declareChatCommand{
        command = "showid",
        description = "In roleplay, makes the player show their identification.s",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "closeblastdoors",
        description = "Administrator uses this to close the facility blast doors.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "openblastdoors",
        description = "Administrator uses this to open the facility blast doors.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "id",
        description = "In roleplay, makes the player show their identification.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "mute",
        description = "Mutes a player locally.",
        delay = 1.5
    }
    DarkRP.declareChatCommand{
        command = "unmute",
        description = "Unmutes a player locally.",
        delay = 1.5
    }
    // define all that
    if SERVER then
        DarkRP.defineChatCommand("announce", PlayerAdvertise, 1.5)
        DarkRP.defineChatCommand("a", PlayerAdvertise, 1.5)
        DarkRP.defineChatCommand("looc", LOOC, 1.5)
        DarkRP.defineChatCommand("/.", LOOC, 1.5)
        DarkRP.defineChatCommand("it", it, 1.5)
        DarkRP.defineChatCommand("who", it, 1.5)
        DarkRP.defineChatCommand("roll", Roll, 1.5)
        DarkRP.defineChatCommand("rtd", Roll, 1.5)
        DarkRP.defineChatCommand("mec", MeWhisper, 1.5)
        DarkRP.defineChatCommand("mel", MeYell, 1.5)
        DarkRP.defineChatCommand("hecu", HECUCall, 1.5)
        DarkRP.defineChatCommand("authorize", Authorize, 30)
        DarkRP.defineChatCommand("closeblastdoors", AdministratorCloseBlastdoors, 1.5)  
        DarkRP.defineChatCommand("openblastdoors", AdministratorOpenBlastdoors, 1.5)  
        DarkRP.defineChatCommand("showid", ShowID, 1.5)  
        DarkRP.defineChatCommand("id", ShowID, 1.5)  
        DarkRP.defineChatCommand("mute", Mute, 1.5)
        DarkRP.defineChatCommand("unmute", UnMute, 1.5)
    end
end)

hook.Add("PlayerCanHearPlayersVoice", "mutedplayers", function(listener, talker)
    if listener:IsMuted(talker) then return false end
end)