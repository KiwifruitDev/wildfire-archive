// Wildfire Black Mesa Roleplay
// File description: BMRP pill pack handler script
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

// Apply a pill for Xenian creatures
local function PillGiver(ply)
    timer.Simple(0.5, function()
        pillList = switch{ // Job -> Pill
            ["Headcrab"] = function () pk_pills.apply(ply, "hl1crab"); ULib.invisible(ply, true, 0) end,
            ["Houndeye"] = function () pk_pills.apply(ply, "hl1houndeye"); ULib.invisible(ply, true, 0) end,
            ["Bullsquid"] = function () pk_pills.apply(ply, "hl1bullsquid"); ULib.invisible(ply, true, 0) end,
        }
        pillList:case(ply:getDarkRPVar("job"))
    end)
end
hook.Add( "PlayerSpawn", "PillGiveHook", PillGiver ) // Works on intial spawn and respawns so I mean... hook into It

// This removes your pill when you die or respawn.
local function PillRemover( ply )
	timer.Simple( 0.5, function()
		pk_pills.restore(ply)
        ULib.invisible(ply, false, 255)
	end)
end
hook.Add( "OnPlayerChangedTeam", "PillRemoveHook", PillRemover ) // Removing the pill from the player when they change job

// Switchcase API found from GitHub because It's much easier.
function switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
  return t
end