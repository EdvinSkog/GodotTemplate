@tool
class_name DataHandler extends Handler

@export_tool_button("Update") var update_action = do_update

@export_storage var maps: Dictionary[StringName, MapData]
@export_dir var maps_folder_path: String

#TODO: Add music list from Audio autoload here

func _ready() -> void:
	do_update()

func do_update() -> void:
	if Engine.is_editor_hint():
		maps.clear()
		var map_list: Array[MapData]	
		var arr: Array = load_resource_list(maps_folder_path)
		map_list.append_array(arr)
		for each in map_list:
			maps[each.key] = each
			print_rich("Stored map - [color=cyan]", each.key)
		maps.make_read_only()

static func load_resource_list(folder_path: String) -> Array[Resource]:
	var arr: Array = get_all_file_paths(folder_path)
	var loaded_arr: Array[Resource]
	for each in arr:
		var resource : MapData = ResourceLoader.load(each)
		loaded_arr.append(resource)
	return loaded_arr


# From Reddit commenter u/dddbbb
static func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
