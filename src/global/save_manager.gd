class_name SaveManager extends Node

signal dictionary_structure_completed
signal completed_setup

## When [b]true[/b], will generate save files if needed, or fix if faulty upon game launch. 
## Disabling this is essentially to disable the save-system.
@export var use_save_files: bool = true

const SETTINGS_FILE_PATH: String = "user://" + "settings.json"
var playthrough_file_path: String # Can have variation due to multiple playthroughs

#TODO: Separate settings data from playthrough data
const SAVE_FOLDER: String = "user://saves/"
var save_files: PackedStringArray:
	get:
		return DirAccess.get_files_at(SAVE_FOLDER)

## Savefile data is transferred into this dictionary vice-versa
var playthrough_data: Dictionary
var settings_data: Dictionary

## Structures are used to validate the save file's contents.
## The data compares to the structure so that keys are matching
## They also represent default values.

## For settings_data
var settings_structure: Dictionary[StringName, Variant] = {
	"graphics":
		{
			"vsync": 1 # (ENUM based) 0 = disabled, 1 = enabled, 2 = adaptive
		},
	"display":
		{
			"max_fps": 144
		},
	"audio":
		{
			"master_volume": 1,
			"music_volume": 1
		}
}

## For playthrough_data
var playthrough_structure: Dictionary[StringName, Variant] = {
	"time_spent": 0,
	#"chapters":
		#{
			#"current_chapter": &"intro"
		#}
}

## Returns the correct dictionary that holds the structure the file should adhere to.
func get_relevant_structure(file_path: String) -> Dictionary[StringName, Variant]:
	match file_path:
		playthrough_file_path:
			return playthrough_structure
		SETTINGS_FILE_PATH:
			return settings_structure
	push_error("Unknown file path, ", file_path, " for getting structure.")
	var dictionary: Dictionary
	return dictionary

## Returns the correct dictionary that holds the actual usable data based on which type of file.
func get_relevant_data(file_path: String) -> Dictionary:
	match file_path:
		playthrough_file_path:
			return playthrough_data
		SETTINGS_FILE_PATH:
			return settings_data
	push_error("Unknown file path, ", file_path, " for getting data.")
	var dictionary: Dictionary
	return dictionary
 
func set_relevant_data(file_path: String, new_dictionary: Dictionary) -> void:
	match file_path:
		playthrough_file_path:
			playthrough_data = new_dictionary
		SETTINGS_FILE_PATH:
			settings_data = new_dictionary
		_:
			push_error("Unknown file path, ", file_path, " for setting data.")

func _enter_tree() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_FOLDER):
		DirAccess.make_dir_absolute(SAVE_FOLDER) # Create saves folder
	autoselect_playthrough()
	
	# Create structures to compare data to
	generate_structure(playthrough_structure)
	generate_structure(settings_structure)
	
	
	if use_save_files:
		load_file(playthrough_file_path, true)
		load_file(SETTINGS_FILE_PATH, true)
		fix_data_structure(playthrough_file_path)
		fix_data_structure(SETTINGS_FILE_PATH)
	completed_setup.emit()



#region Save Load

func autoselect_playthrough() -> void:
	if save_files.is_empty():
		playthrough_file_path = get_playthrough_file_name_from_idx(1)
	elif save_files.size() == 1: # Singular save file; use it
		playthrough_file_path = get_playthrough_file_name_from_idx(1)
	elif save_files.size() > 1:
		playthrough_file_path = get_playthrough_file_name_from_idx(1)
		pass #TODO: Bring player to playthrough selection menu?

func get_playthrough_file_name_from_idx(index: int) -> String:
	return SAVE_FOLDER + "playthrough_" + str(index) + ".json"


## "file_path" helps decide type of data
func save(key: StringName, value: Variant, overwrite: bool = true, file_path: String = playthrough_file_path) -> void:
	_add_to_dictionary(key, value, get_relevant_data(file_path), overwrite)
	save_file(file_path)

#TODO Modulate nested keys
func find_deepest_key_in_dictionary(key: StringName, dictionary: Dictionary) -> Variant:
	if key.contains("/"):
		var split := key.split("/", true, 1)
		return find_deepest_key_in_dictionary(split[1], dictionary[split[0]])
	if dictionary.has(key):
		var value: Variant = dictionary[key]
		return value
	return null

func _add_to_dictionary(key: StringName, value: Variant, dictionary: Dictionary, overwrite: bool = true) -> void:
	# Separate subdictionaries with a "/" in key
	if key.contains("/"):
		var splits: Array = key.split("/", true, 1)
		var subdictionary: Dictionary = dictionary[splits[0]]
		var new_key: StringName = splits[1]
		_add_to_dictionary(new_key, value, subdictionary, overwrite)
		return
	assert(dictionary.has(key))
	if overwrite:
		dictionary[key] = value # Value is replaced no matter what
	elif dictionary[key] == null:
		dictionary[key] = value # Value replaced only if null


func get_value(key: StringName, data_dictionary: Dictionary = playthrough_data, use_default_if_null: bool = true) -> Variant:
	if data_dictionary == null:
		push_error("Data dictionary not found: ", data_dictionary)
		return null
	var value: Variant = find_deepest_key_in_dictionary(key, data_dictionary)
	
	if value == null and use_default_if_null: # If doesn't exist, use default value
		match data_dictionary:
			playthrough_data:
				value = get_default_value(key, playthrough_structure)
			settings_data:
				value = get_default_value(key, settings_structure)
	return value

func get_default_value(key: StringName, data_structure: Dictionary) -> Variant:
	return find_deepest_key_in_dictionary(key, data_structure) 

#region Files

func save_file(file_path: String = playthrough_file_path) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	var data := get_relevant_data(file_path)
	var jstr: String = JSON.stringify(data, "\t")
	file.store_line(jstr)
	file.close()

func load_file(file_path: String, debug_print: bool = false) -> void:
	if FileAccess.file_exists(file_path):
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		var data := file.get_as_text()
		var res: Variant = JSON.parse_string(data)
		if res != null:
			if debug_print:
				print_rich("[b]" + file_path + "[/b] LOADED:\n", data)
			set_relevant_data(file_path, res as Dictionary)
		else:
			print("NO SAVE FILE LOADED")
			push_error("Failed to parse save file!")
		file.close()

## Removes the save file's data values, but keeps the structure.
func clear_file(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		var jstr: String = JSON.stringify(get_relevant_structure(file_path), "\t") # Keep structure in file
		var file: FileAccess = FileAccess.open(file_path,FileAccess.WRITE)
		file.store_line(jstr)
		file.close()
		#file.free() #WARNING suddenly caused errors?

## Removes the actual save file
func remove_save_file(file_path: String) -> void:
	print("REMOVED SAVE FILE ", file_path)
	DirAccess.remove_absolute(file_path)

#endregion


#region Structure of Savefile
func generate_structure(structure: Dictionary) -> void:
	structure.make_read_only()
	dictionary_structure_completed.emit()

# Substructures
func fix_data_structure(file_path: String) -> bool:
	var status: bool = true
	status = _remove_redudant_data_keys(get_relevant_data(file_path), get_relevant_structure(file_path))
	status = _add_missing_data_keys(get_relevant_data(file_path), get_relevant_structure(file_path))
	save_file(file_path)
	return status

func _add_missing_data_keys(data_dictionary: Dictionary, validation_dictionary: Dictionary, nested: bool = true) -> bool:
	var status: bool = true
	for key: StringName in validation_dictionary:
		if not data_dictionary.has(key):
			data_dictionary[key] = validation_dictionary[key]
			
			status = false
			print("SAVE FILE, ADDED KEY '", key, "'")
		if data_dictionary[key] is Dictionary and nested:
			_add_missing_data_keys(data_dictionary[key], validation_dictionary[key])
	return status

func _remove_redudant_data_keys(data_dictionary: Dictionary, validation_dictionary: Dictionary, nested: bool = true) -> bool:
	var status: bool = true
	for key: StringName in data_dictionary:
		var clean_keys_validation_dictionary: Dictionary = validation_dictionary.duplicate()
		clean_keys_validation_dictionary.keys().clear() #No knowledge of nested keys!
		if not clean_keys_validation_dictionary.has(key):
			data_dictionary.erase(key)
			
			status = false
			print("SAVE FILE, REMOVED KEY '", key, "'")
		elif data_dictionary[key] is Dictionary and nested:
			_remove_redudant_data_keys(data_dictionary[key], validation_dictionary[key])
	return status

#endregion
