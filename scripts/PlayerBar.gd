extends Panel


var controller : Controller = null
export(Resource) var healthTexture

onready var dmg_container = $MarginContainer/HSplitContainer/VerticalContainer/DamageContainer
onready var title_label = $MarginContainer/HSplitContainer/VerticalContainer/PlayerName
onready var turn_display = $MarginContainer/HSplitContainer/MarginContainer/TurnDisplay

onready var heart = preload("res://scenes/gui/DamageDisplay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_display.visible = false
	visible = true


func set_ctr(contr):
	controller = contr
	controller.character.connect("character_damaged", self, "update_health_counter")
	update_health_counter()
	title_label.text = controller.playerName


func update_health_counter():
	print("UPDATE HEALTH COUNTER")
	
	for child in dmg_container.get_children():
		child.queue_free()
	
	if controller.defeated:
		return
	var health = controller.character.DamageLimit - controller.character.damage_counter
	for i in range(health):
		var display = heart.instance()
		dmg_container.add_child(display)

func on_draw_state():
	turn_display.visible = false

func on_advance_turn(ctr):
	turn_display.visible = controller == ctr
