@tool
class_name ContentRegistry extends ResourceRegistry

const DEFAULT_CONTENT_ROOT: String = "res://data/content"

## Multiple roots can be added
@export var roots: PackedStringArray = [DEFAULT_CONTENT_ROOT]

func _ready() -> void:
	reload_registry()


func reload_content() -> PackedStringArray:
	return reload_registry()


func reload_registry() -> PackedStringArray:
	clear_registry()
	var errors := scan_roots(
		roots,
		PackedStringArray(["tres", "res"]),
		_register_loaded_content,
	)
	errors.append_array(validate_all())
	reloaded.emit()
	return errors


func register_definition(definition: ContentDefinition) -> PackedStringArray:
	var errors := definition.validate_definition()
	if definition.content_id.is_empty():
		return errors
	errors.append_array(register_resource(definition.content_id, definition, "content"))
	return errors


func get_map(content_id: StringName) -> MapDefinition:
	return definitions.get(content_id) as MapDefinition



func validate_all() -> PackedStringArray:
	var errors := PackedStringArray()
	for definition: ContentDefinition in definitions.values():
		errors.append_array(definition.validate_definition())
	return errors

func _register_loaded_content(_path: String, resource: Resource) -> PackedStringArray:
	if resource is ContentDefinition:
		return register_definition(resource as ContentDefinition)
	return PackedStringArray()
