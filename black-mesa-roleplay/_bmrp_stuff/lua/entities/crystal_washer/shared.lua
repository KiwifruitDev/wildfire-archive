// Wildfire Black Mesa Roleplay
// File description: BMRP shared crystal washer entity script
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

ENT.PrintName = "Crystal Washer" // Change this!
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.IsConnectable = true

ENT.WireDebugName = ENT.PrintName

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "HasCrystal")
    self:NetworkVar("Bool", 1, "IsWashing")
    self:NetworkVar("Bool", 2, "Debounce")
    self:NetworkVar("Bool", 3, "Broken")
    self:NetworkVar("Float", 4, "Progress")
    if SERVER then
        self:SetHasCrystal(false)
        self:SetIsWashing(false)
        self:SetDebounce(false)
        self:SetBroken(false)
        self:SetProgress(0)
    end
end

