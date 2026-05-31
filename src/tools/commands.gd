extends Node




## Wrapper for new Command
func n(_key: StringName, _function: Callable, _type: Variant.Type, _description_: String = "", _condition: Callable = _empty, _rec_args := []) -> void:
	Debug.Command.new(_key, _function, _type, _description_, _condition, _rec_args)

@warning_ignore_start("unused_parameter", "untyped_declaration")
func create_commands() -> void:
	n(
	&"map",
	Scene.load_map, 
	TYPE_STRING_NAME,
	"Load into a different map.",
	func(arg = "") -> Dictionary[String, bool]:
		return {"Map exists." = Data.maps.has(arg)},
	Data.maps.keys()
	)
	n(
	&"volume",
	func(_v: float) -> void: Audio.set_global_volume(&"Master", _v), 
	TYPE_FLOAT,
	"Change the Master volume.",
	func(argument: Variant = "") -> Dictionary[String, bool]:
		return {"AudioServer has 'Master' Bus." = AudioServer.get_bus_index("Master") != -1}
	)
	
	
	n(
	&"quit",
	Scene.quit_game, 
	TYPE_NIL,
	"Quit the game.")
	
	n(
	&"freecam",
	func() -> void: 
		%Freecam.toggle(true), 
	TYPE_NIL,
	"Swap to free cam.",
	func() -> Dictionary[String, bool]:
		
		return _has_controller()

	)
	
	n(
	&"time_scale",
	Engine.set_time_scale, 
	TYPE_FLOAT,
	"Set the overall time scale of the engine.",
	func(arg: String = "1.0") -> Dictionary[String, bool]:

		var arg_f := arg.to_float()
		return { "Float between 0.0 to 3.0" = arg_f == clampf(arg_f, 0, 3) and arg.is_valid_float()}

	)
	
	n(
	&"noclip",
	_not_implemented, 
	TYPE_BOOL,
	"Traverse through collision.",
	func() -> Dictionary[String, bool]:
		var dic := _has_controller()
		dic.merge(_not_implemented())
		return dic
	)
	
	n(
	&"tp",
	func(x: float, y: float, z: float) -> void:
		for controller in get_tree().get_nodes_in_group(&"controller"):
			if controller is Node3D:
				controller.global_position = Vector3(x,y,z)
			elif controller is Node2D:
				controller.global_position = Vector2(x,y)
		, 
	TYPE_FLOAT,
	"Teleport. X and Y if 2D. X, Y, and Z if 3D.",
	func(arg1: String, arg2: String, arg3: String) -> Dictionary[String, bool]:
		
		var controllers := get_tree().get_nodes_in_group(&"controller")
		var cond := controllers.all(
			func(type) -> bool:
				return type is Node3D or type is Node2D
			
		)
		return {
			"X, Y, Z float values." = arg1.is_valid_float() and arg2.is_valid_float() and arg3.is_valid_float(),
			"Controller is a Node3D or Node2D." = cond,
			"Single controller" = get_tree().get_node_count_in_group(&"controller")
		}
	)
	
	n(
	&"hud",
	func() -> void:
		Scene.global_gui.visible = !Scene.global_gui.visible, 
	TYPE_BOOL,
	"Toggle the global HUD."
	#func() -> Dictionary[String, bool]:
		#return { }
	)
	
	n(
	&"pause",
	get_tree().set_pause, 
	TYPE_BOOL,
	"Pause the game.")
	
	n(
	&"save_state",
	func() -> void:
		saved_state_pack = PackedScene.new()
		saved_state_pack.pack(Scene.map),
		# TODO Save to file?:
		#ResourceSaver.save(packed_scene, "res://saved_state.tscn"),
	TYPE_NIL,
	"Save state of ongoing Map.")
	
	n(
	&"load_state",
	func() -> void:
		#var pack: PackedScene = load("res://saved_state.tscn")
		
		Scene.set_map(saved_state_pack.instantiate()),
	TYPE_NIL,
	"Load state of saved Map.")

@warning_ignore_restore("unused_parameter", "untyped_declaration")

var saved_state_pack: PackedScene

#region Reusable conditions

func _empty() -> Dictionary[String, bool]:
	return {}

func _not_implemented() -> Dictionary[String, bool]:
	return {"NOT IMPLEMENTED" = false}

func _has_controller() -> Dictionary[String, bool]:
	return {"Controller exists." = get_tree().get_nodes_in_group(&"controller").size() > 0}


#endregion
