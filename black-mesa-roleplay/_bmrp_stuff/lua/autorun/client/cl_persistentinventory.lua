// Wildfire Black Mesa Roleplay
// File description: (cl) Persistent inventory system
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

CreateConVar("bmrp_blockgifts", "0", {FCVAR_ARCHIVE}, "Block gifts from other players, only applied after a rejoin.")

hook.Add("InitPostEntity", "bmrp_blockgifts", function()
    if GetConVar("bmrp_blockgifts"):GetBool() then
        RunConsoleCommand("bmrp_set_blockgifts")
    end
end)

local inventorypanel
local inventory
local presents

local function PersistentInventoryReload(presentcount)
    if not IsValid(inventorypanel) or not inventorypanel:IsVisible() then return end
    if not inventory then inventorypanel:Close() return end
    presents = presentcount

    local itemCount = table.Count(inventory)

    inventorypanel.List:Clear()
    local i = 0
    local items = {}

    for k, v in pairs(inventory) do
        local ListItem = inventorypanel.List:Add( "DPanel" )
        ListItem:SetSize( 64, 64 )

        local icon = vgui.Create("SpawnIcon", ListItem)
        icon:SetModel(v.Model)
        icon:SetSize(64, 64)
        icon:SetTooltip(v.Description)
        icon.DoClick = function(self)
            net.Start("SpawnPersistentInventoryItem")
                net.WriteBool(v.IsPresent and true or false)
                net.WriteUInt(k - ((v.IsPresent and true or false) and itemCount - presents or 0), 32)
            net.SendToServer()
            presents = presents - 1
        end
        table.insert(items, icon)
        i = i + 1
    end
    /*
    if itemCount < #BMRP.PersistentInventory then
        for _ = 1, #BMRP.PersistentInventory - itemCount do
            local ListItem = inventorypanel.List:Add("DPanel")
            ListItem:SetSize(64, 64)
        end
    end
    */
end

local debounce = 0

hook.Add("InitPostEntity", "PocketModification", function()
    DarkRP.openOriginalPocketMenu = DarkRP.openPocketMenu
    DarkRP.openPocketMenu = function()
        DarkRP.openOriginalPocketMenu()
        if debounce > CurTime() then return end
        debounce = CurTime() + 0.5
        net.Start("GetPersistentInventoryData")
        net.SendToServer()
    end
end)

net.Receive("ReceivePersistentInventoryData", function()
    inventory = table.Copy(BMRP.PersistentInventory)
    local count = net.ReadUInt(8)
    for i = 1, count do
        -- read booleans for each items in BMRP.PersistentInventory (assumed), if they are false then delete the entries in the inventory table
        local bool = net.ReadBool()
        if not bool then
            inventory[i] = nil
        end
    end

    -- add presents to inventory
    local presentcount = net.ReadUInt(8)
    for i = 1, presentcount do
        table.insert(inventory, {
            Name = net.ReadString(),
            Description = net.ReadString(),
            Model = net.ReadString(),
            IsWeapon = false,
            IsPresent = true,
        })
    end

    if #inventory <= 0 then return end -- if the inventory is empty then don't open the inventory panel

    if IsValid(inventorypanel) then
        inventorypanel:Close()
    end

    inventorypanel = vgui.Create("DFrame")

    local count = #inventory or #BMRP.PersistentInventory
    inventorypanel:SetSize(345, 32 + 64 * math.ceil(count / 5) + 3 * math.ceil(count / 5))
    inventorypanel:SetTitle("Persistent Inventory")
    inventorypanel.btnMaxim:SetVisible(false)
    inventorypanel.btnMinim:SetVisible(false)
    inventorypanel:SetDraggable(false)
    inventorypanel:MakePopup()
    inventorypanel:Center()

    -- center horizontally but not vertically (lower half of the screen)
    inventorypanel:SetPos(ScrW() / 2 - inventorypanel:GetWide() / 2, ScrH() / 4 * 3 - inventorypanel:GetTall() / 2)

    local Scroll = vgui.Create("DScrollPanel", inventorypanel)
    Scroll:Dock(FILL)

    local sbar = Scroll:GetVBar()
    sbar:SetWide(3)
    inventorypanel.List = vgui.Create("DIconLayout", Scroll)
    inventorypanel.List:Dock(FILL)
    inventorypanel.List:SetSpaceY(3)
    inventorypanel.List:SetSpaceX(3)
    
    PersistentInventoryReload(presentcount)
end)
