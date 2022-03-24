// Wildfire Black Mesa Roleplay
// File description: BMRP crystal system script
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

// Purple crystal vector bounds
local purple = {
    Vector(-5335.317383, -11369.000977, -2624.817627),
    Vector(-5763.113281, -11093.235352, -2900.767090),
}
// Green crystals vector bounds
local green = {
    Vector(-5975.271973, -8271.554688, -1893.910034),
    Vector(-5681.434570, -7832.852051, -2151.242676),
}
// Red crystals vector bounds
local red = {
    Vector(-6496.148926, -12817.813477, 220.980255),
    Vector(-6650.963379, -12709.971680, 109.932632),
}
// Orange crystals vector bounds
// This is basically the entirety of xen
local orange = {
    Vector(-1017.688904, -5353.187012, 1311.713013),
    Vector(-11005.366211, -13998.221680, -7347.238281),
}

// The names of the crystals
local crystalids = {
    "Purple Crystal",
    "Green Crystal",
    "Red Crystal",
    "Orange Crystal",
}

local function DeleteCrystals(ply)
    // Psuedo print function
    local function prt(txt)
        if IsValid(ply) then
            if ply:IsPlayer() then
                return ply:ChatPrint(txt)
            end
        end
        return print(txt)
    end
    // these are the crystals themselves
    local everyent = {
        [crystalids[1]] = ents.FindInBox(purple[1], purple[2]),
        [crystalids[2]] = ents.FindInBox(green[1], green[2]),
        [crystalids[3]] = ents.FindInBox(red[1], red[2]),
        [crystalids[4]] = ents.FindInBox(orange[1], orange[2]), // haha orange box go brr
    }
    prt("======= Deleting xen crystals... =======")
    local totalcrystals = {}
    local allcrystals = {}
    for k,v in pairs(crystalids) do
        allcrystals = {}
        for k1,v1 in pairs(everyent[v]) do
            if IsValid(v1) then
                if v1:GetClass() == "func_physbox" then
                    table.insert(allcrystals, v1:MapCreationID())
                    table.insert(totalcrystals, v1:MapCreationID())
                    v1:Remove()
                end
            end
        end
        prt("------- Found "..#allcrystals.." "..v.."s -------")
    end
    prt("======= Done! "..#totalcrystals.." total deleted! =======")
end

concommand.Add("dev_resetcrystals", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    DeleteCrystals(ply)
    ply:ChatPrint("All crystals deleted.")
end)

BMRP.AddToMapReset("BMRP_ResetCrystals", DeleteCrystals)
