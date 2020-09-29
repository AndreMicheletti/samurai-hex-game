extends Panel

class_name Card

const PRESS_DELAY = 1

export(Resource) var card_resource

enum Side {UP, DOWN}

onready var title = $Column/Texts/Title/label
onready var move = $Column/Texts/Move/label
onready var attack = $Column/Texts/Attack/label
onready var defense = $Column/Texts/Defense/label
onready var speed = $Column/Texts/Speed/label

onready var border_particles = $BorderParticles

signal card_selected

export var enable_interaction = false
var selected = false
var active = false
var card_index = null
var side = Side.UP

var press_delay = 0
var has_mouse = false

func _ready():
	# add_to_group("UI_CARD")
	$Index.visible = false
	$Column.visible = true
	$Down.visible = false
	border_particles.emitting = false

func get_resource():
	return card_resource

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

func show_index():
	$Index.visible = true
	$Index/Panel/Label.text = str(card_index)
	
func hide_index():
	$Index.visible = false

func on_pressed():
	if enable_interaction:
		emit_signal("card_selected", self)

func _flip():
	match side:
		Side.UP:
			$Column.visible = false
			$Down.visible = true
			side = Side.DOWN
		Side.DOWN:
			$Column.visible = true
			$Down.visible = false
			side = Side.UP

func flip():
	match side:
		Side.UP:
			$anim.play("flip_back")
		Side.DOWN:
			$anim.play("flip_front")
	yield($anim, "animation_finished")
	self.rect_position.x = 0
	self.rect_scale = Vector2(1, 1)

func reveal_and_activate():
	if side == Side.DOWN:
		yield(flip(), "completed")
	set_active(true)

func set_active(value):
	self.active = value
	border_particles.emitting = value
