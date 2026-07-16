extends Control


func _ready() -> void:
	_toggle_pause_handler.call_deferred(false)


func _on_tree_exited() -> void:
	if is_queued_for_deletion():
		_toggle_pause_handler(true)


func _on_title_screen_settings_pressed() -> void:
	%Settings.show()


func _on_settings_returned() -> void:
	%TitleScreen.show()




func _toggle_pause_handler(option: bool) -> void:
	Scene.pause_screen.handler.enabled = option
