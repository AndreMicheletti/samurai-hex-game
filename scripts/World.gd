extends Node2D

const HEX_WIDTH = 50
const HEX_HEIGHT = 50

var HexGrid = preload("res://HexGrid.gd").new()
var HexCell = preload("res://HexCell.gd")

onready var tileset = $Tileset
onready var highlights = $Highlights

onready var window_size = get_viewport().size

export(Vector2) var worldZero = Vector2(0, 0)

export var world_size = 10

var click_enabled = false

signal pressed_hex

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(false)
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	generate_world(world_size)
	for charact in get_tree().get_nodes_in_group("Character"):
		charact.teleport_to(charact.hex_pos.x, charact.hex_pos.y)
	# $Camera2D.position = get_grid().get_hex_center(worldZero)

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
	world_size = size
	var grass = preload("res://scenes/tileset/Grass.tscn")
	var zeroCell = HexCell.new(worldZero)
	
	for cell in zeroCell.get_all_within(size):
		var grass_instance = grass.instance()
		grass_instance.position = HexGrid.get_hex_center(cell.get_axial_coords())
		tileset.add_child(grass_instance)
	HexGrid.set_bounds(Vector2(-size, -size), Vector2(size, size))


func is_outside_world(hex_pos : Vector2):
	if hex_pos.x > world_size or hex_pos.x < -world_size:
		return true
	if hex_pos.y > world_size or hex_pos.y < -world_size:
		return true
	return false

func set_click_enabled(value):
	$Highlight.visible = value
	click_enabled = value

func _unhandled_input(event):
	if click_enabled:
		if 'position' in event:
			var relative_pos = self.transform.affine_inverse() * event.position
			relative_pos.x -= (window_size.x / 2) 
			relative_pos.y -= (window_size.y / 2)
			relative_pos.x *= $Camera2D.zoom.x
			relative_pos.y *= $Camera2D.zoom.y
			var hex = get_grid().get_hex_at(relative_pos)
			
			$Highlight.position = get_grid().get_hex_center(hex)
			if event is InputEventScreenTouch:
				print("SCREEN TOUCH")
				print(event)
				emit_signal("pressed_hex", hex)
