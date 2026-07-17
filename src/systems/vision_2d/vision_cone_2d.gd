@icon("res://assets/icons/editor/2d/eye.svg")
@tool
class_name VisionCone2D extends Node2D

signal detected(area: Area2D)

@export_group("References")
@export var canvas_group: CanvasGroup
@export_category("Parameters")
const BASE_STRENGTH: float = 0.5
const BASE_WIDTH: float = 0.5
@export_range(0.05, 1) var strength: float = BASE_STRENGTH:
	set = set_strength
@export_range(0.05, 1) var width: float = BASE_WIDTH:
	set = set_width

const RANGE: float = 2048


func set_strength(val: float) -> void:
	if !is_node_ready(): await ready
	val = clampf(val, 0.05, 1)
	strength = val
	for light in get_affected_lights():
		light.texture_scale = 2 * pow(2 * strength, 2)
		light.update()

func set_width(val: float) -> void:
	if !is_node_ready(): await ready
	val = clampf(val, 0.05, 1)
	width = val
	for light in get_affected_lights():
		light.scale.y = 2 * pow(2 * width, 2)
		light.update()

func get_lights() -> Array[VisionConeLight2D]:
	return canvas_group.get_children() as Array[VisionConeLight2D]

func get_affected_lights() -> Array[VisionConeLight2D]:
	return get_lights().filter(
		func(light: VisionConeLight2D) -> bool: 
			return !light.unaffected_by_params
	)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	update_detection_shapes()
	
func update_detection_shapes() -> void:
	# TODO Clean up this spaghetti
	var size: Vector2 = Vector2(1024, 512)
	#if !%RayCast2D.is_colliding():
		#%CollisionCone.scale.x = %RayCast2D.target_position.x / size.x
		#return
	
	var dist := get_ray_distance(%CenterRay)
	%CollisionCone.scale.x = dist / size.x 
	%CollisionCone.scale.y = dist / size.y 
	
	
	%UpRay.rotation_degrees += 1 if %UpRay.is_colliding() else -1
	%UpRay.rotation_degrees = clampf(%UpRay.rotation_degrees, -45, -1)
	scan_rotate(%InnerDownRay, 5, %OuterDownRay.rotation_degrees, true)
	scan_rotate(%OuterDownRay, %InnerDownRay.rotation_degrees, 45)

	
	var down_factor := get_normalized_angle(%OuterDownRay.rotation)
	var up_factor := get_normalized_angle(-%UpRay.rotation)
	var x_size: float = get_x_size_from_ray(%CenterRay)
	var up_y_size: float = -clampf(x_size * up_factor, 70, x_size)
	var down_y_size: float = clampf(x_size * down_factor, 70, x_size)
	%CollPoly.polygon = [
		Vector2(x_size, up_y_size),
		Vector2(x_size, -50),
		Vector2(x_size, 50),
		Vector2(x_size, down_y_size),
		Vector2.ZERO
	]
	
	# Maybe: dynamically create new rays going each direction until max degree is reached
	
	
## Angle is radian
func get_normalized_angle(angle: float) -> float:
	const MIN_ANGLE = deg_to_rad(1.0)
	const MAX_ANGLE = deg_to_rad(45.0)
	return clampf(inverse_lerp(MIN_ANGLE, MAX_ANGLE, angle), 0, 1)

func get_ray_distance(ray: RayCast2D) -> float:
	if !ray.is_colliding(): return ray.target_position.x
	var coll_point: Vector2 = ray.get_collision_point()
	
	return global_position.distance_to(coll_point)

func get_x_size_from_ray(ray: RayCast2D) -> float:
	return RANGE * inverse_lerp(1, RANGE, get_ray_distance(ray))

func scan_rotate(ray: RayCast2D, min_angle: float, max_angle: float, inwards: bool = false) -> void:
	var rate: float = 1
	if inwards: rate = -1
	ray.rotation_degrees += (-rate if ray.is_colliding() else rate)
	ray.rotation_degrees = clampf(ray.rotation_degrees, min_angle, max_angle)

func _on_detection_area_entered(area: Area2D) -> void:
	detected.emit(area)
