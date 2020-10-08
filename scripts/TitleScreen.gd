extends Control

onready var player_class = $Center/VBox/PlayerClass
onready var enemy_class = $Center/VBox/EnemyClass

# Called when the node enters the scene tree for the first time.
func _ready():
	init_class_options()

func init_class_options():
	var classes = ["Samurai", "Elite", "Monk"]
	
	for cls in classes:
		player_class.add_item(cls)
		enemy_class.add_item(cls)


func _on_PlayButton_pressed():
	# On play button pressed
	var game_scene = load("res://scenes/Game.tscn")
	global.set_player_class(player_class.selected)
	global.set_enemy_class(enemy_class.selected)
	get_tree().change_scene_to(game_scene)
