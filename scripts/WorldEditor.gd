extends Node2D

const HEX_WIDTH = 34
const HEX_HEIGHT = 34

const BLUE = "#932959ff"
const RED = "#93ff2942"

var HexGrid = preload("res://scripts/HexGrid.gd").new()
var HexCell = preload("res://scripts/HexCell.gd")

onready var map_scene = $World
onready var tileset = $World/Tileset
onready var camera = $World/Camera2D
onready var highlight = $Highlight
onready var window_size = get_viewport().size

onready var mapsize_label = $UI/Params/Panel/Margin/VBox/MapSizeLabel
onready var mapsize_input = $UI/Params/Panel/Margin/VBox/MapSize
onready var tile_select = $UI/Params/Panel/Margin/VBox/TileSelect
onready var obstacle_checkbox = $UI/Params/Panel/Margin/VBox/TileObstacle

onready var filename_input = $UI/Params/Panel/Margin/VBox/FileName

onready var popup = $UI/Popup

onready var p_start = $PlayerStart
onready var e_start = $EnemyStart

export(Vector2) var worldZero = Vector2(0, 0)
export(int) var world_size = 10
export(Vector2) var playerStart = Vector2(0, 1)
export(Vector2) var enemyStart = Vector2(0, -1)

var tile_scene = preload("res://scenes/world/Tile.tscn")
var back_scene = preload("res://scenes/world/background.tscn")
var highlight_scene = preload("res://scenes/world/Highlight.tscn")

var click_enabled = false
var obstacles_coords = []

var tile_options = [
	{"name": "player_start", "type": "p_start"},
	{"name": "enemy_start", "type": "e_start"},
	{"name": "box", "type": Tile.TileType.BOX},
	{"name": "wall", "type": Tile.TileType.WALL},
	{"name": "grass", "type": Tile.TileType.GRASS},
]

var tileset_mapper = {}
var obstacle_mapper = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_click_enabled(true)
	HexGrid.hex_scale = Vector2(HEX_WIDTH, HEX_HEIGHT)
	_on_MapSize_changed(null)
	for option in tile_options:
		tile_select.add_item(option["name"])
	move_player_enemy_starts()

func move_player_enemy_starts():
	p_start.position = HexGrid.get_hex_center(playerStart)
	e_start.position = HexGrid.get_hex_center(enemyStart)

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
			var relative_pos = self.transform.affine_inverse() * event.position
			relative_pos.x -= (window_size.x / 2) 
			relative_pos.y -= (window_size.y / 2)
			relative_pos.x *= camera.zoom.x
			relative_pos.y *= camera.zoom.y
			var hex = get_grid().get_hex_at(relative_pos)
			var hex_coords = cleanup_vector2(hex.get_axial_coords())
			highlight.get_child(1).text = str(hex_coords)
			# print("poiting at hex ", )
#			if not $Samurai.moving:
#				$Samurai.look_to_hex(hex.get_axial_coords())
			
			highlight.position = get_grid().get_hex_center(hex)
#			print("hex x/y ", $Highlight.position)
			# var path = get_grid().find_path(Vector2(0, 0), hex)
			# print(path.size())
			if is_obstacle(hex.get_axial_coords()):
				highlight.get_child(0).color = RED
			else:
				highlight.get_child(0).color = BLUE
			if event is InputEventMouseButton:
				if event.pressed == false:
					if event.button_index == 1:
						on_add(hex_coords)
					else:
						on_remove(hex_coords)

func get_grid():
	return HexGrid

func cleanup_vector2(vec: Vector2):
	var aux_vec = Vector2(vec.x, vec.y)
	if vec.x == -0:
		aux_vec.x = 0
	if vec.y == -0:
		aux_vec.y = 0
	return aux_vec

func _on_MapSize_changed(new_val):
	print("MAP SIZE CHANGED")
	world_size = mapsize_input.value
	mapsize_label.text = "Map Size: " + str(mapsize_input.value)

func on_add(hex_coords):
	var selected_tile = get_selected_tile()
	print("PRESSED ON HEX ", hex_coords)
	print("SELECTED TILE IS ", selected_tile)
	if is_obstacle(hex_coords):
		print("CANNOT ADD TILE TO THIS POSITION")
		return
	
	if selected_tile["type"] is String and selected_tile["type"] == "p_start":
		playerStart = hex_coords
		move_player_enemy_starts()
		return
	if selected_tile["type"] is String and selected_tile["type"] == "e_start":
		enemyStart = hex_coords
		move_player_enemy_starts()
		return
	
	var mapper = tileset_mapper
	if obstacle_checkbox.pressed:
		mapper = obstacle_mapper

	if mapper.get(hex_coords) == null:
		var selected_tile_type = selected_tile["type"]
		var block = tile_scene.instance()
		block.tile_type = selected_tile_type
		block.position = HexGrid.get_hex_center(hex_coords)
		block.hex_pos = hex_coords
		tileset.add_child(block)
		mapper[hex_coords] = {
			"type": selected_tile_type,
			"node": block
		}
		block.owner = map_scene

func on_remove(hex_coords):
	var mapper = tileset_mapper
	if obstacle_checkbox.pressed:
		mapper = obstacle_mapper

	if mapper.has(hex_coords):
		var node = mapper[hex_coords]["node"]
		node.free()
		mapper.erase(hex_coords)

func get_selected_tile():
	return tile_options[tile_select.selected]

func _on_SaveButton_pressed():
	var resource_name = "res://resources/maps/" + filename_input.text + ".tscn"
	# set owners
	for child in map_scene.get_children():
		child.owner = map_scene
	# add scrpt
	var world_script = load("res://scripts/World.gd")
	map_scene.set_script(world_script)
	map_scene.playerStart = playerStart
	map_scene.enemyStart = enemyStart
	map_scene.world_size = world_size
	map_scene.generate = false
	# add obstacles to scene
	map_scene.obstacles_coords = obstacle_mapper.keys()
	# pack scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(map_scene)
	if result == OK:
		var error = ResourceSaver.save(resource_name, packed_scene)
		if error != OK:
			show_popup("An error occurred while saving the scene to disk.")
		else:
			show_popup("Scene has saved sucessfully to " + resource_name)
	else:
		show_popup("Error on packing scene")

func show_popup(message):
	popup.get_child(0).text = message
	popup.popup()
	yield(get_tree().create_timer(2), "timeout")
	popup.hide()
