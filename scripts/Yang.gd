extends DragAndDrop

export(int) var movement = 0
export(int) var speed = 0
export(int) var cost = 0

onready var movement_label = $Texts/Mov
onready var speed_label = $Texts/Spd
onready var cost_label = $Cost/Cost

func _ready():
	movement_label.text = "Mov " + str(movement)
	speed_label.text = "Spd " + str(speed)
	cost_label.text = str(cost)
