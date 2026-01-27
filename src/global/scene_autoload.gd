extends Node

signal level_changed

## References
@onready var loading: LoadingManager = %LoadingManager
@onready var level_holder = %LevelHolder
@onready var global_gui: GlobalGui = %GlobalGui
@onready var pause_screen: PauseScreen = %PauseScreen
var current_level: Node:
	get: 
		if %LevelHolder.get_child_count() <= 0:
			return get_tree().current_scene
		return %LevelHolder.get_child(0)
var current_dialogue_balloon: DialogueBalloon


#region Setup
func _ready():
	var current_scene: Node = get_tree().current_scene
	current_scene.reparent.call_deferred(level_holder) #Reparent at end of frame
	_connect_signals()

func _connect_signals() -> void:
	loading.level_loaded.connect(add_new_level)
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
