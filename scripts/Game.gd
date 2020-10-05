extends Node2D

var world_scene = preload("res://scenes/world/World.tscn")
var player_scene = preload("res://scenes/characters/Samurai.tscn")
var enemy_scene = preload("res://scenes/characters/EnemySamurai.tscn")

var ui_scene = preload("res://scenes/gui/GameUI.tscn")

var world

var game_ui

var player
var enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scene.instance()
	enemy = enemy_scene.instance()
	create_world()
	init_ui()
	init_game()

func create_world():
	world = world_scene.instance()
	add_child(world)
	world.spawn_players(player, enemy)

func init_ui():
	game_ui = ui_scene.instance()
	add_child(game_ui)
	game_ui.init()

func init_game():
	yield(game_ui.show_cards(), "completed")
	player.deal_cards(4)
	yield(game_ui.hide_cards(), "completed")
	# yield(game_ui.show_cards(), "completed")
