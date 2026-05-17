@tool
class_name BoundsObstacle3D extends NavigationObstacle3D

## Whilst this class inherits NavigationObstacle, its not meant to be used as one.
## Simply, the vertice placement is the most convenient to place in editor due to its static Y-level.

@export_tool_button("Generate / Update", "Geometry3D") var action_generate := do_action_generate

## Modify this value to in code to change default across bounds.
@export_flags_3d_physics var collision_layers: int = 7

@export var create_walls: bool = true
@export var create_roof: bool = true
@export var create_floor: bool = true
@export_category("Hollow Bounds")
@export_tool_button("Generate", "ConvexPolygonShape3D") var action_generate_hollow := do_action_generate_hollow
@export_tool_button("Generate Mesh", "MeshInstance3D") var action_generate_mesh := do_action_generate_mesh


@export_group("References")
@export var static_body: StaticBody3D:
	set(value):
		static_body = value
		static_body.collision_layer = collision_layers
		static_body.collision_mask = collision_layers
		static_body.collision_priority = 10
		static_body.input_ray_pickable = false

func do_action_generate() -> void:
	if static_body: static_body.queue_free()
	static_body = StaticBody3D.new()
	
	add_child(static_body)
	_setup_static_body(static_body)
	
	for idx in vertices.size():
		var collision := CollisionShape3D.new()
		collision.shape = BoxShape3D.new()
		collision.shape.size.y = height
		static_body.add_child(collision)
		_setup_collision(collision)
		
		if idx == vertices.size() - 1:
			_fix_wall_collision(collision, vertices[vertices.size() - 1], vertices[0])
		else:
			_fix_wall_collision(collision, vertices[idx], vertices[idx + 1])
	
	if create_floor:
		var collision := CollisionShape3D.new()
		static_body.add_child(collision)
		_setup_collision(collision)
		_fix_area_collision(collision, false)
		
	if create_roof:
		var collision := CollisionShape3D.new()
		static_body.add_child(collision)
		_setup_collision(collision)
		_fix_area_collision(collision, false)
		collision.position.y = height


func do_action_generate_hollow() -> void:
	if static_body: static_body.queue_free()
	static_body = StaticBody3D.new()
	add_child(static_body)
	_setup_static_body(static_body)
	
	var collision := CollisionShape3D.new()
	
	_fix_area_collision(collision, true)
	
	static_body.add_child(collision)
	_setup_collision(collision)

func do_action_generate_mesh() -> void:
	pass

func _setup_static_body(body: StaticBody3D) -> void:
	body.owner = get_tree().edited_scene_root
	
	#Small BUG: toggles between 2 and empty at the end of string per update.
	body.set_deferred(&"name", "StaticBody3D")

## Baseline stuff: name, color etc.
func _setup_collision(coll: CollisionShape3D) -> void:
	coll.owner = get_tree().edited_scene_root
	coll.debug_color = Color(255.014, 20, 50, 0.257)
	coll.name = "CollisionShape3D"

## Collision Shape formed from point one to another
func _fix_wall_collision(coll: CollisionShape3D, start_pos: Vector3, end_pos: Vector3) -> void:
	start_pos.y = height/2
	end_pos.y = height/2
	
	var shape := coll.shape
	var distance := start_pos.distance_to(end_pos)
	var direction: Vector3 = end_pos - start_pos
	
	
	shape.size.z = distance
	coll.look_at_from_position(start_pos + direction * 0.5, end_pos)
	coll.transform = static_body.global_transform * coll.transform

func _fix_area_collision(coll: CollisionShape3D, hollow: bool = false) -> void:
	var shape := ConvexPolygonShape3D.new()
	var points : PackedVector3Array
	if hollow:
		points = get_hollow_vectors()
	else:
		points = vertices.duplicate()
	print(points)
	shape.points = points
	coll.shape = shape

## The entire area vector points
func get_hollow_vectors() -> PackedVector3Array:
	var points := vertices.duplicate()
	for value in vertices:
		var vec3: Vector3 = value
		vec3.y = height
		points.append(vec3)
	return points
