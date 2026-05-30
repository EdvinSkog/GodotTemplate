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
	"Set the overall time scale of the engine.")
	
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
	_not_implemented, 
	TYPE_VECTOR2,
	"[Not Implemented] Teleport.",
	func(argument: Variant = Vector3(1,1,1)) -> Dictionary[String, bool]:
	
		return _not_implemented()

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
