extends Node

class_name GameMatch

const TURNS_BY_HAND = 3

export onready var World = $World
export onready var Player = $World/Player
export onready var Highlights = $Highlights

onready var Cards = $UI/BottomUI/SplitContainer/CardsContainer
onready var debug_label = $Debug/Label

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")
var GameUI = preload("res://scenes/gui/GameUI.tscn")

enum MatchState {DRAW, CHOOSE_CARD, PLAY_TURN}
var state = MatchState.DRAW
var play_turn = 0
var controller_turn_order = []
var controller_turn = 0
var game_ui_node

signal play_state

signal advance_turn

var player1_controller : Controller
var player2_controller : Controller

func _ready():
	var bar = preload("res://scenes/PlayerBar.tscn")
	init_controllers()
	init_ui()
	set_state_draw()

func init_controllers():
	player1_controller = $Controllers/PlayerController
	player2_controller = $Controllers/EnemyController
	for ctr in $Controllers.get_children():
		ctr.connect("defeated", self, "on_controller_defeated")
		ctr.connect("turn_ended", self, "advance_turn")

func init_ui():
	# add GameUI instance
	game_ui_node = GameUI.instance()
	add_child(game_ui_node)
	game_ui_node.game_match = self
	# set enemy and player controllers
	# instance.set_ctr(ctr)
	# connect signals
	game_ui_node.connect("accepted_cards", self, "on_player_accept_cards")
	game_ui_node.connect("advance_turn", self, "on_advance_turn")
	player1_controller.character.connect("character_damaged", game_ui_node, "update_damage_counters")
	player2_controller.character.connect("character_damaged", game_ui_node, "update_damage_counters")
	game_ui_node.update_damage_counters()

func get_controllers():
	return get_tree().get_nodes_in_group("Controller")

func get_alive_controllers():
	var result = []
	for ctr in get_controllers():
		if not ctr.defeated:
			result.append(ctr)
	return result

func controllers_ready():
	for ctr in get_alive_controllers():
		if not ctr.ready:
			return false
	return true

func reset_controllers_ready():
	for ctr in get_alive_controllers():
		ctr.ready = false

func _process(delta):
	_process_debug()
	if state == MatchState.DRAW:
		# _process_draw()
		pass
	elif state == MatchState.CHOOSE_CARD:
		# _process_choose_card()
		pass
	elif state == MatchState.PLAY_TURN:
		# _process_play(delta)
		pass

func _process_debug():
	debug_label.text = "Game State: " + str(state) + "\n"
	if controller_turn_order and controller_turn_order.size() > 0:
		for ctr in controller_turn_order:
			debug_label.text += ("\n " + ctr.name)

#func _process_draw():
#	if controllers_ready():
#		set_state_choose_card()

#func _process_play(delta):
#	if controllers_ready():
#		set_state_draw()

func set_state_draw():
	state = MatchState.DRAW
	reset_controllers_ready()
	player1_controller.draw_hand()
	player2_controller.draw_hand()
	yield(game_ui_node.deal_cards(), "completed")
	set_state_choose_card()

func set_state_choose_card():
	reset_controllers_ready()
	state = MatchState.CHOOSE_CARD
	player2_controller.choose_cards()

func on_player_accept_cards(card_resources):
	player1_controller.cards_selected = card_resources
	set_state_play_turn()

func set_state_play_turn():
	reset_controllers_ready()
	state = MatchState.PLAY_TURN
	emit_signal("play_state")
	play_turn = 0
	controller_turn = -1
	set_turn_order()
	for ctr in controller_turn_order:
		ctr.active = false
	advance_turn()

func advance_turn():
	# inactivate this turn controller
	controller_turn_order[controller_turn].active = false
	controller_turn += 1
	if controller_turn >= controller_turn_order.size():
		# change CARD
		controller_turn = 0
		play_turn += 1
		set_turn_order()
	if play_turn >= TURNS_BY_HAND:
		yield(game_ui_node.clear_side_cards(), "completed")
		set_state_draw()
	else:
	# activate and play next controller
#	if not controller_turn_order[controller_turn].defeated:
		yield(game_ui_node.on_advance_turn(controller_turn_order[controller_turn]), "completed")
		controller_turn_order[controller_turn].active = true
		controller_turn_order[controller_turn].play_turn(play_turn)
#	else:
#		advance_turn()
	# emit_signal("advance_turn", )

func set_turn_order():
	var result = get_alive_controllers()
	result.sort_custom(self, "sort_by_card_speed")
	controller_turn_order = result

func sort_by_health(ctr1 : Controller, ctr2 : Controller):
	# return LEAST DAMAGE to MOST DAMAGE
	if ctr1.character.damage_counter < ctr2.character.damage_counter:
		return true
	return false

func sort_by_card_speed(ctr1 : Controller, ctr2 : Controller):
	# return MOST SPEED to LEAST SPEED
	var card1 : CardResource = ctr1.get_card(play_turn)
	var card2 : CardResource = ctr2.get_card(play_turn)
	if card1 and card2:
		if card1.card_speed > card2.card_speed:
			return true
	return false

func clear_highlights():
	for node in Highlights.get_children():
		node.queue_free()

func set_ctr_process(value : bool):
	for ctr in get_alive_controllers():
		ctr.set_process(value)

func on_controller_defeated(ctr):
	if ctr.name == "PlayerController":
		reset_game()

func reset_game():
	get_tree().reload_current_scene()
