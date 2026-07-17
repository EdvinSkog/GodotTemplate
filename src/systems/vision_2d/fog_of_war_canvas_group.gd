@tool
class_name FogOfWarCanvasGroup extends CanvasGroup

@export var show_in_editor: bool = false:
	set = set_show_in_editor

var _editor_light: DirectionalLight2D

func _ready() -> void:
	pass
	#light_mask = DEFAULT_FOG_OF_WAR_MASK

func set_show_in_editor(option: bool) -> void:
	if !Engine.is_editor_hint(): return
	show_in_editor = option
	if _editor_light: _editor_light.queue_free()
	if show_in_editor:
		_editor_light = DirectionalLight2D.new()
		_editor_light.blend_mode = Light2D.BLEND_MODE_MIX
		_editor_light.light_mask = light_mask
		_editor_light.range_layer_max = 10
		add_child(_editor_light)
