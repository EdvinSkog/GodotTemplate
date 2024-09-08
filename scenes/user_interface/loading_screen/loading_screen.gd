class_name LoadingScreen extends CanvasLayer

## Screen is fully covered by the Loading Screen.
signal loading_screen_has_full_coverage
## This signal means the loading screen wants to instantiate the new scene.
signal finished_waiting

## If enabled, the loading screen awaits a key prompt by the player before switching scene.
@export var await_player_input : bool = true
@export var play_end_animation: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar : ProgressBar = $Panel/ProgressBar

func _ready() -> void:
	_reveal_loading_screen()

func _reveal_loading_screen() -> void:
	animation_player.play("fade_in")
	await Signal(animation_player, "animation_finished")
	emit_signal("loading_screen_has_full_coverage") # Can also be called within the animationplayer
	_start_loading_animation()

func _start_loading_animation() -> void:
	animation_player.queue("start_load")

func _start_outro_animation() -> void:
	if(await_player_input):
		$Panel/LabelPress.visible = true
		await Signal(self, "pressed_key")
		$Panel/LabelPress.visible = false
	else:
		#This is needed or else it sends it emits "finished_waiting" too early.
		await Signal(animation_player, "animation_finished")
	emit_signal("finished_waiting")
	if(play_end_animation):
		animation_player.queue("end_load")
	await Signal(animation_player, "animation_finished") # Can be the loading-animation, not always outro-animation
	self.queue_free()

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

signal pressed_key

func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch:
		if event.pressed:
			pressed_key.emit()
