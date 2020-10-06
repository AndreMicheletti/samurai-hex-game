extends Panel

var card_resource

signal card_pressed

var enabled = true
var back = false

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

func flip():
	if back:
		$anim.play("flip_front")
		yield($anim, "animation_finished")
		back = false
	else:
		$anim.play("flip_back")
		yield($anim, "animation_finished")
		back = true

func set_flipped_back():
	back = true
	$backside.visible = true
	$Margin.visible = false
	rect_scale = Vector2(-1, 1)

func destroy():
	$anim.play("destroy")
	yield($anim, "animation_finished")
	queue_free()
