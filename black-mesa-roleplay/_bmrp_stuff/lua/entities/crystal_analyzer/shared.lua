// Wildfire Black Mesa Roleplay
// File description: BMRP shared crystal analyzer entity script
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

ENT.PrintName = "Crystal Analyzer" 
ENT.Category = "Wildfire BMRP"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.IsConnectable = true

ENT.WireDebugName = ENT.PrintName

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "HasCrystal")
    self:NetworkVar("Bool", 1, "IsScanning")
    self:NetworkVar("Bool", 2, "Debounce")
    self:NetworkVar("Bool", 3, "Broken")
    if SERVER then
        self:SetHasCrystal(false)
        self:SetIsScanning(false)
        self:SetDebounce(false)
        self:SetBroken(false)
    end
end

