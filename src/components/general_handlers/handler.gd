@icon("res://assets/icons/editor/arrow_right_from_line.svg")
class_name Handler extends Node

@export var owner_node: Node

# Abstract class, inherit

func _ready() -> void:
	if owner_node != null:
		owner = owner_node
