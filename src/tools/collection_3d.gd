@tool
@icon("res://assets/icons/editor/folder_3d.svg")
class_name Collection3D extends Node3D

@export_tool_button("Store Position", "EditorPosition") var action_store := do_action_store
@export var stored_position: Vector3
@export_tool_button("Move Children to Stored Position", "3D") var action_move := do_action_move
@export_category("Settings")
@export var disable_process_when_hidden: bool = false




func _enter_tree() -> void:
	set_notify_transform(true)

func do_action_store() -> void:
	stored_position = global_position
	print(stored_position)

func do_action_move() -> void:
	for node in get_children():
		if node is Node3D:
			node.global_position = stored_position

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_TRANSFORM_CHANGED:
		#print("changed position", position)

func _ready() -> void:
	if !Engine.is_editor_hint():
		visibility_changed.connect(_on_visibility_changed)
	else:
		renamed.connect(_on_renamed)

## Force the node's name to be uppercase. 
# Personal preference, helps distinguish them from normal Node3D
func _on_renamed() -> void:
	if name.to_upper() != name:
		name = name.to_upper()

func _on_visibility_changed() -> void:
	if !visible: process_mode = Node.PROCESS_MODE_DISABLED
	else: process_mode = Node.PROCESS_MODE_INHERIT
