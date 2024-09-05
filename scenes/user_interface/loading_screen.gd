extends CanvasLayer

signal loading_screen_has_full_coverage

@onready var animation_player: AnimationPlayer = $Panel/AnimationPlayer
@onready var progress_bar : ProgressBar = $Panel/ProgressBar

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

func _start_outro_animation() -> void:
	await Signal(animation_player, "animation_finished")
	$Panel/LabelPress.visible = true
	await Signal(self, "pressed_key")
	#animation_player.queue("end_load")
	#await Signal(animation_player, "animation_finished")
	self.queue_free()

signal pressed_key

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			pressed_key.emit()
