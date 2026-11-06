extends Node

@onready var sfx_scene: PackedScene = load("res://src/global/audio/sound_effect.tscn")
@onready var music_player: AudioStreamPlayer = $Music
@onready var voice: AudioStreamPlayer = $Voice
@onready var ambience: AudioStreamPlayer = $Ambience

@export_dir var voice_folder_path: String = "res://assets/audio/voice"
@onready var songlist: Dictionary[StringName, AudioStream]:
	get:
		return Game.ref_data.songs
@onready var voicelist: Dictionary[StringName, AudioStream]:
	get:
		return Game.ref_data.voices


# Uses and instantiates the sound_effect.tscn #TODO: Improve use cases
func play_sfx(path: String, volume_modifier: float = 0) -> void:
	var sfx: AudioStreamPlayer = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = 0 + volume_modifier
	add_child(sfx)

#region Playing
# Uses paths, not AudioStream.
func play_music(song_name: StringName, volume_modifier: float = 0, fade_time: float = 0.1) -> void:

	var music_stream := Data.songs[song_name]
	if music_stream:
		if music_player.stream:
			music_player.stop()  # Stop any currently playing music
		
		music_player.stream = music_stream
		
		music_player.volume_db = -40
		music_player.play()
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(music_player, "volume_db", 0 + volume_modifier, fade_time)
	else:
		print("Error: Could not load the music stream for song:", song_name)

func play_ambience(path: String, volume_modifier: float = 0) -> void:
	ambience.stream = load(path)
	ambience.volume_db = 0 + volume_modifier
	ambience.play()

#This function uses paths, because of how Dialogue Manager works
func play_voice(voice_name: String, volume_modifier: float = 0) -> void:
	var voice_path: String = voicelist.get(voice_name, null)
	if voice_path:
		voice.stream = load(voice_path)
		voice.volume_db = 0 + volume_modifier
		voice.play()

func stop_music(fade_time: float = 0.1) -> void:
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(music_player, "volume_db", -40, fade_time)
	await tween.finished
	music_player.stop()
#endregion

#region Volume

# Linear (0 to 1)
var bus_origin_volumes: Dictionary[StringName, float] = {}

# Db
var bus_stored_db_volumes: Dictionary[StringName, float] = {}


## Is a normalized value that the player shall modify in settings
func set_bus_origin_volume(bus_name: String, amount: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0: 
		push_warning("Tried changing origin volume of non-existent bus: ", bus_name)
		return
	amount = clampf(amount, 0, 1) #Maybe 0 to 2?
	bus_origin_volumes.get_or_add(bus_name, amount)
	bus_origin_volumes[bus_name] = amount
	_update_bus_volume(bus_name)

# Is linear
func get_bus_origin_volume(bus_name: StringName) -> float:
	if bus_origin_volumes.has(bus_name):
		return bus_origin_volumes.get(bus_name)
	return 1.0

#NOTE: rename to set_bus_volume
var volume_tween: Tween
func set_bus_volume(bus_name: StringName, db: float, fade_time: float = 0.0) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	
	bus_stored_db_volumes.get_or_add(bus_name, db)
	bus_stored_db_volumes[bus_name] = db
	assert(!is_nan(db))
	
	#debug_volumes(bus_name, db)
	
	# Lambda for easier tweening
	var set_volume := func(val: float) -> void:
		AudioServer.set_bus_volume_db(bus_index, val + linear_to_db(get_bus_origin_volume(bus_name)))
	
	
	if fade_time > 0:
		var current_volume := get_bus_volume(bus_name)
		
		volume_tween = get_tree().create_tween()
		volume_tween.set_ease(Tween.EASE_OUT)
		volume_tween.tween_method(set_volume, current_volume, db, fade_time)
	else:
		set_volume.call(db)
	

## Returns the real as db
func get_bus_volume(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_db(bus_index)

func mute_bus(bus_name: StringName, option: bool = true) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(idx, option)

## Volume without modifed origin applied
func get_stored_db_volume(bus_name: StringName) -> float:
	if bus_stored_db_volumes.has(bus_name):
		return bus_stored_db_volumes.get(bus_name)
	return 0.0
# +=
func modify_bus_volume(bus_name: StringName, amount: float, fade_time: float = 0) -> void:
	set_bus_volume(bus_name, get_bus_volume(bus_name) + amount, fade_time)

func _update_bus_volume(bus_name: StringName) -> void:
	#var bus_index := AudioServer.get_bus_index(bus_name)
	set_bus_volume(bus_name, get_stored_db_volume(bus_name))

func debug_volumes(bus_name: StringName, db_set: float) -> void:
	if !OS.is_debug_build(): return
	print("\n" + bus_name + " Audio")
	print_rich("[color=beige]db volume stored: ", db_set)
	print_rich("[color=beige]origin modified: ", get_bus_origin_volume(bus_name))
	print_rich("[color=beige]real volume: ", get_bus_volume(bus_name))
#endregion
