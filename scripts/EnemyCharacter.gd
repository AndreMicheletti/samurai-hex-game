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
	print("MOVE RANDOM")
	
	var adjc = get_cell().get_all_adjacent()
	if adjc.size() <= 0:
		print("NOWHERE TO MOVE")
		return
	# FIND VALID DESTINATION CLOSEST TO PLAYER
	var move_hex = null
	for dest in adjc:
		var pos = dest.get_axial_coords()
		var adjacent = world.is_adjacent(pos, game.player.hex_pos)
		var obstacle = world.is_obstacle(pos)
		if adjacent and not obstacle:
			move_hex = dest
			break
	# FIND VALID DESTINATION RANDOM
	if move_hex == null:
		move_hex = adjc.pop_front()
		adjc.shuffle()
		while move_hex != null and world.is_obstacle(move_hex.get_axial_coords()):
			move_hex = adjc.pop_front()
	# MOVE
	if move_hex != null:
		yield(move_to(move_hex.get_axial_coords()), "completed")
	else:
		print(" ----******* OMG COMPLETE MOVEMENT CRASH RIGHT NOW!!!!!!!!!!")

func follow_player():
	yield(random_wait(), "completed")
	print("FOLLOW PLAYER")
	
	var aux_path = world.find_path(hex_pos, game.player.hex_pos)
	var path = []
	for hex in aux_path:
		var pos = hex.get_axial_coords()
		if pos == hex_pos or pos == game.player.hex_pos:
			continue
		path.append(pos)

	# move following path
	if path.size() <= 0:
		yield(move_random(), "completed")
	else:
		var hex = path.pop_back()
		yield(move_to(hex), "completed")

func end_turn():
	if not active:
		return
	active = false
	moved = 0
	look_to_hex(game.player.hex_pos)
	emit_signal("turn_ended", self)
