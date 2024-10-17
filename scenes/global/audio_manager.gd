extends Node

enum AUDIO_TYPE {master, sfx, music, ambience, voice}
@onready var sfx_scene: PackedScene = load("res://scenes/global/audio/sound_effect.tscn")
@onready var music = $Music
@onready var voice = $Voice
@onready var ambience = $Voice

@export_dir var music_folder_path: String = "res://assets/audio/music"
var songlist: Dictionary = {}  # Dictionary to store song references by name

func _ready() -> void:
	load_music_files()

func load_music_files():
	# Standard
	var dir: DirAccess = DirAccess.open(music_folder_path)
	dir.list_dir_begin()  # Start reading the directory
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".wav") or file_name.ends_with(".mp3") or file_name.ends_with(".ogg"):  # Check for valid music files
			var song_name = file_name.get_basename()  # Get the file name without extension
			songlist[song_name] = music_folder_path + "/" + file_name  # Add to the dictionary
		file_name = dir.get_next()
	dir.list_dir_end()  # Close directory
	print("Songlist: ", songlist)


# Uses and instantiates the sound_effect.tscn
func play_sfx(path: String, local_volume_change: float = 0):
	var sfx = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = local_volume_change
	add_child(sfx)

# Uses paths, not AudioStream.
func play_music(song_name: String, local_volume_change: float = 0):
	var song_path = songlist.get(song_name, null)
	if song_path:
		print(song_path)
		var music_stream = load(song_path)
		if music_stream:
			if music.stream:
				music.stop()  # Stop any currently playing music
			music.stream = music_stream
			music.play()
		else:
			print("Error: Could not load the music stream for song:", song_name)
	else:
		print("Error: Song name not found in songlist:", song_name)

func play_ambience(path: String, local_volume_change: float = 0):
	ambience.stream = load(path)
	ambience.volume_db = local_volume_change
	ambience.play()

#This function uses paths, because of how Dialogue Manager works
func play_voice(path: String, local_volume_change: float = 0):
	voice.stream = load(path)
	voice.volume_db = local_volume_change
	voice.play()

func stop_music(fade_time: float = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", -30, fade_time)
	await tween.finished
	music.stop()

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
func change_music_volume(db, fade_time: float = 0):
	db = music.volume_db + db
	var tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", db, fade_time)
