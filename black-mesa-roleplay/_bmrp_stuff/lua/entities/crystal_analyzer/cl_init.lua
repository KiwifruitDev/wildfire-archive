// Wildfire Black Mesa Roleplay
// File description: BMRP client-side crystal analyzer entity script
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

surface.CreateFont("AnalyzerText", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(30),
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
    bold = true,
})

surface.CreateFont("FunnyBMRPFont", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(5),
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

surface.CreateFont("FunnyBMRPFontItallic", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(5),
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

surface.CreateFont("FunnyBMRPFontBold", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = ScreenScale(5),
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
    bold = true,
})


function ENT:Draw()
    self:DrawModel()
    
	local text = "(BROKEN)"
	local offset = Vector(0, 0, 105)
	local origin = self:GetPos()
	if LocalPlayer():GetPos():DistToSqr(origin) > (300*300) then return end
	local pos = origin + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)

	cam.Start3D2D(pos, ang, 0.05)
		surface.SetFont("AnalyzerText")
		local w, h = surface.GetTextSize(text)
		if self:GetBroken() then
			draw.SimpleText(text, "AnalyzerText", 4, 4, Color(0,0,0), 1, 1)
			draw.SimpleText(text, "AnalyzerText", 0, 0, Color(255, 0, 0), 1, 1)
        end
	cam.End3D2D()

end

net.Receive( "AnalyzerUI", function( len, ply )
    local analyzer = net.ReadEntity()
    local ent = net.ReadEntity()
    local crystaltype = "White"
    for k,v in pairs(ent.CrystalTypes) do
        if v[1] == ent:GetCrystalType() then
            crystaltype = v[1]
        end
    end

    local ply = LocalPlayer()
    local frame = vgui.Create( "DFrame" )
    local accentcolor = Color( 255, 51, 0, 91 )
    frame:SetSize( 300, 90 )
    frame:SetTitle( "[ Crystal Analyzer Confirmation ]" )
    frame:SetBackgroundBlur(true)
    frame:SetVisible(true)
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame:Center()
    local x, y = frame:GetPos()
    local w, h = frame:GetSize()
    frame:SetPos(-w, y)
    frame:MoveTo(x, y, 0.1, 0)
    frame:MakePopup()
    frame:Center()

    function frame:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, accentcolor )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, Color( 21, 21, 21, 245 ) )
    end

    local text = vgui.Create( "DLabel", frame )
    text:SetPos( 10, 25 )
    text:SetText( "Are you sure you want to scan this " .. crystaltype .. " crystal?" )
    text:SetSize( 280, 20 )
    text:SetTextColor( Color( 255, 255, 255 ) )
    text:SetFont( "FunnyBMRPFont" )

    local text2 = vgui.Create( "DLabel", frame )
    text2:SetPos( 10, 40)
    text2:SetText( "(It could have dangerous side effects...)" )
    text2:SetSize( 300, 20 )
    text2:SetTextColor( Color( 255, 255, 255 ) )
    text2:SetFont( "FunnyBMRPFontItallic" )

    local yesbutton = vgui.Create( "DButton", frame )
    yesbutton:SetText( "Yes!" )
    yesbutton:SetPos( 10, 65 )
    yesbutton:SetSize( 80, 20 )
    yesbutton:SetTextColor( Color( 0, 255, 0 ) )
    yesbutton:SetFont( "FunnyBMRPFontBold" )

    local nobutton = vgui.Create( "DButton", frame )
    nobutton:SetText( "No!" )
    nobutton:SetPos( 210, 65 )
    nobutton:SetSize( 80, 20 )
    nobutton:SetTextColor( Color( 255, 0, 0 ) )
    nobutton:SetFont( "FunnyBMRPFontBold" )

    function yesbutton:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, accentcolor )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, Color( 21, 21, 21, 245 ) )
    end

    function nobutton:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, accentcolor )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, Color( 21, 21, 21, 245 ) )
    end

    yesbutton.DoClick = function()
        net.Start( "AnalyzerConfirm" )
        net.WriteEntity(analyzer) // write the analyzer first
        net.WriteEntity(ent) // write the crystal second
        net.SendToServer()
        frame:Close()
    end

    nobutton.DoClick = function()
        net.Start( "AnalyzerDeny")
        net.WriteEntity(analyzer) // write the analyzer first
        net.WriteEntity(ent) // write the crystal second
        net.SendToServer()
        frame:Close()
    end
    
end )