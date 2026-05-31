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
	$Commands.create_commands()
	item_list.sort_items_by_text.call_deferred()

#region Instances

func _create_connections() -> void:
	
	con(func test() -> void:
		print("Test debug print ", Game.get_seconds_passed()), 2)
	
	con(func() -> void: 
		%Freecam.toggle(true)
		, 3)

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

#region Command Class
class Command:
	var key: StringName
	var function: Callable
	var type: Variant.Type
	var description: String
	var condition: Callable
	var argument_recommends: Array
	
	func _init(_key: StringName, _function: Callable, _type: Variant.Type = TYPE_NIL, _description: String = "", _condition: Callable = func()->bool: return true, _argument_recommends := []) -> void:
		key = _key
		function = _function
		type = _type
		description = _description
		condition = _condition
		argument_recommends = _argument_recommends
		add()
	
	func add() -> void:
		if Debug.commands.has(key):
			push_warning("Duplicate command key %s added!", key)
		Debug.commands.get_or_add(key, self)
		
		var idx: int = Debug.item_list.add_item(key + " | " + description)
		Debug.item_list.set_item_metadata(idx, key)
		Debug.item_list.set_item_tooltip_enabled(idx, false)
	
	## Validate its Type and Conditions
	func validate(arguments: Array[Variant]) -> bool:
		condition_errors.clear()
		var arg_cond := condition_error("Correct argument size of " + str(condition.get_argument_count()), 
		condition.get_argument_count() == arguments.size())
		
		var custom_conditions: Dictionary[String, bool]
		
		if !arg_cond or arguments.is_empty():
			while arguments.size() < condition.get_argument_count():
				arguments.append("")
			custom_conditions = condition.callv(arguments)
		else:
			custom_conditions = condition.callv(arguments)
		condition_errors.merge(custom_conditions)
		
		return check_error_log()
		
	var condition_errors: Dictionary[String, bool]

	## Sets and Updates a condition's state
	func condition_error(message: String, cond: bool = false) -> bool:
		condition_errors.get_or_add(message, cond)
		condition_errors[message] = cond
		return cond

	func check_error_log() -> bool:
		var check := condition_errors.values().all(func(val: bool) -> bool: return val)
		return check
	
	func run(_arguments: Array) -> void:
		var converted_args: Array
		for arg: String in _arguments:
			var converted_arg: Variant = Debug.cast_value(arg, type)
			converted_args.append(converted_arg)
		function.callv(converted_args)
#endregion

#region Inputs
func _input(event: InputEvent) -> void:

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
			if %ContextItems.visible and %ContextItems.is_anything_selected():
				var context_idx : int = %ContextItems.get_selected_items()[0]
				
				set_query(key + " " + %ContextItems.get_item_text(context_idx), false)
				#var idx := item_list.get_selected_items()[0]
				#set_query(item_list.get_item_metadata(idx))
				return
			if item_list.is_anything_selected():
				var idx := item_list.get_selected_items()[0]
				set_query(item_list.get_item_metadata(idx))
				#line_edit.text = 
				
	

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
	set_process_input(option)
	set_process_unhandled_input(option)
	set_process(option)
	%ContextWindow.visible = false
	for controller: Node in get_tree().get_nodes_in_group(&"controller"):
		controller.set_process_unhandled_input(!option)
	await get_tree().process_frame
	line_edit.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
	if option:
		check_command(line_edit.text)
		line_edit.grab_focus()
		line_edit.grab_click_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Player.mouse_mode

func _process(_delta: float) -> void:
	if is_console_enabled():
		line_edit.grab_focus()
#endregion
#region Command Inputs
func _on_line_edit_text_submitted(new_text: String) -> void:
	run_command(new_text)

func set_query(query: String, add_space: bool = false) -> void:
	if add_space: query += " "
	line_edit.text = query
	await get_tree().process_frame
	line_edit.caret_column = line_edit.text.length()
	check_command(query)
	

func run_command(prompt: String) -> void:
	if prompt.is_empty(): return
	
	last_queries.append(prompt)
	

	
	line_edit.text = ""
	
	
	if !commands.has(key): 
		cmdlog("UNKNOWN COMMAND")
		return
	cmdlog(key + " " + str(arguments))
	var command := commands[key]

	if check_command(prompt):
		command.run(arguments)
		cmdlog(key + " successful.")
	else:
		cmdlog("Validation failed.")

var key: String
var arguments: Array

## Set the key and arguments + validate conditions
func check_command(prompt: String) -> bool:
	
	var clear_func := func clear() -> void:
		%ErrorLog.text = ""
		%ContextWindow.hide()
	
	if prompt.is_empty(): 
		clear_func.call()
		return false
	
	if !prompt.contains(" "): prompt += " "
	key = prompt.split(" ", false)[0]
	
	arguments = prompt.trim_prefix(key + " ").split(" ")
	arguments = arguments.filter(func(string: String)-> bool: return string != "")
	if !commands.has(key):# Nonexistent command
		clear_func.call()
		return false
	
	var command := commands[key]


	var validation := command.validate(arguments)
	%ErrorLog.text = ""
	for error: String in command.condition_errors.keys():
		var prefix: String = "[color=green]" if command.condition_errors[error] else "[color=red]"
		%ErrorLog.text += prefix + error + "\n"
	

	update_context_window(command.argument_recommends)
	return validation

func update_context_window(arr: Array) -> void:
	if arr.is_empty():
		%ContextWindow.hide()
		return
	%ContextWindow.show()
	%ContextWindow.position.x = 35 + (line_edit.caret_column * 9.5)
	%ContextItems.clear()
	for text: String in arr:
		%ContextItems.add_item(text)
	if arguments.size() > 0:
		search_item_list(%ContextItems, arguments[0])



func _on_line_edit_text_changed(new_text: String) -> void:
	_search_command(new_text)
	

func _search_command(query: String) -> void:
	search_item_list(%ItemList, query)
	
	check_command(query)

static func search_item_list(_item_list: ItemList, query: String) -> void:
	for i in _item_list.item_count:
		var text := _item_list.get_item_text(i).to_lower()

		if text.begins_with(query):
			_item_list.select(i)
			_item_list.ensure_current_is_visible()
			break
	##FIXME to use ItemList's own incremental search
	#for key: StringName in commands:
		#if key.contains(current_search):
			#var idx: int = %ItemList.add_item(key + " | " + commands[key].description)
			#%ItemList.set_item_metadata(idx, key)
			

func cmdlog(text: String) -> void:
	#print_rich("[color=white]", text)
	%LogLabel.text = text
#endregion


func _on_exit_button_pressed() -> void:
	%Console.hide()
