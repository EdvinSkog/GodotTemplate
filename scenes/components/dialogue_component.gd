class_name DialogueComponent extends Node

enum Style {DEFAULT, SUBTITLES}
@export_category("Dialogue")
@export var dialogue_resource: DialogueResource
@export_category("Balloon")
@export var balloon_style: Style
var balloon_scene: PackedScene #= preload("res://scenes/user_interface/dialogue/default_dialogue_balloon.tscn") # UI element

signal dialogue_finished
signal title_finished(title: String)
var balloon: DialogueBalloon

func _ready():
	# Signal that is triggered when dialogue finishes
	DialogueManager.dialogue_ended.connect(_dialogue_finished)
	DialogueManager.passed_title.connect(_title_finished)
	match balloon_style:
		Style.DEFAULT:
			balloon_scene = load("res://scenes/user_interface/dialogue/default_dialogue_balloon.tscn")
		Style.SUBTITLES:
			balloon_scene = load("res://scenes/user_interface/dialogue/subtitles_dialogue_balloon.tscn")

func play(dialogue_part: String):
	balloon = balloon_scene.instantiate()
	Game.current_dialogue_balloon = balloon
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_part)

func _title_finished(title: String):
	emit_signal("title_finished")

func _dialogue_finished(used_resource):
	if (used_resource == dialogue_resource):
		# Capture Mouse? Allow Movement?
		emit_signal("dialogue_finished")


func _on_tree_entered() -> void:
	pass # use this if you wanna trigger dialogue instantly (ready does not work).
