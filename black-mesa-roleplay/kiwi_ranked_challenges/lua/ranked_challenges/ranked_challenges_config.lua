// Wildfire Ranked Challenges
// File description: Configuration script for ranked challenges
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

//------------------------------------------------------------------------------------------------------------//
// We are declaring some required variables here, skip past these lines if you don't understand what they do. //
//------------------------------------------------------------------------------------------------------------//

// Enumerables for the different types of challenges.
KIWI_CHALLENGE_TYPE_NONE = 0 // DO. NOT. USE. This will cause issues as it is not a challenge type.
KIWI_CHALLENGE_TYPE_RACE = 1 // Race from one point to the other.
KIWI_CHALLENGE_TYPE_CUSTOM = 2 // Scriptable challenge type.
KIWI_CHALLENGE_TYPE_SIZE = 3 // DO. NOT. USE. This is the amount of ranked challenge types and should be incremented.

// Display names for challenges.
KIWI_CHALLENGE_NAMES = {
    [KIWI_CHALLENGE_TYPE_NONE] = "None",
    [KIWI_CHALLENGE_TYPE_RACE] = "Race",
    [KIWI_CHALLENGE_TYPE_CUSTOM] = "Custom", // This can be overwritten by the custom challenge.
}

// Start the configuration section.
KIWI = {}

//------------------------------------------------------------------------//
// This is where you can configure the challenge system and its settings. //
//------------------------------------------------------------------------//

KIWI.ChallengeList = {
    ["XenRace"] = {
        name = "Xen Race",
        description = "You are teleported into Xen and must race through the alien planet to get back to Earth!",
        npcpos = Vector(-4618.9345703125, -10610.358398438, 5.9308881759644), // This is used to distance check the player to make sure that they are close enough to the NPC to start.
        npcradius = 200, // Maximum distance from the NPC to the player.
        challengetype = KIWI_CHALLENGE_TYPE_RACE, // Type of challenge routine to play.
        // Define starting positions for the player.
        startpos = Vector(-4371.303223, -10327.139648, 122.031250), // Where to teleport the player to when they start the challenge.
        startang = Angle(0,90,0), // Where to face the player when they start the challenge.
        // Define a  bounding box for to end the race.
        endcorner1 = Vector(-8571.537109, -8002.477539, -2813.643799), // Where the first corner of the end trigger is.
        endcorner2 = Vector(-8475.567383, -7903.249023, -2885.968750), // Where the second corner of the end trigger is.
        callback = nil,
        finishedcallback = function(ply)
            // Set player to xen teleport location
            //ply:SetPos(-13468.082031, 500.530823, -348.833740)
        end,
        initcallback = nil,
    },
    ["HecuCourse"] = {
        name = "H.E.C.U. Course",
        description = "Complete the H.E.C.U. training course, race to the finish!",
        npcpos = Vector(-3919.922119, -492.641388, 640.031250),
        npcradius = 200,
        challengetype = KIWI_CHALLENGE_TYPE_CUSTOM,
        startpos = Vector(-3829.197266, -601.273438, 640.031250),
        startang = Angle(0,0,0),
        endcorner1 = Vector(0,0,0),
        endcorner2 = Vector(0,0,0),
        callback = function(ply)
            // We need to remove any existing gun triggers so we can create a new one.
            local guns = ents.FindByName("hecugun_"..ply:EntIndex())
            for k,v in pairs(guns) do
                v:Remove()
            end
            // Create a new gun trigger.
            if not IsValid(ply) then return end
            local guntrigger = ents.Create("trigger_hecugun")
            guntrigger:SetName("hecugun_"..ply:EntIndex())
            guntrigger:SetNWEntity("player", ply)
            guntrigger:Spawn()
            guntrigger:Activate()
            // create the gun targets
            local gun1 = ents.Create("hecu_target")
            gun1:SetPos(Vector(-3649.9582519531, -208.24348449707, 627.68157958984))
            gun1:SetAngles(Angle(0, -90, 90))
            gun1:SetNWEntity("player", ply)
            gun1:SetName("hecutarget1_"..ply:EntIndex())
            gun1:Spawn()
            gun1:Activate()
            local gun2 = ents.Create("hecu_target")
            gun2:SetPos(Vector(-3513.9814453125, -260.87170410156, 627.00128173828))
            gun2:SetAngles(Angle(0, -90, 90))
            gun2:SetNWEntity("player", ply)
            gun2:SetName("hecutarget2_"..ply:EntIndex())
            gun2:Spawn()
            gun2:Activate()
            local gun3 = ents.Create("hecu_target")
            gun3:SetPos(Vector(-3360.3637695312, -315.16229248047, 627.16741943359))
            gun3:SetAngles(Angle(0, -90, 90))
            gun3:SetNWEntity("player", ply)
            gun3:SetName("hecutarget3_"..ply:EntIndex())
            gun3:Spawn()
            gun3:Activate()
        end,
        finishedcallback = function(ply)
            if IsValid(ply) then
                if ply:Alive() then
                    ply:StripWeapon("weapon_hecu")
                end
            end
            // Remove our gun trigger.
            local guns = ents.FindByName("hecugun_"..ply:EntIndex())
            for k,v in pairs(guns) do
                v:Remove()
            end
            // Remove our gun targets.
            local gun1 = ents.FindByName("hecutarget1_"..ply:EntIndex())
            for k,v in pairs(gun1) do
                v:Remove()
            end
            local gun2 = ents.FindByName("hecutarget2_"..ply:EntIndex())
            for k,v in pairs(gun2) do
                v:Remove()
            end
            local gun3 = ents.FindByName("hecutarget3_"..ply:EntIndex())
            for k,v in pairs(gun3) do
                v:Remove()
            end
        end,
        initcallback = function()
            local door = ents.FindByName("hecudoor")[1]
            if IsValid(door) then
                door:Fire("Lock")
            end
        end,
    },
}
