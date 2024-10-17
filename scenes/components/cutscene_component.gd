class_name CutsceneComponent extends Node

@export_category("Node Paths")
## Animation Player
@export var anim: AnimationPlayer
## Dialogue Component
@export var dialogue: DialogueComponent
#@export var camera_2d: Camera2D # Change to 3D if need be.

signal started
signal finished
signal part_finished(part: String)
signal part_started(part: String)
signal skipped

var is_cancelled: bool = false

func _ready() -> void:
	pass
	#PlayerManager.active_changed.connect(toggle_cutscene_cancelled)

func get_cutscene_components(cutscene: String) -> Array:
	var parts: Array = [_get_cutscene_animation_names(cutscene), _get_cutscene_dialogue_titles(cutscene)]
	return parts

func _get_cutscene_animation_names(library_name: String) -> Array:
	var valid_anims: Array
	
	if !is_instance_valid(anim.get_animation_library(library_name)):
		#print_debug("No cutscene library found.")
		return valid_anims
	valid_anims = anim.get_animation_library(library_name).get_animation_list()
	return valid_anims
	
func _get_cutscene_dialogue_titles(cutscene: String) -> Array:
	var titles: Array
	
	if !is_instance_valid(dialogue): return titles
	var resource: DialogueResource = dialogue.dialogue_resource
	titles = resource.get_titles() # Warning! Sorts it automatically
	
	var valid_titles: Array
	for i: String in titles:
		if(i.contains(cutscene)):
			valid_titles.append(i)
	return valid_titles

func is_cutscene_empty(cutscene: String) -> bool:
	var arr: Array = section_cutscene_components(cutscene)
	return arr.is_empty()
	

func section_cutscene_components(cutscene: String) -> Array:
	var components = get_cutscene_components(cutscene)
	var anims: Array = components[0]
	var titles: Array = components[1]
	
	var combined_array = anims + titles
	combined_array = _unique_array(combined_array)
	return combined_array
	
# Remove duplicates and sort
func _unique_array(arr: Array) -> Array:
	var dict := {}
	for a in arr:
		dict[a] = 1
	var new_array: Array = dict.keys()
	new_array.sort()
	return new_array

func start_cutscene(cutscene: String):
	is_cancelled = false
	var arr: Array = section_cutscene_components(cutscene)
	PlayerManager.set_player_active(false)
	emit_signal("started")
	for i in arr:
		emit_signal("part_started", i)
		if(_get_cutscene_animation_names(cutscene).has(i) and !is_cancelled):
			anim.play(cutscene+"/"+i) # library/animation
			await anim.animation_finished
			if(is_cancelled):
				break
		if(_get_cutscene_dialogue_titles(cutscene).has(i) and !is_cancelled):
			dialogue.play_dialogue(i)
			await dialogue.dialogue_finished
			if(is_cancelled):
				break
		emit_signal("part_finished", i)
	finish_cutscene()
	# Anim Dial 1
	# Await Anim1
	# Await Dial2
	# Await Anim3
func finish_cutscene():
	PlayerManager.set_player_active(true)
	emit_signal("finished")

func skip_cutscene():
	is_cancelled = true
	anim.clear_queue()
	dialogue.clear_dialogue()
	emit_signal("skipped")
	finish_cutscene()
