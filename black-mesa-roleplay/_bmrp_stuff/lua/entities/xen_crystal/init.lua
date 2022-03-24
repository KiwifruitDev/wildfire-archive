// Wildfire Black Mesa Roleplay
// File description: BMRP server-side AMS cart entity script
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
    
    self:SetModel("models/wildfire/props_xen/crystal_purestsample.mdl") // model stays consistent
    self:SetColor(Color(255, 255, 255, 255)) //default is white along with type

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetTrigger(true)
    self:SetRenderMode(RENDERMODE_NORMAL)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    if self:GetClean() ~= true then
        self:Dirty()
    end

    -- get type table from first value of the crystal type table (self:GetCrystalType())
    for k,v in pairs(self.CrystalTypes) do
        if v[1] == self:GetCrystalType() then
            self:SetColor(v[2])
            self:SetCrystalEffect(v[3])
            break
        end
    end
end

-- Different effects for different crystals (radioactive first)
function ENT:StartTouch(ent)
    if self:GetDebounce() then return end
    if not IsValid(ent) then return end
    if ent:GetClass() == "bmrp_ams_cart" then return end
    if ent:IsPlayer() then
        self:SetDebounce(true)
        timer.Simple(2, function()
            if IsValid(self) then
                self:SetDebounce(false)
            end
        end)
        -- each crystal has a different effect
        if self:GetCrystalEffect() == "Radioactive" then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(math.random(1, 2))
            dmginfo:SetDamageType(DMG_RADIATION)
            dmginfo:SetAttacker(self)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageForce(Vector(0, 0, 0))
            dmginfo:SetDamagePosition(self:GetPos())
            ent:TakeDamageInfo(dmginfo)
            ent:EmitSound("player/geiger" .. math.random(1, 3) .. ".wav", 100, 100)
            hook.Run("SystemMessage", ent, "", "The crystal fills your body with radiation and kills you slowly. Not recommended to touch.")
        elseif self:GetCrystalEffect() == "Sickness" then
            ent:SetNWString("crystal_effect", "lsd")
            ent:SetNWFloat("crystal_effect_start", CurTime())
            ent:SetNWFloat("crystal_effect_end", CurTime() + math.random(1, 5))
            hook.Run("SystemMessage", ent, "", "The wacky purple crystal makes your eyes dilate extremely. Not recommended to touch.")
        elseif self:GetCrystalEffect() == "Health" then
            if ent:Health() < ent:GetMaxHealth() then
                ent:SetHealth(ent:Health() + math.random(1, 20))
                hook.Run("SystemMessage", ent, "", "Your veins start to rush. The crystal appears to be restoring your tissue.")
            else
                hook.Run("SystemMessage", ent, "", "The crystal appears to have no effect.")
            end
        elseif self:GetCrystalEffect() == "Armor" then
            if ent:Armor() < ent:GetMaxArmor() then
                ent:SetArmor(ent:Armor() + math.random(1, 20))
                hook.Run("SystemMessage", ent, "", "Your muscle starts to enhance, your strength increases.")
            else
                hook.Run("SystemMessage", ent, "", "The crystal appears to have no effect.")
            end
        end
    end
end

-- depressive random messages
local sadmessages = {
    "What will my family think?",
    "I really shouldn't have done that...",
    "Never love with all your heart, it only ends in breaking...",
    "I'm not a good person, I'm just a person...",
    "When is it all going to end?",
}

function ENT:Clean()
    self:SetMaterial("")
    self:SetClean(true)
end

function ENT:Dirty()
    self:SetMaterial("models/props_wasteland/tugboat02")
    self:SetClean(false)
end

function ENT:Think()

    if self:GetDebounce() then
        self:SetDebounce(false) -- if you pocket a debounced crystal, it will be un-debounced
    end

    if self:GetClean() == true and self:GetMaterial() ~= "" then
        self:SetMaterial("")
    end
    
    if self:GetCrystalEffect() == "ZeroGravity" then
        local phys = self:GetPhysicsObject()
        construct.SetPhysProp(nil, self, 0, phys, { GravityToggle = false})
        -- make phys mass 1 so it moves slowly
        phys:SetMass(1)
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        -- set color with alpha value
        self:SetColor(Color(self:GetColor().r, self:GetColor().g, self:GetColor().b, 192))
        -- set render fx
        self:SetRenderFX(kRenderFxPulseFast)
    -- check players in range for sadness crystal effect and gimp messages to them
    
    elseif self:GetCrystalEffect() == "Sickness" then
        -- make particle effect appear
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(1)
        util.Effect("balloon_pop", effectdata)
        -- check for players in range
    elseif self:GetCrystalEffect() == "Sadness" then
        for k,v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
            if not IsValid(self) then return end
            if not IsValid(v) then continue end
            if v:IsPlayer() then
                v:Say(table.Random(sadmessages))
                -- next think after 1 second
                v:EmitSound("ambient/voices/citizen_beaten3.wav", 100, 100)
            end
        end
    end
    self:NextThink(CurTime() + 15)
    return true
end

function ENT:Use( ply )
    if not IsValid(ply) then return end
    if not IsValid(self) then return end
    if not IsValid(ply:GetActiveWeapon()) then return end
    if self:GetScanDebounce() then return end
    self:SetScanDebounce(true)
    timer.Simple(3, function()
        if IsValid(self) then
            self:SetScanDebounce(false)
        end
    end)
    if ply:CategoryCheck() == "xenian" then
        if self:GetClean() == false then
            hook.Run("SystemMessage", ply, "", "You cannot consume dirty crystals!")
            return
        else
            for k,v in pairs(self.CrystalTypes) do
                if v[1] == self:GetCrystalType() then
                    ply:SetColor(v[2])
                end
            end
            self:Remove()
            hook.Run("SystemMessage", ply, "", "You've successfully powered yourself up with a " .. self:GetCrystalType() .. " crystal. (max hp is ~400)")
            if ply:Health() >= 400 then return end
            ply:SetHealth(ply:Health() + math.random(1, 150))
            return
        end
    end
    if ply:GetActiveWeapon():GetClass() == "weapon_handheldscanner" then
        if self:GetClean() == false then
            hook.Run("SystemMessage", ply, "", "This crystal is too dirty to be scannable! Clean it!")
            ply:EmitSound("npc/scanner/combat_scan5.wav")
            return
        end
        hook.Run("SystemMessage", ply, "", "You've successfully scanned the crystal. It's resonance is " .. self:GetCrystalResonance() .. "%.")
        ply:EmitSound("npc/scanner/combat_scan2.wav")
        self:SetCrystalScanned(true)
        if self:GetAnalyzerScanned() ~= false then
            hook.Run("SystemMessage", ply, "", "ANALYSIS REPORT >> (AMS) POWER LEVEL: " .. self:GetCrystalAMSPowerLevel() .. "%.")
        end
    else
        hook.Run("SystemMessage", ply, "", "You are not holding out a crystal scanner! You can't scan this!")
    end
end