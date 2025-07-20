extends Control

func _ready() -> void:
	pass

func _on_button_start_pressed() -> void:
	SceneManager.load_manager.load_scene_path("res://scenes/level/test_level.tscn", 1,)


func _on_button_settings_pressed() -> void:
	SceneManager.load_manager.load_scene_path("res://scenes/user_interface/menus/settings.tscn", 1, "subtle")


func _on_button_credits_pressed() -> void:
	SceneManager.load_manager.load_scene_path("res://scenes/user_interface/menus/credits.tscn", 1, "subtle")
