// Wildfire Black Mesa Roleplay
// File description: BMRP player clearance script
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

hook.Add("PlayerUse", "BMRP_ButtonClearance", function(ply, ent)
    local clearance = BMRP.MAPS[game.GetMap()]
    if not clearance then return end
    if not clearance.clearance then return end
    local jobtable = ply:getJobTable()
    local clearancenum = 0
    if jobtable.clearance then clearancenum = jobtable.clearance end
    for k,v in pairs(clearance.clearance) do
        for k2,v2 in pairs(v) do
            if ent:MapCreationID() == v2 or ent:GetName() == v2 then
                // DEBOUNCE SO YOU DON'T +USE 5000 TIMES IN A ROW //
                if ply.debounce == true then return false end
                ply.debounce = true
                timer.Simple(0.5, function()
                    ply.debounce = false
                end)
                // BLACKOUT & POWER FAILURE //
                if GetGlobalBool("blackoutpp", false) == true then
                    if not clearance.blackoutdisabled then return end
                    for m,p in ipairs( clearance.blackoutdisabled ) do
                        if ent:MapCreationID() == p or ent:GetName() == p then
                            ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")
                            hook.Run("SystemMessage", ply, "", "POWER FAILURE.")
                            return false
                        end
                    end
                end
                // AMS & CASCADE FAILURE //
                if GetGlobalBool("CascadeClearance", false) == true then
                    if not clearance.amsdisabled then return end
                    for m,p in ipairs( clearance.amsdisabled ) do
                        if ent:MapCreationID() == p or ent:GetName() == p then
                            ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")
                            hook.Run("SystemMessage", ply, "", "ANTI-MASS SPECTROMETER FAILURE.")
                            return false
                        end
                    end
                end
                // LAMBDA FAILURE //
                if GetGlobalBool("LambdaFailureClearance", false) == true then
                    if not clearance.lambdadisabled then return end
                    for m,p in ipairs( clearance.lambdadisabled ) do
                        if ent:MapCreationID() == p or ent:GetName() == p then
                            ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")
                            hook.Run("SystemMessage", ply, "", "LAMBDA REACTOR FAILURE. UNRESPONSIVE.")
                            return false
                        end
                    end
                end
                // NORMAL SCANNER LOGIC //
                if clearancenum >= k or (jobtable.hecu and GetGlobalBool("hecuallowed", false) == true and k < 5) or (ply:CategoryCheck() == "xenian" and k <= 3) or (jobtable.hecu and k >= 7) then
                    // ACCESS GRANTED //
                    ply:SendLua("surface.PlaySound(\"common/wpn_select.wav\")")
                    // OVERRIDES //
                    if jobtable.hecu then
                        hook.Run("SystemMessage", ply, "", "Military override activated, access granted.")
                    elseif ply:CategoryCheck() == "xenian" then
                        hook.Run("SystemMessage", ply, "", "You used your Xenian energy to overload the machinery causing it to activate.")
                        ply:EmitSound("ambient/explosions/explode_7.wav")
                    else
                        hook.Run("SystemMessage", ply, "", "Level "..k.." clearance, access granted.")
                    end
                else
                    // ACCESS DENIED //
                    ply:SendLua("surface.PlaySound(\"common/wpn_denyselect.wav\")")
                    if jobtable.hecu then
                        hook.Run("SystemMessage", ply, "", "The H.E.C.U cannot use this right now, access denied.")
                    elseif ply:CategoryCheck() == "xenian" then
                        hook.Run("SystemMessage", ply, "", "Your Xenian energy isn't strong enough to blast the machinery.")
                    elseif k >= 7 then
                        hook.Run("SystemMessage", ply, "", "Military clearance is required, access denied.")
                    else
                        hook.Run("SystemMessage", ply, "", "Level "..k.." clearance is required, access denied.")
                    end
                    return false
                end
            end
        end
    end
end)