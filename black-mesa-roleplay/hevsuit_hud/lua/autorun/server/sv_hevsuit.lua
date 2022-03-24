// Wildfire HEV Suit HUD
// File description: Serverside HEV suit handling script
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

util.AddNetworkString("HevSuitHud")

util.AddNetworkString("HevSuitHudOff")

AddCSLuaFile("hevsuit/hevstrings.lua")

concommand.Add("hevquiet", function(ply, cmd, args)
    if not ply:IsValid() then return end
    net.Start("HevSuitHudOff")
    net.Send(ply)
    ply:StripWeapon("hev_hands")
    ply:SendLua("RunConsoleCommand(\"snd_restart\")")
end)
