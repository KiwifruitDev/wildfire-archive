// Wildfire Black Mesa Roleplay
// File description: Discord Webhook (send and receive messages)
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

-- https://github.com/timschumi/gmod-chttp
require("chttp")
require("gwsockets")

-- https://gist.github.com/Shigbeard/6de6f435e4226a312e8c92ffc9e21180

local webhookurl = CreateConVar("bmrp_webhookurl", "https://discordapp.com/api/webhooks/", {FCVAR_ARCHIVE}, "Discord Webhook URL")
local webapikey = CreateConVar("bmrp_steamwebapikey", "", {FCVAR_ARCHIVE}, "Steam Web API Key")
local websocket_url = CreateConVar("bmrp_websocketurl", "", {FCVAR_ARCHIVE}, "WebSocket URL")
local imgurid = CreateConVar("bmrp_imgurid", "", {FCVAR_ARCHIVE}, "Imgur Client ID")
local imgursecret = CreateConVar("bmrp_imgursecret", "", {FCVAR_ARCHIVE}, "Imgur Client Secret")
local imguraccesstoken = CreateConVar("bmrp_imguraccesstoken", "", {FCVAR_ARCHIVE}, "Imgur Access Token")
local imgurrefreshtoken = CreateConVar("bmrp_imgurrefreshtoken", "", {FCVAR_ARCHIVE}, "Imgur Refresh Token")
local relayname = CreateConVar("bmrp_relayname", "bmrp", {FCVAR_ARCHIVE}, "Relay Name")

function getAvatarFromJson( j_response )
    local t_response = util.JSONToTable( j_response )

    if ( !istable( t_response ) or !t_response.response ) then return false end
    if ( !t_response.response.players or !t_response.response.players[1] ) then return false end
    
    return t_response.response.players[1].avatarfull
end

function getAvatarURL(steamid, callback)
    if webapikey:GetString() == "" then
        callback(false)
        return
    end
    local t_struct = {
        failed = function( err )
            MsgC( Color(255,0,0), "HTTP error: " .. err)
            callback(false)
        end,
        method = "get",
        url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
        parameters = {
            key = webapikey:GetString(),
            steamids = steamid,
        },
        success = function(code, body, headers)
            callback(getAvatarFromJson( body ))
        end
    }
    CHTTP( t_struct )
end

function sendChat(p_sender, s_cmd, s_args, t_return)
    if GetConVar("bmrp_betaserver"):GetBool() == false then
        if webhookurl:GetString() == "" then return end
        if !p_sender then return end
        if !s_cmd then return end
        if !s_args then return end
        local suffix = ""
        if s_cmd == "ooc" or s_cmd == "/" then
            suffix = "/OOC"
        elseif s_cmd == "a" then
            suffix = "/A"
        else
            return -- don't send anything outside of these commands
        end
        getAvatarURL(p_sender:SteamID64(), function(avatar)
            if avatar == false then
                avatar = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg"
            end
            local t_struct = {
                failed = function( err ) MsgC( Color(255,0,0), "HTTP error: " .. err ) end,
                method = "post",
                url = webhookurl:GetString(),
                parameters = {
                    content = s_args,
                    username = "("..suffix..") " .. (p_sender:Nick() or "Unknown"),
                    avatar_url = avatar,
                },
                type = "application/json; charset=utf-8"
            }
            CHTTP( t_struct )
        end)
    end
end

hook.Add("onChatCommand","Discord_Webhook_Chat", sendChat)

// OBSOLETE
concommand.Add("chatrelay", function( ply, cmd, args ) if IsValid(ply) then return end PrintMessage(HUD_PRINTTALK, table.concat(args, " ")) end)

function UploadToImgur(image, type, callback, tryagain)
    if imgurid:GetString() == "" or imgursecret:GetString() == "" or imguraccesstoken:GetString() == "" or imgurrefreshtoken:GetString() == "" then
        callback(false)
        return
    end
    local t_struct = {
        failed = function( err ) 
            MsgC( Color(255,0,0), "HTTP error: " .. err)
            callback(false)
        end,
        method = "post",
        url = "https://api.imgur.com/3/image",
        parameters = {
            image = image,
            type = type,
            title = "",
            description = "",
            album = "",
            name = "",
            title = "",
        },
        headers = {
            ["Authorization"] = "Bearer " .. imguraccesstoken:GetString(),
        },
        success = function(code, body, headers)
            print("Imgur response: " .. body)
            if util.JSONToTable( body )["data"]["error"] then
                if tryagain then
                    // let's try the refresh token
                    print("Imgur error: " .. err)
                    local refresh_struct = {
                        failed = function( err )
                            MsgC( Color(255,0,0), "HTTP error: " .. err)
                            callback(false)
                        end,
                        method = "post",
                        url = "https://api.imgur.com/oauth2/token",
                        parameters = {
                            refresh_token = imgurrefreshtoken:GetString(),
                            client_id = imgurid:GetString(),
                            client_secret = imgursecret:GetString(),
                            grant_type = "refresh_token",
                        },
                        success = function(code, body, headers)
                            local t_response = util.JSONToTable( body )
                            if ( !istable( t_response ) or !t_response.access_token ) then return false end
                            imguraccesstoken:SetString(t_response.access_token)
                            UploadToImgur(image, type, callback, false)
                        end
                    }
                else
                    callback(false)
                end
            else
                callback(util.JSONToTable( body )["data"]["link"])
            end
        end
    }
    CHTTP( t_struct )
end

// WEBSOCKET STUFF (related to relay so it's here) //
BMRP_WEBSOCKET_CONNECTED = BMRP_WEBSOCKET_CONNECTED or false

local function HandleWebSocketMessage(t_msg, websocket_prefix)
    if t_msg.server ~= GetConVar("bmrp_relayname"):GetString() then return end -- not for us
    if t_msg.type == "pong" then
        print(websocket_prefix.."Pong received from server.")
        return true
    elseif t_msg.type == "screenshot" then
        print(websocket_prefix.."Screenshot request for user search string '"..t_msg.data.."' received.")
        local done = false
        // search players with this string in their name
        for k,v in pairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(t_msg.data)) then
                v:SendLua("StartSGS_WebSocket("..(t_msg.quality or 1)..")")
                print(websocket_prefix.."Screenshot request for user '"..v:Nick().."' sent.")
                done = true
                break
            end
        end
        if not done then
            -- fall back to steam names
            for k,v in pairs(player.GetAll()) do
                if string.find(string.lower(v:SteamName()), string.lower(t_msg.data)) then
                    v:SendLua("StartSGS_WebSocket("..(t_msg.quality or 1)..")")
                    print(websocket_prefix.."Screenshot request for user '"..v:SteamName().."' sent.")
                    done = true
                    break
                end
            end
            if not done then
                BMRP_WEBSOCKET:write(util.TableToJSON({
                    type = "screenshot",
                    error = "No player found.",
                    server = GetConVar("bmrp_relayname"):GetString(),
                }))
                print(websocket_prefix.."Screenshot request for user search string '"..t_msg.data.."' failed.")
            end
        end
        return true
    elseif t_msg.type == "verify" then
        local code = t_msg.data
        print(websocket_prefix.."Verification request with code '"..code.."' received.")
        local done = false
        for _, ply in pairs(player.GetAll()) do
            if ply:GetVerificationCode() == code then
                ply:SetVerificationCode("")
                getAvatarURL(ply:SteamID64(), function(avatar)
                    if not BMRP_WEBSOCKET_CONNECTED then return end
                    BMRP_WEBSOCKET:write(util.TableToJSON({
                        type = "verify",
                        server = GetConVar("bmrp_relayname"):GetString(),
                        steamname = ply.SteamName and ply:SteamName() or ply:Nick(),
                        steamid = ply:SteamID(),
                        steamid64 = ply:SteamID64(),
                        avatar = avatar,
                    }))
                    print(websocket_prefix.."Verification request for user '"..ply:Nick().."' accepted and sent to server.")
                end)
                done = true
                break
            end
        end
        if not done then
            BMRP_WEBSOCKET:write(util.TableToJSON({
                type = "verify",
                error =  "Invalid code.",
                server = GetConVar("bmrp_relayname"):GetString(),
            }))
            print(websocket_prefix.."Verification request with code '"..code.."' failed.")
        end
        return true
    elseif t_msg.type == "relay" then
        if GetConVar("bmrp_betaserver"):GetBool() == false then -- don't relay to beta server
            local message = t_msg.message
            local author = t_msg.author
            local prefix = t_msg.prefix
            PrintMessage(HUD_PRINTTALK, prefix.." "..author..": "..message)
            return true
        end
        return false
    elseif t_msg.type == "discordinfo" then
        local steamid = t_msg.steamid
        // get player by steamid
        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) then
            print(websocket_prefix.."Discord info request for user '"..ply:Nick().."' received.")
            ply:SetDiscordPremium(t_msg.discordpremium)
            ply:SetDiscordVerified(t_msg.discordverified)
            ply:SetDiscordContributor(t_msg.discordcontributor)
            ply:SetDiscordFormerStaff(t_msg.discordformerstaff)
            ply:SetDiscordAmbassador(t_msg.discordambassador)
            ply:SetDiscordDonator(t_msg.discorddonator)
        end
        return true
    elseif t_msg.type == "network" then
        /*
        {
            type: "network",
            server: "bmrp",
            hostname: "[US] 🔥 Wildfire Black Mesa Roleplay | [Happy Holidays!]",
            map: "rp_sectorc_beta_wf",
            gamemode: "Black Mesa Roleplay",
            playercount: 2,
            maxplayers: 45,
            players: [
                {"name": "Kiwifruit"},
                {"name": "Treycen"}
            ]
        }
        */
        local players = {}
        local count = 0
        for k,v in pairs(player.GetAll()) do
            table.insert(players, {name = v:SteamName()})
            count = count + 1
        end
        BMRP_WEBSOCKET:write(util.TableToJSON({
            type = "network",
            server = GetConVar("bmrp_relayname"):GetString(),
            hostname = GetHostName(),
            map = game.GetMap(),
            gamemode = GAMEMODE.Name,
            playercount = count,
            maxplayers = game.MaxPlayers(),
            players = players,
        }))
        return true
    end
    return false
end

function CreateWebSocket(websocketurl, websocket_prefix)
    local websocket = GWSockets.createWebSocket(websocketurl)
    function websocket:onMessage(txt)
        local t_msg = util.JSONToTable(txt)
        local success = HandleWebSocketMessage(t_msg, websocket_prefix)
        if not success then
            print(websocket_prefix.."Unknown message received: "..txt)
        end
    end
    function websocket:onError(txt)
        print(websocket_prefix.."Error: ", txt)
        self:onDisconnected() -- reconnect
    end
    function websocket:onConnected()
        BMRP_WEBSOCKET_CONNECTED = true
        print(websocket_prefix.."Connected to websocket server")
        hook.Run("BMRP_WEBSOCKET_CONNECTED")
    end
    function websocket:onDisconnected()
        BMRP_WEBSOCKET_CONNECTED = false
        self:closeNow()
        print(websocket_prefix.."Disconnected from websocket server, will not retry as this is a fatal error.")
        //print(websocket_prefix.."Disconnected from websocket server, retrying in 30 seconds...")
        //timer.Simple(30, function()
            //self = CreateWebSocket(websocketurl, websocket_prefix)
            //self:open()
        //end)
    end
    return websocket
end

local plymeta = FindMetaTable("Player")

function plymeta:SetVerificationCode(code)
    self.verificationcode = code
end

function plymeta:GetVerificationCode()
    return self.verificationcode
end

function plymeta:SetDiscordPremium(bool)
    self.discordpremium = bool
end

function plymeta:GetDiscordPremium()
    return self.discordpremium
end

function plymeta:SetDiscordVerified(bool)
    self.discordverified = bool
end

function plymeta:GetDiscordVerified()
    return self.discordverified
end

function plymeta:SetDiscordContributor(bool)
    self.discordcontributor = bool
end

function plymeta:GetDiscordContributor()
    return self.discordcontributor
end

function plymeta:SetDiscordFormerStaff(bool)
    self.discordformerstaff = bool
end

function plymeta:GetDiscordFormerStaff()
    return self.discordformerstaff
end

function plymeta:SetDiscordAmbassador(bool)
    self.discordambassador = bool
end

function plymeta:GetDiscordAmbassador()
    return self.discordambassador
end

function plymeta:SetDiscordDonator(bool)
    self.discorddonator = bool
end

function plymeta:GetDiscordDonator()
    return self.discorddonator
end

// !verify command (used to verify discord users) //
hook.Add("PlayerSay", "BMRP_VerifyCommand", function(ply, text, team)
    if not IsValid(ply) then return end
    if string.sub(text, 1, 7) == "!verify" then
        // generate a random 6 character code and send it to the user
        local code = ""
        for i=1,6 do
            code = code .. string.char(math.random(65,90))
        end
        ply:SetVerificationCode(code)
        hook.Run("SystemMessage", ply, "VERIFY", "Your verification code is \""..code.."\". Enter \"/verify server:[SERVER] code:[CODE]\" in the Wildfire Servers Discord to verify your account.")
        return ""
    end
end)

// When a player joins, ask the websocket for their discord info //
hook.Add("PlayerSpawn", "BMRP_PlayerInitialSpawn", function(ply)
    if not IsValid(ply) then return end
    if not BMRP_WEBSOCKET_CONNECTED then return end
    BMRP_WEBSOCKET:write(util.TableToJSON({
        type = "discordinfo",
        steamid = ply:SteamID(),
        server = GetConVar("bmrp_relayname"):GetString(),
    }))
end)

// SGS (Screengrab) hook //
hook.Add("SGSFinishedWebSocket", "websocket_SGS", function(ply, screenshotdata, sendto)
    if not BMRP_WEBSOCKET_CONNECTED then return end
    if sendto ~= nil then print("SG screenshot request recieved by non-websocket.") return end
    local sgtable
    for i = 1, ply.parts do
        if not sgtable then
            sgtable = {}
            sgtable[ 1 ] = screenshotdata[i]
        else
            local x = table.getn( sgtable ) + 1
            sgtable[ x ] = screenshotdata[i]
        end
    end
    print("Sending screenshot to websocket...")
    if table.getn( sgtable ) == ply.parts then
        local compressed = table.concat( sgtable )
        local decompressed = util.Decompress( compressed )
        getAvatarURL(ply:SteamID64(), function(avatar)
            if not BMRP_WEBSOCKET_CONNECTED then return end
            if avatar == false then
                avatar = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg"
            end
            UploadToImgur(decompressed, "base64", function(link)
                if not BMRP_WEBSOCKET_CONNECTED then return end
                if link == false then
                    print("Failed to upload screenshot to imgur.")
                    return
                end
                print("Screenshot uploaded to imgur ("..link..")")
                local xpcategory = ply:CategoryCheck()
                BMRP_WEBSOCKET:write(util.TableToJSON({
                    type = "screenshot",
                    server = GetConVar("bmrp_relayname"):GetString(),
                    //data = decompressed, // NEVER AGAIN (DDOSED TREYCEN USING THIS ONCE)
                    image = link,
                    player = ply:Nick(),
                    steamid = ply:SteamID(),
                    steamid64 = ply:SteamID64(),
                    location = ply:GetNWString("location"),
                    job = ply:getDarkRPVar('job'),
                    health = ""..ply:Health(),
                    armor = ""..ply:Armor(),
                    money = DarkRP.formatMoney(ply:getDarkRPVar('money')),
                    xptype = string.gsub(xpcategory, "^%l", string.upper),
                    xp = ""..ply:GetNWInt("XP_"..xpcategory),
                    avatar = avatar,
                }))
                print("Screenshot request for user '"..ply:Nick().."' successfully processed and sent to websocket server.")
            end, true)
        end)
    else
        print("ERROR: Screenshot request for user '"..ply:Nick().."' failed to process.")
    end
    ply.parts = nil
    ply.data = nil
    ply.sg = nil
    ply.isgrabbing = nil
end)

local cleanuphooks = {
    "PostCleanupMap",
    "InitPostEntity",
}

for _, hookname in pairs(cleanuphooks) do
    hook.Add(hookname, "BMRP_WebSocket_"..hookname, function()
        if websocket_url:GetString() ~= "" then
            BMRP_WEBSOCKET = BMRP_WEBSOCKET or CreateWebSocket(websocket_url:GetString(), "[BMRP WEBSOCKET] ")
            if not BMRP_WEBSOCKET_CONNECTED then
                print("Starting websocket...")
                BMRP_WEBSOCKET:open()
            end
        end
    end)
end

concommand.Add("bmrp_websocket_reconnect", function(ply, cmd, args)
    if IsValid(ply) then
        if not ply:IsDeveloper() then return end
    end
    -- at this point we know the player is the server console
    if not BMRP_WEBSOCKET_CONNECTED then
        BMRP_WEBSOCKET = BMRP_WEBSOCKET or CreateWebSocket(websocket_url:GetString(), "[BMRP WEBSOCKET] ")
        BMRP_WEBSOCKET:open()
        if IsValid(ply) then
            DarkRP.notify(ply, 0, 4, "Websocket reconnected.")
        else
            print("Websocket reconnected.")
        end
    elseif IsValid(ply) then
        DarkRP.notify(ply, 1, 4, "Websocket is already connected.")
    else
        print("Websocket is already connected.")
    end
end)

-- lua_run BMRP_WEBSOCKET = BMRP_WEBSOCKET or CreateWebSocket(GetConVar("bmrp_websocket_url"):GetString(), "[BMRP WEBSOCKET] ") BMRP_WEBSOCKET:open()