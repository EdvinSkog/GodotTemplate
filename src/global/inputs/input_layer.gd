@icon("res://assets/icons/editor/joypad.svg")
class_name InputLayer extends Node

signal enabled

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
@export var custom_cursor: CustomCursor = null
## Even if no custom cursor is set, it removes the assigned cursor of ARROW
@export var reset_arrow_shape: bool = false
@export var update_mouse_mode: bool = true
@export_enum("No Change:-1", "Visible", "Hidden", "Captured", "Confined", "Confined Hidden") var mouse_mode: int = -1

enum CharacterName {REBECCA, MARY, LEAH}

@export var activate_on_ready: bool = true

## Timer for the custom cursor to utilize.
var _timer: Timer

func _ready() -> void:
	process_priority = 10
	set_process(false)
	if custom_cursor:
		_setup_cursor()
	
		#enable()
	InputManager.layers.append(self)
	if activate_on_ready: 
		await get_tree().process_frame
		InputManager.update_based_on_priority.call_deferred()

func _setup_cursor() -> void:
	if custom_cursor.delay <= 0:
		set_process(true)
	else:
		_timer = Timer.new()
		add_child(_timer)
		_timer.owner = self
		custom_cursor.timer = _timer
		_timer.wait_time = custom_cursor.delay
		_timer.timeout.connect(custom_cursor.next_anim_step)
	custom_cursor.initialize()

func _process(_delta: float) -> void:
	custom_cursor.next_anim_step()

func disable() -> void:
	toggle_group_inputs(false)
	if custom_cursor: custom_cursor.stop()


func enable() -> void:
	
	#if mouse_mode == Input.MOUSE_MODE_CAPTURED or mouse_mode == Input.MOUSE_MODE_HIDDEN:
		#pass
	if custom_cursor:
		custom_cursor.start()
	elif reset_arrow_shape:
		Input.set_custom_mouse_cursor(null)
	if mouse_mode != -1:
		Input.set_deferred(&"mouse_mode", mouse_mode)
	toggle_group_inputs(true)
	enabled.emit()

func toggle_group_inputs(option: bool = true) -> void:
	for group: StringName in groups_affected:
		get_tree().call_group(group, &"set_process_unhandled_input", option)
		get_tree().call_group(group, &"set_process_input", option)

#TODO
func is_enabled() -> bool:
	return true
