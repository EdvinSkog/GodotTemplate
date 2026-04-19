class_name SettingsManager extends Node

## A graphics setting was updated.
signal graphics_updated
## A display setting was updated.
signal display_updated
signal window_mode_toggled(mode: DisplayServer.WindowMode)

const MAX_FPS_CHOICES: Array[int] = [30, 60, 120, 144, -1]

var _save_manager: SaveManager:
	get: return Game.save

func _ready() -> void:
	await owner.ready
	if !_save_manager.use_save_files:
		return #No save files used
	_setup.call_deferred()
	

func _setup() -> void:
	var value : Variant = _get_value("display/max_fps")
	set_max_fps(value)
	set_vsync(_get_value("graphics/vsync"))

## Wrapper for getting value in SaveManager
func _get_value(key: StringName) -> Variant:
	var value: Variant = _save_manager.get_value(key, _save_manager.settings_data)
	return value

## Wrapper for saving value in SaveManager
func _save(key: StringName, value: Variant) -> void:
	_save_manager.save(key, value, true, _save_manager.SETTINGS_FILE_PATH)

func _process(_delta: float) -> void:
	pass

#region Screens

func set_window_mode(value: bool) -> void:
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save("display/fullscreen", value)
	display_updated.emit()

func get_window_mode() -> bool:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
		return true
	elif mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
		return false
	else:
		push_error("Wrong window mode")
	return false
	

## For Debugging
func no_save_toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	window_mode_toggled.emit(DisplayServer.window_get_mode())

func set_current_screen(value: int) -> void:
	get_window().current_screen = value
	display_updated.emit()
	
func get_current_screen() -> int:
	return get_window().current_screen

func get_screens_amount() -> int:
	return DisplayServer.get_screen_count()

func set_resolution(value: Vector2i) -> void:
	get_tree().root.content_scale_size = value

#endregion

#region Framerate

func set_max_fps(value: int) -> void:
	Engine.max_fps = value
	_save("display/max_fps", value)
	display_updated.emit()

func get_max_fps() -> int:
	return Engine.max_fps

#endregion

#region Graphics

func set_vsync(value: DisplayServer.VSyncMode) -> void:
	if value == DisplayServer.VSyncMode.VSYNC_MAILBOX:
		push_error("Tried applying Mailbox VSync - not allowed.")
		return
	DisplayServer.window_set_vsync_mode(value)
	_save("graphics/vsync", value)
	graphics_updated.emit()

func get_vsync() -> DisplayServer.VSyncMode:
	return DisplayServer.window_get_vsync_mode()

#endregion
