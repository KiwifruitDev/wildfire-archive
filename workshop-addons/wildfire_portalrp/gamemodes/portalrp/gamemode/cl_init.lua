/*
	Copyright (c) 2021 Wildfire Servers

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

DeriveGamemode("darkrp")
DEFINE_BASECLASS("gamemode_darkrp")

GM.DarkRP = BaseClass

GM.Version = "1.0.0"
GM.Name = "Aperture Science Roleplay"
GM.Author = "KiwifruitDev"

hook.Add("InitPostEntity", "PortalRPDialog", function()
	if game.MaxPlayers() <= 2 then
		local Frame = vgui.Create("DFrame")
		Frame:SetSize(384, 96)
		Frame:Center()
		Frame:SetTitle("GLaDOS")
		Frame:SetVisible(true)
		Frame:SetDraggable(false)
		Frame:ShowCloseButton(false)
		Frame:SetBackgroundBlur(true)
		local FrameLabel = vgui.Create("DLabel", Frame)
		FrameLabel:SetPos(32, -20)
		FrameLabel:SetSize(325, 128)
		FrameLabel:SetText("Sorry, but this gamemode is only available on our dedicated server.")
		local Button = vgui.Create("DButton", Frame)
		Button:SetText("Join Wildfire Aperture RP")
		Button:SetTextColor(Color(255,255,255))
		Button:SetPos(32, 64)
		Button:SetSize(150, 30)
		Button.DoClick = function()
			Frame:Close()
			// TODO: Set to real server IP address.
			permissions.AskToConnect("127.0.0.1:27015")
		end
		local Button2 = vgui.Create("DButton", Frame)
		Button2:SetText("Oh, switch to sandbox")
		Button2:SetTextColor(Color(255,255,255))
		Button2:SetPos(202, 64)
		Button2:SetSize(150, 30)
		Button2.DoClick = function()
			RunConsoleCommand("gamemode", "sandbox")
			RunConsoleCommand("map", game.GetMap())
		end
		Frame:MakePopup()
	end
end)
