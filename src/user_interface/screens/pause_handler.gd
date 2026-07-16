@icon("res://assets/icons/editor/pause.svg")
class_name PauseHandler extends Handler

var enabled: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause") and enabled:
		if get_tree().paused:
			get_tree().paused = false
			owner.unpause()
		else:
			get_tree().paused = true
			owner.pause()
