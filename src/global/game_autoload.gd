@icon("res://assets/icons/godot_skull.png")
extends Node

var game_time: float = 0

# References
@onready var data: DataManager = %DataManager

func _ready() -> void:
	pass

func _on_timer_second_timeout():
	game_time += 1
