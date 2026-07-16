class_name PauseScreen extends Control

@export var enabled: bool = true
@onready var handler: PauseHandler = $PauseHandler

func _ready() -> void:
	unpause()

func pause() -> void:
	if !enabled:
		return
	show()
	$InputLayer.set_enabled(true)

func unpause() -> void:
	hide()
	$InputLayer.set_enabled(false)
	get_tree().paused = false

func _on_return_button_pressed() -> void:
	unpause()

func _on_quit_button_pressed() -> void:
	Scene.quit_game()

func _on_main_menu_button_pressed() -> void:
	Scene.load_map(&"main_menu")
