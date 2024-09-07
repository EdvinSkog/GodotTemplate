class_name LoadingScreen extends CanvasLayer

signal loading_screen_has_full_coverage
## This signal means the loading screen wants to instantiate the new scene.
signal finished_waiting

## If enabled, the loading screen awaits a key prompt by the player before switching scene.
@export var await_player_input : bool = true
@export var play_end_animation: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar : ProgressBar = $Panel/ProgressBar

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

func _start_outro_animation() -> void:
	await Signal(animation_player, "animation_finished")
	
	if(await_player_input):
		$Panel/LabelPress.visible = true
		await Signal(self, "pressed_key")
		$Panel/LabelPress.visible = false
	emit_signal("finished_waiting")
	if(play_end_animation):
		animation_player.queue("end_load")
		await Signal(animation_player, "animation_finished")
	self.queue_free()

signal pressed_key

func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch:
		if event.pressed:
			pressed_key.emit()
