extends Control

onready var player_class = $Center/VBox/PlayerClass
onready var enemy_class = $Center/VBox/EnemyClass
onready var map_select = $Center/VBox/MapSelect

var maps

# Called when the node enters the scene tree for the first time.
func _ready():
	init_class_options()

func init_class_options():
	var classes = ["Samurai", "Elite", "Monk"]
	map_select.add_item("generate new map")
	
	for cls in classes:
		player_class.add_item(cls)
		enemy_class.add_item(cls)
	
	maps = dir_files("res://resources/maps")
	for file in maps:
		print(file)
		map_select.add_item(file)

func _on_PlayButton_pressed():
	# On play button pressed
	var map_idx = map_select.selected
	var game_scene = load("res://scenes/Game.tscn")
	var world_scene
	if map_idx == 0:
		world_scene = "res://scenes/world/World.tscn"
	else:
		var map_name = maps[map_idx - 1]
		world_scene = "res://resources/maps/" + map_name
	global.set_player_class(player_class.selected)
	global.set_enemy_class(enemy_class.selected)
	global.worldScene = world_scene
	get_tree().change_scene_to(game_scene)

func dir_files(path):
	var result = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				result.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return result
