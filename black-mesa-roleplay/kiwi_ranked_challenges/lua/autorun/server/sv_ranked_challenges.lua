// Wildfire Ranked Challenges
// File description: Serverside script for handling the ranked challenge system
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

include("ranked_challenges/ranked_challenges_config.lua")
AddCSLuaFile("ranked_challenges/ranked_challenges_config.lua")

util.AddNetworkString("OpenRankedChallenges")
util.AddNetworkString("StartRankedChallenge")
util.AddNetworkString("GetRankedChallengeData")
util.AddNetworkString("RecieveRankedChallengeData")
util.AddNetworkString("MoveRankedChallengeData")
util.AddNetworkString("DeleteRankedChallengeData")
util.AddNetworkString("PlayRankedChallengeMusic")
util.AddNetworkString("StopRankedChallengeMusic")

local playertimes = {}

net.Receive("StartRankedChallenge", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    local staff = net.ReadBool()
    local challengename = net.ReadString()
    local challenge = KIWI.ChallengeList[challengename]
    if not challenge then return end
    if ply:GetPos():Distance(challenge.npcpos) > challenge.npcradius then return end
    // If the player is already in a challenge, don't start a new one.
    if ply:GetNWString("Challenge", "") ~= "" then return end
    ply:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.5, 1 )
    ply:Freeze(true)
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetNWFloat("ChallengeTimer", 0)
    ply:SetNWFloat("ChallengePreviousBest", LoadDataFromDataBase(ply, challengename, staff))
    ply:SetNWString("Challenge", "")
    ply:SetNWVector("OriginalPosition", ply:GetPos())
    ply:SetNWAngle("OriginalAngle", ply:GetAngles())
    timer.Simple(0.5, function()
        ply:SetPos(challenge.startpos)
        ply:SetAngles(challenge.startang)
        if challenge.callback ~= nil then
            challenge.callback(ply)
        end
    end)
    timer.Simple(1.5, function()
        ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 0 )
    end)
    timer.Simple(2, function()
        ply:ChatPrint("[Ranked Challenges] Type !stop to quit out of the challenge.")
    end)
    timer.Simple(4.5, function()
        ply:ChatPrint("[Ranked Challenges] "..challenge.name.." - "..challenge.description)
    end)
    timer.Simple(8, function()
        ply:ChatPrint("[Ranked Challenges] 3...")
    end)
    timer.Simple(9, function()
        ply:ChatPrint("[Ranked Challenges] 2...")
    end)
    timer.Simple(10, function()
        ply:ChatPrint("[Ranked Challenges] 1...")
    end)
    timer.Simple(11, function()
        playertimes[ply:EntIndex()] = 0
        ply:SetNWString("Challenge", challengename)
        ply:ChatPrint("[Ranked Challenges] GO!")
        ply:Freeze(false)
        ply:SetMoveType(MOVETYPE_WALK)
        net.Start("PlayRankedChallengeMusic")
        net.Send(ply)
    end)
end)

hook.Add("StopChallengeForPlayer", "stopchallengeforplayerofc", function(player)
    if not IsValid(player) then return end
    if not player:IsPlayer() then return end
    local challenge = player:GetNWString("Challenge", "")
    if not KIWI.ChallengeList[challenge] then return end
    local time = math.Round(player:GetNWFloat("ChallengeTimer", 0),2)
    local best = math.Round(player:GetNWFloat("ChallengePreviousBest", 0),2)
    if best == 0 then best = 90 end
    if time < best then
        SaveDataToDataBase(player, challenge, time, player:IsStaff()) // TODO: change to user groups
    end
    player:SetNWString("Challenge", "")
    net.Start("StopRankedChallengeMusic")
    net.WriteBool(true) -- successful
    net.Send(player)
end)

hook.Add( "PlayerSay", "PlayerSayChallenges", function( ply, text )
	if ( string.lower( text ) == "!stop" ) then
        ply:ChatPrint("[Ranked Challenges] You have exited the challenge.")
        local challenge = KIWI.ChallengeList[ply:GetNWString("Challenge", "")]
        if challenge then
            if challenge.finishedcallback ~= nil then
                challenge.finishedcallback(ply)
            end
        end
        ply:SetNWString("Challenge", "")
        ply:SetNWFloat("ChallengeTimer", 0)
        net.Start("StopRankedChallengeMusic")
        net.WriteBool(false) -- failed
        net.Send(ply)
        /*
        ply:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.5, 1 )
        timer.Simple(0.5, function()
            ply:SetPos(ply:GetNWVector("OriginalPosition"))
            ply:SetAngles(ply:GetNWAngle("OriginalAngle"))
        end)
        timer.Simple(1.5, function()
            ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 0 )
        end)
        */
		return ""
	end
end )

local challengeendhooks = {
    "PlayerDeath",
    "PlayerEnteredVehicle",
    "PlayerChangedTeam",
    "PlayerSpawn",
    "PlayerSpawnedEffect",
    "PlayerSpawnedNPC",
    "PlayerSpawnedEffect",
    "PlayerSpawnedRagdoll",
    "PlayerSpawnedSENT",
    "PlayerSpawnedSENT",
    "PlayerSpawnedVehicle",
    "PlayerGiveSWEP",
    "PlayerNoClip",
}

for k, v in pairs(challengeendhooks) do
    hook.Add(v, "PlayerDeathChallenges", function(ply)
        if not IsValid(ply) then return end
        if not ply:IsPlayer() then return end
        local challenge = ply:GetNWString("Challenge", "")
        if challenge ~= "" then
            if not KIWI.ChallengeList[challenge] then return end
            if challenge.finishedcallback ~= nil then
                challenge.finishedcallback(ply)
            end
            ply:SetNWString("Challenge", "")
            ply:SetNWFloat("ChallengeTimer", 0)
            ply:ChatPrint("[Ranked Challenges] You have been disqualified from the challenge.")
            net.Start("StopRankedChallengeMusic")
            net.WriteBool(false) -- failed
            net.Send(ply)
        end
    end)
end

local cleanup = {
    "InitPostEntity",
    "PostCleanupMap",
}

for k, v in pairs(cleanup) do
    hook.Add(v, "RankedChallengesFinishLines_"..v, function()
        // make finish lines for race challenges
        for k,v in pairs(KIWI.ChallengeList) do
            if v.challengetype == KIWI_CHALLENGE_TYPE_RACE then
                local finishline = ents.Create("trigger_finishline")
                finishline:SetName("finishline_"..k)
                finishline:Spawn()
                finishline:Activate()
                finishline:SetCollisionBoundsWS(v.endcorner1, v.endcorner2)
            end
            if v.initcallback then
                v.initcallback()
            end
        end
    end)
end

hook.Add("InitPostEntity", "RankedChallengeTimer", function()
    // add 1 to playertimes for every player in it
    timer.Create( "RankedChallengeTimer", 1/(1 / engine.TickInterval()), 0, function()
        for k,v in pairs(playertimes) do
            ply = Entity(k)
            if not IsValid(ply) then continue end
            if not ply:IsPlayer() then continue end
            if ply:GetNWString("Challenge", "") == "" then
                playertimes[ply:EntIndex()] = 0
                continue
            end
            playertimes[k] = v + 1/(1 / engine.TickInterval())
            ply:SetNWFloat("ChallengeTimer", v)
            if v >= 90 then
                if ply:GetNWString("Challenge","") == "" then continue end
                ply:ChatPrint("[Ranked Challenges] You have been disqualified from the challenge for taking too long.")
                playertimes[k] = nil
                /*
                ply:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.5, 1 )
                timer.Simple(0.5, function()
                    ply:SetPos(ply:GetNWVector("OriginalPosition"))
                    ply:SetAngles(ply:GetNWAngle("OriginalAngle"))
                end)
                timer.Simple(1.5, function()
                    ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 0 )
                end)
                */
                local challenge = KIWI.ChallengeList[ply:GetNWString("Challenge", "")]
                if not challenge then return end
                if challenge.finishedcallback ~= nil then
                    challenge.finishedcallback(ply)
                end
                ply:SetNWString("Challenge", "")
                continue
            end
        end
    end)
    sql.Query( "CREATE TABLE IF NOT EXISTS challengedata ( SteamID TEXT, Challenge TEXT, TIME FLOAT, NAME TEXT )" )
    //sql.Query( "CREATE TABLE IF NOT EXISTS challengedata_staff ( SteamID TEXT, Challenge TEXT, TIME FLOAT, NAME TEXT )" )
end)

// MYSQL //

// Save a player's specific challenge time
function SaveDataToDataBase( ply, challenge, time, staff )
    if not IsValid(ply) then return end
    local table = "challengedata" //staff and "challengedata_staff" or "challengedata"
	local data = sql.Query( "SELECT * FROM "..table.." WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";")
	if ( data ) then
        // ugly
		sql.Query( "UPDATE "..table.." SET Time = " .. math.Round(time,2) .. " WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
        sql.Query( "UPDATE "..table.." SET Name = " .. sql.SQLStr( ply:Nick()) .. " WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
	else
		sql.Query( "INSERT INTO "..table.." ( SteamID, Challenge, Time, Name ) VALUES( " .. sql.SQLStr( ply:SteamID() ) .. ", " .. sql.SQLStr( challenge ) .. ", " .. math.Round(time,2) .. ", " .. sql.SQLStr(ply:Nick()) .. " )" )
	end
end

// Get data for a specific challenge
function LoadDataFromDataBase(ply, challenge, staff)
    local table = "challengedata" //staff and "challengedata_staff" or "challengedata"
    local data = sql.QueryValue( "SELECT Time FROM "..table.." WHERE SteamID = " .. sql.SQLStr( ply:SteamID() ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
    if data then
        return data
    end
    /*
    elseif staff then
        -- try again without staff
        return LoadDataFromDataBase(ply, challenge, false)
    end
    */
    return 0
end

net.Receive("GetRankedChallengeData", function(len, ply)
    if not IsValid(ply) then return end
    local staff = net.ReadBool()
    local challenge = net.ReadString()
    local table = "challengedata" //staff and "challengedata_staff" or "challengedata"
    local count = tonumber(sql.QueryValue( "SELECT COUNT(*) FROM "..table.." WHERE Challenge = " .. sql.SQLStr( challenge )..";")) or 0
    if count > 32 then count = 32 end // 32 is the max amount of leaderboard entries.
    net.Start("RecieveRankedChallengeData")
    net.WriteBool(staff)
    net.WriteInt(count,7)
    // send the data over in order
    for i = 1, count do
        local row = sql.QueryRow( "SELECT * FROM "..table.." WHERE Challenge = " .. sql.SQLStr( challenge ) .. " ORDER BY Time;", i)
        net.WriteString(row.SteamID)
        net.WriteString(row.NAME)
        net.WriteFloat(row.TIME)
    end
    net.Send(ply)
end)

net.Receive("MoveRankedChallengeData", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    print("INVALID MOVE")
    /*
    local staff = net.ReadBool()
    local steamid = net.ReadString()
    local challenge = net.ReadString()
    if not KIWI.ChallengeList[challenge] then return end
    local from = staff and "challengedata_staff" or "challengedata"
    local to = staff and "challengedata" or "challengedata_staff"
    sql.Query( "INSERT INTO "..to.." SELECT * FROM "..from.." WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
    sql.Query( "DELETE FROM "..from.." WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
    ply:ChatPrint("Moved "..challenge.." entry for SteamID "..steamid.." to "..to.." from "..from)
    */
end)

net.Receive("DeleteRankedChallengeData", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsStaff() then return end
    local staff = net.ReadBool()
    local steamid = net.ReadString()
    local challenge = net.ReadString()
    if not KIWI.ChallengeList[challenge] then return end
    local table = "challengedata" //staff and "challengedata_staff" or "challengedata"
    sql.Query( "DELETE FROM "..table.." WHERE SteamID = " .. sql.SQLStr( steamid ) .. " AND Challenge = " .. sql.SQLStr( challenge ) .. ";" )
    ply:ChatPrint("Deleted "..challenge.." entry for SteamID "..steamid)
end)
