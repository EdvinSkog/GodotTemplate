extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_return_pressed() -> void:
	SceneManager.load_scene("res://scenes/user_interface/menus/title_screen.tscn", 1, "subtle")
