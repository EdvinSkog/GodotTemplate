extends Node

var layers: Array[InputLayer] = []

var enabled_layers: Array[InputLayer]:
	get = get_enabled_layers

@onready var orphan_timers: Node = %CustomCursorOrphanTimers


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	

#func start_default_custom_cursors() -> void:
	#for cursor: CustomCursor in custom_cursor_for_shapes.values().filter(
		#func(val: CustomCursor) -> bool: return val != null
	#):
		#cursor.start()

var _updating_inputs: bool = false
func update_based_on_priority() -> void:
	if _updating_inputs: return
	_updating_inputs = true
	
	var _layers := enabled_layers.duplicate()
	print(_layers)
	var highest_priority_layer: InputLayer = _layers.pop_front()
	print("High:", highest_priority_layer.name)
	for remaining_input: InputLayer in _layers:
		remaining_input.disable()
	
	
	
	await get_tree().process_frame # To prevent duplicate calls
	if highest_priority_layer:
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
