extends Node2D

const HEX_WIDTH = 50
const HEX_HEIGHT = 50

const BLUE = "#932959ff"
const RED = "#93ff2942"

var HexGrid = preload("res://HexGrid.gd").new()
var HexCell = preload("res://HexCell.gd")

onready var tileset = $Tileset
onready var highlights = $Highlights

onready var window_size = get_viewport().size

export(Vector2) var worldZero = Vector2(0, 0)

export var world_size = 10

var click_enabled = false
var world_walls_pos = []

signal pressed_hex

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(true)
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	generate_world(world_size)
	for charact in get_tree().get_nodes_in_group("Character"):
		charact.teleport_to(charact.hex_pos.x, charact.hex_pos.y)
	# $Camera2D.position = get_grid().get_hex_center(worldZero)
	# print_borders_debug()

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
	var wall = preload("res://scenes/tileset/Wall.tscn")
	var zeroCell = HexCell.new(worldZero)
	
	# build walls
	var outer_walls = zeroCell.get_ring(size+1)
	for hex in outer_walls:
		world_walls_pos.append(hex.get_axial_coords())
	get_grid().add_obstacles(outer_walls)
	for cell in outer_walls:
		var block = wall.instance()
		block.position = HexGrid.get_hex_center(cell.get_axial_coords())
		$Wall.add_child(block)
	
	# build grass
	for cell in zeroCell.get_all_within(size):
		var grass_instance = grass.instance()
		grass_instance.position = HexGrid.get_hex_center(cell.get_axial_coords())
		tileset.add_child(grass_instance)
	get_grid().set_bounds(Vector2(-size, -size), Vector2(size, size))


func is_outside_world(hex_pos : Vector2):
	if hex_pos.x > world_size or hex_pos.x < -world_size:
		return true
	if hex_pos.y > world_size or hex_pos.y < -world_size:
		return true
	if hex_pos in world_walls_pos:
		return true
	return false

func set_click_enabled(value):
	set_process_input(value)
	$Highlight.visible = value
	click_enabled = value

func print_borders_debug():
	var node = preload("res://scenes/tileset/Highlight.tscn")
	var n_size = world_size
	for x in range(-n_size, n_size):
		for y in range(-n_size, n_size):
			var coords = Vector2(x, y)
			var instance = node.instance()
			add_child(instance)
			instance.position = get_grid().get_hex_center(coords)
			var path = get_grid().find_path(Vector2(0, 0), coords)
			# print(path.size())
			if path.size() <= 0:
				instance.color = RED
			else:
				instance.color = BLUE
			

func _unhandled_input(event):
	if click_enabled:
		if 'position' in event:
			var relative_pos = self.transform.affine_inverse() * event.position
			relative_pos.x -= (window_size.x / 2) 
			relative_pos.y -= (window_size.y / 2)
			relative_pos.x *= $Camera2D.zoom.x
			relative_pos.y *= $Camera2D.zoom.y
			var hex = get_grid().get_hex_at(relative_pos)
			# print("poiting at hex ", hex.get_axial_coords())
			
			$Highlight.position = get_grid().get_hex_center(hex)
			# var path = get_grid().find_path(Vector2(0, 0), hex)
			# print(path.size())
			if is_outside_world(hex.get_axial_coords()):
				$Highlight.color = RED
			else:
				$Highlight.color = BLUE
			if event is InputEventScreenTouch:
				#print("SCREEN TOUCH")
				#print(event)
				emit_signal("pressed_hex", hex)
