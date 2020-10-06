extends Node2D

const HEX_WIDTH = 34
const HEX_HEIGHT = 34

const BLUE = "#932959ff"
const RED = "#93ff2942"

var HexGrid = preload("res://scripts/HexGrid.gd").new()
var HexCell = preload("res://scripts/HexCell.gd")

onready var tileset = $Tileset
onready var window_size = get_viewport().size

export(Vector2) var worldZero = Vector2(0, 0)
export(int) var world_size = 10
export(Vector2) var playerStart = Vector2(0, 0)
export(Vector2) var enemyStart = Vector2(0, 0)

var tile_scene = preload("res://scenes/world/Tile.tscn")
var back_scene = preload("res://scenes/world/background.tscn")
var highlight_scene = preload("res://scenes/world/Highlight.tscn")

var click_enabled = false
var world_walls_pos = []

onready var game = get_parent()

signal pressed_hex

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(true)
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	build_background()
	generate_world(world_size)

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

func generate_world(size):
	world_size = size
	var zeroCell = HexCell.new(worldZero)
	get_grid().set_bounds(Vector2(-size, -size), Vector2(size, size))
	
	# build walls
	var outer_walls = zeroCell.get_ring(size+1)
	get_grid().add_obstacles(outer_walls)
	for cell in outer_walls:
		var block = tile_scene.instance()
		block.tile_type = Tile.TileType.WALL
		block.position = HexGrid.get_hex_center(cell.get_axial_coords())
		$Tileset.add_child(block)
	
	# build grass
	for cell in zeroCell.get_all_within(size):
		var block = tile_scene.instance()
		block.tile_type = Tile.TileType.GRASS
		block.position = get_grid().get_hex_center(cell.get_axial_coords())
		$Tileset.add_child(block)
		
		# also add highlight
		var block_2 = highlight_scene.instance()
		block_2.hex_pos = cell.get_axial_coords()
		$Highlights.add_child(block_2)
		block_2.init(self)

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
	if hex_pos in world_walls_pos:
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
			var relative_pos = self.transform.affine_inverse() * event.position
			relative_pos.x -= (window_size.x / 2) 
			relative_pos.y -= (window_size.y / 2)
			relative_pos.x *= $Camera2D.zoom.x
			relative_pos.y *= $Camera2D.zoom.y
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
