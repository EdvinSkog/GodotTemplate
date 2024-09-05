extends Node

var game_time: float = 0
var current_dialogue_balloon

func _on_timer_second_timeout():
	game_time += 1
