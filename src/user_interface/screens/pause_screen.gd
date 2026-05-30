class_name PauseScreen extends Control

@export var enabled: bool = true
@onready var handler: PauseHandler = $PauseHandler

## Store the most recent mouse mode
var last_mouse_mode: Input.MouseMode

func _ready() -> void:
	unpause()

func pause() -> void:
	if !enabled:
		return
	last_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

func unpause() -> void:
	Input.mouse_mode = last_mouse_mode
	hide()
	get_tree().paused = false

func _on_return_button_pressed() -> void:
	unpause()

func _on_quit_button_pressed() -> void:
	Scene.quit_game()




func _on_main_menu_button_pressed() -> void:
	Scene.load_map(&"main_menu")
