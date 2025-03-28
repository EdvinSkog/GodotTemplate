extends Node

@onready var sfx_scene: PackedScene = load("res://scenes/global/audio/sound_effect.tscn")
@onready var music_player = $Music
@onready var voice = $Voice
@onready var ambience = $Voice

@export_dir var music_folder_path: String = "res://assets/audio/music"
var songlist: Dictionary[StringName, String] = {}  # Dictionary to store song references by name




func _ready() -> void:
	load_music_files()

func load_music_files(folder_path: String = ""):
	#print("music_folder_path:", music_folder_path)
	#print("folder_path:", folder_path)

	var dir: DirAccess = DirAccess.open(music_folder_path + folder_path)

	if dir:
		dir.list_dir_begin()  # Start reading the directory
		var file_name = dir.get_next()
		#print("file_name before loop: ", file_name)
		while file_name != "":
			#print("file_name: ", file_name)
			# Ignore "." and ".." which refer to the current and parent directory
			if file_name != "." and file_name != "..":
				var full_path = music_folder_path + folder_path + "/" + file_name
				#print("full_path: ", full_path)
				if dir.current_is_dir():
					# Recursively load music files from subdirectories
					load_music_files(folder_path + "/" + file_name)
				elif file_name.ends_with(".wav.import") or file_name.ends_with(".mp3.import") or file_name.ends_with(".ogg.import"):
					if (file_name.ends_with(".import")):
						file_name = file_name.get_basename()
					var song_name = file_name.get_basename()  # Get the file name without extension
					#print("Adding:", song_name)
					songlist[song_name] = full_path.get_basename()  # Add full path to the dictionary
			file_name = dir.get_next()
		dir.list_dir_end()  # Close directory
	else:
		print_debug("Error: Could not open folder at path:", music_folder_path + folder_path)

# Uses and instantiates the sound_effect.tscn
func play_sfx(path: String, volume_modifier: float = 0):
	var sfx = sfx_scene.instantiate()
	sfx.stream = load(path)
	sfx.volume_db = 0 + volume_modifier
	add_child(sfx)

# Uses paths, not AudioStream.
func play_music(song_name: String, volume_modifier: float = 0, fade_time = 0.1):
	var song_path = songlist.get(song_name, null)
	if song_path:
		var music_stream = load(song_path)
		if music_stream:
			if music_player.stream:
				music_player.stop()  # Stop any currently playing music
			
			music_player.stream = music_stream
			
			music_player.volume_db = -40
			music_player.play()
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(music_player, "volume_db", 0 + volume_modifier, fade_time)
		else:
			print("Error: Could not load the music stream for song:", song_name)
	else:
		print("Error: Song name not found in songlist:", song_name)

func play_ambience(path: String, volume_modifier: float = 0):
	ambience.stream = load(path)
	ambience.volume_db = 0 + volume_modifier
	ambience.play()

#This function uses paths, because of how Dialogue Manager works
func play_voice(path: String, volume_modifier: float = 0):
	voice.stream = load(path)
	voice.volume_db = 0 + volume_modifier
	voice.play()

func stop_music(fade_time: float = 0.1):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(music_player, "volume_db", -40, fade_time)
	await tween.finished
	music_player.stop()

func set_global_volume(bus_name: String, amount: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	amount = linear_to_db(amount)
	AudioServer.set_bus_volume_db(bus_index, amount)

# Increases/decreases by db amount
func change_music_volume(db, fade_time: float = 0):
	db = 0 + db
	var tween = get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", db, fade_time)
