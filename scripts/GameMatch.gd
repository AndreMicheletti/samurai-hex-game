extends Node

onready var World = $World
onready var Player = $World/Player
onready var Highlights = $World/Highlights

onready var Cards = $UI/BottomUI/CardsContainer

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")

enum MatchState {DRAW, CHOOSE_CARD, PLAY_TURN}
export var state = MatchState.DRAW

var assalt_cards = []
var assalt_turn = 0

var turn_atk = 0
var turn_def = 0
var turn_mov = 0

signal draw_state
signal choose_card_state
signal play_state

func _ready():
	set_state_draw()
	for card in Cards.get_children():
		card.connect("card_selected", self, "on_card_selected")

func _process(delta):
	if state == MatchState.DRAW:
		_process_draw()
	elif state == MatchState.CHOOSE_CARD:
		_process_choose_card()
	elif state == MatchState.PLAY_TURN:
		_process_play(delta)


func set_state_draw():
	reset_assalt()
	state = MatchState.DRAW
	emit_signal("draw_state")


func set_state_choose_card():
	state = MatchState.CHOOSE_CARD
	emit_signal("choose_card_state")


func set_state_play_turn():
	state = MatchState.PLAY_TURN
	var card = assalt_cards[assalt_turn]
	emit_signal("play_state", card)
	self.turn_mov = card["mov"]
	self.turn_atk = card["atk"]
	self.turn_def = card["def"]
	clear_highlights()


func _process_draw():
	set_state_choose_card()


func _process_choose_card():
	pass


func _process_play(delta):
	
	if turn_mov <= 0:
		assalt_turn += 1
		if assalt_turn >= assalt_cards.size():
			set_state_draw()
		else:
			set_state_play_turn()
		return
	
	if Highlights.get_child_count() <= 0:
		show_moves()


func show_moves():
	for cell in Player.get_cell().get_all_within(turn_mov):
		if cell.get_axial_coords() == Player.hex_pos:
			continue
		var instance = MoveHint.instance()
		instance.hex_pos = cell.get_axial_coords()
		instance.position = World.get_grid().get_hex_center(cell)
		instance.connect("move_hint_clicked", self, "move_hint_clicked")
		Highlights.add_child(instance)


func move_hint_clicked(move_hex_pos):
	var move_cost = Player.get_cell().distance_to(move_hex_pos)
	Player.move_to(move_hex_pos.x, move_hex_pos.y)
	turn_mov -= move_cost
	clear_highlights()


func on_card_selected(card_info):
	print("SELECTED CARD")
	print(card_info)
	assalt_cards = [card_info]
	set_state_play_turn()


func reset_assalt():
	assalt_cards = []
	assalt_turn = 0


func clear_highlights():
	for node in Highlights.get_children():
		node.queue_free()


