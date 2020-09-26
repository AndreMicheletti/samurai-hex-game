extends Node

const TURNS_BY_HAND = 1

export onready var World = $World
export onready var Player = $World/Player
export onready var Highlights = $World/Highlights

onready var Cards = $UI/BottomUI/CardsContainer
onready var debug_label = $UI/DebugLabel

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")

enum MatchState {DRAW, CHOOSE_CARD, PLAY_TURN}
export var state = MatchState.DRAW

signal draw_state
signal choose_card_state
signal play_state
signal ai_state

signal start_turn

export var play_turn = 0
export var controller_turn = 0

func _ready():
	set_state_draw()
	for ctr in get_controllers():
		print("connecting ", ctr.name)
		self.connect("start_turn", ctr, "on_start_turn")


func get_controllers():
	return get_tree().get_nodes_in_group("Controller")


func controllers_ready():
	for ctr in get_controllers():
		if not ctr.ready:
			return false
	return true


func reset_controllers_ready():
	for ctr in get_controllers():
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
	play_turn = 0
	controller_turn = 0
	state = MatchState.DRAW
	emit_signal("draw_state")


func set_state_choose_card():
	reset_controllers_ready()
	state = MatchState.CHOOSE_CARD
	emit_signal("choose_card_state")


func set_state_play_turn():
	reset_controllers_ready()
	play_turn = 0
	controller_turn = 0
	state = MatchState.PLAY_TURN
	emit_signal("play_state")
	emit_signal("start_turn")


func _process_draw():
	if controllers_ready():
		set_state_choose_card()


func _process_choose_card():
	if controllers_ready():
		set_state_play_turn()


func _process_play(delta):
	if play_turn > TURNS_BY_HAND:
		set_state_draw()
	else:
		if this_turn_ctr().ready:
			# step to next controller
			controller_turn += 1
			if controller_turn >= get_controllers().size():
				# if everybody played, end turn and go to next
				controller_turn = 0
				play_turn += 1
				emit_signal("start_turn")
		#else:
			#if randi() % 2 == 0:
			#	print(" ///////////// TURN FOR ", this_turn_ctr().name, "")


func this_turn_ctr():
	return get_controllers()[controller_turn]


func resolve_turn_effects():
	# check attack
	pass


func clear_highlights():
	for node in Highlights.get_children():
		node.queue_free()


func set_ctr_process(value : bool):
	for ctr in get_controllers():
		ctr.set_process(value)
