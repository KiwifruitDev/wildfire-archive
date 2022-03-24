// Wildfire Ranked Challenges
// File description: Clientside script for handling the ranked challenge GUI
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

local function start(challenge, ghost, challengename, staff)
    local newframe = vgui.Create( "DFrame" )
    newframe:SetSize( 300, 150 ) 
    newframe:SetTitle("Ranked Challenge - "..challenge.name ) 
    newframe:SetVisible(true) 
    newframe:SetDraggable(false) 
    newframe:ShowCloseButton(true) 
    newframe:SetBackgroundBlur(true)
    newframe:Center()
    local label = Label("Are you sure you would like to start the\n\n",newframe)
    label:SizeToContents()
    label:Center()
    local label2 = Label("\n"..challenge.name.." ranked challenge?\n",newframe)
    label2:SizeToContents()
    label2:Center()
    local DermaButton = vgui.Create( "DButton", newframe )
    DermaButton:SetText( "Yes" )
    DermaButton:SetPos( 25, 100 )
    DermaButton:SetSize( 125, 30 )
    DermaButton.DoClick = function()
        newframe:Close()
        net.Start("StartRankedChallenge")
        net.WriteBool(staff)
        net.WriteString(challengename)
        net.SendToServer("StartRankedChallenge")
    end
    local sayno = vgui.Create( "DButton", newframe )
    sayno:SetText( "No" )
    sayno:SetPos( 150, 100 )
    sayno:SetSize( 125, 30 )
    sayno.DoClick = function()
        newframe:Close()
    end
    newframe:MakePopup()
end

local list = {}
local list2 = {}
local Frame
local challengename
local challenge

net.Receive("OpenRankedChallenges", function()
    challengename = net.ReadString()
    challenge = KIWI.ChallengeList[challengename]
    if not challenge then return end
    Frame = vgui.Create( "DFrame" )
    Frame:SetSize( ScrW()/2, ScrH()/2 ) 
    Frame:SetTitle( "Ranked Challenge - "..challenge.name ) 
    Frame:SetVisible( true ) 
    Frame:SetDraggable( false ) 
    Frame:ShowCloseButton( true ) 
    Frame:SetBackgroundBlur(true)
    Frame:Center()
    Frame:MakePopup()
    local sheet = vgui.Create( "DPropertySheet", Frame )
    sheet:Dock( FILL )
    local panel1 = vgui.Create( "DPanel", sheet )
    panel1:Dock(FILL)
    list = vgui.Create("DListView", panel1)
    list:Dock( FILL )
    list:SetMultiSelect( false )
    list:AddColumn( "Player Name" )
    list:AddColumn( "SteamID" )
    list:AddColumn( "Time (Seconds)" )
    list:SortByColumn(3, false)
    // Populate this menu with the top 32 players.
    net.Start("GetRankedChallengeData")
    net.WriteBool(false) // not staff
    net.WriteString(challengename)
    net.SendToServer()
    list.OnRowSelected = function( lst, index, pnl )
        local Menu = DermaMenu()
        local steamidcopy = Menu:AddOption( "Copy SteamID", function()
            SetClipboardText(pnl:GetColumnText( 2 ))
        end)
        steamidcopy:SetIcon( "icon16/key.png" )
        /*
        local btnWithIcon = Menu:AddOption( "Challenge with ghost", function()
            Frame:Close()
            start(challenge, pnl:GetColumnText(2), challengename, false)
        end)
        btnWithIcon:SetIcon( "icon16/user_go.png" )
        */
        local btnWithIcon2 = Menu:AddOption( "Challenge", function()
            Frame:Close()
            start(challenge, "", challengename, false)
        end)
        btnWithIcon2:SetIcon( "icon16/arrow_right.png" )
        if LocalPlayer():IsStaff() then
            local btnWithIcon3 = Menu:AddOption( "Move to Staff Leaderboard", function()
                net.Start("MoveRankedChallengeData")
                net.WriteBool(false)
                net.WriteString(pnl:GetColumnText(2))
                net.WriteString(challengename)
                net.SendToServer()
            end)
            btnWithIcon3:SetIcon( "icon16/application_edit.png" )
            local btnWithIcon4 = Menu:AddOption( "Delete entry", function()
                net.Start("DeleteRankedChallengeData")
                net.WriteBool(false)
                net.WriteString(pnl:GetColumnText(2))
                net.WriteString(challengename)
                net.SendToServer()
            end)
            btnWithIcon4:SetIcon( "icon16/application_delete.png" )
        end
        Menu:Open()
        //print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
    end
    local panel3 = vgui.Create( "DPanel", sheet )
    panel3:Dock(FILL)
    list2 = vgui.Create("DListView", panel3)
    list2:Dock( FILL )
    list2:SetMultiSelect( false )
    list2:AddColumn( "Player Name" )
    list2:AddColumn( "SteamID" )
    list2:AddColumn( "Time (Seconds)" )
    list2:SortByColumn(3, false)
    // Populate this menu with the top 32 staff.
    net.Start("GetRankedChallengeData")
    net.WriteBool(true) // is staff
    net.WriteString(challengename)
    net.SendToServer()
    //list2:AddLine("Kiwifruit", "STEAM_0:1:41323547", "10")
    //list2:AddLine("Flynn", "STEAM_0:1:75090064", "11")
    //list2:AddLine("Treycen", "STEAM_0:0:78540453", "12")
    list2.OnRowSelected = function( lst, index, pnl )
        local Menu = DermaMenu()
        local steamidcopy = Menu:AddOption( "Copy SteamID", function()
            SetClipboardText(pnl:GetColumnText( 2 ))
        end)
        steamidcopy:SetIcon( "icon16/key.png" )
        /*
        local btnWithIcon = Menu:AddOption( "Challenge with ghost", function()
            Frame:Close()
            start(challenge, pnl:GetColumnText(2), challengename, true)
        end)
        btnWithIcon:SetIcon( "icon16/user_go.png" )
        */
        local btnWithIcon2 = Menu:AddOption( "Challenge", function()
            Frame:Close()
            start(challenge, "", challengename, true)
        end)
        btnWithIcon2:SetIcon( "icon16/arrow_right.png" )
        
        if LocalPlayer():IsStaff() then
            /*
            local btnWithIcon3 = Menu:AddOption( "Move to Player Leaderboard", function()
                net.Start("MoveRankedChallengeData")
                net.WriteBool(true)
                net.WriteString(pnl:GetColumnText(2))
                net.WriteString(challengename)
                net.SendToServer()
            end)
            btnWithIcon3:SetIcon( "icon16/application_edit.png" )
            */
            local btnWithIcon4 = Menu:AddOption( "Delete entry", function()
                net.Start("DeleteRankedChallengeData")
                net.WriteBool(true)
                net.WriteString(pnl:GetColumnText(2))
                net.WriteString(challengename)
                net.SendToServer()
            end)
            btnWithIcon4:SetIcon( "icon16/application_delete.png" )
        end
        Menu:Open()
        print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
    end
    sheet:AddSheet( "Player Leaderboard", panel1, "icon16/application.png" )
    //sheet:AddSheet( "Staff Leaderboard", panel3, "icon16/application_key.png" )
end)

net.Receive("RecieveRankedChallengeData", function()
    local staff = net.ReadBool()
    local amount = net.ReadInt(7)
    for i = 1, amount do
        local steamid = net.ReadString()
        local name = net.ReadString()
        local time = math.Round(net.ReadFloat(),2)
        if staff then
            list2:AddLine(name, steamid, time)
        else
            list:AddLine(name, steamid, time)
        end
    end
    if amount == 0 then
        local Menu = DermaMenu()
        local btnWithIcon2 = Menu:AddOption( "Challenge", function()
            Frame:Close()
            start(challenge, "", challengename)
        end)
        btnWithIcon2:SetIcon( "icon16/arrow_right.png" )
        Menu:Open()
    end
end)

// https://wiki.facepunch.com/gmod/surface.DrawPoly

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	draw.NoTexture()
	surface.DrawPoly( cir )
end

local x = -192
local xmemory = -192
local dt = 0
local text = ""

local white = Color(255,255,255,255)

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
    local ply = LocalPlayer()
    local challengename = ply:GetNWString("Challenge","")
    if challengename ~= "" then
        x = 256
    else
        x = -192
    end
    xmemory = math.Approach( xmemory, x, dt*1024 )
	surface.SetDrawColor( 0, 0, 0, 128 )
    surface.SetFont("DermaLarge")
	draw.Circle( ScrW()-xmemory, ScrH() / 2, 128+math.sin( CurTime()*4 ) * 8, 32 )
    draw.Circle( ScrW()-xmemory, ScrH() / 2, 140+math.sin( CurTime()*4 ) * 8, 32 )
    local challenge = KIWI.ChallengeList[challengename]
    if challenge then
        text = challenge.name.."\n\n"..math.Round(ply:GetNWFloat("ChallengeTimer", 0),2).."\n\nBest: "..math.Round(ply:GetNWFloat("ChallengePreviousBest", 0),2)
    end
    local w, h = surface.GetTextSize(text)
    draw.DrawText(text, "DermaLarge", ScrW()-xmemory, ScrH()/2-h/2, white, TEXT_ALIGN_CENTER)
    dt = FrameTime()
end )

local RANKED_CHALLENGE_MUSIC

net.Receive("PlayRankedChallengeMusic", function()
    if RANKED_CHALLENGE_MUSIC then
        RANKED_CHALLENGE_MUSIC:Stop()
    end
    RANKED_CHALLENGE_MUSIC = CreateSound(LocalPlayer(), "#wildfire/challenges/thinking_music.mp3") -- the # symbol means that this is music
    RANKED_CHALLENGE_MUSIC:Play()
end)

net.Receive("StopRankedChallengeMusic", function()
    if RANKED_CHALLENGE_MUSIC then
        RANKED_CHALLENGE_MUSIC:FadeOut(1)
    end
    local success = net.ReadBool()
    if success then
        surface.PlaySound("wildfire/challenges/success.mp3")
    end
end)