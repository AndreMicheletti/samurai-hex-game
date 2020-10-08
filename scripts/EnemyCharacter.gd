extends Character

enum AIMode {RANDOM, BALANCED, AGRESSIVE, DEFENSIVE}

export(AIMode) var ai_mode = AIMode.RANDOM

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()

func choose_card():
	match ai_mode:
		AIMode.RANDOM:
			randomize()
			select_card(randi() % hand.size())
		AIMode.BALANCED:
			pass
		AIMode.AGGRESSIVE:
			pass
		AIMode.DEFENSIVE:
			pass

func play_turn():
	print("ENEMY PLAY TURN!! ")
	emit_signal("turn_started", self)
	moved = 0
	yield(reveal_card(), "completed")
	var res = select_movement()
	if res is GDScriptFunctionState:
		yield(res, "completed")
	end_turn()

func reveal_card():
	yield(game.game_ui.reveal_enemy_card(), "completed")
	yield(get_tree().create_timer(0.5), "timeout")

func select_movement():
	# FIND PATH TO PLAYER
	var aux_path = world.find_path(hex_pos, game.player.hex_pos)
	var path = []
	for hex in aux_path:
		var pos = hex.get_axial_coords()
		if pos == hex_pos or pos == game.player.hex_pos:
			continue
		path.append(pos)
	
	var moves = get_remaining_moves()
	if moves > path.size():
		print("MOVE RANDOM")
		match ai_mode:
			AIMode.RANDOM:
				# MOVE RANDOM
				var adjc = get_cell().get_all_adjacent()
				if adjc.size() <= 0:
					print("NOWHERE TO MOVE")
					return select_movement()
				# FIND VALID DESTINATION TO MOVE
				adjc.shuffle()
				var dest = adjc.pop_front()
				while dest != null and world.is_obstacle(dest.get_axial_coords()):
					print("stuck in while")
					adjc.shuffle()
					dest = adjc.pop_front()
				# MOVE
				var random_wait = (randi() % 3) / 10.0
				yield(get_tree().create_timer(random_wait), "timeout")
				move_to(dest.get_axial_coords())
				yield(self, "move_ended")
				# CALL RECURSIVE
				return select_movement()
			AIMode.BALANCED:
				pass
			AIMode.AGGRESSIVE:
				pass
			AIMode.DEFENSIVE:
				pass

	# move following path
	for hex in path:
		var random_wait = (randi() % 3) / 10.0
		yield(get_tree().create_timer(random_wait), "timeout")
		move_to(hex)
		yield(self, "move_ended")

func end_turn():
	if not active:
		return
	active = false
	moved = 0
	look_to_hex(game.player.hex_pos)
	emit_signal("turn_ended", self)
