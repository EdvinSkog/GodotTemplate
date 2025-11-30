class_name PauseHandler extends Handler


func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		if get_tree().paused:
			get_tree().paused = false
			owner.unpause()
		else:
			get_tree().paused = true
			owner.pause()
