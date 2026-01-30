extends HSlider

@export var bus_name: String = "Master"

var bus_index

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db: float = AudioServer.get_bus_volume_db(bus_index)
	value = db_to_linear(volume_db)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
