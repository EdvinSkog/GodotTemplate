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
	# TODO Clean up this spaghetti
	var size: Vector2 = Vector2(1024, 512)
	if !%RayCast2D.is_colliding():
		%CollisionCone.scale.x = %RayCast2D.target_position.x / size.x
		return
	
	var wall_point: Vector2 = %RayCast2D.get_collision_point()
	
	var dist := global_position.distance_to(wall_point)
	%CollisionCone.scale.x = dist / size.x 
	%CollisionCone.scale.y = dist / size.y 
	
	#var dist_down : float = global_position.distance_to(%DownRayCast2D.get_collision_point())
	#var dist_up : float = global_position.distance_to(%UpRayCast2D.get_collision_point())
	#var points: PackedVector2Array = [
		#Vector2(0,0),
		#Vector2(503,253),
		#Vector2(1024,512),
		#Vector2(1024,0),
		#Vector2(1024,-512),
		#Vector2(528,-252)
	#] 
	#%CollisionCone.shape.points = points

func _on_detection_area_entered(area: Area2D) -> void:
	detected.emit(area)
