class_name OffsetLayers extends RefCounted

## Several effects may drive one Control at once: an entrance, a hover scale, a
## held squash and a reflow glide. Each writes its own named layer and the Control
## shows the combination, so effects never overwrite each other.

enum Channel { POSITION, SCALE, ALPHA }

const _META := {
	Channel.POSITION: &"_offset_position_layers",
	Channel.SCALE: &"_offset_scale_layers",
	Channel.ALPHA: &"_offset_alpha_layers",
}
const _BASE_ALPHA := &"_offset_base_alpha"


static func identity(channel: Channel) -> Variant:
	match channel:
		Channel.POSITION:
			return Vector2.ZERO
		Channel.SCALE:
			return Vector2.ONE
	return 1.0


static func get_layer(target: Control, channel: Channel, layer: StringName) -> Variant:
	var layers: Dictionary = target.get_meta(_META[channel], {})
	return layers.get(layer, identity(channel))


static func set_layer(target: Control, channel: Channel, layer: StringName, value: Variant) -> void:
	if channel == Channel.ALPHA and not target.has_meta(_BASE_ALPHA):
		target.set_meta(_BASE_ALPHA, target.modulate.a)
	var layers: Dictionary = target.get_meta(_META[channel], {})
	layers[layer] = value
	target.set_meta(_META[channel], layers)
	_compose(target, channel)


## Tweens one layer from its current value, replacing any tween on that layer.
static func tween_layer(
	target: Control,
	channel: Channel,
	layer: StringName,
	value: Variant,
	duration: float,
	transition := Tween.TRANS_QUAD,
	ease_type := Tween.EASE_OUT,
	delay := 0.0,
) -> Tween:
	return AutoTween.method(
		target,
		tween_key(channel, layer),
		func(current: Variant) -> void: set_layer(target, channel, layer, current),
		get_layer(target, channel, layer),
		value,
		duration,
		transition,
		ease_type,
		delay,
	)


static func tween_key(channel: Channel, layer: StringName) -> String:
	return "layer/%s/%s" % [Channel.keys()[channel], layer]


static func _compose(target: Control, channel: Channel) -> void:
	var layers: Dictionary = target.get_meta(_META[channel], {})
	match channel:
		Channel.POSITION:
			var total := Vector2.ZERO
			for value: Vector2 in layers.values():
				total += value
			target.offset_transform_enabled = true
			target.offset_transform_position = total
		Channel.SCALE:
			var total := Vector2.ONE
			for value: Vector2 in layers.values():
				total *= value
			target.offset_transform_enabled = true
			target.offset_transform_scale = total
		Channel.ALPHA:
			var total: float = target.get_meta(_BASE_ALPHA, 1.0)
			for value: float in layers.values():
				total *= value
			target.modulate.a = total
