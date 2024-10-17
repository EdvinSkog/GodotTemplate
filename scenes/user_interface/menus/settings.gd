extends Control

func _ready() -> void:
	AudioManager.stop_music()

func _on_button_return_pressed() -> void:
	SceneManager.load_scene("res://scenes/user_interface/menus/title_screen.tscn", 1, "subtle")
