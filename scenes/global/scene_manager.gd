extends CanvasLayer

var current_level : Node
signal level_changed

## Loading
signal progress_changed(progress)
signal load_done

var _load_screen_path_normal : String = "res://scenes/user_interface/loading/loading_screen.tscn"
var _load_screen = load(_load_screen_path_normal)
var _load_screen_path_subtle : String = "res://scenes/user_interface/loading/loading_screen_subtle.tscn"
var _load_screen_subtle = load(_load_screen_path_subtle)
var _loaded_resource:  PackedScene
var _scene_path: String
var _progress: Array = []

enum State {READY, ANIMATING, LOADING}
var state: State = State.READY

var use_sub_threads: bool = false

func remove_dialogue_balloon(): 
	if(Game.current_dialogue_balloon != null):
		Game.current_dialogue_balloon.queue_free()

func load_scene(scene_path: String, speed_multipler: float = 1, style : String = "normal") -> void:
	remove_dialogue_balloon()
	if state != State.READY:
		return
	
	state = State.LOADING
	

	_scene_path = scene_path
	
	# Spawn loading screen
	var new_loading_screen: LoadingScreen
	match style:
		"normal":
			new_loading_screen = _load_screen.instantiate()
		"subtle":
			new_loading_screen = _load_screen_subtle.instantiate()
		_:
			new_loading_screen = _load_screen.instantiate()

	get_tree().get_root().add_child(new_loading_screen)
	state = State.ANIMATING
	
	# Set speed multipler
	new_loading_screen.animation_player.speed_scale = speed_multipler
	
	# Set-up signal connections for loading screen
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	#self.load_done.connect(new_loading_screen._start_outro_animation)
	
	# Wait until loading screen have fully covered the screen
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	state = State.LOADING

	# Start loading the next scene
	start_load()
	await Signal(self, "load_done")
	

	# Delete the old scene.
	if(current_level != null):
		current_level.queue_free() # Remove current level
	new_loading_screen._start_outro_animation()
	state = State.ANIMATING
	if !new_loading_screen.state == new_loading_screen.State.FINISHED:
		await Signal(new_loading_screen, "finished_waiting")
	current_level = _loaded_resource.instantiate() # Set the new one as current
	emit_signal("level_changed") # Adds new level in App script
	state = State.READY


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(delta):
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2: #? THREAT_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			progress_changed.emit(_progress[0])
		3: #? THREAD_LOAD_LOADED
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			progress_changed.emit(1.0)
			load_done.emit()



func set_current_level(level : Node):
	if(current_level != null):
		current_level.queue_free() # Remove current level
	current_level = level # Set the new one as current
	level_changed.emit() # Adds new level in App script

func switch_scene(target: String, fade_multiplier: float = 1) -> void:
	var new_level = load(target)
	$AnimationPlayer.speed_scale = fade_multiplier
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	
	set_current_level(new_level.instantiate())
	
	$AnimationPlayer.play_backwards("dissolve")

func change_top_scene(target: String, fade_multiplier: float = 1):
	$AnimationPlayer.speed_scale = fade_multiplier
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")

func quit_game():
	#await $AnimationPlayer.play("quit")
	get_tree().quit()
