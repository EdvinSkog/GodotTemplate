class_name DataManager extends Node

const save_path: String = "user://playthrough.json"

signal dictionary_structure_completed

var save_dictionary: Dictionary

#region Structure of Savefile
var structure_dictionary: Dictionary[StringName, Variant] = {
	"playthrough": null
}

func generate_structure() -> void:
	# If structure_dictionary requires automation of certain variables;
	# it can be coded into here
	structure_dictionary.make_read_only()
	dictionary_structure_completed.emit()

#endregion

func _ready() -> void:
	#await owner.ready
	generate_structure()
	load_data(true)
	fix_save_structure()

#region Save Load
func save(key: StringName, value: Variant, overwrite: bool = true) -> void:
	_add_to_dictionary(key, value, save_dictionary, overwrite)
	save_file()

#TODO Modulate nested keys
#func find_deepest_key_in_dictionary(key: StringName, dictionary: Dictionary) -> Array:
	#if key.contains("/"):
		#var split := key.split("/", true, 1)
		#find_deepest_key_in_dictionary(split[1], dictionary[split[0]])
	#return dictionary[key]

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

func save_file() -> void:
	var save_file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	var jstr: String = JSON.stringify(save_dictionary, "\t")
	save_file.store_line(jstr)
	save_file.close()


func get_data(key: StringName, dictionary: Dictionary = save_dictionary) -> Variant:
	if dictionary == null:
		return
	if dictionary.has(key):
		return dictionary[key]
	return null

func load_data(debug_print: bool = false) -> void:
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		var data := file.get_as_text()
		var res: Variant = JSON.parse_string(data)
		#var res: Variant = JSON.parse_string(file.get_line())
		if res != null:
			if debug_print:
				print("SAVE FILE LOADED:\n", data)
			save_dictionary = res as Dictionary
		else:
			push_error("Failed to parse save file!")
		file.close()

func fix_save_structure() -> void:
	_remove_redudant_keys_in_dictionary(save_dictionary, structure_dictionary)
	_fix_keys_in_dictionary(save_dictionary, structure_dictionary)
	save_file()

func _fix_keys_in_dictionary(dictionary: Dictionary, validation_dictionary: Dictionary, nested: bool = true) -> void:
	for key: StringName in validation_dictionary:
		if not dictionary.has(key):
			dictionary[key] = validation_dictionary[key] 
		if dictionary[key] is Dictionary and nested:
			_fix_keys_in_dictionary(dictionary[key], validation_dictionary[key])

func _remove_redudant_keys_in_dictionary(dictionary: Dictionary, validation_dictionary: Dictionary, nested: bool = true) -> void:
	for key: StringName in dictionary:
		var clean_keys_validation_dictionary: Dictionary = validation_dictionary.duplicate()
		clean_keys_validation_dictionary.keys().clear() #No knowledge of nested keys!
		if not clean_keys_validation_dictionary.has(key):
			dictionary.erase(key)
		elif dictionary[key] is Dictionary and nested:
			_remove_redudant_keys_in_dictionary(dictionary[key], validation_dictionary[key])
		

func clear_data() -> void:
	if FileAccess.file_exists(save_path):
		var jstr: String = JSON.stringify(structure_dictionary, "\t")
		var file: FileAccess = FileAccess.open(save_path,FileAccess.WRITE)
		file.store_line(jstr)
		file.close()
#endregion
