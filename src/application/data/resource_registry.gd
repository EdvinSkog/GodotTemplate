@icon("res://addons/at-icons/node/database.svg")
@tool
@abstract
class_name ResourceRegistry extends Node

signal reloaded

## Shared mechanics for registries whose entries are Resources.
var definitions: Dictionary[StringName, Resource] = {}
var definitions_by_type: Dictionary[StringName, Array] = {}

@abstract
func reload_registry() -> PackedStringArray

func clear_registry() -> void:
	definitions.clear()
	definitions_by_type.clear()


func register_resource(
	resource_id: StringName,
	resource: Resource,
	duplicate_label := "resource",
) -> PackedStringArray:
	var errors := PackedStringArray()
	if resource_id.is_empty():
		errors.append("Registry ID must not be empty")
		return errors
	if not resource:
		errors.append("Registry entry %s has no resource" % resource_id)
		return errors
	if definitions.has(resource_id):
		errors.append("Duplicate %s ID: %s" % [duplicate_label, resource_id])
		return errors
	definitions[resource_id] = resource
	var type_name := _get_registry_type(resource)
	if not definitions_by_type.has(type_name):
		definitions_by_type[type_name] = []
	definitions_by_type[type_name].append(resource)
	return errors


func get_definition(resource_id: StringName) -> Resource:
	return definitions.get(resource_id)


func has_definition(resource_id: StringName) -> bool:
	return definitions.has(resource_id)


func get_definitions_by_type(type_name: StringName) -> Array:
	return definitions_by_type.get(type_name, []).duplicate()


func scan_roots(
	root_paths: PackedStringArray,
	extensions: PackedStringArray,
	register_loaded: Callable,
) -> PackedStringArray:
	var errors := PackedStringArray()
	for root: String in root_paths:
		_scan_directory(root, extensions, register_loaded, errors)
	return errors


func _scan_directory(
	path: String,
	extensions: PackedStringArray,
	register_loaded: Callable,
	errors: PackedStringArray,
) -> void:
	if not ResourceDirectory.exists(path):
		errors.append("Registry root could not be opened: %s" % path)
		return
	for child_path: String in ResourceDirectory.list_files(path, extensions):
		var resource := ResourceLoader.load(child_path)
		if not resource:
			errors.append("Registry resource could not be loaded: %s" % child_path)
		else:
			var registration_errors: PackedStringArray = register_loaded.call(
				child_path,
				resource,
			)
			errors.append_array(registration_errors)


func _get_registry_type(resource: Resource) -> StringName:
	var script := resource.get_script() as Script
	if script:
		var global_name := script.get_global_name()
		if not global_name.is_empty():
			return global_name
	return StringName(resource.get_class())
