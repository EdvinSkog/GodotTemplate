extends Node

# Global player-related stuff is put here

signal active_changed(active: bool)

var aiming_target # For aim_controller

# Movement
var _allow_move: bool = true

func set_player_active(option: bool): # Disable movement/input etc.
	_allow_move = option
	emit_signal("active_changed", option)
