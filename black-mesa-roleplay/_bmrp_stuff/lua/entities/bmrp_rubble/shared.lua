// Wildfire Black Mesa Roleplay
// File description: BMRP shared rubble entity script
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

ENT.PrintName = "Cascade Rubble"
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "RubbleHealth", {
        KeyName = "rubble_health",
        Edit = {
            type = "Int",
            order = 1,
            min = 0,
            max = 600,
            category = "Rubble"
        }
    })
    self:NetworkVar("Bool", 1, "Destroyed", {
        KeyName = "destroyed",
        Edit = {
            type = "Boolean",
            order = 2,
            category = "Rubble"
        }
    })
    self:NetworkVar("Bool", 2, "Visible", {
        KeyName = "visible",
        Edit = {
            type = "Boolean",
            order = 3,
            category = "Rubble"
        }
    })
    self:NetworkVar("String", 3, "RubbleModel", {
        KeyName = "model",
        Edit = {
            type = "String",
            order = 4,
            category = "Rubble"
        }
    })
    if SERVER then
        self:SetRubbleHealth(600)
        self:SetDestroyed(false)
        self:SetVisible(false)
        self:SetRubbleModel("")
    end
end