@icon("res://addons/at-icons/animation/arrow_right.svg")
class_name SequenceTweenEffect extends TweenEffect

## Plays its steps one after another, each starting when the previous one has
## finished. Save a sequence as a .tres to reuse a whole choreography as a single
## preset, for example "slide up, then pop".
##
## Every step's start state is applied up front, so nothing shows its resting
## state while earlier steps play. Forward (active) runs the steps in order;
## backward runs them in reverse, so a state trigger unwinds the choreography.
## Retriggering cancels a sequence that is still running. duration, transition
## and ease_type are unused; delay waits before the first step.

const _SERIAL_META_PREFIX := "_tween_sequence_"

## Effects played in order. A step may itself be a sequence.
@export var steps: Array[TweenEffect] = []
## Extra pause between steps, in seconds.
@export_range(0.0, 5.0, 0.01) var step_gap := 0.0


func supports(target: Control) -> bool:
	return steps.all(func(step: TweenEffect) -> bool: return step == null or step.supports(target))


func prepare(target: Control, layer: StringName) -> void:
	for index: int in steps.size():
		if steps[index]:
			steps[index].prepare(target, _step_layer(layer, index))


func play_start(target: Control, layer: StringName) -> void:
	_next_serial(target, layer)
	for index: int in steps.size():
		if steps[index]:
			steps[index].play_start(target, _step_layer(layer, index))


func play(target: Control, layer: StringName) -> void:
	_run(target, layer, true, false)


func apply(target: Control, layer: StringName, active: bool, instant: bool) -> void:
	if instant:
		_next_serial(target, layer)
		for index: int in steps.size():
			if steps[index]:
				steps[index].apply(target, _step_layer(layer, index), active, true)
		return
	_run(target, layer, active, true)


func get_duration(target: Control) -> float:
	var total := delay
	var counted := 0
	for step: TweenEffect in steps:
		if step:
			total += step.get_duration(target)
			counted += 1
	return total + step_gap * maxi(counted - 1, 0)


## Event triggers call each step's play(); state triggers drive each step's
## apply() so it continues from wherever it currently is.
func _run(target: Control, layer: StringName, active: bool, as_state: bool) -> void:
	var serial := _next_serial(target, layer)
	var order: Array = range(steps.size())
	if not active:
		order.reverse()
	var still_current: bool = await _wait(target, layer, serial, delay)
	if not still_current:
		return
	for position_in_order: int in order.size():
		var index: int = order[position_in_order]
		var step := steps[index]
		if not step:
			continue
		var step_layer := _step_layer(layer, index)
		if as_state:
			step.apply(target, step_layer, active, false)
		else:
			step.play(target, step_layer)
		var is_last := position_in_order == order.size() - 1
		var wait := step.get_duration(target) + (0.0 if is_last else step_gap)
		still_current = await _wait(target, layer, serial, wait)
		if not still_current:
			return


## Waits, then reports whether this run is still the latest one for the target.
func _wait(target: Control, layer: StringName, serial: int, seconds: float) -> bool:
	if seconds > 0.0 and is_instance_valid(target) and target.is_inside_tree():
		# process_always, ignore Engine.time_scale: matches AutoTween's UI tweens.
		await target.get_tree().create_timer(seconds, true, false, true).timeout
	return is_instance_valid(target) and target.is_inside_tree() \
		and int(target.get_meta(_serial_key(layer), 0)) == serial


func _next_serial(target: Control, layer: StringName) -> int:
	var serial := int(target.get_meta(_serial_key(layer), 0)) + 1
	target.set_meta(_serial_key(layer), serial)
	return serial


func _serial_key(layer: StringName) -> StringName:
	return StringName(_SERIAL_META_PREFIX + str(layer))


func _step_layer(layer: StringName, index: int) -> StringName:
	return StringName("%s_step%d" % [layer, index])
