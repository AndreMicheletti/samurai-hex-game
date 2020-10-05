extends Panel

var card_resource

signal card_pressed

func _ready():
	pass

func set_resource(card : CardResource):
	card_resource = card
	$Margin/VBox/Title/Label.text = str(card.title)
	$Margin/VBox/Atk.text = str(card.atk)
	$Margin/VBox/Def.text = str(card.def)
	$Margin/VBox/Mov.text = str(card.mov)
	$Margin/VBox/Speed.text = str(card.speed)


func _on_Card_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed == false:
			emit_signal("card_pressed", self)
