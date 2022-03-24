// Wildfire Black Mesa Roleplay
// File description: BMRP server-side crystal analyzer entity script
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

util.AddNetworkString( "AnalyzerUI" )
util.AddNetworkString( "AnalyzerScanning" )
util.AddNetworkString( "AnalyzerConfirm" )
util.AddNetworkString( "AnalyzerDeny" )

function ENT:Initialize()
    
    self:SetModel("models/props_equipment/hev_suitdock01.mdl") 
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetTrigger(true)
    //self:SetSolidFlags(FSOLID_CUSTOMRAYTEST) 
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
    self.Outputs = WireLib.CreateSpecialOutputs(self, {"Crystal", "Scanning", "Successful", "Failed", "Broken"}, {"NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"})
end

function ENT:Use(activator)
    local ply = activator
    local ent = self:GetChildren()[1]
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not IsValid(ent) then return end
    if self:GetIsScanning() == true then return end
    // cppi owner check
    if self:CPPIGetOwner() ~= ply then 
        hook.Run("SystemMessage", ply, "", "You are not the owner of this analyzer.")
        return
    elseif self:GetHasCrystal() == true then
        if not IsValid(ent) then return end
        net.Start("AnalyzerUI")
        net.WriteEntity(self) // write the analyzer first
        net.WriteEntity(ent) // write the crystal second
        net.Send(ply)
    else
        if WireAddon then Wire_TriggerOutput(self, "Successful", 0) end
        if WireAddon then Wire_TriggerOutput(self, "Failed", 0) end
        if WireAddon then Wire_TriggerOutput(self, "Scannning", 0) end
        if WireAddon then Wire_TriggerOutput(self, "Crystal", 0) end
        self:SetDebounce(false)
        self:SetHasCrystal(false)
        self:SetIsScanning(false) // double check
        self:SetSkin(0)
        local oldpos = ent:GetPos()
        ent:SetParent(nil)
        ent:SetVelocity(self:GetForward())
        ent:SetPos(oldpos)
        self:SetDebounce(true)
        timer.Simple(5, function()
            if not IsValid(self) then return end 
            self:SetDebounce(false)
        end)
    end
end

local FailedScanChance = 25
local MachineExplosionChance = 5
local scantime = 30

net.Receive( "AnalyzerConfirm", function( len, ply )
    local analyzer = net.ReadEntity()
    local ent = net.ReadEntity()
    local beamcolor = "255 255 255"
    local rainbow = false
    if WireAddon then Wire_TriggerOutput(analyzer, "Scanning", 1) end
    for k,v in pairs(ent.CrystalTypes) do
        if v[1] == ent:GetCrystalType() then
            if v[3] == "Rainbow" then
                beamcolor = math.random(0,255).." "..math.random(0,255).." "..math.random(0,255)
                rainbow = true
            else
                beamcolor = v[2].r .. " " .. v[2].g .. " " .. v[2].b
            end
        end
    end
    analyzer:SetIsScanning(true) 
    analyzer:SetSkin(1)
    hook.Run("SystemMessage", ply, "", "The crystal is beginning to spin and analyze, please wait...")
    -- play sound
    analyzer:EmitSound("ambient/machines/thumper_startup1.wav")
    local entname = "wacky_crystal_"..ent:EntIndex()
    ent:SetName(entname)
    local beam = ents.Create("env_beam")
    beam:SetKeyValue("BoltWidth", "1.0")
    beam:SetKeyValue("life", ".25")
    beam:SetKeyValue("NoiseAmplitude", "10.4")
    beam:SetKeyValue("Radius", "500")
    beam:SetKeyValue("TextureScroll", "35")
    beam:SetKeyValue("renderamt", "150")
    beam:SetKeyValue("rendercolor", beamcolor)
    beam:SetKeyValue("LightningStart", entname)
    beam:SetKeyValue("StrikeTime", "-.5")
    beam:SetKeyValue("Texture", "sprites/lgtning.spr")
    beam:SetKeyValue("damage", "2")
    beam:SetKeyValue("spawnflags", "1")
    local shouldactivatebeams = false
    timer.Simple(4, function()
        if not IsValid(analyzer) then return end
        shouldactivatebeams = true
        beam:Spawn()
        beam:Activate()
        analyzer:EmitSound("debris/beamstart8.wav")
    end)
    timer.Simple(3, function()
        if not IsValid(ent) then return end
        if not IsValid(analyzer) then return end
        timer.Create("TurnCrystalAnalyzer"..ent:EntIndex(), scantime/(scantime*10), (scantime*10), function()
            if not IsValid(ent) then return end
            if not IsValid(analyzer) then return end
            if not IsValid(beam) then return end
            ent:SetAngles(ent:GetAngles() + Angle(10, 10, 0))
            local beamendvec = analyzer:GetPos() + Vector(10, 0, 0)
            beam:SetKeyValue("targetpoint", beamendvec.x .. " " .. beamendvec.y .. " " .. beamendvec.z)
            if rainbow then
                beamcolor = math.random(0,255).." "..math.random(0,255).." "..math.random(0,255)
                beam:SetKeyValue("rendercolor", beamcolor)
            end
            if shouldactivatebeams then
                beam:Fire("Toggle", "", 0)
            end
        end)
        analyzer:EmitSound("npc/scanner/scanner_scan_loop2.wav", 100, 100)
        timer.Simple(scantime, function()
            if WireAddon then Wire_TriggerOutput(analyzer, "Scanning", 0) end
            local rand = math.random(1, 100)
            if rand <= MachineExplosionChance then // random chances of the machine exploding
                hook.Run("SystemMessage", ply, "", "The crystal's yearn for power became overwhelming causing it to explode. Call a maintenance team to repair your analyzer.")
                analyzer:SetHasCrystal(false)
                analyzer:EmitSound("ambient/levels/labs/electric_explosion1.wav")
                analyzer:SetBroken(true)
                analyzer:Ignite(30)
                analyzer:SetSkin(0)
                ent:Remove()
                
                local explosion = ents.Create("env_explosion")
                explosion:SetKeyValue("iMagnitude", "3")
                explosion:SetKeyValue("rendermode", "5")
                explosion:Fire("Explode")
                explosion:SetPos(analyzer:GetPos())
                if WireAddon then Wire_TriggerOutput(analyzer, "Broken", 1) end
            elseif rand <= FailedScanChance then // random chances of the scan failing
                hook.Run("SystemMessage", ply, "", "The crystal has failed to scan. Please try again.")
                analyzer:SetHasCrystal(true)
                analyzer:SetSkin(0)
                analyzer:EmitSound("ambient/machines/thumper_shutdown1.wav")
                if WireAddon then Wire_TriggerOutput(analyzer, "Failed", 1) end
            else
                hook.Run("SystemMessage", ply, "", "The crystal has been sucessfully scanned! You can get the new data by using the handheld scanner.")
                analyzer:EmitSound("ambient/machines/teleport3.wav")
                analyzer:SetHasCrystal(false)
                ent:SetAnalyzerScanned(true)
                ent:SetCrystalScanned(true) // removes the need for handheld scanners
                -- trigger wire output
                if WireAddon then Wire_TriggerOutput(analyzer, "Successful", 1) end
            end
            analyzer:SetIsScanning(false)
            if IsValid(beam) then
                beam:Remove()
            end
            -- stop sound
            analyzer:StopSound("npc/scanner/scanner_scan_loop2.wav")
        end)
    
    end)

end )

net.Receive( "AnalyzerDeny", function( len, ply )
    local analyzer = net.ReadEntity()
    local ent = net.ReadEntity()
    if WireAddon then Wire_TriggerOutput(analyzer, "Successful", 0) end
    if WireAddon then Wire_TriggerOutput(analyzer, "Failed", 0) end
    if WireAddon then Wire_TriggerOutput(analyzer, "Scannning", 0) end
    if WireAddon then Wire_TriggerOutput(analyzer, "Crystal", 0) end
    analyzer:SetDebounce(false)
    analyzer:SetHasCrystal(false)
    analyzer:SetIsScanning(false) // double check
    analyzer:SetSkin(0)

    local oldpos = ent:GetPos()
    ent:SetParent(nil)
    ent:SetVelocity(analyzer:GetForward())
    ent:SetPos(oldpos)
    analyzer:SetDebounce(true)
    timer.Simple(5, function()
        if not IsValid(analyzer) then return end 
        analyzer:SetDebounce(false)
    end)

end )

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if not IsValid(self) then return end
    if ent:IsPlayer() then return end
    if self:GetBroken() == true then return end
    
    if ent:GetClass() == "xen_crystal" then
        if self:GetDebounce() == false and self:GetHasCrystal() == false then
            self:SetDebounce(true)
            timer.Simple(2, function()
                if not IsValid(self) then return end
                self:SetDebounce(false)
            end)
        elseif self:GetDebounce() == true then
            return
        end
        if self:GetHasCrystal() == true then return end // If it has a crystal inside of it, do nothing.
        if ent:GetClean() ~= true then return end // If the crystal is dirty, do nothing.
        if ent:GetAnalyzerScanned() == true then return end // If It's already scanned, don't let them do it again!
        if self:GetHasCrystal() ~= true then
            ent:ForcePlayerDrop()
            if WireAddon then Wire_TriggerOutput(self, "Crystal", 1) end
            self:SetHasCrystal(true)
            for _, ply in pairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) <= 100 then
                    hook.Run("SystemMessage", ply, "", "You have inserted a crystal into the analyzer. Be careful!")
                end
            end
            ent:SetParent(self)
            ent:SetLocalPos(Vector(-1.1386244297028, -5.793468952179, 65.816223144531))
            ent:SetLocalAngles(Angle(-90, 90, 0))
        end
    end 
end
