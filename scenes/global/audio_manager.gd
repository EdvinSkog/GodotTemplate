extends Node

enum AUDIO_TYPE {sfx, music, voice}
@onready var sfx_scene: PackedScene = load("res://scenes/global/audio/sound_effect.tscn")
@onready var music = $Music
@onready var voice = $Voice
# Global volume parameters
var volume_sfx = -15
var volume_music = -10
var volume_voice = -10


# Uses and instantiates the sound_effect.tscn
func play_sfx(path: String, local_volume_change: float = 0):
	var sfx = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = volume_sfx + local_volume_change
	add_child(sfx)
	pass

# Uses paths, not AudioStream.
func play_music(path: String, local_volume_change: float = 0):
	music.stream = load(path)
	music.volume_db = volume_music + local_volume_change
	music.play()

#This function uses paths, because of how Dialogue Manager works
func play_voice(path: String, local_volume_change: float = 0):
	voice.stream = load(path)
	voice.volume_db = volume_voice + local_volume_change
	voice.play()

func set_global_volume(option: AUDIO_TYPE, amount: float):
	match option:
		AUDIO_TYPE.sfx:
			volume_sfx = amount
		AUDIO_TYPE.music:
			volume_music = amount
		AUDIO_TYPE.voice:
			volume_voice = amount
		_:
			print_debug("Invalid audio type")

# Increases/decreases by db amount
func change_local_music_volume(db, fade_time: float = 0):
	db = music.volume_db + db
	var tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", db, fade_time)
	#print("volume_db = ", music.volume_db, " and ", db)
