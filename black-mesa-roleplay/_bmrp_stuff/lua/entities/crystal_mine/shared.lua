// Wildfire Black Mesa Roleplay
// File description: BMRP shared AMS cart entity script
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

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Crystal Mine"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "CrystalType")
    self:NetworkVar("String", 1, "CrystalEffect")
    self:NetworkVar("Int", 2, "CrystalMineHealth")
    self:NetworkVar("Int", 3, "CrystalRemaining")
    if SERVER then
        self:SetCrystalType("White") //Default WHITE crystal
        self:SetCrystalEffect("Default") //Default no effect
        self:SetCrystalMineHealth(325)
        self:SetCrystalRemaining(4)
    end
end

ENT.CrystalTypeLimit = 9
ENT.RainbowCrystal = 11

// Red is the type, color is the actual color of the crystal, "radioactive" is the effect the crystal gives off, and 4 is the money multiplier.
ENT.CrystalTypes = {
    {"Red", Color(255, 0, 0, 255), "Radioactive", 4},

    {"Orange", Color(255, 93, 0, 255), "Default", 1},

    {"Green", Color(102, 255, 102, 150), "ZeroGravity", 2},

    {"Purple", Color(138, 43, 226, 255), "Sickness", 3},

    {"Dark Blue", Color(29, 0, 255, 255), "Sadness", 2},

    {"Cyan", Color(0, 255, 255, 255), "Default", 1},

    {"Yellow", Color(255, 255, 0, 255), "Default", 1},

    {"Black", Color(0, 0, 0, 255), "Default", 1},

    {"Pink", Color(255, 105, 180, 255), "Default", 1},

    -- UNABLE TO BE SPAWNED BEYOND THIS POINT (SEE CrystalTypeLimit)

    {"White", Color(255, 255, 255, 255), "Default", 1},

    {"Rainbow", Color(255, 255, 255, 255), "Rainbow", 5},
}
