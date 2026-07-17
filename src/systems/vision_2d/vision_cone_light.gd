@tool
class_name VisionConeLight2D extends PointLight2D

@export_tool_button("Update Texture Preview") var action_update_texture: Callable = func() -> void:
	_editor_sprite.texture = texture
@export var unaffected_by_params: bool = false
@export var collision_shape: ConvexPolygonShape2D
@export var collision_shape_node: CollisionShape2D

var _editor_sprite: Sprite2D
func _ready() -> void:
	energy = 1.1
	blend_mode = Light2D.BLEND_MODE_MIX
	range_layer_max = 4
	scale = Vector2.ONE
	if Engine.is_editor_hint():
		_editor_sprite = Sprite2D.new()
		_editor_sprite.texture = texture
		add_child(_editor_sprite)
	collision_shape = ConvexPolygonShape2D.new()
	update()

func update() -> void:
	if _editor_sprite:
		_editor_sprite.scale = Vector2.ONE * texture_scale
	
	if !collision_shape or !collision_shape_node: return
	
	texture.get_size()
	
	
	
	var points: Array[Vector2] = [
		Vector2.ZERO,
		texture.get_size() / 2,
		Vector2(1, -1) * texture.get_size() / 2
	]
	collision_shape.points = points
	collision_shape_node.shape = collision_shape
	collision_shape_node.scale = Vector2(1,1) * texture_scale
	collision_shape_node.scale.y *= scale.y / 2

func _process(_delta: float) -> void:
	if _editor_sprite:
		_editor_sprite.scale = Vector2.ONE * texture_scale
