extends "res://scripts/MapObject.gd"


export(NodePath) var highlights_path = null

onready var highlights = get_node(highlights_path)

var move_hint = preload("res://scenes/tileset/MoveHint.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to(0, 0)


func _process(delta):
	pass
