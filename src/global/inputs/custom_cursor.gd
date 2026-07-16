@icon("res://assets/icons/editor/cursor.svg")
class_name CustomCursor extends Resource


signal started
signal stopped

@export var textures: Array[Texture2D]
## Requires an assigned timer-node.
## A value of 0 means frame-by-frame
@export_range(0, 10) var delay: float = 0.4:
	set(value):
		value = clampf(value, 0.0, 10)
		delay = value

## Does the loop reverse once it reaches one end?
@export var loop_is_clamped: bool = false
@export_group("Extra")
@export var shape: Input.CursorShape = Input.CURSOR_ARROW
## If not modified, uses project setting as default.
@export var hotspot: Vector2 = DEFAULT_HOTSPOT

## Taken from ProjectSettings
static var DEFAULT_HOTSPOT: Vector2 = ProjectSettings.get_setting("display/mouse_cursor/custom_image_hotspot")

## A timer node to be assigned by an InputLayer
var timer: Timer
var enabled: bool = false

func validate_textures() -> bool:
	if textures == null: return false
	return textures.all(
		func(texture: Texture2D) -> bool:
			return texture.get_size() <= Vector2(128, 128)
	)

var _initialized: bool = false

func start() -> void:
	assert(validate_textures(), "Custom cursor's texture failed validation.")
	if !_initialized: initialize()
	
	enabled = true
	next_anim_step(false)
	if !is_animated():
		next_anim_step() # Single call.
	elif delay <= 0:
		pass # Frame-by-frame, handled by InputLayer
	else:
		assert(timer != null)
		timer.start()
	started.emit()

## This is needed so as to avoid
## a frame of the default cursor being visible due to animation desyncs.
func initialize() -> void:
	
	#var prev_mouse_mode := Input.mouse_mode
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#Input.mouse_mode = prev_mouse_mode
	if timer == null and is_animated():
		timer = Timer.new()
		timer.wait_time = delay
		InputManager.orphan_timers.add_child(timer)
		timer.timeout.connect(next_anim_step)
	_initialized = true
	
## To be called by timer's timeout signal.
var _index: int = 0:
	set(val):
		val = clampi(val, 0, textures.size() - 1)
		_index = val

func next_anim_step(has_to_match_shape: bool = true) -> void:
	var stored_shape := Input.get_current_cursor_shape()
	if stored_shape != shape and has_to_match_shape: return
	if textures.is_empty():
		Input.set_custom_mouse_cursor(null, shape)
	else:
		Input.set_custom_mouse_cursor(textures[_index], shape, hotspot)
	if _index >= textures.size() - 1:
		if loop_is_clamped:
			textures.reverse()
		_index = 1 # we skip first element because it repeats.
	else:
		_index += 1

func stop() -> void:
	Input.set_custom_mouse_cursor(null, shape)
	enabled = false
	if timer: timer.stop()
	stopped.emit()

func is_animated() -> bool:
	return textures.size() > 1
