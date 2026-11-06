class_name ResourceDirectory extends RefCounted

## Whether `path` is a folder that can be listed.
static func exists(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)


## Full paths of the resources below `path`, recursively and sorted. With
## `extensions` (lower case, without the dot), only files with one of them.
static func list_files(path: String, extensions: PackedStringArray = []) -> PackedStringArray:
	var result := PackedStringArray()
	_collect(path, extensions, result)
	result.sort()
	return result


static func _collect(path: String, extensions: PackedStringArray, result: PackedStringArray) -> void:
	for entry: String in ResourceLoader.list_directory(path):
		if entry.ends_with("/"):
			_collect(path.path_join(entry.trim_suffix("/")), extensions, result)
		elif extensions.is_empty() or entry.get_extension().to_lower() in extensions:
			result.append(path.path_join(entry))
