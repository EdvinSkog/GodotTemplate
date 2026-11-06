extends Node

signal map_changed

var _map_list: Dictionary[StringName, MapData]:
	get: 
		return Data.maps

## References
@onready var loading: LoadingManager = %LoadingManager
@onready var map_holder: Node = %MapHolder

@onready var global_gui: GlobalGui = %GlobalGui
@onready var pause_screen: PauseScreen = %PauseScreen

## Current map.
## Use the LoadingManager to have a smoother transition into a new map.
var map: Node:
	set = set_map


#region Setup
func _ready()  -> void:
	map = get_tree().current_scene
	_setup()

func _setup() -> void:
	var current_scene: Node = get_tree().current_scene
	current_scene.reparent.call_deferred(map_holder) #Reparent at end of frame
	loading.level_loaded.connect(set_map)
#endregion

#region Map Management

func get_maps() -> Dictionary[StringName, MapData]:
	return _map_list

func load_map(key: StringName) -> void:
	if !get_maps().has(key):
		push_error("Could not find map data -> ", key)
		return
	var data: MapData = get_maps().get(key)
	loading.load_scene_path(data.scene_path)

func set_map(new_map: Node) -> void:
	_clear_map_holder()
	map = new_map
	if map.get_parent() == null:
		map_holder.add_child(map)
	else:
		map.reparent.call_deferred(map_holder)
	map_changed.emit()
	

func _clear_map_holder() -> void: # not used
	for child: Node in %MapHolder.get_children():
		child.queue_free()

#endregion

func quit_game() -> void:
	get_tree().quit()
