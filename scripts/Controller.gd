extends Node

class_name Controller

export(Array, Resource) var CardDeck

var MoveHint = preload("res://scenes/tileset/MoveHint.tscn")

var hand = []
var ready = false
var game_match
var character
var cards_selected = []

signal cards_drawn

func _ready():
	add_to_group("Controller")
	game_match = get_tree().get_nodes_in_group("GameMatch")[0]

func get_character():
	return character
	
func set_character(ch):
	character = ch
	character.connect("character_died", self, "on_character_died")


func _process(delta):
	if game_match.state == game_match.MatchState.DRAW:
		_process_draw()
	elif game_match.state == game_match.MatchState.CHOOSE_CARD:
		_process_choose_card()
	elif game_match.state == game_match.MatchState.PLAY_TURN:
		_process_play(delta)


func _process_draw():
	pass


func _process_choose_card():
	pass


func _process_play(delta):
	if not game_match.this_turn_ctr() == self:
		return
	_process_turn(delta)


func _process_turn(delta):
	pass


func process_effects():
	print(self.name, " process effects!!")
	if ready == true:
		print("TRYIED TO PROCESS EFFECTS WHEN READY")
		return
	ready = true
	var atk = character.turn_atk
	if atk > 0:
		# has attacks to make
		var characters = get_tree().get_nodes_in_group("Character")
		for target in characters:
			if target != character and character.get_cell().distance_to(target.hex_pos) <= 1:
				var result = target.hit(atk)
				if result is GDScriptFunctionState:
					yield(result, "completed")
	return true


func start_turn():
	print("\n\n\n\n\n", self.name, " start turn!!")
	hand = []
	character.set_turn_stats(cards_selected[0])


func show_possible_moves():
	for move in possible_moves():
		var coords = move[0]
		var cost = move[1]
		var instance = MoveHint.instance()
		instance.hex_pos = coords
		instance.move_cost = cost
		instance.position = character.get_world().get_grid().get_hex_center(coords)
		instance.connect("move_hint_clicked", self, "move_hint_clicked")
		game_match.Highlights.add_child(instance)


func possible_moves():
	# return Array of tuple [Vector2 coords, int cost]
	var result = []
	var moves = character.turn_mov - character.moved
	for cell in character.get_cell().get_all_within(moves):
		var cell_coords = cell.get_axial_coords()
		if cell_coords == character.hex_pos:
			continue
		if character.get_world().is_outside_world(cell_coords):
			continue
		var path = character.get_world().find_path(character.hex_pos, cell_coords)
		if path.size() - 1 > moves:
			continue
		result.append([cell_coords, path.size() - 1])
	return result


func move_hint_clicked(move_hex_pos, move_cost):
	pass


func clear_highlights():
	self.game_match.clear_highlights()


func draw_hand():
	for i in range(5):
		hand.append(CardDeck[randi() % CardDeck.size()])
	emit_signal("cards_drawn")
	ready = true
	print("CARDS DRAWN FOR ", self.name)


func on_character_died():
	print("character died")