extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	init_class_options()

func init_class_options():
	var classes = ["Samurai", "Elite", "Monk"]
	
	for cls in classes:
		$PlayerClass.add_item(cls)
		$EnemyClass.add_item(cls)


func _on_PlayButton_pressed():
	# On play button pressed
	var game_scene = load("res://scenes/Game.tscn")
	global.set_player_class($PlayerClass.selected)
	global.set_enemy_class($EnemyClass.selected)
	get_tree().change_scene_to(game_scene)
