extends Node

enum AUDIO_TYPE {master, sfx, music, ambience, voice}
@onready var sfx_scene: PackedScene = load("res://scenes/global/audio/sound_effect.tscn")
@onready var music = $Music
@onready var voice = $Voice
@onready var ambience = $Voice

@export_file("*.mp3") var music_list

# Uses and instantiates the sound_effect.tscn
func play_sfx(path: String, local_volume_change: float = 0):
	var sfx = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = local_volume_change
	add_child(sfx)

# Uses paths, not AudioStream.
func play_music(path: String, local_volume_change: float = 0):
	music.stream = load(path)
	music.volume_db = local_volume_change
	music.play()

func play_ambience(path: String, local_volume_change: float = 0):
	ambience.stream = load(path)
	ambience.volume_db = local_volume_change
	ambience.play()

#This function uses paths, because of how Dialogue Manager works
func play_voice(path: String, local_volume_change: float = 0):
	voice.stream = load(path)
	voice.volume_db = local_volume_change
	voice.play()



func set_global_volume(option: AUDIO_TYPE, amount: float):
	amount = linear_to_db(amount)
	match option:
		AUDIO_TYPE.master:
			AudioServer.set_bus_volume_db(0, amount)
		AUDIO_TYPE.sfx:
			AudioServer.set_bus_volume_db(1, amount)
		AUDIO_TYPE.sfx:
			AudioServer.set_bus_volume_db(1, amount)
		AUDIO_TYPE.music:
			AudioServer.set_bus_volume_db(2, amount)
		AUDIO_TYPE.ambience:
			AudioServer.set_bus_volume_db(3, amount)
		AUDIO_TYPE.voice:
			AudioServer.set_bus_volume_db(4, amount)
		_:
			print_debug("Invalid audio type")

# Increases/decreases by db amount
func change_local_music_volume(db, fade_time: float = 0):
	db = music.volume_db + db
	var tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", db, fade_time)
