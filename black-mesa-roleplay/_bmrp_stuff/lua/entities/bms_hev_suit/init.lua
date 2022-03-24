// Wildfire Black Mesa Roleplay
// File description: BMRP server-side HEV suit entity script
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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    
    self:SetModel("models/bmhev/bmhev.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:EnableMotion( false )
    end

end

function ENT:Touch(ent)

end

function ENT:Use(ent)
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    if not ent:Alive() then return end
    local job = ent:getDarkRPVar("job")
    if job ~= "Surveyor" then return end
    if ent:HEVSuitEquipped() then
        
        // MERGING FROM HEVSUIT_HUD

        if not IsValid(ent) then return end
        if not ent:IsPlayer() then return end
        if not ent:Alive() then return end
        ent:RemoveSuit()
        net.Start("HevSuitHudOff")
        net.Send(ent)
        if ent:HasWeapon("hev_hands") then
            ent:StripWeapon("hev_hands")
        end

        // END MERGE
        
        ent:RemoveSuit()
        local lgm = ent:GetNWString("LastGoodModel")
        if lgm == "" or lgm == nil then
            local jobtable = ent:getJobTable()
            lgm = jobtable.model
        end
        ent:SetModel(lgm)
        ent:SetNWString("LastGoodModel","")
        return
    end
    ent:SetNWString("LastGoodModel",ent:GetModel())
    ent:SetModel("models/motorhead/hevscientist.mdl")
    //ent:SendLua("surface.PlaySound(\"music/HL2_song23_SuitSong3.mp3\")")

    // MERGING FROM HEVSUIT_HUD

    ent:EquipSuit()
    net.Start("HevSuitHud")
    net.Send(ent)
    ent:Give("hev_hands")
    ent:SelectWeapon("hev_hands")
    timer.Simple(26.533, function() // won't sync to client, oh well
        if not IsValid(ent) then return end
        if not ent:IsPlayer() then return end
        if not ent:Alive() then return end
        if not ent:IsSuitEquipped() then return end
        if not ent:HasWeapon("hev_hands") then return end
        ent:StripWeapon("hev_hands")
    end)

    // END MERGE
end
