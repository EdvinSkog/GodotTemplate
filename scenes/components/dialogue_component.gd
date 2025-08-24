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
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	DialogueManager.passed_title.connect(_on_title_finished)
	match balloon_style:
		Style.DEFAULT:
			balloon_scene = load("res://scenes/user_interface/dialogue/default_dialogue_balloon.tscn")
		Style.SUBTITLES:
			balloon_scene = load("res://scenes/user_interface/dialogue/subtitles_dialogue_balloon.tscn")

func play(dialogue_part: String):
	balloon = balloon_scene.instantiate()
	Game.current_dialogue_balloon = balloon #TODO: Export option for balloon parent
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_part)

func _on_title_finished(title: String):
	title_finished.emit(title)

func _on_dialogue_finished(used_resource):
	if (used_resource == dialogue_resource):
		dialogue_finished.emit()
