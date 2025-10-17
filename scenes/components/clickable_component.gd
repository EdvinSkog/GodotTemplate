class_name ClickableComponent extends Area3D

## Name of the input action (in Project Settings)
@export var hold_action_name := "click"
@export var enabled := true:
	set(value):
		enabled = value
		set_enabled(value)
## If hovered and held, which process should be performed?
@export var parallel_priority := ParallelPriority.BOTH
## If you're holding, end the hover.
@export var hold_ends_hover := false
## If you're no longer hovering, end the hold.
@export var unhover_ends_hold := false
@export_group("Start State Overrides")
@export var starting_hover_state := State.READY
@export var starting_hold_state := State.READY

## Emitted **every frame** the component is being hovered.
signal hovering
## Emitted **every frame** the component is being held.
signal holding
## Emitted the frame the component was first held.
signal just_held
## Emitted the frame the component was released.
signal just_unheld
## Emitted the frame the component was first hovered.
signal just_hovered
## Emitted the frame the component was no longer hovered.
signal just_unhovered

## Applied to both hovering or holding/clicking.
enum State {
	DISABLED, ## Don't process
	READY, ## Ready to perform action.
	ACTIVE, ## Handling action.
}

enum ParallelPriority {
	BOTH, ## If hovered and held, both hovering and holding signals are emitted.
	HOLD, ## If holding, hovering signal won't be emitted.
	HOVER, ## If hovering, holding signal wont't emitted.
}

var _hover_state: State = starting_hover_state
var _hold_state: State = starting_hold_state

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(hold_action_name) and _hover_state == State.ACTIVE:
		_hold_state = State.ACTIVE
		just_held.emit()
		if hold_ends_hover:
			_hover_state = State.READY
			just_unhovered.emit()
	
	if Input.is_action_just_released(hold_action_name) and _hold_state == State.ACTIVE:
		_hold_state = State.READY
		just_unheld.emit()

	match parallel_priority:
		ParallelPriority.BOTH:
			if _hover_state == State.ACTIVE: hovering.emit()
			if _hold_state == State.ACTIVE: holding.emit()
		ParallelPriority.HOLD:
			if _hold_state == State.ACTIVE: holding.emit()
			elif _hover_state == State.ACTIVE: hovering.emit()
		ParallelPriority.HOVER:
			if _hover_state == State.ACTIVE: hovering.emit()
			elif _hold_state == State.ACTIVE: holding.emit()
	
	
#func _ready() -> void:
#	mouse_entered.connect(_on_mouse_entered)
#	mouse_exited.connect(_on_mouse_exited)

func _mouse_enter() -> void:
	if _hover_state == State.DISABLED: return
	if _hold_state == State.ACTIVE and hold_ends_hover: return
	_hover_state = State.ACTIVE
	just_hovered.emit()

func _mouse_exit() -> void:
	if _hover_state == State.DISABLED: return
	_hover_state = State.READY
	just_unhovered.emit()
	if unhover_ends_hold:
		_hold_state = State.READY
		just_unheld.emit()
	
func set_enabled(area := true, hover := true, hold := true) -> void:
	monitoring = area;
	if hover: _hover_state = State.READY
	else: _hover_state = State.DISABLED
	if hold: _hold_state = State.READY
	else: _hold_state = State.DISABLED
