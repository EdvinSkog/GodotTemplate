extends CharacterBody2D

# Movement
const SPEED: float = 1000
var direction: Vector2

# References
var _original_camera: Camera2D
@onready var camera: Camera2D = $Camera2D


func _input(event: InputEvent) -> void:
	if event.is_action("ui_zoom_in"):
		camera.zoom += Vector2(0.1, 0.1)
	
	if event.is_action("ui_zoom_out"):
		camera.zoom -= Vector2(0.1, 0.1)


func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED / camera.zoom
	move_and_slide()

func toggle(option: bool) -> void:
	if get_viewport().get_camera_2d() == camera: option = false
	
	
	set_process_input(option)
	camera.enabled = option
	if option:
		process_mode = Node.PROCESS_MODE_ALWAYS
		_original_camera = get_viewport().get_camera_2d()
		camera.zoom = _original_camera.zoom
		camera.global_transform = _original_camera.global_transform
		camera.make_current()
		
		
	elif _original_camera:
		_original_camera.make_current()
		process_mode = Node.PROCESS_MODE_DISABLED
