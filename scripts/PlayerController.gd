extends Node

class_name PlayerController

export(Array, Resource) var CardDeck

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")

export var hand = []
export var ready = false
var game_match
var character
var cards_selected = []

signal cards_drawn

func _ready():
	add_to_group("Controller")
	game_match = get_tree().get_nodes_in_group("GameMatch")[0]
	character = get_parent()

func get_character():
	return character

func _process(delta):
	if game_match.state == game_match.MatchState.DRAW:
		_process_draw()
	elif game_match.state == game_match.MatchState.CHOOSE_CARD:
		_process_choose_card()
	elif game_match.state == game_match.MatchState.PLAY_TURN:
		_process_play(delta)


func _process_draw():
	cards_selected = []
	character.moved = 0
	if hand.size() <= 0:
		draw_hand()


func _process_choose_card():
	ready = cards_selected.size() >= 1


func _process_play(delta):
	hand = []
	if not game_match.this_turn_ctr() == self:
		return
	
	if game_match.Highlights.get_child_count() <= 0:
		character.set_turn_stats(cards_selected[0])
		show_possible_moves()

	if character.turn_mov - character.moved <= 0:
		# TODO end turn
		ready = true
		return


func show_possible_moves():
	for cell in character.get_cell().get_all_within(character.turn_mov - character.moved):
		if cell.get_axial_coords() == character.hex_pos:
			continue
		var path = character.get_world().find_path(character.hex_pos, cell.get_axial_coords())
		print(path.size())
		if path.size() - 1 > character.turn_mov:
			continue
		var instance = MoveHint.instance()
		instance.hex_pos = cell.get_axial_coords()
		instance.move_cost = path.size() - 1
		instance.position = character.get_world().get_grid().get_hex_center(cell)
		instance.connect("move_hint_clicked", self, "move_hint_clicked")
		game_match.Highlights.add_child(instance)


func move_hint_clicked(move_hex_pos, move_cost):
	character.move_to(move_hex_pos.x, move_hex_pos.y)
	character.moved += move_cost
	clear_highlights()


func clear_highlights():
	self.game_match.clear_highlights()


func draw_hand():
	for i in range(5):
		hand.append(CardDeck[randi() % CardDeck.size()])
	emit_signal("cards_drawn")
	ready = true

func on_select_card(card):
	print("CARD SELECTED ", card)
	cards_selected.append(card)
