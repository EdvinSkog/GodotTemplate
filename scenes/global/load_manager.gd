extends Node

signal level_loaded(level: Node)

## Loading
signal progress_changed(progress)
signal load_done

var loaded_resources: Array

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

func load_scene_path(scene_path: String, speed_multipler: float = 1, style : String = "normal") -> void:
	remove_dialogue_balloon()
	if state != State.READY:
		return
	
	if loaded_resources.size() > 1: # If there are many loaded levels
		for node: Node in loaded_resources:
			node.queue_free()
	
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
	_start_load()
	await Signal(self, "load_done")
	
	new_loading_screen._start_outro_animation()
	state = State.ANIMATING
	if !new_loading_screen.state == new_loading_screen.State.FINISHED:
		await Signal(new_loading_screen, "finished_waiting")
	var level: Node = _loaded_resource.instantiate() # Set the new one as current
	loaded_resources.append(level) # Store a reference if the instantiate doesn't get added as a child
	level_loaded.emit(level)
	state = State.READY


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
			load_done.emit()
