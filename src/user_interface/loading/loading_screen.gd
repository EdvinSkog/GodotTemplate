class_name LoadingScreen extends CanvasLayer

## Screen is fully covered by the Loading Screen.
signal loading_screen_has_full_coverage
## This signal means the loading screen wants to instantiate the new scene.
signal finished_waiting

signal pressed_key

## If enabled, the loading screen awaits a key prompt by the player before switching scene.
@export var await_player_input : bool = true
@export var play_end_animation: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar : ProgressBar = %LoadingBar

enum State{ANIMATING, FINISHED}
var state: State = State.ANIMATING

func _ready() -> void:
	_reveal_loading_screen()

func _reveal_loading_screen() -> void:
	animation_player.play("fade_in")
	await Signal(animation_player, "animation_finished")
	loading_screen_has_full_coverage.emit() # Can also be called within the animationplayer
	_start_loading_animation()

func _start_loading_animation() -> void:
	animation_player.queue("start_load")

func _start_outro_animation() -> void:
	if(await_player_input):
		$Panel/LabelPress.visible = true
		await Signal(self, "pressed_key")
		$Panel/LabelPress.visible = false
	_end()

func _end():
	state = State.FINISHED
	finished_waiting.emit()
	
	if(play_end_animation):
		animation_player.queue("end_load")
		await Signal(animation_player, "animation_finished")
	self.queue_free()

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)

func _input(event):
	if event is InputEventKey or event is InputEventScreenTouch:
		if event.pressed:
			pressed_key.emit()
