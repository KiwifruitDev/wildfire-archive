// Wildfire Black Mesa Roleplay
// File description: BMRP client-side testing entity script
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

include("shared.lua")

function ENT:Draw()

    self:DrawModel()

end
function ENT:Think()
    if IsValid(self:GetFlare()) then
        local dlight = DynamicLight(self:EntIndex())
        if ( dlight ) then
            dlight.pos = self:GetPos() + self:GetUp() * 18
            dlight.r = 255
            dlight.g = 0
            dlight.b = 0
            dlight.brightness = 2
            dlight.Decay = 1000
            dlight.Size = 256
            dlight.Style = 0 --4
            dlight.DieTime = CurTime() + 1
        end
    end
end