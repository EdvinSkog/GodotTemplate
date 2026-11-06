@tool
@abstract
class_name ContentDefinition extends Resource

@export var content_id: StringName:
	set = set_content_id
@export var display_name: String
@export_multiline var description: String


func validate_definition() -> PackedStringArray:
	var errors := PackedStringArray()
	if content_id.is_empty():
		errors.append("content_id must not be empty")
	if display_name.is_empty():
		errors.append("%s must have a display name" % content_id)
	return errors

# i.e. ItemDefinition returns item_
func get_prefix() -> StringName:
	return ""

## Non-blocking authoring feedback, separate from invalid content errors.
func get_validation_warnings() -> PackedStringArray:
	return PackedStringArray()

func set_content_id(val: StringName) -> void:
	content_id = val.to_snake_case()
	
