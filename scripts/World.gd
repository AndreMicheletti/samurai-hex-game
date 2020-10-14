extends Node2D

const HEX_WIDTH = 34
const HEX_HEIGHT = 34

const BLUE = "#932959ff"
const RED = "#93ff2942"

var HexGrid = preload("res://scripts/HexGrid.gd").new()
var HexCell = preload("res://scripts/HexCell.gd")

onready var tileset = $Tileset
onready var window_size = get_viewport().size
onready var camera = $Camera2D

export(bool) var debug = false
export(bool) var generate = true

export(bool) var night = true

export(Vector2) var worldZero = Vector2(0, 0)
export(int) var world_size = 10
export(Vector2) var playerStart = Vector2(0, 0)
export(Vector2) var enemyStart = Vector2(0, 0)

export(int) var boxCount = 14

var back_scene = preload("res://scenes/world/background.tscn")
var highlight_scene = preload("res://scenes/world/Highlight.tscn")
var night_scene = preload("res://scenes/world/Night.tscn")

var click_enabled = false
export(Array, Vector2) var obstacles_coords = []

onready var zeroCell = HexCell.new(worldZero)
onready var game = get_parent()

signal pressed_hex

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(true)
	init_world()
	build_background()
	if generate:
		generate_world(world_size)
	if not debug:
		build_highlights()
	discover_obstacles()
	create_night()

func init_world():
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	get_grid().set_bounds(Vector2(-world_size, -world_size), Vector2(world_size, world_size))

func build_highlights():
	if global.is_mobile():
		return
	for tile in get_tree().get_nodes_in_group("Tile"):
		if not tile.passable:
			continue
		var coords = tile.hex_pos
		var block = highlight_scene.instance()
		block.hex_pos = coords
		$Highlights.add_child(block)
		block.init(self)

func build_background():
	var block_size = 64
	var width = (window_size.x / block_size) + 1
	var height = (window_size.y / block_size) + 1
	for x in range(width):
		for y in range(height):
			var node = back_scene.instance()
			var pos = Vector2()
			pos.x = (x * block_size) - (window_size.x / 2)
			pos.y = (y * block_size) - (window_size.y / 2)
			$Backgrounds.add_child(node)
			node.position = pos

func discover_obstacles():
	for node in get_tree().get_nodes_in_group("ObstacleTile"):
		obstacles_coords.append(node.hex_pos)
	get_grid().add_obstacles(obstacles_coords)

func create_night():
	var night = night_scene.instance()
	add_child(night)

func generate_world(size):
	# build walls
	var outer_walls = zeroCell.get_ring(size+1)	
	var wall = TileLoader.get_tile("wall")
	var grass = TileLoader.get_tile("grass")
	var box = TileLoader.get_tile("box")

	for cell in outer_walls:
		var block = wall.instance()
		block.position = HexGrid.get_hex_center(cell.get_axial_coords())
		block.hex_pos = cell.get_axial_coords()
		$Tileset.add_child(block)
	
	# build grass
	for cell in zeroCell.get_all_within(size):
		var block = grass.instance()
		block.position = get_grid().get_hex_center(cell.get_axial_coords())
		block.hex_pos = cell.get_axial_coords()
		$Tileset.add_child(block)
	
	# build boxes
	var available = []
	for hex in zeroCell.get_all_within(size):
		var coords = hex.get_axial_coords()
		if coords != playerStart and coords != enemyStart:
			available.append(coords)
	available.shuffle()
	
	for n in range(boxCount):
		randomize()
		var idx = randi() % available.size()
		var selected = available[idx]
		available.remove(idx)
		var block = box.instance()
		block.position = get_grid().get_hex_center(selected)
		block.hex_pos = selected
		$Tileset.add_child(block)

func spawn_players(player, enemy):
	# add instances
	add_child(player)
	add_child(enemy)
	# teleport them
	player.teleport_to(playerStart)
	enemy.teleport_to(enemyStart)
	# make them look to each other
	player.look_to_hex(enemy.hex_pos)
	enemy.look_to_hex(player.hex_pos)

func init_camera():
	camera.init_camera()

func find_path(start, goal):
	var exceptions = []
	for charact in get_tree().get_nodes_in_group("Character"):
		if charact.hex_pos == start:
			continue
		exceptions.append(charact.hex_pos)
	return HexGrid.find_path(start, goal, exceptions)

func is_obstacle(hex_pos : Vector2):
	if hex_pos.x > world_size or hex_pos.x < -world_size:
		return true
	if hex_pos.y > world_size or hex_pos.y < -world_size:
		return true
	if hex_pos in obstacles_coords:
		return true
	return false

func set_click_enabled(value):
	print("SET WORLD CLICK ENABLED TO ", value)
	set_process_input(value)
	$Highlight.visible = value
	click_enabled = value

func _unhandled_input(event):
	if click_enabled:
		if 'position' in event:
#			var relative_pos = self.transform.affine_inverse() * event.position
#			relative_pos += camera.global_position
#			relative_pos.x -= (window_size.x / 2) 
#			relative_pos.y -= (window_size.y / 2)
#			relative_pos.x *= camera.zoom.x
#			relative_pos.y *= camera.zoom.y
#			relative_pos.x -= camera.position.x
#			relative_pos.y -= camera.position.y
#			print("camera pos ", camera.get_global_mouse_position())
			var relative_pos = camera.get_global_mouse_position()
			var hex = get_grid().get_hex_at(relative_pos)
			# print("poiting at hex ", hex.get_axial_coords())
#			if not $Samurai.moving:
#				$Samurai.look_to_hex(hex.get_axial_coords())
			
			$Highlight.position = get_grid().get_hex_center(hex)
#			print("hex x/y ", $Highlight.position)
			# var path = get_grid().find_path(Vector2(0, 0), hex)
			# print(path.size())
			if is_obstacle(hex.get_axial_coords()):
				$Highlight.color = RED
			else:
				$Highlight.color = BLUE
			if event is InputEventScreenTouch:
#				print("SCREEN TOUCH")
#				print(event)
				emit_signal("pressed_hex", hex)
				# $Samurai.move_to(hex.get_axial_coords())

func get_grid():
	return HexGrid
