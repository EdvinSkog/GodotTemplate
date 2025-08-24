extends Node

@onready var load_manager = %LoadManager
@onready var level_holder = %LevelHolder
@onready var player_gui = %PlayerGui

var current_level: Node:
	get: return %LevelHolder.get_child(0)
	
signal level_changed

#region Setup
func _ready():
	var current_scene: Node = get_tree().current_scene
	await get_tree().process_frame
	current_scene.reparent(level_holder)
	#level_holder.add_child(override_title_screen_start)
	print("current_scene: ", level_holder.get_child(0))
	_connect_signals()

func _connect_signals() -> void:
	load_manager.level_loaded.connect(add_new_level)
#endregion

#region Level Management
func add_new_level(level: Node) -> void:
	clear_level_holder()
	level_holder.add_child(level)
	level_changed.emit()

func clear_level_holder() -> void: # not used
	for child: Node in %LevelHolder.get_children():
		child.queue_free()

func quit_game():
	get_tree().quit()
#endregion

#region UI
func _toggle_gameplay_ui(option : bool) -> void:
	player_gui.visible = option
#endregion
