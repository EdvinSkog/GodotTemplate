class_name InteractableComponent extends Node

signal prompt_toggled(toggled: bool)
signal interacted

var enabled: bool = true:
	set(val):
		enabled = val
		if !enabled:
			toggle_prompt(false)

var prompted: bool = false:
	set(value):
		if prompted == value: return # No Change
		prompted = value
		prompt_toggled.emit(prompted)

func interact() -> void:
	if !enabled: return
	interacted.emit()

func toggle_prompt(option: bool) -> void:
	if !enabled: return
	prompted = option
