extends Panel

var card_resource

signal card_pressed

var enabled = true

func _ready():
	pass

func set_resource(card : CardResource):
	card_resource = card
	$Margin/VBox/Title/Label.text = str(card.title)
	$Margin/VBox/Atk.text = "Atk " + str(card.atk)
	$Margin/VBox/Def.text = "Def " + str(card.def)
	$Margin/VBox/Mov.text = "Mov " + str(card.mov)
	$Margin/VBox/Speed.text = "Spd " + str(card.speed)

func _on_Card_gui_input(event):
	if enabled and event is InputEventScreenTouch:
		if event.pressed == false:
			emit_signal("card_pressed", self)
