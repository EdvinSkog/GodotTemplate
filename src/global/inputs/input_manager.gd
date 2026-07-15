extends Node

const custom_cursor_shape_used: Input.CursorShape = Input.CURSOR_ARROW



static var layers: Array[InputLayer]

static var enabled_layers: Array[InputLayer]:
	get = get_enabled_layers

@export var test_textures: Array[Texture2D]
@export var test_cursor: CustomCursor

#region Cursors
@export var default_input_layer: InputLayer
@export_group("Default Custom Cursors")
@export var bdiag: CustomCursor
@export var busy: CustomCursor
@export var can_drop: CustomCursor
@export var cross: CustomCursor
@export var drag: CustomCursor
@export var fdiag: CustomCursor
@export var forbidden: CustomCursor
@export var help: CustomCursor
@export var hsize: CustomCursor
@export var hsplit: CustomCursor
@export var ibeam: CustomCursor
@export var move: CustomCursor
@export var pointing_hand: CustomCursor
@export var vsize: CustomCursor
@export var vsplit: CustomCursor
@export var wait: CustomCursor

## A default custom cursor for each shape [b]except[/b] for CURSOR_ARROW, the default one.
@onready var custom_cursor_for_shapes: Dictionary[Input.CursorShape, CustomCursor] = {
	Input.CURSOR_BDIAGSIZE: bdiag,
	Input.CURSOR_BUSY: busy,
	Input.CURSOR_CAN_DROP: can_drop,
	Input.CURSOR_CROSS: cross,
	Input.CURSOR_DRAG: drag,
	Input.CURSOR_FDIAGSIZE: fdiag,
	Input.CURSOR_FORBIDDEN: forbidden,
	Input.CURSOR_HELP: help,
	Input.CURSOR_HSIZE: hsize,
	Input.CURSOR_HSPLIT: hsplit,
	Input.CURSOR_IBEAM: ibeam,
	Input.CURSOR_MOVE: move,
	Input.CURSOR_POINTING_HAND: pointing_hand,
	Input.CURSOR_VSIZE: vsize,
	Input.CURSOR_VSPLIT: vsplit,
	Input.CURSOR_WAIT: wait
}:
	set(val):
		custom_cursor_for_shapes = val
		custom_cursor_for_shapes.make_read_only()
#endregion


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	#for cursor: CustomCursor in custom_cursor_for_shapes.values().filter(
		#func(val: CustomCursor) -> bool: return val != null
	#):
		#cursor.start()
var _updating_inputs: bool = false
func update_based_on_priority() -> void:
	if _updating_inputs: return
	_updating_inputs = true
	var _layers := get_enabled_layers()
	var highest_priority_layer: InputLayer = _layers.pop_front()
	for remaining_input in _layers:
		remaining_input.disable()

	
	await get_tree().process_frame # To prevent duplicate calls
	highest_priority_layer.enable()
	_updating_inputs = false
	
	

## Reset to normal OS-cursor
func reset() -> void:
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
