class_name SoundEffect extends AudioStreamPlayer

func _init() -> void:
	autoplay = true
	bus = &"Sfx" #DANGER if renamed

func _ready() -> void:
	finished.connect(_on_finished)

func _on_finished() -> void:
	queue_free()
