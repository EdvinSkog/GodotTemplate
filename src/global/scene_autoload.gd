extends Node

signal level_changed

## References
@onready var load: LoadManager = %LoadManager
@onready var level_holder = %LevelHolder
@onready var player_gui: PlayerGui = %PlayerGui
@onready var pause_screen: PauseScreen = %PauseScreen
var current_level: Node:
	get: return %LevelHolder.get_child(0)
var current_dialogue_balloon: DialogueBalloon


#region Setup
func _ready():
	var current_scene: Node = get_tree().current_scene
	current_scene.reparent.call_deferred(level_holder) #Reparent at end of frame
	_connect_signals()

func _connect_signals() -> void:
	load.level_loaded.connect(add_new_level)
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
