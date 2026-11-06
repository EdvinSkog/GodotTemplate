extends Camera2D

@export var max_offset := 150.0
@export var follow_speed := 8.0

func _process(delta: float) -> void:
	var viewport_center := get_viewport().get_visible_rect().size * 0.5
	var mouse_pos := get_viewport().get_mouse_position()
	var dir := mouse_pos - viewport_center

	# Limit how far the camera can move
	var target_offset := dir.limit_length(max_offset)

	# Smooth movement
	offset = offset.lerp(target_offset, follow_speed * delta)
