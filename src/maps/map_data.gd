@icon("res://assets/icons/editor/map.svg")
@tool
class_name MapData extends Resource

## If empty, use file name minus "_map_data" and extension
@export var override_key: StringName = ""
var key: StringName:
	get = get_key,
	set = set_key
@export_file("*.tscn") var scene_path: String

#TODO: Add flags or other data to be saved within the map
#var saved_dictionary: Dictionary[StringName, Variant]

func set_key(val: StringName) -> void:
	key = val

func get_key() -> StringName:
	if !override_key.is_empty(): return override_key
	var splits := resource_path.split("/")
	var file_name := splits.get(splits.size() - 1)
	file_name = file_name.trim_suffix(".tres")
	file_name = file_name.trim_suffix("_map_data")
	return file_name
