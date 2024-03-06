extends Node

var game_time: float = 0

func _on_timer_second_timeout():
	game_time += 1
