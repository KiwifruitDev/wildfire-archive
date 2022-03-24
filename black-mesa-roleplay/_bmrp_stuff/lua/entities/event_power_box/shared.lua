// Wildfire Black Mesa Roleplay
// File description: BMRP shared power box entity script
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

ENT.PrintName = "Event Power Box"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "MaxNeeded", {
        KeyName = "maxneeded",
        Edit = {
            type = "Int",
            order = 1,
            min = 0,
            max = 255,
            category = "Power"
        }
    })
    self:NetworkVar("Bool", 1, "Activated", {
        KeyName = "activated",
        Edit = {
            type = "Boolean",
            order = 2,
            category = "Power"
        }
    })
    if SERVER then
        self:SetMaxNeeded(4)
        self:SetActivated(true)
    end
end