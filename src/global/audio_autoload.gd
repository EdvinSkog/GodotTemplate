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

func set_global_volume(bus_name: String, amount: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	amount = linear_to_db(amount)
	AudioServer.set_bus_volume_db(bus_index, amount)

# Relative increases/decrease by db amount
func change_music_volume(db: float, fade_time: float = 0) -> void:
	db = 0 + db
	var tween := get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", db, fade_time)
