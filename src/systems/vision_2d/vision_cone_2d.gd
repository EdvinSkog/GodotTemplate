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

const RANGE: float = 1024
const FOV := 90.0
const STARTING_ACTIVE_RAYS: int = 7
const MAX_RAYS: int = 7

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

func _ready() -> void:
	if Engine.is_editor_hint(): return
	create_scan_rays()
	set_active_rays(STARTING_ACTIVE_RAYS)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	update_detection_shapes()

var scanning: bool = true
var base_angle : float = 45

var ray_index : int = 0

func update_detection_shapes() -> void:
	
	%CollPoly.polygon = get_points()

func get_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)
	scan_rays.sort_custom(func(a: RayCast2D, b: RayCast2D) -> bool:
		return a.rotation < b.rotation
	)
	for ray in scan_rays:
		if !ray.enabled:
			continue

		var global_point := ray.get_collision_point() if ray.is_colliding() else ray.to_global(ray.target_position)
		var local_point : Vector2 = %CollPoly.to_local(global_point)
		local_point.x = roundf(local_point.x)
		local_point.y = roundf(local_point.y)
		if points.is_empty() or points[-1].distance_to(local_point) > 1.0:
			points.append(local_point)
	points.append(Vector2.ZERO)
	return points

@onready var scan_rays: Array[RayCast2D] = []

func create_scan_rays(amount: int = MAX_RAYS) -> void:
	scan_rays.clear()

	for i in amount:
		var ray := RayCast2D.new()

		ray.enabled = false
		ray.target_position = Vector2.RIGHT * RANGE

		var t := 0.0 if amount == 1 else float(i) / float(amount - 1)
		ray.rotation_degrees = lerp(-FOV * 0.5, FOV * 0.5, t)
		ray.name = str(ray.rotation_degrees) + "Ray"
		%DetectionArea.add_child(ray)
		scan_rays.append(ray)

func set_active_rays(count: int = scan_rays.size()) -> void:
	count = clampi(count, 0, scan_rays.size())

	for ray in scan_rays:
		ray.enabled = false

	if count == 0:
		return

	var center := scan_rays.size() / 2
	var enabled := 1

	scan_rays[center].enabled = true

	var left := 0
	var right := scan_rays.size() - 1

	while enabled < count:
		if left < center:
			scan_rays[left].enabled = true
			enabled += 1
			left += 1

			if enabled >= count:
				break

		if right > center:
			scan_rays[right].enabled = true
			enabled += 1
			right -= 1

## Angle is radian
func get_normalized_angle(angle: float) -> float:
	const MIN_ANGLE = deg_to_rad(1.0)
	const MAX_ANGLE = deg_to_rad(45.0)
	return clampf(inverse_lerp(MIN_ANGLE, MAX_ANGLE, angle), 0, 1)

func get_ray_distance(ray: RayCast2D) -> float:
	if !ray.is_colliding(): return ray.target_position.x
	var coll_point: Vector2 = ray.get_collision_point()
	
	return global_position.distance_to(coll_point)


func _on_detection_area_entered(area: Area2D) -> void:
	detected.emit(area)


func _on_detection_area_exited(area: Area2D) -> void:
	pass
