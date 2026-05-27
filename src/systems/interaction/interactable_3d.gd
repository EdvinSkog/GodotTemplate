class_name Interactable3D extends Area3D


signal interacted
signal prompt_toggled(toggled: bool)

## Technically a wrapper variable to its component.
@export var enabled: bool = true:
	get:
		if !is_node_ready():
			await ready
		return interactable_component.enabled
	set(val):
		interactable_component.enabled = val
		monitorable = interactable_component.enabled
@export_group("References")
@export var prompt_visual: Node3D

@onready var interactable_component: InteractableComponent = %InteractableComponent


func toggle_prompt(option: bool) -> void:
	interactable_component.toggle_prompt(option)

func interact() -> void:
	interactable_component.interact()

#region Component Wrapper

func _on_interactable_component_prompt_toggled(toggled: bool) -> void:
	prompt_visual.visible = toggled
	prompt_toggled.emit(toggled)
	


func _on_interactable_component_interacted() -> void:
	interacted.emit()

#endregion
