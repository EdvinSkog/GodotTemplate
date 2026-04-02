extends Area3D

signal found_interactable(interactable: Interactable3D)
signal left_interactable(interactable: Interactable3D)


func _on_area_entered(area: Area3D) -> void:
	if area is Interactable3D:
		area.toggle_prompt(true)
		found_interactable.emit(area)


func _on_area_exited(area: Area3D) -> void:
	if area is Interactable3D:
		area.toggle_prompt(false)
		left_interactable.emit(area)
