extends CanvasLayer

onready var game = get_parent()

var damage_scene = preload("res://scenes/gui/Damage.tscn")
var card_scene = preload("res://scenes/gui/Card.tscn")

var player
var enemy

onready var player_cards = $Screen/Player1/Cards
onready var enemy_cards = $Screen/Player1/Cards

onready var player_center_card = $Screen/CenterLeft
onready var enemy_center_card = $Screen/CenterRight

signal card_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init():
	player = game.player
	enemy = game.enemy
	init_player_gui()
	init_health_counter()
	player.connect("card_dealed", self, "add_card")
	player.connect("card_selected", self, "on_player_select_card")
	enemy.connect("card_selected", self, "on_enemy_select_card")

func init_player_gui():
	$Screen/Player1/Box/Panel/Content/Name/Label.text = player.PlayerName

func init_health_counter():
	# PLAYER HEALTH COUNTER
	var player_node = $Screen/Player1/Box/Panel/Content/Health/Counter
	for i in range(player.get_remaining_health()):
		var node = damage_scene.instance()
		player_node.add_child(node)
	
	# ENEMY HEALTH COUNTER
	var enemy_node = $Screen/Player2/Box/Panel/Content/Health/Counter
	for i in range(enemy.get_remaining_health()):
		var node = damage_scene.instance()
		enemy_node.add_child(node)

func update_health_counter(character, damage):
	if character == player:
		var player_node = $Screen/Player1/Box/Panel/Content/Health/Counter
		for i in range(damage):
			player_node.remove_child(player_node.get_child(0))
	else:
		var enemy_node = $Screen/Player2/Box/Panel/Content/Health/Counter
		for i in range(damage):
			enemy_node.remove_child(enemy_node.get_child(0))

func add_card(card_res : CardResource):
	var node = card_scene.instance()
	node.set_resource(card_res)
	node.connect("card_pressed", self, "on_card_pressed")
	player_cards.add_child(node)

func on_card_pressed(node):
	if game.state == game.Phase.CHOOSE:
		emit_signal("card_pressed", node.card_resource)
		player_cards.remove_child(node)

func show_cards():
	$Tween.interpolate_property(
		player_cards, "rect_position",
		player_cards.rect_position,
		Vector2(player_cards.rect_position.x, 320),
		0.4)
	$Tween.interpolate_property(
		player_center_card, "rect_position",
		player_center_card.rect_position,
		Vector2(270, player_center_card.rect_position.y),
		0.4)
	$Tween.interpolate_property(
		enemy_center_card, "rect_position",
		enemy_center_card.rect_position,
		Vector2(450, enemy_center_card.rect_position.y),
		0.4)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_cards():
	$Tween.interpolate_property(
		player_cards, "rect_position",
		player_cards.rect_position,
		Vector2(player_cards.rect_position.x, 400),
		0.4)
	$Tween.interpolate_property(
		player_center_card, "rect_position",
		player_center_card.rect_position,
		Vector2(20, player_center_card.rect_position.y),
		0.4)
	$Tween.interpolate_property(
		enemy_center_card, "rect_position",
		enemy_center_card.rect_position,
		Vector2(705, enemy_center_card.rect_position.y),
		0.4)
	$Tween.start()
	yield($Tween, "tween_completed")

func reset_center():
	if player_center_card.get_child_count() > 0:
		player_center_card.get_child(0).destroy()
	if enemy_center_card.get_child_count() > 0:
		yield(enemy_center_card.get_child(0).destroy(), "completed")
	yield(get_tree().create_timer(0.1), "timeout")

func on_player_select_card(card_res : CardResource):
	var card = card_scene.instance()
	card.set_resource(card_res)
	player_center_card.add_child(card)

func on_enemy_select_card(card_res : CardResource):
	var card = card_scene.instance()
	card.set_resource(card_res)
	card.set_flipped_back()
	enemy_center_card.add_child(card)

func reveal_enemy_card():
	if enemy_center_card.get_child(0).back:
		yield(enemy_center_card.get_child(0).flip(), "completed")
	yield(get_tree().create_timer(0.1), "timeout")
