@tool
class_name DataHandler extends Handler

@export_tool_button("Update") var update_action := do_update

@export_storage var songs: Dictionary[StringName, AudioStream]
@export_dir var _music_folder_path: String

@export_storage var voices: Dictionary[StringName, AudioStream]
@export_dir var _voice_folder_path: String

@export_storage var maps: Dictionary[StringName, MapData]
@export_dir var _maps_folder_path: String

#TODO: Add music list from Audio autoload here

func _enter_tree() -> void:
	if OS.is_debug_build():
		do_update()

func do_update() -> void:
	if !Engine.is_editor_hint():
		return #WARNING: If not updated can cause errors
	_store_resource_into_list(maps, _maps_folder_path)
	_store_resource_into_list(songs, _music_folder_path, "resource_name")
	_store_resource_into_list(voices, _voice_folder_path, "resource_name")
	var singleton := Engine.get_singleton("EditorInterface")
	if singleton:
		singleton.save_scene()
#region Resource to List

func _store_resource_into_list(list: Dictionary, folder_path: String, property_key: StringName = &"key") -> void:
	list.clear()
	
	var do_autoname: bool = false
	if property_key == "resource_name": 
		# This is mainly for asset files that are loaded as resources.
		do_autoname = true
	
	var arr: Array[Resource] = load_resource_list(folder_path, do_autoname)
	for each in arr:
		if property_key in each:
			list[each.get(property_key)] = each
			print_rich("[color=lightyellow]" +
				get_name_based_on_file_path(folder_path) + "[/color] stored: [color=cyan]", each.get(property_key))
		else: push_warning("Missing property key for ", list)



static func load_resource_list(folder_path: String, autoname: bool = false) -> Array[Resource]:
	var arr: Array = get_all_file_paths(folder_path)
	var loaded_arr: Array[Resource]
	for each in arr:
		var resource : Resource = ResourceLoader.load(each)
		if resource.resource_name.is_empty() and autoname:
			resource.resource_name = get_name_based_on_file_path(resource.resource_path)
		loaded_arr.append(resource)
	return loaded_arr

#endregion

#region File Path

static func get_name_based_on_file_path(file_path: String) -> String:
	var splits := file_path.split("/")
	var file_name := splits[splits.size() -1 ] # Last index
	file_name = file_name.split(".")[0]
	return file_name

# From Reddit commenter u/dddbbb #NOTE: ignores .txt and .import
static func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir := DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name := dir.get_next()  
	while file_name != "":  
		var file_path := path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else: 
			if file_path.ends_with(".import") or file_path.ends_with(".txt"): 
				pass
			else: file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths

#endregion
