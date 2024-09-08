extends Control

@export_enum("GameManager", "PlayerVariables") var what_script = 0
@export var what_property: String
@export var custom_text: String
var selected_script
var expression = Expression.new()

@onready var label_value: Label = $LabelValue
@onready var label_property: Label = $LabelProperty

# Called when the node enters the scene tree for the first time.
func _ready():
	label_property.text = what_property + "="
	if(!custom_text.is_empty()):
		label_property.text = custom_text + "="
	match what_script:
		0:
			selected_script = GameManager
		1:
			selected_script = PlayerVariables
	expression.parse(what_property) # Security risk?

func _process(delta):
	var result = expression.execute([], selected_script)
	label_value.text = str(result)
