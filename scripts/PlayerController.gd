extends Controller


func _process_play(delta):
	if not active:
		return

	if game_match.Highlights.get_child_count() <= 0:
		show_possible_moves()

	if character.turn_mov - character.moved <= 0:
		process_effects()
		emit_signal("turn_ended")


func play_turn(turn):
	.play_turn(turn)
	show_possible_moves()


func move_hint_clicked(move_hex_pos, move_cost):
	print("MOVE HINT CLICKED FOR PLAYER")
	character.move_to(move_hex_pos.x, move_hex_pos.y)
	character.moved += move_cost
	clear_highlights()


func on_select_card(card):
	print("CARD SELECTED ", card)
	cards_selected.append(card)
