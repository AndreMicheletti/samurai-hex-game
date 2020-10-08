extends Node2D

enum Phase {DRAW, CHOOSE, PLAY, GAMEOVER}

var world_scene = preload("res://scenes/world/World.tscn")
var player_scene = preload("res://scenes/characters/Player.tscn")
var enemy_scene = preload("res://scenes/characters/Enemy.tscn")

var ui_scene = preload("res://scenes/gui/GameUI.tscn")

var world
var game_ui
var player
var enemy
var state = Phase.DRAW

var first_draw = true
var first_blood = null

signal changed_state

# Called when the node enters the scene tree for the first time.
func _ready():
	create_players()
	create_world()
	init_ui()
	init_game()

func create_players():
	player = player_scene.instance()
	enemy = enemy_scene.instance()
	player.characterClass = global.selectedPlayerClass
	enemy.characterClass = global.selectedEnemyClass
	player.connect("card_selected", self, "on_player_selected_card")
	player.connect("character_defeated", self, "lose_game")
	player.connect("deck_depleted", self, "choose_winner")
	enemy.connect("deck_depleted", self, "choose_winner")
	enemy.connect("character_defeated", self, "win_game")

func create_world():
	world = world_scene.instance()
	add_child(world)
	world.spawn_players(player, enemy)
	world.connect("pressed_hex", player, "on_pressed_hex")

func init_ui():
	game_ui = ui_scene.instance()
	add_child(game_ui)
	game_ui.init()
	game_ui.connect("card_pressed", player, "on_select_card")
	# game_ui.connect("card_pressed", self, "play_phase")
	player.connect("character_hit", game_ui, "update_health_counter")
	enemy.connect("character_hit", game_ui, "update_health_counter")

func init_game():
	draw_phase()

func draw_phase():
	print("\n*********************** DRAW PHASE")
	yield(game_ui.reset_center(), "completed")
	player.selected_card = null
	enemy.selected_card = null
	state = Phase.DRAW
	emit_signal("changed_state", Phase.DRAW)
	if first_draw:
		first_draw = false
		player.deal_cards(4)
		enemy.deal_cards(4)
	else:
		player.deal_cards(1)
		enemy.deal_cards(1)
	yield(game_ui.show_cards(), "completed")
	choose_phase()

func choose_phase():
	if state != Phase.DRAW:
		return
	print("\n*********************** CHOOSE PHASE")
	state = Phase.CHOOSE
	emit_signal("changed_state", Phase.CHOOSE)
	enemy.choose_card()

func play_phase():
	if state != Phase.CHOOSE:
		return
	print("\n*********************** PLAY PHASE")
	state = Phase.PLAY
	emit_signal("changed_state", Phase.PLAY)

	# DETERMINE TURN ORDER
	var turn_order = compare_cards()
	print("TURN ORDER ", turn_order)
	
	var first_char
	if turn_order[0] == player:
		first_char = "player"
	else:
		first_char = "enemy"

	yield(game_ui.reveal_faster_card(first_char), 'completed')		
	yield(game_ui.hide_cards(), "completed")
	
	# FIRST ON TURN
	turn_order[0].active = true
	turn_order[0].play_turn()
	yield(turn_order[0], "turn_ended")
	turn_order[0].active = false
	
	var attacked = check_attack(turn_order, 0)
	if attacked is GDScriptFunctionState:
		attacked = yield(attacked, "completed")
	
	if attacked == false:
		# SECOND ON TURN
		turn_order[1].active = true
		turn_order[1].play_turn()
		yield(turn_order[1], "turn_ended")
		turn_order[1].active = false
		
		check_attack(turn_order, 1)
	else:
		# SKIP SECOND ON TURN
		turn_order[1].end_turn()
	
	yield(get_tree().create_timer(0.8), "timeout")
	# BACK TO DRAW PHASE
	draw_phase()

func check_attack(turn_order, index):
	var attacker = turn_order[index]
	var defensor = turn_order[1 - index]
	
	if attacker.selected_card.atk <= 0:
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
	var damage = attacker.selected_card.atk - defensor.selected_card.def
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
		attacker.play_attack(attacker.selected_card)
		yield(attacker, "anim_hit")
		attacker.attacked(defensor)
		yield(defensor.play_hit(), "completed")
		defensor.hit(damage)
		return true
	else:
		# play animation
		attacker.play("attack_slash")
		yield(attacker, "anim_hit")
		yield(defensor.play_defend(), "completed")
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
	
	if player.selected_card.speed != enemy.selected_card.speed:
		if player.selected_card.speed > enemy.selected_card.speed:
			return [player, enemy]
		else:
			return [enemy, player]
	else:
		if player.selected_card.mov != enemy.selected_card.mov:
			if player.selected_card.mov > enemy.selected_card.mov:
				return [player, enemy]
			else:
				return [enemy, player]
		else:
			randomize()
			if randi() % 2 == 0:
				return [player, enemy]
			else:
				return [enemy, player]

func on_player_selected_card(_card):
	play_phase()

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
