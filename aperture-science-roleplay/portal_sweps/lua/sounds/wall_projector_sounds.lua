--[[

	WALL PROJECTOR SOUNDS
	
]]

AddCSLuaFile()

local wallProjectorFootsteps =
{
	channel	= CHAN_WEAPON,
	name	= "TA:WallProjectorFootsteps",
	level	= 70,
	sound	= { "player/footsteps/fs_fm_lightbridge_01.wav" 
		, "player/footsteps/fs_fm_lightbridge_02.wav" 
		, "player/footsteps/fs_fm_lightbridge_03.wav" 
		, "player/footsteps/fs_fm_lightbridge_04.wav" 
		, "player/footsteps/fs_fm_lightbridge_05.wav" 
		, "player/footsteps/fs_fm_lightbridge_06.wav" 
		, "player/footsteps/fs_fm_lightbridge_07.wav" 
		, "player/footsteps/fs_fm_lightbridge_08.wav" 
		, "player/footsteps/fs_fm_lightbridge_09.wav" 
		, "player/footsteps/fs_fm_lightbridge_10.wav" 
	},
	volume	= 1.0,
	pitch	= 100,
}
sound.Add(wallProjectorFootsteps)

local wallEmiterEnabledNoises =
{
	channel	= CHAN_WEAPON,
	name	= "TA:WallEmiterEnabledNoises",
	level	= 70,
	sound	= "bridge/bridge_glow_lp_01.wav",
	volume	= 0.5,
	pitch	= 100,
}
sound.Add(wallEmiterEnabledNoises)

local wallEmiterEnabledAmb =
{
	channel	= CHAN_BODY,
	name	= "TA:WallEmiterEnabledAmb",
	level	= 70,
	sound	= "bridge/sp_a2_bridge_the_gap_lbout.wav",
	volume	= 0.3,
	pitch	= 100,
}
sound.Add(wallEmiterEnabledAmb)