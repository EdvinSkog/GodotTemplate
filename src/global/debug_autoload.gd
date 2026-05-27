extends Node

signal pressed_debug(idx: int)

var connections: Array[Connection]

var last_queries: Array[StringName]
static var commands: Dictionary[StringName, Command]
## The UI node for the commands
@onready var item_list: ItemList = %ItemList
@onready var line_edit: LineEdit = %LineEdit

static func cast_value(value: String, type: Variant.Type) -> Variant:
	match type:
		TYPE_INT:
			return value.to_int()
		TYPE_FLOAT:
			return value.to_float()
		TYPE_BOOL:
			return value.to_lower() in ["true", "1"]
		TYPE_STRING:
			return value
		TYPE_STRING_NAME:
			return StringName(value)
		TYPE_NIL:
			return null
		_:
			return value

static func cast_warning(type: Variant.Type) -> String:
	match type:
		TYPE_INT:
			return "Integer required."
		TYPE_FLOAT:
			return "Float required."
		TYPE_BOOL:
			return "Bool required (true or false)"
		TYPE_STRING:
			return "String required."
		TYPE_STRING_NAME:
			return "String required."
		TYPE_NIL:
			return ""
		_:
			return ""

func _enter_tree() -> void:
	%Console.visible = false

func _ready() -> void:
	if !OS.is_debug_build(): 
		process_mode = Node.PROCESS_MODE_DISABLED
		#queue_free() # Dangerous if something were to reference Debug
		return
	
	%ItemList.item_selected.connect(
		func(selected_idx: int) -> void:
			set_query(%ItemList.get_item_metadata(selected_idx), true)
			#run_command(%ItemList.get_item_metadata(selected_idx)) 
	)
	pressed_debug.connect(_check_press)
	_create_connections()
	_create_commands()
	item_list.sort_items_by_text.call_deferred()

#region Instances

func _create_connections() -> void:
	
	con(func test() -> void:
		print("Test debug print ", Game.get_seconds_passed()), 2)
	
	con(func() -> void: 
		$Freecam2D.toggle(true)
		, 3)

func _create_commands() -> void:
	
	Command.new(
	&"map",
	Scene.load_map, 
	TYPE_STRING_NAME,
	"Load into a different map.")
	
	Command.new(
	&"volume",
	func(_v: float) -> void: Audio.set_global_volume(&"Master", _v), 
	TYPE_FLOAT,
	"Change the Master volume.")
	
	Command.new(
	&"quit",
	Scene.quit_game, 
	TYPE_NIL,
	"Quit the game.")
	
	Command.new(
	&"freecam",
	_not_implemented, 
	TYPE_NIL,
	"Swap to free cam.")
	
	Command.new(
	&"time_scale",
	Engine.set_time_scale, 
	TYPE_FLOAT,
	"Set the overall time scale of the engine.")
	
	Command.new(
	&"noclip",
	_not_implemented, 
	TYPE_BOOL,
	"[Not Implemented] Controller flies and ignore collisions.")
	
	Command.new(
	&"tp",
	_not_implemented, 
	TYPE_VECTOR2,
	"[Not Implemented] Teleport.")
	
	Command.new(
	&"pause",
	get_tree().set_pause, 
	TYPE_BOOL,
	"Pause the game.")
	
	Command.new(
	&"save_state",
	func() -> void:
		saved_state_pack = PackedScene.new()
		saved_state_pack.pack(Scene.map),
		# TODO Save to file?:
		#ResourceSaver.save(packed_scene, "res://saved_state.tscn"),
	TYPE_NIL,
	"Save state of ongoing Map.")
	
	Command.new(
	&"load_state",
	func() -> void:
		#var pack: PackedScene = load("res://saved_state.tscn")
		
		Scene.set_map(saved_state_pack.instantiate()),
	TYPE_NIL,
	"Load state of saved Map.")
	# Conditions?

	# gym.map

var saved_state_pack: PackedScene

func _not_implemented(_v: Variant) -> void:
	cmdlog("Not implemented.")

## Sample function for testing the debug feature.
func toggling_test(toggled: bool = false) -> void:
	if toggled: print("Yeah we true")
	else: print("Nah we false")

#endregion

#region Connection
class Connection:
	var input_idx: int
	var callable: Callable
	
	## If we want the connection to toggle every debug press. 
	## Requires the first argument in the callable to be a bool 
	var toggleable: bool
	## The status of its toggling.
	var toggled: bool = false

## "Connection"-Debug wrapper, call the first argument with debug keys F1-F12
func con(test: Callable, input_idx: int = 1, toggleable: bool = false) -> void:
	var connection: Connection = Connection.new()
	connection.callable = test
	connection.input_idx = input_idx
	connection.toggleable = toggleable
	connections.append(connection)



## To check the idx of the debug press
func _check_press(idx: int) -> void:
	for connection in connections:
		if connection.input_idx != idx:
			continue
		if connection.toggleable:
			connection.toggled = !connection.toggled
			connection.callable.call(connection.toggled)	
		else:
			connection.callable.call()
#endregion

#region Console Commands
class Command:
	var key: StringName
	var function: Callable
	var type: Variant.Type
	var description: String
	
	func _init(_key: StringName, _function: Callable, _type: Variant.Type = TYPE_NIL, _description: String = "") -> void:
		key = _key
		function = _function
		type = _type
		description = _description
		add()
	
	func add() -> void:
		if Debug.commands.has(key):
			push_warning("Duplicate command key %s added!", key)
		Debug.commands.get_or_add(key, self)
		
		var idx: int = Debug.item_list.add_item(key + " | " + description)
		Debug.item_list.set_item_metadata(idx, key)
		Debug.item_list.set_item_tooltip_enabled(idx, false)

#endregion

#region Inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		line_edit.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		%Console.visible = !%Console.visible
		return
	
	if is_console_enabled():
		if event.is_action_pressed("ui_up"):
			if last_queries.is_empty(): return
			var latest : StringName = last_queries.back()
			var index: int = last_queries.rfind(line_edit.text)
			if index > 0:
				latest = last_queries[index-1]
			set_query(latest)
			
		elif event.is_action_pressed("ui_down"):
			if last_queries.is_empty(): return
			set_query(last_queries.back())
	
		if event.is_action_pressed("console_text_completion_accept"):
			if item_list.is_anything_selected():
				var idx := item_list.get_selected_items()[0]
				set_query(item_list.get_item_metadata(idx))
				#line_edit.text = 
				
	
	#WARNING: Potential performance problems
	for number in range(1, 13):
		var event_name: String = "debug_"
		event_name += str(number)
		if event.is_action_pressed(event_name):
			call_debug_action(number)

func call_debug_action(idx: int) -> void:
	idx = clampi(idx, 1, 12)
	print_rich("[color=white]DEBUG CALL [color=green]%s[/color] @ %ss." % [idx, Game.get_seconds_passed()] )
	match idx:
		1:
			pass
		12:
			pass
	pressed_debug.emit(idx)

#endregion

#region Console UI

func is_console_enabled() -> bool:
	return %Console.visible

func _on_console_visibility_changed() -> void:
	_enable_console(%Console.visible)

func _enable_console(option: bool) -> void:
	#set_process_input(option)
	set_process_unhandled_input(option)
	set_process(option)
	for controller: Node in get_tree().get_nodes_in_group(&"controller"):
		controller.set_process_unhandled_input(!option)
	await get_tree().process_frame
	line_edit.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
	if option:
		
		line_edit.grab_focus()
		line_edit.grab_click_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Player.mouse_mode

func _process(_delta: float) -> void:
	if is_console_enabled():
		line_edit.grab_focus()

func _on_line_edit_text_submitted(new_text: String) -> void:
	run_command(new_text)

func set_query(query: String, add_space: bool = false) -> void:
	if add_space: query += " "
	line_edit.text = query
	await get_tree().process_frame
	line_edit.caret_column = line_edit.text.length()
	

func run_command(prompt: String) -> void:
	if prompt.is_empty(): return
	
	last_queries.append(prompt)
	
	if !prompt.contains(" "): prompt += " "
	var key := prompt.split(" ", false)[0]
	var argument: Variant = prompt.split(" ")[1]
	
	line_edit.text = ""
	
	
	if !commands.has(key): 
		cmdlog("UNKNOWN COMMAND")
		return
	cmdlog(key + " " + str(argument))
	var command := commands[key]
	if command.type == TYPE_NIL: 
		command.function.call() # No argument
		return
	argument = cast_value(argument, command.type)
	
	command.function.call(argument)

func check_command(prompt: String) -> void:
	if prompt.is_empty(): return
	if !prompt.contains(" "): prompt += " "
	var key := prompt.split(" ", false)[0]
	var _argument: Variant = prompt.split(" ")[1]
	
	
	if !commands.has(key):
		return
	var command := commands[key]
	cmdlog(cast_warning(command.type))
	



func _on_line_edit_text_changed(new_text: String) -> void:
	_update_command_queries(new_text)
	

func _update_command_queries(query: String) -> void:
	
	
	
	for i in item_list.item_count:
		var text := item_list.get_item_text(i).to_lower()

		if text.begins_with(query):
			item_list.select(i)
			item_list.ensure_current_is_visible()
			break
	check_command(query)
	#cmdlog()

	
	##FIXME to use ItemList's own incremental search
	#for key: StringName in commands:
		#if key.contains(current_search):
			#var idx: int = %ItemList.add_item(key + " | " + commands[key].description)
			#%ItemList.set_item_metadata(idx, key)
			

func cmdlog(text: String) -> void:
	#print_rich("[color=white]", text)
	%LogLabel.text = text
#endregion
