@icon("res://assets/icons/editor/joypad.svg")
class_name InputLayer extends Node

signal enabled
signal disabled

## Higher priority means this InputLayer will enable before other layers.
## If tied with another layer, last one called is the one that enables.
@export_range(-100, 100, 1) var priority: int = 0:
	set(val):
		priority = val
		if is_node_ready():
			InputManager.update_based_on_priority.call_deferred()
## To manage unhandled_input / input on nodes within these groups.
@export var groups_affected: Array[StringName]
## A custom cursor with null texture will use system OS cursor.
@export var custom_cursors: Array[CustomCursor] = []
var _single_frame_cursors: Array[CustomCursor]
var _frame_by_frame_cursors: Array[CustomCursor]
var _timer_delayed_cursors: Array[CustomCursor]

@export_enum("No Change:-1", "Visible", "Hidden", "Captured", "Confined", "Confined Hidden") var mouse_mode: int = -1

@export var enable_on_ready: bool = true
## Only modify cursor shapes that the custom cursors contain.
@export var keep_unaffected_shapes: bool = false

## Timer for the custom cursor to utilize.
var _timer: Timer
var _enabled: bool = false:
	set = set_enabled,
	get = is_enabled


func has_custom_cursor() -> bool:
	return !custom_cursors.is_empty()

func _ready() -> void:
	process_priority = 10
	set_process(false)
	if has_custom_cursor():
		for cursor in custom_cursors:
			_setup_cursor(cursor)

	InputManager.layers.append(self)
	set_enabled.call_deferred(enable_on_ready)
	await get_tree().process_frame

func _setup_cursor(custom_cursor: CustomCursor) -> void:
	if !custom_cursor.is_animated():
		_single_frame_cursors.append(custom_cursor)
		return
	if custom_cursor.delay <= 0:
		_frame_by_frame_cursors.append(custom_cursor)
		set_process(true)
	else:
		_timer_delayed_cursors.append(custom_cursor)
		_timer = Timer.new()
		add_child(_timer)
		custom_cursor.timer = _timer
		_timer.wait_time = custom_cursor.delay
		_timer.timeout.connect(custom_cursor.next_anim_step)

func _process(_delta: float) -> void:
	for cursor in _frame_by_frame_cursors:
		cursor.next_anim_step()

func set_enabled(option: bool) -> void:
	_enabled = option
	if option: enable()
	else: disable()
	InputManager.update_based_on_priority()

func disable(only_disable_certain_shapes: Array[Input.CursorShape] = []) -> void:
	toggle_group_inputs(false)
	if has_custom_cursor():
		for cursor in custom_cursors:
			if only_disable_certain_shapes.is_empty():
				cursor.stop()
			elif only_disable_certain_shapes.has(cursor.shape): 
				cursor.stop()
			
	disabled.emit()

func enable() -> void:
	if has_custom_cursor():
		for cursor in custom_cursors:
			cursor.start()
	if mouse_mode != -1: # Change mouse mode
		Input.set_deferred(&"mouse_mode", mouse_mode)
	toggle_group_inputs(true)
	enabled.emit()

func is_enabled() -> bool:
	return _enabled

func toggle_group_inputs(option: bool = true) -> void:
	for group: StringName in groups_affected:
		get_tree().call_group(group, &"set_process_unhandled_input", option)
		get_tree().call_group(group, &"set_process_input", option)

func get_affected_shapes() -> Array[Input.CursorShape]:
	var arr: Array[Input.CursorShape]
	for cursor in custom_cursors:
		arr.append(cursor.shape)
	return arr
