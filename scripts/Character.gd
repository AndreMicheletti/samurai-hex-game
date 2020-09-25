extends Node2D

var HexCell = preload("res://HexCell.gd")

export(Vector2) var hex_pos = Vector2()

signal character_moved

export var DamageLimit = 4
var damage = 0

var turn_atk = 0
var turn_def = 0
var turn_mov = 0
export var moved = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Character")
	self.damage = 0

func get_world():
	return get_tree().get_nodes_in_group("World")[0]

func move_to(x, y):
	hex_pos = Vector2(x, y)
	self.position = get_world().get_grid().get_hex_center(hex_pos)
	emit_signal("character_moved")

func get_cell():
	return HexCell.new(hex_pos)

func set_turn_stats(card : CardResource):
	print("SET TURN STATS ", card)
	turn_mov = card.card_mov
	turn_atk = card.card_atk
	turn_def = card.card_def
