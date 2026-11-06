@icon("res://addons/at-icons/node/arrow_axes.svg")
class_name TweenTrigger extends Node

## Decides [b]when[/b] its effects play on the parent Control.
## The effects decide [b]what[/b] is animated.
## One effect (a typewriter, a scale pop) can be reused with any
## trigger. Add several TweenTriggers to one Control for different moments.
##
## Event triggers play each effect from its start state to rest. State triggers
## drive effects forward while the state holds and back when it ends, continuing
## from wherever they are (a typewriter un-types mid-word).

enum Trigger {
	## Event: once, when the scene is ready and actually visible.
	ON_READY,
	## Event: every time the Control becomes visible.
	ON_SHOWN,
	## Event: whenever the parent button is pressed.
	ON_PRESSED,
	## State: while the mouse is over the Control.
	WHILE_HOVERED,
	## State: while the Control has keyboard or gamepad focus.
	WHILE_FOCUSED,
	## State: while hovered or focused, so menus behave the same without a mouse.
	WHILE_HOVERED_OR_FOCUSED,
	## State: while the parent button is held down.
	WHILE_HELD,
}

## Frames whose delta exceeds this are treated as loading hitches and skipped.
const _HITCH_DELTA := 0.1
const _MAX_SETTLE_FRAMES := 10

@export var trigger := Trigger.ON_READY
@export var effects: Array[TweenEffect] = []
## Event triggers: switch off mouse and keyboard focus for the Control and all of
## its children while the effects play (entrance and exit), so nothing can be
## clicked mid-transition. Uses Control.mouse_behavior_recursive and
## focus_behavior_recursive, restoring the previous values afterwards.
@export var block_input_while_playing := false

var _target: Control
var _hovered := false
var _focused := false
var _held := false
var _active := false
var _play_serial := 0
var _input_blocked := false
var _saved_mouse_behavior := Control.MOUSE_BEHAVIOR_INHERITED
var _saved_focus_behavior := Control.FOCUS_BEHAVIOR_INHERITED


func _ready() -> void:
	_target = get_parent() as Control
	if not _target:
		push_warning("%s must be a child of a Control" % name)
		return
	for index: int in effects.size():
		var effect := effects[index]
		if effect and effect.supports(_target):
			effect.prepare(_target, _layer(index))
		elif effect:
			push_warning("%s cannot animate %s" % [effect.resource_path, _target.name])
	match trigger:
		Trigger.ON_READY:
			if _target.is_visible_in_tree():
				_play_event(true)
		Trigger.ON_SHOWN:
			_target.visibility_changed.connect(_on_visibility_changed)
			if _target.is_visible_in_tree():
				_play_event(true)
		Trigger.ON_PRESSED:
			var button := _require_button()
			if button:
				button.pressed.connect(_play_event.bind(false))
		_:
			_connect_state_signals()
			_apply_all(false, true)


#region Events

func _play_event(wait_until_presentable: bool) -> void:
	# The start state is applied at once so the resting state never flashes.
	_for_each_effect(func(effect: TweenEffect, layer: StringName) -> void:
		effect.play_start(_target, layer)
	)
	_play_serial += 1
	var serial := _play_serial
	_set_input_blocked(true)
	if wait_until_presentable:
		await _wait_until_presentable()
	if serial != _play_serial or not is_instance_valid(_target) or not _target.is_inside_tree():
		return
	_for_each_effect(func(effect: TweenEffect, layer: StringName) -> void:
		effect.play(_target, layer)
	)
	await _wait_seconds(_get_longest_duration())
	if serial == _play_serial:
		_set_input_blocked(false)


## Scenes are added while the loading screen is still fading out, and the first
## frames after a scene appears are often long enough to finish a short tween in
## a single step. Waiting for both keeps entrance animations visible.
func _wait_until_presentable() -> void:
	var loading: LoadingManager = Scene.loading if Scene else null
	if loading and loading.is_transitioning():
		await loading.transition_finished
	for _frame: int in _MAX_SETTLE_FRAMES:
		await get_tree().process_frame
		if get_process_delta_time() < _HITCH_DELTA:
			return


func _on_visibility_changed() -> void:
	if _target.is_visible_in_tree():
		_play_event(true)

#endregion


#region Exit

## Plays this trigger's entrance backwards and returns once it has finished.
## Only event triggers (ready, shown, pressed) have an entrance to reverse;
## a sequence unwinds in reverse step order.
func play_exit() -> void:
	if not is_event_trigger() or not is_instance_valid(_target):
		return
	# Also cancels an entrance that is still waiting to start.
	_play_serial += 1
	_set_input_blocked(true)
	_apply_all(false, false)
	await _wait_seconds(_get_longest_duration())


## Plays the exit of every event TweenTrigger at or below root together and
## returns when the longest one has finished. Await it before hiding or freeing
## a screen:  await TweenTrigger.play_exit_on(self)
static func play_exit_on(root: Node) -> void:
	var longest := 0.0
	for node: Node in [root] + root.find_children("*", "", true, false):
		var exit_trigger := node as TweenTrigger
		if exit_trigger and exit_trigger.is_event_trigger():
			longest = maxf(longest, exit_trigger._get_longest_duration())
			exit_trigger.play_exit()
	if longest > 0.0 and root.is_inside_tree():
		await root.get_tree().create_timer(longest, true, false, true).timeout


func is_event_trigger() -> bool:
	return trigger in [Trigger.ON_READY, Trigger.ON_SHOWN, Trigger.ON_PRESSED]

#endregion


#region States

func _connect_state_signals() -> void:
	match trigger:
		Trigger.WHILE_HOVERED, Trigger.WHILE_HOVERED_OR_FOCUSED:
			_target.mouse_entered.connect(_set_hovered.bind(true))
			_target.mouse_exited.connect(_set_hovered.bind(false))
	match trigger:
		Trigger.WHILE_FOCUSED, Trigger.WHILE_HOVERED_OR_FOCUSED:
			_target.focus_entered.connect(_set_focused.bind(true))
			_target.focus_exited.connect(_set_focused.bind(false))
	if trigger == Trigger.WHILE_HELD:
		var button := _require_button()
		if button:
			button.button_down.connect(_set_held.bind(true))
			button.button_up.connect(_set_held.bind(false))
			_target.mouse_exited.connect(_set_held.bind(false))


func _set_hovered(value: bool) -> void:
	_hovered = value
	_refresh_state()


func _set_focused(value: bool) -> void:
	_focused = value
	_refresh_state()


func _set_held(value: bool) -> void:
	_held = value
	_refresh_state()


func _refresh_state() -> void:
	var button := _target as BaseButton
	var active := false
	if not (button and button.disabled):
		match trigger:
			Trigger.WHILE_HOVERED:
				active = _hovered
			Trigger.WHILE_FOCUSED:
				active = _focused
			Trigger.WHILE_HOVERED_OR_FOCUSED:
				active = _hovered or _focused
			Trigger.WHILE_HELD:
				active = _held
	if active == _active:
		return
	_active = active
	_apply_all(active, false)

#endregion


func _get_longest_duration() -> float:
	var longest := 0.0
	for effect: TweenEffect in effects:
		if effect and is_instance_valid(_target) and effect.supports(_target):
			longest = maxf(longest, effect.get_duration(_target))
	return longest


## Waits in real time, unaffected by pause and Engine.time_scale, like UI tweens.
func _wait_seconds(seconds: float) -> void:
	if seconds > 0.0 and is_inside_tree():
		await get_tree().create_timer(seconds, true, false, true).timeout


func _set_input_blocked(blocked: bool) -> void:
	if not block_input_while_playing or blocked == _input_blocked or not is_instance_valid(_target):
		return
	_input_blocked = blocked
	if blocked:
		_saved_mouse_behavior = _target.mouse_behavior_recursive
		_saved_focus_behavior = _target.focus_behavior_recursive
		_target.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		_target.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		var focus_owner: Control = _target.get_viewport().gui_get_focus_owner() if _target.is_inside_tree() else null
		if focus_owner and (focus_owner == _target or _target.is_ancestor_of(focus_owner)):
			focus_owner.release_focus()
	else:
		_target.mouse_behavior_recursive = _saved_mouse_behavior
		_target.focus_behavior_recursive = _saved_focus_behavior


func _apply_all(active: bool, instant: bool) -> void:
	_for_each_effect(func(effect: TweenEffect, layer: StringName) -> void:
		effect.apply(_target, layer, active, instant)
	)


func _for_each_effect(callable: Callable) -> void:
	for index: int in effects.size():
		var effect := effects[index]
		if effect and effect.supports(_target):
			callable.call(effect, _layer(index))


## Unique per trigger and effect slot, so two triggers using the same shared
## effect resource still animate independent layers.
func _layer(index: int) -> StringName:
	return StringName("%d_%d" % [get_instance_id(), index])


func _require_button() -> BaseButton:
	var button := _target as BaseButton
	if not button:
		push_warning("%s: %s needs a BaseButton parent" % [name, Trigger.keys()[trigger]])
	return button
