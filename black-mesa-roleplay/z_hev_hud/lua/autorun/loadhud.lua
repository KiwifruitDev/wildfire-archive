if SERVER then
    AddCSLuaFile('half_hud/halfhud_main/halfhud_main.lua')
    AddCSLuaFile('half_hud/halfhud_settings.lua')
else
    include('half_hud/halfhud_main/halfhud_main.lua')
    include('half_hud/halfhud_settings.lua')
end
