@tool
class_name TopdownPolygon extends Polygon2D

@export var use_light_occlusion: bool = true
#@export var use_navigation_obstacle: bool = true
@export var use_static_body: bool = true

func _ready() -> void:
	if polygon.is_empty(): return
	#if use_navigation_obstacle:
		#create_navigation_obstacle()
	if Engine.is_editor_hint(): return
	
	if use_light_occlusion:
		create_light_occlusion()
	
	if use_static_body:
		create_static_body()

func create_light_occlusion() -> void:
	var light_occluder := LightOccluder2D.new()
	light_occluder.occluder_light_mask = 2 #TODO: const-ify
	light_occluder.occluder = OccluderPolygon2D.new()
	light_occluder.occluder.polygon = polygon
	light_occluder.occluder.closed = true
	add_child(light_occluder)
	

func create_static_body() -> void:
	var static_body := StaticBody2D.new()
	add_child(static_body)
	
	var shape := CollisionPolygon2D.new()
	shape.polygon = polygon
	static_body.add_child(shape)
	

#func create_navigation_obstacle() -> void:
	#var navigation_obstacle := NavigationObstacle2D.new()
	#navigation_obstacle.vertices = polygon
	#add_child(navigation_obstacle)
