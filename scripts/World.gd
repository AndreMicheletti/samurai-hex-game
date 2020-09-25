extends Node

const HEX_WIDTH = 50
const HEX_HEIGHT = 50

var HexGrid = preload("res://HexGrid.gd").new()
var HexCell = preload("res://HexCell.gd")
onready var tileset = $Tileset

onready var highlights = $Highlights

export(Vector2) var worldZero = Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	generate_world(10)
	for charact in get_tree().get_nodes_in_group("Character"):
		charact.teleport_to(charact.hex_pos.x, charact.hex_pos.y)

func get_grid():
	#HexGrid.remove_all_obstacles()
	#for charact in get_tree().get_nodes_in_group("Character"):
	#	HexGrid.add_obstacles(charact.hex_pos)
	return HexGrid


func find_path(start, goal):
	var exceptions = []
	for charact in get_tree().get_nodes_in_group("Character"):
		if charact.hex_pos == start:
			continue
		exceptions.append(charact.hex_pos)
	#print("FIND PATH !! ", start, " to ", goal)
	return HexGrid.find_path(start, goal, exceptions)


func generate_world(size):
	
	var grass = preload("res://scenes/tileset/Grass.tscn")
	var zeroCell = HexCell.new(worldZero)
	
	for cell in zeroCell.get_all_within(size):
		var grass_instance = grass.instance()
		grass_instance.position = HexGrid.get_hex_center(cell.get_axial_coords())
		tileset.add_child(grass_instance)
	HexGrid.set_bounds(Vector2(-size, -size), Vector2(size, size))


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
