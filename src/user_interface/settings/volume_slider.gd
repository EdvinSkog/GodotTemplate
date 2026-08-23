extends HSlider

@export var bus_name: String = "Master"

func _ready() -> void:
	var volume_db: float = Audio.get_bus_volume(bus_name)
	value = db_to_linear(volume_db)

func _on_value_changed(_value: float) -> void:
	Audio.set_bus_volume(bus_name, _value)
