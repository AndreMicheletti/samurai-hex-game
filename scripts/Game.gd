extends Node2D

enum Phase {CHOOSE, PLAY, GAMEOVER}

var player_scene = preload("res://scenes/characters/Player.tscn")
var enemy_scene = preload("res://scenes/characters/Enemy.tscn")

var ui_scene = preload("res://scenes/gui/YinYangUI.tscn")

var world
var game_ui
var player
var enemy
var state = Phase.CHOOSE

var first_blood = null

signal changed_state

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		node.free()
	create_players()
	create_world()
	init_ui()
	init_game()

func create_players():
	player = player_scene.instance()
	enemy = enemy_scene.instance()
	player.characterClass = global.selectedPlayerClass
	enemy.characterClass = global.selectedEnemyClass
	player.connect("character_defeated", self, "lose_game")
	enemy.connect("character_defeated", self, "win_game")
	# set initial energy
	player.energy = 0
	enemy.energy = 0

func create_world():
	world = global.worldScene.instance()
	add_child(world)
	world.spawn_players(player, enemy)
	world.init_camera()
	world.connect("pressed_hex", player, "on_pressed_hex")

func init_ui():
	game_ui = ui_scene.instance()
	add_child(game_ui)
	game_ui.init()
	game_ui.connect("accepted_stats", self, "on_ui_accepted_stats")
	player.connect("character_hit", game_ui, "update_health_counter")
	# enemy.connect("character_hit", game_ui, "update_health_counter")
	# game_ui.turn_time.connect("timeout", self, "on_turn_timeout")

func on_ui_accepted_stats(stats):
	player.selected_stats = stats
	play_phase()

func init_game():
	choose_phase()
	
func reset_turn():
	if state == Phase.GAMEOVER:
		return
	print("/ RESET TURN \\")
	player.selected_stats = null
	enemy.selected_stats = null
	yield(game_ui.reset(), "completed")

func choose_phase():
	if state == Phase.GAMEOVER:
		return
	print("\n*********************** CHOOSE PHASE")
	reset_turn()
	state = Phase.CHOOSE
	emit_signal("changed_state", Phase.CHOOSE)
	# restore energy
	player.restore_energy(5)
	enemy.restore_energy(5)
	game_ui.update_bars()
	# enemy choose movement
	enemy.choose_stats()
	# game_ui.turn_time.start()

func play_phase():
	if state != Phase.CHOOSE or state == Phase.GAMEOVER:
		return
	print("\n*********************** PLAY PHASE")
	state = Phase.PLAY
	emit_signal("changed_state", Phase.PLAY)
#	game_ui.turn_time.stop()
	# CONSUME ENERGY
	player.consume_energy(player.selected_stats["cost"])
	enemy.consume_energy(enemy.selected_stats["cost"])
	game_ui.update_bars()
	
	# DETERMINE TURN ORDER
	var turn_order = compare_cards()
	print("TURN ORDER ", turn_order)
	
	yield(game_ui.hide(), "completed")
	var first_char
	var first_message
	var second_message
	if turn_order[0] == player:
		first_char = "player"
		first_message = "Your turn"
		second_message = "Enemy Turn"
	else:
		first_char = "enemy"
		first_message = "Enemy turn"
		second_message = "Your turn"
	
	yield(game_ui.show_turn(first_message), "completed")
	# FIRST ON TURN
	turn_order[0].active = true
	turn_order[0].play_turn()
	yield(turn_order[0], "turn_ended")
	turn_order[0].active = false
	
	var attacked = check_attack(turn_order, 0)
	if attacked is GDScriptFunctionState:
		attacked = yield(attacked, "completed")
	
	if attacked == false:
		yield(game_ui.show_turn(second_message), "completed")
		# SECOND ON TURN
		turn_order[1].active = true
		turn_order[1].play_turn()
		yield(turn_order[1], "turn_ended")
		turn_order[1].active = false
		
		attacked = check_attack(turn_order, 1)
		if attacked is GDScriptFunctionState:
			attacked = yield(attacked, "completed")
	else:
		# SKIP SECOND ON TURN
		turn_order[1].end_turn()
	
	yield(get_tree().create_timer(0.5), "timeout")
	# BACK TO CHOOSE PHASE
	choose_phase()

func check_attack(turn_order, index):
	var attacker = turn_order[index]
	var defensor = turn_order[1 - index]
	
	if attacker.get_attack() <= 0:
		return false
	
	var is_adjacent = false
	var adjacent_hexes = attacker.get_cell().get_all_adjacent()
	for hex in adjacent_hexes:
		var pos = hex.get_axial_coords()
		if pos == defensor.hex_pos:
			is_adjacent = true
			break

	if not is_adjacent:
		return false

	print("AN ATTACK IS HAPPENNING !!!")
	var damage = attacker.get_attack() - defensor.get_defense()
	attacker.look_to_hex(defensor.hex_pos)
	defensor.look_to_hex(attacker.hex_pos)
	
	if defensor == self.enemy:
		yield(defensor.reveal_card(), "completed")
	
	if damage == 0 and attacker.characterClass.passiveHability == ClassResource.Passive.IGNORE_DEF:
		attacker.set_attack_advantage(true)
		damage = 1
	
	if damage > 0:
		# set first blood
		if first_blood == null:
			first_blood = attacker
		# play animation
		attacker.play_attack(attacker.get_attack())
		yield(attacker, "anim_hit")
		attacker.attacked(defensor)
		yield(defensor.play_hit(), "completed")
		defensor.hit(damage)
		return true
	else:
		# play animation
		attacker.play_attack(attacker.get_attack())
		yield(attacker, "anim_hit")
		yield(defensor.play_defend(defensor.get_defense()), "completed")
		yield(defensor.defended(attacker), "completed")
	
	attacker.look_to_hex(defensor.hex_pos)
	defensor.look_to_hex(attacker.hex_pos)
	return false

func compare_cards():
	# Compare the cards speed and return the turn order
	if player.advantage and not enemy.advantage:
		player.set_speed_advantage(false)
		return [player, enemy]
	elif enemy.advantage and not player.advantage:
		enemy.set_speed_advantage(false)
		return [enemy, player]
	
	if player.get_speed() != enemy.get_speed():
		if player.get_speed() > enemy.get_speed():
			return [player, enemy]
		else:
			return [enemy, player]
	else:
		if player.get_movement() != enemy.get_movement():
			if player.get_movement() > enemy.get_movement():
				return [player, enemy]
			else:
				return [enemy, player]
		else:
			randomize()
			if randi() % 2 == 0:
				return [player, enemy]
			else:
				return [enemy, player]

func choose_winner(_character):
	if player.get_remaining_health() == enemy.get_remaining_health():
		if first_blood == player:
			win_game(null, "You draw first blood")
		else:
			lose_game(null, "The opponent draw first blood")
	else:
		if player.get_remaining_health() > enemy.get_remaining_health():
			win_game(null, "You suffered less damage")
		else:
			lose_game(null, "You suffered more damage")

func win_game(_character, message="You defeated your opponent"):
	game_ui.show_game_over(true, message)
	reset_scene()

func lose_game(_character, message="You were defeated"):
	game_ui.show_game_over(false, message)
	reset_scene()

func reset_scene():
	state = Phase.GAMEOVER
	# get_tree().reload_current_scene()
