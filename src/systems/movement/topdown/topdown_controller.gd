class_name TopDownController extends CharacterBody2D


var speed := 300.0
var sprint_modifier: float = 3


var sprinting: bool = false
var direction: Vector2

## Gets attached to the CameraRemote node so as to follow this controller.
@export var camera: Camera2D

@export_category("Parameters")
@export_range(0.00, 1, 0.01) var turn_speed: float = 0.2

func _ready() -> void:
	_setup.call_deferred()

func _setup() -> void:
	$CameraRemote.remote_path = camera.get_path()
	Player.toppc = self
	Player.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(_delta: float) -> void:
	_handle_move()
	_handle_head()

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
	
	# Apply
	if direction:
		velocity = direction * _applied_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _applied_speed)
		velocity.y = move_toward(velocity.y, 0, _applied_speed)
	move_and_slide()



func _handle_head() -> void:
	var target: Vector2 = get_global_mouse_position()
	if turn_speed <= 0.00:
		look_at(target)
		return

	var angle := get_angle_to(target) # Radians
	if angle > 0.4:
		rotate(1 * turn_speed)
	elif angle < -0.4:
		rotate(-1 * turn_speed)
	else:
		rotate(angle)
	


func _handle_interact() -> void:
	pass # Add code here
