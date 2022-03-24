// Wildfire Black Mesa Roleplay
// File description: BMRP server-side tape recorder entity
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
    
    self:SetModel("models/props_xen/crystal_purestsample.mdl")
    self:SetMaterial("models/props_xen/glow_red3.vmt")
    self:SetColor(Color(255,255,255,255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    local cassette_ent = self:GetCassette()
    if not IsValid(cassette_ent) then return end
    if self:GetDonePlaying() then
        self:SetDonePlaying(false)
        self:SetCassette(nil)
        cassette_ent:SetParent(nil)
        cassette_ent:SetPos(self:GetPos() + Vector(0, 0, 10))
        cassette_ent:SetAlreadyPlayed(true)
        timer.Simple(30, function()
            if not IsValid(cassette_ent) then return end
            cassette_ent:SetAlreadyPlayed(false)
        end)
    end
    if self:GetPlaying() then return end
    local cassette = BMRP_ARG.CASSETTES[cassette_ent:GetCassetteID()]
    if not cassette then return end
    self:SetPlaying(true)
    self:OnExtraURL(cassette.text, cassette.sound)
    timer.Simple(cassette.length, function()
        if not IsValid(self) then return end
        self:SetPlaying(false)
        self:SetDonePlaying(true)
        self:OnExtraURL(cassette.text, "")
        self:EmitSound("bmrp/tape_recorder/tape_recorder_stop.wav", 75, 100)
    end)
end

function ENT:Think()
    -- check if a cassette is near it
    if IsValid(self:GetCassette()) then return end
    local pos = self:GetPos()
    local cassettes = ents.FindInSphere(pos, 100)
    for k, v in pairs(cassettes) do
        if v:GetClass() == "cassette" and not v:GetAlreadyPlayed() then
            self:SetCassette(v)
            v:SetParent(self)
            break
        end
    end
end
