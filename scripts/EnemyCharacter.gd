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
			randomize()
			select_card(randi() % hand.size())
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
	var moves = get_remaining_moves()
		
	match ai_mode:
		AIMode.RANDOM:
			# MOVE RANDOM
			print("MOVE RANDOM")
			for i in range(moves):
				yield(move_random(), "completed")
		AIMode.BALANCED:
			print("FOLLOW PLAYER")
			for i in range(moves):
				yield(follow_player(), "completed")
		AIMode.AGGRESSIVE:
			pass
		AIMode.DEFENSIVE:
			pass

func random_wait():
	var random_wait = (randi() % 3) / 10.0
	yield(get_tree().create_timer(random_wait), "timeout")

func move_random():
	yield(random_wait(), "completed")
	
	var adjc = get_cell().get_all_adjacent()
	if adjc.size() <= 0:
		print("NOWHERE TO MOVE")
		return
	# FIND VALID DESTINATION TO MOVE
	adjc.shuffle()
	var dest = adjc.pop_front()
	while dest != null and world.is_obstacle(dest.get_axial_coords()):
		dest = adjc.pop_front()
	# MOVE
	if dest != null:
		move_to(dest.get_axial_coords())
		yield(self, "move_ended")

func follow_player():
	yield(random_wait(), "completed")
	
	var aux_path = world.find_path(hex_pos, game.player.hex_pos)
	var path = []
	for hex in aux_path:
		var pos = hex.get_axial_coords()
		if pos == hex_pos or pos == game.player.hex_pos:
			continue
		path.append(pos)

	# move following path
	var hex = path.pop_back()
	move_to(hex)
	yield(self, "move_ended")

func end_turn():
	if not active:
		return
	active = false
	moved = 0
	look_to_hex(game.player.hex_pos)
	emit_signal("turn_ended", self)
