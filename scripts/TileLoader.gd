extends Object

class_name TileLoader

const GAME_TILES = {
	"wall": preload("res://scenes/world/tiles/Wall.tscn"),
	"grass": preload("res://scenes/world/tiles/Grass.tscn"),
	"sand": preload("res://scenes/world/tiles/Sand.tscn"),
	"box": preload("res://scenes/world/tiles/Box.tscn"),
	"flaming_box": preload("res://scenes/world/tiles/FlamingBox.tscn"),
}

static func get_tile(tile_name) :
	return GAME_TILES.get(tile_name)
