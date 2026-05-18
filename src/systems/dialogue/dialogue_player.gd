@icon("res://addons/dialogue_manager/assets/icon.svg")
class_name DialoguePlayer extends Node

enum Style {BASIC, SUBTITLES}
@export_category("Dialogue")
@export var dialogue_resource: DialogueResource
@export_category("Balloon")
@export var balloon_style: Style
var balloon_scene: PackedScene #= preload("res://scenes/user_interface/dialogue/default_dialogue_balloon.tscn") # UI element

@export var autoplay: bool = false

signal dialogue_finished
signal title_finished(title: String)
var balloon: DialogueBalloon

## "Global" variable to track if there is an active balloon
## Access with DialoguePlayer.current_balloon
static var current_balloon: DialogueBalloon

func _ready() -> void:
	# Signal that is triggered when dialogue finishes
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	DialogueManager.passed_title.connect(_on_title_finished)
	match balloon_style:
		Style.BASIC:
			balloon_scene = load("res://src/systems/dialogue/balloons/basic_dialogue_balloon.tscn")
		Style.SUBTITLES:
			balloon_scene = load("res://src/systems/dialogue/balloons/subtitles_dialogue_balloon.tscn")
	if autoplay:
		play.call_deferred("start")
	
## Create a balloon and trigger its contents.
func play(dialogue_part: String) -> void:
	balloon = balloon_scene.instantiate()
	current_balloon = balloon #TODO: Export option for balloon parent
	Scene.global_gui.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_part)

## Deletes the balloon instantiated by this DialoguePlayer
func stop() -> void:
	if balloon: 
		balloon.end()
		dialogue_finished.emit()

## When a "~" line in a DialogueResource is activated
func _on_title_finished(title: String) -> void:
	title_finished.emit(title)

func _on_dialogue_finished(used_resource: DialogueResource) -> void:
	if (used_resource == dialogue_resource):
		dialogue_finished.emit()
