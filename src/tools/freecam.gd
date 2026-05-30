extends Node



# References
var _original_camera_2d: Camera2D
var _original_camera_3d: Camera3D
@onready var camera_2d: Camera2D = %Camera2D
@onready var camera_3d: Camera3D = %Camera3D

func _ready() -> void:
	
	Scene.map_changed.connect(
		func() -> void:
		toggle.call_deferred(false)
		)

func is_active() -> bool:
	return camera_3d.current or camera_2d.is_current() 
	

func toggle(option: bool) -> void:
	var option_2d: bool = option
	var option_3d: bool = option
	
	if get_viewport().get_camera_3d() == camera_3d or get_viewport().get_camera_3d() == null:
		option_3d = false
	if get_viewport().get_camera_2d() == camera_2d or get_viewport().get_camera_2d() == null:
		option_2d = false
	
	option = option_2d or option_3d

	for controller: Node in get_tree().get_nodes_in_group(&"controller"):
			controller.set_process_unhandled_input(!option)
	if option:
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		
		process_mode = Node.PROCESS_MODE_DISABLED
	
	_handle_2d(option_2d)
	_handle_3d(option_3d)
	

func _handle_2d(option: bool) -> void:
	camera_2d.enabled = option
	$Input2D.set_process_input(option)
	$Input2D.set_process(option)
	_original_camera_2d = get_viewport().get_camera_2d()
	
	if _original_camera_2d:
		camera_2d.zoom = _original_camera_2d.zoom
		camera_2d.global_transform = _original_camera_2d.global_transform
	if option: camera_2d.make_current()
	else:
		if _original_camera_2d:
			_original_camera_2d.make_current()

func _handle_3d(option: bool) -> void:
	_original_camera_3d= get_viewport().get_camera_3d()
	
	$Input3D.set_process_input(option)
	$Input3D.set_process(option)
	
	if _original_camera_3d:
		camera_3d.global_transform = _original_camera_3d.global_transform
		camera_3d.fov =_original_camera_3d.fov
		camera_3d.projection = _original_camera_3d.projection
	camera_3d.current = option
	if option:
		camera_3d.make_current()
	else:
		if _original_camera_3d and _original_camera_3d != camera_3d:
			_original_camera_3d.make_current()
