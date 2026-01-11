class_name PauseScreen extends Control

@export var enabled: bool = true
@onready var handler: PauseHandler = $PauseHandler


func _ready() -> void:
	unpause()

func pause() -> void:
	if !enabled:
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

func unpause() -> void:
	Input.mouse_mode = Player.mouse_mode
	hide()
	get_tree().paused = false

func _on_return_button_pressed() -> void:
	unpause()

func _on_quit_button_pressed() -> void:
	Scene.quit_game()
