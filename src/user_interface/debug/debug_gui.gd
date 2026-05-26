extends Control


@export var enable_debug_ui: bool = false

func _ready() -> void:
	if(enable_debug_ui):
		visible = true
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
