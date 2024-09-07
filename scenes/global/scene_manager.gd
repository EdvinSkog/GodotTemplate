extends CanvasLayer

var current_level : Node
signal level_changed

## Loading
signal progress_changed(progress)
signal load_done

var _load_screen_path : String = "res://scenes/user_interface/loading_screen.tscn"
var _load_screen = load(_load_screen_path)
var _loaded_resource:  PackedScene
var _scene_path: String
var _progress: Array = []

var use_sub_threads: bool = true

func remove_dialogue_balloon(): 
	if(GameManager.current_dialogue_balloon):
		GameManager.current_dialogue_balloon.queue_free()

func load_scene(scene_path: String, style : int = 0) -> void:
	remove_dialogue_balloon()
	
	if (style == 1):
		switch_scene(scene_path)
		return
	
	
	_scene_path = scene_path
	
	var new_loading_screen: LoadingScreen = _load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._start_outro_animation)
	
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	start_load()
	await Signal(self, "load_done")
	if(current_level != null):
		current_level.queue_free() # Remove current level
	await Signal(new_loading_screen, "finished_waiting")
	current_level = _loaded_resource.instantiate() # Set the new one as current
	level_changed.emit() # Adds new level in App script


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
