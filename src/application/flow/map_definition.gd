@icon("res://addons/at-icons/animation/map.svg")
@tool
class_name MapDefinition extends ContentDefinition

#Practically, Maps are things the player "loads" between. A simple example is a platformer level leading to the next platformer level.
#However, currently I define a "menu" as a type of Map, i.e. the main menu with title screen, options, etc.
#This is because of how a menu can act as the area for the player to navigate, if that makes sense.
#This is subject to change if it turns out to be confusing.
#A lengthy cutscene could potentially also be contained as a single map

@export_file("*.tscn") var scene_path: String


func get_key() -> StringName:
	if not content_id.is_empty(): return content_id
	var splits := resource_path.split("/")
	var file_name := splits.get(splits.size() - 1)
	file_name = file_name.trim_suffix(".tres")
	file_name = file_name.trim_suffix("_map_data")
	return file_name


func validate_definition() -> PackedStringArray:
	var errors := super()
	if scene_path.is_empty():
		errors.append("%s must reference a map scene" % content_id)
	elif not ResourceLoader.exists(scene_path):
		errors.append("%s references a missing map scene: %s" % [content_id, scene_path])
	return errors
