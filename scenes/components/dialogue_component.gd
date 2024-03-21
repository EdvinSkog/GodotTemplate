extends Node

const Balloon = preload("res://scenes/user_interface/dialogue_balloon.tscn") # UI element
@export var dialogue_resource: DialogueResource

func _ready():
	# Signal that is triggered when dialogue finishes
	DialogueManager.dialogue_ended.connect(dialogue_finished)


func play_dialogue(dialogue_part: String):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_part)

func dialogue_finished(used_resource):
	if (used_resource == dialogue_resource): 
		# Code for finished dialogue
		pass

func _on_timer_timeout():
	play_dialogue("start")
	pass
	# For some reason, a timer had to be used instead of ready
