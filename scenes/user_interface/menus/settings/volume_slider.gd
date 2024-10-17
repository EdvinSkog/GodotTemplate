extends HSlider

@export var bus_name: String = "Master"

var bus_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	print("Chaing value ", value, " in ", bus_index)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
