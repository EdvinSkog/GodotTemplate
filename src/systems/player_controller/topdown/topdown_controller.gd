class_name TopDownController extends CharacterBody2D

static var ref: TopDownController

var speed := 300.0


var sprinting: bool = false
var direction: Vector2
var look_target: Vector2 = Vector2.UP

## Gets attached to the CameraRemote node so as to follow this controller.
@export var camera: Camera2D
@export var vision_cone: VisionCone2D

@export_category("Parameters")
@export_range(0.00, 1, 0.01) var turn_speed: float = 0.2
@export_range(0, 1) var snap_to_mouse_threshold : float = 0.4
@export_range(1, 10) var sprint_modifier: float = 3


func _ready() -> void:
	ref = self
	_setup.call_deferred()

func _setup() -> void:
	%CameraRemote.remote_path = camera.get_path()

func _physics_process(_delta: float) -> void:
	_handle_head()
	_handle_move()


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("sprint"):
		sprinting = true
	if event.is_action_released("sprint"):
		sprinting = false
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if event.is_action_pressed("interact"):
		_handle_interact()

func _handle_move() -> void:
	# Speed
	var _applied_speed := speed
	if sprinting:
		_applied_speed = _applied_speed * sprint_modifier
		vision_cone.width = vision_cone.width * 0.997
	else:
		vision_cone.width = VisionCone2D.BASE_WIDTH
	
	# Apply
	if direction:
		velocity = direction * _applied_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _applied_speed)
		velocity.y = move_toward(velocity.y, 0, _applied_speed)
	move_and_slide()



func _handle_head() -> void:
	if is_processing_unhandled_input(): look_target = get_global_mouse_position()
	var target: Vector2 = look_target
	if turn_speed <= 0.00:
		look_at(target)
		return

	var angle := get_angle_to(target) # Radians
	if angle > snap_to_mouse_threshold:
		rotate(1 * turn_speed)
	elif angle < -snap_to_mouse_threshold:
		rotate(-1 * turn_speed)
	else:
		rotate(angle)
	


func _handle_interact() -> void:
	pass # Add code here


func _on_vision_cone_2d_detected(_area: Area2D) -> void:
	pass
