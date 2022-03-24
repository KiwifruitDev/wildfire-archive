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

ENT.PrintName = "AMS Cart"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "HasCrystal", {
        KeyName = "has_crystal",
        Edit = {
            type = "Boolean",
            order = 1,
            category = "General"
        }
    })
    self:NetworkVar("Bool", 1, "InsideAMS", {
        KeyName = "inside_ams",
        Edit = {
            type = "Boolean",
            order = 2,
            category = "General"
        }
    }) // Is the AMS cart currently inside the AMS?
    self:NetworkVar("Bool", 2, "Debounce", {
        KeyName = "debounce",
        Edit = {
            type = "Boolean",
            order = 3,
            category = "General"
        }
    }) // Is the AMS cart debouncing?
    if SERVER then
        self:SetHasCrystal(false)
        self:SetInsideAMS(false)
        self:SetDebounce(false)
    end
end