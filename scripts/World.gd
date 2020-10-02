extends Node2D

const HEX_WIDTH = 50
const HEX_HEIGHT = 50

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

var click_enabled = false
var world_walls_pos = []

signal pressed_hex

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(true)
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	generate_world(world_size)

func generate_world(size):
	world_size = size
	var zeroCell = HexCell.new(worldZero)
	get_grid().set_bounds(Vector2(-size, -size), Vector2(size, size))

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
			print("hex x/y ", $Highlight.position)
			# var path = get_grid().find_path(Vector2(0, 0), hex)
			# print(path.size())
			if is_outside_world(hex.get_axial_coords()):
				$Highlight.color = RED
			else:
				$Highlight.color = BLUE
			if event is InputEventScreenTouch:
				print("SCREEN TOUCH")
				print(event)
				emit_signal("pressed_hex", hex)
				$Samurai.move_to(hex.get_axial_coords())

func get_grid():
	return HexGrid
