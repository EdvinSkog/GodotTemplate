extends Node

@export var override_title_screen_start: PackedScene = load("res://scenes/user_interface/menus/title_screen.tscn")

@onready var level_holder = $SubViewportContainer/SubViewport/LevelHolder
@onready var gameplay_ui = $CanvasLayer/GameplayInterface

## Setup
func _ready():
	assert(override_title_screen_start != null)
	var override_title_screen_start = override_title_screen_start.instantiate()
	level_holder.add_child(override_title_screen_start)
	
	var current_level = level_holder.get_child(0)
	SceneManager.set_current_level(current_level)
	_connect_signals()

func _connect_signals():
	SceneManager.level_changed.connect(add_new_level)
	#PlayerVariables.ui_toggled.connect(_toggle_gameplay_ui)


## Level Management
func add_new_level():
	level_holder.add_child(SceneManager.current_level)

func remove_level(): # not used
	SceneManager.current_level.queue_free()


## UI
func _toggle_gameplay_ui(option : bool):
	gameplay_ui.visible = option
