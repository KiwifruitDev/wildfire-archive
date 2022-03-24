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

ENT.PrintName = "Xen Crystal"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "CrystalType", {
        KeyName = "crystaltype",
        Edit = {
            type = "Generic",
            category = "Crystal",
            default = "White",
        },
    })
    self:NetworkVar("String", 1, "CrystalEffect", {
        KeyName = "crystaleffect",
        Edit = {
            type = "Generic",
            category = "Crystal",
            default = "Default",
        },
    })
    self:NetworkVar("Int", 2, "CrystalResonance", {
        KeyName = "crystalresonance",
        Edit = {
            type = "Int",
            category = "Crystal", 
            min = 0,
            max = 100,
            default = 0,
        },
    })
    self:NetworkVar("Int", 3, "CrystalAMSPowerLevel", {
        KeyName = "crystalamspowerlevel",
        Edit = {
            type = "Int",
            category = "Crystal",
            min = 0,
            max = 100,
            default = 0,
        },
    })
    self:NetworkVar("Bool", 4, "CrystalScanned", {
        KeyName = "crystalscanned",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    self:NetworkVar("Bool", 5, "AnalyzerScanned", {
        KeyName = "analyzerscanned",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    self:NetworkVar("Bool", 6, "Debounce", {
        KeyName = "debounce",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    self:NetworkVar("Bool", 7, "ScanDebounce", {
        KeyName = "scandebounce",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    self:NetworkVar("Bool", 8, "Clean", {
        KeyName = "clean",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    self:NetworkVar("Bool", 9, "AMSTested", {
        KeyName = "amstested",
        Edit = {
            type = "Boolean",
            category = "Crystal",
            default = false,
        },
    })
    if SERVER then
        self:SetCrystalType("White") // white will never be used but It's default
        self:SetCrystalEffect("Default") // default no effect
        self:SetCrystalResonance(0)
        self:SetCrystalAMSPowerLevel(0)
        self:SetCrystalScanned(false)
        self:SetAnalyzerScanned(false)
        self:SetDebounce(false)
        self:SetScanDebounce(false)
        self:SetClean(false)
        self:SetAMSTested(false)
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

    {"Cyan", Color(0, 255, 255, 255), "Armor", 2},

    {"Yellow", Color(255, 255, 0, 255), "Default", 1},

    {"Black", Color(0, 0, 0, 255), "Default", 1},

    {"Pink", Color(255, 105, 180, 255), "Health", 2},

    -- UNABLE TO BE SPAWNED BEYOND THIS POINT (SEE CrystalTypeLimit)

    {"White", Color(255, 255, 255, 255), "Default", 1},

    {"Rainbow", Color(255, 255, 255, 255), "Rainbow", 5},
}

