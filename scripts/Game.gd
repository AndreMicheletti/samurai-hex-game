extends Node2D

enum Phase {DRAW, CHOOSE, PLAY}

var world_scene = preload("res://scenes/world/World.tscn")
var player_scene = preload("res://scenes/characters/Samurai.tscn")
var enemy_scene = preload("res://scenes/characters/EnemySamurai.tscn")

var ui_scene = preload("res://scenes/gui/GameUI.tscn")

var world
var game_ui
var player
var enemy
var state = Phase.DRAW

var first_draw = true

# Called when the node enters the scene tree for the first time.
func _ready():
	create_players()
	create_world()
	init_ui()
	init_game()

func create_players():
	player = player_scene.instance()
	enemy = enemy_scene.instance()
	player.connect("card_selected", self, "play_phase")

func create_world():
	world = world_scene.instance()
	add_child(world)
	world.spawn_players(player, enemy)

func init_ui():
	game_ui = ui_scene.instance()
	add_child(game_ui)
	game_ui.init()
	game_ui.connect("card_pressed", player, "on_select_card")
	game_ui.connect("card_pressed", self, "play_phase")

func init_game():
	draw_phase()

func draw_phase():
	print("\n*********************** DRAW PHASE")
	player.selected_card = null
	enemy.selected_card = null
	state = Phase.DRAW
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
	enemy.choose_card()

func play_phase():
	if state != Phase.CHOOSE:
		return
	print("\n*********************** PLAY PHASE")
	state = Phase.PLAY
	yield(game_ui.hide_cards(), "completed")
	var turn_order = compare_cards()
	print("TURN ORDER ", turn_order)
	# FIRST ON TURN
	turn_order[0].active = true
	turn_order[0].play_turn()
	yield(turn_order[0], "turn_ended")
	turn_order[0].active = false
	
	# SECOND ON TURN
	turn_order[0].active = true
	turn_order[1].play_turn()
	yield(turn_order[1], "turn_ended")
	turn_order[0].active = false
	
	# BACK TO DRAW PHASE
	draw_phase()

func compare_cards():
	# Compare the cards speed and return the turn order
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

