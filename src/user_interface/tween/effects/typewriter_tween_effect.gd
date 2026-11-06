@icon("res://addons/at-icons/node/text.svg")
class_name TypewriterTweenEffect extends TweenEffect

## Inactive: no text. Active: all text. Reveals or removes one character at a
## time at characters_per_second, continuing from wherever it is, so leaving a
## hover mid-word un-types from that point. duration and transition are unused.
##
## Labels and RichTextLabels use visible_ratio. Buttons have no such property, so
## their text is rewritten; lock_button_width keeps the full-text width so the
## layout does not shift while typing. The full text is captured once at
## prepare(), so text changed later from code is not picked up.

const _FULL_TEXT := &"_typewriter_full_text"
const _PROGRESS := &"_typewriter_progress"
const _TWEEN_KEY := "typewriter"

@export_range(1.0, 400.0, 1.0) var characters_per_second := 40.0
## Buttons only: keep the full-text width while typing so the layout stays still.
@export var lock_button_width := true


func supports(target: Control) -> bool:
	return target is Button or target is Label or target is RichTextLabel


func prepare(target: Control, _layer: StringName) -> void:
	var button := target as Button
	if not button:
		return
	if not target.has_meta(_FULL_TEXT):
		target.set_meta(_FULL_TEXT, button.text)
	if lock_button_width:
		button.custom_minimum_size.x = maxf(
			button.custom_minimum_size.x, button.get_combined_minimum_size().x,
		)


func apply(target: Control, _layer: StringName, active: bool, instant: bool) -> void:
	var to_value := 1.0 if active else 0.0
	var from_value: float = target.get_meta(_PROGRESS, 1.0)
	var seconds := absf(to_value - from_value) * _length(target) / characters_per_second
	if instant or seconds <= 0.0:
		AutoTween.kill(target, _TWEEN_KEY)
		_set_progress(target, to_value)
		return
	AutoTween.method(
		target,
		_TWEEN_KEY,
		func(value: float) -> void: _set_progress(target, value),
		from_value,
		to_value,
		seconds,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		delay,
	)


func get_duration(target: Control) -> float:
	return delay + _length(target) / characters_per_second


func _length(target: Control) -> int:
	if target is Button:
		return str(target.get_meta(_FULL_TEXT, (target as Button).text)).length()
	if target is Label:
		return (target as Label).get_total_character_count()
	return (target as RichTextLabel).get_total_character_count()


func _set_progress(target: Control, value: float) -> void:
	target.set_meta(_PROGRESS, value)
	if target is Button:
		var full := str(target.get_meta(_FULL_TEXT, ""))
		(target as Button).text = full.substr(0, roundi(value * full.length()))
	elif target is Label:
		(target as Label).visible_ratio = value
	else:
		(target as RichTextLabel).visible_ratio = value
