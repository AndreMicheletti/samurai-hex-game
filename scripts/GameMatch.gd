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
	#elif state == MatchState.PLAY_TURN:
		#_process_play(delta)


func set_state_draw():
	reset_controllers_ready()
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
	var play_turn = 0
	for i in range(TURNS_BY_HAND):
		yield(play_turn(i), "completed")
	set_state_draw()


func play_turn(turn):
	print("\n\nTURN STARTED // PLAY NEXT CARD")
	for ctr in get_controllers():
		print("\n", ctr.name, " IS ACTIVE")
		ctr.active = true
		ctr.play_turn(turn)
		yield(ctr, "turn_ended")
		print(ctr.name, " TURN ENDED")
		ctr.active = false

func _process_draw():
	if controllers_ready():
		set_state_choose_card()


func _process_choose_card():
	if controllers_ready():
		set_state_play_turn()


func clear_highlights():
	for node in Highlights.get_children():
		node.queue_free()


func set_ctr_process(value : bool):
	for ctr in get_controllers():
		ctr.set_process(value)

func on_controller_defeated(controller):
	if controller.name == "PlayerController":
		reset_game()
		
func reset_game():
	get_tree().reload_current_scene()
