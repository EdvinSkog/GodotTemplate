class_name LoadingManager extends Node

signal level_loaded(level: Node)

## Loading progress updatged
signal progress_changed(progress: float)
signal load_done
## Every loading screen has left the tree, so the new scene is fully visible.
## The scene itself is added while the loading screen is still fading out.
signal transition_finished

var loaded_resources: Array
var _loaded_resource:  PackedScene
## Path being loaded
var _scene_path: String
var _progress: Array = []

# Loading Screen
enum Style {SUBTLE, CLEAR}

@export_group("Loading Screen References", "_load_screen")
@export var _load_screen_clear: PackedScene
@export var _load_screen_subtle: PackedScene

enum State {READY, ANIMATING, LOADING}
var state: State = State.READY

var use_sub_threads: bool = false

var _active_loading_screens := 0

func load_scene_path(scene_path: String, style: Style = Style.SUBTLE, speed_multiplier: float = 1) -> void:
	_remove_dialogue_balloon()
	
	if state != State.READY:
		return
	
	state = State.LOADING
	
	_scene_path = scene_path
	
	# Spawn loading screen
	var new_loading_screen: LoadingScreen = get_loading_screen_from_style(style)
	
	_active_loading_screens += 1
	new_loading_screen.tree_exited.connect(_on_loading_screen_exited, CONNECT_ONE_SHOT)
	get_tree().get_root().add_child(new_loading_screen)
	state = State.ANIMATING
	
	new_loading_screen.animation_player.speed_scale = speed_multiplier
	
	# Set-up signal connections for loading screen
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	
	# Wait until loading screen have fully covered the screen
	await new_loading_screen.loading_screen_has_full_coverage
	state = State.LOADING
	
	_start_load()
	await load_done
	
	new_loading_screen._start_outro_animation()
	state = State.ANIMATING
	if !new_loading_screen.state == new_loading_screen.State.FINISHED:
		await new_loading_screen.finished_waiting
	var level: Node = _loaded_resource.instantiate() # Set the new one as current
	loaded_resources.append(level) # Store a reference if the instantiate doesn't get added as a child
	level_loaded.emit(level)
	state = State.READY
	# Loading screen without an end animation is already gone by now.
	if _active_loading_screens == 0:
		transition_finished.emit()
	await get_tree().process_frame

func _on_loading_screen_exited() -> void:
	_active_loading_screens = maxi(_active_loading_screens - 1, 0)
	if _active_loading_screens == 0 and state == State.READY:
		transition_finished.emit()


func _start_load() -> void:
	var _state := ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if _state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status := ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			progress_changed.emit(1.0)
			set_process(false)
			load_done.emit()
#region Misc
func _remove_dialogue_balloon() -> void: 
	if(DialoguePlayer.current_balloon != null):
		DialoguePlayer.current_balloon.queue_free()

func is_transitioning() -> bool:
	return state != State.READY or _active_loading_screens > 0

func get_loading_screen_from_style(style: Style) -> LoadingScreen:
	var screen: LoadingScreen
	match style:
		Style.SUBTLE:
			screen = _load_screen_subtle.instantiate()
		Style.CLEAR:
			screen = _load_screen_clear.instantiate()
		_:
			screen = _load_screen_clear.instantiate()
	return screen
#endregion
