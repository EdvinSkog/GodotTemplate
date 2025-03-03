class_name Interactable extends Area2D

signal prompted_interaction
signal interacted
@export var interactable: bool = true
@export var interact_label: String = "INTERACT"
var _prompted: bool = false


func _ready() -> void:
	%Label.text = interact_label
	if !interactable:
		%Interact.hide()

func interact() -> void:
	if !interactable:
		return
	interacted.emit()

func toggle_prompt(option: bool) -> void:
	if option:
		_prompted = true
		%Prompt.show()
		
	else: 
		_prompted = false
		%Prompt.hide()
