@icon("res://assets/icons/godot_skull.png")
extends Node

@export_group("References")
@export var save: SaveManager
@export var settings: SettingsManager
@export var ref_data: DataHandler

var game_time: float = 0

func _ready() -> void:
	pass

func _on_timer_second_timeout():
	game_time += 1
