@icon("res://addons/at-icons/node/resize.svg")
class_name ScaleTweenEffect extends TweenEffect

## Inactive: normal size. Active: active_scale. Scale layers multiply, so a hover
## scale and a held scale on the same button combine instead of overwriting.
## On event triggers it plays as a pulse: out to active_scale and back.

@export var active_scale := Vector2(1.05, 1.05)


func _init() -> void:
	duration = 0.12
	transition = Tween.TRANS_BACK


func apply(target: Control, layer: StringName, active: bool, instant: bool) -> void:
	var value := active_scale if active else Vector2.ONE
	if instant:
		OffsetLayers.set_layer(target, OffsetLayers.Channel.SCALE, layer, value)
		return
	OffsetLayers.tween_layer(
		target, OffsetLayers.Channel.SCALE, layer, value, duration, transition, ease_type, delay,
	)


func play(target: Control, layer: StringName) -> void:
	var channel := OffsetLayers.Channel.SCALE
	var tween := AutoTween.start(
		target, OffsetLayers.tween_key(channel, layer), transition, ease_type,
	)
	var set_value := func(value: Vector2) -> void: OffsetLayers.set_layer(target, channel, layer, value)
	tween.tween_method(set_value, Vector2.ONE, active_scale, duration * 0.5).set_delay(delay)
	tween.tween_method(set_value, active_scale, Vector2.ONE, duration * 0.5)
