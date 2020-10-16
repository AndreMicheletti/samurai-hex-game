extends Control

var card_resource

signal card_pressed

var enabled = true
var back = false

func _ready():
	pass

func set_resource(card : CardResource):
	card_resource = card
	$Modulate/Margin/Name.text = str(card.title)
	$Modulate/Margin/Atk.text = str(card.atk)
	$Modulate/Margin/Def.text = str(card.def)
	$Modulate/Margin/Mov.text = str(card.mov)
	$Modulate/Margin/Speed.text = str(card.speed)
	$Special.emitting = card_resource.special

func _on_Card_gui_input(event):
	if enabled and event is InputEventScreenTouch:
		if event.pressed == false:
			emit_signal("card_pressed", self)

func flip():
	if back:
		$anim.play("flip_front")
		yield($anim, "animation_finished")
		back = false
		$Special.emitting = card_resource.special
	else:
		$anim.play("flip_back")
		yield($anim, "animation_finished")
		back = true
		enabled = false
		$Special.emitting = false

func set_flipped_back():
	enabled = false
	back = true
	# $Modulate/frontside.visible = false
	$Modulate/backside.visible = true
	$Modulate/Margin.visible = false
	rect_scale = Vector2(-1, 1)
	$Special.emitting = false

func play_choose():
	$anim.play("choose")
	yield($anim, "animation_finished")
	
func destroy():
	$anim.play("destroy_nice")
	yield($anim, "animation_finished")
	queue_free()
