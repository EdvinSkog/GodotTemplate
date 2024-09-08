extends Node

const Balloon = preload("res://scenes/user_interface/dialogue_balloon.tscn") # UI element
@export var dialogue_resource: DialogueResource

signal dialogue_finished
signal title_finished(title: String)


func _ready():
	# Signal that is triggered when dialogue finishes
	DialogueManager.dialogue_ended.connect(_dialogue_finished)
	DialogueManager.passed_title.connect(_title_finished)


func play_dialogue(dialogue_part: String):
	var balloon: Node = Balloon.instantiate()
	GameManager.current_dialogue_balloon = balloon
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_part)

func _title_finished(title: String):
	emit_signal("title_finished")

func _dialogue_finished(used_resource):
	if (used_resource == dialogue_resource):
		# Capture Mouse? Allow Movement?
		emit_signal("dialogue_finished")

func _on_timer_timeout():
	play_dialogue("start")
	pass
	# For some reason, a timer had to be used instead of ready
