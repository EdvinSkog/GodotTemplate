class_name DataManager extends Node

@export_group("Data Services")
@export var content: ContentRegistry

@export_group("Audio Catalogs")
@export_dir var music_folder_path := "res://assets/audio/music"
@export_dir var voice_folder_path := "res://assets/audio/voice"

var songs: Dictionary[StringName, AudioStream] = {}
var voices: Dictionary[StringName, AudioStream] = {}


func _ready() -> void:
	reload_audio_catalogs()


func reload_audio_catalogs() -> void:
	songs = _load_audio_catalog(music_folder_path)
	voices = _load_audio_catalog(voice_folder_path)


func get_song(song_id: StringName) -> AudioStream:
	return songs.get(song_id) as AudioStream


func get_voice(voice_id: StringName) -> AudioStream:
	return voices.get(voice_id) as AudioStream


func _load_audio_catalog(folder_path: String) -> Dictionary[StringName, AudioStream]:
	var catalog: Dictionary[StringName, AudioStream] = {}
	for path: String in _get_resource_paths(folder_path):
		var stream := ResourceLoader.load(path) as AudioStream
		if not stream:
			continue
		var audio_id := StringName(stream.resource_name)
		if audio_id.is_empty():
			audio_id = StringName(path.get_file().get_basename())
		if catalog.has(audio_id):
			push_warning("Duplicate audio ID '%s' at %s" % [audio_id, path])
			continue
		catalog[audio_id] = stream
	return catalog


func _get_resource_paths(path: String) -> PackedStringArray:
	if not ResourceDirectory.exists(path):
		push_warning("Audio catalog folder could not be opened: %s" % path)
		return PackedStringArray()
	var paths := PackedStringArray()
	for child_path: String in ResourceDirectory.list_files(path):
		if ResourceLoader.exists(child_path):
			paths.append(child_path)
	return paths
