HLOF_DISPLACER_TELEPORT_LOCATIONS = {
    ["Facility"] = { -- from Xen
        Vector(-2928.234131, -768.603577, -101.800171),
        Vector(-6076.7802734375, 410.66076660156, -301.04675292969),
        Vector(-5023.894531, -2845.524658, -1108.968750),
        Vector(448.82870483398, -4895.6201171875, -252.96875),
        Vector(4423.4877929688, -2821.3286132812, -239.96875),
        Vector(3967.0922851562, -786.65826416016, -239.96875),
        Vector(1401.9086914062, -1639.3380126953, -377.96875),
        Vector(-8804.771484, -1040.978760, -134.335068),
        Vector(-11418.10546875, -1047.4189453125, -248.96875),
        Vector(-10538.905273438, -1044.9074707031, -252.96875),
        Vector(-5869.8725585938, -1522.8991699219, 562.03125),
        Vector(-4723.6274414062, -597.99963378906, 592.03125),
        Vector(-7543.9711914062, -1895.3988037109, 569.94403076172),
        Vector(-6902.2236328125, -223.12557983398, -252.96875),
        Vector(-2972.4709472656, -186.48098754883, 576.03125),
        Vector(-9099.015625, -1646.5963134766, 2322.03125),
        Vector(-10370.428710938, -362.93124389648, 570.03125),
    },
    ["Xen"] = { -- from Facility
        Vector(-10173.008789, -7369.780762, -1358.480591),
        Vector(-10869.288086, -8076.114746, -2234.289063),
        Vector(-8681.105469, -7709.875488, -2327.111816),
        Vector(-8556.010742, -7929.621582, -2619.783691),
        Vector(-5371.3989257812, -10861.131835938, -2847.96875),
        Vector(-5488.208984, -7995.393555, -1536.825806),
        Vector(-5464.517578125, -5889.8505859375, -1113.96875),
        Vector(-5461.865234375, -11433.15625, -5.96875),
        Vector(-3277.7282714844, -10705.227539062, 162.03125),
        Vector(-5251.6577148438, -9891.5283203125, 258.03125),
    },
}

HLOF_DISPLACER_TRAM_CHANCE = 10
HLOF_DISPLACER_TRAMS = {
    ["rp_bmrf_wf"] = {
        {
            "bmrf_tramnumerouno",
            {
                {-999, 355.02233886719},
                {130, -60.96875},
            },
        },
        {
            "bmrf_tramnumerodeux",
            {
                {-999, 355.02233886719},
                {130, -60.96875},
            }
        },
    },
    ["rp_sectorc_beta_wf"] = {
        {
            "train",
            {
                {-999, -240.0546875},
            }
        }
    }
}

// Displacer Cannon

sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Single",
channel = CHAN_WEAPON,
volume = VOL_NORM,
soundlevel = SNDLVL_GUNFIRE,
sound = "hlof/weapons/displacer_fire.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Double",
channel = CHAN_WEAPON,
volume = VOL_NORM,
soundlevel = SNDLVL_GUNFIRE,
sound = "hlof/weapons/displacer_self.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Spin",
channel = CHAN_WEAPON,
volume = VOL_NORM,
soundlevel = SNDLVL_NORM,
sound = "hlof/weapons/displacer_spin.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Spin2",
channel = CHAN_WEAPON,
volume = VOL_NORM,
soundlevel = SNDLVL_NORM,
sound = "hlof/weapons/displacer_spin2.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Impact",
channel = CHAN_WEAPON,
volume = VOL_NORM,
soundlevel = SNDLVL_NORM,
sound = "hlof/weapons/displacer_impact.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Teleport",
channel = CHAN_ITEM,
volume = VOL_NORM,
soundlevel = SNDLVL_NORM,
sound = "hlof/weapons/displacer_teleport.wav"
} )
sound.Add(
{
name = "Weapon_HLOF_Displacer_Cannon.Teleport_Player",
channel = CHAN_ITEM,
volume = VOL_NORM,
soundlevel = SNDLVL_NORM,
sound = "hlof/weapons/displacer_teleport_player.wav"
} )
