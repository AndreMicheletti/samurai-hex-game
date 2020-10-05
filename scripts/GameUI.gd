extends CanvasLayer

onready var game = get_parent()

var damage_scene = preload("res://scenes/gui/Damage.tscn")
var card_scene = preload("res://scenes/gui/Card.tscn")

var player
var enemy

onready var player_cards = $Screen/Player1/Cards

signal card_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init():
	player = game.player
	enemy = game.enemy
	init_player_gui()
	update_health_counter()
	player.connect("card_dealed", self, "add_card")

func init_player_gui():
	$Screen/Player1/Box/Panel/Content/Name/Label.text = player.PlayerName

func update_health_counter():
	var player_node = $Screen/Player1/Box/Panel/Content/Health/Counter
	for n in player_node.get_children():
		n.queue_free()
	for i in range(player.get_remaining_health()):
		var node = damage_scene.instance()
		player_node.add_child(node)

func add_card(card_res : CardResource):
	var node = card_scene.instance()
	node.set_resource(card_res)
	node.connect("card_pressed", self, "on_card_pressed")
	player_cards.add_child(node)

func on_card_pressed(node):
	emit_signal("card_pressed", node.card_resource)
	player_cards.remove_child(node)

func show_cards():
	var initial = player_cards.rect_position
	var final = Vector2(initial.x, 320)
	$Tween.interpolate_property(player_cards, "rect_position", initial, final, 0.4)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_cards():
	var initial = player_cards.rect_position
	var final = Vector2(initial.x, 400)
	$Tween.interpolate_property(player_cards, "rect_position", initial, final, 0.4)
	$Tween.start()
	yield($Tween, "tween_completed")
