extends Area2D

signal found_interactable(interactable: Interactable)
signal left_interactable(interactable: Interactable)


func _on_area_entered(area: Area2D) -> void:
	if area is Interactable:
		found_interactable.emit(area)


func _on_area_exited(area: Area2D) -> void:
	if area is Interactable:
		left_interactable.emit(area)
