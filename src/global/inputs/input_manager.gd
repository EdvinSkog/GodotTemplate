extends Node

var layers: Array[InputLayer] = []

var enabled_layers: Array[InputLayer]:
	get = get_enabled_layers

@onready var orphan_timers: Node = %CustomCursorOrphanTimers


func _ready() -> void:
	var project_setting_cursor: String = ProjectSettings.get_setting("display/mouse_cursor/custom_image")
	assert(project_setting_cursor == "", "Utilize InputManager's default input layer for custom cursors instead.")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

var _updating_inputs: bool = false

func update_based_on_priority() -> void:
	if _updating_inputs: return
	
	_updating_inputs = true
	var prev_mode := Input.mouse_mode
	if is_mouse_visible(): Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var _layers := enabled_layers.duplicate()
	var highest_priority_layer: InputLayer = _layers.pop_front()
	var affected_cursor_shapes: Array[Input.CursorShape] = []
	if highest_priority_layer and highest_priority_layer.keep_unaffected_shapes:
		affected_cursor_shapes = highest_priority_layer.get_affected_shapes()
	for remaining_input: InputLayer in _layers:
		remaining_input.disable(affected_cursor_shapes)
	
	
	
	await get_tree().process_frame # To prevent duplicate calls
	if highest_priority_layer:
		if highest_priority_layer.mouse_mode == -1: Input.mouse_mode = prev_mode
		highest_priority_layer.enable()
	_updating_inputs = false
	
	

## Reset to normal OS-cursor
func reset() -> void:
	for each in layers:
		each.set_enabled(false)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)

func get_enabled_layers() -> Array[InputLayer]:
	var _filtered_layers := layers.filter(
		func(val: InputLayer) -> bool: return val.is_enabled()
	)
	# Sort by priority
	_filtered_layers.sort_custom(
		func(a: InputLayer, b: InputLayer) -> bool: return a.priority > b.priority
	)
	return _filtered_layers

func is_mouse_visible() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_VISIBLE or Input.mouse_mode == Input.MOUSE_MODE_CONFINED
