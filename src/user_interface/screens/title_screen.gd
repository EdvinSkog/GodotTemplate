extends Control

@export var map_key: StringName = &"gym"

signal started_pressed
signal settings_pressed

func _on_button_start_pressed() -> void:
	Scene.load_map(map_key)
	started_pressed.emit()


func _on_button_settings_pressed() -> void:
	settings_pressed.emit()
