extends Panel

class_name Card

const PRESS_DELAY = 1

export(Resource) var card_resource

onready var title = $Column/Texts/Title/label
onready var move = $Column/Texts/Move/label
onready var attack = $Column/Texts/Attack/label
onready var defense = $Column/Texts/Defense/label
onready var speed = $Column/Texts/Speed/label

signal card_selected

export var enable_interaction = true
var selected = false

var press_delay = 0
var has_mouse = false

func _ready():
	add_to_group("UI_CARD")

func set_resource(res : CardResource):
	card_resource = res
	title.text = card_resource.card_title

	if title.text.length() > 15:
		title.get_font("font").size = 10
	elif title.text.length() > 8:
		title.get_font("font").size = 12

	move.text = "Move " + str(card_resource.card_mov)
	attack.text = "Attack " + str(card_resource.card_atk)
	defense.text = "Defense " + str(card_resource.card_def)
	speed.text = "Speed " + str(card_resource.card_speed)

func _process(delta):
	if press_delay > 0:
		press_delay = max(press_delay - delta, 0)

func _on_Card_mouse_entered():
	has_mouse = true

func _on_Card_mouse_exited():
	has_mouse = false

func _on_Card_gui_input(event):
	#print("press_delay ", press_delay)
	if press_delay == 0:
		if event is InputEventScreenTouch:
			press_delay = PRESS_DELAY
			on_pressed()

func on_pressed():
	if enable_interaction:
		emit_signal("card_selected", self)
