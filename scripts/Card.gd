extends Panel

export(Resource) var card_resource

onready var title = $Column/Texts/Title/label
onready var move = $Column/Texts/Move/label
onready var attack = $Column/Texts/Attack/label
onready var defense = $Column/Texts/Defense/label

signal card_selected

func _ready():
	pass

func set_resource(res):
	card_resource = res
	title.text = card_resource.card_title
	
	if title.text.length() > 15:
		title.get_font("font").size = 10
	elif title.text.length() > 8:
		title.get_font("font").size = 12
	
	move.text = "Move " + str(card_resource.card_mov)
	attack.text = "Attack " + str(card_resource.card_atk)
	defense.text = "Defense " + str(card_resource.card_def)

func _on_Button_pressed():
	emit_signal("card_selected", card_resource)
