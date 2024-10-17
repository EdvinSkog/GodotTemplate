extends Node3D

signal aimed_valid_target
signal aimed_invalid_target

@onready var ray : RayCast3D = $RayCast3D

func _ready():
	pass # Replace with function body.

func _process(delta):
	aiming_at(Node3D)

func aiming_at(type : Variant ):
	var collision = ray.get_collider()
	if collision:
		if is_instance_of(collision, type):
			PlayerVariables.aiming_target = collision
			aimed_valid_target.emit()
		else:
			PlayerVariables.aiming_target = null
			aimed_invalid_target.emit()
	else:
		#PlayerVariables.aiming_target = null
		aimed_invalid_target.emit()
