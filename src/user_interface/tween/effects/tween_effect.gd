@icon("res://addons/at-icons/node/arrow_turn_down_right.svg")
class_name TweenEffect extends Resource

## [b]What[/b] a TweenTrigger animates. Effects are shared resources: one .tres
## may serve many Controls, so they must keep no per-target state. Store it on
## the target (OffsetLayers, AutoTween keys or metadata) instead.
##
## "Active" is the effect's highlighted state (a hover scale, fully typed text,
## an entrance at rest); "inactive" is its other end.

@export_range(0.01, 5.0, 0.01) var duration := 0.25
@export var transition := Tween.TRANS_QUAD
@export var ease_type := Tween.EASE_OUT
## Seconds to wait before animating. Use increasing values to stagger siblings.
@export_range(0.0, 5.0, 0.01) var delay := 0.0


func supports(_target: Control) -> bool:
	return true


## One-time setup when the trigger is ready.
func prepare(_target: Control, _layer: StringName) -> void:
	pass


## Moves to the active or inactive end, instantly or animated from where it is.
func apply(_target: Control, _layer: StringName, _active: bool, _instant: bool) -> void:
	pass


## Event triggers: jump to the start state (applied before any waiting).
func play_start(target: Control, layer: StringName) -> void:
	apply(target, layer, false, true)


## Event triggers: animate from the start state to rest.
func play(target: Control, layer: StringName) -> void:
	apply(target, layer, true, false)


## Ease for animating toward active or inactive. Going back to inactive uses the
## mirrored ease, so a reverse looks like the forward animation played backwards.
func get_ease(active: bool) -> Tween.EaseType:
	if active:
		return ease_type
	match ease_type:
		Tween.EASE_OUT:
			return Tween.EASE_IN
		Tween.EASE_IN:
			return Tween.EASE_OUT
	return ease_type


## Seconds from starting until this effect has finished, including delay.
## SequenceTweenEffect waits this long before starting its next step.
func get_duration(_target: Control) -> float:
	return delay + duration
