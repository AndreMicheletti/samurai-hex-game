extends DragAndDrop

export(int) var attack = 0
export(int) var defense = 0
export(int) var cost = 0

onready var attack_label = $Texts/Atk
onready var defense_label = $Texts/Def
onready var cost_label = $Cost/Cost

func _ready():
	attack_label.text = "Atk " + str(attack)
	defense_label.text = "Def " + str(defense)
	cost_label.text = str(cost)
