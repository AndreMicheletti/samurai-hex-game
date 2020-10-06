extends Node2D

class_name Tile

enum TileType {GRASS, SAND, WALL, BOX}

export(TileType) var tile_type

# Called when the node enters the scene tree for the first time.
func _ready():
	var grass_tiles = ["grass1.png", "grass2.png", "grass3.png"]
	var sand_tiles = ["sand1.png", "sand2.png"]
	var wall_tiles = ["wall1.png"]
	var box_tiles = ["box1.png"]
	match tile_type:
		TileType.GRASS:
			select_texture(grass_tiles)
		TileType.SAND:
			select_texture(sand_tiles)
		TileType.WALL:
			select_texture(wall_tiles)
		TileType.BOX:
			select_texture(box_tiles)
			scale = Vector2(.85, .85)

func select_texture(list):
	var file_path = list[0]
	if list.size() > 1:
		randomize()
		file_path = list[randi() % list.size()]
	var texture_path = load("res://graphics/world/" + file_path)
	$Sprite.texture = texture_path


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
