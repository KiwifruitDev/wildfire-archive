// Wildfire Black Mesa Roleplay
// File description: BMRP server-side trashcan init
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
    self:SetModel("models/highrise/trashcanashtray_01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
    // make invisible
    //self:SetRenderMode(RENDERMODE_TRANSALPHA)
    //self:SetColor(Color(255, 255, 255, 0))
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then
        return
    end
    hook.Run("SystemMessage", activator, "", "Place crystals and materials here to remove it.")
end

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if self:GetTimedOut() ~= 0 and self:GetTimedOut() > CurTime() then return end
    if ent:IsPlayer() then return end
    local materialtype
    if ent.GetCrystalType ~= nil then
        materialtype = ent:GetCrystalType() .. " Crystal"
    elseif ent.GetCraftingMaterialType ~= nil then
        materialtype = ent:GetCraftingMaterialType() .. " Scrap"
    end
    if materialtype then
        if ent:CPPIGetOwner() ~= nil then
            // tell the cppi owner that the entity is being removed
            hook.Run("SystemMessage", ent:CPPIGetOwner(), "", "Your \"" .. materialtype .. "\" has been disposed of.")
        end
        // remove the entity
        ent:Remove()
        self:SetTimedOut(CurTime() + 5)
    end
end
