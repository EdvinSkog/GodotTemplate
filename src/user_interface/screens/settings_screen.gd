extends Control

signal returned

func _ready() -> void:
	pass

func _on_button_return_pressed() -> void:
	returned.emit()
