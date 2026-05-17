@tool
@icon("res://assets/icons/editor/folder_2d.svg")
class_name Collection2D extends Node2D

@export_tool_button("Store Position", "EditorPosition") var action_store := do_action_store
@export var stored_position: Vector2
@export_tool_button("Move Children to Stored Position", "2D") var action_move := do_action_move
@export_category("Settings")
@export var disable_process_when_hidden: bool = false

func do_action_store() -> void:
	stored_position = global_position
	print(stored_position)

func do_action_move() -> void:
	for node in get_children():
		if node is Node2D:
			node.global_position = stored_position

func _ready() -> void:
	if !Engine.is_editor_hint():
		visibility_changed.connect(_on_visibility_changed)
	else:
		renamed.connect(_on_renamed)

## Force the node's name to be uppercase. 
# Personal preference, helps distinguish them from normal Node3D
func _on_renamed() -> void:
	if name.is_empty():
		name = "Collection2D"
		return
	if name.to_upper() != name and name != "Collection2D":
		name = name.to_upper()

func _on_visibility_changed() -> void:
	if !disable_process_when_hidden: return
	if !visible: process_mode = Node.PROCESS_MODE_DISABLED
	else: process_mode = Node.PROCESS_MODE_INHERIT
