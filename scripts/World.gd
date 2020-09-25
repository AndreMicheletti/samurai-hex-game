extends Node

const HEX_WIDTH = 50
const HEX_HEIGHT = 50

var HexGrid = preload("res://HexGrid.gd").new()
onready var tileset = $Tileset

onready var highlights = $Highlights


# Called when the node enters the scene tree for the first time.
func _ready():
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	generate_world(10)


func generate_world(size):
	
	var grass = preload("res://scenes/tileset/Grass.tscn")
	
	for x in range(-size, size+1):
		for y in range (-size, size+1):
			var pos = Vector2(x, y)
			var grass_instance = grass.instance()
			grass_instance.position = HexGrid.get_hex_center(pos)
			tileset.add_child(grass_instance)


#func _on_Area2D_input_event(viewport, event, shape_idx):
	#if "position" in event:
		#var relative_pos = self.transform.affine_inverse() * event.global_position
		# Display the coords used
		#if area_coords != null:
		#	area_coords.text = str(relative_pos)
		#if hex_coords != null:
		#	hex_coords.text = str(HexGrid.get_hex_at(relative_pos).axial_coords)
		# Snap the highlight to the nearest grid cell
		#if highlight != null:
		#	highlight.position = HexGrid.get_hex_center(HexGrid.get_hex_at(relative_pos))
