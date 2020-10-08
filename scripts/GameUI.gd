extends CanvasLayer

onready var game = get_parent()

var damage_scene = preload("res://scenes/gui/Damage.tscn")
var card_scene = preload("res://scenes/gui/Card.tscn")

var player
var enemy

onready var player_cards = $Bottom/Player1/Cards
onready var enemy_cards = $Top/Player2/Cards

onready var player_center_card = $Center/CenterLeft
onready var enemy_center_card = $Center/CenterRight

onready var player_deck = $Bottom/Player1/Deck/Deck
onready var enemy_deck = $Top/Player2/Deck/Deck

onready var player_name = $Bottom/Player1/Box/Panel/Content/Name/Label
onready var enemy_name = $Top/Player2/Box/Panel/Content/Name/Label

onready var player_health = $Bottom/Player1/Box/Panel/Content/Health/Counter
onready var enemy_health = $Top/Player2/Box/Panel/Content/Health/Counter

onready var turn_time = $Bottom/Player1/TurnTimer

onready var game_over = $Screen/GameOver
onready var game_over_winner = $Screen/GameOver/VBox/Top/VBox/Winner
onready var game_over_message = $Screen/GameOver/VBox/Top/VBox/Message

signal card_pressed

var center_left_middle
var center_right_middle

var center_left_corner = 20
onready var center_right_corner = get_viewport().size.x - 120 - 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init():
	center_left_middle = player_center_card.rect_position.x
	center_right_middle = enemy_center_card.rect_position.x
	player = game.player
	enemy = game.enemy
	init_player_gui()
	init_health_counter()
	player.connect("card_dealed", self, "add_card")
	player.connect("card_dealed", self, "update_decks")
	enemy.connect("card_dealed", self, "update_decks")
	player.connect("card_selected", self, "on_player_select_card")
	enemy.connect("card_selected", self, "on_enemy_select_card")

func init_player_gui():
	player_name.text = player.PlayerName

func init_health_counter():
	# PLAYER HEALTH COUNTER
	var player_node = player_health
	for i in range(player.get_remaining_health()):
		var node = damage_scene.instance()
		player_node.add_child(node)
	
	# ENEMY HEALTH COUNTER
	var enemy_node = enemy_health
	for i in range(enemy.get_remaining_health()):
		var node = damage_scene.instance()
		enemy_node.add_child(node)

func update_health_counter(character, damage):
	if character == player:
		var player_node = player_health
		for i in range(damage):
			player_node.remove_child(player_node.get_child(0))
	else:
		var enemy_node = enemy_health
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

func remove_player_card(idx):
	player_cards.remove_child(player_cards.get_child(idx))

func show_cards():
	$Tween.interpolate_property(
		player_cards, "rect_position",
		player_cards.rect_position,
		Vector2(player_cards.rect_position.x, player_cards.rect_position.y - 100),
		0.4)
	$Tween.interpolate_property(
		player_center_card, "rect_position",
		player_center_card.rect_position,
		Vector2(center_left_middle, player_center_card.rect_position.y),
		0.4)
	$Tween.interpolate_property(
		enemy_center_card, "rect_position",
		enemy_center_card.rect_position,
		Vector2(center_right_middle, enemy_center_card.rect_position.y),
		0.4)
	$Tween.start()
	yield($Tween, "tween_completed")

func hide_cards():
	$Tween.interpolate_property(
		player_cards, "rect_position",
		player_cards.rect_position,
		Vector2(player_cards.rect_position.x, player_cards.rect_position.y + 100),
		0.4)
	$Tween.interpolate_property(
		player_center_card, "rect_position",
		player_center_card.rect_position,
		Vector2(center_left_corner, player_center_card.rect_position.y),
		0.4)
	$Tween.interpolate_property(
		enemy_center_card, "rect_position",
		enemy_center_card.rect_position,
		Vector2(center_right_corner, enemy_center_card.rect_position.y),
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

func reveal_faster_card(character):
	yield(get_tree().create_timer(0.5), "timeout")
	var card_node
	if character == "player":
		card_node = player_center_card.get_child(0)
	else:
		card_node = enemy_center_card.get_child(0)
	yield(card_node.play_choose(), "completed")
	yield(get_tree().create_timer(0.5), "timeout")

func reveal_enemy_card():
	if enemy_center_card.get_child(0).back:
		yield(enemy_center_card.get_child(0).flip(), "completed")
	yield(get_tree().create_timer(0.1), "timeout")

func update_decks(_card_dealed):
	player_deck.set_value(player.deck_count())
	enemy_deck.set_value(enemy.deck_count())

func show_game_over(player_win, message):
	# disable click for all cards
	for card in player_cards.get_children():
		card.enabled = false
	player_cards.visible = false
	player_center_card.visible = false
	enemy_cards.visible = false
	enemy_center_card.visible = false
	turn_time.stop()
	# show game over panel
	game_over.visible = true
	game_over_message.text = message
	if player_win:
		game_over_winner.text = "YOU WIN"
	else:
		game_over_winner.text = "YOU LOSE"

func _on_PlayAgain_pressed():
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	var title_scene = load("res://scenes/TitleScreen.tscn")
	get_tree().change_scene_to(title_scene)
