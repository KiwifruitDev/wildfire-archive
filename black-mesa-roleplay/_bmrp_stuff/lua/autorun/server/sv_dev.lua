// Wildfire Black Mesa Roleplay
// File description: BMRP developer functionality script
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

// DEVELOPER FUNCTIONS/COMMANDS, ONLY WORKS IF YOU ARE SET IN THE TABLE //
// Force a payday upon yourself.
concommand.Add("dev_payday", function(ply)
    if not ply:IsDeveloper() then return end
    if not IsValid(ply) then return end
    if ply:IsDeveloper() then
        ply:payDay()
    end
end)
// Forces yourself into a spectator mode/un-spectator mode.
concommand.Add("dev_roam", function(ply, cmd, args)
    if ply:IsDeveloper() then
        if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
            ply:Spectate(OBS_MODE_ROAMING) // This makes the player a spectator.
        else
            ply:UnSpectate() // This makes the player a player.
        end
    end
end)
// Force teleport yourself to a known Map Creation ID.
concommand.Add("dev_gotomcid", function( ply, cmd, args )
    if not ply:IsDeveloper() then return end
    if IsValid(ply) then
        if args[1] ~= nil then
            local mcid = args[1]
            local ent = ents.GetMapCreatedEntity(mcid)
            if IsValid(ent) then
                ply:SetPos(ent:GetPos())
                ply:ChatPrint("Teleporting to "..mcid.."...")
            else
                ply:ChatPrint("Invalid entity! "..mcid)
            end
        end
    end
end)
// RESETS EVERY SINGLE DOOR IN THE MAP TO UNOWNABLE. BE CAUTIOUS.
concommand.Add("dev_resetdoors", function(ply, cmd, args)
    if not ply:IsDeveloper() then return end
    local doors = ents.FindByClass("func_door")
    local doors2 = ents.FindByClass("func_door_rotating")
    local alldoors = {}
    table.Add(alldoors, doors)
    table.Add(alldoors, doors2)
    for k,v in pairs(alldoors) do
        if IsValid(v:getDoorOwner()) then
            v:keysUnOwn(v:getDoorOwner())
        end
        v:setKeysNonOwnable(true)
        v:removeAllKeysExtraOwners()
        v:removeAllKeysAllowedToOwn()
        v:removeAllKeysDoorTeams()
        v:setDoorGroup(nil)
        v:setKeysTitle(nil)
        DarkRP.storeDoorData(v)
        DarkRP.storeDoorGroup(v, nil)
        DarkRP.storeTeamDoorOwnability(v)
    end
    hook.Run("SystemMessage", v, "", "Doors have been reset.")
end)
// Displays every piece of entity info for whatever you're looking at.
concommand.Add("dev_entinfo", function( ply, cmd, args )
    if not ply:IsDeveloper() then return end
    if IsValid(ply) then
        local eyetrace = ply:GetEyeTrace()
        if eyetrace ~= nil then
            if eyetrace.Entity ~= nil then
                ply:ChatPrint("Name: "..eyetrace.Entity:GetName())
                ply:ChatPrint("Classname: "..eyetrace.Entity:GetClass())
                ply:ChatPrint("Model: "..eyetrace.Entity:GetModel())
                ply:ChatPrint("Map Creation ID: "..eyetrace.Entity:MapCreationID())
                local pos = eyetrace.Entity:GetPos()
                ply:ChatPrint("Position: "..pos.x..", "..pos.y..", "..pos.z)
                local ang = eyetrace.Entity:GetAngles()
                ply:ChatPrint("Angle: "..ang.p..", "..ang.y..", "..ang.r)
                local hit = eyetrace.HitPos
                ply:ChatPrint("Hit Position: "..hit.x..", "..hit.y..", "..hit.z)
                local normal = eyetrace.HitNormal
                ply:ChatPrint("Normal: "..normal.x..", "..normal.y..", "..normal.z)
            end
        end
    end
end)
// Gets all entities in range of you.
concommand.Add("dev_getents", function( ply, cmd, args )
    if not ply:IsDeveloper() then return end
    if IsValid(ply) then
        local eyetrace = ply:GetEyeTrace()
        if eyetrace ~= nil then
            if eyetrace.Entity ~= nil then
                local ent = eyetrace.Entity
                local ents = ents.FindInSphere(ent:GetPos(), 100)
                for k,v in pairs(ents) do
                    if IsValid(v) then
                        ply:ChatPrint("Name: "..v:GetName())
                        ply:ChatPrint("Classname: "..v:GetClass())
                        ply:ChatPrint("Map Creation ID: "..v:MapCreationID())
                    end
                end
            end
        end
    end
end)
// Force sets your first position for the bounds tool.
concommand.Add( "dev_pos1", function( ply, cmd, args )
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    wep:SetStartPos(ply:EyePos())
end)
// Force sets your second position for the bounds tool.
concommand.Add( "dev_pos2", function( ply, cmd, args )
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    wep:SetManual(true)
    local ent = wep:GetBoundingBox()
    if not IsValid(ent) then return end
    local shootpos = ply:EyePos()
    local startpos = wep:GetStartPos()
    ent:SetCollisionBoundsWS(startpos, shootpos)
end)
// Teleport yourself to certain Vectors on the map.
// usage: dev_goto <vector> <vector> <vector>
concommand.Add("dev_goto", function( ply, cmd, args )
    if not ply:IsDeveloper() then return end
    if !IsValid( ply ) then return end
    if !ply:IsPlayer() then return end
    if !ply:Alive() then return end
    local pos = Vector(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0)
    ply:SetPos(pos)
end)
// Used to select a Staff door.
concommand.Add("door_select", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsDeveloper() then return end
	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) then return end
    if ent:GetClass() ~= "lab_door" then
        ply:ChatPrint("That is not a valid door!")
        return
    end
	ply:SetNWEntity("SelectedDoor", ent)
	ply:ChatPrint("Selected targetted door...")
end)
// Used to clear a staff door.
concommand.Add("door_clear", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsDeveloper() then return end
	ply:SetNWEntity("SelectedDoor", Entity(1))
	ply:ChatPrint("Unselected any targetted doors!")
end)
// Used to set the position of a staff door.
concommand.Add("door_setpos", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsDeveloper() then return end
	local ent = ply:GetNWEntity("SelectedDoor")
	if not IsValid(ent) then
		ply:ChatPrint("No door selected!")
		return
	end
	local pos = ply:GetPos()
	local ang = ply:GetAngles()
	ent:SetTeleportEnt(pos)
	ent:SetTeleportEnt2(ang)
	ply:ChatPrint("Set position of selected door to "..pos.x.." "..pos.y.." "..pos.z.." ".." and angles to "..ang.p.." "..ang.y.." "..ang.r)
end)
// Used to create an entity without sv_cheats
concommand.Add("dev_create", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsDeveloper() then return end
	local enti = ents.Create(args[1])
    if not IsValid(enti) then return end
    enti:SetPos(ply:GetEyeTrace().HitPos)
    enti:Spawn()
    enti:Activate()
    --enti:CPPISetOwner(ply)
    DarkRP.notify(ply, 0, 4, "Created "..enti:GetClass())
end)
// create prop_physics
concommand.Add("dev_prop", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local enti = ents.Create("prop_physics")
    if not IsValid(enti) then return end
    enti:SetPos(ply:GetEyeTrace().HitPos)
    enti:SetModel(args[1] or "models/helios/foilage/pine.mdl")
    enti:Spawn()
    enti:Activate()
    --enti:CPPISetOwner(ply)
    DarkRP.notify(ply, 0, 4, "Created "..enti:GetClass())
end)
// Used to get the keyvalues of an entity classname
concommand.Add("dev_kv", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    for k,v in pairs(ents.FindByClass(args[1])) do
        if v.ClassName == args[1] then
            PrintTable(v:GetKeyValues())
        end
    end
    ply:ChatPrint("Printed keyvalues of "..args[1]..".")
end)
// Used to show rubble without activating a cascade
concommand.Add("dev_rubble", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    for k,v in pairs(ents.FindByClass("bmrp_rubble")) do
        v:Fire("Visualize")
        v:Fire("Reset")
    end
end)
// Used to drop an entity to the floor
concommand.Add("dev_drop", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    ent:DropToFloor()
end)
// Give yourself an HEV suit
concommand.Add("dev_hev", function(ent, cmd, args)
    if not IsValid(ent) then return end
    if not ent:IsDeveloper() then return end
    if ent:GetModel() == "models/motorhead/hevscientist.mdl" then
        ent:RemoveSuit()
        local lgm = ent:GetNWString("LastGoodModel")
        if lgm == "" or lgm == nil then
            local jobtable = ent:getJobTable()
            lgm = jobtable.model
        end
        ent:SetModel(lgm)
        ent:SetNWString("LastGoodModel","")
        DarkRP.notify(ent, 0, 4, "[DEV] Removed HEV suit.")
    else
        ent:SetNWString("LastGoodModel",ent:GetModel())
        ent:SetModel("models/motorhead/hevscientist.mdl")
        ent:EquipSuit()
        DarkRP.notify(ent, 0, 4, "[DEV] Equipped HEV suit.")
    end
end)
// Suck everyone into lambda core
concommand.Add("dev_lambda", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    SetGlobalBool("SuckEveryoneIntoLambdaCore", not GetGlobalBool("SuckEveryoneIntoLambdaCore"))
    if GetGlobalBool("SuckEveryoneIntoLambdaCore") then
        DarkRP.notify(ply, 0, 4, "[DEV] Everyone is now being sucked into the Lambda Core.")
    else
        DarkRP.notify(ply, 0, 4, "[DEV] Everyone is no longer being sucked into the Lambda Core.")
    end
end)
// unparent entity you're looking at
concommand.Add("dev_unparent", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    ent:SetParent(nil)
    -- take ownership
    ent:CPPISetOwner(ply)
end)
// clean crystal in front of you
concommand.Add("dev_clean", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    if not ent.Clean then return end
    ent:Clean()
end)

// clean crystal in front of you
concommand.Add("dev_fix", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    if not ent.SetBroken then return end
    ent:SetBroken(false)
end)
// This turns off the lights without triggering any other event.
concommand.Add("dev_lightsoff", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    LightsOff()
end)
// This turns on the lights without triggering any other event.
concommand.Add("dev_lightson", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    LightsOn()
end)
// cycle crystal type
concommand.Add("dev_cycle", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    if not ent:GetClass() == "xen_crystal" then return end
    if not ent.CrystalTypes then return end
    local type = ent:GetCrystalType()
    for k,v in pairs(ent.CrystalTypes) do
        local typetable
        if k >= #ent.CrystalTypes then
            typetable = ent.CrystalTypes[1]
        elseif v[1] == type then
            typetable = ent.CrystalTypes[k+1]
        end
        if typetable then
            ent:PhysicsInit(SOLID_VPHYSICS)
            ent:SetRenderMode(RENDERMODE_NORMAL)
            ent:SetRenderFX(kRenderFxNone)
            ent:SetCrystalType(typetable[1])
            ent:SetCrystalEffect(typetable[3])
            ent:SetColor(typetable[2])
            break
        end
    end
    DarkRP.notify(ply, 0, 4, "[DEV] Crystal type changed to "..ent:GetCrystalType()..".")
end)

concommand.Add("ams_check", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    ply:ChatPrint(GetGlobalBool("ams_shutdown", false) and "ams_shutdown is true" or "ams_shutdown is false")
    ply:ChatPrint(GetGlobalBool("ams_open", false) and "ams_open is true" or "ams_open is false")
    ply:ChatPrint(GetGlobalBool("AMSLaserPoll", false) and "AMSLaserPoll is true" or "AMSLaserPoll is false")
    ply:ChatPrint(GetGlobalBool("ResonanceCascade", false) and "ResonanceCascade is true" or "ResonanceCascade is false")
end)

// ent_fire basically
concommand.Add("dev_fire", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    ent:Fire(args[1])
end)

-- for k, v in pairs(ents.FindByClass("squidspit")) do v:Remove() end

concommand.Add("server_restartwarning", function(ply, cmd, args)
    if IsValid(ply) then return end -- only run from server
    local newdelay = tonumber(args[1]) or 1800 -- 30 minutes
    for k, v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "The server is restarting in "..newdelay.." seconds.")
        v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
    end
    timer.Simple(newdelay-600, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 10 minutes...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-300, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 5 minutes...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-60, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 1 minute...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-30, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 30 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-10, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 10 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-5, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Restarting in the server in 5 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay, function()
        timer.Remove("RestartNukeTimer")
        SetGlobalString("NukeText", "")
        SetGlobalBool("NukeEvent", false)
    end)
    timer.Create("RestartNukeTimer", 1/(1 / engine.TickInterval()), newdelay*(1 / engine.TickInterval()), function()
        newdelay = newdelay - 1/(1 / engine.TickInterval())
        SetGlobalInt("NukeTimer", newdelay)
    end)
    SetGlobalBool("NukeEvent", true)
    SetGlobalString("NukeText", "Server Restart:")
end)

concommand.Add("server_updatewarning", function(ply, cmd, args)
    if IsValid(ply) then return end -- only run from server
    local newdelay = tonumber(args[1]) or 600 -- 10 minutes
    for k, v in pairs(player.GetAll()) do
        hook.Run("SystemMessage", v, "", "The server is changing level for a major update in "..newdelay.." seconds.")
        v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
    end
    timer.Simple(newdelay-300, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Changing level for an update in 5 minutes...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-60, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Changing level for an update in 1 minute...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-30, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Changing level for an update in 30 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-10, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Changing level for an update in 10 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay-5, function()
        for k, v in pairs(player.GetAll()) do
            hook.Run("SystemMessage", v, "", "Changing level for an update in 5 seconds...")
            v:SendLua("surface.PlaySound(\"ambient/alarms/klaxon1.wav\")")
        end
    end)
    timer.Simple(newdelay, function()
        timer.Remove("UpdateNukeTimer")
        SetGlobalString("NukeText", "")
        SetGlobalBool("NukeEvent", false)
        RunConsoleCommand("changelevel", game.GetMap())
    end)
    timer.Create("UpdateNukeTimer", 1/(1 / engine.TickInterval()), newdelay*(1 / engine.TickInterval()), function()
        newdelay = newdelay - 1/(1 / engine.TickInterval())
        SetGlobalInt("NukeTimer", newdelay)
    end)
    SetGlobalBool("NukeEvent", true)
    SetGlobalString("NukeText", "Server Update Level Change:")
end)

-- locations / bounding boxes
concommand.Add("bounds_setlocation", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    if #args < 1 then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    local ent = wep:GetBoundingBox()
    if not IsValid(ent) then 
        ent = ply:GetNWEntity("BoundingBox")
    end
    ent:SetLocation(table.concat(args, " "))
    ent:SetGeneric(false)
    DarkRP.notify(ply, 0, 4, "Location set to "..table.concat(args, " ")..".")
end)
concommand.Add("bounds_select", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    -- get entities in range (bounding_box)
    local ents = ents.FindInSphere(ply:GetPos(), 1000)
    for k, v in pairs(ents) do
        if LocalToWorld(v:OBBCenter(), Angle(0,0,0), v:GetPos(), Angle(0,0,0)):Distance(ply:EyePos()) <= 100 then
            if v:GetClass() == "bounding_box" then
                ply:SetNWEntity("BoundingBox", v)
                DarkRP.notify(ply, 0, 4, "Bounding box selected. "..v:GetLocation())
                return
            end
        end
    end
end)
concommand.Add("bounds_staff", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    local ent = wep:GetBoundingBox()
    if not IsValid(ent) then
        ent = ply:GetNWEntity("BoundingBox")
    end
    ent:SetStaff(ent:GetStaff() == true and false or true)
    DarkRP.notify(ply, 0, 4, ent:GetStaff() and "Staff check set to true." or "Staff check set to false.")
end)
concommand.Add("bounds_save", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    if not PermaProps then DarkRP.notify(ply, 1, 4, "ERROR: Lib not found" ) return end
    for k, ent in pairs(ents.FindByClass("bounding_box")) do
        if not IsValid(ent) then continue end
        local mins, maxs = ent:WorldSpaceAABB()
        ent:SetBoundsPos1X(mins.x)
        ent:SetBoundsPos1Y(mins.y)
        ent:SetBoundsPos1Z(mins.z)
        ent:SetBoundsPos2X(maxs.x)
        ent:SetBoundsPos2Y(maxs.y)
        ent:SetBoundsPos2Z(maxs.z)
        // permaprops API
        if ent.PermaProps then continue end
        mins, maxs = ent:GetCollisionBounds()
        local content = PermaProps.PPGetEntTable(ent)
        if not content then continue end
        local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;"))
        if not max then max = 1 else max = max + 1 end
        local new_ent = PermaProps.PPEntityFromTable(content, max)
        if !new_ent or !new_ent:IsValid() then continue end
        PermaProps.SparksEffect( ent )
        PermaProps.SQL.Query("INSERT INTO permaprops (id, map, content) VALUES(NULL, ".. sql.SQLStr(game.GetMap()) ..", ".. sql.SQLStr(util.TableToJSON(content)) ..");")
        DarkRP.notify(ply, 0, 4, "Bounding box saved via PermaProps.")
        ent:Remove()
        new_ent:SetCollisionBounds(mins, maxs)
    end
end)
concommand.Add("bounds_delete", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    local ent = wep:GetBoundingBox()
    if not IsValid(ent) then
        ent = ply:GetNWEntity("BoundingBox")
    end
    // permaprops API
    if not PermaProps then DarkRP.notify(ply, 1, 4, "ERROR: Lib not found" ) return end
    if not ent.PermaProps then ply:ChatPrint( "That is not a PermaProp!" ) return end
    if not ent.PermaProps_ID then ply:ChatPrint( "ERROR: ID not found" ) return end
    PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = ".. ent.PermaProps_ID ..";")
    DarkRP.notify(ply, 0, 4, "Bounding box deleted via PermaProps.")
    ent:Remove()
end)
--[[
concommand.Add("bounds_deleteall", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    for k, ent in pairs(ents.FindByClass("bounding_box")) do
        if not IsValid(ent) then continue end
        // permaprops API
        if not PermaProps then continue end
        if not ent.PermaProps then continue end
        if not ent.PermaProps_ID then continue end
        PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = ".. ent.PermaProps_ID ..";")
        ent:Remove()
    end
    DarkRP.notify(ply, 0, 4, "All Bounding boxes deleted via PermaProps.")
end)
]]--
-- priority
concommand.Add("bounds_priority", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_bounds" then return end
    local ent = wep:GetBoundingBox()
    if not IsValid(ent) then
        ent = ply:GetNWEntity("BoundingBox")
    end
    ent:SetPriority(tonumber(args[1]) or 0)
    DarkRP.notify(ply, 0, 4, "Priority set to "..args[1]..".")
end)
-- get every wire convar (sbox_max*) and set them to 0 //
local wireconvars = {
    "sbox_maxwire_deployers",
    "sbox_maxwire_wheels",
    "sbox_maxwire_weights",
    "sbox_maxwire_waypoints",
    "sbox_maxwire_watersensors",
    "sbox_maxwire_vectorthrusters",
    "sbox_maxwire_vehicles",
    "sbox_maxwire_values",
    "sbox_maxwire_users",
    "sbox_maxwire_twoway_radios",
    "sbox_maxwire_turrets",
    "sbox_maxwire_triggers",
    "sbox_maxwire_trails",
    "sbox_maxwire_thrusters",
    "sbox_maxwire_textscreens",
    "sbox_maxwire_textreceivers",
    "sbox_maxwire_textentrys",
    "sbox_maxwire_teleporters",
    "sbox_maxwire_target_finders",
    "sbox_maxwire_spus",
    "sbox_maxwire_speedometers",
    "sbox_maxwire_spawners",
    "sbox_maxwire_soundemitters",
    "sbox_maxwire_simple_explosives",
    "sbox_maxwire_sensors",
    "sbox_maxwire_screens",
    "sbox_maxwire_relays",
    "sbox_maxwire_rangers",
    "sbox_maxwire_radios",
    "sbox_maxwire_pods",
    "sbox_maxwire_sockets",
    "sbox_maxwire_plugs",
    "sbox_maxwire_pixels",
    "sbox_maxwire_outputs",
    "sbox_maxwire_oscilloscopes",
    "sbox_maxwire_numpads",
    "sbox_maxwire_nailers",
    "sbox_maxwire_motors",
    "sbox_maxwire_locators",
    "sbox_maxwire_lights",
    "sbox_maxwire_levers",
    "sbox_maxwire_latchs",
    "sbox_maxwire_las_receivers",
    "sbox_maxwire_lamps",
    "sbox_maxwire_keypads",
    "sbox_maxwire_keyboards",
    "sbox_maxwire_inputs",
    "sbox_maxwire_indicators",
    "sbox_maxwire_igniters",
    "sbox_maxwire_hydraulics",
    "sbox_maxwire_hudindicators",
    "sbox_maxwire_hoverballs",
    "sbox_maxwire_hologrids",
    "sbox_maxwire_holoemitters",
    "sbox_maxwire_hdds",
    "sbox_maxwire_gyroscopes",
    "sbox_maxwire_graphics_tablets",
    "sbox_maxwire_grabbers",
    "sbox_maxwire_gpulib_controllers",
    "sbox_maxwire_gpus",
    "sbox_maxwire_gpss",
    "sbox_maxwire_gimbals",
    "sbox_maxwire_gates",
    "sbox_maxwire_fx_emitters",
    "sbox_maxwire_friendslists",
    "sbox_maxwire_freezers",
    "sbox_maxwire_forcers",
    "sbox_maxwire_eyepods",
    "sbox_maxwire_extbuss",
    "sbox_maxwire_expressions",
    "sbox_maxwire_explosives",
    "sbox_maxwire_exit_points",
    "sbox_maxwire_emarkers",
    "sbox_maxwire_egps",
    "sbox_maxwire_dynamic_buttons",
    "sbox_maxwire_dual_inputs",
    "sbox_maxwire_digitalscreens",
    "sbox_maxwire_dhdds",
    "sbox_maxwire_detonators",
    "sbox_maxwire_datarates",
    "sbox_maxwire_dataports",
    "sbox_maxwire_datasockets",
    "sbox_maxwire_dataplugs",
    "sbox_maxwire_data_transferers",
    "sbox_maxwire_data_stores",
    "sbox_maxwire_data_satellitedishs",
    "sbox_maxwire_damage_detectors",
    "sbox_maxwire_cpus",
    "sbox_maxwire_consolescreens",
    "sbox_maxwire_colorers",
    "sbox_maxwire_clutchs",
    "sbox_maxwire_cd_locks",
    "sbox_maxwire_cd_rays",
    "sbox_maxwire_cd_disks",
    "sbox_maxwire_cameracontrollers",
    "sbox_maxwire_buttons",
    "sbox_maxwire_adv_inputs",
    "sbox_maxwire_adv_emarkers",
    "sbox_maxwire_addressbuss",
}
concommand.Add("dev_doublewireconvars", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    for k,v in pairs(wireconvars) do
        local cvar = GetConVar(v)
        if cvar then
            cvar:SetInt(cvar:GetInt() * 2)
            ply:ChatPrint(v.." \""..cvar:GetInt().."\"")
        end
    end
end)
-- name entity in front of player
concommand.Add("dev_name", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end
    local ent = tr.Entity
    if not IsValid(ent) then return end
    ent:SetName(args[1])
end)

function byedoor(ent, ply)
    if not IsValid(ent) then return false end
    if ent:GetClass() ~= "func_door" and ent:GetClass() ~= "func_door_rotating" then return false end
    ent:SetSolid(SOLID_NONE)
    ent:SetNoDraw(true)
    ent:Fire("Disable")
    local newphysprop = ents.Create("prop_physics")
    newphysprop:SetModel(ent:GetModel())
    newphysprop:SetPos(ent:GetPos())
    newphysprop:SetAngles(ent:GetAngles())
    newphysprop:Spawn()
    newphysprop:PhysicsInit(SOLID_VPHYSICS)
    newphysprop:CPPISetOwner(ply)
    local phys = newphysprop:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetForward() * -1000)
    end
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(ent:GetPos())
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "0")
    explosion:Fire("Explode", 0, 0)
    timer.Simple(10, function()
        if IsValid(newphysprop) then
            newphysprop:Remove()
        end
        if IsValid(ent) then
            ent:SetSolid(SOLID_BSP)
            ent:SetNoDraw(false)
            ent:Fire("Enable")
        end
    end)
    return true
end

-- BLOW UP THE DOOR IN FRONT OF YOU
concommand.Add("dev_byedoor", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsDeveloper() then return end
    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end
    local done = false
    for _, ent in pairs(ents.FindInSphere(tr.HitPos, 150)) do
        if done == true then
            byedoor(ent, ply)
        else
            done = byedoor(ent, ply)
        end
    end
    if not done then
        if IsValid(tr.Entity) then
            byedoor(tr.Entity, ply)
        end
    end
end)
