extends Node2D


const HEX_WIDTH = 50
const HEX_HEIGHT = 50

var HexCell = preload("res://HexCell.gd")
var HexGrid = preload("res://HexGrid.gd").new()
export var hex_pos = Vector2()

signal character_moved

# Called when the node enters the scene tree for the first time.
func _ready():
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	move_to(hex_pos.x, hex_pos.y)

func move_to(x, y):
	hex_pos = Vector2(x, y)
	self.global_position = HexGrid.get_hex_center(hex_pos)
	emit_signal("character_moved")
	
func get_cell():
	return HexCell.new(hex_pos)
