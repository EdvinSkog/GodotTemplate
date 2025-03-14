extends Node

var game_time: float = 0

# References
var current_dialogue_balloon: DialogueBalloon

func _on_timer_second_timeout():
	game_time += 1
