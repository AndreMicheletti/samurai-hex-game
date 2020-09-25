extends Panel

export(String) var CardTitle = ""
export(int) var MoveValue = 0
export(int) var AttackValue = 0
export(int) var DefenseValue = 0

onready var title = $Column/Texts/Title/label
onready var move = $Column/Texts/Move/label
onready var attack = $Column/Texts/Attack/label
onready var defense = $Column/Texts/Defense/label

signal card_selected

func _ready():
	title.text = CardTitle
	
	if CardTitle.length() > 15:
		title.get_font("font").size = 10
	elif CardTitle.length() > 8:
		title.get_font("font").size = 12
	
	move.text = "Move " + str(MoveValue)
	attack.text = "Attack " + str(AttackValue)
	defense.text = "Defense " + str(DefenseValue)
	


func _on_Button_pressed():
	var cardInfo = {
		"id": randi(),
		"title": CardTitle,
		"atk": AttackValue,
		"def": DefenseValue,
		"mov": MoveValue
	}
	emit_signal("card_selected", cardInfo)
