extends Node2D


const HEX_WIDTH = 50
const HEX_HEIGHT = 50
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var HexCell = preload("res://HexCell.gd")
var HexGrid = preload("res://HexGrid.gd").new()
export var hex_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)

func move_to(x, y):
	hex_pos = Vector2(x, y)
	self.global_position = HexGrid.get_hex_center(hex_pos)
	
func get_cell():
	return HexCell.new(hex_pos)
