@icon("res://assets/icons/godot_skull.png")
extends Node

@export_group("Node References")
@export var save: SaveManager
@export var settings: SettingsManager

var game_time: float = 0

func _process(_delta: float) -> void:
	game_time = get_seconds_passed()


## Returns time passed after engine started with two decimals.
func get_seconds_passed() -> float:
	var _time: float = Time.get_ticks_msec() as float
	_time /= 10
	_time = roundf(_time)
	_time /= 100
	return _time
