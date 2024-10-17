extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CutsceneComponent.start_cutscene("test")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	SceneManager.load_scene("res://scenes/level/test_level.tscn", 1, "subtle")
