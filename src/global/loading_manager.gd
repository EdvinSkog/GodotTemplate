class_name LoadingManager extends Node

signal level_loaded(level: Node)

## Loading
signal progress_changed(progress)
signal load_done

var loaded_resources: Array
var _loaded_resource:  PackedScene
var _scene_path: String
var _progress: Array = []

# Loading Screen
enum Style {SUBTLE, CLEAR}
#var _load_screen_path_normal : String = ""
@export_group("Loading Screen References", "_load_screen")
@export var _load_screen_clear: PackedScene
@export var _load_screen_subtle: PackedScene

enum State {READY, ANIMATING, LOADING}
var state: State = State.READY

var use_sub_threads: bool = false

func remove_dialogue_balloon(): 
	if(Scene.current_dialogue_balloon != null):
		Scene.current_dialogue_balloon.queue_free()

#TODO Add a loader for map, instead of scene_path

func load_scene_path(scene_path: String, style: Style = Style.SUBTLE, speed_multipler: float = 1) -> void:
	remove_dialogue_balloon()
	
	if state != State.READY:
		return
	
	if loaded_resources.size() > 1: # If there are many loaded levels
		for node in loaded_resources:
			if node != null:
				node.queue_free()
		loaded_resources.clear()
	
	state = State.LOADING
	
	_scene_path = scene_path
	
	# Spawn loading screen
	var new_loading_screen: LoadingScreen = get_loading_screen_from_style(style)
	
	get_tree().get_root().add_child(new_loading_screen)
	state = State.ANIMATING
	
	# Set speed multipler
	new_loading_screen.animation_player.speed_scale = speed_multipler
	
	# Set-up signal connections for loading screen
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	#self.load_done.connect(new_loading_screen._start_outro_animation)
	
	# Wait until loading screen have fully covered the screen
	await new_loading_screen.loading_screen_has_full_coverage
	state = State.LOADING

	# Start loading the next scene
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
	await get_tree().process_frame


func _start_load() -> void:
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
			set_process(false)
			load_done.emit()

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
