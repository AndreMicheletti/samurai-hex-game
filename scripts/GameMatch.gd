extends Node

const TURNS_BY_HAND = 2

export onready var World = $World
export onready var Player = $World/Player
export onready var Highlights = $World/Highlights

onready var Cards = $UI/BottomUI/CardsContainer
onready var debug_label = $UI/DebugLabel

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")

enum MatchState {DRAW, CHOOSE_CARD, PLAY_TURN}
var state = MatchState.DRAW
var play_turn = 0
var controller_turn_order = []
var controller_turn = 0

signal draw_state
signal choose_card_state
signal play_state
signal ai_state

func _ready():
	for ctr in get_controllers():
		ctr.connect("defeated", self, "on_controller_defeated")
	set_state_draw()


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
	debug_label.text = "Game State: " + str(state)
	if state == MatchState.DRAW:
		_process_draw()
	elif state == MatchState.CHOOSE_CARD:
		_process_choose_card()
	elif state == MatchState.PLAY_TURN:
		_process_play(delta)


func set_state_draw():
	reset_controllers_ready()
#	for ctr in get_controllers():
#		if ctr.defeated:
#			ctr.queue_free()
	state = MatchState.DRAW
	emit_signal("draw_state")


func set_state_choose_card():
	reset_controllers_ready()
	state = MatchState.CHOOSE_CARD
	emit_signal("choose_card_state")


func set_state_play_turn():
	reset_controllers_ready()
	state = MatchState.PLAY_TURN
	emit_signal("play_state")
	play_turn = 0
	controller_turn = -1
	set_turn_order()
	for ctr in controller_turn_order:
		ctr.active = false
		ctr.connect("turn_ended", self, "advance_turn")
	advance_turn()


func _process_draw():
	if controllers_ready():
		set_state_choose_card()


func _process_choose_card():
	if controllers_ready():
		set_state_play_turn()


func _process_play(delta):
	if controllers_ready():
		set_state_draw()


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
			set_state_draw()
			return
	# activate and play next controller
	if not controller_turn_order[controller_turn].defeated:
		controller_turn_order[controller_turn].active = true
		controller_turn_order[controller_turn].play_turn(play_turn)
	else:
		advance_turn()


func set_turn_order():
	# TODO custom turn order
	controller_turn_order = get_alive_controllers()

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
