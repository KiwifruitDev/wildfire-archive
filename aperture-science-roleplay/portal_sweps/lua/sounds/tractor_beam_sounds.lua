--[[

	TRACTOR BEAM SOUNDS
	
]]

AddCSLuaFile()

--------------------- Tractor Beam soundscripts ----------------------------

local tractorBeamLoop =
{
	channel	= CHAN_WEAPON,
	name	= "TA:TractorBeamLoop",
	level	= 60,
	sound	= "tbeam/tbeam_emitter_spin_lp_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(tractorBeamLoop)

local tractorBeamStart =
{
	channel	= CHAN_BODY,
	name	= "TA:TractorBeamStart",
	level	= 60,
	sound	= "tbeam/tbeam_emitter_start_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(tractorBeamStart)

local tractorBeamMiddle =
{
	channel	= CHAN_BODY,
	name	= "TA:TractorBeamMiddle",
	level	= 60,
	sound	= "tbeam/tbeam_emitter_middle_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(tractorBeamMiddle)

local tractorBeamEnd =
{
	channel	= CHAN_BODY,
	name	= "TA:TractorBeamEnd",
	level	= 60,
	sound	= "tbeam/tbeam_emitter_end_01.wav",
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(tractorBeamEnd)

local tractorBeamEnter =
{
	channel	= CHAN_BODY,
	name	= "TA:TractorBeamEnter",
	level	= 60,
	sound	= {
		"player/tbeam/player_enter_tbeam_lp_01.wav",
		"player/tbeam/player_enter_tbeam_lp_02.wav",
		"player/tbeam/player_enter_tbeam_lp_03.wav",
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(tractorBeamEnter)

local tractorBeamInside =
{
	channel	= CHAN_AUTO,
	name	= "TA:TractorBeamInside",
	level	= 59,
	sound	= {
		"player/tbeam/sp_a4_laser_platform_tbin.wav",
	},
	volume	= 0.5,
	pitch	= 100,
}
sound.Add(tractorBeamInside)

local tractorBeamloop2 =
{
	channel	= CHAN_BODY,
	name	= "TA:TractorBeamloop2",
	level	= 59,
	sound	= {
		"player/tbeam/sp_a4_tb_intro_tbin.wav",
	},
	volume	= 0.7,
	pitch	= 100,
}
sound.Add(tractorBeamloop2)


