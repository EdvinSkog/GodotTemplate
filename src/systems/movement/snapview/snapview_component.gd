class_name Snapview extends Node3D

# Also known as the Inscryption View
#@export_custom(PROPERTY_HINT_NONE, "suffix:m") var height: float = 1.5

@export_enum("Primary Focus", "Last Used") var starting_focus := 0
@export_enum("Primary Focus", "Any Focus", "Unallowed") var allow_exit := 1
@export var snapview_marker: Marker3D
@export var exit_marker: Marker3D

@onready var camera: Camera3D = %Camera3D
@onready var head: Node3D = $Head
@onready var ray: RayCast3D = %ClickingRay

signal switched_focus(focus_index: int)
signal entered_snapview
signal exited_snapview

const base_fov: float = 70

var current_focus_index: int:
	set(value):
		value = clamp(value, 0, focuses.size() - 1)
		current_focus_index = value

var focuses: Array[SnapviewFocus]:
	get = get_focus_markers

enum State {DISABLED, STANDBY, ANIMATING, ENGAGED, LOCKED}
var state: State = State.STANDBY

func _process(_delta: float) -> void:
	pass
	if state == State.ENGAGED and Player.is_snapviewed():
		var mousePos: Vector2 = Player.snapview.camera.get_viewport().get_mouse_position()
		ray.target_position = camera.project_local_ray_normal(mousePos) * 10
#
		if ray.is_colliding():
			var area := ray.get_collider()
			#if area is ClickableComponent:
			#	area.module.on_snapview_raycast_hit(ray)

func activate() -> void:
	camera.current = true
	Player.snapview = self
	await switch_focus(1, false)
	entered_snapview.emit()

func deactivate() -> void:
	#await transform_camera(fpc.CAMERA.global_transform, State.STANDBY)
	camera.current = false
	#fpc.toggle_active(true)
	Player.snapview = null
	ray.target_position = Vector3.DOWN
	exited_snapview.emit()

func _input(event: InputEvent) -> void:
	if state == State.ENGAGED:
		if event.is_action_pressed("move_right"):
			switch_focus(current_focus_index + 1)
		if event.is_action_pressed("move_left"):
			switch_focus(current_focus_index - 1)

func transform_camera(to_transform: Transform3D, new_state: State, fov: float = 70, animate: bool = true) -> void:
	var duration: float = 0.42
	if !animate:
		duration = 0.01
	state = State.ANIMATING
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(head, "global_transform", to_transform, duration)
	tween.parallel().tween_property(camera, "fov", fov, duration+0.08)
	#await tween.finished
	await get_tree().create_timer(duration*0.25).timeout 
	state = new_state

func get_focus_markers() -> Array:
	var arr: Array[SnapviewFocus]
	for node in get_children():
		if node is SnapviewFocus:
			arr.append(node)
	return arr

func switch_focus(focus_index: int, animate: bool = true) -> void:
	current_focus_index = focus_index
	
	var focus: SnapviewFocus = focuses[current_focus_index]
	
	await transform_camera(focus.global_transform, State.ENGAGED, base_fov + focus.fov_modifier, animate)
	switched_focus.emit(focus_index)
