// Wildfire Black Mesa Roleplay
// File description: BMRP client-side AMS cart entity script
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
include("bmrp_crafting.lua")

surface.CreateFont("CraftingTableText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(30),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function ENT:Draw()
    self:DrawModel()

    local text = "Crafting Table"
    local offset = Vector(0, 0, 50)
    local origin = self:GetPos()
    if LocalPlayer():GetPos():DistToSqr(origin) > (500*500) then return end
    local pos = origin + offset
    local ang = (LocalPlayer():EyePos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    cam.Start3D2D(pos, ang, 0.05)
        surface.SetFont("CraftingTableText")
        local w, h = surface.GetTextSize(text)
        surface.SetTextPos(-(w / 2), -(h / 2))
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text)
    cam.End3D2D()
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

local buttonstate = false
local buttonstatetext = "Required items not in pocket."

net.Receive("BMRP_CraftingGUI", function(len, pl)
    local ply = LocalPlayer()
    if IsValid(Frame) then Frame:Close() end
    Frame = vgui.Create("DFrame")
    Frame:SetSize(512, 300)
    Frame:SetTitle("[ Black Mesa Standardized Crafting Appliance ]")
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
    DLabel:SetText( "Craft Item:" )
    DLabel:SizeToContents()


    function Frame:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 138, 86, 210, 245 ) )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, Color( 21, 21, 21, 245 ) )
    end
    local canproceed = true
    local pocketitems = LocalPlayer():getPocketItems()
    local pocketItems = net.ReadString()
    local craftingtable = net.ReadEntity()
    if pocketitems and pocketItems ~= "" then
        if #pocketitems > 0 then
            canproceed = true
        end
    end
    if canproceed then
        local DLabel2 = vgui.Create( "DLabel", Frame )
        DLabel2:SetPos( 20, 90 )
        DLabel2:SetFont("DermaBigText")
        DLabel2:SetText( "Your Pocket:" )
        DLabel2:SizeToContents()
        local DLabel3 = vgui.Create( "DLabel", Frame )
        DLabel3:SetPos( 20, 60 )
        DLabel3:SetFont("DermaSmallText")
        buttonstate = false
        DLabel3:SetText( pocketItems )
        DLabel3:SetSize( 325, 200 )
        local DComboBox = vgui.Create( "DComboBox", Frame )
        DComboBox:SetPos( 20, 60 )
        DComboBox:SetSize( 300, 20 )
        DComboBox:SetValue( "Click to select an item." )
        DComboBox:SetSortItems(true)
        function DComboBox:Paint( w, h )
            surface.SetDrawColor( 125, 125, 125, 245)
            surface.DrawRect( 0, 0, w, h )
        end
        for k,v in pairs(CRAFTING.CraftItems) do
            DComboBox:AddChoice(k, nil, true)
        end
        local DLabelDesc = vgui.Create( "DLabel", Frame )
        DLabelDesc:SetPos( 20, 210 )
        DLabelDesc:SetFont("DermaSmallText")
        DLabelDesc:SetText( CRAFTING.CraftItems[DComboBox:GetOptionText(DComboBox:GetSelectedID())].description )
        DLabelDesc:SetSize( 325, 200 )
        // word wrapping
        DLabelDesc:SetWrap(true)
        DLabelDesc:SetAutoStretchVertical(true)
        local DButton = vgui.Create( "DButton", Frame )
        DButton:SetPos( 150, 90)
        DButton:SetSize( 170, 25 )
        DButton:SetText( "Craft!" )
        DButton.Think = function()
            if buttonstate == false then
                DButton:SetText(buttonstatetext)
            else
                DButton:SetText("Craft!")
            end
            DButton:SetDisabled(not buttonstate)
        end
        DButton.DoClick = function()
            net.Start("bms_craft")
            net.WriteString(DComboBox:GetOptionText(DComboBox:GetSelectedID()))
            net.WriteEntity(craftingtable)
            net.SendToServer()
            Frame:Close()
        end
        net.Start("bms_cancraft")
        net.WriteString(DComboBox:GetOptionText(DComboBox:GetSelectedID()))
        net.SendToServer()
        local DModelPanel = vgui.Create( "DModelPanel", Frame )
        DModelPanel:SetPos( 320, 24 )
        DModelPanel:SetSize( 190, 275 )
        DModelPanel:SetCamPos( Vector(0, 90, -180) )
        DModelPanel:SetModel( CRAFTING.CraftItems[DComboBox:GetOptionText(DComboBox:GetSelectedID())].model or "models/error.mdl" )
        local mn, mx = DModelPanel.Entity:GetRenderBounds()
        local size = 0
        size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
        size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
        size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
        DModelPanel:SetFOV( 45 )
        DModelPanel:SetCamPos( Vector( size, size, size ) )
        DModelPanel:SetLookAt( (mn + mx) * 0.5 )
        function DModelPanel:LayoutEntity(entity)
        return end
        DComboBox.OnSelect = function( panel, index, value )
            DModelPanel:SetModel( CRAFTING.CraftItems[value].model or "models/error.mdl" )
            local mn, mx = DModelPanel.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
            DModelPanel:SetCamPos( Vector( size, size, size ) )
            DModelPanel:SetLookAt( (mn + mx) * 0.5 )
            DLabelDesc:SetText( CRAFTING.CraftItems[value].description )
            net.Start("bms_cancraft")
            net.WriteString(value)
            net.SendToServer()
        end
    else
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 20, 60 )
        DLabel:SetFont("DermaSmallText")
        DLabel:SetText( "Your pocket is empty or does not contain craftable items! Use the pocket swep to collect up to 4 items for crafting. " )
        DLabel:SetSize( 475, 200 )
        DLabel:SetWrap(true)
        //DLabel:SetAutoStretchVertical(true)
        /*
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 20, 120 )
        DLabel:SetFont("DermaSmallText")
        DLabel:SetText( "You are not a job that is rank applicable." )
        DLabel:SizeToContents()
        */
    end

end)

net.Receive("bms_canpresscraft", function()
    buttonstate = net.ReadBool()
    buttonstatetext = net.ReadString()
end)
