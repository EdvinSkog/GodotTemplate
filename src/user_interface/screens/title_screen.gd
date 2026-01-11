extends Control

signal started_pressed
signal settings_pressed

func _on_button_start_pressed() -> void:
	Scene.load.load_scene_path("res://src/maps/test_level.tscn")
	started_pressed.emit()


func _on_button_settings_pressed() -> void:
	settings_pressed.emit()
