// Wildfire Black Mesa Roleplay
// File description: BMRP server-side testing entity script
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
    self:SetModel("models/halflife/items/flare.mdl")
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

function ENT:Think()
    if IsValid(self:GetFlare()) then
        self:GetFlare():SetPos(self:GetPos() + self:GetUp() * 18)
    end
end

-- on removal, remove the flare
function ENT:OnRemove()
    if IsValid(self:GetFlare()) then
        self:GetFlare():Remove()
    end
    self:StopSound("ambient/fire/fire_small1.wav")
end

function ENT:Use()
    if not IsValid(self:GetFlare()) then
        self:EmitSound("ambient/fire/gascan_ignite1.wav")
        local flare = ents.Create("env_flare")
        flare:SetPos(self:GetPos() + self:GetUp() * 18)
        flare:SetKeyValue("spawnflags", "4")
        flare:Spawn()
        flare:SetColor(Color(255,255,255,0))
        flare:SetRenderMode(RENDERMODE_TRANSALPHA)
        if IsValid(flare) then
            self:SetFlare(flare)
        end
        self:EmitSound("ambient/fire/fire_small1.wav")
    else
        self:GetFlare():Remove()
        self:SetFlare(nil)
        self:StopSound("ambient/fire/fire_small1.wav")
    end
end