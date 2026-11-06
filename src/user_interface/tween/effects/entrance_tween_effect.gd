@icon("res://addons/at-icons/node/doorway_entrance.svg")
class_name EntranceTweenEffect extends TweenEffect

## Inactive: offset, scaled and transparent. Active: at rest in its laid-out spot.

## Start offset from the laid-out position, in pixels.
@export var from_offset := Vector2(0.0, 24.0)
## Start offset as a fraction of the Control's own size, added to from_offset.
## (0, 1) starts one full height below, independent of resolution.
@export var from_offset_ratio := Vector2.ZERO
@export var from_scale := Vector2.ONE
@export_range(0.0, 1.0, 0.01) var from_alpha := 0.0


func _init() -> void:
	duration = 0.35
	transition = Tween.TRANS_BACK


func apply(target: Control, layer: StringName, active: bool, instant: bool) -> void:
	var position := Vector2.ZERO if active else from_offset + from_offset_ratio * target.size
	var scale := Vector2.ONE if active else from_scale
	var alpha := 1.0 if active else from_alpha
	if instant:
		OffsetLayers.set_layer(target, OffsetLayers.Channel.POSITION, layer, position)
		OffsetLayers.set_layer(target, OffsetLayers.Channel.SCALE, layer, scale)
		OffsetLayers.set_layer(target, OffsetLayers.Channel.ALPHA, layer, alpha)
		return
	# Leaving uses the mirrored ease so an exit reads as the entrance in reverse.
	var direction_ease := get_ease(active)
	OffsetLayers.tween_layer(
		target, OffsetLayers.Channel.POSITION, layer, position, duration, transition, direction_ease, delay,
	)
	OffsetLayers.tween_layer(
		target, OffsetLayers.Channel.SCALE, layer, scale, duration, transition, direction_ease, delay,
	)
	OffsetLayers.tween_layer(
		target, OffsetLayers.Channel.ALPHA, layer, alpha, duration * 0.6,
		Tween.TRANS_LINEAR, direction_ease, delay,
	)
