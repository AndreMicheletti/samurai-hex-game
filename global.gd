extends Node

var classes = [
	preload("res://resources/classes/samurai.tres"),
	preload("res://resources/classes/elite.tres"),
	preload("res://resources/classes/monk.tres"),
]

var selectedPlayerClass = classes[0]
var selectedEnemyClass = classes[0]

func set_player_class(idx):
	selectedPlayerClass = classes[idx]

func set_enemy_class(idx):
	selectedEnemyClass = classes[idx]

func is_mobile():
	return OS.get_name() == "Android"
