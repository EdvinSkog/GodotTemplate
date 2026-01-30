extends Control


@export var enable_debug_ui: bool = false

@onready var cheats: MenuButton = $VBoxContainer/CheatMenu
@onready var cheats_popup: PopupMenu = cheats.get_popup()
# Called when the node enters the scene tree for the first time.
func _ready():
	if(enable_debug_ui):
		visible = true
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
	cheats_popup.id_pressed.connect(check_popup_id)

func check_popup_id(id):
	print(id)
	match id:
		0:
			print("Cheat 0")
		1:
			print("Cheat 1")
		2:
			print("Cheat 2")
