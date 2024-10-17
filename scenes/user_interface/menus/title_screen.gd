extends Control

func _ready() -> void:
	pass

func _on_button_start_pressed() -> void:
	SceneManager.load_scene("res://scenes/level/test_level.tscn", 1, "normal")


func _on_button_settings_pressed() -> void:
	SceneManager.load_scene("res://scenes/user_interface/menus/settings.tscn", 1, "subtle")


func _on_button_credits_pressed() -> void:
	SceneManager.load_scene("res://scenes/user_interface/menus/credits.tscn", 1, "subtle")
