extends Node

# Global player-related stuff

signal pressed_debug(idx: int)

## Reference to Player node
var fpc: FirstPersonController

#WARNING: Potential performance problems
func _input(event: InputEvent) -> void:
	for number in range(1, 13):
		var text: String = "debug_"
		text += str(number)
		if event.is_action_pressed(text):
			call_debug_action(number)

func call_debug_action(idx: int) -> void:
	match idx:
		1:
			pass
		12:
			pass
	pressed_debug.emit(idx)
