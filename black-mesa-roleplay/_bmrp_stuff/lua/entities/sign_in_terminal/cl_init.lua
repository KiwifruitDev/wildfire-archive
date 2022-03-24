// Wildfire Black Mesa Roleplay
// File description: BMRP client-side sign in terminal entity script
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

include("shared.lua")

function ENT:Draw()

    self:DrawModel()

end

surface.CreateFont("DermaBigText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("DermaSmallText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local buttonstate = true

net.Receive("BMRP_SignInGUI", function(len, pl)
    buttonstate = true
    local subjobs = {}
    local jobcommandtable = {}
    local limit1 = net.ReadUInt(8)
    for i = 1, limit1 do // amount of subjobs
        table.insert(subjobs, {
            command = net.ReadString(), // subjob command
            name = net.ReadString(), // subjob name
            model = net.ReadString(), // subjob model
            description = net.ReadString(), // subjob description
            xp = net.ReadInt(32), // subjob xp
            ranks = {}, // subjob ranks
        })
        local limit2 = net.ReadUInt(8)
        for i2 = 1, limit2 do
            subjobs[i].ranks[net.ReadString()] = {
                prefix = net.ReadString(),
                bonus = net.ReadInt(32),
                xp = net.ReadInt(32),
            }
        end
        // sort ranks by xp
        table.SortByMember(subjobs[i].ranks, "xp", true)
        jobcommandtable[subjobs[i].name] = subjobs[i].command
    end
    // sort subjobs by xp
    table.SortByMember(subjobs, "xp", true)

    local ply = LocalPlayer()
    if IsValid(Frame) then Frame:Close() end
    Frame = vgui.Create("DFrame")
    Frame:SetSize(512, 300)
    Frame:SetTitle("[ Black Mesa Research Facility Sign-in Terminal ] - " .. "[" .. team.GetName(ply:Team()) .. "]")
    Frame:SetBackgroundBlur(true)
    Frame:SetVisible(true)
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true)
    Frame:Center()
    local x, y = Frame:GetPos()
    local w, h = Frame:GetSize()
    Frame:SetPos(-w, y)
    Frame:MoveTo(x, y, 0.1, 0)
    Frame:MakePopup()

    
    local DLabel = vgui.Create( "DLabel", Frame )
    DLabel:SetPos( 20, 30 )
    DLabel:SetFont("DermaBigText")
    DLabel:SetText( "Division:" )
    DLabel:SizeToContents()

    local DLabel2 = vgui.Create( "DLabel", Frame )
    DLabel2:SetPos( 20, 90 )
    DLabel2:SetFont("DermaBigText")
    DLabel2:SetText( "Rank:" )
    DLabel2:SizeToContents()

    function Frame:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 33, 73, 128, 245 ) )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, Color( 21, 21, 21, 245 ) )
    end

    local DModelPanel = vgui.Create( "DModelPanel", Frame )
    DModelPanel:SetPos( 200, 16 )
    DModelPanel:SetSize( 400, 300 - 18 )
    DModelPanel:SetModel( ply:GetModel() or "models/humans/pyri_pm/guard_pm.mdl")
    
    if IsValid(DModelPanel.Entity) then
        local eyepos = DModelPanel.Entity:GetBonePosition(DModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
        eyepos:Add(Vector(0, 0, -15))    -- Move up slightly
        DModelPanel:SetLookAt(eyepos)
    end
    DModelPanel:SetCamPos( Vector(55, -15, 60) )
    function DModelPanel:LayoutEntity(entity)
    return end

    local DLabelDesc = vgui.Create( "DLabel", Frame )
    DLabelDesc:SetPos( 20, 145 )
    DLabelDesc:SetFont("DermaSmallText")
    DLabelDesc:SetText( LocalPlayer():getJobTable().description )
    DLabelDesc:SetSize( 325, 200 )
    // word wrapping
    DLabelDesc:SetWrap(true)
    DLabelDesc:SetAutoStretchVertical(true)
    local hardcodedjobcommands = { //BAD CODE
        "scientist",
        "surveyor",
        "securityguard",
        "securityheavyweapons",
        "securitymedic",
        "hecumarine",
        "hecumedic",
        "hecubrute",
        "heresearcher",
    }
    local canproceed = false
    for k,v in pairs(jobcommandtable) do
        if table.HasValue(hardcodedjobcommands, v) then
            canproceed = true
            break
        end
    end
    if canproceed then
        local SecurityModels = {
            //["0XP - Security Officer"] = "models/humans/pyri_pm/guard_pm.mdl",
            //["25XP - Security Medic"] = "models/humans/pyri_pm/guard_pm_medic.mdl",
            //["75XP - Security Heavy Weapons"] = "models/humans/pyri_pm/guard_pm_heavy.mdl",
        }

        local DComboBox = vgui.Create( "DComboBox", Frame )
        DComboBox:SetPos( 20, 60 )
        DComboBox:SetSize( 300, 20 )
        DComboBox:SetValue( "Click to select a division." )
        DComboBox:SetSortItems(true)
        function DComboBox:Paint( w, h )
            surface.SetDrawColor( 125, 125, 125, 245)
            surface.DrawRect( 0, 0, w, h )
        end
        local DComboBox2 = vgui.Create( "DComboBox", Frame )
        local allnumbersregex = "(%d+)"
        DComboBox.OnSelect = function( self, index, value )
            DModelPanel:SetModel( SecurityModels[value] )
            DComboBox2:Clear()
            DComboBox2:SetValue( "Click to select a rank." )
            local jobname = string.Replace(string.gsub(DComboBox:GetValue(), allnumbersregex, ""), "XP" .. " - ", "")
            local rankname = string.Replace(string.Replace(string.gsub(DComboBox2:GetValue(), allnumbersregex, ""), "XP" .. " - ", ""), " - $ bonus", "")
            if jobcommandtable[jobname] then
                net.Start("bms_canpress")
                net.WriteString(jobcommandtable[jobname])
                net.WriteString(rankname)
                net.SendToServer()
                local jobname = string.Replace(string.gsub(value, allnumbersregex, ""), "XP" .. " - ", "")
                for k, v in pairs(subjobs) do
                    if v.name == jobname then
                        DLabelDesc:SetText( v.description )
                        // use sorted order of v.ranks and loop through it
                        local sortedtable = {}
                        for k2, v2 in pairs(v.ranks) do
                            table.insert(sortedtable, {
                                name = k2,
                                prefix = v2.prefix,
                                bonus = v2.bonus,
                                xp = v2.xp,
                            })
                        end
                        table.SortByMember(sortedtable, "xp", true)
                        for k2, v2 in pairs(sortedtable) do
                            DComboBox2:AddChoice(v2.xp .. "XP" .. " - " .. v2.name .. " - $" .. v2.bonus .. " bonus", nil, v2.xp == 0)
                        end
                    end
                end
            end
        end
        DComboBox2:SetPos( 20, 120 )
        DComboBox2:SetSize( 300, 20 )
        DComboBox2:SetValue( "Click to select a rank." )
        DComboBox2:SetSortItems(false)
        function DComboBox2:Paint( w, h )
            surface.SetDrawColor( 125, 125, 125, 245)
            surface.DrawRect( 0, 0, w, h )
        end
        DComboBox2.OnSelect = function( self, index, value )
            local jobname = string.Replace(string.gsub(DComboBox:GetValue(), allnumbersregex, ""), "XP" .. " - ", "")
            local rankname = string.Replace(string.Replace(string.gsub(DComboBox2:GetValue(), allnumbersregex, ""), "XP" .. " - ", ""), " - $ bonus", "")
            net.Start("bms_canpress")
            net.WriteString(jobcommandtable[jobname])
            net.WriteString(rankname)
            net.SendToServer()
        end
        local DButton = vgui.Create( "DButton", Frame )
        DButton:SetPos( 150, 150 )
        DButton:SetSize( 170, 25 )
        DButton:SetText( "Sign-in" )
        DButton.Think = function()
            if buttonstate == false then
                DButton:SetText("Not enough XP!")
            else
                DButton:SetText("Sign-in")
            end
        end
        DButton.DoClick = function()
            local jobname = string.Replace(string.gsub(DComboBox:GetValue(), allnumbersregex, ""), "XP" .. " - ", "")
            local rankname = string.Replace(string.Replace(string.gsub(DComboBox2:GetValue(), allnumbersregex, ""), "XP" .. " - ", ""), " - $ bonus", "")
            net.Start("bms_signin")
            net.WriteString(jobcommandtable[jobname])
            net.WriteString(rankname)
            net.SendToServer()
            Frame:Close()
        end
        for k, v in pairs(subjobs) do
            SecurityModels[v.xp .. "XP" .. " - " .. v.name] = v.model
        end
        for k,v in pairs(SecurityModels) do
            if k ~= "0XP - " then
                DComboBox:AddChoice(k, nil, string.find(k, "0XP") == 1)
            end
        end
    else
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 20, 60 )
        DLabel:SetFont("DermaSmallText")
        DLabel:SetText( "You are not a job that is division applicable." )

        DLabel:SizeToContents()
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 20, 120 )
        DLabel:SetFont("DermaSmallText")
        DLabel:SetText( "You are not a job that is rank applicable." )
        DLabel:SizeToContents()
    end

end)

net.Receive("bms_canpress", function()
    buttonstate = net.ReadBool()
end)