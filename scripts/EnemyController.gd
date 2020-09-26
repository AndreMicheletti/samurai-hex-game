extends Controller

enum BehaviourMode {RANDOM, BALANCED, AGGRESSIVE, DEFENSIVE}
export(BehaviourMode) var behaviour_mode = BehaviourMode.RANDOM


func _process_draw():
	cards_selected = []
	character.moved = 0
	if hand.size() <= 0:
		draw_hand()


func _process_choose_card():
	if not ready:
		match behaviour_mode:
			BehaviourMode.RANDOM:
				for i in range(game_match.TURNS_BY_HAND):
					cards_selected.append(hand[randi() % hand.size()])
		ready = true
		print("Enemy Controller chose cards")

func _process_play(delta):
	if not active:
		return

	if character.turn_mov - character.moved <= 0:
		emit_signal("turn_ended")

func get_target_character():
	var controllers = get_tree().get_nodes_in_group("Controller")
	for ctr in controllers:
		if ctr.name == "PlayerController":
			return ctr.get_character()
	return null


func play_turn(turn):
	.play_turn(turn)
	clear_highlights()
	show_possible_moves()
	
	# select path
	var moves = character.turn_mov - character.moved
	var target = get_target_character()
	if moves > 0:
		var path = character.get_world().find_path(character.hex_pos, target.hex_pos)
		if path.size() > 1:
			for i in range(1, min(moves+1, path.size())):
				var to = path[i].get_axial_coords()
				yield(character.move_to(to.x, to.y), "completed")
				character.moved += 1
				clear_highlights()
				show_possible_moves()

		while (character.turn_mov - character.moved) > 0:
			print("STUCK IN WHILE ",  character.turn_mov - character.moved)
			var possible_moves = possible_moves()
			var random = possible_moves[randi() % possible_moves.size()]
			if random[0] != target.hex_pos:
				yield(character.move_to(random[0].x, random[0].y), "completed")
				character.moved += random[1]
				clear_highlights()
				show_possible_moves()

	process_effects()
	emit_signal("turn_ended")


func show_possible_moves():
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
		var instance = MoveHint.instance()
		instance.hex_pos = cell_coords
		instance.move_cost = path.size() - 1
		instance.position = character.get_world().get_grid().get_hex_center(cell)
		instance.connect("move_hint_clicked", self, "move_hint_clicked")
		game_match.Highlights.add_child(instance)



func move_hint_clicked(move_hex_pos, move_cost):
	pass


func on_select_card(card):
	print("CARD SELECTED ", card)
	cards_selected.append(card)
