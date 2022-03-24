AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/console03c.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if ( IsValid( phys ) ) then
        phys:Wake()
    end

    self.PlayerUsing = nil
end

local function ST_END_INTERCOM(INTERCOM, SOUND)
    INTERCOM:SetIntercomUsing(false)

    INTERCOM:SetColor(Color(255, 255, 255, 255))

    if IsValid(INTERCOM:GetIntercomUser()) then
        INTERCOM:GetIntercomUser().IntercomUser = false
        hook.Run("PlayerEndIntercom", INTERCOM:GetIntercomUser(), INTERCOM)
    end

    INTERCOM:SetIntercomUser(nil)

    if SOUND then
        for k, v in ipairs(player.GetAll()) do
            //v:EPS_PlaySound(INTERCOM.Sound.End)
            if v:GetNWString("location") ~= "Xen" then
                v:SendLua("surface.PlaySound(\"" .. INTERCOM.Sound.End .. "\")")
            end
        end
    end

    if timer.Exists("IsPlayerNear" .. INTERCOM:GetCreationID()) then
        timer.Remove("IsPlayerNear" .. INTERCOM:GetCreationID())
    end


end

local function ST_START_INTERCOM(PLAYER, INTERCOM)
    INTERCOM:SetIntercomUsing(true)
    INTERCOM:SetIntercomUser(PLAYER)
    INTERCOM:SetColor(Color(255, 0, 0, 255))
    PLAYER.IntercomUser = true
    hook.Run("PlayerStartIntercom", PLAYER, INTERCOM)
    for k, v in ipairs(player.GetHumans()) do
        //v:EPS_PlaySound(INTERCOM.Sound.Start)
        if v:GetNWString("location") ~= "Xen" then
            v:SendLua("surface.PlaySound(\"" .. INTERCOM.Sound.Start .. "\")")
        end
    end
end

function ENT:Use(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    //if not self:GetIntercomUsing() then return end
    local staffoverride = ply:IsStaff()
    if ply:CategoryCheck() == "security" or ply:CategoryCheck() == "administrative" or staffoverride then // This only allows security & the administrator to use the intercom.
        if ply:GetNWInt("XP_security") >= 1600 or ply:GetNWInt("XP_administrative") >= 200 or staffoverride then // This only allows security captains & experienced administrators to use the intercom.
            if not self:GetIntercomUsing() then

                for k,v in ipairs(player.GetAll()) do
                    hook.Run("SystemMessage", v, "", ply:Nick() .. " [ " .. team.GetName(ply:Team()) .. " ] " .. "- is now using the intercom.")
                end

                ST_START_INTERCOM(ply, self)

                timer.Create("IsPlayerNear" .. self:GetCreationID(), 1, 0, function()
                    if IsValid(self) and IsValid(self:GetIntercomUser()) then
                        if self:GetPos():DistToSqr(self:GetIntercomUser():GetPos()) >= 100 * 100 then
                            ST_END_INTERCOM(self, true)
                        end
                    end
                end)

            elseif ply == self:GetIntercomUser() then

                ST_END_INTERCOM(self, true)

            end
            
        else
            DarkRP.notify(ply, 1, 4, "You don't have enough XP to use this!")
        end

    else
        DarkRP.notify(ply, 1, 4, "You are not allowed to use this!")
    end
end


function ENT:OnRemove()
    ST_END_INTERCOM(self)
end

util.AddNetworkString("IntercomActive")

hook.Add("PlayerCanHearPlayersVoice", "IntercomEnt", function(listener, talker)
    if talker.IntercomUser then
        net.Start("IntercomActive")
        net.Broadcast()
        if listener ~= talker then
            -- CHECK IF LISTNER IS NOT IN OUTER SPACE (XEN)
            if listener:GetNWString("location") == "Xen" then return false end
            -- show in the middle of the player's screen that an intercom is being used
            return true 
        end
    end
end)