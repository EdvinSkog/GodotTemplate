extends Node

signal map_changed

var _map_list: Dictionary[StringName, MapData]:
	get: 
		return Game.ref_data.maps 

## References
@onready var loading: LoadingManager = %LoadingManager
@onready var map_holder = %MapHolder

@onready var global_gui: GlobalGui = %GlobalGui
@onready var pause_screen: PauseScreen = %PauseScreen

var current_level: Node:
	get: 
		if %MapHolder.get_child_count() <= 0:
			return get_tree().current_scene
		return %MapHolder.get_child(0)
var current_dialogue_balloon: DialogueBalloon


#region Setup
func _ready():
	_setup()

func _setup() -> void:
	var current_scene: Node = get_tree().current_scene
	current_scene.reparent.call_deferred(map_holder) #Reparent at end of frame
	loading.level_loaded.connect(add_new_map)
#endregion

#region Map Management

func load_map(key: StringName) -> void:
	if !_map_list.has(key):
		push_error("Could not find map data -> ", key)
		return
	var data: MapData = _map_list.get(key)
	loading.load_scene_path(data.scene_path)

func add_new_map(map: Node) -> void:
	_clear_map_holder()
	map_holder.add_child(map)
	map_changed.emit()

func _clear_map_holder() -> void: # not used
	for child: Node in %MapHolder.get_children():
		child.queue_free()

#endregion

func quit_game():
	get_tree().quit()
