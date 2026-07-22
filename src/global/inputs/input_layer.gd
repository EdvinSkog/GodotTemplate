@icon("res://assets/icons/editor/joypad.svg")
class_name InputLayer extends Node

signal updated_enabled(val: bool)
signal deactivated
signal activated

## Higher priority means this InputLayer will enable before other layers.
## If tied with another layer, last one called is the one that enables.
@export_range(-100, 100, 1) var priority: int = 0:
	set(val):
		priority = val
		if is_node_ready():
			InputManager.update_based_on_priority.call_deferred()
## (Not Implemented) To manage unhandled_input / input
@export var groups_affected: Array[StringName]
## If left to null, will use system OS cursor.
@export var custom_cursors: Array[CustomCursor] = []
var _single_frame_cursors: Array[CustomCursor]
var _frame_by_frame_cursors: Array[CustomCursor]
var _timer_delayed_cursors: Array[CustomCursor]

## Even if no custom cursor is set, it removes the assigned cursor of ARROW
@export var reset_arrow_shape: bool = false
@export var update_mouse_mode: bool = true
@export_enum("No Change:-1", "Visible", "Hidden", "Captured", "Confined", "Confined Hidden") var mouse_mode: int = -1

@export var enable_on_ready: bool = true

## Timer for the custom cursor to utilize.
var _timer: Timer
var _enabled: bool = false:
	set = set_enabled,
	get = is_enabled


func _ready() -> void:
	process_priority = 10
	set_process(false)
	InputManager.layers.append(self)
	if has_custom_cursor():
		for cursor in custom_cursors:
			_setup_cursor(cursor)
	set_enabled.call_deferred(enable_on_ready)

func _setup_cursor(custom_cursor: CustomCursor) -> void:
	if custom_cursor.textures.size() == 1:
		_single_frame_cursors.append(custom_cursor)
		custom_cursor.initialize.call_deferred()
		return
	if custom_cursor.delay <= 0 or custom_cursor.force_frame_by_frame_update:
		_frame_by_frame_cursors.append(custom_cursor)
	else:
		_timer_delayed_cursors.append(custom_cursor)
		_timer = Timer.new()
		add_child(_timer)
		custom_cursor.timer = _timer
		_timer.wait_time = custom_cursor.delay
		_timer.timeout.connect(custom_cursor.next_anim_step)
	custom_cursor.initialize.call_deferred()

func has_custom_cursor() -> bool:
	return !custom_cursors.is_empty()

func _process(_delta: float) -> void:
	for cursor in _frame_by_frame_cursors:
		cursor.next_anim_step()

## Updates priority as well
func set_enabled(option: bool) -> void:
	_enabled = option
	if option: enable()
	else: disable()


func activate() -> void:
	if !_enabled:
		push_warning("Activated ", name, " without being enabled.")
	set_process(true)
	toggle_group_inputs(true)
	if has_custom_cursor():
		for cursor in custom_cursors:
			cursor.start()
	elif reset_arrow_shape:
		Input.set_custom_mouse_cursor(null)
	if mouse_mode != -1:
		Input.set_deferred(&"mouse_mode", mouse_mode)
	activated.emit()

func deactivate(only_disable_certain_shapes: Array[Input.CursorShape] = []) -> void:
	set_process(false)
	toggle_group_inputs(false)
	if has_custom_cursor():
		for cursor in custom_cursors:
			if only_disable_certain_shapes.is_empty():
				cursor.stop() # We stop all cursors
			elif only_disable_certain_shapes.has(cursor.shape): 
				cursor.stop() # We stop certain cursors
	deactivated.emit()


func is_enabled() -> bool:
	return _enabled

func toggle_group_inputs(option: bool = true) -> void:
	for group: StringName in groups_affected:
		get_tree().call_group(group, &"set_process_unhandled_input", option)
		get_tree().call_group(group, &"set_process_input", option)
