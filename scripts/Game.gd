extends Node2D

var world_scene = preload("res://scenes/world/World.tscn")
var player_scene = preload("res://scenes/characters/Samurai.tscn")
var enemy_scene = preload("res://scenes/characters/EnemySamurai.tscn")

var world

var player
var enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scene.instance()
	enemy = enemy_scene.instance()
	create_world()

func create_world():
	world = world_scene.instance()
	add_child(world)
	world.spawn_players(player, enemy)
